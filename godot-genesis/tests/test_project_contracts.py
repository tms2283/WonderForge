import importlib.util
from pathlib import Path
import unittest

HERE=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('validate_project',HERE/'tools/validate_project.py')
v=importlib.util.module_from_spec(spec)
spec.loader.exec_module(v)

class ProjectContracts(unittest.TestCase):
    def test_sources(self): self.assertGreaterEqual(v.check_scenes_and_scripts(),7)
    def test_parts_and_quests(self):
        p,q=v.check_catalog();self.assertGreaterEqual(p,40);self.assertGreaterEqual(q,24)
    def test_quality(self): v.check_quality()
    def test_docs(self): v.check_docs()

if __name__=='__main__': unittest.main()
