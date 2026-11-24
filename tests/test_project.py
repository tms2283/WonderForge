"""Read-only smoke and contract tests for the WonderForge prototype."""
import json
import threading
import unittest
from urllib.request import urlopen, Request
from urllib.error import HTTPError
from http.server import ThreadingHTTPServer
from pathlib import Path
from importlib.machinery import SourceFileLoader

ROOT=Path(__file__).resolve().parents[1]
server=SourceFileLoader('wonderforge_server',str(ROOT/'server.py')).load_module()

class CatalogTests(unittest.TestCase):
    def test_twenty_distinct_quests_with_outcomes(self):
        data=json.loads((ROOT/'data/quests.json').read_text(encoding='utf-8'))
        self.assertEqual(len(data),20)
        self.assertEqual(len({q['id'] for q in data}),len(data))
        for quest in data:
            for key in ['id','title','category','description','steps','hints','artifact','brothers']:
                self.assertIn(key,quest)
            self.assertGreaterEqual(len(quest['steps']),3)
            self.assertTrue(quest['artifact'])
    def test_nine_studios_with_install_disclosure(self):
        data=json.loads((ROOT/'data/apps.json').read_text(encoding='utf-8'))
        self.assertEqual(len(data),9)
        self.assertEqual(len({x['id'] for x in data}),len(data))
        for studio in data:
            self.assertTrue(studio['availability'])
            self.assertTrue(studio['programs'])
    def test_offline_asset_bundle_and_relative_routes(self):
        text=(ROOT/'web/index.html').read_text()
        self.assertIn('src="/web/app.js"',text)
        self.assertIn('href="/web/styles.css"',text)
        self.assertNotIn('https://fonts.googleapis.com',text)
        self.assertNotIn('src="https://',text)
        assets=list((ROOT/'web/assets').glob('*.webp'))
        self.assertGreaterEqual(len(assets),4)
        self.assertLess(sum(x.stat().st_size for x in assets),2_000_000)
    def test_disclosures_and_actual_logic_game(self):
        js=(ROOT/'web/app.js').read_text()
        self.assertIn('not a bootable OS'.lower(), js.lower())
        self.assertIn('logicStep()',js)
        self.assertIn('LOGIC_WALLS',js)
        self.assertIn('localStorage',js)
        self.assertNotIn('eval(',js)

class ServerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.httpd=ThreadingHTTPServer(('127.0.0.1',0),server.Handler)
        cls.port=cls.httpd.server_address[1]
        cls.thread=threading.Thread(target=cls.httpd.serve_forever,daemon=True)
        cls.thread.start()
    @classmethod
    def tearDownClass(cls):
        cls.httpd.shutdown();cls.httpd.server_close();cls.thread.join(2)
    def open(self,path):
        return urlopen('http://127.0.0.1:'+str(self.port)+path,timeout=3)
    def test_local_static_site_and_security_headers(self):
        with self.open('/') as r:
            content=r.read().decode('utf-8')
            self.assertIn('WonderForge',content)
            self.assertIn("default-src 'none'",r.headers['Content-Security-Policy'])
            self.assertEqual(r.headers['X-Content-Type-Options'],'nosniff')
    def test_bundled_image_and_app_script(self):
        with self.open('/web/assets/aether-citadel.webp') as r:
            self.assertEqual(r.headers['Content-Type'],'image/webp')
            self.assertGreater(len(r.read()),100_000)
        with self.open('/web/app.js') as r:
            self.assertIn(b'logicRun',r.read())
    def test_no_unknown_urls_or_writes(self):
        for url in ['/../../etc/passwd','/favicon.ico','/index.php']:
            with self.assertRaises(HTTPError) as exc:self.open(url)
            self.assertEqual(exc.exception.code,404)
        with self.assertRaises(HTTPError) as exc:
            urlopen(Request('http://127.0.0.1:'+str(self.port)+'/',data=b'data',method='POST'),timeout=3)
        self.assertEqual(exc.exception.code,405)

if __name__=='__main__':unittest.main()
