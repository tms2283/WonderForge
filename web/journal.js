/* WonderForge Maker Journal: offline, dependency-free, testable data model.
 * Records are learner-authored evidence, never automatic proof of mastery.
 */
(function(root,factory){
  if(typeof module==='object'&&module.exports)module.exports=factory();
  else root.WonderForgeJournal=factory();
})(typeof globalThis!=='undefined'?globalThis:this,function(){
  'use strict';
  const fields={title:100,questId:80,question:1600,hypothesis:2400,method:2400,observation:2400,conclusion:2400,nextStep:2400};
  const maxEntries=75;
  function validate(raw){
    if(!raw||typeof raw!=='object'||Array.isArray(raw))throw Error('Expected a journal record');
    const out={};
    for(const [key,max]of Object.entries(fields)){
      const val=raw[key]??'';
      if(typeof val!=='string'||val.length>max)throw Error('Invalid journal field: '+key);
      out[key]=val.trim();
    }
    if(!out.title||out.title.length<3)throw Error('Give your experiment a title (at least 3 characters)');
    if(out.questId&&!/^[a-z0-9-]{1,80}$/.test(out.questId))throw Error('Invalid quest link');
    if(raw.id!==undefined&&(typeof raw.id!=='string'||!/^[A-Za-z0-9-]{4,80}$/.test(raw.id)))throw Error('Invalid journal ID');
    out.id=raw.id||('experiment-'+Date.now()+'-'+Math.random().toString(36).slice(2,8));
    out.updated=typeof raw.updated==='string'&&/^\d{4}-\d{2}-\d{2}T/.test(raw.updated)?raw.updated:new Date().toISOString();
    return out;
  }
  function hasEvidence(x){return ['hypothesis','method','observation','conclusion'].every(k=>typeof x[k]==='string'&&x[k].trim().length>=10)}
  function sanitize(list){if(!Array.isArray(list))return[];const seen=new Set();const safe=[];for(const raw of list.slice(0,maxEntries)){try{const e=validate(raw);if(!seen.has(e.id)){safe.push(e);seen.add(e.id)}}catch{}}return safe;}
  function summarize(list,quests=[]){const entries=sanitize(list);const evidenced=entries.filter(hasEvidence);const ids=new Set(quests.map(q=>q.id));const linked=new Set(evidenced.filter(e=>ids.has(e.questId)).map(e=>e.questId));return {entries:entries.length,evidenced:evidenced.length,linkedQuests:linked.size,linkedQuestIds:Array.from(linked).sort()};}
  function exportDocument(list,workspace){return {format:'wonderforge-maker-journal',version:1,workspace,exportedAt:new Date().toISOString(),entries:sanitize(list)};}
  function parseImport(data){if(!data||data.format!=='wonderforge-maker-journal'||data.version!==1||!Array.isArray(data.entries)||data.entries.length>maxEntries)throw Error('Invalid journal backup');const safe=sanitize(data.entries);if(safe.length!==data.entries.length)throw Error('Backup contains duplicate or invalid records');return safe;}
  return {validate,hasEvidence,sanitize,summarize,exportDocument,parseImport,maxEntries};
});
