/* Actual exported game, isolated Edge storage. No time acceleration or game test API.
 * Default: seeded boundary/layout checks. --normal: fresh ordinary-speed complete journey. */
const {chromium}=require('playwright');
const fs=require('node:fs'),path=require('node:path'),http=require('node:http'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),evidence=path.join(root,'docs/art-direction/milestone-2/screenshots');
const geometry=JSON.parse(fs.readFileSync(path.join(root,'.verification/m2-ui-geometry.json')));
const normal=process.argv.includes('--normal');
async function main(){
 const server=http.createServer((req,res)=>{
  if(req.url==='/fixture'){res.writeHead(200,{'Content-Type':'text/html'}).end('<title>Isolated fixture</title>');return;}
  if(req.url==='/favicon.ico'){res.writeHead(204).end();return;}
  const file=path.resolve(root,'builds/web','.'+(req.url==='/'?'/index.html':req.url.split('?')[0]));
  if(!file.startsWith(path.join(root,'builds/web')+path.sep)){res.writeHead(403).end();return;}
  fs.readFile(file,(e,b)=>{if(e){res.writeHead(404).end();return;}res.writeHead(200,{'Cache-Control':'no-store','Content-Type':({'.html':'text/html','.js':'text/javascript','.wasm':'application/wasm'})[path.extname(file)]||'application/octet-stream'}).end(b)});
 });
 await new Promise(r=>server.listen(0,'127.0.0.1',r));
 const browser=await chromium.launch({channel:'msedge',headless:true});
 const errors=[],events=[],began=Date.now();
 const context=await browser.newContext({viewport:{width:1280,height:800},hasTouch:true});
 const page=await context.newPage();
 page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(m.type()==='error')errors.push(m.text())});
 const url='http://127.0.0.1:'+server.address().port+'/';
 let key='1280x800',view='mortal',phase='';
 const layout=()=>geometry[key][phase+view];
 const log=(name,data)=>{const event={name,seconds:(Date.now()-began)/1000,...data};events.push(event);console.log(JSON.stringify(event));fs.writeFileSync(path.join(evidence,normal?'normal-progress.json':'browser-progress.json'),JSON.stringify({events,errors},null,2));};
 const start=async(dismiss=true)=>{await page.goto(url);await page.waitForFunction(()=>!document.querySelector('#status'),{timeout:60000});await page.waitForTimeout(1600);if(dismiss)await page.keyboard.press('Escape');};
 const save=async(data)=>page.evaluate(async data=>{
  const db=await new Promise((resolve,reject)=>{const r=indexedDB.open('/userfs');r.onsuccess=()=>resolve(r.result);r.onerror=reject});
  const tx=db.transaction('FILE_DATA',data?'readwrite':'readonly'),store=tx.objectStore('FILE_DATA');
  const key="/userfs/godot/app_userdata/Dao's End/cultivation.json";
  const entry=await new Promise(resolve=>{const r=store.get(key);r.onsuccess=()=>resolve(r.result)});
  if(!entry){db.close();return null;}
  if(data){entry.contents=new TextEncoder().encode(JSON.stringify(data));entry.timestamp=new Date();store.put(entry,key);}
  await new Promise((resolve,reject)=>{tx.oncomplete=resolve;tx.onerror=reject});db.close();
  return JSON.parse(new TextDecoder().decode(entry.contents));
 },data);
 const seed=async data=>{await page.goto(url+'fixture');await save(data);await start();view=data.realm==='Mortal'?'mortal':'unlocked';phase=data.realm==='Foundation Establishment'?'foundation_':'';};
 const scroll=async amount=>{const p=layout().scroll;await page.mouse.move(...p);await page.mouse.wheel(0,-10000);await page.waitForTimeout(200);if(amount){await page.mouse.wheel(0,10000);await page.waitForTimeout(220)}};
 const click=async(name,touch=false)=>{
  const target=layout()[name];
  assert(target,'Missing target '+view+':'+name);
  const point=Array.isArray(target)?target:target.point;
  if(!Array.isArray(target))await scroll(target.scroll);
  if(touch)await page.touchscreen.tap(...point);else await page.mouse.click(...point);
  await page.waitForTimeout(1700);
 };
 const waitFor=async(predicate,label,limit=180000)=>{
  const until=Date.now()+limit;let s;
  while(Date.now()<until){s=await save();if(s&&predicate(s)){log(label,{qi:s.qi,herbs:s.herbs,realm:s.realm,trip:s.trip,mastery:s.mastery});return s;}await page.waitForTimeout(2000);}
  throw Error(label+' timed out '+JSON.stringify(s));
 };
 const snap=async name=>page.screenshot({path:path.join(evidence,name+'.png')});
 try{
  await start();
  if(normal){
   log('fresh ordinary-speed start',await save());
   const order=['breathing','breathing','meridian','breathing','mind','breathing','meridian'];
   for(const id of order){const s=await save();const cost=Math.ceil(({breathing:25,meridian:120,mind:200})[id]*Math.pow(({breathing:2.4,meridian:4,mind:1})[id],s.levels[id]));await waitFor(s=>s.qi>=cost,'afford '+id,300000);await click(id);log('purchase '+id,await save());}
   await waitFor(s=>s.qi>=800,'Mortal requirement',300000);await click('advance');view='unlocked';assert.equal((await save()).realm,'Qi Refining');await snap('normal-qi-refining');
   await click('iron');await click('forest');view='forest';await click('start');await click('repeat');
   // Tabs are shared coordinates; the forest geometry only contains its content.
   await page.mouse.click(...geometry[key].unlocked.cultivate);await page.waitForTimeout(300);view='unlocked';
   await click('azure');let s=await save();assert.equal(s.trip.primary,'iron');assert.equal(s.pending_primary,'azure');assert.equal(s.repeat,false);log('queued method and stop committed',s);
   await waitFor(s=>!s.trip.active&&s.herbs===6,'first ordinary 120-second trip',150000);
   await click('forest');view='forest';await click('repeat');await click('start');
   await waitFor(s=>s.herbs>=10,'second ordinary trip',150000);
   await page.mouse.click(...geometry[key].unlocked.cultivate);await page.waitForTimeout(300);view='unlocked';
   await click('azure_mastery');await click('iron');
   await waitFor(s=>s.herbs>=12,'gather preparation herbs',300000);
   await click('forest');view='forest';await click('prepare');assert.equal((await save()).prepared,true);await snap('normal-prepared');
   await waitFor(s=>s.herbs>=12&&s.qi>=7000,'ordinary Foundation requirements',400000);
   await page.mouse.click(...geometry[key].unlocked.advance);await page.waitForTimeout(1700);
   s=await save();assert.equal(s.realm,'Foundation Establishment');assert.equal(s.prepared,false);log('ordinary Foundation breakthrough',s);
   await waitFor(s=>s.trip.azure===.15,'resonance on next departure',150000);await snap('normal-resonance');
   const before=await save();await page.goto(url+'fixture');await page.waitForTimeout(12000);await start();s=await save();assert(s.qi>before.qi);assert(s.herbs>=before.herbs);log('real twelve-second absence reload',{before,after:s});await snap('normal-return');
  }else{
   const fixture={version:1,qi:10000,realm:'Qi Refining',levels:{breathing:4,meridian:2,mind:1},rate:15,saved_at:Date.now()/1000};
   await seed(fixture);let s=await save();assert.equal(s.version,2);assert.equal(s.primary,'none');assert.equal(s.herbs,0);assert.equal(s.trip.active,false);log('v1 Qi migration',s);
   await click('iron');assert.equal((await save()).primary,'iron');
   await click('forest');view='forest';await click('start');s=await save();assert.equal(s.trip.primary,'iron');assert.equal(s.trip.iron,2);await click('repeat');assert.equal((await save()).repeat,false);
   await page.mouse.click(...geometry[key].unlocked.cultivate);await page.waitForTimeout(300);view='unlocked';await click('azure');s=await save();assert.equal(s.pending_primary,'azure');assert.equal(s.trip.primary,'iron');assert.equal(s.trip.azure,0);log('commitment survives queued input',s);await snap('browser-queued-method');
   await page.goto(url+'fixture');await page.waitForTimeout(12000);await start(false);await snap('browser-offline-rewards');await page.keyboard.press('Escape');s=await save();assert.equal(s.repeat,false);assert.equal(s.pending_primary,'azure');log('real short absence reload preserves stop and queue',s);
   // Explicit fixture only: shorten remaining time by seeding elapsed, never change runtime clock.
   s.trip.elapsed=119;s.saved_at=Date.now()/1000;await seed(s);view='unlocked';
   await waitFor(s=>!s.trip.active,'seeded exact boundary finishes once');s=await save();assert.equal(s.herbs,6);assert.equal(s.primary,'azure');assert.equal(s.pending_primary,'');log('seeded stop boundary',s);
   s.herbs=40;s.qi=9000;s.saved_at=Date.now()/1000;await seed(s);
   await click('azure_mastery');assert.equal((await save()).mastery.azure,1);await snap('browser-mastery');
   await click('forest');view='forest';await click('prepare');s=await save();assert(s.prepared&&s.herbs===20);await snap('browser-foundation-prepared');
   await page.mouse.click(...geometry[key].unlocked.advance);await page.waitForTimeout(1700);s=await save();assert.equal(s.realm,'Foundation Establishment');assert.equal(s.herbs,8);assert.equal(s.rate,39);phase='foundation_';log('Foundation resonance seeded flow',s);
   for(const [width,height] of [[320,640],[430,932],[1280,800]]){
    key=width+'x'+height;await page.setViewportSize({width,height});await page.waitForTimeout(400);
    await page.mouse.click(...geometry[key].unlocked.cultivate);view='unlocked';await page.waitForTimeout(300);await snap('browser-'+key+'-methods');
    await page.mouse.click(...geometry[key].unlocked.help);await page.waitForTimeout(300);await snap('browser-'+key+'-help');await page.keyboard.press('Enter');await page.waitForTimeout(300);
    const beforeDetails=await save();await click('effects');await snap('browser-'+key+'-method-effects');await page.keyboard.press('Enter');await page.waitForTimeout(300);const afterDetails=await save();assert.equal(afterDetails.primary,beforeDetails.primary);assert.deepEqual(afterDetails.mastery,beforeDetails.mastery);assert.equal(afterDetails.herbs,beforeDetails.herbs);
    await click('forest',true);view='forest';await snap('browser-'+key+'-forest');
   }
   key='320x640';await page.setViewportSize({width:320,height:640});await page.waitForTimeout(300);
   await page.touchscreen.tap(...geometry[key].unlocked.cultivate);view='unlocked';await page.waitForTimeout(300);
   // Compact methods now fit without scrolling. Expand practices to test a
   // genuinely overflowing native container rather than demand fake overflow.
   await click('practice',true);await scroll(0);await snap('browser-expanded-practices');
   // Native touch drag through actual buttons must scroll rather than select on release.
   const cdp=await context.newCDPSession(page),p=geometry[key].unlocked.scroll;
   const swipe=async()=>{
    await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:p[0],y:p[1]+40}]});
    for(let i=1;i<=10;i++){await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x:p[0],y:p[1]+40-i*12}]});await page.waitForTimeout(25)}
    await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});await page.waitForTimeout(250);
   };
   const area=layout().scroll_rect;const clip={x:area[0],y:area[1],width:Math.floor(area[2]),height:Math.floor(area[3])};await page.mouse.move(0,0);const beforeScroll=await page.screenshot({clip});const beforeDrag=await save();
   await swipe();await swipe();const afterScroll=await page.screenshot({clip});const afterDrag=await save();assert.notDeepEqual(beforeScroll,afterScroll,'Touch drag changes the bounded content');assert.equal(afterDrag.primary,beforeDrag.primary,'Drag does not accidentally choose a method');assert.deepEqual(afterDrag.mastery,beforeDrag.mastery,'Drag does not train');assert.equal(afterDrag.herbs,beforeDrag.herbs,'Drag does not spend herbs');await snap('browser-touch-scroll');
   // Re-establish a known scroll offset using wheel, then touch selects Iron.
   await click('iron',true);s=await save();assert.equal(s.primary,'iron');assert.equal(s.rate,34.5);log('small-screen touch method selection',s);
   await click('forest',true);view='forest';await click('start',true);s=await save();assert.equal(s.trip.active,true);assert.equal(s.trip.azure,.15);assert.equal(s.trip.iron,2);
   await scroll(0);await snap('browser-320x640-forest-active');
   key='430x932';await page.setViewportSize({width:430,height:932});await page.waitForTimeout(300);await scroll(0);await snap('browser-430x932-forest-active');
   const timing=await page.evaluate(()=>new Promise(resolve=>{let start,prev;const a=[];function frame(t){start??=t;if(prev)a.push(t-prev);prev=t;if(t-start<3000)requestAnimationFrame(frame);else{a.sort((x,y)=>x-y);const gl=document.querySelector('canvas').getContext('webgl2'),e=gl.getExtension('WEBGL_debug_renderer_info');resolve({samples:a.length,medianMs:a[Math.floor(a.length*.5)],p95Ms:a[Math.floor(a.length*.95)],renderer:e?gl.getParameter(e.UNMASKED_RENDERER_WEBGL):'unavailable'})}}requestAnimationFrame(frame)}));log('presentation frame sample',timing);
  }
  assert.deepEqual(errors,[]);log('PASS',{mode:normal?'ordinary-speed fresh journey':'isolated seeded interaction and render checks'});
 }finally{await browser.close();server.close();fs.writeFileSync(path.join(evidence,normal?'normal-browser-results.json':'browser-results.json'),JSON.stringify({events,errors,completed:events.some(e=>e.name==='PASS')},null,2));}
}
main().catch(e=>{console.error(e);process.exit(1)});
