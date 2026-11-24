#!/usr/bin/env python3
"""Browser acceptance for ORBIT with a simulated LOCAL response, no model weights.

Chromium automation on a development host is not Pi 4 performance proof.
"""
import json
import re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def run():
    from playwright.sync_api import sync_playwright
    html=(ROOT/'web/index.html').read_text()
    html=re.sub(r'<script src="[^"]+" defer></script>', '',html)
    html=re.sub(r'<link rel="stylesheet"[^>]*>', '',html)
    catalogs={name:json.loads((ROOT/'data'/f'{name}.json').read_text()) for name in ('quests','apps','learning')}
    catalog=json.dumps(catalogs)
    with sync_playwright() as p:
        browser=p.chromium.launch(headless=True,executable_path='/usr/bin/chromium',args=['--no-sandbox'])
        page=browser.new_page(viewport={'width':1440,'height':900})
        errors=[]; page.on('pageerror',lambda err: errors.append(str(err)))
        page.set_content(html,wait_until='domcontentloaded')
        page.add_style_tag(content=(ROOT/'web/styles.css').read_text())
        js=r'''
const __db={};Object.defineProperty(window,'localStorage',{configurable:true,value:{getItem:k=>Object.prototype.hasOwnProperty.call(__db,k)?__db[k]:null,setItem:(k,v)=>{__db[k]=String(v)},removeItem:k=>{delete __db[k]},clear:()=>{for(let k in __db)delete __db[k]}}});
window.__catalogs=CATALOG_PLACEHOLDER;
window.__calls=[];window.__modelReady=true;
window.fetch=async(path,opts={})=>{let url=String(path),body={ok:true};window.__calls.push(url);
if(url.endsWith('/quests.json'))body=window.__catalogs.quests;
else if(url.endsWith('/apps.json'))body=window.__catalogs.apps;
else if(url.endsWith('/learning.json'))body=window.__catalogs.learning;
else if(url==='/api/session')body={ok:true,username:'dev',profile:null,linux_identity_enforced:false,team_available:false,version:'0.7'};
else if(url==='/api/apps')body={ok:true,apps:[]};
else if(url==='/api/ai/status')body={ok:true,ai:{available:window.__modelReady,enabled:true,model:'qwen3:0.6b',reason:window.__modelReady?'':'Ollama not installed'}};
else if(url==='/api/ai/chat')body={ok:true,reply:'Test with two spans and record the results.',model:'qwen3:0.6b',calls:[{name:'search_lessons',status:'ok'}],sources:[{id:'bridge',title:'Build stronger bridges',type:'lesson'}],proposal:{token:'a'.repeat(32),requires_confirmation:true,preview:{title:'A braced bridge study',question:'Does adding braces reduce simulated sag?',hypothesis:'Braces may reduce displacement.',method:'Compare two models.',observation:'',conclusion:'',nextStep:'Use the field guide.'}}};
else if(url==='/api/ai/approve')body={ok:true,approved_draft:{title:'A braced bridge study',question:'Does adding braces reduce simulated sag?',hypothesis:'Braces may reduce displacement.',method:'Compare two models.',observation:'',conclusion:'',nextStep:'Use the field guide.'}};
else if(url==='/api/shared')body={ok:true,enabled:false,items:[]};
else if(url==='/api/health')body={ok:true,health:{model:'TEST HOST',is_target_pi4b:false,memory:{available_mib:2000},disk:{free_gib:20},disclosure:'test'}};
return {ok:true,status:200,json:async()=>body};};
window.confirm=()=>true;
'''.replace('CATALOG_PLACEHOLDER',catalog)
        page.evaluate(js)
        for name in ('labs','journal','app'):
            page.add_script_tag(content=(ROOT/'web'/f'{name}.js').read_text())
        page.get_by_role('button',name=re.compile('ATLAS',re.I)).first.click()
        page.locator('[data-route="orbit"]').first.click()
        page.wait_for_timeout(200)
        assert 'LOCAL AI' in page.locator('#view').inner_text()
        page.locator('#chat-input').fill('Plan an experiment')
        page.locator('#chat-form button[type="submit"]').click()
        page.wait_for_timeout(250)
        content=page.locator('#view').inner_text()
        assert 'Test with two spans' in content,content[:700]
        assert 'NOT YET SAVED' in content
        assert 'Build stronger bridges' in content
        page.locator('[data-action="ai-approve"]').click()
        page.wait_for_timeout(100)
        content=page.locator('#view').inner_text()
        assert 'A braced bridge study' in content,content[:700]
        assert page.locator('#journal-title').input_value()=='A braced bridge study'
        assert page.locator('#journal-observation').input_value()==''
        assert page.locator('#journal-conclusion').input_value()==''
        assert page.evaluate('JSON.parse(localStorage.getItem("wf-reforged:v3:journal:atlas")).length')==1
        assert page.evaluate('window.__calls.filter(x=>x==="/api/ai/chat").length')==1
        # A model-disabled browser must explicitly display and use the scripted fallback.
        page.evaluate('window.__modelReady=false')
        page.locator('[data-route="orbit"]').first.click()
        page.locator('[data-action="ai-refresh"]').click()
        page.wait_for_timeout(70)
        assert 'SCRIPTED FALLBACK' in page.locator('#view').inner_text()
        page.locator('#chat-input').fill('How should I test a beam?')
        page.locator('#chat-form button[type="submit"]').click()
        assert page.locator('.bubble.agent').count()>=2, page.locator('#view').inner_text()
        assert page.evaluate('window.__calls.filter(x=>x==="/api/ai/chat").length')==1, 'Fallback must not invoke a model'
        page.set_viewport_size({'width':390,'height':844})
        page.wait_for_timeout(100)
        assert page.evaluate('document.documentElement.scrollWidth<=window.innerWidth+2'), 'Mobile overflow'
        out=ROOT/'engineering-previews'/'v07';out.mkdir(parents=True,exist_ok=True)
        page.screenshot(path=str(out/'ORBIT-mobile-offline.png'),full_page=True)
        page.evaluate('window.__modelReady=true')
        page.locator('[data-action="ai-refresh"]').click()
        page.wait_for_timeout(100)
        page.screenshot(path=str(out/'ORBIT-mobile-local-ai.png'),full_page=True)
        page.set_viewport_size({'width':1440,'height':900})
        page.screenshot(path=str(out/'ORBIT-desktop-local-ai.png'),full_page=True)
        assert not errors,errors
        print('PASS: local model, bounded tool response, approval -> Maker Journal draft, fallback, 390px responsive, 0 JS errors')
        browser.close()

if __name__=='__main__':run()
