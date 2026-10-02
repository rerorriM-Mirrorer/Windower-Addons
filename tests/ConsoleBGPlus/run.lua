-- Run from the Lua repository root: lua tests/ConsoleBGPlus/run.lua
-- Exercises the addon against a minimal Windower API, not a game client.
local addon_path = 'addons/ConsoleBGPlus/'
package.path = addon_path .. '?.lua;' .. package.path
local callbacks, objects, saved, logs = {}, {}, nil, {}
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
function config.load(defaults) return saved and copy(saved) or copy(defaults) end
function config.save(settings) saved = copy(settings) end
function config.register(settings, fn) config.callback = fn; return 'test-registration' end
function config.unregister(settings, registration) assert(registration == 'test-registration') end
package.preload.config = function() return config end

windower = {
    addon_path = addon_path,
    console = {visible = function() return console_open end},
    prim = {},
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

local function count()
    local result = 0
    for _ in pairs(objects) do result = result + 1 end
    return result
end
local function all_visible(value)
    for _, object in pairs(objects) do assert(object.visible == value) end
end
local function run(...) callbacks['addon command'](...) end
local function tick() callbacks.prerender() end

dofile(addon_path .. 'ConsoleBGPlus.lua')
assert(count() > 10 and count() <= 199)
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
run('input', 'on', '26'); assert(count() == old_count + 1 and saved.input.enabled)
run('input', 'off'); assert(count() == old_count and not saved.input.enabled)

local before = copy(saved)
run('size', 'oops', '100')
run('gradient', '-1', '256')
run('position', '1.5', '50')
run('color', '255', '0', '1')
run('input', 'on', 'NaN')
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
callbacks.unload(); assert(count() == 0)
dofile(addon_path .. 'ConsoleBGPlus.lua')
run('status'); assert(logs[#logs][2]:find('960x320', 1, true))
config.callback()
run('reset')
assert(saved.pos.x == 32 and saved.extents.x == 1070 and saved.gradient.top == 110)
run('alpha', '0')
for _, object in pairs(objects) do
    if object.texture:find('_mid_', 1, true) then assert(object.alpha == 0) end
end
run('reset')

-- Export actual layout geometry for the offline renderer.
local layout = require('cbg_layout')
local pieces = layout.build(saved, {width = 1920, height = 1080})
local file = assert(io.open('reference/layout.json', 'w'))
file:write('[')
for index, piece in ipairs(pieces) do
    if index > 1 then file:write(',') end
    file:write(string.format('{"texture":"%s","x":%d,"y":%d,"width":%d,"height":%d,"alpha":%d,"repeat_x":%.6f,"repeat_y":%.6f}',
        piece.texture, piece.x, piece.y, piece.width, piece.height, piece.alpha,
        piece.repeat_x, piece.repeat_y))
end
file:write(']'); file:close()
callbacks.unload(); assert(count() == 0)
print('PASS: show/hide, idle rendering, preview, validation, saved settings, resizing, input divider, reset, and unload cleanup.')
