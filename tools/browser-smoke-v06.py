#!/usr/bin/env python3
"""Optional Playwright smoke test. Isolated mock API, not physical Pi validation.

Usage: python3 tools/browser-smoke-v06.py [--screenshot-dir PATH]
Requires the extra development dependency `playwright` and installed Chromium.
"""
import argparse
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]


def run(output:Path):
    from playwright.sync_api import sync_playwright
    html=(ROOT/'web/index.html').read_text()
    html=re.sub(r'<script src="[^"]+" defer></script>', '', html)
    html=re.sub(r'<link rel="stylesheet"[^>]*>', '', html)
    css=(ROOT/'web/styles.css').read_text()
    js_files=['web/labs.js','web/journal.js','web/app.js']
    quests=json.loads((ROOT/'data/quests.json').read_text())
    apps=json.loads((ROOT/'data/apps.json').read_text())
    learning=json.loads((ROOT/'data/learning.json').read_text())
    output.mkdir(parents=True,exist_ok=True)
    with sync_playwright() as play:
        browser=play.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox'])
        page=browser.new_page(viewport={'width':1440,'height':900},device_scale_factor=1)
        errors=[]
        page.on('pageerror', lambda e: errors.append(str(e)))
        page.set_content(html,wait_until='domcontentloaded')
        page.add_style_tag(content=css)
        mock_js='''const __ls={};Object.defineProperty(window,'localStorage',{configurable:true,value:{getItem:k=>Object.prototype.hasOwnProperty.call(__ls,k)?__ls[k]:null,setItem:(k,v)=>{__ls[k]=String(v)},removeItem:k=>{delete __ls[k]},clear:()=>{for(const k in __ls)delete __ls[k]}}});window.__mockCatalogs=JSON.parse('''+json.dumps(json.dumps({'quests':quests,'apps':apps,'learning':learning}))+''');
window.fetch=async path=>{let url=String(path),body={ok:true};
if(url.includes('quests.json'))body=window.__mockCatalogs.quests;
else if(url.includes('apps.json'))body=window.__mockCatalogs.apps;
else if(url.includes('learning.json'))body=window.__mockCatalogs.learning;
else if(url==='/api/session')body={ok:true,username:'dev',profile:null,linux_identity_enforced:false,team_available:false,version:'0.6'};
else if(url==='/api/apps')body={ok:true,apps:[]};
else if(url==='/api/shared')body={ok:true,enabled:false,items:[]};
else if(url==='/api/health')body={ok:true,health:{model:'DEVELOPMENT FIXTURE / NO ACTUAL PI',is_target_pi4b:false,memory:{total_mib:4096,available_mib:2800,used_percent:31.6},disk:{free_gib:40,total_gib:60},load_average:[.1,.2,.3],temperature_c:null,throttled_hex:null,disclosure:'Live local observation only; no FPS estimate and no hardware certification.'}};
return {ok:true,status:200,json:async()=>body};};'''
        page.evaluate(mock_js)
        for path in js_files:page.add_script_tag(content=(ROOT/path).read_text())
        page.get_by_role('button',name=re.compile('ATLAS',re.I)).first.click()
        page.wait_for_timeout(250)
        assert 'Welcome back' in page.locator('#view').inner_text()
        page.locator('[data-route="journal"]').first.click()
        page.wait_for_timeout(130)
        assert 'Proof of curiosity' in page.locator('#view').inner_text()
        page.locator('#journal-title').fill('A bridge with triangular braces')
        page.locator('#journal-quest').select_option('sky-fortress')
        for name,value in [('question','Does bracing reduce deflection?'),('hypothesis','Adding a brace should reduce bridge sag.'),('method','Keep load the same, compare two structures.'),('observation','Observed deflection from 5mm to 2mm.'),('conclusion','The braced model sagged less in our test.'),('nextStep','Try more loads with same span.')]:
            page.locator('#journal-'+name).fill(value)
        page.locator('#journal-form button[type="submit"]').click()
        assert 'WITH COMPLETE EVIDENCE' in page.locator('#view').inner_text()
        assert page.locator('.journal-item').count()==1, page.locator('#toast').inner_text()
        page.screenshot(path=str(output/'maker-journal.png'),full_page=True)
        page.locator('[data-route="pulse"]').first.click()
        page.wait_for_timeout(250)
        text=page.locator('#view').inner_text()
        assert 'DEVELOPMENT HOST' in text and '2800' in text
        page.screenshot(path=str(output/'system-pulse.png'),full_page=True)
        page.set_viewport_size({'width':390,'height':844})
        page.locator('[data-action="toggle-menu"]').first.click()
        page.locator('[data-route="journal"]').first.click()
        assert page.locator('#journal-title').count()==1
        assert page.evaluate('document.documentElement.scrollWidth<=window.innerWidth+2'), 'Mobile horizontal overflow'
        page.screenshot(path=str(output/'maker-journal-mobile.png'),full_page=True)
        assert not errors,errors
        print('PASS: desktop Maker Journal evidence save, System Pulse dev-host honesty, mobile layout, 0 JavaScript errors')
        browser.close()

if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--screenshot-dir',default=str(ROOT/'engineering-previews'/'v06'))
    args=parser.parse_args()
    run(Path(args.screenshot_dir))
