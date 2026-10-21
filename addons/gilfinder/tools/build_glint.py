"""A: deterministic masked highlight frames for the native 23px coin sprite."""
from pathlib import Path
from PIL import Image
import math
root=Path(__file__).resolve().parents[1]
coin=Image.open(root/'gil.png').convert('RGBA')
out=root/'images/glint';out.mkdir(parents=True,exist_ok=True)
for frame in range(20):
    progress=frame/19
    image=Image.new('RGBA',coin.size)
    for y in range(coin.height):
        for x in range(coin.width):
            # Diagonal ribbon travels over the opaque coin only.
            d=(x+0.48*y)-(-8+progress*50)
            strength=math.exp(-0.5*(d/1.6)**2)*0.85 + math.exp(-0.5*(d/4.0)**2)*0.15
            alpha=round(coin.getpixel((x,y))[3]*strength*math.sin(math.pi*progress))
            image.putpixel((x,y),(255,249,220,alpha))
    image.save(out/f'{frame+1:02}.png')
print('Generated 20 masked glint frames')
