"""Per-UNIX-user, capability-authenticated localhost browser portal.

A loopback port is NOT per-user isolation. The short-lived, single-use ticket
provides an HttpOnly SameSite=Strict cookie for authenticated API access. The
launcher can read the secret in the user's mode-0700 directory; another Unix
user cannot. Protect the original user's account and home directory.
"""
from __future__ import annotations
import hashlib
import hmac
import os
import re
import secrets
import threading
import time
from http.cookies import SimpleCookie
from pathlib import Path

TICKET = re.compile(r'^([0-9]{9,12})\.([a-f0-9]{32})\.([a-f0-9]{64})$')
SESSION = re.compile(r'^[a-f0-9]{64}$')
COOKIE_NAME = 'wf_portal'


def secret_path() -> Path:
    base = Path(os.environ.get('WONDERFORGE_AUTH_DIR', str(Path.home() / '.local' / 'state' / 'wonderforge')))
    return base / 'portal.key'


def secret_bytes() -> bytes:
    target = secret_path()
    target.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    if target.parent.is_symlink():
        raise PermissionError('Auth directory must not be a symlink')
    os.chmod(target.parent, 0o700)
    try:
        fd = os.open(str(target), os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, 'O_NOFOLLOW', 0), 0o600)
    except FileExistsError:
        pass
    else:
        try:
            os.write(fd, secrets.token_bytes(32))
            os.fsync(fd)
        finally:
            os.close(fd)
    fd = os.open(str(target), os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0))
    try:
        st = os.fstat(fd)
        if st.st_uid != os.geteuid() or st.st_mode & 0o077 or st.st_size != 32 or not __import__('stat').S_ISREG(st.st_mode):
            raise PermissionError('Auth key must be a private regular file owned by this user')
        key = os.read(fd, 33)
        if len(key) != 32:
            raise ValueError('Invalid auth key length')
        return key
    finally:
        os.close(fd)


def issue_ticket(now=None):
    ts = str(int(now if now is not None else time.time()))
    nonce = secrets.token_hex(16)
    msg = ts + '.' + nonce
    mac = hmac.new(secret_bytes(), msg.encode('ascii'), hashlib.sha256).hexdigest()
    return msg + '.' + mac


class PortalAuth:
    def __init__(self, key=None):
        self.key = key if key is not None else secret_bytes()
        self.sessions = {}
        self.spent_tickets = set()
        self.lock = threading.RLock()

    def claim(self, ticket, now=None):
        m = TICKET.fullmatch(ticket)
        if not m:
            return None
        ts, nonce, mac = m.groups()
        now = time.time() if now is None else now
        if abs(now-int(ts)) > 40:
            return None
        expected = hmac.new(self.key, (ts+'.'+nonce).encode(), hashlib.sha256).hexdigest()
        if not hmac.compare_digest(mac, expected):
            return None
        with self.lock:
            if nonce in self.spent_tickets:
                return None
            self.spent_tickets.add(nonce)
            session = secrets.token_hex(32)
            self.sessions[session] = now + 10*3600
            if len(self.spent_tickets) > 4096:
                self.spent_tickets = {nonce}  # Old tickets expired by time regardless.
            for k, expiry in list(self.sessions.items()):
                if expiry < now:
                    self.sessions.pop(k, None)
            return session

    def authenticated(self, cookie_header, now=None):
        cookie = SimpleCookie()
        try:
            cookie.load(cookie_header or '')
            value = cookie[COOKIE_NAME].value if COOKIE_NAME in cookie else ''
        except Exception:
            return False
        if not SESSION.fullmatch(value):
            return False
        with self.lock:
            return self.sessions.get(value, 0) > (now if now is not None else time.time())
