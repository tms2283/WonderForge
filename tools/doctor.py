#!/usr/bin/env python3
"""Read-only diagnostic for future Raspberry Pi OS rollout."""
from pathlib import Path
import os
import platform
import shutil
import sys
import json

print('WONDERFORGE DEVICE CHECK (read-only)')
print('Operating system:', platform.platform())
print('Machine architecture:', platform.machine())
print('Python:', sys.version.split()[0])
print('Total RAM (GiB):', end=' ')
try:
    data = Path('/proc/meminfo').read_text()
    kb = int(next(line.split()[1] for line in data.splitlines() if line.startswith('MemTotal:')))
    print(round(kb / 1048576, 1))
except (OSError, StopIteration, ValueError): print('not available')
print('Home storage available (GiB):', round(shutil.disk_usage(Path.home()).free / (1024**3), 1))
for app in ['luanti','luantiserver','minetest','thonny','inkscape','krita','kicad','openscad','stellarium','godot','sonic-pi','chromium','firefox','kiwix-serve']:
    print(f'  {app:15} {shutil.which(app) or "not installed"}')
print('Screen session:', 'Wayland' if os.environ.get('WAYLAND_DISPLAY') else 'X11' if os.environ.get('DISPLAY') else 'headless')
print('No system changes made. A missing app may use a different launcher name.')
