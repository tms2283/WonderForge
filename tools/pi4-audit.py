#!/usr/bin/env python3
"""Read-only Pi 4B setup audit for adult/maintainer. No network access."""
from __future__ import annotations
import json
import os
import platform
import pwd
import grp
import shutil
import stat
import subprocess
import sys
from pathlib import Path


def check():
    reports=[]
    def add(key,passed,detail,severity='warn'):
        reports.append({'check':key,'status':'pass' if passed else severity,'detail':str(detail)})
    modelpath=Path('/proc/device-tree/model')
    model=modelpath.read_bytes().decode('utf8','replace').strip('\0') if modelpath.exists() else '(not on Raspberry Pi)'
    add('hardware', 'Raspberry Pi 4 Model B' in model,model)
    machine=platform.machine()
    add('architecture',machine in ('aarch64','arm64'),machine)
    os_text=Path('/etc/os-release').read_text() if Path('/etc/os-release').exists() else ''
    add('OS release', 'VERSION_CODENAME=trixie' in os_text, next((x for x in os_text.splitlines() if x.startswith('PRETTY_NAME=')), 'unknown'))
    mem='unknown'
    try:
        line=next(x for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemTotal:'))
        mem=round(int(line.split()[1])/1024)
    except (OSError,StopIteration,ValueError): pass
    add('RAM detected',isinstance(mem,int) and 3350<=mem<=6550, str(mem)+' MiB',severity='warn')
    try:
        disk=shutil.disk_usage('/');free_gb=round(disk.free/(1024**3),1)
        add('storage free',free_gb>=4,str(free_gb)+' GiB free')
    except OSError: pass
    for username in ('atlas','nova'):
        try:
            entry=pwd.getpwnam(username)
            home=Path(entry.pw_dir)
            permissions=stat.S_IMODE(home.stat().st_mode)
            groups=[g.gr_name for g in grp.getgrall() if username in g.gr_mem]
            add(username+' account',entry.pw_uid>=1000 and permissions==0o700 and
                'wonderforge' in groups and not any(x in groups for x in ('sudo','docker','adm')),
                'uid=%s home=%s permissions=%o groups=%s'%(entry.pw_uid,home,permissions,','.join(groups)),severity='fail')
            world=home/'.minetest/worlds/WonderForge/worldmods/wonderforge/init.lua'
            add(username+' Luanti world',world.is_file(),str(world))
        except (KeyError,OSError):
            add(username+' account',False,'not yet provisioned',severity='fail')
    team=Path('/srv/wonderforge/team')
    if team.exists():
        st=team.stat()
        add('Team Forge permissions',stat.S_IMODE(st.st_mode)==0o2770 and
            grp.getgrgid(st.st_gid).gr_name=='wonderforge',
            'mode=%o group=%s'%(stat.S_IMODE(st.st_mode),grp.getgrgid(st.st_gid).gr_name),severity='fail')
    else: add('Team Forge permissions',False,'no shared folder',severity='fail')
    for app in ('chromium','luanti','thonny','gimp'):
        add(app, bool(shutil.which(app)),shutil.which(app) or 'not installed')
    add('WonderForge launcher',Path('/usr/local/bin/wonderforge-launch').exists(), '/usr/local/bin/wonderforge-launch')
    add('WonderForge service',Path('/usr/lib/systemd/user/wonderforge.service').exists(),'/usr/lib/systemd/user/wonderforge.service')
    add('Network guard configured',Path('/etc/wonderforge-family.nft').exists(),
        'Optional account-level outbound blocking; not a full content filter')
    return reports


if __name__=='__main__':
    checks=check()
    if '--json' in sys.argv:print(json.dumps(checks,indent=2))
    else:
        print('WONDERFORGE / PHYSICAL PI 4B AUDIT (READ-ONLY)')
        for row in checks:
            print('[%5s] %-27s %s'%(row['status'].upper(),row['check'],row['detail']))
        print('Pass: %d  Warnings: %d  Fail: %d'%(
            sum(x['status']=='pass' for x in checks),sum(x['status']=='warn' for x in checks),sum(x['status']=='fail' for x in checks)))
