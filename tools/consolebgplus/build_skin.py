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
from PIL import Image


def build(source: Path, destination: Path):
    tiles = {}
    for name in ('top', 'mid', 'bottom'):
        path = source / (name + '.png')
        if not path.exists():
            path = source / ('Bg' + name.title() + '.png')
        image = Image.open(path).convert('RGBA')
        cap = 3 if name == 'mid' else 20
        rectangles = {
            name + '_left': (0, 0, cap, image.height),
            name + '_center': (208, 0, 212, image.height),
            name + '_right': (image.width - cap, 0, image.width, image.height),
        }
        if name == 'top':
            rectangles['divider'] = (208, 0, 212, 2)
        for tile_name, rectangle in rectangles.items():
            tile = image.crop(rectangle)
            stream = io.BytesIO()
            tile.save(stream, 'PNG')
            tiles[tile_name] = base64.b64encode(stream.getvalue()).decode('ascii')

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
        local path = directory .. 'cbgplus_v1_' .. name .. '.png'
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
