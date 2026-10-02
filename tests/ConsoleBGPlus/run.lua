-- Run from the Lua repository root: lua tests/ConsoleBGPlus/run.lua
-- Exercises the addon against a minimal Windower API, not a game client.
local addon_path = 'addons/ConsoleBGPlus/'
package.path = addon_path .. '?.lua;' .. package.path
local callbacks, objects, text_objects, saved, logs = {}, {}, {}, nil, {}
local console_open, screen_width, screen_height = false, 1920, 1080
local visibility_calls, geometry_calls = 0, 0
_addon = {}

local function copy(value)
    if type(value) ~= 'table' then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = copy(item) end
    return result
end

local config = {}
local function merge(base, value)
    for key, item in pairs(value or {}) do
        if type(item) == 'table' and type(base[key]) == 'table' then merge(base[key], item)
        else base[key] = copy(item) end
    end
    return base
end
function config.load(defaults) return merge(copy(defaults), saved) end
function config.save(settings) saved = copy(settings) end
function config.register(settings, fn) config.callback = fn; return 'test-registration' end
function config.unregister(settings, registration) assert(registration == 'test-registration') end
package.preload.config = function() return config end

windower = {
    addon_path = addon_path,
    console = {visible = function() return console_open end},
    prim = {},
    text = {},
    get_windower_settings = function()
        return {ui_x_res = screen_width, ui_y_res = screen_height}
    end,
    add_to_chat = function(color, text) logs[#logs + 1] = {color, text} end,
    register_event = function(name, fn) callbacks[name] = fn end,
}
function windower.prim.create(name) assert(not objects[name]); objects[name] = {} end
function windower.prim.delete(name) assert(objects[name]); objects[name] = nil end
function windower.prim.set_visibility(name, visible)
    assert(type(visible) == 'boolean'); objects[name].visible = visible
    visibility_calls = visibility_calls + 1
end
function windower.prim.set_fit_to_texture(name, fit) objects[name].fit = fit end
function windower.prim.set_texture(name, path)
    local file = assert(io.open(path, 'rb'))
    assert(file:read(8) == '\137PNG\r\n\26\n'); file:close()
    objects[name].texture = path
end
function windower.prim.set_position(name, x, y)
    objects[name].x, objects[name].y = x, y; geometry_calls = geometry_calls + 1
end
function windower.prim.set_size(name, width, height)
    assert(width > 0 and height > 0)
    objects[name].width, objects[name].height = width, height
end
function windower.prim.set_repeat(name, x, y)
    assert(x > 0 and y > 0); objects[name].repeat_x, objects[name].repeat_y = x, y
end
function windower.prim.set_color(name, alpha, red, green, blue)
    for _, value in ipairs({alpha, red, green, blue}) do
        assert(value >= 0 and value <= 255 and value % 1 == 0)
    end
    objects[name].alpha = alpha
end

function windower.text.create(name) assert(not text_objects[name]); text_objects[name] = {} end
function windower.text.delete(name) assert(text_objects[name]); text_objects[name] = nil end
function windower.text.set_visibility(name, value)
    assert(type(value) == 'boolean'); text_objects[name].visible = value
    visibility_calls = visibility_calls + 1
end
function windower.text.set_font(name, value) text_objects[name].font = value end
function windower.text.set_font_size(name, value) text_objects[name].size = value end
function windower.text.set_text(name, value) text_objects[name].text = value end
function windower.text.set_italic(name, value) text_objects[name].italic = value end
function windower.text.set_bold(name, value) text_objects[name].bold = value end
function windower.text.set_right_justified(name, value) text_objects[name].right = value end
function windower.text.set_bg_visibility(name, value) text_objects[name].bg = value end
function windower.text.set_bg_border_size(name, value) text_objects[name].padding = value end
function windower.text.set_color(name, alpha, red, green, blue)
    text_objects[name].alpha = alpha
    text_objects[name].red, text_objects[name].green, text_objects[name].blue = red, green, blue
end
function windower.text.set_stroke_width(name, value) text_objects[name].stroke = value end
function windower.text.set_stroke_color(name, alpha, red, green, blue) end
function windower.text.set_location(name, x, y)
    text_objects[name].x, text_objects[name].y = x, y
    geometry_calls = geometry_calls + 1
end
function windower.text.get_extents(name)
    local object = text_objects[name]
    return math.ceil(#object.text * object.size * 0.7), math.ceil(object.size * 1.4)
end

local function count()
    local result = 0
    for _ in pairs(objects) do result = result + 1 end
    return result
end
local function all_visible(value)
    for _, object in pairs(objects) do assert(object.visible == value) end
    assert(text_objects.ConsoleBGPlus_label_title.visible == value)
    if not value then assert(not text_objects.ConsoleBGPlus_label_input.visible) end
end
local function run(...) callbacks['addon command'](...) end
local function tick() callbacks.prerender() end

dofile(addon_path .. 'ConsoleBGPlus.lua')
assert(count() > 10 and count() <= 199)
run('status'); assert(logs[#logs][2]:find('1856x344 (screen width)', 1, true))
assert(text_objects.ConsoleBGPlus_label_title.font == 'Verdana')
assert(not text_objects.ConsoleBGPlus_label_input.visible)
all_visible(false)
console_open = true; tick(); all_visible(true)
local calls = visibility_calls
local geometry = geometry_calls
for _ = 1, 60 do tick() end
assert(visibility_calls == calls and geometry_calls == geometry,
    'An unchanged frame should not redraw its primitives on every tick')
console_open = false; tick(); all_visible(false)
run('preview', 'on'); all_visible(true)
run('preview', 'off'); all_visible(false)

run('position', '16', '24')
run('size', '960', '320')
run('gradient', '80', '230')
assert(saved.pos.x == 16 and saved.pos.y == 24)
assert(saved.extents.x == 960 and saved.extents.y == 320)
assert(saved.gradient.top == 80 and saved.gradient.bottom == 230)
local old_count = count()
run('input', 'on', '26'); assert(count() == old_count + 6 and saved.input.enabled)
run('preview', 'on'); assert(text_objects.ConsoleBGPlus_label_input.visible)
local right_tab_x = text_objects.ConsoleBGPlus_label_input.x
run('tab', 'left'); assert(text_objects.ConsoleBGPlus_label_input.x < right_tab_x)
run('tab', 'right'); assert(text_objects.ConsoleBGPlus_label_input.x == right_tab_x)
run('preview', 'off')
run('input', 'off'); assert(count() == old_count and not saved.input.enabled)
assert(not text_objects.ConsoleBGPlus_label_input.visible)

run('width', 'screen'); assert(saved.extents.mode == 'screen')
console_open = true; tick()
screen_width = 1280; tick()
run('status'); assert(logs[#logs][2]:find('1248x320 (screen width)', 1, true))
assert(saved.extents.x == 960, 'Responsive width must preserve the fixed-width preference')
screen_width = 1920; tick()
run('width', '960'); assert(saved.extents.mode == 'fixed' and saved.extents.x == 960)
local with_glow = count()
run('glow', '0'); assert(count() < with_glow)
run('glow', '48', '32'); assert(saved.glow.alpha == 48 and saved.glow.height == 32)

local before = copy(saved)
run('size', 'oops', '100')
run('gradient', '-1', '256')
run('position', '1.5', '50')
run('color', '255', '0', '1')
run('input', 'on', 'NaN')
run('width', '119')
run('width', 'screen', 'extra')
run('glow', '256')
run('glow', '12', '3')
run('tab', 'centre')
assert(saved.extents.x == before.extents.x and saved.gradient.top == before.gradient.top)
assert(saved.pos.x == before.pos.x and saved.bg.red == before.bg.red)
assert(logs[#logs][1] == 123)

console_open = true; tick()
screen_width, screen_height = 640, 240; tick()
for _, object in pairs(objects) do
    assert(object.x >= 0 and object.y >= 0)
    assert(object.x + object.width <= screen_width and object.y + object.height <= screen_height)
end
assert(saved.extents.x == 960 and saved.extents.y == 320,
    'Clipping to a smaller viewport must not overwrite saved geometry')
screen_width, screen_height = 1920, 1080; tick()
run('status'); assert(logs[#logs][2]:find('960x320', 1, true))
callbacks.unload(); assert(count() == 0 and next(text_objects) == nil)
-- A v0.1.0 settings file retains the user's colors/position while new
-- fields receive their defaults from Windower's config library.
saved.extents.mode, saved.glow, saved.input.tab = nil, nil, nil
dofile(addon_path .. 'ConsoleBGPlus.lua')
run('status'); assert(logs[#logs][2]:find('1888x320 (screen width)', 1, true))
assert(logs[#logs][2]:find('gradient 80 to 230', 1, true))
config.callback()
run('reset')
assert(saved.pos.x == 32 and saved.extents.x == 1070 and saved.extents.mode == 'screen' and saved.gradient.top == 110)
run('alpha', '0')
for _, object in pairs(objects) do
    if object.texture:find('_mid_', 1, true) then assert(object.alpha == 0) end
end
run('reset')

-- Export actual layout geometry for the offline renderer.
local layout = require('cbg_layout')
local function export(path, viewport)
    if os.getenv('CBGPLUS_EXPORT_LAYOUT') ~= '1' then return end
    local pieces = layout.build(saved, viewport, windower.text.get_extents('ConsoleBGPlus_label_title'))
    local file = assert(io.open(path, 'w'))
    file:write(string.format('{"viewport":{"width":%d,"height":%d},"pieces":[', viewport.width, viewport.height))
    for index, piece in ipairs(pieces) do
        if index > 1 then file:write(',') end
        file:write(string.format('{"texture":"%s","x":%d,"y":%d,"width":%d,"height":%d,"alpha":%d,"red":%d,"green":%d,"blue":%d,"repeat_x":%.6f,"repeat_y":%.6f}',
            piece.texture, piece.x, piece.y, piece.width, piece.height, piece.alpha,
            piece.red, piece.green, piece.blue, piece.repeat_x, piece.repeat_y))
    end
    file:write('],"labels":[')
    local first = true
    for _, object in pairs(text_objects) do
        if object.visible then
            if not first then file:write(',') end
            file:write(string.format('{"text":"%s","x":%d,"y":%d,"size":%d,"red":%d,"green":%d,"blue":%d}',
                object.text, object.x, object.y, object.size, object.red, object.green, object.blue))
            first = false
        end
    end
    file:write(']}'); file:close()
end
run('input', 'on', '26')
console_open = true; tick()
export('reference/layout.json', {width = 1920, height = 1080})
run('size', '1070', '344')
export('reference/layout_fixed.json', {width = 1920, height = 1080})
run('glow', '0')
export('reference/layout_no_glow.json', {width = 1920, height = 1080})
run('reset'); run('input', 'on')
for _, viewport in ipairs({{width=120,height=40}, {width=80,height=30}, {width=1,height=1}, {width=640,height=240}, {width=3840,height=2160}}) do
    local pieces = layout.build(saved, viewport)
    for _, piece in ipairs(pieces) do
        assert(piece.x >= 0 and piece.y >= 0)
        assert(piece.x + piece.width <= viewport.width and piece.y + piece.height <= viewport.height,
            'Every frame piece must fit even a small viewport')
    end
end
callbacks.unload(); assert(count() == 0 and next(text_objects) == nil)
print('PASS: responsive/fixed widths, legacy settings, separate labels, tab placement, glow, show/hide, idle rendering, validation, viewport bounds, and unload cleanup.')
