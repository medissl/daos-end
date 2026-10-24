/* Isolated exported-game task walkthrough. Native control geometry, real input,
 * real time; no game API, accelerated clock or user-profile writes. */
const {chromium}=require('playwright');
const fs=require('node:fs'),path=require('node:path'),http=require('node:http'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),before=process.argv.includes('--before');
const slice=process.argv.includes('--slice');
const density=Number((process.argv.find(a=>a.startsWith('--density='))||'--density=3').split('=')[1]);
const desktopOnly=process.argv.includes('--desktop');
assert([2,2.625,3].includes(density));
const out=path.join(root,'docs/ux-reset'),phase=before?'before':desktopOnly?'final-desktop':density===3?'after':'density-'+density;
const build=path.join(root,before?'.verification/ux-reset-before/builds/web':'builds/web');
const geometry=JSON.parse(fs.readFileSync(path.join(root,before?'.verification/ux-reset-before/geometry.json':'.verification/ux-reset-geometry.json')));
const events=[],errors=[];let taps=0,scrolls=0;
fs.mkdirSync(path.join(out,'screenshots',phase),{recursive:true});
const log=(name,details={})=>{const event={name,...details};events.push(event);console.log(JSON.stringify(event));fs.writeFileSync(path.join(out,phase+'-progress.json'),JSON.stringify({events,errors},null,2))};
async function main(){
 const server=http.createServer((req,res)=>{
  if(req.url==='/fixture'){res.writeHead(200,{'Content-Type':'text/html'}).end('<title>Isolated fixture</title>');return}
  if(req.url==='/favicon.ico'){res.writeHead(204).end();return}
  const file=path.resolve(build,'.'+(req.url==='/'?'/index.html':req.url.split('?')[0]));
  if(!file.startsWith(build+path.sep)){res.writeHead(403).end();return}
  fs.readFile(file,(error,data)=>{if(error){res.writeHead(404).end();return}res.writeHead(200,{'Cache-Control':'no-store','Content-Type':({'.html':'text/html','.js':'text/javascript','.wasm':'application/wasm'})[path.extname(file)]||'application/octet-stream'}).end(data)});
 });
 await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
 const url='http://127.0.0.1:'+server.address().port+'/',browser=await chromium.launch({channel:'msedge',headless:true});
 try{
  for(const [width,height] of desktopOnly?[[1280,800]]:density!==3?[[390,844]]:slice?[[320,640],[430,932]]:[[320,640],[390,844],[430,932],[1280,800]]){
   const key=width+'x'+height,context=await browser.newContext({viewport:{width,height},hasTouch:true,isMobile:width<700,deviceScaleFactor:width<700?density:1});
   const page=await context.newPage(),began=Date.now();let profile='foundation',view='retreat';taps=0;scrolls=0;
   page.on('pageerror',error=>errors.push(key+': '+error.message));
   page.on('console',message=>{if(message.type()==='error'&&!message.text().includes('favicon'))errors.push(key+': '+message.text())});
   const g=()=>geometry[profile][key],layout=()=>g().views[view];
   const snap=async name=>{await page.mouse.move(0,0);await page.screenshot({path:path.join(out,'screenshots',phase,key+'-'+name+'.png'),scale:'css'})};
   async function record(data,filename='cultivation.json'){return page.evaluate(async ({data,filename})=>{
    const db=await new Promise((resolve,reject)=>{const req=indexedDB.open('/userfs');req.onsuccess=()=>resolve(req.result);req.onerror=reject});
    const tx=db.transaction('FILE_DATA',data?'readwrite':'readonly'),store=tx.objectStore('FILE_DATA'),key="/userfs/godot/app_userdata/Dao's End/"+filename;
    const entry=await new Promise(resolve=>{const req=store.get(key);req.onsuccess=()=>resolve(req.result)});
    if(!entry){db.close();return null}
    if(data){entry.contents=new TextEncoder().encode(JSON.stringify(data));entry.timestamp=new Date();store.put(entry,key)}
    await new Promise((resolve,reject)=>{tx.oncomplete=resolve;tx.onerror=reject});db.close();const raw=new TextDecoder().decode(entry.contents);return filename.endsWith('.json')?JSON.parse(raw):raw;
   },{data,filename})}
   async function start(){await page.goto(url);await page.waitForFunction(()=>!document.querySelector('#status'),{timeout:60000});await page.waitForTimeout(1100);await page.keyboard.press('Escape');const s=await record();view=s?.chapter?.journey.status==='camp'?'result':s?.chapter?.journey.status==='battle'?'battle':s?.realm==='Mortal'?'practices':'retreat'}
   async function seed(kind){profile=kind;const data=JSON.parse(fs.readFileSync(path.join(root,'.verification/jade-'+kind+'-fixture.json')));data.saved_at=Date.now()/1000;await page.goto(url+'fixture');await record(data);await start();assert.equal((await record()).realm,data.realm)}
   async function saved(predicate,label,timeout=8000){const limit=Date.now()+timeout;while(Date.now()<limit){const state=await record();if(predicate(state))return state;await page.waitForTimeout(400)}throw Error(key+' '+label+' timed out')}
   async function top(){await page.mouse.move(...layout().scroll);await page.mouse.wheel(0,-10000);await page.waitForTimeout(120)}
   async function click(id){const target=layout().targets[id];assert(target,'Missing '+profile+'/'+key+'/'+view+'/'+id);if(!['audio','compare','refine','improve','replace','slot'].includes(view))await top();if(target.scroll>0){scrolls++;const [x,y,w,h]=layout().bar,thumb=Math.max(8,h*layout().page/(layout().maximum+layout().page)),delta=Math.min(1,target.scroll/layout().maximum)*(h-thumb);await page.mouse.move(x+w*.5,y+thumb*.5);await page.mouse.down();await page.mouse.move(x+w*.5,y+thumb*.5+delta,{steps:12});await page.mouse.up();await page.waitForTimeout(150)}taps++;await page.touchscreen.tap(...target.point);await page.waitForTimeout(550)}
   async function tab(id){taps++;await page.touchscreen.tap(...(layout()?.tabs?.[id]||g().tabs[id]));view=id;await page.waitForTimeout(300)}
   await start();await seed('foundation');await snap('cultivate');
   if(before){
    await tab('journey');await click('route_stone_steps');view='preview';await snap('preview');
    const departScroll=layout().targets.depart.scroll;await click('depart');view='battle';await snap('battle');await click('camp_request');
    await saved(s=>s.chapter.journey.status==='camp','real first encounter to camp',100000);profile='camp';view='result';await snap('camp');
    const continueScroll=layout().targets.continue.scroll;await click('camp_build');view='arts';await snap('techniques');
    const beforeEquip=await record();await click('slot_1');await click('art_flame');
    let state=await saved(s=>s.chapter.combat_slots[1]==='flame','free discovery equip');assert.deepEqual(state.chapter.combat_mastery,beforeEquip.chapter.combat_mastery);assert.equal(state.herbs,beforeEquip.herbs);
    await tab('journey');view='result';await click('continue');await saved(s=>s.chapter.journey.status==='battle'&&s.chapter.journey.node===1,'continue second encounter');
    log('BASELINE route → battle → camp → equip → continue',{key,taps,scrolls,departScroll,continueScroll,seconds:(Date.now()-began)/1000,fixture:'Foundation entry, no gear/history; actual first battle, no accelerated clock'});
    await seed('camp');await tab('gear');await snap('equipment-empty');
    await seed('developed');await tab('gear');await snap('equipment-owned');
    await seed('foundation');await click('retreat_core');view='core';await snap('realm');
   }else{
    assert.equal(layout().targets.goal.scroll,0);await click('goal');view='preview';await snap('preview');
    if(density!==3)await page.screenshot({path:path.join(out,'screenshots',phase,key+'-preview-device.png'),scale:'device'});
    assert.equal(layout().targets.depart.scroll,0);await click('depart');view='battle';await snap('battle');
    assert.equal(layout().targets.camp_request.scroll,0);await click('camp_request');
    await saved(s=>s.chapter.journey.status==='camp','real first encounter to camp',100000);profile='camp';view='result';await snap('camp');
    const beforeEquip=await record();assert.equal(layout().targets.discovery_flame.scroll,0);await click('discovery_flame');
    let state=await saved(s=>s.chapter.combat_slots[1]==='flame','direct free discovery equip');assert.equal(state.chapter.combat_slots[0],'sword');assert.deepEqual(state.chapter.combat_mastery,beforeEquip.chapter.combat_mastery);assert.equal(state.herbs,beforeEquip.herbs);await snap('camp-equipped');
    const retained=state.chapter.journey.rewards;await click('camp_build');view='arts';await snap('techniques');
    await click('build_return');view='result';state=await record();assert.equal(state.chapter.journey.status,'camp');assert.deepEqual(state.chapter.journey.rewards,retained,'Build navigation cannot duplicate rewards');assert.equal(state.chapter.stones,beforeEquip.chapter.stones);assert.equal(state.herbs,beforeEquip.herbs);
    assert.equal(layout().targets.continue.scroll,0);await click('continue');view='battle';state=await saved(s=>s.chapter.journey.status==='battle'&&s.chapter.journey.node===1,'continue second encounter');assert.deepEqual(state.chapter.journey.battle.stats.slots,['sword','flame']);await snap('continued');
    assert.equal(scrolls,0,'The complete core task must need no scrolling');
    log('PASS route → battle → camp → equip → continue',{key,taps,scrolls,directFlowTaps:taps-2,buildDetourTaps:2,seconds:(Date.now()-began)/1000,fixture:'Foundation entry, no gear/history; ordinary-speed first fight; no general Help'});
    if(!slice&&density===3){
     taps=0;scrolls=0;
     await seed('camp');await tab('cultivate');view='retreat';await tab('explore');view='result';
     assert.equal((await record()).chapter.journey.status,'camp','Cultivate preserves paused journey');
     await click('camp_build');view='arts';await snap('techniques');
     await click('build_gear');view='gear';await snap('equipment-empty');
     assert.equal(Object.keys((await record()).chapter.inventory).length,0,'Empty inventory is not seeded away');
     await click('empty_gear_route');view='preview';assert.equal(layout().targets.depart.scroll,0);await snap('paused-route-preview');
     await tab('explore');view='result';assert.equal((await record()).chapter.journey.status,'camp');
     log('PASS empty equipment and journey recovery',{key,taps,scrolls});
     await seed('developed');await tab('build');view='arts';await click('build_gear');view='gear';await snap('equipment-owned');
     taps=0;scrolls=0;
     let original=await record();await click('compare_cinnabar_blade');view='compare';await snap('equipment-compare');
     const prefix=width>=700?'detail_':'sheet_';await click(prefix+'equip');view='gear';
     state=await saved(s=>s.chapter.equipment.weapon==='cinnabar_blade','free owned replacement');
     assert.equal(state.chapter.stones,original.chapter.stones);assert.equal(state.herbs,original.herbs);assert.deepEqual(state.chapter.inventory,original.chapter.inventory);
     await click('refine_cinnabar_blade');view='refine';await snap('equipment-refine');
     original=await record();await click(prefix+'buy');
     state=await saved(s=>s.chapter.inventory.cinnabar_blade===1,'separate refinement purchase');
     assert.equal(original.chapter.stones-state.chapter.stones,15);assert(state.qi<original.qi-2200,'Refinement spends 2500 Qi, allowing passive accrual');
     log('PASS owned equipment comparison and refinement',{key,taps,scrolls,refinePrice:'2500 Qi + 15 stones',freeEquipNoSpend:true});
     if(width<700)await click('sheet_close');
     await seed('developed');await tab('build');view='arts';
     await click('improve_sword');view='improve';await snap('technique-improve');
     original=await record();const target=layout().targets[prefix+'buy'];
     const cdp=await context.newCDPSession(page),[px,py]=target.point;
     await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:px,y:py}]});
     for(let i=1;i<=12;i++){await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x:px,y:py-i*8}]});await page.waitForTimeout(20)}
     await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});await page.waitForTimeout(700);
     state=await record();assert.deepEqual(state.chapter.combat_mastery,original.chapter.combat_mastery);assert.equal(state.herbs,original.herbs,'Dragging off price cannot train');
     if(width<700)await click('sheet_close');view='arts';
     await click('art_sword');view='replace';await snap('technique-replace');await click('replace_1');view='arts';
     state=await saved(s=>s.chapter.combat_slots[1]==='sword','explicit replace target');assert.equal(state.chapter.combat_slots[0],'ward');assert.equal(state.herbs,original.herbs);
     log('PASS explicit slot replacement and no purchase on drag',{key,masteryUnchanged:true,otherSlotRetained:true});
     await seed('foundation');await click('retreat_core');view='core';await snap('realm');
     await seed('developed');await tab('explore');view='journey';
     await click('route_stone_steps');view='preview';await click('preview_inspect');await snap('preview-inspection');assert.equal(layout().targets.depart.scroll,0);
     await seed('developed');await tab('explore');view='journey';
     await page.touchscreen.tap(...g().help);view='audio';await page.waitForTimeout(350);await snap('menu');
     const wasMuted=(await record(null,'audio.cfg'))?.includes('mute=true');
     await click('audio_mute');const setting=await record(null,'audio.cfg');assert(setting);await click('audio_close');
     await start();assert.equal(await record(null,'audio.cfg'),setting,'Menu settings survive reload');
     await page.touchscreen.tap(...g().help);view='audio';await page.waitForTimeout(350);await page.keyboard.press('Enter');await page.waitForTimeout(300);
     await snap('keyboard-return');
     log('PASS Menu settings reload and keyboard Return',{key,previouslyMuted:wasMuted});
     if(width===390){await page.setViewportSize({width:320,height:640});await page.waitForTimeout(650);await snap('resized-to-320');await page.setViewportSize({width:430,height:932});await page.waitForTimeout(650);await snap('resized-to-430');}
     await page.setViewportSize({width,height});
     await seed('mortal');await tab('explore');view='explore_locked';await snap('mortal-explore');await tab('build');view='build_locked';await snap('mortal-build');assert.equal((await record()).realm,'Mortal');
     await seed('refining');await tab('explore');view='gather';await snap('refining-gather');
     await seed('golden');await snap('golden-cultivate');await tab('build');view='arts';await snap('golden-build');
     log('PASS early-realm locks and Golden Core compositions',{key});
     if(width===390){
      await seed('developed');await tab('explore');view='journey';await click('route_stone_steps');view='preview';await click('depart');view='battle';await click('camp_request');
      original=await record();assert.equal(original.chapter.journey.status,'battle');const committed=original.chapter.journey.battle.stats.slots;
      await tab('build');view='arts';await click('art_sword');view='replace';await click('replace_1');view='arts';state=await record();
      assert.deepEqual(state.chapter.combat_slots,['ward','sword']);assert.deepEqual(state.chapter.journey.battle.stats.slots,committed,'Active encounter keeps its committed build');await snap('queued-next-encounter');
      // This running profile has a return dock absent in the idle developed
      // fixture; its pinned position is measured in the camp Build fixture.
      await page.touchscreen.tap(...geometry.camp[key].views.arts.targets.build_return.point);view='battle';await saved(s=>s.chapter.journey.status==='camp','queued build reaches requested camp',100000);profile='camp';view='result';await click('continue');view='battle';state=await saved(s=>s.chapter.journey.node===1,'queued next encounter');assert.deepEqual(state.chapter.journey.battle.stats.slots,['ward','sword']);
      log('PASS real battle queue boundary',{key,currentEncounterFrozen:true,nextEncounterCommitted:true});
     }
    }
   }
   assert.equal(await page.evaluate(()=>devicePixelRatio),width<700?density:1);await context.close();
  }
  assert.deepEqual(errors,[]);log('PASS',{phase});
 }finally{
  fs.writeFileSync(path.join(out,phase.toUpperCase()+'_BROWSER_RESULTS.json'),JSON.stringify({events,errors,completed:events.some(e=>e.name==='PASS')},null,2));await browser.close();server.close();
 }
}
main().catch(error=>{console.error(error);process.exit(1)});
