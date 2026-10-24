"""Archive actual evidence and reproducible hashes; fail on incomplete checks."""
from pathlib import Path
import hashlib,json,re,shutil

root=Path(__file__).resolve().parent.parent
out=root/'docs/jade-road'
def digest(file): return hashlib.sha256(file.read_bytes()).hexdigest()
def write(name,data): (out/name).write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
logs={
 'original progression':('jade-core-final.log',73),
 'milestone two compatibility':('jade-m2-final.log',96),
 'chapter rules and saves':('jade-tests.log',190),
 'audio lifecycle':('jade-audio.log',15),
 'native rendered text/control bounds':('jade-ui.log',6789),
}
results=[]
(out/'verification').mkdir(exist_ok=True)
# Keep raw logs unchanged; correct two mislabeled exploratory CDP overrides.
# Capture restored DPR 3, so these are not evidence for the requested densities.
normal_path=out/'NORMAL_BROWSER_RESULTS.json'
normal_report=json.loads(normal_path.read_text())
attempts=[e for e in normal_report['events'] if e['name']=='PASS live density resize']
if attempts:
    assert len(attempts)==2 and all(e['devicePixelRatio']==3 for e in attempts)
    for requested,event in zip([2,2.625],attempts):
        event.update(original_name=event['name'],name='Density override not accepted as evidence',requested_dpr=requested,accepted_as_density_evidence=False)
    final=next(e for e in reversed(normal_report['events']) if e['name']=='PASS')
    final['original_mode']=final['mode']
    final['mode']='ordinary-speed high-density phone journey'
    normal_report['verification_note']='Two exploratory CDP density overrides were restored to DPR 3 by capture. Their original metrics and labels are retained; they are not accepted as DPR 2/2.625 evidence. Dedicated browser contexts verify those densities in DENSITY_2_BROWSER_RESULTS.json and DENSITY_2.625_BROWSER_RESULTS.json.'
    normal_path.write_text(json.dumps(normal_report,indent=2)+'\n',encoding='utf-8')
for name,(file,expected) in logs.items():
    source=root/'.verification'/file
    text=source.read_text(encoding='utf-8-sig')
    counts=re.search(r'(\d+) checks[;,]\s*(\d+) failures',text)
    assert counts and tuple(map(int,counts.groups()))==(expected,0),(name,text[-600:])
    assert 'SCRIPT ERROR' not in text and 'ERROR:' not in text,(name,text[-600:])
    shutil.copyfile(source,out/'verification'/file)
    results.append({'suite':name,'checks':expected,'failures':0,'log':'verification/'+file})
for file in ['jade-export.log','jade-play.log','jade-comparisons.log','jade-economy.log','jade-browser.log','jade-browser-normal.log','jade-browser-comparison.log','jade-browser-retina.log','jade-browser-density-2.log','jade-browser-density-2.625.log']:
    source=root/'.verification'/file
    text=source.read_text(encoding='utf-8-sig')
    assert 'SCRIPT ERROR' not in text and 'ERROR:' not in text,(file,text[-800:])
    shutil.copyfile(source,out/'verification'/file)
for file in ['BROWSER_RESULTS.json','NORMAL_BROWSER_RESULTS.json','COMPARISON_BROWSER_RESULTS.json','RETINA_BROWSER_RESULTS.json','DENSITY_2_BROWSER_RESULTS.json','DENSITY_2.625_BROWSER_RESULTS.json']:
    report=json.loads((out/file).read_text())
    assert report['completed'] and not report['errors'],file
    if file.startswith('DENSITY_'):
        expected_density=float(file.split('_')[1])
        phones=[e for e in report['events'] if e['name']=='PASS high-density phone']
        resizes=[e for e in report['events'] if e['name']=='PASS live viewport resize']
        assert len(phones)==1 and len(resizes)==3
        assert all(e['devicePixelRatio']==expected_density for e in phones+resizes)
    results.append({'suite':file,'completed':True,'captured_errors':report['errors']})
assert json.loads((out/'CHAPTER_REACHABILITY.json').read_text())['failures']==0
preservation=json.loads((out/'MOBILE_LOGIC_PRESERVATION.json').read_text())
assert len(preservation['files'])==8 and all(row['unchanged'] for row in preservation['files'])
results.append({'suite':'Mobile presentation scope','unchanged_logic_files':8,'evidence':'MOBILE_LOGIC_PRESERVATION.json'})
write('TEST_RESULTS.json',{'date':'2026-10-24','results':results,'scope':'Mobile-first interface and revision-two audio: rendered Windows bounds at 320x640, 390x844, 430x932 and 1280x800. Full four-size flow/audio preceded the final short Arts heading, above-fold Camp and density correction. Final standard-density comparison, DPR 3 mobile touch and ordinary-speed 390px route/Core Trial cover the final export. Dedicated DPR 2 and 2.625 contexts verify actual density and live 320/430/390px resizing; exploratory overrides that stayed at DPR 3 are explicitly not accepted as evidence. The before-fix high-density failure is archived separately. Fixtures are labeled. No physical device or headphone listening claim.'})
reproduction=root/'.verification/jade-browser-retina-before-fix.log'
assert 'timed out' in reproduction.read_text(encoding='utf-8-sig')
shutil.copyfile(reproduction,out/'verification/jade-browser-retina-before-fix.log')

files=[]
for folder in ['scripts','scenes','data','assets','tests']:
    files.extend(p for p in (root/folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
files.extend(root/name for name in ['project.godot','export_presets.cfg','icon.svg','README.md','DESIGN.md'])
source=[{'path':str(p.relative_to(root)).replace('\\','/'),'bytes':p.stat().st_size,'sha256':digest(p)} for p in sorted(set(files))]
build=[{'path':str(p.relative_to(root)).replace('\\','/'),'bytes':p.stat().st_size,'sha256':digest(p)} for p in sorted((root/'builds/web').iterdir()) if p.is_file() and p.suffix!='.import']
baseline=json.loads((root/'.verification/jade-road-before/hashes.json').read_text(encoding='utf-8-sig'))
changed=[]
for row in baseline:
    p=Path(row['Path'])
    if p.exists() and digest(p).upper()!=row['Hash'].upper(): changed.append(str(p.relative_to(root)).replace('\\','/'))
write('SOURCE_MANIFEST.json',{'date':'2026-10-24','engine':'Godot 4.7.2 stable ed1daf0bf','git':'No local Git metadata; no commit, push or deployment. Pre-change checkpoint under .verification/jade-road-before.','changed_checkpoint_files':changed,'source_files':source,'final_web_export':build})
derived=[]
for side,box in [('left',[0,0,48,47]),('right',[720,0,768,47])]:
    p=root/f'assets/ui/progress-end-{side}.png'
    derived.append({'id':'progress-end-'+side,'source':'assets/ui/progress-track.png','crop':box,'runtime':str(p.relative_to(root)).replace('\\','/'),'dimensions':[48,47],'display':[10,10],'sha256':digest(p)})
write('DERIVED_ASSETS.json',derived)

screens=[]
for p in sorted((out/'screenshots').rglob('*.png')):
    name=p.name
    native_final=name.startswith(('native-foundation-','native-camp-','native-developed-','native-golden-'))
    if p.parent.name in ['before','after'] or native_final or name.startswith(('browser-320','browser-390','browser-430','browser-1280','final-','ordinary-','retina-','density-','style-','frame-before-','frame-after-')) or name in ['icon-size-review.png','scene-layer-review.png','main-frame-alpha-review.png']:
        scope='ordinary-speed browser with labeled entry fixtures' if name.startswith('ordinary-') else ('actual browser; labeled state fixture' if name.startswith(('browser-','final-','retina-','density-')) or p.parent.name in ['before','after'] else 'native rendered fixture or asset contact sheet')
        revision='Exploratory override remained at DPR 3; not evidence of the density in this historical filename' if name.startswith('ordinary-density-') else ('Four-size full flow before the final short Arts heading, above-fold Camp and density correction' if name.startswith('browser-') else ('Historical baseline or intermediate panel/density defect' if p.parent.name=='before' or name.startswith(('frame-before-','retina-before-')) else 'Final layout or retained asset inspection'))
        screens.append({'path':str(p.relative_to(out)).replace('\\','/'),'scope':scope,'revision':revision,'sha256':digest(p)})
write('SCREENSHOT_MANIFEST.json',screens)

data=json.loads((root/'data/jade_road.json').read_text())
lines=['# Jade Road content manifest','','Source of truth: `data/jade_road.json` (definition version 1). Live stats are evaluated by `chapter_data.gd`; combat rules are in `combat.gd`.','','## Six finite routes','','| Region / route | Stable ID | Four node IDs | First-clear item |','|---|---|---|---|']
for id,r in data['routes'].items(): lines.append(f"| {r['region']} / {r['name']} | {id} | {', '.join(r['nodes'])} | {data['items'][r['item']]['name']} |")
lines+=['','Every distinct route finale grants one Core Seal. Ordinary node rewards can repeat; first-clear item/seal/art history cannot.','','## 24 encounter definitions','','| ID / name | Traits | HP / armor / attack / interval | Qi / herbs / stones | Art family |','|---|---|---|---|---|']
for id,e in data['enemies'].items(): lines.append(f"| {id} / {e['name']} | {', '.join(e['traits'])} | {e['hp']} / {e['armor']} / {e['attack']} / {e['interval']}s | {e['qi']} / {e['herbs']} / {e['stones']} | {e['art']} |")
lines+=['','## Optional trials','','| ID / name | Objective | Item |','|---|---|---|']
for id,t in data['trials'].items(): lines.append(f"| {id} / {t['name']} | {t['description']} | {data['items'][t['item']]['name'] if t['item'] else 'No item; guaranteed resources'} |")
lines+=['','First successful trial completion grants 2,000 Qi, 4 herbs and 35 stones (60 for the three-encounter mixed sequence); trial rewards are not repeat farms. First Core Trial victory grants 2,500 Qi, 4 herbs and 50 stones.','','## Equipment','','| ID / item | Slot | Base effect | Deterministic source |','|---|---|---|---|']
for id,item in data['items'].items(): lines.append(f"| {id} / {item['name']} | {item['slot']} | {item['description']} | {item['source']} |")
lines+=['','Refinement R1/R2/R3 costs 2,500/7,500/22,500 Qi and 15/30/60 stones. Flat stats scale by 1 + 0.2 × level; secondary effects stay fixed. Four combat arts and their exact costs, cooldowns and descriptions remain in the JSON skills table.','','Core requirements: 75,000 Qi, three distinct finale seals, at least two routes in each region and a separate Core Trial win. Optional 24-herb preparation reduces incoming Core Trial damage by 10%. Golden Core has multiplier 8, three ordered art slots and one free preset. No later chapter is implemented.','']
(out/'CONTENT_MANIFEST.md').write_text('\n'.join(lines),encoding='utf-8')
print(f'Archived {len(results)} suite/browser results, hashed {len(source)} source files, {len(build)} build files and {len(screens)} screenshots; content catalog generated.')
