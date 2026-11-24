#!/usr/bin/env python3
"""Produce real Chromium screenshots from the actual local app code.

The runner replaces only resource fetching with the exact bundled asset bytes:
this is needed because some sandbox browsers block localhost navigation. The app
JavaScript, CSS, DOM, storage behavior, animations and interactions are real.
Requires playwright and a Chromium binary, not necessary to run WonderForge.
"""
from pathlib import Path
from playwright.sync_api import sync_playwright
import base64,re,json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'previews'
OUT.mkdir(parents=True,exist_ok=True)

def start(page):
    html=(ROOT/'web/index.html').read_text(encoding='utf-8')
    html=re.sub(r'<link rel="stylesheet"[^>]*>','',html)
    html=html.replace('<script src="/web/app.js" defer></script>','')
    page.set_content(html,wait_until='domcontentloaded')
    css=(ROOT/'web/styles.css').read_text(encoding='utf-8')
    for im in (ROOT/'web/assets').glob('*.webp'):
        css=css.replace('/web/assets/'+im.name,'data:image/webp;base64,'+base64.b64encode(im.read_bytes()).decode())
    page.add_style_tag(content=css)
    page.evaluate("""d=>{let data={};Object.defineProperty(window,'localStorage',{configurable:true,value:{getItem:k=>data[k]||null,setItem:(k,v)=>{data[k]=v},removeItem:k=>{delete data[k]}}});window.fetch=async function(u){return {ok:true,json:async()=>JSON.parse(u.includes('quests.json')?d.quests:d.apps)}};}""", {'quests':(ROOT/'data/quests.json').read_text(),'apps':(ROOT/'data/apps.json').read_text()})
    page.add_script_tag(content=(ROOT/'web/app.js').read_text(encoding='utf-8'))
    page.wait_for_timeout(140)

def snap(page,name):
    page.evaluate("document.querySelector('#toast').classList.remove('show')")
    page.evaluate('window.scrollTo({top:0,behavior:"instant"})')
    page.screenshot(path=str(OUT/name),full_page=False)
    print(name)

def main():
    with sync_playwright() as p:
        b=p.chromium.launch(headless=True,executable_path='/usr/bin/chromium',args=['--no-sandbox','--disable-gpu'])
        page=b.new_page(viewport={'width':1600,'height':1000},device_scale_factor=1)
        errors=[];page.on('pageerror',lambda e:errors.append(str(e)))
        start(page);snap(page,'A-00-Workshop-Gateway.png')
        page.locator('[data-enter="atlas"]').click();snap(page,'A-01-Mission-Control.png')
        views=[('world','A-02-ForgeVerse.png'),('builder','A-03-Pocket-Builder.png'),('logic','A-04-Robot-Logic-Lab.png'),('quests','A-05-Quest-Atlas.png'),('studios','A-06-Creation-Studios.png'),('orbit','A-07-ORBIT.png'),('vault','A-08-Project-Vault.png'),('library','A-09-Discovery-Library.png'),('team','A-10-Team-Forge.png'),('parent','A-11-Parent-Desk.png'),('settings','A-12-Settings.png')]
        for route,name in views:
            page.locator(f'.sidebar nav [data-route="{route}"]').click()
            if route=='builder':
                page.locator('[data-action="builder-demo"]').click();snap(page,'A-03b-Builder-With-Model.png')
                page.locator('[data-action="builder-undo"]').click()
                page.locator('[data-action="builder-redo"]').click()
            if route=='logic':
                for cmd in 'RRRUUURRRUUU':page.locator(f'[data-cmd="{cmd}"]').click()
                page.locator('[data-action="logic-run"]').click()
                page.wait_for_timeout(3150)
                status=page.locator('.logic-status').inner_text()
                assert 'SOLVED!' in status,status
                snap(page,'A-04b-Robot-Logic-Lab-Solved.png')
                page.locator('[data-action="logic-reset"]').click()
            if route=='orbit':page.locator('[data-prompt]').first.click()
            if route=='vault':
                for title,note in [('Skybridge prototype','Tested how triangular braces strengthen a paper span.'),('Rescue rover','Idea: a sensor triggers an LED when a robot senses an obstacle.')]:
                    page.locator('[data-action="new-project"]').first.click()
                    page.locator('#project-title').fill(title)
                    page.locator('#project-notes').fill(note)
                    page.locator('#project-form button[type=submit]').click()
                assert page.locator('.vault-card').count()==2
            snap(page,name)
        assert not errors,errors
        print('Desktop route checks passed; javascript errors:',len(errors))
        page.close()
        m=b.new_page(viewport={'width':390,'height':844},device_scale_factor=1)
        errors=[];m.on('pageerror',lambda e:errors.append(str(e)))
        start(m);m.locator('[data-enter="nova"]').click();snap(m,'B-00-Mobile-Mission-Control.png')
        for route,name in [('world','B-01-Mobile-ForgeVerse.png'),('logic','B-02-Mobile-Robot-Logic-Lab.png')]:
            m.locator('[data-action="toggle-menu"]').click()
            m.locator(f'.sidebar nav [data-route="{route}"]').click()
            snap(m,name)
            assert m.evaluate('document.documentElement.scrollWidth')<=390,'Mobile overflow'
        assert not errors,errors
        print('Mobile checks passed; horizontal overflow: none')
        m.close();b.close()

if __name__=='__main__':main()
