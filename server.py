#!/usr/bin/env python3
"""WonderForge v0.5: per-user, loopback-only local portal and bounded sharing API.

Never run as a network service, never use sudo for app launches. Browser state
is not a security boundary; Linux accounts and the filesystem are.
"""
from __future__ import annotations

import argparse
from contextlib import contextmanager
import json
import sqlite3
import logging
import os
import pwd
import re
import secrets
import shutil
import stat
import subprocess
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit, parse_qs
from portal_security import PortalAuth, COOKIE_NAME
import device_health
import local_ai

ROOT = Path(__file__).resolve().parent
APP_NAME = 'WonderForge/0.7'
MAX_POST = 262144
MAX_TEAM_NOTE = 9000
ID_PATTERN = re.compile(r'^[a-f0-9]{24}$')
APPS = {
    'luanti': ('Luanti / ForgeVerse', ('luanti', 'minetest')),
    'thonny': ('Thonny Python', ('thonny',)),
    'krita': ('Krita', ('krita',)),
    'gimp': ('GIMP', ('gimp',)),
    'inkscape': ('Inkscape', ('inkscape',)),
    'openscad': ('OpenSCAD', ('openscad',)),
    'kicad': ('KiCad', ('kicad',)),
    'stellarium': ('Stellarium', ('stellarium',)),
    'audacity': ('Audacity', ('audacity',)),
    'godot': ('Godot', ('godot', 'godot4')),
    'scratch': ('Scratch', ('scratch3', 'scratch')),
}


def catalog_routes():
    route_map = {
        '/': ('web/index.html', 'text/html; charset=utf-8'),
        '/web/index.html': ('web/index.html', 'text/html; charset=utf-8'),
        '/web/styles.css': ('web/styles.css', 'text/css; charset=utf-8'),
        '/web/app.js': ('web/app.js', 'text/javascript; charset=utf-8'),
        '/web/labs.js': ('web/labs.js', 'text/javascript; charset=utf-8'),
        '/web/journal.js': ('web/journal.js', 'text/javascript; charset=utf-8'),
        '/data/learning.json': ('data/learning.json', 'application/json; charset=utf-8'),
        '/data/quests.json': ('data/quests.json', 'application/json; charset=utf-8'),
        '/data/apps.json': ('data/apps.json', 'application/json; charset=utf-8'),
    }
    for item in (ROOT / 'web' / 'assets').glob('*'):
        if not item.is_file() or item.is_symlink():
            continue
        mime = {'webp': 'image/webp', 'svg': 'image/svg+xml', 'png': 'image/png', 'jpg': 'image/jpeg'}.get(item.suffix.lower().lstrip('.'))
        if mime:
            route_map['/web/assets/' + item.name] = ('web/assets/' + item.name, mime)
    return route_map


ROUTES = catalog_routes()


def username():
    return pwd.getpwuid(os.geteuid()).pw_name


def team_path():
    return Path(os.environ.get('WONDERFORGE_TEAM_DIR', '/srv/wonderforge/team'))


def state_db_path():
    """Private account data; never stored inside the root-owned app tree."""
    base = Path(os.environ.get('WONDERFORGE_STATE_DIR', str(Path.home() / '.local' / 'share' / 'wonderforge')))
    base.mkdir(mode=0o700, parents=True, exist_ok=True)
    if base.is_symlink():
        raise PermissionError('State directory must not be a symlink')
    os.chmod(base, 0o700)
    return base / 'workshop.sqlite3'


@contextmanager
def state_db():
    path = state_db_path()
    if path.is_symlink():
        raise PermissionError('State database must not be a symlink')
    con = sqlite3.connect(str(path), timeout=5)
    os.chmod(path, 0o600)
    con.execute('PRAGMA busy_timeout = 4000')
    try:
        con.execute('CREATE TABLE IF NOT EXISTS state (key TEXT PRIMARY KEY, value TEXT NOT NULL, updated TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)')
        with con:
            yield con
    finally:
        con.close()


STATE_KEY = re.compile(r'^wf-reforged:v3:(?:(?:quests|projects|blocks|logic-completed|logic-program|chat|labs|journal):(?:atlas|nova|team)|prefs|last-profile)$')
MAX_STATE_VALUE = 180000

def approved_executable(candidates):
    """Use only executable system package paths, not user-controlled $PATH."""
    for name in candidates:
        for parent in ('/usr/bin', '/usr/games', '/bin'):
            path = Path(parent) / name
            try:
                resolved = path.resolve(strict=True)
                st = resolved.stat()
                if st.st_uid == 0 and not st.st_mode & 0o022 and stat.S_ISREG(st.st_mode) and os.access(resolved, os.X_OK):
                    return str(path)
            except OSError:
                continue
    return None


def available_apps():
    return [
        {'id': ident, 'name': title, 'installed': approved_executable(commands) is not None}
        for ident, (title, commands) in APPS.items()
    ]


class Handler(BaseHTTPRequestHandler):
    server_version = APP_NAME
    _launch_lock = threading.Lock()
    _share_lock = threading.Lock()
    _last_launch = {}

    def _allowed_host(self):
        hostname = self.headers.get('Host', '')
        port = self.server.server_address[1]
        return hostname in (f'127.0.0.1:{port}', f'localhost:{port}')

    def _security_headers(self):
        self.send_header('Cache-Control', 'no-store, private')
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('X-Frame-Options', 'DENY')
        self.send_header('Referrer-Policy', 'no-referrer')
        self.send_header('Cross-Origin-Resource-Policy', 'same-origin')
        self.send_header('Permissions-Policy', 'camera=(), microphone=(), geolocation=(), payment=()')
        self.send_header('Content-Security-Policy',
                         "default-src 'none'; script-src 'self'; style-src 'self' 'unsafe-inline'; "
                         "img-src 'self' data:; connect-src 'self'; base-uri 'none'; form-action 'self'; "
                         "object-src 'none'; frame-ancestors 'none'")

    def _reply(self, code, data, content_type='application/json; charset=utf-8'):
        if isinstance(data, (dict, list)):
            raw = json.dumps(data, ensure_ascii=False, separators=(',', ':')).encode('utf-8')
        elif isinstance(data, str):
            raw = data.encode('utf-8')
        else:
            raw = data
        self.send_response(code)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(len(raw)))
        self._security_headers()
        self.end_headers()
        try:
            self.wfile.write(raw)
        except (BrokenPipeError, ConnectionResetError):
            pass

    def _reject(self, code, msg):
        self._reply(code, {'ok': False, 'error': msg})

    def _shared_enabled(self):
        path = team_path()
        return path.is_dir() and os.access(path, os.R_OK | os.X_OK)

    def _read_team(self):
        if not self._shared_enabled():
            return []
        result = []
        for path in list(team_path().glob('*.json'))[:200]:
            if not ID_PATTERN.fullmatch(path.stem) or path.is_symlink():
                continue
            try:
                if path.stat().st_size > MAX_POST:
                    continue
                item = json.loads(path.read_text('utf-8'))
                if item.get('id') != path.stem or item.get('kind') not in ('notebook', 'blueprint'):
                    continue
                result.append({k: item.get(k) for k in ('id', 'kind', 'title', 'author', 'created')})
            except (OSError, UnicodeError, ValueError):
                continue
        return sorted(result, key=lambda x: x.get('created', ''), reverse=True)[:100]

    def _authenticated(self):
        auth = getattr(self.server, 'auth', None)
        return auth is None or auth.authenticated(self.headers.get('Cookie', ''))

    def do_GET(self):
        if not self._allowed_host():
            return self._reject(403, 'Invalid localhost host')
        parsed = urlsplit(self.path)
        path = parsed.path
        # A one-use ticket immediately becomes an HttpOnly SameSite cookie.
        # After the redirect, the URL and browser history contain no capability.
        auth = getattr(self.server, 'auth', None)
        if auth is not None and path == '/' and 'ticket' in parse_qs(parsed.query):
            session = auth.claim(parse_qs(parsed.query).get('ticket', [''])[0])
            if session is None:
                return self._reject(403, 'Portal ticket expired or already used')
            self.send_response(303)
            self.send_header('Location', '/')
            self.send_header('Set-Cookie', COOKIE_NAME+'='+session+'; HttpOnly; SameSite=Strict; Path=/')
            self._security_headers()
            self.send_header('Content-Length', '0')
            self.end_headers()
            return
        if path.startswith('/api/') and not self._authenticated():
            return self._reject(401, 'Authenticate through the signed-in Linux session')
        if path == '/api/session':
            user = username()
            return self._reply(200, {'ok': True, 'username': user,
                                     'profile': user if user in ('atlas', 'nova') else None,
                                     'linux_identity_enforced': user in ('atlas', 'nova'),
                                     'team_available': self._shared_enabled(),
                                     'apps_available': True,
                                     'version': '0.7'})
        if path == '/api/state':
            try:
                with state_db() as db:
                    items = {key: json.loads(val) for key, val in db.execute('SELECT key, value FROM state')}
                return self._reply(200, {'ok': True, 'state': items, 'persistent': True})
            except (OSError, sqlite3.Error, ValueError) as exc:
                logging.warning('Unable to read account state: %s', exc)
                return self._reject(503, 'Private account storage unavailable')
        if path == '/api/ai/status':
            return self._reply(200, {'ok': True, 'ai': local_ai.status()})
        if path == '/api/health':
            return self._reply(200, {'ok': True, 'health': device_health.sample()})
        if path == '/api/apps':
            return self._reply(200, {'ok': True, 'apps': available_apps(), 'launch_requires_click': True})
        if path == '/api/shared':
            return self._reply(200, {'ok': True, 'enabled': self._shared_enabled(), 'items': self._read_team()})
        if path.startswith('/api/shared/'):
            ident = path.split('/')[-1]
            if not ID_PATTERN.fullmatch(ident) or not self._shared_enabled():
                return self._reject(404, 'Not found')
            filename = team_path() / (ident + '.json')
            try:
                fd = os.open(str(filename), os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0))
                try:
                    if not stat.S_ISREG(os.fstat(fd).st_mode) or os.fstat(fd).st_size > MAX_POST:
                        return self._reject(404, 'Not found')
                    data = json.loads(os.read(fd, MAX_POST + 1))
                finally:
                    os.close(fd)
                if data.get('id') != ident or data.get('kind') not in ('notebook', 'blueprint'):
                    return self._reject(404, 'Not found')
                return self._reply(200, {'ok': True, 'item': data})
            except (OSError, UnicodeError, ValueError):
                return self._reject(404, 'Not found')
        entry = ROUTES.get(path)
        if not entry:
            return self._reject(404, 'Not found')
        relative, content_type = entry
        try:
            raw = (ROOT / relative).read_bytes()
        except OSError:
            return self._reject(503, 'Local content unavailable')
        return self._reply(200, raw, content_type)

    def _accept_post(self):
        port = self.server.server_address[1]
        if self.headers.get('Origin') not in (f'http://127.0.0.1:{port}', f'http://localhost:{port}'):
            return False, 'Same-origin request required'
        if self.headers.get('Sec-Fetch-Site', 'same-origin') not in ('same-origin', 'none'):
            return False, 'Cross-site request rejected'
        if self.headers.get('Content-Type', '').split(';')[0].strip().lower() != 'application/json':
            return False, 'JSON request required'
        try:
            size = int(self.headers.get('Content-Length', '-1'))
        except ValueError:
            size = -1
        if size < 2 or size > MAX_POST:
            return False, 'Request size invalid'
        return True, size

    def do_POST(self):
        if not self._allowed_host():
            return self._reject(403, 'Invalid localhost host')
        path = urlsplit(self.path).path
        if path not in ('/api/shared', '/api/launch', '/api/state', '/api/ai/chat', '/api/ai/approve'):
            return self._reject(405, 'No write endpoint')
        if not self._authenticated():
            return self._reject(401, 'Authenticate through the signed-in Linux session')
        valid, result = self._accept_post()
        if not valid:
            return self._reject(403 if result != 'Request size invalid' else 413, result)
        try:
            body = json.loads(self.rfile.read(result))
        except (ValueError, UnicodeError):
            return self._reject(400, 'Invalid JSON')
        if not isinstance(body, dict):
            return self._reject(400, 'Expected an object')
        if path == '/api/state':
            return self._write_state(body)
        if path == '/api/ai/chat':
            return self._ai_chat(body)
        if path == '/api/ai/approve':
            return self._ai_approve(body)
        if path == '/api/shared':
            return self._create_shared(body)
        if path == '/api/launch':
            return self._launch(body)
        return self._reject(404, 'Not found')

    def _ai_actor(self):
        # The cookie never goes to the model. Fingerprinting it binds pending
        # proposals to the exact signed-in browser session, not just a UID.
        import hashlib
        return hashlib.sha256(self.headers.get('Cookie', '').encode('utf-8')).hexdigest()

    def _ai_chat(self, body):
        question = body.get('message', '')
        if not isinstance(question, str) or not 1 <= len(question.strip()) <= local_ai.MAX_INPUT_CHARS:
            return self._reject(400, 'Ask a question between 1 and 700 characters')
        history = body.get('history', [])
        if not isinstance(history, list) or len(history) > 6:
            return self._reject(400, 'Chat context must be a short array')
        try:
            response = local_ai.answer(question, history)
        except ValueError:
            return self._reject(400, 'Invalid AI question')
        except local_ai.ModelUnavailable as exc:
            return self._reject(503, str(exc))
        proposal = response.pop('proposal', None)
        if proposal:
            # Proposals are not actions. A separate human click is required
            # to redeem one time and write anything into their Maker Journal.
            identity = self._ai_actor()
            ident = secrets.token_hex(16)
            now = time.monotonic()
            with self.server.ai_lock:
                pending = self.server.ai_pending
                for k, v in list(pending.items()):
                    if v['expires'] <= now:
                        del pending[k]
                if len(pending) >= 32:
                    pending.pop(next(iter(pending)))
                pending[ident] = {'owner': identity, 'expires': now + 180, 'draft': proposal}
            response['proposal'] = {'token': ident, 'preview': proposal,
                                    'requires_confirmation': True, 'expires_seconds': 180}
        return self._reply(200, {'ok': True, **response})

    def _ai_approve(self, body):
        ident = body.get('token', '')
        if not isinstance(ident, str) or not re.fullmatch(r'[a-f0-9]{32}', ident):
            return self._reject(400, 'Invalid action token')
        with self.server.ai_lock:
            item = self.server.ai_pending.get(ident)
            if not item or item['owner'] != self._ai_actor() or item['expires'] <= time.monotonic():
                return self._reject(403, 'Proposal expired, already used, or belongs to another session')
            del self.server.ai_pending[ident]
        # This is the approved *data*, not an implicit file write. The existing
        # Maker Journal validator and private persistence path must save it.
        return self._reply(200, {'ok': True, 'approved_draft': item['draft'],
                                 'note': 'Use the ordinary journal save path; no model output executed'})

    def _write_state(self, body):
        key = body.get('key')
        value = body.get('value')
        if not isinstance(key, str) or not STATE_KEY.fullmatch(key):
            return self._reject(400, 'Unrecognized state key')
        try:
            encoded = json.dumps(value, ensure_ascii=False, separators=(',', ':'), allow_nan=False)
        except (TypeError, ValueError):
            return self._reject(400, 'Invalid state value')
        if len(encoded.encode('utf-8')) > MAX_STATE_VALUE:
            return self._reject(413, 'State value exceeds 180 KB')
        if isinstance(value, (str, int, float)) and key not in ('wf-reforged:v3:last-profile',) and not key.startswith('wf-reforged:v3:logic-completed:'):
            return self._reject(400, 'State must be an object or list')
        try:
            with state_db() as db:
                db.execute('INSERT OR REPLACE INTO state (key,value,updated) VALUES (?,?,CURRENT_TIMESTAMP)', (key, encoded))
                size = db.execute('SELECT SUM(LENGTH(value)) FROM state').fetchone()[0] or 0
                if size > 3_000_000:
                    db.rollback()
                    return self._reject(413, 'Private storage quota reached')
            return self._reply(200, {'ok': True, 'saved': key})
        except (OSError, sqlite3.Error) as exc:
            logging.warning('State save failure: %s', exc)
            return self._reject(503, 'Unable to save account state')

    def _create_shared(self, body):
        parent = team_path()
        if not (parent.is_dir() and os.access(parent, os.W_OK | os.X_OK)):
            return self._reject(403, 'Shared folder unavailable for this Linux user')
        kind = body.get('kind')
        title = body.get('title')
        if kind not in ('notebook', 'blueprint') or not isinstance(title, str) or not 1 <= len(title.strip()) <= 100:
            return self._reject(400, 'Invalid kind or title')
        if kind == 'notebook':
            notes = body.get('notes', '')
            if not isinstance(notes, str) or len(notes) > MAX_TEAM_NOTE:
                return self._reject(400, 'Invalid notes')
            payload = {'notes': notes}
        else:
            blocks = body.get('blocks')
            if not isinstance(blocks, dict) or len(blocks) > 1152:
                return self._reject(400, 'Invalid blueprint')
            allowed = {'grass', 'stone', 'wood', 'glass', 'gold', 'cosmic'}
            if any(not isinstance(k, str) or not re.fullmatch(r'\d{1,2},\d{1,2},[0-7]', k) or
                   any(int(x) >= 12 for x in k.split(',')[:2]) or v not in allowed
                   for k, v in blocks.items()):
                return self._reject(400, 'Blueprint blocks are outside the allowed grid')
            payload = {'format': 'wonderforge-blueprint', 'version': 3, 'blocks': blocks}
        ident = secrets.token_hex(12)
        data = {'id': ident, 'kind': kind, 'title': title.strip(), 'author': username(),
                'created': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()), **payload}
        encoded = json.dumps(data, ensure_ascii=False).encode('utf-8')
        if len(encoded) > MAX_POST:
            return self._reject(413, 'Shared record too large')
        target = parent / (ident + '.json')
        with self._share_lock:
            if len(list(parent.glob('*.json'))) >= 250:
                return self._reject(429, 'Team Forge reached its shared-record limit. Ask an adult to archive old work.')
            try:
                fd = os.open(str(target), os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, 'O_NOFOLLOW', 0), 0o660)
                os.fchmod(fd, 0o660)
                with os.fdopen(fd, 'wb') as file:
                    file.write(encoded)
                    file.flush()
                    os.fsync(file.fileno())
            except OSError:
                return self._reject(503, 'Unable to save shared record')
        return self._reply(201, {'ok': True, 'item': {k: data[k] for k in ('id', 'kind', 'title', 'author', 'created')}})

    def _launch(self, body):
        app_id = body.get('id')
        if not isinstance(app_id, str) or app_id not in APPS:
            return self._reject(400, 'Application is not approved')
        if os.geteuid() == 0:
            return self._reject(403, 'Running applications as root is forbidden')
        if not (os.environ.get('DISPLAY') or os.environ.get('WAYLAND_DISPLAY')):
            return self._reject(409, 'No graphical desktop session')
        title, candidates = APPS[app_id]
        executable = approved_executable(candidates)
        if not executable:
            return self._reject(404, f'{title} is not installed')
        key = (os.getuid(), app_id)
        with self._launch_lock:
            now = time.monotonic()
            if now - self._last_launch.get(key, 0) < 15:
                return self._reject(429, 'Wait before opening this program again')
            self._last_launch[key] = now
        argv = [executable]
        if app_id == 'luanti':
            world = Path.home() / '.minetest' / 'worlds' / 'WonderForge'
            if world.is_dir() and (world / 'world.mt').is_file():
                # Official Luanti options: --world PATH --go (offline singleplayer).
                # A fixed local path, no user-controlled command line parameters.
                argv += ['--world', str(world), '--go']
        try:
            subprocess.Popen(argv, cwd=os.path.expanduser('~'),
                             stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                             stderr=subprocess.DEVNULL, close_fds=True, start_new_session=True)
        except OSError:
            with self._launch_lock:
                self._last_launch.pop(key, None)
            return self._reject(503, 'The application could not start')
        return self._reply(202, {'ok': True, 'launched': app_id, 'note': 'Launch requested; actual UI is not guaranteed'})

    def log_message(self, fmt, *args):
        logging.info('%s %s', self.client_address[0], fmt % args)


def user_port():
    return 20000 + os.getuid() % 25000


def run(port=8765, host='127.0.0.1', production=False):
    if host not in ('127.0.0.1', 'localhost'):
        raise ValueError('Network binding is intentionally disabled')
    with ThreadingHTTPServer(('127.0.0.1', port), Handler) as httpd:
        httpd.daemon_threads = True
        if production:
            httpd.auth = PortalAuth()
        httpd.ai_lock = threading.Lock()
        httpd.ai_pending = {}
        print(f'WonderForge v0.7 available at http://127.0.0.1:{httpd.server_port}/', flush=True)
        httpd.serve_forever()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='WonderForge local-only OS portal')
    parser.add_argument('--port', type=int, default=8765)
    parser.add_argument('--user-port', action='store_true', help='Derive a separate localhost port from Linux UID')
    args = parser.parse_args()
    run(user_port() if args.user_port else args.port, production=args.user_port)
