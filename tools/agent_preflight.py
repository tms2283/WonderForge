#!/usr/bin/env python3
"""Non-destructive WonderForge Genesis local-agent preflight.

Run: python3 tools/agent_preflight.py --full --strict --report .agent-reports/preflight.json
No installs, privilege escalation, arbitrary shell commands or network calls.
Godot import writes its normal .godot cache; engine tests use test user:// state.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT / "godot-genesis"
TIMEOUT_S = 180
MAX_OUTPUT = 3500
ENGINE_ERRORS = re.compile(r"(SCRIPT ERROR|Parse Error|RUNTIME ERROR|WF .* FAIL)")


def godot_version_ok(text: str) -> bool:
    return "4.7.2.stable" in text


def pi_fingerprint(model: str, machine: str) -> str:
    if not model:
        return "NOT_RUN"
    if "Raspberry Pi 4 Model B" in model and machine.lower() in ("aarch64", "arm64"):
        return "PASS"
    return "FAIL"


def run_check(name: str, argv: list[str], cwd: Path, *, engine: bool = False,
              marker: str = "", timeout: int = TIMEOUT_S) -> dict[str, Any]:
    result: dict[str, Any] = {"name": name, "status": "NOT_RUN",
                              "exit_code": None, "details": ""}
    if not argv or (shutil.which(argv[0]) is None and not Path(argv[0]).is_file()):
        result["details"] = "Missing executable: " + (argv[0] if argv else "<none>")
        return result
    try:
        p = subprocess.run(argv, cwd=cwd, capture_output=True, text=True,
                           timeout=timeout, check=False)
        combined = (p.stdout or "") + "\n" + (p.stderr or "")
        okay = p.returncode == 0
        if engine and ENGINE_ERRORS.search(combined):
            okay = False
        if marker and marker not in combined:
            okay = False
        result.update({"status": "PASS" if okay else "FAIL",
                       "exit_code": p.returncode, "details": combined[-MAX_OUTPUT:].strip()})
    except subprocess.TimeoutExpired:
        result.update({"status": "FAIL", "details": f"Exceeded {timeout}s timeout"})
    except (OSError, UnicodeError) as exc:
        result.update({"status": "FAIL", "details": type(exc).__name__})
    return result


def hardware_check() -> dict[str, Any]:
    source = Path("/proc/device-tree/model")
    try:
        model = source.read_bytes().replace(b"\x00", b"").decode("utf-8", errors="replace") if source.is_file() else ""
    except OSError:
        model = ""
    arch = platform.machine()
    return {"name": "Physical Pi 4B ARM64 fingerprint",
            "status": pi_fingerprint(model, arch), "exit_code": None,
            "details": f"Device model: {model or 'unavailable'}; architecture: {arch}"}


def git_sha() -> str:
    info = run_check("Repository commit", ["git", "rev-parse", "HEAD"], ROOT, timeout=10)
    return info["details"].splitlines()[-1] if info["status"] == "PASS" else "unknown"


def collect(*, full: bool, godot_bin: str | None = None) -> dict[str, Any]:
    checks: list[dict[str, Any]] = []
    for name, command, cwd in [
        ("Root unit/security tests",
         [sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v"], ROOT),
        ("Genesis source unit tests",
         [sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v"], GAME),
        ("Game code and art manifest validation",
         [sys.executable, "tools/validate_project.py"], GAME),
    ]:
        checks.append(run_check(name, command, cwd))
    for js in ("web/app.js", "web/labs.js", "web/journal.js"):
        checks.append(run_check("JavaScript syntax: " + js, ["node", "--check", js], ROOT, timeout=30))
    shell_paths = [str(path.relative_to(ROOT)) for pattern in
                   ("installer/*.sh", "scripts/*.sh", "image/*.sh", "start.sh")
                   for path in ROOT.glob(pattern)]
    if shell_paths:
        checks.append(run_check("Shell script syntax", ["bash", "-n", *shell_paths], ROOT, timeout=30))
    checks.append(hardware_check())
    engine_binary = godot_bin or shutil.which("godot") or shutil.which("godot4")
    if full and engine_binary:
        version = run_check("Pinned Godot version", [engine_binary, "--version"], GAME, timeout=30)
        if version["status"] == "PASS" and not godot_version_ok(version["details"]):
            version.update({"status": "FAIL", "details": "Wrong engine: " + version["details"]})
        checks.append(version)
        if version["status"] == "PASS":
            jobs = [
                ("Actual engine script import", ["--headless", "--path", str(GAME), "--editor", "--quit"], ""),
                ("Actual Explorer 30 frame run", ["--headless", "--path", str(GAME), "--quit-after", "30", "--", "--quality=explorer"], ""),
                ("Actual engine system contract", ["--headless", "--path", str(GAME), "--script", "res://tests/runtime_smoke.gd"], "WF ENGINE CONTRACT PASS"),
                ("Actual save recovery contract", ["--headless", "--path", str(GAME), "--script", "res://tests/save_guard_smoke.gd"], "WF SAVE GUARD CONTRACT PASS"),
                ("Actual assembly graph contract", ["--headless", "--path", str(GAME), "--script", "res://tests/assembly_scan_smoke.gd"], "WF ASSEMBLY SCAN PASS"),
            ]
            for name, args, expected in jobs:
                checks.append(run_check(name, [engine_binary, *args], GAME,
                                        engine=True, marker=expected))
    else:
        checks.append({"name": "Actual Godot engine and system tests", "status": "NOT_RUN",
                       "exit_code": None, "details": "Use --full with Godot 4.7.2 installed" if not full else "Godot not found"})
    totals = {v: sum(c["status"] == v for c in checks) for v in ("PASS", "FAIL", "NOT_RUN")}
    return {"schema": "wonderforge.agent-preflight.v1",
            "created_utc": datetime.now(timezone.utc).isoformat(),
            "revision": git_sha(),
            "host": {"os": platform.system(), "arch": platform.machine()},
            "requested_engine": full, "results": totals, "checks": checks,
            "manual_gates_not_covered": [
                "Windows/Linux graphical playtest and controller usability",
                "Actual Raspberry Pi 4B game frame-time and thermal capture",
                "Real socket/joint dynamics", "Finished professional art review",
                "Child-specific privacy and content review with adult",
                "Power-cut recovery on an actual Pi SD/SSD",
            ]}


def main() -> int:
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--full", action="store_true", help="Run true Godot engine tests")
    cli.add_argument("--godot-bin", help="Use explicit Godot 4.7.2 binary path")
    cli.add_argument("--strict", action="store_true", help="Exit nonzero if tests fail or requested Godot missing")
    cli.add_argument("--report", type=Path, help="Local JSON evidence output; do not commit private traces")
    args = cli.parse_args()
    evidence = collect(full=args.full, godot_bin=args.godot_bin)
    for c in evidence["checks"]:
        print(f"[{c['status']:<7}] {c['name']}")
    print("Summary:", evidence["results"])
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
        print("Local evidence:", args.report)
    if evidence["results"]["FAIL"]:
        return 1
    if args.strict and args.full and any(c["status"] == "NOT_RUN" and "Godot" in c["name"] for c in evidence["checks"]):
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
