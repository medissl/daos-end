"""Technical alpha-preserving crop/padding/downscale; never repaint source art."""
from pathlib import Path
import json, hashlib, shutil
from PIL import Image
import numpy as np
root=Path(__file__).resolve().parent.parent
inputs=json.loads((root/'.verification/jade-art-inputs.json').read_text())
records=[]
for entry in inputs:
    source=Path(entry['source'])
    archived=root/'docs/jade-road/sources'/f"{entry['id']}{'-refined' if entry.get('edit_from') else ''}.png"
    if not archived.exists(): shutil.copyfile(source,archived)
    img=Image.open(archived).convert('RGBA')
    box=img.getchannel('A').point(lambda x:255 if x>16 else 0).getbbox()
    if entry['id']=='methods-scroll':
        # Ignore isolated marks beyond the paper/rods when finding crop bounds.
        # Keep 12 source pixels of safety; alpha inside the crop is untouched.
        occupied=np.flatnonzero((np.asarray(img.getchannel('A'))>16).sum(axis=1)>img.width*.05)
        box=(box[0],max(box[1],int(occupied[0])-12),box[2],min(box[3],int(occupied[-1])+13))
    if entry['id']=='main-panel':
        # Preserve a safety gutter around the complete opaque contour.
        box=(max(0,box[0]-8),max(0,box[1]-8),min(img.width,box[2]+8),min(img.height,box[3]+8))
    if entry['kind']=='icon':
        trimmed=img.crop(box); trimmed.thumbnail((216,216),Image.Resampling.LANCZOS)
        out=Image.new('RGBA',(256,256)); out.alpha_composite(trimmed,((256-trimmed.width)//2,(256-trimmed.height)//2))
        destination=root/'assets/chapter'/f"{entry['id']}.png"
    elif entry['kind']=='scene':
        out=img.copy(); out.thumbnail((1200,900),Image.Resampling.LANCZOS)
        destination=root/'assets/chapter'/f"{entry['id']}.png"
    else:
        out=img.crop(box)
        width=768 if entry['id']=='progress-track' else (384 if entry['id']=='methods-scroll' else 512)
        out=out.resize((width,round(out.height*width/out.width)),Image.Resampling.LANCZOS)
        destination=root/'assets/ui'/f"{entry['id']}.png"
    out.save(destination)
    records.append(dict(entry,source=str(archived.relative_to(root)),generator_file=source.name,runtime=str(destination.relative_to(root)),dimensions=list(out.size),crop_bounds=list(box),source_sha256=hashlib.sha256(archived.read_bytes()).hexdigest(),runtime_sha256=hashlib.sha256(destination.read_bytes()).hexdigest(),alpha='Preserved from built-in imagegen; crop bounds only, no alpha repaint'))
(root/'docs/jade-road/ART_MANIFEST.json').write_text(json.dumps(records,indent=2)+'\n')
print(f'{len(records)} individually generated assets copied, normalized and hashed.')

# Independent meter end layers derived from the accepted generated track.
track=Image.open(root/'assets/ui/progress-track.png').convert('RGBA')
for side,box in [('left',(0,0,48,track.height)),('right',(track.width-48,0,track.width,track.height))]:
    track.crop(box).save(root/'assets/ui'/f'progress-end-{side}.png')
