/* Browser-rendered audio capture and signal evidence. This does not claim a
 * human listening review. Installed before Godot creates its AudioContext. */
exports.install=async context=>context.addInitScript(()=>{
 const Native=window.AudioContext||window.webkitAudioContext;if(!Native)return;
 window.__audioCapture={contexts:[],samples:[]};
 const connect=AudioNode.prototype.connect;
 AudioNode.prototype.connect=function(destination,...args){
  const result=connect.call(this,destination,...args),ctx=this.context;
  if(destination===ctx.destination&&ctx.__capture){connect.call(this,ctx.__capture.mix);connect.call(this,ctx.__capture.analyser)}
  return result;
 };
 class CapturedContext extends Native{
  constructor(...args){super(...args);const mix=this.createMediaStreamDestination(),analyser=this.createAnalyser(),chunks=[];
   const recorder=new MediaRecorder(mix.stream,{mimeType:'audio/webm;codecs=opus'});
   recorder.ondataavailable=e=>{if(e.data.size)chunks.push(e.data)};recorder.start(500);
   this.__capture={mix,analyser,chunks,recorder,started:performance.now()};window.__audioCapture.contexts.push(this);
   const buffer=new Float32Array(analyser.fftSize);setInterval(()=>{analyser.getFloatTimeDomainData(buffer);let sum=0,peak=0;for(const x of buffer){sum+=x*x;peak=Math.max(peak,Math.abs(x))}if(window.__audioCapture.samples.length<12000)window.__audioCapture.samples.push({at:performance.now(),state:this.state,rms:Math.sqrt(sum/buffer.length),peak})},100);
  }
 }
 window.AudioContext=CapturedContext;if(window.webkitAudioContext)window.webkitAudioContext=CapturedContext;
});
exports.finish=async(page,filename)=>{
 const fs=require('node:fs');const result=await page.evaluate(async()=>{
  const capture=window.__audioCapture;if(!capture?.contexts.length)return {error:'No AudioContext was captured'};
  const ctx=capture.contexts[0],data=ctx.__capture;await new Promise(resolve=>{data.recorder.onstop=resolve;data.recorder.stop()});
  const bytes=new Uint8Array(await new Blob(data.chunks,{type:'audio/webm'}).arrayBuffer());let binary='';for(let i=0;i<bytes.length;i+=16384)binary+=String.fromCharCode(...bytes.subarray(i,i+16384));
  const values=capture.samples;return{base64:btoa(binary),sampleRate:ctx.sampleRate,startMs:data.started,samples:values.length,runningSamples:values.filter(x=>x.state==='running').length,audibleSamples:values.filter(x=>x.rms>.00001).length,peak:Math.max(...values.map(x=>x.peak)),rmsPeak:Math.max(...values.map(x=>x.rms)),note:'Actual browser-rendered mix captured through a parallel MediaStreamDestination. No implementing-agent listening claim.'};
 });
 if(result.base64){fs.writeFileSync(filename,Buffer.from(result.base64,'base64'));delete result.base64}return result;
};
