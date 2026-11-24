from pathlib import Path
p=Path(__file__).resolve().parents[1]/'web/app.js'
s=p.read_text('utf8')
assert 'const ns=' in s
prefix="""
// ===== WONDERFORGE v0.4: REAL LINUX SESSION + SHARED TEAM API =====
let systemSession=null, installedApps=[], sharedItems=[];
const APP_STUDIOS={
 'voxel-universe':['luanti'],
 'pixel-and-paint':['krita','gimp','inkscape'],
 '3d-object-forge':['openscad'],
 'code-engine':['thonny','godot'],
 'electronics-hangar':['thonny','kicad'],
 'sound-reactor':['audacity'],
 'science-observatory':['stellarium'],
 'design-lab':['openscad','kicad']
};
async function wfApi(path,body=null){
 const options={headers:{'Accept':'application/json'}};
 if(body!==null){options.method='POST';options.headers['Content-Type']='application/json';options.body=JSON.stringify(body)}
 const response=await fetch(path,options);
 const data=await response.json();
 if(!response.ok||!data.ok)throw Error(data.error||('Local service returned '+response.status));
 return data;
}
async function wfInitSystem(){
 try{
  const [s,a]=await Promise.all([wfApi('/api/session'),wfApi('/api/apps')]);
  systemSession=s;installedApps=a.apps||[];
  if(s.team_available)await refreshShared(false);
 }catch(err){console.info('Local OS integration unavailable; pure prototype mode:',err.message)}
}
async function refreshShared(repaint=true){
 try{
  const data=await wfApi('/api/shared');
  sharedItems=data.items||[];
  if(systemSession)systemSession.team_available=!!data.enabled;
  if(repaint&&(route==='team'||route==='vault'))render();
 }catch(err){console.info('Shared folder not available:',err.message)}
}
function realVaultExtras(){
 if(!systemSession?.team_available)return '';
 const projects=allProjects();
 return `<article class="surface os-native-box"><div class="eyebrow">REAL LINUX TEAM SHARING</div><h3>Share an invention across accounts</h3><p>Copies a notebook to the group-owned Team Forge folder. Your personal original stays in this Linux user's browser.</p><div class="os-native-list">${projects.length?projects.map(p=>`<div class="os-native-row"><strong>${esc(p.title)}</strong><button class="btn btn-outline" data-action="share-project" data-id="${esc(p.id)}">SHARE COPY ↗</button></div>`).join(''):'Create a personal notebook first, then share a copy with your brother.'}</div></article>`;
}
function sharedCard(item){
 const mark=item.kind==='blueprint'?'▦':'▤';
 return `<button class="shared-team-card" data-shared-id="${esc(item.id)}"><span>${mark} ${esc(item.kind.toUpperCase())}</span><strong>${esc(item.title)}</strong><small>BY ${esc(item.author)} · ${esc(item.created||'')}</small><b>OPEN SHARED ITEM ↗</b></button>`;
}
function realTeamExtras(){
 if(!systemSession?.team_available){
  return `<article class="surface os-native-box"><div class="eyebrow">LINUX TEAM FOLDER</div><h3>Shared workspace not configured yet</h3><p>Install WonderForge for separate Linux accounts to enable group-owned project sharing. The current Team Forge profile in browser-demo mode is not account security.</p></article>`;
 }
 return `<article class="surface os-native-box"><div class="eyebrow">LIVE TEAM FORGE / SHARED LINUX DIRECTORY</div><h3>Creations you both can open.</h3><p>Atlas and Nova can contribute from their own Linux sessions. To contribute a notebook, go to Project Vault. To contribute your blocks, share from Pocket Builder.</p><div class="shared-team-grid">${sharedItems.length?sharedItems.map(sharedCard).join(''):'<p>No shared creations yet. Share a notebook or blueprint to begin.</p>'}</div><button class="btn btn-outline" data-action="shared-refresh">REFRESH TEAM FORGE ↻</button></article>`;
}
function realBuilderExtras(){
 if(!systemSession?.team_available)return '';
 return `<article class="surface os-native-box"><div class="eyebrow">REAL CROSS-ACCOUNT SHARING</div><h3>Publish a blueprint to Team Forge</h3><p>This makes a copy of the current block design accessible to both Linux accounts. It does not upload to the internet.</p><button class="btn btn-primary" data-action="share-blueprint">SHARE MY CURRENT BLUEPRINT ↗</button></article>`;
}
function realRouteExtras(){
 if(route==='team')return realTeamExtras();
 if(route==='vault')return realVaultExtras();
 if(route==='builder')return realBuilderExtras();
 return '';
}
async function openSharedItem(id){
 try{
  const response=await wfApi('/api/shared/'+encodeURIComponent(id)),item=response.item;
  if(item.kind==='notebook'){
    showModal(`<div class="eyebrow">TEAM FORGE / SHARED NOTEBOOK</div><h2>${esc(item.title)}</h2><p>Shared by ${esc(item.author)} · ${esc(item.created)}</p><div class="family-note" style="white-space:pre-wrap">${esc(item.notes||'')}</div><button class="btn btn-outline" data-action="close-modal">CLOSE</button>`);
  }else if(item.kind==='blueprint'){
    if(!confirm('Import shared blueprint “'+item.title+'”? Your current blocks will be replaced (undo is available).'))return;
    const data=item.blocks;
    if(!data||typeof data!=='object'||Array.isArray(data)||Object.keys(data).length>1152)throw Error('Invalid shared blueprint');
    const valid={};for(const [k,v] of Object.entries(data)){
      const m=k.match(/^(\\d+),(\\d+),([0-7])$/);
      if(m&&+m[1]<SIZE&&+m[2]<SIZE&&MATERIALS.some(x=>x.id===v))valid[k]=v;
    }
    pushUndo();blocks=valid;saveBlocks();go('builder');notify('Loaded a shared Team Forge blueprint!');
  }
 }catch(err){notify('Cannot open shared work: '+err.message)}
}
async function shareNotebook(id){
 const item=allProjects().find(p=>p.id===id);
 if(!item)return notify('Notebook was not found.');
 if(!confirm('Share “'+item.title+'” with both Linux accounts? The copy will be readable by the other brother.'))return;
 try{await wfApi('/api/shared',{kind:'notebook',title:item.title,notes:item.notes||''});await refreshShared(false);notify('Shared notebook saved for both inventors.');render()}
 catch(err){notify('Sharing failed: '+err.message)}
}
async function shareBlueprint(){
 if(!confirm('Publish your current blueprint to the shared Linux Team Forge folder?'))return;
 try{const title='Blueprint from '+(P[profile]?.name||'Inventor');await wfApi('/api/shared',{kind:'blueprint',title,blocks});await refreshShared(false);notify('Blueprint published to Team Forge.');render()}
 catch(err){notify('Cannot share blueprint: '+err.message)}
}
async function launchApprovedApp(appId){
 const app=installedApps.find(a=>a.id===appId&&a.installed);
 if(!app)return notify('This program is not currently installed.');
 if(!confirm('Launch locally installed program '+app.name+'?'))return;
 try{const r=await wfApi('/api/launch',{id:appId});notify('Requested '+app.name+' from this Linux desktop session.')}
 catch(err){notify('Could not launch: '+err.message)}
}
// ===== END OS INTEGRATION =====
"""
point="const NAV=["
assert point in s
s=s.replace(point,prefix+'\n'+point,1)
# Force real account isolation: entry auto redirects to actual Linux user
s=s.replace("function appStart(){const q=new URLSearchParams(location.search);", "function appStart(){if(systemSession?.linux_identity_enforced){enter(systemSession.profile);return;}const q=new URLSearchParams(location.search);",1)
s=s.replace("function enter(id){if(!P[id])return;", "function enter(id){if(!P[id])return;if(systemSession?.linux_identity_enforced&&id!==systemSession.profile){notify('Switch Linux users at the desktop login screen to access the other inventor’s files.');return;}",1)
s=s.replace("function render(){const content={", "function render(){const content={",1)
needle="$('#view').innerHTML=`<div class=\"page\">${content()}</div>`;"
assert needle in s
s=s.replace(needle,"$('#view').innerHTML=`<div class=\"page\">${content()}${realRouteExtras()}</div>`;",1)
# refresh team data after route
needle="$('#main').focus({preventScroll:true})}"
assert needle in s
s=s.replace(needle,"$('#main').focus({preventScroll:true});if(target==='team'||target==='vault')void refreshShared()}" ,1)
# Extend the studio modal's action choices safely
needle="${a.id==='code-engine'?`<button class=\"btn btn-outline\" data-route=\"logic\">${icon('command')} TRY ROBOT LOGIC LAB</button>`:''}"
assert needle in s
extra="${(APP_STUDIOS[a.id]||[]).filter(id=>installedApps.some(ap=>ap.id===id&&ap.installed)).map(id=>`<button class=\"btn btn-outline\" data-action=\"launch-app\" data-app-id=\"${esc(id)}\">LAUNCH ${esc(installedApps.find(ap=>ap.id===id).name)} ↗</button>`).join('')}"
s=s.replace(needle,needle+extra,1)
# OS mode don't let profile UI switch, avoid pseudo account masquerading
s=s.replace("'switch-profile':()=>{closeModal();profile=null;showWelcome()}", "'switch-profile':()=>{if(systemSession?.linux_identity_enforced){notify('Sign out from the Linux desktop to choose a different inventor account.');return;}closeModal();profile=null;showWelcome()}",1)
s=s.replace("'enter-team':()=>{enter('together');go('builder')}","'enter-team':()=>{if(systemSession?.linux_identity_enforced){go('team');return;}enter('together');go('builder')}",1)
s=s.replace("'team-note':()=>{enter('together');go('vault');newProjectModal(null,'Our team invention')}","'team-note':()=>{if(systemSession?.linux_identity_enforced){go('vault');newProjectModal(null,'Our team invention');return;}enter('together');go('vault');newProjectModal(null,'Our team invention')}",1)
needle="'logic-run':logicRun,"
assert needle in s
s=s.replace(needle,needle+"\n'share-project':el=>void shareNotebook(el.dataset.id),'share-blueprint':()=>void shareBlueprint(),'shared-refresh':()=>void refreshShared(),'launch-app':el=>void launchApprovedApp(el.dataset.appId),",1)
needle="if(btn.dataset.enter){enter(btn.dataset.enter);return}"
assert needle in s
s=s.replace(needle,"if(btn.dataset.sharedId){void openSharedItem(btn.dataset.sharedId);return}"+needle,1)
# do not hardcode fake absence of all OS integrations
s=s.replace("Not yet real:</b> Bootable OS image, actual Raspberry Pi OS installer, genuine 3D multiplayer world, running installed application launchers, enforced Linux user accounts and parent policies, generative AI or hardware metrics.",
            "Not yet complete:</b> A built and physically verified custom OS image, live 3D multiplayer world integration, full parental policy management, generative AI, or measured Pi 4 performance. A real Linux-user installer, curated app launcher, offline Luanti mod, and shared-folder service are now included separately; they require a genuine Pi installation.")
needle="applyPrefs();appStart()}"
assert needle in s
s=s.replace(needle,"await wfInitSystem();applyPrefs();appStart()}",1)
p.write_text(s)
print('patched JS bytes',len(s))
