"""Security regression: separate localhost ports do not isolate Unix accounts."""
from contextlib import closing
import base64
import hashlib
import hmac
import http.cookiejar
import json
import os
import sqlite3
import tempfile
import threading
import time
import unittest
from http.server import ThreadingHTTPServer
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import HTTPCookieProcessor, build_opener, Request, urlopen
from unittest import mock
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import portal_security
import server


class PrivatePortalTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.a = mock.patch.dict(os.environ, {
            'WONDERFORGE_AUTH_DIR': self.tmp.name+'/auth',
            'WONDERFORGE_STATE_DIR': self.tmp.name+'/state',
            'WONDERFORGE_TEAM_DIR': self.tmp.name+'/team',
        })
        self.a.start()
        self.httpd = ThreadingHTTPServer(('127.0.0.1', 0), server.Handler)
        self.httpd.auth = portal_security.PortalAuth()
        self.port = self.httpd.server_address[1]
        self.origin = 'http://127.0.0.1:'+str(self.port)
        self.thread = threading.Thread(target=self.httpd.serve_forever, daemon=True)
        self.thread.start()
        self.jar = http.cookiejar.CookieJar()
        self.client = build_opener(HTTPCookieProcessor(self.jar))

    def tearDown(self):
        self.httpd.shutdown()
        self.httpd.server_close()
        self.thread.join(timeout=2)
        self.a.stop()
        self.tmp.cleanup()

    def call(self, path, data=None, authenticated=True):
        headers = {'Origin':self.origin, 'Content-Type':'application/json'}
        req = Request(self.origin+path, headers=headers, data=json.dumps(data).encode() if data is not None else None,
                      method='POST' if data is not None else 'GET')
        client = self.client if authenticated else build_opener()
        with client.open(req, timeout=4) as response:
            return response.status, json.load(response)

    def login(self):
        ticket = portal_security.issue_ticket()
        with self.client.open(self.origin+'/?ticket='+ticket, timeout=4) as r:
            self.assertEqual(r.status, 200)
        self.assertEqual(len(list(self.jar)), 1)
        cookie = list(self.jar)[0]
        self.assertTrue(cookie.has_nonstandard_attr('HttpOnly'))
        self.assertEqual(cookie.get_nonstandard_attr('SameSite'), 'Strict')
        return ticket

    def test_other_local_user_without_cookie_cannot_read_or_write(self):
        with self.assertRaises(HTTPError) as e:
            self.call('/api/session', authenticated=False)
        self.assertEqual(e.exception.code, 401)
        ticket = self.login()
        status, session = self.call('/api/session')
        self.assertEqual(status, 200)
        status, state = self.call('/api/state')
        self.assertEqual(state['state'], {})
        with self.assertRaises(HTTPError) as e:
            self.call('/api/state', {'key':'wf-reforged:v3:quests:atlas', 'value':{}}, authenticated=False)
        self.assertEqual(e.exception.code, 401)
        with self.assertRaises(HTTPError) as e:
            self.call('/?ticket='+ticket, authenticated=False)
        self.assertEqual(e.exception.code, 403)

    def test_tampering_and_expired_tickets(self):
        key = portal_security.secret_bytes()
        self.assertEqual(Path(self.tmp.name+'/auth/portal.key').stat().st_mode & 0o777, 0o600)
        auth = self.httpd.auth
        self.assertIsNone(auth.claim('bad'))
        self.assertIsNone(auth.claim('1234567890.'+'a'*32+'.'+'b'*64))
        ts=int(time.time())-300
        nonce='d'*32
        mac=hmac.new(key, (str(ts)+'.'+nonce).encode(), hashlib.sha256).hexdigest()
        self.assertIsNone(auth.claim(str(ts)+'.'+nonce+'.'+mac))

    def test_private_sqlite_survives_new_server_and_enforces_key_rules(self):
        self.login()
        k='wf-reforged:v3:quests:atlas'
        _, result = self.call('/api/state', {'key':k,'value':{'sky-fortress': True}})
        self.assertEqual(result['saved'], k)
        self.assertEqual(self.call('/api/state')[1]['state'][k], {'sky-fortress':True})
        self.assertEqual(Path(self.tmp.name+'/state/workshop.sqlite3').stat().st_mode & 0o777, 0o600)
        with closing(sqlite3.connect(str(Path(self.tmp.name+'/state/workshop.sqlite3')))) as con:
            self.assertEqual(json.loads(con.execute('SELECT value FROM state WHERE key=?',(k,)).fetchone()[0]),{'sky-fortress':True})
        with self.assertRaises(HTTPError) as e:
            self.call('/api/state', {'key':'../../../etc/passwd','value':{'oops':1}})
        self.assertEqual(e.exception.code, 400)
        with self.assertRaises(HTTPError) as e:
            self.call('/api/state', {'key':k,'value':'z'*190000})
        self.assertEqual(e.exception.code, 413)

    def test_csrf_still_blocks_authenticated_browser(self):
        self.login()
        req=Request(self.origin+'/api/state',data=json.dumps({'key':'wf-reforged:v3:quests:atlas','value':{}}).encode(),
                    headers={'Content-Type':'application/json','Origin':'https://evil.test'},method='POST')
        with self.assertRaises(HTTPError) as e:
            self.client.open(req, timeout=4)
        self.assertEqual(e.exception.code, 403)

if __name__=='__main__': unittest.main()
