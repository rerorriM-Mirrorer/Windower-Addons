"""Build the text-only Lua texture bundle from XIVParty's three FFXI PNGs.

Usage: python tools/consolebgplus/build_skin.py SOURCE_DIRECTORY
SOURCE_DIRECTORY contains top.png, mid.png, and bottom.png (or BgTop.png,
BgMid.png, and BgBottom.png from Tylas11/XivParty/assets/ffxi).
Pillow is only needed by this developer tool, not by the Windower addon.
"""
import argparse
import base64
import io
from pathlib import Path
from PIL import Image, ImageDraw


def build(source: Path, destination: Path):
    tiles = {}
    top = None
    for name in ('top', 'mid', 'bottom'):
        path = source / (name + '.png')
        if not path.exists():
            path = source / ('Bg' + name.title() + '.png')
        image = Image.open(path).convert('RGBA')
        if name == 'mid':
            # The fill starts at the outer top instead of below the 10px
            # rail. Rotate by two rows to keep the native body stripe phase.
            original = image.copy()
            for y in range(image.height):
                image.paste(original.crop((0, (y + 2) % 4, image.width, (y + 2) % 4 + 1)), (0, y))
        else:
            # Only the silver rail is overlaid on the continuous fill.
            # Its baked background would darken the first/last stripe rows.
            rail_rows = range(3) if name == 'top' else range(5, 8)
            for y in range(image.height):
                if y not in rail_rows:
                    for x in range(image.width):
                        r, g, b, _ = image.getpixel((x, y))
                        image.putpixel((x, y), (r, g, b, 0))
        if name == 'top': top = image
        # The native right fade occupies 64px. Taking only its final 20px
        # starts almost transparent and leaves a visible step at the join.
        left_cap = 3 if name == 'mid' else 20
        right_cap = 64
        rectangles = {
            name + '_left': (0, 0, left_cap, image.height),
            name + '_center': (208, 0, 212, image.height),
            name + '_right': (image.width - right_cap, 0, image.width, image.height),
        }
        if name == 'top':
            rectangles['divider_left'] = (0, 0, left_cap, 2)
            rectangles['divider_center'] = (208, 0, 212, 2)
            rectangles['divider_right'] = (image.width - right_cap, 0, image.width, 2)
        for tile_name, rectangle in rectangles.items():
            tile = image.crop(rectangle)
            stream = io.BytesIO()
            tile.save(stream, 'PNG')
            tiles[tile_name] = base64.b64encode(stream.getvalue()).decode('ascii')
            if name == 'mid':
                # A gently brighter copy keeps the stripe spacing and native
                # edge alpha. The layout blends it in only near the bottom.
                glow = tile.copy()
                glow.putdata([(min(255, r + 80), min(255, g + 64),
                               min(255, b + 110), a)
                              for r, g, b, a in (tile.getpixel((x, y))
                                                for y in range(tile.height)
                                                for x in range(tile.width))])
                stream = io.BytesIO()
                glow.save(stream, 'PNG')
                tiles[tile_name.replace('mid_', 'glow_')] = base64.b64encode(stream.getvalue()).decode('ascii')

    # Fade the rail into the title notch on both sides. The layout leaves
    # out the original rail under these caps, so a translucent cap cannot
    # reveal a solid silver line beneath the title.
    for name, reverse in (('title_left', False), ('title_right', True)):
        cap = Image.new('RGBA', (8, 10))
        for y in range(10):
            for x in range(8):
                r, g, b, a = top.getpixel((208 + x % 4, y))
                strength = x / 7 if reverse else 1 - x / 7
                cap.putpixel((x, y), (r, g, b, round(a * strength)))
        stream = io.BytesIO()
        cap.save(stream, 'PNG')
        tiles[name] = base64.b64encode(stream.getvalue()).decode('ascii')

    # The native input tab is a short grey plaque above the divider. Keep
    # the little corner caps fixed-size when its centre is resized.
    tab = Image.new('RGBA', (40, 14))
    draw = ImageDraw.Draw(tab)
    draw.rounded_rectangle((0, 0, 39, 15), radius=2, fill=(125, 126, 144, 255),
                           outline=(167, 168, 181, 255), width=1)
    for name, rectangle in {'tab_left': (0, 0, 3, 14),
                            'tab_center': (20, 0, 21, 14),
                            'tab_right': (36, 0, 40, 14)}.items():
        stream = io.BytesIO()
        tab.crop(rectangle).save(stream, 'PNG')
        tiles[name] = base64.b64encode(stream.getvalue()).decode('ascii')

    handle = Image.new('RGBA', (14, 14))
    draw = ImageDraw.Draw(handle)
    for offset in (2, 6, 10):
        draw.line((offset, 12, 12, offset), fill=(198, 199, 217, 240), width=1)
    stream = io.BytesIO()
    handle.save(stream, 'PNG')
    tiles['resize_handle'] = base64.b64encode(stream.getvalue()).decode('ascii')

    # Repeat the same pale diagonal motif along the top drag edge in edit mode.
    grip = Image.new('RGBA', (10, 6))
    ImageDraw.Draw(grip).line((2, 5, 7, 0), fill=(198, 199, 217, 240), width=1)
    stream = io.BytesIO()
    grip.save(stream, 'PNG')
    tiles['drag_grip'] = base64.b64encode(stream.getvalue()).decode('ascii')

    entries = '\n'.join("    %s = '%s'," % (name, value) for name, value in sorted(tiles.items()))
    module = """-- Generated texture bundle. Do not edit the base64 payloads by hand.
-- Source: Tylas11/XivParty assets/ffxi/BgTop.png, BgMid.png, BgBottom.png.
-- Copyright 2024 Tylas. See LICENSE.txt for attribution and terms.
local skin = {}
local images = {
%s
}

local alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local values = {}
for index = 1, #alphabet do values[alphabet:sub(index, index)] = index - 1 end

local function decode(text)
    local bytes = {}
    for index = 1, #text, 4 do
        local a = values[text:sub(index, index)]
        local b = values[text:sub(index + 1, index + 1)]
        local c = values[text:sub(index + 2, index + 2)]
        local d = values[text:sub(index + 3, index + 3)]
        bytes[#bytes + 1] = string.char(a * 4 + math.floor(b / 16))
        if c then bytes[#bytes + 1] = string.char((b %% 16) * 16 + math.floor(c / 4)) end
        if d then bytes[#bytes + 1] = string.char((c %% 4) * 64 + d) end
    end
    return table.concat(bytes)
end

function skin.prepare(root)
    if root:sub(-1) ~= '/' and root:sub(-1) ~= '\\\\' then root = root .. '/' end
    local directory = root .. 'assets/'
    if windower.create_dir then windower.create_dir(directory) end
    local paths = {}
    for name, encoded in pairs(images) do
        local path = directory .. 'cbgplus_v4_' .. name .. '.png'
        local bytes = decode(encoded)
        local existing = io.open(path, 'rb')
        local unchanged = false
        if existing then
            unchanged = existing:read('*a') == bytes
            existing:close()
        end
        if not unchanged then
            local file, open_error = io.open(path, 'wb')
            if not file then return nil, open_error end
            local written, write_error = file:write(bytes)
            local closed, close_error = file:close()
            if not written or not closed then return nil, write_error or close_error end
        end
        paths[name] = path
    end
    return paths
end

return skin
""" % entries
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(module, encoding='utf-8')
    print('Built %d native-size PNG pieces into %s' % (len(tiles), destination))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    args = parser.parse_args()
    build(args.source, Path(__file__).resolve().parents[2] / 'addons/ConsoleBGPlus/cbg_skin.lua')
