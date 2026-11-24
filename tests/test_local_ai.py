"""v0.7 AI security: real mocked HTTP protocol, model-selected tool allowlist and consent."""
import hashlib
import http.cookiejar
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from pathlib import Path
import sys
import threading
import unittest
from urllib.request import Request, HTTPCookieProcessor, build_opener
from urllib.error import HTTPError
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
import local_ai
import portal_security
import server


class FakeOllama(BaseHTTPRequestHandler):
    calls = []
    def do_GET(self):
        assert self.path == '/api/tags'
        self.respond({'models': [{'name': 'qwen3:0.6b'}]})
    def do_POST(self):
        self.__class__.calls.append((self.path, json.loads(self.rfile.read(int(self.headers['Content-Length'])))))
        if len(self.__class__.calls) % 2:
            message = {'tools': [{'name': 'search_lessons', 'arguments': {'query': 'resistor LED'}},
                                  {'name': 'write_file', 'arguments': {'path': '/etc/passwd'}}],
                       'journal_draft': {'title': 'LED brightness trial', 'question': 'Does resistance change LED brightness?',
                                         'hypothesis': 'More resistance will lower current.',
                                         'method': 'Use the simulated LED model.',
                                         'observation': 'The experiment proved the theory.',
                                         'conclusion': 'Verified safe circuit.'}}
            self.respond({'message': {'role': 'assistant', 'content': json.dumps(message)}})
        else:
            self.respond({'message': {'role': 'assistant', 'content': 'Try changing one resistor value, and record the simulated current.'}})
    def respond(self, val):
        b = json.dumps(val).encode('utf-8')
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(b)))
        self.end_headers()
        self.wfile.write(b)
    def log_message(self, *_args):
        pass


class AIAgentTests(unittest.TestCase):
    def test_model_names_are_strict_and_no_cloud_is_permitted(self):
        for bad in ['qwen3:35b', 'llama4:cloud', 'attacker/qwen3:0.6b', 'http://evil/', '../secret', '']:
            with self.subTest(model=bad), patch.dict(os.environ, {'WONDERFORGE_AI_MODEL': bad}):
                self.assertEqual(local_ai.selected_model(), 'qwen3:0.6b')
        with patch.dict(os.environ, {'WONDERFORGE_AI_MODEL': 'gemma3:1b'}):
            self.assertEqual(local_ai.selected_model(), 'gemma3:1b')
        with self.assertRaises(ValueError):
            local_ai._http_json('http://example.com/')

    def test_tool_invocation_rejects_unapproved_actions(self):
        for bad in ('execute_shell', 'fetch_url', 'read_private_journal', 'write_file', 'launch_app'):
            with self.assertRaises(ValueError):
                local_ai.run_tool(bad, {})
        with self.assertRaises(ValueError):
            local_ai.run_tool('estimate_led', {'voltage': 1e18})
        with self.assertRaises(ValueError):
            local_ai.run_tool('estimate_beam', {'material': '/etc/passwd'})
        self.assertAlmostEqual(local_ai.run_tool('estimate_led', {'voltage': 5, 'resistance_ohms': 330,
                                                                 'forward_voltage': 2})['ma'], 9.0909, places=3)
        result = local_ai.run_tool('search_lessons', {'query': 'LED resistor'})
        self.assertTrue(result['results'])
        self.assertTrue(all('safety' in x for x in result['results']))

    def test_simulated_ollama_http_two_stage_agent_is_local(self):
        srv = ThreadingHTTPServer(('127.0.0.1', 0), FakeOllama)
        th = threading.Thread(target=srv.serve_forever, daemon=True)
        FakeOllama.calls = []
        th.start()
        try:
            with patch.object(local_ai, 'OLLAMA_PORT', srv.server_port), patch.dict(os.environ, {'WONDERFORGE_AI_ENABLED': '1'}):
                self.assertTrue(local_ai.status()['available'])
                answer = local_ai.answer('Plan an LED resistor experiment')
            self.assertEqual(answer['mode'], 'local-model')
            self.assertIn('simulated current', answer['reply'])
            self.assertEqual(answer['calls'], [{'name': 'search_lessons', 'status': 'ok'}])
            self.assertEqual(len(FakeOllama.calls), 2)
            self.assertEqual([c[0] for c in FakeOllama.calls], ['/api/chat', '/api/chat'])
            self.assertTrue(all(c[1]['stream'] is False and c[1]['options']['num_ctx'] == 2048 for c in FakeOllama.calls))
            self.assertEqual(answer['proposal']['title'], 'LED brightness trial')
            self.assertEqual(answer['proposal']['conclusion'], '')
            self.assertEqual(answer['proposal']['observation'], '')
        finally:
            srv.shutdown()
            srv.server_close()
            th.join(timeout=3)

    def test_invalid_model_json_is_not_a_tool_injection(self):
        self.assertEqual(local_ai._parse_plan('not-json'), ([], None))
        calls, draft = local_ai._parse_plan(json.dumps({'tools': [{'name': 'open_url', 'arguments': {'url':'https://x'}},
                                                                     {'name': 'search_quests', 'arguments': {'query':'Mars'}}],
                                                         'journal_draft': {'title': 'bad'}}))
        self.assertEqual([c['name'] for c in calls], ['search_quests'])
        self.assertIsNone(local_ai.validate_draft(draft))

    def test_local_ai_installer_dry_run_never_modifies_the_host(self):
        import subprocess
        from pathlib import Path
        script=ROOT/'installer'/'setup-local-ai.sh'
        proc=subprocess.run(['bash',str(script)],capture_output=True,text=True,timeout=6)
        self.assertEqual(proc.returncode,0,proc.stderr)
        self.assertIn('DRY RUN',proc.stdout)
        self.assertIn('OLLAMA',proc.stdout.upper())
        self.assertIn('DRY RUN',proc.stdout)
        invalid=subprocess.run(['bash',str(script),'--model=https://remote'],capture_output=True,text=True,timeout=5)
        self.assertNotEqual(invalid.returncode,0)

    def test_code_and_package_contract_explicitly_include_local_only_runtime(self):
        assert (ROOT/'docs'/'LOCAL-AI.md').exists()
        package=(ROOT/'scripts'/'build-deb.sh').read_text()
        self.assertIn('local_ai.py',package)
        self.assertIn('setup-local-ai.sh', (ROOT/'docs'/'LOCAL-AI.md').read_text())
        self.assertIn('OLLAMA_NO_CLOUD=1',(ROOT/'installer'/'setup-local-ai.sh').read_text())
        self.assertIn('127.0.0.1:11434',(ROOT/'installer'/'setup-local-ai.sh').read_text())
        self.assertNotIn('subprocess.', (ROOT/'local_ai.py').read_text())

    def test_single_inference_slot_rejects_concurrency(self):
        self.assertTrue(local_ai._GATE.acquire(blocking=False))
        try:
            with self.assertRaises(local_ai.ModelUnavailable):
                local_ai.answer('Question')
        finally:
            local_ai._GATE.release()


class AIPortalTests(unittest.TestCase):
    def setUp(self):
        self.httpd = ThreadingHTTPServer(('127.0.0.1', 0), server.Handler)
        self.httpd.auth = portal_security.PortalAuth(key=b'z' * 32)
        self.httpd.ai_lock = threading.Lock()
        self.httpd.ai_pending = {}
        self.port = self.httpd.server_port
        self.origin = f'http://127.0.0.1:{self.port}'
        self.th = threading.Thread(target=self.httpd.serve_forever, daemon=True)
        self.th.start()
        self.jar = http.cookiejar.CookieJar()
        self.client = build_opener(HTTPCookieProcessor(self.jar))
        self.client.open(self.origin + '/?ticket=' + self._ticket()).close()

    def _ticket(self):
        import hmac, time
        from hashlib import sha256
        ts = str(int(time.time()))
        nonce = '8' * 32
        mac = hmac.new(b'z' * 32, (ts + '.' + nonce).encode('ascii'), sha256).hexdigest()
        return ts + '.' + nonce + '.' + mac

    def tearDown(self):
        self.httpd.shutdown()
        self.httpd.server_close()
        self.th.join(timeout=3)

    def request(self, url, payload=None, client=None, origin=None):
        headers = {'Content-Type': 'application/json', 'Origin': origin or self.origin}
        req = Request(self.origin + url,
                      data=json.dumps(payload).encode('utf-8') if payload is not None else None,
                      headers=headers, method='POST' if payload is not None else 'GET')
        with (client or self.client).open(req, timeout=5) as resp:
            return resp.status, json.load(resp)

    def test_ai_endpoints_require_portal_auth_and_separate_approval(self):
        with self.assertRaises(HTTPError) as e:
            self.request('/api/ai/status', client=build_opener())
        self.assertEqual(e.exception.code, 401)
        with self.assertRaises(HTTPError) as e:
            self.request('/api/ai/chat', {'message': 'hi', 'history': []}, client=build_opener())
        self.assertEqual(e.exception.code, 401)
        draft = {'title': 'Our bridge experiment', 'question': 'How does a brace change the strength?',
                 'hypothesis': 'Triangles reduce movement', 'method': 'Change one variable'}
        with patch.object(server.local_ai, 'answer', return_value={
                'reply': 'Make two test bridges.', 'mode': 'local-model', 'model': 'qwen3:0.6b',
                'calls': [], 'sources': [], 'proposal': draft}):
            _, answer = self.request('/api/ai/chat', {'message': 'plan bridge experiment', 'history': []})
        self.assertEqual(answer['reply'], 'Make two test bridges.')
        token = answer['proposal']['token']
        self.assertTrue(answer['proposal']['requires_confirmation'])
        self.assertEqual(len(self.httpd.ai_pending), 1)
        with self.assertRaises(HTTPError) as e:
            self.request('/api/ai/approve', {'token': token}, origin='https://malicious.test')
        self.assertEqual(e.exception.code, 403)
        with self.assertRaises(HTTPError) as e:
            self.request('/api/ai/approve', {'token': token}, client=build_opener())
        self.assertEqual(e.exception.code, 401)
        _, approval = self.request('/api/ai/approve', {'token': token})
        self.assertEqual(approval['approved_draft']['title'], 'Our bridge experiment')
        self.assertEqual(len(self.httpd.ai_pending), 0)
        with self.assertRaises(HTTPError) as e:
            self.request('/api/ai/approve', {'token': token})
        self.assertEqual(e.exception.code, 403)

    def test_giant_model_request_rejected_before_inference(self):
        with self.assertRaises(HTTPError) as e:
            self.request('/api/ai/chat', {'message': 'a' * 701, 'history': []})
        self.assertEqual(e.exception.code, 400)
        with self.assertRaises(HTTPError) as e:
            self.request('/api/ai/chat', {'message': 'Hello', 'history': ['fake'] * 40})
        self.assertEqual(e.exception.code, 400)

if __name__ == '__main__':
    unittest.main()
