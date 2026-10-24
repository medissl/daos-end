"""Technical size/padding normalization of preserved generated sources; no repainting.
Run from repo root. Requires Pillow. Source images remain unchanged.
"""
import json
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / 'assets/icons/manifest.json').read_text())
for entry in manifest:
    name = entry['id']
    image = Image.open(root / entry['source']).convert('RGBA')
    if name == 'route':
        image.thumbnail((1248, 416), Image.Resampling.LANCZOS)
    else:
        assert image.getchannel('A').getextrema()[0] == 0, name + ' has no transparency'
        box = image.getchannel('A').point(lambda a: 255 if a > 16 else 0).getbbox()
        glyph = image.crop(box)
        glyph.thumbnail((216, 216), Image.Resampling.LANCZOS)
        image = Image.new('RGBA', (256, 256))
        image.alpha_composite(glyph, ((256-glyph.width)//2, (256-glyph.height)//2))
    image.save(root / entry['runtime'], optimize=True)
print('Normalized', len(manifest)-1, 'transparent icons and one route vignette')
