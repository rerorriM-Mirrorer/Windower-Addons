"""Render a Lua layout export to inspect the texture joins and labels offline.

Example: python tools/consolebgplus/render_preview.py --layout reference/layout.json
"""
import argparse
import json
import os
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path(__file__).resolve().parents[2]


def font(name, size):
    candidates = [name]
    runtime = os.environ.get('CODEX_PRIMARY_RUNTIME_ROOT')
    if runtime:
        candidates.append(str(Path(runtime) / 'dependencies/native/libreoffice-headless/libreoffice/share/fonts/truetype' / name))
    for candidate in candidates:
        try:
            return ImageFont.truetype(candidate, size)
        except OSError:
            pass
    return ImageFont.truetype('DejaVuSans.ttf', size)


def render(layout_path, output_path):
    data = json.loads(layout_path.read_text())
    width = data['viewport']['width']
    height = max(piece['y'] + piece['height'] for piece in data['pieces']) + 24
    canvas = Image.new('RGBA', (width, height), (42, 42, 44, 255))
    draw = ImageDraw.Draw(canvas)
    for y in range(0, height, 32):
        for x in range(0, width, 32):
            if (x // 32 + y // 32) % 2:
                draw.rectangle((x, y, x + 31, y + 31), fill=(53, 53, 56, 255))
    for piece in data['pieces']:
        source = Image.open(root / 'addons/ConsoleBGPlus/assets' /
                            ('cbgplus_v2_' + piece['texture'] + '.png')).convert('RGBA')
        patch = Image.new('RGBA', (piece['width'], piece['height']))
        for y in range(0, patch.height, source.height):
            for x in range(0, patch.width, source.width):
                patch.paste(source, (x, y))
        r, g, b, a = patch.split()
        patch = Image.merge('RGBA', tuple(channel.point(lambda v, strength=strength: round(v * strength / 255))
                                         for channel, strength in zip((r, g, b),
                                                                      (piece['red'], piece['green'], piece['blue']))) +
                            (a.point(lambda value: round(value * piece['alpha'] / 255)),))
        canvas.alpha_composite(patch, (piece['x'], piece['y']))
    draw = ImageDraw.Draw(canvas)
    # Verdana remains the user's in-game console font. This local fallback
    # shows alignment only; Windows/Windower supplies the actual typeface.
    console_font = font('DejaVuSans.ttf', 14)
    lines = ['> ConsoleBG+ v0.1.1', '> Full native edge fade and a subtle bottom glow.',
             '> cbg width screen', '> The title and the input tab are separate.',
             '> cbg input on 26', '> cbg tab right']
    for index, line in enumerate(lines):
        draw.text((50, 210 + index * 17), line, font=console_font, fill=(238, 238, 238, 255))
    draw.text((50, 329), '$', font=console_font, fill=(238, 238, 238, 255))
    for label in data['labels']:
        label_font = font('DejaVuSans-Oblique.ttf', max(8, round(label['size'] * 1.4)))
        draw.text((label['x'], label['y'] - 2), label['text'], font=label_font,
                  fill=(label['red'], label['green'], label['blue'], 255))
    canvas.convert('RGB').save(output_path)
    return canvas


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--layout', type=Path, default=Path('reference/layout.json'))
    parser.add_argument('--output', type=Path, default=Path('reference/preview.png'))
    args = parser.parse_args()
    render(root / args.layout, root / args.output)
    print('Rendered', args.output, 'from', args.layout)
