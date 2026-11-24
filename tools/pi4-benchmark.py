#!/usr/bin/env python3
"""WonderForge read-only Pi 4B resource sampler (no network or dependency installs).

Run once on the idle desktop, once with Chromium+ForgeVerse open, once in Luanti.
This measures local CPU load, memory available, core temperatures and throttling;
it does not pretend to measure 3D game FPS or certify the build as child-safe.
"""
from __future__ import annotations
import argparse
import json
import os
from pathlib import Path
import shutil
import statistics
import subprocess
import time


def meminfo():
    try:
        parts={}
        for line in Path('/proc/meminfo').read_text().splitlines():
            key, rest = line.split(':', 1)
            try: parts[key]=int(rest.strip().split()[0])*1024
            except (ValueError, IndexError): pass
        return parts
    except OSError: return {}


def cpu_counters():
    try:
        first=Path('/proc/stat').read_text().splitlines()[0].split()
        values=[int(x) for x in first[1:]]
        # Linux /proc/stat: idle + iowait is the 'not working' subtotal.
        return sum(values),values[3] + (values[4] if len(values)>4 else 0)
    except (OSError, ValueError, IndexError): return 0,0


def cpu_fraction(before, after):
    total=max(0,after[0]-before[0]);idle=max(0,after[1]-before[1])
    return round(max(0,min(100,100*(total-idle)/total)),1) if total else None


def temp_c():
    try:return round(int(Path('/sys/class/thermal/thermal_zone0/temp').read_text().strip())/1000,1)
    except (OSError,ValueError):return None


def throttling():
    executable=shutil.which('vcgencmd')
    if not executable:return None
    try:
        result=subprocess.run([executable,'get_throttled'],capture_output=True,text=True,timeout=3,check=False)
        value=result.stdout.strip().split('=',1)[-1]
        return int(value,16) if value.startswith('0x') else None
    except (OSError,subprocess.TimeoutExpired):return None


def sample(duration=15, interval=1, label='desktop'):
    times=max(2,int(duration/interval))
    readings=[]
    before=cpu_counters()
    for i in range(times):
        time.sleep(interval)
        after=cpu_counters()
        memory=meminfo()
        entry={'offset_s':round((i+1)*interval,2),
               'cpu_percent':cpu_fraction(before,after),
               'available_mib':round(memory.get('MemAvailable',0)/(1024**2),1) if memory else None,
               'memory_total_mib':round(memory.get('MemTotal',0)/(1024**2),1) if memory else None,
               'temperature_c':temp_c(), 'throttled_bits':throttling()}
        readings.append(entry);before=after
    valid=lambda field:[r[field] for r in readings if isinstance(r.get(field),(int,float))]
    def summary(field):
        v=valid(field)
        return {'min':min(v),'median':round(statistics.median(v),1),'max':max(v)} if v else None
    return {'label':label,'hardware_model':
            Path('/proc/device-tree/model').read_bytes().decode('utf-8','replace').strip('\0')
            if Path('/proc/device-tree/model').exists() else 'Not Raspberry Pi',
            'duration_s':round(times*interval,1),'interval_s':interval,'is_real_pi4b':
            Path('/proc/device-tree/model').exists() and 'Raspberry Pi 4 Model B' in
            Path('/proc/device-tree/model').read_bytes().decode('utf-8','replace'),
            'summary':{'cpu_percent':summary('cpu_percent'),'available_mib':summary('available_mib'),
                       'temperature_c':summary('temperature_c')},
            'any_throttle_flags':any(bool(r['throttled_bits']) for r in readings),
            'measurements':readings,
            'notes':['A development computer is not a physical Pi performance result.',
                     'Thermal or power throttling can occur even when this sample appears smooth.',
                     'No measured FPS, audio latency, boot duration, or real-world battery behavior.',
                     'Compare desktop, world and creative application sessions on the actual Pi.']}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--duration',type=float,default=15)
    parser.add_argument('--interval',type=float,default=1)
    parser.add_argument('--label',default='idle-desktop')
    parser.add_argument('--json-out',type=Path)
    a=parser.parse_args()
    if not (2<=a.duration<=600 and .2<=a.interval<=10 and a.duration/a.interval>=2):
        parser.error('Use 2–600 sec total, 0.2–10 sec per sample, at least 2 samples')
    report=sample(a.duration,a.interval,a.label)
    pretty=json.dumps(report,indent=2)
    if a.json_out:
        a.json_out.write_text(pretty+'\n',encoding='utf8')
        print('Saved:',a.json_out)
    else:print(pretty)
    if not report['is_real_pi4b']:
        print('NOT A PHYSICAL PI 4B SAMPLE — DO NOT REPORT AS A PI PERFORMANCE TEST')
