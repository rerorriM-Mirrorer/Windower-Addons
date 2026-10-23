"""Deterministic 23px provisional badges; replaceable when final art is chosen."""
from pathlib import Path
from PIL import Image, ImageDraw
out=Path(__file__).resolve().parents[1]/'images/currencies'
out.mkdir(parents=True,exist_ok=True)
for name,color,label in [('sparks',(149,204,226),'SP'),('sandoria',(218,144,147),'SD'),('bastok',(153,178,220),'BA'),('windurst',(156,204,167),'WI')]:
    im=Image.new('RGBA',(23,23));d=ImageDraw.Draw(im)
    d.rounded_rectangle((1,1,21,21),radius=5,fill=(*color,45),outline=(*color,220),width=1)
    d.text((11,11),label,anchor='mm',fill=(*color,255))
    im.save(out/(name+'.png'))
