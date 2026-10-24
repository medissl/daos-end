"""Normalize licensed source recordings, crossfade loop seams, keep edits auditable."""
from pathlib import Path
import sys,json,hashlib,subprocess
import numpy as np
root=Path(__file__).resolve().parent.parent
sys.path.insert(0,str(root/'.verification/python-deps'))
import soundfile as sf
import imageio_ffmpeg
src=root/'docs/jade-road/sources/audio'; out=root/'assets/audio'
records=[]
def read(path):
    x,sr=sf.read(str(path),always_2d=True)
    return x.astype(np.float64),sr
def save(name,path,creator,title,url,kind,start=0,length=None,rms=.1,seam=0,lowpass=0):
    print('Preparing',name,flush=True)
    x,sr=read(path)
    x=x[round(start*sr):round((start+length)*sr) if length else None]
    x-=x.mean(axis=0,keepdims=True)
    if lowpass:
        temporary=root/'.verification'/('filtered-'+name+'.wav')
        subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),'-nostdin','-loglevel','error','-y','-i',str(path),'-af',f'highpass=f=70,lowpass=f={lowpass}',str(temporary)],check=True)
        x,sr=read(temporary)
        x=x[round(start*sr):round((start+length)*sr) if length else None]
        x-=x.mean(axis=0,keepdims=True)
    if kind=='sfx':
        # Trim excess silence; preserve a few ms before natural transients.
        energy=np.max(np.abs(x),axis=1)
        active=np.flatnonzero(energy>max(.0003,float(energy.max())*.007))
        if len(active):x=x[max(0,active[0]-round(sr*.004)):min(len(x),active[-1]+round(sr*.03))]
    if seam:
        n=min(round(seam*sr),len(x)//4)
        t=np.linspace(0,1,n)[:,None]
        cross=x[-n:]*(1-t)+x[:n]*t
        x=np.concatenate((x[n:-n],cross),axis=0)
    else:
        n=min(round(sr*.005),len(x)//5)
        x[:n]*=np.linspace(0,1,n)[:,None]
        x[-n:]*=np.linspace(1,0,n)[:,None]
    current=float(np.sqrt(np.mean(x*x)))
    x*=min(rms/max(current,1e-9),.35/max(float(np.abs(x).max()),1e-9))
    dest=out/(name+('.wav' if kind=='sfx' else '.ogg'))
    if kind=='sfx':
        sf.write(str(dest),x,sr,subtype='PCM_16')
    else:
        temp=root/'.verification'/('normalized-'+name+'.wav')
        sf.write(str(temp),x,sr,subtype='PCM_16')
        subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),'-nostdin','-loglevel','error','-y','-i',str(temp),'-c:a','libvorbis','-q:a','4',str(dest)],check=True)
    decoded,actual_sr=read(dest)
    assert np.isfinite(decoded).all() and np.abs(decoded).max()<.9
    records.append(dict(id=name,kind=kind,source=str(path.relative_to(root)),creator=creator,title=title,source_url=url,license='CC0 1.0',license_url='https://creativecommons.org/publicdomain/zero/1.0/',runtime=str(dest.relative_to(root)),edits=dict(start_seconds=start,length_seconds=length,target_rms=rms,crossfade_seconds=seam,dc_removed=True,peak_ceiling_dbfs=-9.1,lowpass_hz=lowpass,highpass_hz=70 if lowpass else 0),duration=len(decoded)/actual_sr,peak_dbfs=20*np.log10(max(float(abs(decoded).max()),1e-9)),rms_dbfs=20*np.log10(max(float(np.sqrt(np.mean(decoded*decoded))),1e-9)),seam_step=float(np.abs(decoded[0]-decoded[-1]).max()),sha256=hashlib.sha256(dest.read_bytes()).hexdigest()))
def find(folder,name):return next((src/folder).rglob(name))
organic=src/'organic-v2'
music_url='https://bitemegames.itch.io/chinese-game-music'
save('music-retreat',organic/'biteme-music/Lotus Pond - Loop.wav','BiteMe Games','Lotus Pond (loop)',music_url,'music',rms=.065,seam=.08)
save('music-journey',organic/'biteme-music/Dragon Dance - Loop.wav','BiteMe Games','Dragon Dance (loop)',music_url,'music',rms=.06,seam=.08)
foley_url='https://opengameart.org/content/100-cc0-sfx-2'
everyday_url='https://opengameart.org/content/100-cc0-sfx'
save('ambience-mountain',organic/'rubberduck-foley2/sfx100v2_loop_water_01.ogg','rubberduck','Flowing water 01',foley_url,'ambience',rms=.035,seam=.7,lowpass=3000)
save('ambience-river',organic/'rubberduck-foley2/sfx100v2_loop_water_03.ogg','rubberduck','Flowing water 03',foley_url,'ambience',rms=.04,seam=.8,lowpass=3500)
effects={
 'select':('rubberduck-foley2/sfx100v2_wood_hit_01.ogg',.018,.18),
 'purchase':('rubberduck-everyday/wooden_01.ogg',.035,None),
 'unavailable':('rubberduck-foley2/sfx100v2_wood_hit_03.ogg',.016,.2),
 'panel':('rubberduck-everyday/paper_02.ogg',.018,None),
 'ward':('rubberduck-foley2/sfx100v2_wood_02.ogg',.035,None),
 'discovery':('rubberduck-everyday/gong_02.ogg',.035,None),
 'breakthrough':('rubberduck-everyday/gong_01.ogg',.05,None),
 'strike':('rubberduck-foley2/sfx100v2_air_03.ogg',.025,None),
 'enemy-hit':('rubberduck-foley2/sfx100v2_hit_01.ogg',.025,None),
 'collect':('rubberduck-everyday/paper_04.ogg',.022,None)}
for name,(file,rms,length) in effects.items():
    save(name,organic/file,'rubberduck',Path(file).name,everyday_url if file.startswith('rubberduck-everyday') else foley_url,'sfx',rms=rms,length=length,lowpass=4200)
save('flame',src/'ignition.flac','qubodup','Flare ignition','https://opengameart.org/content/flare-ignition','sfx',rms=.03,length=.7,lowpass=4200)
save('river',src/'water-wave.flac','transitking; submitted by qubodup','Water Waves / wave 02','https://opengameart.org/content/water-waves','sfx',rms=.03,length=.65,lowpass=4200)
manifest=dict(date='2026-10-23',revision=2,production='Replaced rejected synth-like UI cues, Tozan music and bird/synth ambience. Recorded wood/paper/air/impact/gong/water foley; optional Chinese-instrument music by BiteMe Games. Quieter filtered mix; music starts off. No retro interface tones.',license_note='BiteMe creator page lists CC0 and explicitly permits commercial game use; its standalone asset resale restriction is retained in the archived page. These files are integrated into the game, not offered as a resold asset pack.',listening='Audio preview tool cannot accept audio input. No headphone/speaker audition claim. Physical source provenance and signal analysis are verified separately; perceived quality still needs human listening.',assets=records)
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(root/'docs/jade-road/AUDIO_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
(src/'CC0-1.0.txt').write_text('These selected assets are licensed under Creative Commons CC0 1.0.\nhttps://creativecommons.org/publicdomain/zero/1.0/\nSource-specific license pages and bundled Kenney License.txt files are preserved here.\n')
print(f'{len(records)} decoded, edited and signal-checked runtime audio files; '+str(sum((root/r['runtime']).stat().st_size for r in records))+' bytes.')
