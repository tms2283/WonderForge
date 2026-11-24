"""v0.6 regressions: observable machine state and learner-owned experiment records."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import threading
import unittest
from http.server import ThreadingHTTPServer
from urllib.error import HTTPError
from urllib.request import Request, build_opener

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
import device_health
import portal_security
import server


class MakerJournalTests(unittest.TestCase):
    def node(self, script):
        r = subprocess.run(['node', '-e', script], cwd=str(ROOT), text=True,
                           capture_output=True, timeout=10, check=False)
        self.assertEqual(r.returncode, 0, r.stderr)
        return json.loads(r.stdout.strip())

    def test_structured_evidence_never_certifies_mastery(self):
        result = self.node("""
const j=require('./web/journal.js');
const a=j.validate({title:'Bridge comparison',questId:'sky-fortress',
 hypothesis:'The triangles should make the bridge less flexible.',
 method:'Same weight and span, change bracing only.',
 observation:'Measured 6 mm before and 2 mm after the change.',
 conclusion:'The triangle-braced model sagged less in this test.'});
console.log(JSON.stringify({valid:j.hasEvidence(a),summary:j.summarize([a],[{id:'sky-fortress'}]),imported:j.parseImport(j.exportDocument([a],'atlas')).length}));
""")
        self.assertTrue(result['valid'])
        self.assertEqual(result['summary']['linkedQuests'], 1)
        self.assertEqual(result['imported'], 1)

    def test_journal_rejects_invalid_records_and_conflicting_backup(self):
        result = self.node("""
const j=require('./web/journal.js');let errors=0;
for(const bad of [{title:'a'},{title:'valid title',questId:'../../etc/passwd'}, {title:'Another experiment',hypothesis:9}]){
 try{j.validate(bad)}catch{errors++}}
const a=j.validate({title:'Experiment notes'});
try{j.parseImport({format:'wonderforge-maker-journal',version:1,entries:[a,a]})}catch{errors++}
console.log(JSON.stringify({errors,draft:j.hasEvidence(a)}));
""")
        self.assertEqual(result['errors'], 4)
        self.assertFalse(result['draft'])

    def test_persistent_keys_and_ui_routes(self):
        self.assertIsNotNone(server.STATE_KEY.fullmatch('wf-reforged:v3:journal:atlas'))
        self.assertIsNotNone(server.STATE_KEY.fullmatch('wf-reforged:v3:journal:nova'))
        self.assertIsNone(server.STATE_KEY.fullmatch('wf-reforged:v3:journal:../../escape'))
        html = (ROOT/'web'/'index.html').read_text()
        js = (ROOT/'web'/'app.js').read_text()
        self.assertIn('data-route="journal"', html)
        self.assertIn('data-route="pulse"', html)
        self.assertIn('journalPage()', js)
        self.assertIn('WonderForgeJournal', js)
        self.assertIn('/web/journal.js', server.ROUTES)


class MachinePulseTests(unittest.TestCase):
    def test_meminfo_uses_available_not_total_free(self):
        output = device_health.parse_meminfo('MemTotal: 4096000 kB\nMemFree: 40000 kB\nMemAvailable: 1024000 kB\n')
        self.assertEqual(output['total_mib'], 4000)
        self.assertEqual(output['available_mib'], 1000)
        self.assertEqual(output['used_percent'], 75)
        self.assertEqual(device_health.parse_meminfo('')['used_percent'], None)

    def test_reports_observed_not_fabricated_values(self):
        h = device_health.sample()
        self.assertIn('is_target_pi4b', h)
        self.assertIn('memory', h)
        self.assertIn('disk', h)
        self.assertIsInstance(h['sampled_at_epoch'], int)
        self.assertNotIn('fps', h)
        self.assertIn('no FPS', h['disclosure'])

    def test_private_api_does_not_leak_hardware_without_auth(self):
        srv=ThreadingHTTPServer(('127.0.0.1',0),server.Handler)
        srv.auth=portal_security.PortalAuth(key=b'a'*32)
        th=threading.Thread(target=srv.serve_forever,daemon=True)
        th.start()
        try:
            with self.assertRaises(HTTPError) as err:
                build_opener().open(f'http://127.0.0.1:{srv.server_port}/api/health', timeout=3)
            self.assertEqual(err.exception.code, 401)
        finally:
            srv.shutdown();srv.server_close();th.join(timeout=2)

    def test_ci_and_installable_package_include_modules(self):
        script=(ROOT/'scripts'/'build-deb.sh').read_text()
        self.assertIn('device_health.py',script)
        self.assertIn('journal.js', (ROOT/'web'/'index.html').read_text())
        self.assertIn('unittest', (ROOT/'.github'/'workflows'/'ci.yml').read_text())

if __name__ == '__main__': unittest.main()
