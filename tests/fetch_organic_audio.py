"""Archive primary CC0 packages before selecting any runtime recordings."""
from pathlib import Path
from urllib.request import Request,urlopen
from concurrent.futures import ThreadPoolExecutor
import hashlib,json,zipfile
root=Path(__file__).resolve().parent.parent/'docs/jade-road/sources/audio/organic-v2'
root.mkdir(parents=True,exist_ok=True)
sources={
 'rubberduck-everyday.html':'https://opengameart.org/content/100-cc0-sfx',
 'rubberduck-foley2.html':'https://opengameart.org/content/100-cc0-sfx-2',
 'rubberduck-everyday.zip':'https://opengameart.org/sites/default/files/100-CC0-SFX_0.zip',
 'rubberduck-foley2.zip':'https://opengameart.org/sites/default/files/sfx_100_v2.zip',
 'biteme-chinese-music.html':'https://bitemegames.itch.io/chinese-game-music',
 'biteme-download-page.html':'https://bitemegames.itch.io/chinese-game-music/purchase'}
def fetch(pair):
 name,url=pair
 with urlopen(Request(url,headers={'User-Agent':'Mozilla/5.0'}),timeout=60) as response: data=response.read()
 target=root/name;target.write_bytes(data)
 if target.suffix=='.zip':
  with zipfile.ZipFile(target) as archive:
   for member in archive.infolist():
    destination=(root/target.stem/member.filename).resolve()
    assert destination.is_relative_to((root/target.stem).resolve())
   archive.extractall(root/target.stem)
 return {'file':name,'url':url,'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)}
records=list(ThreadPoolExecutor(max_workers=4).map(fetch,sources.items()))
(root/'receipt.json').write_text(json.dumps(records,indent=2)+'\n')
for r in records:print(r['file'],r['bytes'])
print('Recordings:',*[str(p.relative_to(root)) for p in root.rglob('*.ogg')],sep='\n')
