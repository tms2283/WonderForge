"""Portable preview must import without the POSIX-only pwd module."""
import importlib.util
import os
from pathlib import Path
import sys
import threading
import unittest
from http.server import ThreadingHTTPServer
from unittest.mock import patch
from urllib.request import urlopen
import json

ROOT = Path(__file__).resolve().parents[1]

class WindowsPreviewCompatibility(unittest.TestCase):
    def test_unix_pwd_is_optional_for_browser_demo(self):
        spec = importlib.util.spec_from_file_location('wonderforge_no_pwd_demo', ROOT / 'server.py')
        module = importlib.util.module_from_spec(spec)
        with patch.dict(sys.modules, {'pwd': None}):
            spec.loader.exec_module(module)
        self.assertIsNone(module.pwd)
        with patch.dict(os.environ, {'USERNAME': 'windows-preview-user'}):
            self.assertEqual(module.username(), 'windows-preview-user')
        httpd = ThreadingHTTPServer(('127.0.0.1', 0), module.Handler)
        th = threading.Thread(target=httpd.serve_forever, daemon=True)
        th.start()
        try:
            port = httpd.server_address[1]
            with urlopen(f'http://127.0.0.1:{port}/', timeout=3) as resp:
                self.assertEqual(resp.status, 200)
                self.assertIn(b'WonderForge', resp.read())
            with urlopen(f'http://127.0.0.1:{port}/api/session', timeout=3) as resp:
                session = json.load(resp)
                self.assertFalse(session['linux_identity_enforced'])
                self.assertIsNone(session['profile'])
        finally:
            httpd.shutdown()
            httpd.server_close()
            th.join(timeout=3)
