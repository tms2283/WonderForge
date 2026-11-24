"""Read-only local diagnostics for WonderForge on a Raspberry Pi.

No telemetry, cloud requests, privileged commands, or guessed FPS. All values
come from a single on-device sample, are optional, and are labeled honestly.
"""
from __future__ import annotations

import os
from pathlib import Path
import platform
import shutil
import subprocess
import time


def read_text(path: str, limit: int = 4096) -> str:
    try:
        return Path(path).read_bytes()[:limit].replace(b'\0', b'').decode('utf-8', 'replace').strip()
    except OSError:
        return ''


def parse_meminfo(raw: str) -> dict:
    items = {}
    for line in raw.splitlines():
        if ':' not in line:
            continue
        key, value = line.split(':', 1)
        parts = value.strip().split()
        if parts and parts[0].isdigit():
            items[key] = int(parts[0])  # Linux /proc/meminfo reports kB.
    total = items.get('MemTotal', 0)
    available = items.get('MemAvailable', 0)
    return {'total_mib': round(total / 1024),
            'available_mib': round(min(total, available) / 1024),
            'used_percent': round(100 * (total - min(total, available)) / total, 1) if total else None}


def sample() -> dict:
    model = read_text('/proc/device-tree/model') or platform.machine()
    is_pi = 'Raspberry Pi 4 Model B' in model
    mem = parse_meminfo(read_text('/proc/meminfo'))
    temperature = None
    value = read_text('/sys/class/thermal/thermal_zone0/temp').split('\n', 1)[0]
    if value and value.lstrip('-').isdigit():
        n = int(value) / 1000
        if -40 <= n <= 140:
            temperature = round(n, 1)
    try:
        usage = shutil.disk_usage(str(Path.home()))
        disk = {'free_gib': round(usage.free / (1024 ** 3), 1),
                'total_gib': round(usage.total / (1024 ** 3), 1)}
    except OSError:
        disk = {'free_gib': None, 'total_gib': None}
    try:
        loads = [round(float(x), 2) for x in os.getloadavg()]
    except OSError:
        loads = None
    throttle = None
    if is_pi and Path('/usr/bin/vcgencmd').is_file():
        try:
            result = subprocess.run(['/usr/bin/vcgencmd', 'get_throttled'], capture_output=True,
                                    text=True, timeout=1, check=False)
            if result.returncode == 0 and result.stdout.strip().startswith('throttled=0x'):
                throttle = result.stdout.strip().split('=', 1)[1]
        except (OSError, subprocess.TimeoutExpired):
            pass
    return {'model': model[:160], 'is_target_pi4b': is_pi, 'memory': mem,
            'temperature_c': temperature, 'load_average': loads, 'disk': disk,
            'throttled_hex': throttle, 'sampled_at_epoch': int(time.time()),
            'disclosure': 'Live local observation only; no FPS estimate and no hardware certification.'}
