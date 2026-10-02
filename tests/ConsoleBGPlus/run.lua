-- Run from the Lua repository root: lua tests/ConsoleBGPlus/run.lua
-- Exercises the addon against a minimal Windower API, not a game client.
local addon_path = 'addons/ConsoleBGPlus/'
package.path = addon_path .. '?.lua;' .. package.path
local callbacks, objects, text_objects, saved, logs = {}, {}, {}, nil, {}
local console_open, screen_width, screen_height = false, 1920, 1080
local visibility_calls, geometry_calls = 0, 0
local save_calls, positions, console_writes = 0, {}, 0
local diagnostic_files, fail_diagnostics = {}, false
local real_open = io.open
-- Keep diagnostic I/O deterministic, including open failures. PNG files
-- still use the real filesystem and must contain valid image bytes.
io.open = function(path, mode)
    if path == addon_path .. 'data/diagnostics.txt' or path == addon_path .. 'data/visibility.log' then
        if fail_diagnostics then return nil, 'simulated write failure' end
        assert(mode == 'w')
        local output = {text = '', closed = false, flushes = 0}
        function output:write(...)
            assert(not self.closed)
            for _, value in ipairs({...}) do self.text = self.text .. value end
            return self
        end
        function output:flush() self.flushes = self.flushes + 1; return true end
        function output:close() self.closed = true; return true end
        diagnostic_files[path] = output
        return output
    end
    return real_open(path, mode)
end
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
function config.save(settings) saved = copy(settings); save_calls = save_calls + 1 end
function config.register(settings, fn) config.callback = fn; return 'test-registration' end
function config.unregister(settings, registration) assert(registration == 'test-registration') end
package.preload.config = function() return config end

windower = {
    addon_path = addon_path,
    console = {visible = function() return console_open end,
        set_position = function(x, y) positions[#positions + 1] = {x = x, y = y} end,
        write = function() console_writes = console_writes + 1 end},
    prim = {},
    text = {},
    get_windower_settings = function()
        return {ui_x_res = screen_width, ui_y_res = screen_height, hook_version = 'mock-hook',
            future_setting = 'must not be copied as a value'}
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
    return math.ceil(#object.text * object.size * 0.8), math.ceil(object.size * 1.4)
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
local function mouse(kind, x, y, blocked) return callbacks.mouse(kind, x, y, 0, blocked) end
local function rectangle()
    local top, bottom, right
    for _, object in pairs(objects) do
        if object.texture:find('_top_left.png', 1, true) then top = object end
        if object.texture:find('_bottom_left.png', 1, true) then bottom = object end
        if object.texture:find('_top_right.png', 1, true) then right = object end
    end
    return {x = top.x, y = top.y, width = right.x + right.width - top.x,
        height = bottom.y + bottom.height - top.y}
end

dofile(addon_path .. 'ConsoleBGPlus.lua')
assert(count() > 10 and count() <= 199)
run('status'); assert(logs[#logs][2]:find('1856x348 (screen width)', 1, true))
assert(positions[#positions].x == 32 and positions[#positions].y == 16)
assert(text_objects.ConsoleBGPlus_label_title.font == 'Verdana')
assert(not text_objects.ConsoleBGPlus_label_input.visible)
all_visible(false)
console_open = true; tick(); all_visible(true)
local calls = visibility_calls
local geometry = geometry_calls
local native_calls = #positions
for _ = 1, 60 do tick() end
assert(visibility_calls == calls and geometry_calls == geometry,
    'An unchanged frame should not redraw its primitives on every tick')
assert(#positions == native_calls, 'An unchanged frame must not rewrite console position')
console_open = false; tick(); all_visible(false)
run('preview', 'on'); all_visible(true)
run('preview', 'off'); all_visible(false)

run('position', '16', '24')
run('size', '960', '320')
run('gradient', '80', '230')
assert(saved.pos.x == 16 and saved.pos.y == 24)
assert(saved.extents.x == 960 and saved.extents.y + saved.input.padding == 320)
assert(saved.gradient.top == 80 and saved.gradient.bottom == 230)
local old_count = count()
run('input', 'on', '26'); assert(count() == old_count + 6 and saved.input.enabled)
run('preview', 'on'); assert(text_objects.ConsoleBGPlus_label_input.visible)
run('tab', 'right')
local right_tab_x = text_objects.ConsoleBGPlus_label_input.x
run('tab', 'left'); assert(text_objects.ConsoleBGPlus_label_input.x < right_tab_x)
run('tab', 'right'); assert(text_objects.ConsoleBGPlus_label_input.x == right_tab_x)
run('preview', 'off')
run('input', 'off'); assert(count() == old_count and not saved.input.enabled)
assert(not text_objects.ConsoleBGPlus_label_input.visible)

-- Mouse ownership: regular play/body clicks/wheel events pass through.
console_open = true; tick()
local r = rectangle()
assert(not mouse(1, r.x + 30, r.y + 2))
run('edit', 'on')
assert(text_objects.ConsoleBGPlus_label_edit.visible)
assert(not mouse(1, r.x + 30, r.y + 2, true))
assert(not mouse(1, r.x + 100, r.y + 100))
assert(not mouse(3, r.x + 30, r.y + 2))
assert(not mouse(1, r.x - 1, r.y + 2))
local saves_before_drag = save_calls
assert(mouse(1, r.x + 30, r.y + 2))
assert(mouse(0, r.x + 110, r.y + 62))
assert(save_calls == saves_before_drag, 'Dragging must not write XML on every mouse move')
assert(positions[#positions].x == r.x + 80 and positions[#positions].y == r.y + 60)
assert(mouse(2, -10, -10))
assert(save_calls == saves_before_drag + 1 and saved.pos.x == r.x + 80 and saved.pos.y == r.y + 60)

r = rectangle()
assert(mouse(1, r.x + r.width - 8, r.y + r.height - 8))
assert(mouse(0, r.x + r.width + 72, r.y + r.height + 32))
assert(mouse(2, 0, 0))
assert(saved.extents.x == r.width + 80 and saved.extents.y + saved.input.padding == r.height + 40)
assert(saved.extents.mode == 'fixed')
-- Resize clamping and a blocked release must leave no stuck drag.
r = rectangle()
assert(mouse(1, r.x + r.width - 8, r.y + r.height - 8))
assert(mouse(0, 100000, 100000))
assert(not mouse(2, 100000, 100000, true))
assert(not mouse(0, 0, 0))
r = rectangle()
assert(r.x + r.width <= screen_width and r.y + r.height <= screen_height)

run('position', '16', '24'); run('size', '960', '320')
run('console', 'off')
native_calls = #positions
run('position', '20', '28')
assert(#positions == native_calls, 'Unlinked movement must leave the native console alone')
run('offset', '5', '-3'); run('console', 'on')
assert(positions[#positions].x == 25 and positions[#positions].y == 25)
run('offset', '0', '0'); run('position', '16', '24')
run('edit', 'off'); assert(not text_objects.ConsoleBGPlus_label_edit.visible)

run('input', 'on', '8')
assert(saved.input.height == 8, 'Values below the former 12-pixel limit should work')
run('tab', 'left'); run('preview', 'on')
assert(text_objects.ConsoleBGPlus_label_input.visible)
r = rectangle()
assert(text_objects.ConsoleBGPlus_label_input.x + 30 < r.x + 50,
    'The compact left label should fit before the native console text inset')
run('label', '$'); assert(text_objects.ConsoleBGPlus_label_input.text == '$')
run('tabstyle', 'native'); assert(text_objects.ConsoleBGPlus_label_input.stroke == 0)
run('labelfont', 'Meiryo'); assert(text_objects.ConsoleBGPlus_label_title.font == 'Meiryo')
run('labelsize', '8', '10'); assert(text_objects.ConsoleBGPlus_label_input.visible)
run('labeloffset', '-1')
run('label', 'Input'); run('labelfont', 'Verdana'); run('labelsize', '8', '7')
run('labeloffset', '-2'); run('tabstyle', 'red'); run('input', 'off'); run('preview', 'off')
run('border', 'link'); run('gradient', '0', '255')
for _, object in pairs(objects) do
    if object.texture:find('_top_left.png', 1, true) then assert(object.alpha == 0) end
    if object.texture:find('_bottom_left.png', 1, true) then assert(object.alpha == 240) end
end
assert(text_objects.ConsoleBGPlus_label_title.alpha == 0)
run('alpha', '0')
for _, object in pairs(objects) do assert(object.alpha == 0) end
assert(text_objects.ConsoleBGPlus_label_title.alpha == 0 and text_objects.ConsoleBGPlus_label_input.alpha == 0)
run('alpha', '255'); run('gradient', '80', '230'); run('border', 'free')

-- Diagnostics capture explicit configuration and visibility, never console
-- text. A trace must stay quiet on idle frames and close on stop/unload.
run('diagnose')
local report = diagnostic_files[addon_path .. 'data/diagnostics.txt']
assert(report.closed and report.text:find('hook_version=mock-hook', 1, true))
assert(report.text:find('future_setting', 1, true) and not report.text:find('must not be copied', 1, true))
assert(report.text:find('native_position_written=16,24', 1, true))
run('trace', 'on')
local trace = diagnostic_files[addon_path .. 'data/visibility.log']
local trace_size = #trace.text
for _ = 1, 60 do tick() end
assert(#trace.text == trace_size, 'Idle tracing should not append duplicate samples')
console_open = false; tick()
assert(trace.text:find('console_visible=false frame_visible=false', 1, true))
console_open = true; tick()
assert(#trace.text > trace_size and console_writes == 0)
run('trace', 'off'); assert(trace.closed)
fail_diagnostics = true; run('diagnose'); assert(logs[#logs][1] == 123)
run('trace', 'on'); assert(logs[#logs][1] == 123)
fail_diagnostics = false

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
run('inputpad', '33')
run('labeloffset', '-13')
run('console', 'sometimes')
run('offset', 'NaN', '0')
assert(saved.extents.x == before.extents.x and saved.gradient.top == before.gradient.top)
assert(saved.pos.x == before.pos.x and saved.bg.red == before.bg.red)
assert(logs[#logs][1] == 123)

console_open = true; tick()
screen_width, screen_height = 640, 240; tick()
for _, object in pairs(objects) do
    assert(object.x >= 0 and object.y >= 0)
    assert(object.x + object.width <= screen_width and object.y + object.height <= screen_height)
end
assert(saved.extents.x == 960 and saved.extents.y + saved.input.padding == 320,
    'Clipping to a smaller viewport must not overwrite saved geometry')
screen_width, screen_height = 1920, 1080; tick()
run('status'); assert(logs[#logs][2]:find('960x320', 1, true))
callbacks.unload(); assert(count() == 0 and next(text_objects) == nil)
-- A v0.1.0 settings file retains the user's colors/position while new
-- fields receive their defaults from Windower's config library.
saved.extents.mode, saved.glow, saved.input.tab = nil, nil, nil
saved.input.padding, saved.labels, saved.console, saved.border.linked = nil, nil, nil, nil
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
    local title_width = windower.text.get_extents('ConsoleBGPlus_label_title')
    local input_width, input_height = windower.text.get_extents('ConsoleBGPlus_label_input')
    local pieces = layout.build(saved, viewport, title_width, input_width,
        text_objects.ConsoleBGPlus_label_edit.visible, input_height)
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
            file:write(string.format('{"text":"%s","x":%d,"y":%d,"size":%d,"red":%d,"green":%d,"blue":%d,"alpha":%d,"stroke":%d}',
                object.text, object.x, object.y, object.size, object.red, object.green, object.blue,
                object.alpha, object.stroke))
            first = false
        end
    end
    file:write(']}'); file:close()
end
run('position', '0', '0'); run('input', 'on', '14')
console_open = true; tick()
export('reference/layout.json', {width = 1920, height = 1080})
run('size', '1070', '348')
export('reference/layout_fixed.json', {width = 1920, height = 1080})
run('glow', '0')
export('reference/layout_no_glow.json', {width = 1920, height = 1080})
run('edit', 'on')
export('reference/layout_edit.json', {width = 1920, height = 1080})
run('edit', 'off'); run('border', 'link')
export('reference/layout_linked.json', {width = 1920, height = 1080})
run('reset'); run('input', 'on')
for _, viewport in ipairs({{width=120,height=40}, {width=80,height=30}, {width=1,height=1}, {width=640,height=240}, {width=3840,height=2160}}) do
    local pieces = layout.build(saved, viewport, 40, 25, true)
    for _, piece in ipairs(pieces) do
        assert(piece.x >= 0 and piece.y >= 0)
        assert(piece.x + piece.width <= viewport.width and piece.y + piece.height <= viewport.height,
            'Every frame piece must fit even a small viewport')
    end
end
callbacks.unload(); assert(count() == 0 and next(text_objects) == nil)

-- Older API builds may provide the command setter instead of the Lua
-- method. The fallback must still apply position once and remain idle.
local queued = {}
windower.console.set_position = nil
windower.send_command = function(value) queued[#queued + 1] = value end
dofile(addon_path .. 'ConsoleBGPlus.lua')
assert(queued[1] == 'console_position 32 16')
for _ = 1, 60 do tick() end
assert(#queued == 1)
run('trace', 'on')
trace = diagnostic_files[addon_path .. 'data/visibility.log']
callbacks.unload(); assert(trace.closed and count() == 0 and next(text_objects) == nil)
io.open = real_open
print('PASS: mouse ownership, linked dragging, release-only saves, resize bounds, diagnostics/trace, font/tab controls, legacy settings, idle rendering, API fallback, and unload cleanup.')
