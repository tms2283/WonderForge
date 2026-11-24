#!/usr/bin/env python3
"""Static source and authored-data checks. NOT a substitute for running Godot."""
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

def require(condition, reason):
    if not condition:
        raise AssertionError(reason)

def check_scenes_and_scripts():
    conf=(ROOT/'project.godot').read_text()
    require('res://scenes/Main.tscn' in conf,'Project must have Godot main scene')
    for file in sorted(ROOT.rglob('*.tscn')):
        contents=file.read_text()
        for resource in re.findall(r'path="(res://[^"]+)"',contents):
            require((ROOT/resource.removeprefix('res://')).exists(),f'Missing resource {resource} in {file}')
    gd_files=list(ROOT.rglob('*.gd'))
    require(len(gd_files)>=7, 'Expected actual playable scripts')
    for file in gd_files:
        contents=file.read_text()
        require('extends ' in contents,f'No GDScript extends in {file}')
        for preload in re.findall(r'preload\("(res://[^"]+)"\)',contents):
            require((ROOT/preload.removeprefix('res://')).exists(),f'Broken preload {preload} in {file}')
    return len(gd_files)

def check_catalog():
    p=json.loads((ROOT/'data/part_catalog.json').read_text())
    require(p['schema']=='wonderforge.genesis.part-catalog.v1','Unknown catalog schema')
    require(len(p['parts'])>=40,'At least 40 authored part specifications required')
    seen=set()
    for part in p['parts']:
        uid=part['id']
        require(uid not in seen and re.fullmatch(r'[a-z0-9.]+',uid),f'Invalid part id: {uid}')
        seen.add(uid)
        require(part['mass_kg']>0 and part['cost_units']>0,'Physical part data must be positive')
        require(len(part['dimensions_m'])==3 and all(v>0 for v in part['dimensions_m']),'Part dimensions invalid')
        require(len(part['sockets'])>=2,'Part must show at least two planned connection sockets')
        require(part['physics_status']=='UNVERIFIED_MODEL', 'Do not mark art/spec catalog as implemented')
    q=json.loads((ROOT/'data/quest_arcs.json').read_text())
    require(len(q['quests'])>=24,'At least 24 authored quest briefs required')
    require(len(set(x['region'] for x in q['quests']))==6,'Quest briefs must cover all six realms')
    require(all(x['implementation_status']=='DESIGN_SPEC_NOT_PLAYABLE' for x in q['quests']), 'Spec must not masquerade as implemented missions')
    return len(p['parts']),len(q['quests'])

def check_quality():
    s=(ROOT/'scripts/quality_profiles.gd').read_text()
    for mode in ['explorer','creator','ultra']:
        require(f'"{mode}":' in s, f'Missing {mode} quality profile')
    require('get_cmdline_user_args' in s, 'Quality override missing')
    game=(ROOT/'scripts/game.gd').read_text()
    require('QUALITY_SCRIPT.resolve_requested()' in game and 'landscape.tree_instances' in game,'Game does not apply quality data')
    require('genesis_save_v1.json' in game,'Shared save schema must remain stable')

def check_docs():
    mandatory=['MASTER_GAME_DESIGN.md','ART_BIBLE.md','AGENT_BUILD_PLAYBOOK.md','QA_ACCEPTANCE.md','PI4_PERFORMANCE.md','ARCHITECTURE_PLATFORM_MATRIX.md']
    for name in mandatory:
        p=ROOT/'docs'/name
        require(p.exists() and len(p.read_text().split())>300,f'Incomplete production reference: {name}')

def main():
    script_count=check_scenes_and_scripts()
    part_count,quest_count=check_catalog()
    check_quality();check_docs()
    print(f'PASS static source contracts | GDScript files: {script_count}, part specs: {part_count}, quest briefs: {quest_count}')
    print('NOTICE: Godot engine parse, runtime gameplay, graphics quality and Pi device certification NOT tested here')

if __name__=='__main__':
    try: main()
    except Exception as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
