-- ConsoleBG+ is derived from ConsoleBG by StarHawk, Copyright 2015 Windower.
-- Redistribution terms and the XIVParty texture notice are in LICENSE.txt.
_addon.name = 'ConsoleBGPlus'
_addon.author = 'StarHawk; ConsoleBG+ contributors'
_addon.version = '0.1.2'
_addon.commands = {'consolebgplus', 'cbgplus', 'cbg'}

local config = require('config')
local layout = require('cbg_layout')
local skin = require('cbg_skin')
local diagnostics = require('cbg_diagnostics')
local defaults = {
    bg = {alpha = 255, red = 255, green = 255, blue = 255},
    pos = {x = 32, y = 16},
    extents = {x = 1070, y = 344, mode = 'screen'},
    gradient = {top = 110, bottom = 235},
    border = {alpha = 240, linked = false},
    glow = {alpha = 36, height = 24},
    input = {enabled = false, height = 14, padding = 4, tab = 'left'},
    labels = {font = 'Verdana', title_size = 8, input_size = 7,
        input_text = 'Input', input_style = 'red', offset_y = -2},
    console = {linked = true, offset_x = 0, offset_y = 0},
}
local settings = config.load(defaults)
local primitives, shown, preview, editing = {}, false, false, false
local last_viewport, actual_rectangle = nil, nil
local labels = {}
local drag, native_position, position_warning = nil, nil, false
local position_dirty = true
local frame = 0
local recorder = diagnostics.new(windower.addon_path, _addon.version)

local function message(text, is_error)
    windower.add_to_chat(is_error and 123 or 207, '[ConsoleBG+] ' .. text)
end

local textures, texture_error = skin.prepare(windower.addon_path)
if not textures then
    message('Could not prepare the frame textures: ' .. tostring(texture_error), true)
    return
end

local function viewport()
    local value = windower.get_windower_settings() or {}
    return {
        width = tonumber(value.ui_x_res or value.x_res) or 1920,
        height = tonumber(value.ui_y_res or value.y_res) or 1080,
    }
end

local function visibility(visible)
    for _, primitive in ipairs(primitives) do
        windower.prim.set_visibility(primitive.name, visible)
    end
    for _, label in pairs(labels) do
        windower.text.set_visibility(label.name, visible and label.enabled)
    end
    shown = visible
end

local function new_label(key, text, size, red, green, blue, stroke)
    local name = 'ConsoleBGPlus_label_' .. key
    windower.text.create(name)
    windower.text.set_visibility(name, false)
    windower.text.set_font(name, 'Verdana')
    windower.text.set_font_size(name, size)
    windower.text.set_text(name, text)
    windower.text.set_italic(name, true)
    windower.text.set_bold(name, true)
    windower.text.set_right_justified(name, false)
    windower.text.set_bg_visibility(name, false)
    windower.text.set_bg_border_size(name, 0)
    windower.text.set_color(name, 240, red, green, blue)
    windower.text.set_stroke_width(name, stroke)
    windower.text.set_stroke_color(name, 220, 15, 14, 28)
    labels[key] = {name = name, enabled = false}
end

new_label('title', 'Console', 8, 235, 234, 245, 1)
new_label('input', 'Input', 7, 233, 107, 124, 1)
new_label('edit', 'Drag top edge / resize corner', 8, 235, 234, 245, 1)

local function sync_console(rect, screen)
    if settings.console.linked ~= true then return end
    local x = math.max(0, math.min(screen.width - 1, rect.x + settings.console.offset_x))
    local y = math.max(0, math.min(screen.height - 1, rect.y + settings.console.offset_y))
    if not position_dirty and native_position and native_position.x == x and native_position.y == y then return end
    if windower.console.set_position then
        windower.console.set_position(x, y)
    elseif windower.send_command then
        windower.send_command('console_position ' .. x .. ' ' .. y)
    else
        if not position_warning then message('Console position API unavailable; only the frame can move.', true) end
        position_warning = true
        return
    end
    native_position = {x = x, y = y}
    position_dirty = false
end

local function style_labels()
    for _, key in ipairs({'title', 'input'}) do
        local label = labels[key]
        windower.text.set_font(label.name, settings.labels.font)
        windower.text.set_font_size(label.name, settings.labels[key .. '_size'])
    end
    windower.text.set_text(labels.input.name, settings.labels.input_text)
    local native = settings.labels.input_style == 'native'
    windower.text.set_stroke_width(labels.input.name, native and 0 or 1)
    labels.input.red, labels.input.green, labels.input.blue = native and 25 or 233,
        native and 24 or 107, native and 43 or 124
end

local function refresh(screen)
    screen = screen or viewport()
    style_labels()
    local title_width, title_height = windower.text.get_extents(labels.title.name)
    local input_width, input_height = windower.text.get_extents(labels.input.name)
    local pieces
    pieces, actual_rectangle = layout.build(settings, screen, title_width, input_width, editing, input_height)
    for index, piece in ipairs(pieces) do
        local primitive = primitives[index]
        if not primitive then
            primitive = {name = 'ConsoleBGPlus_' .. index}
            windower.prim.create(primitive.name)
            windower.prim.set_visibility(primitive.name, false)
            windower.prim.set_fit_to_texture(primitive.name, false)
            primitives[index] = primitive
        end
        if primitive.texture ~= piece.texture then
            windower.prim.set_texture(primitive.name, textures[piece.texture])
            primitive.texture = piece.texture
        end
        windower.prim.set_position(primitive.name, piece.x, piece.y)
        windower.prim.set_size(primitive.name, piece.width, piece.height)
        windower.prim.set_repeat(primitive.name, piece.repeat_x, piece.repeat_y)
        windower.prim.set_color(primitive.name, piece.alpha, piece.red, piece.green, piece.blue)
        windower.prim.set_visibility(primitive.name, shown)
    end
    for index = #primitives, #pieces + 1, -1 do
        windower.prim.delete(primitives[index].name)
        primitives[index] = nil
    end
    local title = labels.title
    local rect = actual_rectangle
    title.enabled = rect.title_slot ~= nil and screen.height >= title_height
    windower.text.set_color(title.name, rect.title_alpha, 235, 234, 245)
    windower.text.set_stroke_color(title.name, rect.title_alpha, 15, 14, 28)
    if rect.title_slot then
        windower.text.set_location(title.name, rect.title_slot.x, rect.title_slot.y)
    end
    windower.text.set_visibility(title.name, shown and title.enabled)
    local input = labels.input
    local tab = rect.input_tab
    input.enabled = tab ~= nil and input_width + 8 <= tab.width and input_height <= tab.height
    windower.text.set_color(input.name, rect.input_alpha, input.red, input.green, input.blue)
    windower.text.set_stroke_color(input.name, rect.input_alpha, 15, 14, 28)
    if tab then
        windower.text.set_location(input.name, tab.x + 4,
            math.max(0, tab.y + math.floor((tab.height - input_height) / 2) + settings.labels.offset_y))
    end
    windower.text.set_visibility(input.name, shown and input.enabled)
    local edit = labels.edit
    local edit_width, edit_height = windower.text.get_extents(edit.name)
    edit.enabled = editing and rect.width >= edit_width + 24 and rect.height >= edit_height + 30
    windower.text.set_location(edit.name, rect.x + 12, rect.y + 12)
    windower.text.set_visibility(edit.name, shown and edit.enabled)
    sync_console(rect, screen)
    last_viewport = screen
end

local function save()
    config.save(settings)
    refresh()
end

local function end_drag()
    if not drag then return end
    local changed = drag.changed
    drag = nil
    if changed then
        save()
        message(string.format('Layout saved: %d,%d, %dx%d.', actual_rectangle.x,
            actual_rectangle.y, actual_rectangle.width, actual_rectangle.height))
    end
end

local function context(console_visible)
    return {
        settings = settings, native_settings = windower.get_windower_settings() or {},
        rectangle = actual_rectangle, viewport = last_viewport, console_visible = console_visible,
        frame_visible = shown, preview = preview, edit = editing, frame = frame,
        native_position = native_position, primitive_count = #primitives,
        position_setter = windower.console.set_position and 'console.set_position'
            or (windower.send_command and 'console_position command' or 'unavailable'),
        label_measurements = {
            title = {width = select(1, windower.text.get_extents(labels.title.name)),
                height = select(2, windower.text.get_extents(labels.title.name))},
            input = {width = select(1, windower.text.get_extents(labels.input.name)),
                height = select(2, windower.text.get_extents(labels.input.name))},
        },
    }
end

local function integer(value, minimum, maximum)
    local number = tonumber(value)
    if not number or number ~= number or number == math.huge or number == -math.huge
        or number % 1 ~= 0 or number < minimum or number > maximum then
        return nil
    end
    return number
end

local function numbers(args, count, minimum, maximum)
    if #args ~= count then return nil end
    local result = {}
    for index = 1, count do
        result[index] = integer(args[index], minimum, maximum)
        if result[index] == nil then return nil end
    end
    return result
end

local function usage(text)
    message('Usage: //cbg ' .. text, true)
end

local aliases = {p = 'position', s = 'size', c = 'color', pos = 'position'}
local function command(action, ...)
    action = (action or 'help'):lower()
    action = aliases[action] or action
    local args = {...}
    end_drag()
    if action == 'position' then
        local value = numbers(args, 2, 0, 32768)
        if not value then return usage('position <x> <y> (nonnegative integers)') end
        settings.pos.x, settings.pos.y = value[1], value[2]
        save()
        message('Position saved: ' .. value[1] .. ', ' .. value[2] .. '.')
    elseif action == 'size' then
        local value = numbers(args, 2, 1, 32768)
        if not value or value[1] < 120 or value[2] < 40 then
            return usage('size <width> <height> (minimum 120 x 40)')
        end
        settings.extents.x, settings.extents.y = value[1], math.max(1, value[2] - settings.input.padding)
        settings.extents.mode = 'fixed'
        save()
        message('Size saved: ' .. value[1] .. ' x ' .. value[2] .. '.')
    elseif action == 'width' then
        if #args ~= 1 then return usage('width screen|<pixels>') end
        if args[1]:lower() == 'screen' then
            settings.extents.mode = 'screen'
        else
            local width = integer(args[1], 120, 32768)
            if not width then return usage('width screen|<pixels> (minimum 120)') end
            settings.extents.x, settings.extents.mode = width, 'fixed'
        end
        save()
        message(settings.extents.mode == 'screen' and 'Width follows the game window with matching side margins.'
            or ('Width saved: ' .. settings.extents.x .. ' pixels.'))
    elseif action == 'gradient' then
        local value = numbers(args, 2, 0, 255)
        if not value then return usage('gradient <top alpha> <bottom alpha> (0-255)') end
        settings.gradient.top, settings.gradient.bottom = value[1], value[2]
        save()
        message('Gradient saved: top ' .. value[1] .. ', bottom ' .. value[2] .. '.')
    elseif action == 'glow' then
        local alpha = args[1] and integer(args[1], 0, 255)
        local height = args[2] and integer(args[2], 4, 128)
        if #args < 1 or #args > 2 or not alpha or (args[2] and not height) then
            return usage('glow <alpha 0-255> [height 4-128]')
        end
        settings.glow.alpha = alpha
        if height then settings.glow.height = height end
        save()
        message('Bottom glow saved: ' .. alpha .. ' over ' .. settings.glow.height .. ' pixels.')
    elseif action == 'border' and #args == 1 and (args[1]:lower() == 'link' or args[1]:lower() == 'free') then
        settings.border.linked = args[1]:lower() == 'link'
        save()
        message(settings.border.linked and 'Borders and labels follow the background gradient.'
            or 'Border opacity is independent of the background gradient.')
    elseif action == 'alpha' or action == 'border' then
        local value = numbers(args, 1, 0, 255)
        if not value then return usage(action .. ' <alpha> (0-255)') end
        if action == 'alpha' then settings.bg.alpha = value[1]
        else settings.border.alpha = value[1] end
        save()
        message(action .. ' opacity saved: ' .. value[1] .. '.')
    elseif action == 'color' then
        local value = numbers(args, 4, 0, 255)
        if not value then return usage('color <alpha> <red> <green> <blue> (0-255)') end
        settings.bg.alpha, settings.bg.red, settings.bg.green, settings.bg.blue =
            value[1], value[2], value[3], value[4]
        save()
        message('Texture tint saved. Use color 255 255 255 255 for the original colors.')
    elseif action == 'input' then
        local mode = args[1] and args[1]:lower()
        local height = args[2] and integer(args[2], 6, 256) or nil
        if #args < 1 or #args > 2 or (mode ~= 'on' and mode ~= 'off')
            or (args[2] and not height) then
            return usage('input on|off [height in pixels, 6-256]')
        end
        settings.input.enabled = mode == 'on'
        if height then settings.input.height = height end
        save()
        message('Input strip and tab ' .. mode .. ' (shown with the console).')
    elseif action == 'inputpad' then
        local value = numbers(args, 1, 0, 32)
        if not value then return usage('inputpad <bottom padding 0-32>') end
        settings.input.padding = value[1]
        save()
        message('Extra bottom padding saved: ' .. value[1] .. ' pixels.')
    elseif action == 'tab' then
        local side = args[1] and args[1]:lower()
        if #args ~= 1 or (side ~= 'left' and side ~= 'right') then return usage('tab left|right') end
        settings.input.tab = side
        save()
        message('Input tab placed on the ' .. side .. '.')
    elseif action == 'tabstyle' then
        local style = args[1] and args[1]:lower()
        if #args ~= 1 or (style ~= 'red' and style ~= 'native') then return usage('tabstyle red|native') end
        settings.labels.input_style = style
        save()
        message('Input label style saved: ' .. style .. '.')
    elseif action == 'label' or action == 'labelfont' then
        local value = table.concat(args, ' ')
        local maximum = action == 'label' and 16 or 64
        if #value < 1 or #value > maximum or value:find('%c') then
            return usage(action .. (action == 'label' and ' <input tab text, 1-16 bytes>' or ' <font name>'))
        end
        if action == 'label' then settings.labels.input_text = value
        else settings.labels.font = value end
        save()
        message(action == 'label' and ('Input tab label saved: ' .. value .. '.')
            or ('Frame label font saved: ' .. value .. '. The console font is set separately in Windower.'))
    elseif action == 'labelsize' then
        local value = numbers(args, 2, 6, 16)
        if not value then return usage('labelsize <title size> <input size> (6-16)') end
        settings.labels.title_size, settings.labels.input_size = value[1], value[2]
        save()
        message('Frame label sizes saved.')
    elseif action == 'labeloffset' then
        local value = numbers(args, 1, -12, 12)
        if not value then return usage('labeloffset <input label vertical offset, -12 to 12>') end
        settings.labels.offset_y = value[1]
        save()
        message('Input label offset saved: ' .. value[1] .. ' pixels.')
    elseif action == 'console' then
        local mode = args[1] and args[1]:lower()
        if #args ~= 1 or (mode ~= 'on' and mode ~= 'off') then return usage('console on|off') end
        settings.console.linked = mode == 'on'
        position_dirty = true
        save()
        message(settings.console.linked and 'Console text moves with the frame.' or 'Console movement is independent.')
    elseif action == 'offset' then
        local value = numbers(args, 2, -32768, 32768)
        if not value then return usage('offset <console x offset> <console y offset> (signed pixels)') end
        settings.console.offset_x, settings.console.offset_y = value[1], value[2]
        position_dirty = true
        save()
        message('Console offset saved: ' .. value[1] .. ', ' .. value[2] .. '.')
    elseif action == 'edit' then
        local mode = args[1] and args[1]:lower()
        if #args > 1 or (mode and mode ~= 'on' and mode ~= 'off') then return usage('edit [on|off]') end
        editing = mode and mode == 'on' or (not mode and not editing)
        refresh()
        visibility(preview or editing or windower.console.visible())
        message(editing and 'Edit mode on: drag the top edge; resize the lower-right corner. Release to save.'
            or 'Edit mode off.')
    elseif action == 'diagnose' then
        if #args ~= 0 then return usage('diagnose') end
        refresh()
        local path, err = recorder.snapshot(context(windower.console.visible()))
        message(path and 'Diagnostic snapshot saved to ConsoleBGPlus/data/diagnostics.txt.'
            or ('Could not save diagnostics: ' .. tostring(err)), not path)
    elseif action == 'trace' then
        local mode = args[1] and args[1]:lower()
        if #args ~= 1 or (mode ~= 'on' and mode ~= 'off') then return usage('trace on|off') end
        if mode == 'on' then
            local ok, err = recorder.start(context(windower.console.visible()))
            message(ok and 'Trace on: console/layout changes go to ConsoleBGPlus/data/visibility.log.'
                or ('Could not start trace: ' .. tostring(err)), not ok)
        else
            local ok, err = recorder.stop()
            message(ok and 'Trace off. Visibility log saved.' or ('Could not close trace: ' .. tostring(err)), not ok)
        end
    elseif action == 'preview' then
        local mode = args[1] and args[1]:lower()
        if #args > 1 or (mode and mode ~= 'on' and mode ~= 'off') then
            return usage('preview [on|off]')
        end
        if mode then preview = mode == 'on' else preview = not preview end
        visibility(preview or editing or windower.console.visible())
        message('Preview ' .. (preview and 'on' or 'off') .. '.')
    elseif action == 'reset' then
        if #args ~= 0 then return usage('reset') end
        for group, values in pairs(defaults) do
            for key, value in pairs(values) do settings[group][key] = value end
        end
        position_dirty = true
        save()
        message('Default frame settings restored.')
    elseif action == 'status' then
        if #args ~= 0 then return usage('status') end
        local rect = actual_rectangle
        message(string.format('v%s: drawn at %d,%d, %dx%d (%s width); gradient %d to %d; glow %d; input %s (%d + %d padding); console %s; edit %s; preview %s; trace %s.',
            _addon.version, rect.x, rect.y, rect.width, rect.height,
            settings.extents.mode,
            settings.gradient.top, settings.gradient.bottom,
            settings.glow.alpha,
            settings.input.enabled and 'on' or 'off', settings.input.height, settings.input.padding,
            settings.console.linked and 'linked' or 'free', editing and 'on' or 'off',
            preview and 'on' or 'off', recorder.active and 'on' or 'off'))
    elseif action == 'help' then
        if #args ~= 0 then return usage('help') end
        message('v' .. _addon.version .. ' | //cbg position <x> <y> | size <width> <height>')
        message('//cbg edit [on|off] | console on|off | offset <x> <y>')
        message('//cbg width screen|<pixels> | glow <alpha> [height]')
        message('//cbg gradient <top> <bottom> | alpha <0-255> | border <0-255>|link|free')
        message('//cbg color <alpha> <red> <green> <blue> | input on|off [height] | tab left|right')
        message('//cbg inputpad <0-32> | tabstyle red|native | label <text>')
        message('//cbg labelfont <font> | labelsize <title> <input> | labeloffset <-12 to 12>')
        message('//cbg diagnose | trace on|off. Files go to ConsoleBGPlus/data/.')
        message('//cbg preview [on|off] | status | reset. Changes save to data/settings.xml.')
    else
        message('Unknown command. Use //cbg help.', true)
    end
end

refresh()
local registration = config.register(settings, function()
    drag, position_dirty = nil, true
    refresh()
end)
windower.register_event('addon command', command)
windower.register_event('prerender', function()
    frame = frame + 1
    local console_visible = windower.console.visible()
    local wanted = preview or editing or console_visible
    if wanted then
        local screen = viewport()
        if screen.width ~= last_viewport.width or screen.height ~= last_viewport.height then
            refresh(screen)
        end
    end
    if wanted ~= shown then visibility(wanted) end
    if recorder.active then
        local ok, err = recorder.observe(context(console_visible))
        if err then message('Visibility trace: ' .. tostring(err), true) end
    end
end)
windower.register_event('mouse', function(kind, x, y, delta, blocked)
    -- A release claimed by another addon still ends our own drag.
    if kind == 2 and drag then
        end_drag()
        return not blocked
    end
    if blocked or not editing or not shown then return false end
    if kind == 1 then
        local rect = actual_rectangle
        if x < rect.x or y < rect.y or x >= rect.x + rect.width or y >= rect.y + rect.height then
            return false
        end
        local resize = x >= rect.x + rect.width - 16 and y >= rect.y + rect.height - 16
        if not resize and y >= rect.y + 18 then return false end
        drag = {kind = resize and 'resize' or 'move', x = x, y = y,
            rectangle = {x = rect.x, y = rect.y, width = rect.width, height = rect.height}, changed = false}
        return true
    elseif kind == 0 and drag then
        local dx, dy = math.floor(x - drag.x + 0.5), math.floor(y - drag.y + 0.5)
        if dx == 0 and dy == 0 and not drag.changed then return true end
        local rect, screen = drag.rectangle, viewport()
        local function clamp(value, minimum, maximum)
            return math.max(minimum, math.min(maximum, value))
        end
        if drag.kind == 'resize' then
            local available_width, available_height = math.max(1, screen.width - rect.x),
                math.max(1, screen.height - rect.y)
            settings.pos.x, settings.pos.y = rect.x, rect.y
            settings.extents.x = clamp(rect.width + dx, math.min(120, available_width), available_width)
            local height = clamp(rect.height + dy, math.min(40, available_height), available_height)
            settings.extents.y = math.max(1, height - settings.input.padding)
            settings.extents.mode = 'fixed'
        else
            local maximum_x = settings.extents.mode == 'screen'
                and math.floor((screen.width - math.min(120, screen.width)) / 2)
                or math.max(0, screen.width - rect.width)
            settings.pos.x = clamp(rect.x + dx, 0, maximum_x)
            settings.pos.y = clamp(rect.y + dy, 0, math.max(0, screen.height - rect.height))
        end
        drag.changed = true
        refresh(screen)
        return true
    end
    return false
end)
windower.register_event('unload', function()
    if drag and drag.changed then config.save(settings) end
    drag = nil
    recorder.stop()
    for _, primitive in ipairs(primitives) do windower.prim.delete(primitive.name) end
    primitives = {}
    for _, label in pairs(labels) do windower.text.delete(label.name) end
    labels = {}
    if config.unregister then config.unregister(settings, registration) end
end)
