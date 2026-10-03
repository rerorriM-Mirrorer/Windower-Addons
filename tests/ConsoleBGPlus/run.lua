-- Run from the Lua repository root: lua tests/ConsoleBGPlus/run.lua
-- Exercises the addon against a minimal Windower API, not a game client.
local addon_path = 'addons/ConsoleBGPlus/'
package.path = addon_path .. '?.lua;' .. package.path
local callbacks, objects, text_objects, saved, logs = {}, {}, {}, nil, {}
local console_open, screen_width, screen_height = false, 1920, 1080
local visibility_calls, geometry_calls = 0, 0
local save_calls, positions, console_writes = 0, {}, 0
local diagnostic_files, fail_diagnostics = {}, false
local render_frame, style_calls, measurement_calls = 0, 0, 0
local render_latency = 2
local test_seconds, fake_log_size, log_polls = 0, nil, 0
package.preload.socket = function() return {gettime = function() return test_seconds end} end
local real_open = io.open
-- Keep diagnostic I/O deterministic, including open failures. PNG files
-- still use the real filesystem and must contain valid image bytes.
io.open = function(path, mode)
    if path == './console.log' and mode == 'rb' then
        log_polls = log_polls + 1
        if not fake_log_size then return nil, 'no console log' end
        return {seek = function(_, whence) assert(whence == 'end'); return fake_log_size end,
            close = function() return true end}
    end
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
local function native_style(name, key, value)
    local object = text_objects[name]
    object[key], object.ready = value, render_frame + render_latency
    style_calls = style_calls + 1
end
function windower.text.set_font(name, value) native_style(name, 'font', value) end
function windower.text.set_font_size(name, value) native_style(name, 'size', value) end
function windower.text.set_text(name, value) native_style(name, 'text', value) end
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
    measurement_calls = measurement_calls + 1
    if not object.visible then return 0, 0 end
    return object.rendered_width or 0, object.rendered_height or 0
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
local function tick(seconds)
    test_seconds = test_seconds + (seconds or 1 / 30)
    callbacks.prerender()
    render_frame = render_frame + 1
    for _, object in pairs(text_objects) do
        if object.visible and render_frame >= object.ready then
            local width_factor = object.font == 'Meiryo' and 0.9 or 0.8
            local height_factor = object.font == 'Meiryo' and 2.4 or 1.4
            object.rendered_width = math.ceil(#object.text * object.size * width_factor)
            object.rendered_height = math.ceil(object.size * height_factor)
        end
    end
end
local function settle() for _ = 1, 16 do tick() end end
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
assert(positions[#positions].x == 82 and positions[#positions].y == 31)
assert(text_objects.ConsoleBGPlus_label_title.font == 'Verdana')
assert(not text_objects.ConsoleBGPlus_label_input.visible)
all_visible(false)
console_open = true; tick(); all_visible(true)
settle()
local title = text_objects.ConsoleBGPlus_label_title
local title_left, title_right
for _, object in pairs(objects) do
    if object.texture:find('_title_left.png', 1, true) then title_left = object end
    if object.texture:find('_title_right.png', 1, true) then title_right = object end
end
assert(title_left and title_right and title.x < title_left.x + title_left.width
    and title.x + title.rendered_width > title_right.x
    and title.y == 10, 'Title text should float over both end caps and sit two pixels higher')
local calls = visibility_calls
local geometry = geometry_calls
local styles, measurements = style_calls, measurement_calls
local native_calls = #positions
for _ = 1, 60 do tick() end
assert(visibility_calls == calls and geometry_calls == geometry,
    'An unchanged frame should not redraw its primitives on every tick')
assert(#positions == native_calls, 'An unchanged frame must not rewrite console position')
assert(style_calls == styles and measurement_calls == measurements,
    'Settled labels must not reset fonts or poll native measurements on idle frames')
console_open = false; tick(); all_visible(false)
run('diagnose')
local hidden_report = diagnostic_files[addon_path .. 'data/diagnostics.txt'].text
assert(hidden_report:find('title_label=45x12 (measured)', 1, true)
    and hidden_report:find('title_native_bounds=0x0', 1, true),
    'A hidden zero must not overwrite the retained positive title bounds')
run('preview', 'on'); all_visible(true)
run('preview', 'off'); all_visible(false)

run('position', '16', '24')
run('size', '960', '320')
run('gradient', '80', '230')
assert(saved.pos.x == 16 and saved.pos.y == 24)
assert(saved.extents.x == 960 and saved.extents.y + saved.input.padding == 320)
assert(saved.gradient.top == 80 and saved.gradient.bottom == 230)
local old_count = count()
run('input', 'on', '26'); assert(count() == old_count + 3 and saved.input.enabled)
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
assert(positions[#positions].x == r.x + 130 and positions[#positions].y == r.y + 75)
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
settle()
local function plaque()
    local left, right
    for _, object in pairs(objects) do
        if object.texture:find('_tab_left.png', 1, true) then left = object end
        if object.texture:find('_tab_right.png', 1, true) then right = object end
    end
    return left and {x = left.x, y = left.y, width = right.x + right.width - left.x, height = left.height}
end
run('label', 'Input'); settle()
assert(plaque().width == 53 and plaque().height == 24,
    'The native plaque should fit rendered Meiryo text without extra vertical padding')
run('label', '$'); settle(); assert(plaque().width == 17)
render_latency = 7
run('label', 'Input'); settle(); assert(plaque().width == 53,
    'Changing $ back to Input must recover the new size without a second command')
render_latency = 2
-- Reopening and unrelated commands while hidden keep the last good bounds.
run('preview', 'off'); console_open = false; tick()
run('position', '17', '24'); assert(plaque().width == 53)
run('preview', 'on'); settle(); assert(plaque().width == 53)
run('tabstyle', 'red'); settle(); assert(not plaque(), 'Red mode should have no plaque primitives')
local with_divider = count()
local input_x, input_y = text_objects.ConsoleBGPlus_label_input.x, text_objects.ConsoleBGPlus_label_input.y
run('divider', 'off')
assert(count() == with_divider - 3 and text_objects.ConsoleBGPlus_label_input.visible)
assert(text_objects.ConsoleBGPlus_label_input.x == input_x and text_objects.ConsoleBGPlus_label_input.y == input_y,
    'Hiding the divider must preserve the input label anchor')
run('divider', 'on'); assert(count() == with_divider)
run('position', '16', '24')
run('labeloffset', '-1')
run('label', 'Input'); run('labelfont', 'Verdana'); run('labelsize', '8', '7')
run('labeloffset', '-2'); run('tabstyle', 'red'); run('input', 'off'); run('preview', 'off')
run('preview', 'on')
run('border', 'link'); run('gradient', '0', '255')
for _, object in pairs(objects) do
    if object.texture:find('_top_left.png', 1, true) then assert(object.alpha == 0) end
    if object.texture:find('_bottom_left.png', 1, true) then assert(object.alpha == 240) end
end
assert(text_objects.ConsoleBGPlus_label_title.alpha == 0)
run('alpha', '0')
for _, object in pairs(objects) do assert(object.alpha == 0) end
assert(text_objects.ConsoleBGPlus_label_title.alpha == 0 and text_objects.ConsoleBGPlus_label_input.alpha == 0)
run('alpha', '255'); run('gradient', '80', '230'); run('border', 'free'); run('preview', 'off')

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
run('divider', 'sometimes')
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
saved.input.padding, saved.input.divider, saved.labels, saved.console, saved.native,
    saved.border.linked, saved.activity = nil, nil, nil, nil, nil, nil, nil
dofile(addon_path .. 'ConsoleBGPlus.lua')
run('status'); assert(logs[#logs][2]:find('1888x320 (screen width)', 1, true))
assert(logs[#logs][2]:find('gradient 80 to 230', 1, true))
config.callback()
run('reset')
assert(saved.pos.x == 32 and saved.extents.x == 1070 and saved.extents.mode == 'screen' and saved.gradient.top == 100)
assert(saved.gradient.bottom == 250 and saved.glow.alpha == 200 and saved.glow.height == 24)
assert(saved.console.offset_x == 50 and saved.console.offset_y == 15 and saved.input.divider)
assert(saved.activity.enabled == false and saved.activity.delay_ms == 1000
    and saved.activity.fade_ms == 1000 and saved.native.font == 'Verdana')
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
console_open = true; tick(); settle()
export('reference/layout.json', {width = 1920, height = 1080})
run('size', '1070', '348')
export('reference/layout_fixed.json', {width = 1920, height = 1080})
run('glow', '0')
export('reference/layout_no_glow.json', {width = 1920, height = 1080})
run('edit', 'on')
export('reference/layout_edit.json', {width = 1920, height = 1080})
run('edit', 'off'); run('border', 'link')
export('reference/layout_linked.json', {width = 1920, height = 1080})
run('glow', '200', '24'); run('tabstyle', 'native'); settle()
export('reference/layout_native.json', {width = 1920, height = 1080})
run('tabstyle', 'red'); run('divider', 'off'); settle()
export('reference/layout_plain.json', {width = 1920, height = 1080})
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
assert(queued[1] == 'console_position 82 31')
assert(queued[2] == 'console_font Verdana 12'
    and queued[3] == 'console_color 255 250 250 250'
    and queued[4] == 'console_fadedelay 1000'
    and queued[5] == 'console_displayactivity 1'
    and queued[6] == 'console_log 0', 'Loading should establish the complete native profile')
for _ = 1, 60 do tick() end
assert(#queued == 6, 'Idle frames must not rewrite the native profile')
run('nativefont', 'Trebuchet', 'MS', '11')
assert(saved.native.font == 'Trebuchet MS' and saved.native.size == 11
    and queued[#queued - 4] == 'console_font "Trebuchet MS" 11')
run('nativecolor', '255', '230', '231', '232')
assert(saved.native.red == 230 and queued[#queued - 3] == 'console_color 255 230 231 232')
run('trace', 'on')
trace = diagnostic_files[addon_path .. 'data/visibility.log']
callbacks.unload(); assert(trace.closed and count() == 0 and next(text_objects) == nil)

-- Reproduce the user's Hook behavior: native text appears on a log append
-- while console.visible() stays false. A watcher starts at EOF and checks
-- byte counts, then fades without parsing text or claiming keyboard focus.
assert(require('cbg_activity').new('C:\\Windower4\\Addons\\ConsoleBGPlus\\').path
    == 'C:/Windower4/console.log', 'Resolve the live Windows addon path to its console log')
windower.console.set_position = function(x, y) positions[#positions + 1] = {x = x, y = y} end
saved, fake_log_size, console_open = nil, nil, false
dofile(addon_path .. 'ConsoleBGPlus.lua')
assert(queued[#queued] == 'console_log 0')
run('input', 'on', '14')
local inactive_polls = log_polls
for _ = 1, 30 do tick() end
assert(log_polls == inactive_polls and not text_objects.ConsoleBGPlus_label_title.visible,
    'Log watching must be opt-in, with no reads while disabled')
run('activity', 'on')
assert(queued[#queued] == 'console_log 1')
run('fade', '3000', '450')
fake_log_size = 10000; tick(0.16)
assert(not text_objects.ConsoleBGPlus_label_title.visible,
    'An existing log must start at EOF rather than replaying old output')
fake_log_size = 10014; tick(0.16)
assert(text_objects.ConsoleBGPlus_label_title.visible)
assert(not text_objects.ConsoleBGPlus_label_input.visible,
    'Automatic output must not imply typing focus or show the input label')
for _, object in pairs(objects) do
    if object.texture:find('_divider_', 1, true) then assert(not object.visible) end
end
local top_name = 'ConsoleBGPlus_1'
local original_alpha = objects[top_name].alpha
local original_title_alpha = text_objects.ConsoleBGPlus_label_title.alpha
tick(3.25)
assert(text_objects.ConsoleBGPlus_label_title.visible)
assert(objects[top_name].alpha > 0 and objects[top_name].alpha < original_alpha,
    'Automatic output should gradually fade after the hold period')
assert(text_objects.ConsoleBGPlus_label_title.alpha > 0
    and text_objects.ConsoleBGPlus_label_title.alpha < original_title_alpha,
    'The title must fade with the border and fill')
tick(0.3)
assert(not text_objects.ConsoleBGPlus_label_title.visible)
fake_log_size = 25; tick(0.16)
assert(not text_objects.ConsoleBGPlus_label_title.visible,
    'Truncating or replacing the log must set a new baseline')
fake_log_size = 30; tick(0.16)
assert(text_objects.ConsoleBGPlus_label_title.visible)
console_open = true; tick(0.01)
assert(text_objects.ConsoleBGPlus_label_input.visible and objects[top_name].alpha == original_alpha,
    'Manual opening always shows the input and full-strength frame')
console_open = false; tick(0.01)
assert(not text_objects.ConsoleBGPlus_label_title.visible,
    'Closing the manual console must not keep the prior command frame open')
run('activity', 'off')
assert(queued[#queued] == 'console_log 0')
fake_log_size = 40; tick(0.16)
assert(not text_objects.ConsoleBGPlus_label_title.visible)
run('activity', 'on'); tick(0.16)
assert(queued[#queued] == 'console_log 1')
assert(not text_objects.ConsoleBGPlus_label_title.visible,
    'Re-enabling must baseline the current file, not play missed lines')
run('fade', '2000', '600')
assert(saved.activity.delay_ms == 2000 and saved.activity.fade_ms == 600)
assert(queued[#queued] == 'console_fadedelay 2000')
local queued_before_character_change = #queued
config.callback()
assert(#queued == queued_before_character_change + 5
    and queued[#queued - 2] == 'console_fadedelay 2000'
    and queued[#queued] == 'console_log 1',
    'A per-character setting change must reapply the saved native profile')
run('diagnose')
assert(diagnostic_files[addon_path .. 'data/diagnostics.txt'].text:find('activity_available=true', 1, true))
callbacks.unload(); assert(count() == 0 and next(text_objects) == nil)
dofile(addon_path .. 'ConsoleBGPlus.lua')
assert(queued[#queued - 2] == 'console_fadedelay 2000'
    and queued[#queued] == 'console_log 1',
    'The native profile should be restored after reload')
callbacks.unload()
io.open = real_open
print('PASS: title caps and position, native console profile/load/reload, delayed/hidden label bounds, automatic tab resizing, text-only red style, optional divider, log growth, no replay, fade/manual focus, rotation, mouse ownership, linked dragging, release-only saves, resize bounds, diagnostics/trace, legacy settings, idle rendering, API fallback, and unload cleanup.')
