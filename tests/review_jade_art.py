"""Runtime-size contact sheets, with no modification to production artwork."""
from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont

root=Path(__file__).resolve().parent.parent
records=json.loads((root/'docs/jade-road/ART_MANIFEST.json').read_text())
font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',15)
icons=[r for r in records if r['kind']=='icon']
sheet=Image.new('RGB',(760,52+len(icons)*90),'#f4efe2')
draw=ImageDraw.Draw(sheet)
draw.text((16,12),'Jade Road: actual runtime icons at 32 / 48 / 64 logical pixels',font=font,fill='#293e39')
for i,r in enumerate(icons):
    y=52+i*90
    draw.text((16,y+24),r['id'],font=font,fill='#293e39')
    art=Image.open(root/r['runtime']).convert('RGBA')
    for x,size in [(220,32),(300,48),(400,64)]:
        sheet.paste(art.resize((size,size),Image.Resampling.LANCZOS),(x,y+(64-size)//2),art.resize((size,size),Image.Resampling.LANCZOS))
    dark=Image.new('RGBA',(76,76),'#293e39')
    small=art.resize((64,64),Image.Resampling.LANCZOS)
    dark.alpha_composite(small,(6,6))
    sheet.paste(dark.convert('RGB'),(540,y))
    draw.line((16,y+82,740,y+82),fill='#ced2c4')
sheet.save(root/'docs/jade-road/screenshots/icon-size-review.png')
scenes=[r for r in records if r['kind']=='scene']
sheet=Image.new('RGB',(1000,60+((len(scenes)+1)//2)*360),'#f4efe2')
draw=ImageDraw.Draw(sheet)
draw.text((16,12),'Region and guardian silhouettes: actual runtime layers',font=font,fill='#293e39')
for i,r in enumerate(scenes):
    x=16+(i%2)*490;y=60+(i//2)*360
    draw.text((x,y),r['id'],font=font,fill='#293e39')
    art=Image.open(root/r['runtime']).convert('RGBA');art.thumbnail((460,320),Image.Resampling.LANCZOS)
    sheet.paste(art,(x+(460-art.width)//2,y+26),art)
sheet.save(root/'docs/jade-road/screenshots/scene-layer-review.png')
print(f'Review sheets: {len(icons)} icons at three sizes; {len(scenes)} scene/guardian layers.')
