"""Pure, host-neutral tests for the local-agent preflight."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1] / "tools" / "agent_preflight.py"
spec = importlib.util.spec_from_file_location("wonderforge_preflight", SOURCE)
preflight = importlib.util.module_from_spec(spec)
spec.loader.exec_module(preflight)


class AgentPreflightTests(unittest.TestCase):
    def test_pinned_engine_version(self):
        self.assertTrue(preflight.godot_version_ok("4.7.2.stable.official"))
        self.assertFalse(preflight.godot_version_ok("4.6.1.stable.official"))

    def test_never_infer_a_pi_from_x64_machine(self):
        self.assertEqual(preflight.pi_fingerprint("", "x86_64"), "NOT_RUN")
        self.assertEqual(preflight.pi_fingerprint("Raspberry Pi 4 Model B Rev 1.5", "x86_64"), "FAIL")
        self.assertEqual(preflight.pi_fingerprint("Raspberry Pi 4 Model B Rev 1.5", "aarch64"), "PASS")

    def test_missing_tool_not_reported_pass(self):
        r = preflight.run_check("Missing", ["/unlikely/missing/preflight-executable"], Path("."))
        self.assertEqual(r["status"], "NOT_RUN")

    def test_unsafe_engine_output_does_not_pass_silently(self):
        with tempfile.TemporaryDirectory() as root:
            script = Path(root) / "echo.py"
            script.write_text("print('SCRIPT ERROR: pretend parse failure')\n", encoding="utf-8")
            result = preflight.run_check("Engine text", ["python3", str(script)], Path(root), engine=True)
            self.assertEqual(result["status"], "FAIL")


if __name__ == "__main__":
    unittest.main()
