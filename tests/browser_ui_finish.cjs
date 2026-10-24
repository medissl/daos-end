/* Matched before/after captures of the exported game. Isolated Edge/IDBFS;
 * fixtures are written only while the engine is unloaded, never a player profile. */
const {chromium}=require('playwright');
const fs=require('node:fs'),path=require('node:path'),http=require('node:http'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),stage=process.argv.includes('--before')?'before':'after',evidence=path.join(root,'docs/art-direction/milestone-2/ui-finish',stage);
const geometry=JSON.parse(fs.readFileSync(path.join(root,stage==='before'?'.verification/ui-finish-before/m2-ui-geometry.json':'.verification/m2-ui-geometry.json')));
assert(process.argv.includes('--capture'),'Use --capture to run the matched fixture capture.');
assert(stage!=='before'||!fs.existsSync(path.join(evidence,'browser-results.json')),'The Before evidence is sealed; do not overwrite it with the current export.');

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
 const log=(name,data)=>{const event={name,seconds:(Date.now()-began)/1000,...data};events.push(event);console.log(JSON.stringify(event));fs.writeFileSync(path.join(evidence,'browser-progress.json'),JSON.stringify({events,errors},null,2));};
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
 const snap=async name=>page.screenshot({path:path.join(evidence,name+'.png')});
 try{
  await start();
  if(process.argv.includes('--capture')){
   const idle={active:false,primary:'none',elapsed:0,azure:0,iron:0};
   const fixture={version:2,qi:9000,realm:'Qi Refining',levels:{breathing:4,meridian:2,mind:1},rate:15,saved_at:0,herbs:24,mastery:{azure:0,iron:0},primary:'none',pending_primary:'',prepared:false,repeat:true,trip:idle};
   for(const [width,height] of [[320,640],[430,932],[1280,800]]){
    key=width+'x'+height;await page.setViewportSize({width,height});
    for(const state of ['mortal','methods','queued','forest','prepared','foundation','details','rewards']){
     const f=structuredClone(fixture);f.saved_at=Date.now()/1000;
     if(state==='mortal'){Object.assign(f,{realm:'Mortal',qi:124,rate:2,herbs:0,levels:{breathing:1,meridian:0,mind:0}});}
     if(['queued','forest'].includes(state)){Object.assign(f,{primary:'iron',pending_primary:'azure',rate:15,repeat:false,trip:{active:true,primary:'iron',elapsed:42,azure:0,iron:2}});}
     if(state==='prepared'){Object.assign(f,{primary:'azure',prepared:true,herbs:12,rate:19.5,mastery:{azure:1,iron:0}});}
     if(state==='foundation'){Object.assign(f,{realm:'Foundation Establishment',primary:'azure',qi:2400,herbs:8,rate:39,mastery:{azure:1,iron:0}});}
     if(state==='rewards'){f.saved_at-=120;Object.assign(f,{primary:'iron',trip:{active:true,primary:'iron',elapsed:42,azure:0,iron:2},rate:15});}
     await seed(f);
     if(state==='forest'){await click('forest');view='forest';await scroll(0);}
     if(state==='details'){await click('help');}
     if(state==='rewards'){await page.goto(url+'fixture');f.saved_at=Date.now()/1000-120;await save(f);await start(false);}
     await page.mouse.move(0,0);await page.waitForTimeout(250);await snap(key+'-'+state);
     log('capture '+key+' '+state,{});
    }
   }
  }
  assert.equal(events.filter(e=>e.name.startsWith('capture ')).length,24);assert.deepEqual(errors,[]);log('PASS',{mode:'matched isolated browser render fixtures'});
 }finally{await browser.close();server.close();fs.writeFileSync(path.join(evidence,'browser-results.json'),JSON.stringify({events,errors,completed:events.some(e=>e.name==='PASS')},null,2));}
}
main().catch(e=>{console.error(e);process.exit(1)});
