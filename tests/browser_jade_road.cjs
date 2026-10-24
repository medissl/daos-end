/* Real exported Godot game in isolated Edge storage. Inputs use measured native
 * control geometry; no game state API or accelerated clock is injected. */
const {chromium}=require('playwright');
const fs=require('node:fs'),path=require('node:path'),http=require('node:http'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),out=path.join(root,'docs/jade-road');
const geometry=JSON.parse(fs.readFileSync(path.join(root,'.verification/jade-ui-geometry.json')));
const normal=process.argv.includes('--normal'),audioOnly=process.argv.includes('--audio'),comparison=process.argv.includes('--comparison'),retina=process.argv.includes('--retina');
const density=Number((process.argv.find(arg=>arg.startsWith('--density='))||'--density=3').split('=')[1]);
assert([2,2.625,3].includes(density),'Supported test densities');
function audioProbe(){
 window.__sound={blocks:[],contexts:[],connections:0,connectedSources:[],rate:48000};
 const connect=AudioNode.prototype.connect;
 AudioNode.prototype.connect=function(destination,...rest){
  const answer=connect.call(this,destination,...rest),ctx=this.context;
  if(destination===ctx.destination&&!this.__probe){
   const s=window.__sound;
   if(!s.contexts.includes(ctx))s.contexts.push(ctx);
   s.connections++;s.connectedSources.push(this.constructor.name);
   if(!ctx.__probe){
    const probe=ctx.createScriptProcessor(2048,2,2),silent=ctx.createGain();
    probe.__probe=true;silent.__probe=true;silent.gain.value=0;
    connect.call(probe,silent);connect.call(silent,ctx.destination);
    probe.onaudioprocess=e=>{s.rate=e.inputBuffer.sampleRate;const l=e.inputBuffer.getChannelData(0),r=e.inputBuffer.getChannelData(1);s.blocks.push([Array.from(l),Array.from(r)]);if(s.blocks.length>180)s.blocks.shift()};
    ctx.__probe=probe;
   }
   connect.call(this,ctx.__probe);
  }
  return answer;
 };
}
async function main(){
 const server=http.createServer((req,res)=>{
  if(req.url==='/fixture'){res.writeHead(200,{'Content-Type':'text/html'}).end('<title>Isolated fixture</title>');return}
  if(req.url==='/favicon.ico'){res.writeHead(204).end();return}
  const file=path.resolve(root,'builds/web','.'+(req.url==='/'?'/index.html':req.url.split('?')[0]));
  if(!file.startsWith(path.join(root,'builds/web')+path.sep)){res.writeHead(403).end();return}
  fs.readFile(file,(e,b)=>{if(e){res.writeHead(404).end();return}res.writeHead(200,{'Cache-Control':'no-store','Content-Type':({'.html':'text/html','.js':'text/javascript','.wasm':'application/wasm'})[path.extname(file)]||'application/octet-stream'}).end(b)});
 });
 await new Promise(r=>server.listen(0,'127.0.0.1',r));
 const browser=await chromium.launch({channel:'msedge',headless:true});
 const context=await browser.newContext({viewport:{width:430,height:932},hasTouch:true,...(retina?{isMobile:true,deviceScaleFactor:density}:{})});
 await context.addInitScript(audioProbe);
 const page=await context.newPage(),errors=[],events=[],began=Date.now();
 const touchSession=await context.newCDPSession(page);
 page.on('pageerror',e=>errors.push(e.message));
 page.on('console',m=>{if(m.type()==='error'&&!m.text().includes('favicon'))errors.push(m.text())});
 const url='http://127.0.0.1:'+server.address().port+'/';
 let key='430x932',profile='foundation',view='retreat';
 const g=()=>geometry[profile][key],layout=()=>g().views[view];
 const log=(name,data={})=>{events.push({name,seconds:(Date.now()-began)/1000,...data});console.log(JSON.stringify(events.at(-1)));fs.writeFileSync(path.join(out,normal?'normal-progress.json':retina?'density-'+density+'-progress.json':'browser-progress.json'),JSON.stringify({events,errors},null,2))};
 const snap=async name=>{await page.mouse.move(0,0);await page.screenshot({path:path.join(out,'screenshots',name+'.png'),scale:normal?'css':'device'})};
 async function start(dismiss=true){await page.goto(url);await page.waitForFunction(()=>!document.querySelector('#status'),{timeout:60000});await page.waitForTimeout(1200);if(dismiss)await page.keyboard.press('Escape');view='retreat'}
 async function record(data,filename='cultivation.json'){
  return page.evaluate(async({data,filename})=>{
   const db=await new Promise((resolve,reject)=>{const r=indexedDB.open('/userfs');r.onsuccess=()=>resolve(r.result);r.onerror=reject});
   const tx=db.transaction('FILE_DATA',data?'readwrite':'readonly'),store=tx.objectStore('FILE_DATA');
   const k="/userfs/godot/app_userdata/Dao's End/"+filename;
   const entry=await new Promise(resolve=>{const r=store.get(k);r.onsuccess=()=>resolve(r.result)});
   if(!entry){db.close();return null}
   if(data){entry.contents=new TextEncoder().encode(JSON.stringify(data));entry.timestamp=new Date();store.put(entry,k)}
   await new Promise((resolve,reject)=>{tx.oncomplete=resolve;tx.onerror=reject});db.close();
   const text=new TextDecoder().decode(entry.contents);return filename.endsWith('.json')?JSON.parse(text):text;
  },{data,filename});
 }
 async function seed(kind){
  profile=kind;
  const data=JSON.parse(fs.readFileSync(path.join(root,'.verification/jade-'+kind+'-fixture.json')));
  data.saved_at=Date.now()/1000;
  await page.goto(url+'fixture');await record(data);await start();
  assert.equal((await record()).realm,data.realm,'Fixture must load without fallback');
 }
 async function top(){await page.mouse.move(...layout().scroll);await page.mouse.wheel(0,-10000);await page.waitForTimeout(180)}
 async function scrollTo(offset){
  await top();if(offset<=0)return;
  const d=layout(),[x,y,w,h]=d.bar;
  const thumb=Math.max(8,h*d.page/(d.maximum+d.page));
  const delta=Math.min(1,offset/d.maximum)*(h-thumb);
  await page.mouse.move(x+w*.5,y+thumb*.5);await page.mouse.down();await page.mouse.move(x+w*.5,y+thumb*.5+delta,{steps:12});await page.mouse.up();await page.waitForTimeout(180);
 }
 async function click(id,touch=false){
  const t=layout().targets[id];assert(t,'Missing measured action '+profile+'/'+key+'/'+view+'/'+id);
  if(view!=='audio')await scrollTo(t.scroll);
  if(id==='equip_cinnabar_blade')await snap('debug-equipment-scrolled');
  if(touch)await page.touchscreen.tap(...t.point);else await page.mouse.click(...t.point);
  await page.waitForTimeout(1000);
 }
 async function tab(id){await page.touchscreen.tap(...g().tabs[id]);view=id;await page.waitForTimeout(350)}
 async function swipeContent(startPoint=null){
  const [x,y,w,h]=layout().scroll_rect,px=startPoint?startPoint[0]:x+w*.45,from=startPoint?startPoint[1]:y+h-20,to=y+20;
  await touchSession.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:px,y:from}]});
  for(let step=1;step<=14;step++){
   await touchSession.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x:px,y:from+(to-from)*step/14}]});
   await page.waitForTimeout(20);
  }
  await touchSession.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
  await page.waitForTimeout(1200);
 }
 async function openAudio(){await page.mouse.click(...g().help);view='audio';await page.waitForTimeout(400)}
 async function slider(bus,percent){
  const [x,y,w,h]=g().audio[bus];
  await page.mouse.click(x+8+(w-16)*percent/100,y+h/2);await page.waitForTimeout(450);
 }
 async function pcm(name,seconds=2,save=false,trigger=null){
  await page.evaluate(()=>window.__sound.blocks=[]);if(trigger)await trigger();await page.waitForTimeout(seconds*1000);
  const data=await page.evaluate(()=>{const s=window.__sound;let total=0,n=0,peak=0;for(const b of s.blocks)for(const ch of b)for(const x of ch){total+=x*x;n++;peak=Math.max(peak,Math.abs(x))}return{rms:n?Math.sqrt(total/n):0,peak,samples:n,sampleRate:s.rate,contexts:s.contexts.map(c=>c.state),connections:s.connections,sources:s.connectedSources,blocks:s.blocks}});
  const {blocks,...metrics}=data;log('PCM '+name,metrics);
  if(save&&blocks.length){const count=blocks.reduce((n,b)=>n+b[0].length,0),buffer=Buffer.alloc(44+count*4);buffer.write('RIFF');buffer.writeUInt32LE(buffer.length-8,4);buffer.write('WAVEfmt ',8);buffer.writeUInt32LE(16,16);buffer.writeUInt16LE(1,20);buffer.writeUInt16LE(2,22);buffer.writeUInt32LE(data.sampleRate,24);buffer.writeUInt32LE(data.sampleRate*4,28);buffer.writeUInt16LE(4,32);buffer.writeUInt16LE(16,34);buffer.write('data',36);buffer.writeUInt32LE(count*4,40);let at=44;for(const b of blocks)for(let i=0;i<b[0].length;i++)for(let c=0;c<2;c++){buffer.writeInt16LE(Math.round(Math.max(-1,Math.min(1,b[c][i]))*32767),at);at+=2}fs.writeFileSync(path.join(out,'browser-'+name+'.wav'),buffer)}
  return metrics;
 }
 async function waitState(predicate,label,limit=180000){
  const until=Date.now()+limit;let s;
  while(Date.now()<until){s=await record();if(predicate(s)){log(label,{realm:s.realm,qi:s.qi,herbs:s.herbs,journey:s.chapter.journey.status,node:s.chapter.journey.node});return s}await page.waitForTimeout(1300)}
  throw Error(label+' timed out: '+JSON.stringify(s));
 }
 async function saved(predicate,label){return waitState(predicate,label,8000)}
 try{
  await start(false);await page.waitForTimeout(800);
  const before=await pcm('before-gesture',1);assert(before.rms===0,'No audible signal before a real gesture');
  await page.touchscreen.tap(215,220);await page.waitForTimeout(1200);
  await seed('foundation');
  if(retina&&!normal&&!comparison){
   const prefix=density===3?'retina':'density-'+density;
   for(const [width,height] of density===3?[[320,640],[390,844],[430,932]]:[[390,844]]){
    key=width+'x'+height;await page.setViewportSize({width,height});await seed('developed');
    await snap(prefix+'-'+key+'-methods');await tab('gear');await snap(prefix+'-'+key+'-equipment');
    const before=await record();await swipeContent();await snap(prefix+'-'+key+'-swipe');
    assert.deepEqual((await record()).chapter.inventory,before.chapter.inventory,'Retina swipe cannot refine');
    await click('equip_cinnabar_blade',true);await saved(s=>s.chapter.equipment.weapon==='cinnabar_blade','Retina touch equip '+key);
    await openAudio();await snap(prefix+'-'+key+'-menu');await click('audio_close');view='retreat';
    assert.equal(await page.evaluate(()=>devicePixelRatio),density,'Actual browser density matches the configured context');
    log('PASS high-density phone',{key,...await page.evaluate(()=>({devicePixelRatio,innerWidth,innerHeight,canvasWidth:document.querySelector('canvas').width,canvasHeight:document.querySelector('canvas').height}))});
   }
   for(const [width,height,item] of [[320,640,'pine_sword'],[430,932,'cinnabar_blade'],[390,844,'pine_sword']]){
    key=width+'x'+height;await page.setViewportSize({width,height});await page.waitForTimeout(700);
    await tab('arts');await snap(prefix+'-'+key+'-live-resize-arts');await tab('gear');await click('equip_'+item,true);
    await saved(s=>s.chapter.equipment.weapon===item,'Touch equip after live resize '+key);
    const metrics=await page.evaluate(()=>({devicePixelRatio,innerWidth,innerHeight,canvasWidth:document.querySelector('canvas').width,canvasHeight:document.querySelector('canvas').height}));
    assert.equal(metrics.devicePixelRatio,density);assert.equal(metrics.innerWidth,width);assert.equal(metrics.innerHeight,height);
    log('PASS live viewport resize',{key,...metrics});
   }
  }else if(comparison){
   fs.mkdirSync(path.join(out,'screenshots/after'),{recursive:true});
   for(const [width,height] of [[320,640],[390,844],[430,932],[1280,800]]){
    key=width+'x'+height;await page.setViewportSize({width,height});
    const data=JSON.parse(fs.readFileSync(path.join(root,'.verification/jade-foundation-fixture.json')));
    data.version=2;delete data.chapter;delete data.policy;delete data.azure_refund;
    Object.assign(data,{qi:2400,herbs:8,rate:39,saved_at:Date.now()/1000,mastery:{azure:1,iron:0}});
    await page.goto(url+'fixture');await record(data);await start();profile='foundation';
    const migrated=await saved(s=>s.version===3,'Matched legacy fixture migrated '+key);
    assert.equal(migrated.herbs,12,'Legitimate one-time Azure refund is retained in comparison');
    await snap('after/'+key+'-foundation');
    log('PASS comparison',{key,fixture:'Same v2 Foundation entry: 2400 Qi, 8 herbs, Azure M1, practices 4/2/1; migration credits 4 herbs'});
    // Final visual regression after the meter-cap refinement. State changes
    // still use actual native controls; no accelerated combat is injected.
    await seed('developed');
    if(width<600){
     await tab('gear');const beforeDrag=await record();
     const refine=layout().targets.refine_pine_sword;
     await scrollTo(refine.scroll);await swipeContent(refine.point);
     await snap('final-'+key+'-swipe-from-refine');
     const afterDrag=await record();
     assert.deepEqual(afterDrag.chapter.inventory,beforeDrag.chapter.inventory,'Dragging from Refine cancels the purchase');
     assert.deepEqual(afterDrag.chapter.equipment,beforeDrag.chapter.equipment,'Dragging from Refine preserves equipment');
     assert.equal(afterDrag.chapter.stones,beforeDrag.chapter.stones,'Dragging from Refine spends no stones');
     log('PASS purchase drag cancellation',{key});
    }
    await tab('journey');await click('route_stone_steps');view='preview';await click('depart',true);view='battle';await snap('final-'+key+'-combat');
    assert.equal(layout().targets.camp_request.scroll,0,'Camp must be reachable without scrolling');
    await click('camp_request',true);await saved(s=>s.chapter.journey.camp_requested,'Above-fold Camp queued '+key);await snap('final-'+key+'-camp-queued');
    await seed('golden');await snap('final-'+key+'-golden-core');await openAudio();await snap('final-'+key+'-menu');
    const beforeInformation=await record();
    await click('menu_help');await snap('final-'+key+'-help');await page.mouse.click(...g().help_close);await page.waitForTimeout(400);view='retreat';
    await openAudio();await click('audio_credits');await snap('final-'+key+'-credits');await page.keyboard.press('Escape');await page.waitForTimeout(400);view='retreat';
    assert.deepEqual((await record()).mastery,beforeInformation.mastery,'Information panels cannot trigger an underlying training purchase');
    log('PASS final visual review',{key,views:['matched Foundation','combat meter caps','Golden Core badge','Menu','Help','Credits']});
   }
  }else if(normal){
   key='390x844';await page.setViewportSize({width:390,height:844});await seed('foundation');
   await tab('journey');await click('route_stone_steps');view='preview';await snap('ordinary-route-preview');await click('depart',true);view='battle';
   const active=await record();assert.equal(active.chapter.journey.status,'battle');await snap('ordinary-first-combat');
   await waitState(s=>s.chapter.journey.status==='camp','First node ordinary-speed discovery camp');profile='camp';view='result';await snap('ordinary-flame-discovery');
   // The new art is equipped through separate free selection, never training.
   await tab('arts');await click('slot_1',true);await click('art_flame',true);
   let s=await saved(s=>s.chapter.combat_slots[1]==='flame','Saved free Flame equip');assert.deepEqual(s.chapter.combat_slots,['sword','flame']);assert.equal(s.chapter.combat_mastery.flame,0);
   await snap('ordinary-free-flame-equip');
   await tab('journey');view='result';await click('continue',true);view='battle';await snap('ordinary-sword-flame-combat');
   s=await waitState(s=>s.chapter.journey.status==='complete'||s.chapter.journey.status==='defeat','Ordinary-speed finite route boundary',240000);
   assert.equal(s.chapter.journey.status,'complete');assert(s.chapter.cleared_routes.includes('stone_steps'));assert(s.chapter.inventory.pine_sword===0);assert(s.chapter.learned.includes('ward'));
   view='result';await snap('ordinary-route-first-clear');const seals=s.chapter.cleared_routes.length,stones=s.chapter.stones;
   await start();s=await record();assert.equal(s.chapter.cleared_routes.length,seals);assert.equal(s.chapter.stones,stones,'Reload awards no duplicate stones');await snap('ordinary-after-reload');
   log('PASS ordinary route',{wallSeconds:(Date.now()-began)/1000,clock:'Unmodified real browser time',fixture:'Foundation entry only; no gear or route history'});
   // Separate late boundary fixture: history/gear came from the earned-path
   // simulation; the Core Trial win flag is false. Combat still uses real time.
   await seed('core_ready');profile='developed';await tab('journey');await click('core_review');view='core';await click('prepare_core');await saved(s=>s.chapter.core_prepared,'Core Trial preparation saved');view='core_prepared';await click('core_trial');view='battle';await snap('ordinary-core-trial');
   s=await waitState(s=>s.chapter.core_trial_won||s.chapter.journey.status==='defeat','Ordinary-speed Core Trial from labeled late fixture',110000);assert(s.chapter.core_trial_won);view='result';await snap('ordinary-core-trial-victory');
   await tab('journey');await click('core_review');view='core_prepared';await click('advance_core');s=await saved(s=>s.realm==='Golden Core','Core advancement after actual trial victory');profile='golden';view='retreat';await snap('ordinary-core-advancement');await start();assert.equal((await record()).realm,'Golden Core');
   log('PASS actual Core Trial',{fixture:'Earned history/equipment, stored Core win flag cleared, 100000 Qi boundary balance',clock:'Unmodified browser time'});
   if(retina){
    for(const [width,height] of [[320,640],[430,932],[390,844]]){
     key=width+'x'+height;await page.setViewportSize({width,height});await page.waitForTimeout(700);await tab('arts');await snap('ordinary-resize-'+key+'-arts');
     assert.equal((await record()).realm,'Golden Core','Viewport changes preserve advancement');
     log('PASS live viewport resize',{key,...await page.evaluate(()=>({devicePixelRatio,innerWidth,innerHeight,canvasWidth:document.querySelector('canvas').width,canvasHeight:document.querySelector('canvas').height}))});
    }
   }
  }else{
   if(!audioOnly){
    for(const [width,height] of [[320,640],[390,844],[430,932],[1280,800]]){
     key=width+'x'+height;await page.setViewportSize({width,height});await seed('mortal');await snap('browser-'+key+'-opening');await seed('developed');
     await snap('browser-'+key+'-methods');
     if(width<600){
      await tab('gear');const beforeSwipe=await record();
      await snap('browser-'+key+'-before-finger-swipe');
      await swipeContent();await snap('browser-'+key+'-after-finger-swipe');
      const afterSwipe=await record();
      assert.deepEqual(afterSwipe.chapter.equipment,beforeSwipe.chapter.equipment,'A scroll gesture cannot equip an item');
      assert.deepEqual(afterSwipe.chapter.inventory,beforeSwipe.chapter.inventory,'A scroll gesture cannot refine an item');
      assert.equal(afterSwipe.chapter.stones,beforeSwipe.chapter.stones,'A scroll gesture cannot spend stones');
      log('PASS finger swipe',{key,scope:'Real touch start/move/end across the content, no scrollbar drag; before/after captures require rendered review'});
     }
     await tab('arts');await snap('browser-'+key+'-arts');
     const beforeSelect=await record();await click('slot_0',true);await click('art_sword',true);let s=await saved(s=>s.chapter.combat_slots[0]==='sword','Saved Sword equip '+key);assert.equal(s.herbs,beforeSelect.herbs,'Art selection does not spend herbs');assert.deepEqual(s.chapter.combat_mastery,beforeSelect.chapter.combat_mastery);
     await tab('gear');await snap('browser-'+key+'-equipment');
     const beforeEquip=await record();await click('equip_cinnabar_blade',true);s=await saved(s=>s.chapter.equipment.weapon==='cinnabar_blade','Saved gear equip '+key);assert.equal(s.chapter.stones,beforeEquip.chapter.stones,'Equip does not refine');
     await click('refine_cinnabar_blade',true);s=await saved(s=>s.chapter.inventory.cinnabar_blade===1,'Saved separate refinement '+key);assert.equal(s.chapter.stones,beforeEquip.chapter.stones-15);
     await click('gear_filter_robe');view='gear_robe';await snap('browser-'+key+'-robes');await click('gear_filter_artifact');view='gear_artifact';await snap('browser-'+key+'-charms');
     await tab('journey');await snap('browser-'+key+'-routes');await click('region_river');view='river';await snap('browser-'+key+'-river');await click('region_misty');view='journey';await click('trials');view='trials';await snap('browser-'+key+'-trials');await tab('journey');await click('route_stone_steps');view='preview';await snap('browser-'+key+'-preview');await click('depart',true);view='battle';await snap('browser-'+key+'-combat');
     await click('camp_request',true);await waitState(s=>s.chapter.journey.status==='camp','Requested camp '+key);view='result';await snap('browser-'+key+'-reward');
     await click('leave',true);view='retreat';await tab('journey');await click('core_review');view='core';await snap('browser-'+key+'-core-preparation');
     await click('prepare_core',true);s=await saved(s=>s.chapter.core_prepared,'Saved preparation '+key);view='core_prepared';await snap('browser-'+key+'-core-prepared');
     await click('advance_core',true);s=await saved(s=>s.realm==='Golden Core','Saved Golden Core '+key);profile='golden';view='retreat';await snap('browser-'+key+'-golden-core');assert.equal(s.chapter.combat_slots.length,3);
     await tab('arts');await click('preset_save',true);await click('slot_2',true);await click('art_river',true);s=await saved(s=>s.chapter.combat_slots[2]==='river','Saved third slot '+key);await click('preset_apply',true);s=await saved(s=>s.chapter.combat_slots[2]==='','Saved preset restore '+key);await snap('browser-'+key+'-golden-slots-preset');
     await openAudio();await snap('browser-'+key+'-audio');await click('audio_close');view='retreat';
     await start();s=await record();assert.equal(s.realm,'Golden Core');assert(s.chapter.preset.primary);log('PASS viewport',{key,realm:s.realm});
    }
   }
   key='430x932';await page.setViewportSize({width:430,height:932});await seed('foundation');await openAudio();await snap('audio-debug-open');
   await slider('Master',70);await slider('Music',0);await slider('Ambience',0);await slider('SFX',0);
   await snap('audio-debug-zero');log('Audio settings after slider inputs',{preferences:await record(null,'audio.cfg')});
   const silent=await pcm('all-buses-zero',1);assert(silent.rms<1e-6);
   await slider('Music',70);const music=await pcm('music-only',3,true);assert(music.rms>.00001&&music.peak<.99);
   await slider('Music',0);await slider('Ambience',70);const ambience=await pcm('ambience-only',3,true);assert(ambience.rms>.00001&&ambience.peak<.99);
   await slider('Ambience',0);await slider('SFX',70);
   const sfx=await pcm('sfx-only',1,true,async()=>{await click('audio_close');view='retreat';await tab('journey')});assert(sfx.rms>.00001&&sfx.peak<.99);
   await openAudio();await click('menu_motion');await page.waitForTimeout(700);const displayPrefs=await record(null,'presentation.cfg');assert(displayPrefs&&displayPrefs.includes('reduced_motion=true'),'Animation option persists in the menu');
   await slider('Music',0);await slider('Ambience',12);await slider('SFX',35);
   await click('audio_mute');const mute=await pcm('master-mute',1);assert(mute.rms<1e-6);await click('audio_close');view='retreat';await start();
   const prefs=await record(null,'audio.cfg');assert(prefs&&prefs.includes('mute=true'),'Mute persists separately');
   await openAudio();await click('audio_mute');await slider('Master',0);const masterZero=await pcm('master-zero',1);assert(masterZero.rms<1e-6);await slider('Master',70);await click('audio_close');view='retreat';
   const mixed=await pcm('default-mix',3,true);assert(mixed.rms>.00001&&mixed.peak<.99);
   // A second real page backgrounds the game; foreground return resumes one mix.
   const other=await context.newPage();await other.goto(url+'fixture');await other.bringToFront();await page.waitForTimeout(1500);await page.bringToFront();await other.close();await page.waitForTimeout(1400);
   const returned=await pcm('focus-return',2,true);assert(returned.rms>.00001);assert(returned.connections===mixed.connections,'Focus does not create duplicate destination nodes');
   log('PASS audio signal/routing',{listening:'Unperformed: tool cannot accept audio input; PCM evidence does not establish aesthetic quality',preferences:prefs});
  }
  const performance=await page.evaluate(async()=>{
   const samples=[];let last=performance.now();
   await new Promise(resolve=>{function tick(now){samples.push(now-last);last=now;if(samples.length<120)requestAnimationFrame(tick);else resolve()}requestAnimationFrame(tick)});
   samples.shift();samples.sort((a,b)=>a-b);
   const gl=document.querySelector('canvas').getContext('webgl2'),debug=gl&&gl.getExtension('WEBGL_debug_renderer_info');
   return {medianFrameMs:samples[Math.floor(samples.length*.5)],p95FrameMs:samples[Math.floor(samples.length*.95)],renderer:debug?gl.getParameter(debug.UNMASKED_RENDERER_WEBGL):'Unavailable',scope:'120 headless browser animation frames, not a mobile-device benchmark'};
  });log('Rendered performance sample',performance);
  assert.deepEqual(errors,[]);log('PASS',{mode:normal?(retina?'ordinary-speed high-density phone journey and viewport resize':'ordinary-speed representative journey'):comparison?'matched legacy Foundation screenshots':retina?'high-density mobile browser, DPR '+density:audioOnly?'browser audio signal/routing':'phone-first four-size gameplay, boundaries and audio'});
 }finally{
  fs.writeFileSync(path.join(out,normal?'NORMAL_BROWSER_RESULTS.json':comparison?'COMPARISON_BROWSER_RESULTS.json':retina?(density===3?'RETINA_BROWSER_RESULTS.json':'DENSITY_'+density+'_BROWSER_RESULTS.json'):audioOnly?'AUDIO_BROWSER_RESULTS.json':'BROWSER_RESULTS.json'),JSON.stringify({events,errors,completed:events.some(e=>e.name==='PASS')},null,2));
  await browser.close();server.close();
 }
}
main().catch(e=>{console.error(e);process.exit(1)});
