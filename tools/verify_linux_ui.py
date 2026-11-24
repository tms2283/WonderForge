#!/usr/bin/env python3
"""Browser-side integration verification with a simulated local Linux user API.
Does NOT claim a real Pi was used. The actual HTML, JS, CSS, and catalog bytes are run.
"""
from __future__ import annotations
import base64
import json
import re
from pathlib import Path
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'engineering-previews'
OUT.mkdir(exist_ok=True)


def start(page, username='atlas'):
    html=(ROOT/'web/index.html').read_text()
    html=re.sub(r'<link rel="stylesheet"[^>]*>', '', html)
    html=html.replace('<script src="/web/app.js" defer></script>', '')
    html=html.replace('<script src="/web/labs.js" defer></script>', '')
    page.set_content(html, wait_until='domcontentloaded')
    css=(ROOT/'web/styles.css').read_text()
    for im in (ROOT/'web/assets').glob('*.webp'):
        css=css.replace('/web/assets/'+im.name,
                        'data:image/webp;base64,'+base64.b64encode(im.read_bytes()).decode())
    page.add_style_tag(content=css)
    data={'quests':json.loads((ROOT/'data/quests.json').read_text()),
          'apps':json.loads((ROOT/'data/apps.json').read_text()),
          'learning':json.loads((ROOT/'data/learning.json').read_text())}
    page.evaluate('''(config)=>{
        let ls={};
        Object.defineProperty(window,'localStorage',{configurable:true,value:{
          getItem(k){return Object.prototype.hasOwnProperty.call(ls,k)?ls[k]:null},
          setItem(k,v){ls[k]=v},removeItem(k){delete ls[k]}}});
        window.__apiState={records:[],launches:[],private:{}};
        window.fetch=async function(url,opt={}){
          let value={ok:true};
          const u=String(url);
          if(u.endsWith('/data/quests.json'))value=config.quests;
          else if(u.endsWith('/data/learning.json'))value=config.learning;
          else if(u.endsWith('/data/apps.json'))value=config.apps;
          else if(u.endsWith('/api/session'))value={ok:true,username:config.username,profile:config.username,
            linux_identity_enforced:true,team_available:true,apps_available:true,version:'0.5'};
          else if(u.endsWith('/api/state')){
            if(opt.method==='POST'){let item=JSON.parse(opt.body);window.__apiState.private[item.key]=item.value;value={ok:true,saved:item.key}}
            else value={ok:true,persistent:true,state:window.__apiState.private};
          }
          else if(u.endsWith('/api/apps'))value={ok:true,apps:[{id:'luanti',name:'Luanti / ForgeVerse',installed:true},
            {id:'thonny',name:'Thonny Python',installed:true}]};
          else if(u.endsWith('/api/shared') && opt.method==='POST'){
            const b=JSON.parse(opt.body); const id='a'.repeat(23)+String(window.__apiState.records.length);
            const record={...b,id,author:config.username,created:'2026-11-22T00:00:00Z'};
            window.__apiState.records.push(record);
            value={ok:true,item:record};
          }else if(u.endsWith('/api/shared')){
            value={ok:true,enabled:true,items:window.__apiState.records};
          }else if(u.includes('/api/shared/')){
            const id=u.split('/').pop();value={ok:true,item:window.__apiState.records.find(x=>x.id===id)};
          }else if(u.endsWith('/api/launch')){
            window.__apiState.launches.push(JSON.parse(opt.body));value={ok:true,launched:'luanti'};
          }else throw Error('Unexpected mocked URL '+url);
          return {ok:true,status:opt.method==='POST'?201:200,json:async()=>value};
        };
    }''', {'username':username, **data})
    page.add_script_tag(content=(ROOT/'web/labs.js').read_text())
    page.add_script_tag(content=(ROOT/'web/app.js').read_text())
    page.wait_for_timeout(180)


def main():
    with sync_playwright() as p:
        browser=p.chromium.launch(headless=True,executable_path='/usr/bin/chromium',
                                  args=['--no-sandbox', '--disable-gpu'])
        page=browser.new_page(viewport={'width':1600,'height':1000},device_scale_factor=1)
        errs=[]
        page.on('pageerror',lambda ex: errs.append(str(ex)))
        page.on('dialog',lambda d:d.accept())
        start(page)
        assert page.locator('#welcome').is_hidden(), 'Linux account bypassed by welcome chooser'
        assert 'Atlas' in page.locator('#view').inner_text()
        page.locator('[data-action="switch-profile"]').first.click()
        assert page.locator('#welcome').is_hidden(), 'Profile switch bypassed Linux identity'
        page.locator('.sidebar nav [data-route="vault"]').click()
        page.locator('[data-action="new-project"]').first.click()
        page.locator('#project-title').fill('Sibling solar bridge')
        page.locator('#project-notes').fill('Test triangulated supports with identical weights.')
        page.locator('#project-form button[type=submit]').click()
        assert page.locator('[data-action="share-project"]').count()==1
        page.locator('[data-action="share-project"]').click()
        page.wait_for_timeout(170)
        assert len(page.evaluate('window.__apiState.records'))==1
        page.locator('.sidebar nav [data-route="team"]').click()
        page.wait_for_timeout(150)
        assert page.locator('.shared-team-card').count()==1
        page.screenshot(path=str(OUT/'01-Real-Team-Forge-Linux-Mode.png'),full_page=False)
        page.locator('.shared-team-card').click()
        assert page.locator('#modal').is_visible()
        assert 'Test triangulated' in page.locator('#modal').inner_text()
        page.locator('#modal [data-action="close-modal"]').first.click()
        page.locator('.sidebar nav [data-route="builder"]').click()
        page.locator('[data-action="builder-demo"]').click()
        page.locator('[data-action="share-blueprint"]').click()
        page.wait_for_timeout(130)
        assert len(page.evaluate('window.__apiState.records'))==2
        page.locator('.sidebar nav [data-route="studios"]').click()
        page.locator('[data-studio="voxel-universe"]').first.click()
        launch=page.locator('#modal [data-action="launch-app"]')
        assert launch.count()==1,'Installed local Luanti launch option missing'
        launch.click()
        page.wait_for_timeout(130)
        assert page.evaluate('window.__apiState.launches[0].id')=='luanti'
        page.locator('#modal [data-action="close-modal"]').first.click() if page.locator('#modal [data-action="close-modal"]').count() else page.keyboard.press('Escape')
        assert errs==[],errs
        page.close()
        mobile=browser.new_page(viewport={'width':390,'height':844},device_scale_factor=1)
        errs=[]
        mobile.on('pageerror',lambda ex:errs.append(str(ex)))
        start(mobile,'nova')
        assert 'Nova' in mobile.locator('#view').inner_text()
        mobile.locator('[data-action="toggle-menu"]').click()
        mobile.locator('.sidebar nav [data-route="team"]').click()
        mobile.wait_for_timeout(120)
        assert mobile.evaluate('document.documentElement.scrollWidth')<=390,'Mobile overflow'
        mobile.screenshot(path=str(OUT/'02-Mobile-Team-Forge-Linux-Mode.png'),full_page=False)
        assert errs==[],errs
        browser.close()
        print('PASS: Linux profile enforced, team shared notebook, blueprint publication, approved app launch, mobile, no JS errors')

if __name__=='__main__':main()
