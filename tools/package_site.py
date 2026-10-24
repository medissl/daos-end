"""Build the static landing and exported-game site without external dependencies."""
from pathlib import Path
import shutil
from PIL import Image

root=Path(__file__).resolve().parents[1]
source=root/'site'
output=root/'builds/site'
media=output/'media'
media.mkdir(parents=True,exist_ok=True)
for name in ['index.html','style.css']:
    shutil.copy2(source/name,output/name)
for name in ['CormorantGaramond.ttf','Lato-Regular.ttf','CormorantGaramond-OFL.txt','Lato-OFL.txt']:
    shutil.copy2(root/'assets/fonts'/name,media/name)
shutil.copy2(root/'assets/icons/qi.png',media/'qi.png')
for src,dst in [('assets/art/sanctuary-wide.png','sanctuary.webp'),('assets/art/living/golden.png','cultivator.webp')]:
    Image.open(root/src).save(media/dst,'WEBP',quality=91,method=6)
for src,dst in [('320x640-storm-battle.png','storm.png'),('320x640-manage-thunder.png','build.png'),('320x640-nascent-persistent.png','nascent.png')]:
    shutil.copy2(root/'docs/living-dao/screenshots/frontier-browser'/src,media/dst)
shutil.copytree(root/'builds/web',output/'play',dirs_exist_ok=True,ignore=shutil.ignore_patterns('*.import'))
for stale in (output/'play').glob('*.import'):
    stale.unlink()
(output/'.nojekyll').write_text('',encoding='utf-8')
evidence=output/'evidence'
evidence.mkdir(exist_ok=True)
for name in ['COMPARE.html','DELIVERY.md','PACING.md','CONTENT_TABLE.md','MOTION_REVIEW.md','AUDIO_VERIFICATION.md']:
    shutil.copy2(root/'docs/living-dao'/name,evidence/name)
for folder in ['before','release','release-desktop','frontier-browser']:
    shutil.copytree(root/'docs/living-dao/screenshots'/folder,evidence/'screenshots'/folder,dirs_exist_ok=True)
(evidence/'motion').mkdir(exist_ok=True)
for source in (root/'docs/living-dao/motion').iterdir():
    if source.is_file() and (source.name.endswith('-frontier.webm') or source.name.endswith('-storm-audio.webm') or source.name.endswith('-soul-audio.webm') or source.name in ['living-dao-reel.webm','realm-progression.png']):
        shutil.copy2(source,evidence/'motion'/source.name)
print('Built',output)
