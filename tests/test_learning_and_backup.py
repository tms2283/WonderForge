"""Physics calculations, original offline curriculum and conservative recovery checks."""
from pathlib import Path
import importlib.util
import io
import json
import shutil
import subprocess
import sys
import tarfile
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('inspect_backup', ROOT / 'tools' / 'inspect-backup.py')
backup_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(backup_module)


class LearningAndRecoveryTest(unittest.TestCase):
    def test_offline_curriculum_has_unique_complete_original_lessons(self):
        lessons = json.loads((ROOT / 'data' / 'learning.json').read_text('utf-8'))
        self.assertIsInstance(lessons, list)
        self.assertEqual(len(lessons), 18)
        self.assertEqual(len({l['id'] for l in lessons}), 18)
        for lesson in lessons:
            for key in ('id', 'title', 'region', 'concept', 'activity', 'evidence', 'safety'):
                self.assertTrue(lesson[key], f'Lesson {lesson.get("id")} missing {key}')
        self.assertEqual(len({x['region'] for x in lessons}), 6)

    @unittest.skipUnless(shutil.which('node'), 'Node required to exercise portable JavaScript math')
    def test_science_math_and_physical_caveats(self):
        js = r'''
        const assert=require('node:assert/strict');
        const lab=require(process.argv[1]);
        const a=lab.led(5,330,2);
        assert.ok(Math.abs(a.ma-9.090909)<0.001);
        assert.ok(Math.abs(a.powerW-0.0272727)<0.0001);
        assert.equal(lab.led(5,1,2).severity,'unsafe');
        assert.equal(lab.led(2,330,2).ma,0);
        const b=lab.beam(100,1,30,40,'wood');
        assert.ok(Math.abs(b.deflectionMm-1.302083)<0.005);
        assert.ok(Math.abs(b.stressMPa-3.125)<0.005);
        const tall=lab.beam(100,1,30,80,'wood');
        assert.ok(tall.deflectionMm<b.deflectionMm/7.9);
        assert.match(b.warning,/Never use for construction/i);
        console.log('LED & beam reference values and guardrails passed');
        '''
        result = subprocess.run(['node','-e',js,str(ROOT/'web/labs.js')],capture_output=True,text=True,timeout=8)
        self.assertEqual(result.returncode,0,result.stdout+'\n'+result.stderr)

    def _archive(self, archive_path, members):
        with tarfile.open(archive_path,'w:gz') as tf:
            for name, type_, value in members:
                if type_=='file':
                    info=tarfile.TarInfo(name)
                    data=value.encode('utf8');info.size=len(data)
                    tf.addfile(info,io.BytesIO(data))
                elif type_=='symlink':
                    info=tarfile.TarInfo(name);info.type=tarfile.SYMTYPE;info.linkname=value
                    tf.addfile(info)

    def test_backup_audit_accepts_ordinary_data_and_receipt(self):
        with tempfile.TemporaryDirectory() as tmp:
            path=Path(tmp)/'family.tar.gz'
            self._archive(path,[('home/atlas/.local/share/wonderforge/workshop.sqlite3','file','data'),
                                ('home/nova/project.txt','file','notes'),
                                ('srv/wonderforge/team/sample.json','file','{}')])
            report=backup_module.audit(path)
            self.assertTrue(report['ok'],report['issues'])
            self.assertEqual(report['regular_files'],3)
            self.assertFalse(backup_module.audit(path,'0'*64)['ok'])

    def test_backup_audit_rejects_escape_and_unsafe_members(self):
        with tempfile.TemporaryDirectory() as tmp:
            path=Path(tmp)/'bad.tar.gz'
            self._archive(path,[('home/atlas/../../etc/shadow','file','oops')])
            self.assertFalse(backup_module.audit(path)['ok'])
            self._archive(path,[('home/atlas/secret-symlink','symlink','/etc/shadow')])
            self.assertFalse(backup_module.audit(path)['ok'])
            self._archive(path,[('etc/password','file','oops')])
            self.assertFalse(backup_module.audit(path)['ok'])

    def test_installation_is_not_silent_autoprovisioning(self):
        image_script=(ROOT/'image/firstboot.sh').read_text()
        self.assertNotIn('system-install.sh --apply',image_script)
        self.assertIn('adult',image_script.lower())
        service=(ROOT/'os/systemd/wonderforge.service').read_text()
        self.assertIn('UMask=0077',service)

    def test_pi4_resource_math_and_output_are_not_faked(self):
        spec = importlib.util.spec_from_file_location('pi4_benchmark', ROOT / 'tools' / 'pi4-benchmark.py')
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        self.assertEqual(module.cpu_fraction((100, 40), (200, 90)), 50.0)
        self.assertIsNone(module.cpu_fraction((100, 40), (100, 40)))
        self.assertGreaterEqual(module.meminfo().get('MemTotal', 0), 0)

    def test_new_api_catalog_resources_have_explicit_routes(self):
        sys.path.insert(0,str(ROOT))
        import server
        self.assertIn('/data/learning.json',server.ROUTES)
        self.assertIn('/web/labs.js',server.ROUTES)
        self.assertTrue((ROOT/'data/learning.json').is_file())
        self.assertTrue((ROOT/'web/labs.js').is_file())


if __name__=='__main__':unittest.main()
