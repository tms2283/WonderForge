"""Integration tests for localhost API, cross-account shared material and permissions."""
from __future__ import annotations

import json
import os
import tempfile
import threading
import unittest
from pathlib import Path
from unittest import mock
from urllib.error import HTTPError
from urllib.request import Request, urlopen
from http.server import ThreadingHTTPServer
from importlib.util import spec_from_file_location, module_from_spec

ROOT = Path(__file__).resolve().parents[1]
spec = spec_from_file_location('wf_os_server_v4', ROOT/'server.py')
server = module_from_spec(spec)
spec.loader.exec_module(server)


class LocalOsIntegrationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.TemporaryDirectory(prefix='wf-team-test-')
        cls.orig = os.environ.get('WONDERFORGE_TEAM_DIR')
        os.environ['WONDERFORGE_TEAM_DIR'] = cls.tmp.name
        cls.httpd = ThreadingHTTPServer(('127.0.0.1', 0), server.Handler)
        cls.port = cls.httpd.server_address[1]
        cls.thread = threading.Thread(target=cls.httpd.serve_forever, daemon=True)
        cls.thread.start()
    @classmethod
    def tearDownClass(cls):
        cls.httpd.shutdown(); cls.httpd.server_close(); cls.thread.join(2)
        if cls.orig is None: os.environ.pop('WONDERFORGE_TEAM_DIR', None)
        else: os.environ['WONDERFORGE_TEAM_DIR'] = cls.orig
        cls.tmp.cleanup()

    def url(self, path): return f'http://127.0.0.1:{self.port}{path}'
    def get(self, path, headers=None):
        req=Request(self.url(path), headers=headers or {})
        with urlopen(req, timeout=3) as result:
            return result.status, json.load(result)
    def post(self, path, content, headers=None):
        opts={'Origin':f'http://127.0.0.1:{self.port}', 'Content-Type':'application/json'}
        opts.update(headers or {})
        req=Request(self.url(path), data=json.dumps(content).encode('utf8'), headers=opts, method='POST')
        with urlopen(req, timeout=3) as result:
            return result.status, json.load(result)

    def assert_code(self, code, f, *args, **kwargs):
        with self.assertRaises(HTTPError) as e:
            f(*args, **kwargs)
        self.assertEqual(e.exception.code, code)

    def test_session_reflects_unix_account(self):
        with mock.patch.object(server, 'username', return_value='atlas'):
            code, data = self.get('/api/session')
        self.assertEqual(code, 200)
        self.assertEqual(data['profile'], 'atlas')
        self.assertTrue(data['linux_identity_enforced'])
        self.assertTrue(data['team_available'])

    def test_shared_notebook_round_trip_and_separate_authors(self):
        with mock.patch.object(server, 'username', return_value='atlas'):
            code, one = self.post('/api/shared', {'kind':'notebook', 'title':'Our bridge', 'notes':'Triangle braces test'})
        self.assertEqual(code, 201)
        ident=one['item']['id']
        self.assertRegex(ident, r'^[a-f0-9]{24}$')
        with mock.patch.object(server, 'username', return_value='nova'):
            code, result = self.get('/api/shared/' + ident)
            self.assertEqual(code, 200)
            self.assertEqual(result['item']['author'], 'atlas')
            self.assertEqual(result['item']['notes'], 'Triangle braces test')
            code, listing = self.get('/api/shared')
            self.assertIn(ident, [x['id'] for x in listing['items']])
        self.assertEqual(Path(self.tmp.name, ident+'.json').stat().st_mode & 0o777,0o660)

    def test_valid_blueprint_and_invalid_coordinate_rejection(self):
        self.assert_code(400, self.post, '/api/shared',
                         {'kind':'blueprint', 'title':'bad', 'blocks':{'12,0,0':'grass'}})
        self.assert_code(400, self.post, '/api/shared',
                         {'kind':'blueprint', 'title':'bad', 'blocks':{'0,0,0':'lava'}})
        code, result=self.post('/api/shared',
                         {'kind':'blueprint', 'title':'Shared castle', 'blocks':{'0,0,0':'grass','2,1,4':'stone'}})
        self.assertEqual(code,201)
        _, data=self.get('/api/shared/'+result['item']['id'])
        self.assertEqual(data['item']['blocks']['2,1,4'],'stone')

    def test_csrf_host_and_malicious_requests_rejected(self):
        self.assert_code(403, self.post, '/api/shared', {'kind':'notebook','title':'bad'},
                         {'Origin':'https://attacker.example'})
        self.assert_code(403, self.post, '/api/shared', {'kind':'notebook','title':'bad'},
                         {'Sec-Fetch-Site':'cross-site'})
        self.assert_code(403, self.get, '/api/session', {'Host':'attacker.example'})
        self.assert_code(404, self.get, '/api/shared/../../etc/passwd')
        self.assert_code(405, self.post, '/', {'bad':'bad'})

    def test_launcher_is_whitelisted_and_root_disallowed(self):
        code, apps=self.get('/api/apps')
        self.assertEqual(code,200)
        self.assertGreater(len(apps['apps']),5)
        self.assert_code(400, self.post, '/api/launch', {'id':'/bin/sh'})
        with mock.patch.object(server.os, 'geteuid', return_value=0):
            self.assert_code(403, self.post, '/api/launch', {'id':'thonny'})

    def test_team_records_reject_symlink(self):
        path=Path(self.tmp.name)/('a'*24+'.json')
        path.symlink_to('/etc/passwd')
        self.assert_code(404, self.get, '/api/shared/'+'a'*24)
        _, result=self.get('/api/shared')
        self.assertNotIn('a'*24,[x['id'] for x in result['items']])
        path.unlink()

    def test_luanti_approved_launcher_uses_installed_world_directly(self):
        with tempfile.TemporaryDirectory() as tmp:
            home=Path(tmp)
            world=home/'.minetest/worlds/WonderForge'
            world.mkdir(parents=True)
            (world/'world.mt').write_text('gameid = minetest\n')
            server.Handler._last_launch.clear()
            with mock.patch.object(server.os,'geteuid',return_value=1001), \
                 mock.patch.object(server.os,'getuid',return_value=1001), \
                 mock.patch.object(server.Path,'home',return_value=home), \
                 mock.patch.object(server,'approved_executable',return_value='/usr/games/luanti'), \
                 mock.patch.object(server.subprocess,'Popen') as run, \
                 mock.patch.dict(os.environ,{'DISPLAY':':0'}):
                code,data=self.post('/api/launch', {'id':'luanti'})
                self.assertEqual(code,202,data)
                command=run.call_args.args[0]
                self.assertEqual(command[0],'/usr/games/luanti')
                self.assertEqual(command[1:],['--world',str(world),'--go'])
                self.assertNotIn('shell',run.call_args.kwargs)

    def test_user_port_unique_and_nft_guard_template(self):
        with mock.patch.object(server.os, 'getuid', return_value=1001): a=server.user_port()
        with mock.patch.object(server.os, 'getuid', return_value=1002): b=server.user_port()
        self.assertEqual(b-a,1)
        self.assertTrue(1024<a<65536)
        self.assertIn('oifname != "lo" reject',(ROOT/'installer/offline-guard.sh').read_text())


if __name__=='__main__':unittest.main()
