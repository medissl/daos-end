/* Isolated exported-game task walkthrough. Native control geometry, real input,
 * real time; no game API, accelerated clock or user-profile writes. */
const {chromium}=require('playwright');
const fs=require('node:fs'),path=require('node:path'),http=require('node:http'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),before=process.argv.includes('--before');
const slice=process.argv.includes('--slice');
const density=Number((process.argv.find(a=>a.startsWith('--density='))||'--density=3').split('=')[1]);
const desktopOnly=process.argv.includes('--desktop');
const phonesOnly=process.argv.includes('--phones');
assert([2,2.625,3].includes(density));
const out=path.join(root,'docs/living-dao'),phase=process.argv.includes('--release')?(desktopOnly?'release-desktop':'release'):'sample';
const build=path.join(root,before?'.verification/ux-reset-before/builds/web':'builds/web');
const geometry=JSON.parse(fs.readFileSync(path.join(root,before?'.verification/ux-reset-before/geometry.json':'.verification/living-ui-geometry.json')));
const events=[],errors=[];let taps=0,scrolls=0;
const audioCapture=require('./browser_living_audio.cjs');
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
  for(const [width,height] of desktopOnly?[[1280,800]]:density!==3?[[390,844]]:slice?[[320,640],[430,932]]:phonesOnly?[[320,640],[390,844],[430,932]]:[[320,640],[390,844],[430,932],[1280,800]]){
   const key=width+'x'+height,context=await browser.newContext({viewport:{width,height},hasTouch:true,isMobile:width<700,deviceScaleFactor:width<700?density:1,recordVideo:{dir:path.join(out,'motion'),size:{width,height}}});
   if(phase.startsWith('release'))await audioCapture.install(context);
   await context.addInitScript(()=>{window.__frames=[];let last=0;function frame(t){if(last&&window.__frames.length<30000)window.__frames.push(t-last);last=t;requestAnimationFrame(frame)}requestAnimationFrame(frame)});
   const page=await context.newPage(),began=Date.now(),loads=[];let profile='foundation',view='retreat';taps=0;scrolls=0;
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
   async function start(){const beganLoad=Date.now();await page.goto(url);await page.waitForFunction(()=>!document.querySelector('#status'),{timeout:60000});await page.waitForTimeout(1100);await page.keyboard.press('Escape');loads.push(Date.now()-beganLoad);const s=await record();view=s?.chapter?.journey.status==='camp'?'result':s?.chapter?.journey.status==='battle'?'battle':s?.realm==='Mortal'?'practices':'retreat'}
   async function seed(kind){profile=kind;const data=JSON.parse(fs.readFileSync(path.join(root,'.verification/jade-'+kind+'-fixture.json')));data.saved_at=Date.now()/1000;await page.goto(url+'fixture');await record(data);await start();assert.equal((await record()).realm,data.realm)}
   async function saved(predicate,label,timeout=8000){const limit=Date.now()+timeout;while(Date.now()<limit){const state=await record();if(predicate(state))return state;await page.waitForTimeout(400)}throw Error(key+' '+label+' timed out')}
   async function top(){await page.mouse.move(...layout().scroll);await page.mouse.wheel(0,-10000);await page.waitForTimeout(120)}
   async function click(id){const target=layout().targets[id];assert(target,'Missing '+profile+'/'+key+'/'+view+'/'+id);if(!['audio','compare','refine','improve','replace','slot'].includes(view))await top();if(target.scroll>0){scrolls++;const [x,y,w,h]=layout().bar,thumb=Math.max(8,h*layout().page/(layout().maximum+layout().page)),delta=Math.min(1,target.scroll/layout().maximum)*(h-thumb);await page.mouse.move(x+w*.5,y+thumb*.5);await page.mouse.down();await page.mouse.move(x+w*.5,y+thumb*.5+delta,{steps:12});await page.mouse.up();await page.waitForTimeout(150)}taps++;await page.touchscreen.tap(...target.point);await page.waitForTimeout(550)}
   async function tab(id){taps++;await page.touchscreen.tap(...(layout()?.tabs?.[id]||g().tabs[id]));view=id;await page.waitForTimeout(300)}
   await start();await seed('foundation');await snap('cultivate');
   await page.waitForTimeout(7000);
   await click('goal');view='preview';await snap('route-selection');
   assert.equal(layout().targets.depart.scroll,0);await click('depart');view='battle';await snap('battle');
   let state=await saved(s=>s.chapter.journey.node>=1&&s.chapter.journey.status==='battle'&&s.chapter.learned.includes('flame'),'discovery continues automatically',100000);
   assert.equal(state.chapter.combat_slots[1],'','No implicit auto-equip');await snap('discovery-onward');
   await click('camp_request');await saved(s=>s.chapter.journey.status==='camp','requested next safe camp',100000);profile='camp';view='result';await snap('camp');
   const prior=await record();await click('camp_build');view='arts';await snap('collection');await click('art_flame');view='manage_flame';await snap('manage-flame');
   await click(width>=900?'detail_equip':'sheet_equip');view='arts';state=await saved(s=>s.chapter.combat_slots[1]==='flame','deliberate free equip');assert.deepEqual(state.chapter.combat_mastery,prior.chapter.combat_mastery);assert.equal(state.herbs,prior.herbs);assert.equal(state.chapter.stones,prior.chapter.stones);
   await click('build_return');view='result';await click('continue');view='battle';state=await saved(s=>s.chapter.journey.status==='battle'&&s.chapter.journey.node>=2,'continue committed build');assert.deepEqual(state.chapter.journey.battle.stats.slots,['sword','flame']);await snap('continue');
   const capturedAudio=phase.startsWith('release')?await audioCapture.finish(page,path.join(out,'motion',key+'-release-audio.webm')):null;
   const performance=await page.evaluate(()=>{const frames=window.__frames.slice(120).sort((a,b)=>a-b),q=p=>frames[Math.min(frames.length-1,Math.floor(frames.length*p))];const canvas=document.querySelector('canvas');const gl=canvas.getContext('webgl2'),ext=gl?.getExtension('WEBGL_debug_renderer_info');return{samples:frames.length,p50:q(.5),p95:q(.95),p99:q(.99),worst:frames.at(-1),renderer:ext?gl.getParameter(ext.UNMASKED_RENDERER_WEBGL):'unavailable',jsHeap:window.performance.memory?.usedJSHeapSize}});
   log('PASS continuous discovery, requested camp, one-sheet free equip, continue',{key,taps,scrolls,seconds:(Date.now()-began)/1000,fixture:'Foundation entry; actual ordinary-speed first two encounters',loads_ms:loads,audio:capturedAudio,performance});
   assert.equal(await page.evaluate(()=>devicePixelRatio),width<700?density:1);const video=page.video();await context.close();if(video)fs.renameSync(await video.path(),path.join(out,'motion',key+'-'+phase+'.webm'));
  }
  assert.deepEqual(errors,[]);log('PASS',{phase});
 }finally{
  fs.writeFileSync(path.join(out,phase.toUpperCase()+'_BROWSER_RESULTS.json'),JSON.stringify({events,errors,completed:events.some(e=>e.name==='PASS')},null,2));await browser.close();server.close();
 }
}
main().catch(error=>{console.error(error);process.exit(1)});
