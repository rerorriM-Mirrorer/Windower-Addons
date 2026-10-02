"""Render the actual Lua layout export to inspect texture seams offline."""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path(__file__).resolve().parents[2]
canvas = Image.new('RGBA', (1140, 390), (42, 42, 44, 255))
draw = ImageDraw.Draw(canvas)
for y in range(0, canvas.height, 32):
    for x in range(0, canvas.width, 32):
        if (x // 32 + y // 32) % 2:
            draw.rectangle((x, y, x + 31, y + 31), fill=(53, 53, 56, 255))
for piece in json.loads((root / 'reference/layout.json').read_text()):
    source = Image.open(root / 'addons/ConsoleBGPlus/assets' / ('cbgplus_v1_' + piece['texture'] + '.png')).convert('RGBA')
    patch = Image.new('RGBA', (piece['width'], piece['height']))
    for y in range(0, patch.height, source.height):
        for x in range(0, patch.width, source.width):
            patch.paste(source, (x, y))
    patch.putalpha(patch.getchannel('A').point(lambda value: round(value * piece['alpha'] / 255)))
    canvas.alpha_composite(patch, (piece['x'], piece['y']))
draw = ImageDraw.Draw(canvas)
font = ImageFont.truetype('DejaVuSans.ttf', 14)
lines = ['> ConsoleBG+ v0.1.0', '> FFXI-style frame loaded.', '> Position: 32,16 | Size: 1070x344', '> Gradient: 110 to 235', '> cbg help', '> Native stripe spacing; fixed-size corners.', '$']
for index, line in enumerate(lines):
    draw.text((50, 226 + index * 17), line, font=font, fill=(238, 238, 238, 255))
canvas.convert('RGB').save(root / 'reference/preview.png')
print('Offline preview rendered from the Lua-generated primitive layout.')
