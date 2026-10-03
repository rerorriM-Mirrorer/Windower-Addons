-- ConsoleBG+ is derived from ConsoleBG by StarHawk, Copyright 2015 Windower.
-- Redistribution terms and the XIVParty texture notice are in LICENSE.txt.
_addon.name = 'ConsoleBGPlus'
_addon.author = 'StarHawk; ConsoleBG+ contributors'
_addon.version = '0.1.5'
_addon.commands = {'consolebgplus', 'cbgplus', 'cbg'}

local config = require('config')
local layout = require('cbg_layout')
local skin = require('cbg_skin')
local diagnostics = require('cbg_diagnostics')
local activity = require('cbg_activity')
local defaults = {
    bg = {alpha = 255, red = 255, green = 255, blue = 255},
    pos = {x = 32, y = 16},
    extents = {x = 1070, y = 344, mode = 'screen'},
    gradient = {top = 100, bottom = 250},
    border = {alpha = 240, linked = false},
    glow = {alpha = 200, height = 24},
    input = {enabled = false, height = 14, padding = 4, tab = 'left', divider = true},
    labels = {font = 'Verdana', title_size = 8, input_size = 7,
        input_text = 'Input', input_style = 'red', offset_y = -2},
    console = {linked = true, offset_x = 50, offset_y = 15},
    native = {font = 'Verdana', size = 12, alpha = 255, red = 250, green = 250, blue = 250},
    activity = {enabled = false, delay_ms = 1000, fade_ms = 1000,
        native_delay_owned = false},
}
local settings = config.load(defaults)
local primitives, shown, preview, editing = {}, false, false, false
local last_viewport, actual_rectangle = nil, nil
local labels = {}
local drag, native_position, position_warning = nil, nil, false
local position_dirty = true
local frame = 0
local recorder = diagnostics.new(windower.addon_path, _addon.version)
local watcher = activity.new(windower.addon_path)
local auto_alpha, draw_alpha, input_shown, manual_was_open = 0, 255, false, false
local measurement_cache, measurement_order = {}, {}

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

local function label_visibility(label, visible)
    if label.visible == visible then return end
    windower.text.set_visibility(label.name, visible)
    label.visible = visible
    if visible then
        -- Hidden text can report 0x0. Keep its previous bounds, then allow
        -- fresh render passes before reading the native measurement again.
        label.pending, label.wait, label.stable = true, 0, 0
    end
end

local function opacity(value)
    return math.floor(value * draw_alpha / 255 + 0.5)
end

local function tint_label(label)
    windower.text.set_color(label.name, opacity(label.base_alpha),
        label.red, label.green, label.blue)
    windower.text.set_stroke_color(label.name, opacity(label.base_stroke), 15, 14, 28)
end

local function apply_alpha(value)
    -- Eight-ish visible fade steps keep a large tiled frame inexpensive.
    local quantized = math.min(255, math.floor(value / 32 + 0.5) * 32)
    if quantized == draw_alpha then return end
    draw_alpha = quantized
    for _, primitive in ipairs(primitives) do
        windower.prim.set_color(primitive.name, opacity(primitive.alpha),
            primitive.red, primitive.green, primitive.blue)
    end
    for _, label in pairs(labels) do tint_label(label) end
end

local function visibility(visible, input_mode)
    input_mode = visible and input_mode or false
    if shown == visible and input_shown == input_mode then return end
    for _, primitive in ipairs(primitives) do
        windower.prim.set_visibility(primitive.name, visible and (input_mode or not primitive.input_only))
    end
    for key, label in pairs(labels) do
        label_visibility(label, visible and label.enabled and (input_mode or key ~= 'input'))
    end
    shown, input_shown = visible, input_mode
end

local function update_visibility()
    local manual = preview or editing or windower.console.visible()
    apply_alpha(manual and 255 or auto_alpha)
    visibility(manual or auto_alpha > 0, manual)
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
    labels[key] = {name = name, enabled = false, visible = false,
        font = 'Verdana', size = size, text = text, stroke = stroke,
        red = red, green = green, blue = blue, base_alpha = 240, base_stroke = 220}
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

local function label_metrics(label)
    local key = table.concat({label.font, label.size, label.text, label.stroke}, '\0')
    if label.measurement_key == key then return end
    label.measurement_key = key
    local cached = measurement_cache[key]
    -- Estimates only cover the first visible render or a new font/text.
    -- Native positive measurements replace them without another command.
    label.width = cached and cached.width or math.max(1, math.ceil(#label.text * label.size * 0.8))
    label.height = cached and cached.height or math.max(1, math.ceil(label.size * 1.8))
    label.source = cached and 'cached' or 'estimated'
    label.pending, label.wait, label.stable = true, 0, 0
end

local function style_labels()
    for _, key in ipairs({'title', 'input'}) do
        local label = labels[key]
        local font, size = settings.labels.font, settings.labels[key .. '_size']
        if label.font ~= font then
            windower.text.set_font(label.name, font)
            label.font = font
        end
        if label.size ~= size then
            windower.text.set_font_size(label.name, size)
            label.size = size
        end
    end
    local input = labels.input
    if input.text ~= settings.labels.input_text then
        windower.text.set_text(input.name, settings.labels.input_text)
        input.text = settings.labels.input_text
    end
    local native = settings.labels.input_style == 'native'
    local stroke = native and 0 or 1
    if input.stroke ~= stroke then
        windower.text.set_stroke_width(input.name, stroke)
        input.stroke = stroke
    end
    input.red, input.green, input.blue = native and 25 or 233,
        native and 24 or 107, native and 43 or 124
    for _, label in pairs(labels) do label_metrics(label) end
end

local function refresh(screen)
    screen = screen or viewport()
    style_labels()
    local title_width, title_height = labels.title.width, labels.title.height
    local input_width, input_height = labels.input.width, labels.input.height
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
        primitive.input_only = piece.texture:find('divider_', 1, true) == 1
            or piece.texture:find('tab_', 1, true) == 1
        primitive.alpha, primitive.red, primitive.green, primitive.blue =
            piece.alpha, piece.red, piece.green, piece.blue
        if primitive.texture ~= piece.texture then
            windower.prim.set_texture(primitive.name, textures[piece.texture])
            primitive.texture = piece.texture
        end
        windower.prim.set_position(primitive.name, piece.x, piece.y)
        windower.prim.set_size(primitive.name, piece.width, piece.height)
        windower.prim.set_repeat(primitive.name, piece.repeat_x, piece.repeat_y)
        windower.prim.set_color(primitive.name, opacity(piece.alpha), piece.red, piece.green, piece.blue)
        windower.prim.set_visibility(primitive.name, shown and (input_shown or not primitive.input_only))
    end
    for index = #primitives, #pieces + 1, -1 do
        windower.prim.delete(primitives[index].name)
        primitives[index] = nil
    end
    local title = labels.title
    local rect = actual_rectangle
    title.enabled = rect.title_slot ~= nil and screen.height >= title_height
    title.base_alpha, title.base_stroke = rect.title_alpha, rect.title_alpha
    tint_label(title)
    if rect.title_slot then
        windower.text.set_location(title.name, rect.title_slot.x, rect.title_slot.y)
    end
    label_visibility(title, shown and title.enabled)
    local input = labels.input
    local tab = rect.input_tab
    input.enabled = tab ~= nil and input_width + 8 <= tab.width and input_height <= tab.height
    input.base_alpha, input.base_stroke = rect.input_alpha, rect.input_alpha
    tint_label(input)
    if tab then
        windower.text.set_location(input.name, tab.x + 4,
            math.max(0, tab.y + math.floor((tab.height - input_height) / 2) + settings.labels.offset_y))
    end
    label_visibility(input, shown and input_shown and input.enabled)
    local edit = labels.edit
    local edit_width, edit_height = edit.width, edit.height
    edit.enabled = editing and rect.width >= edit_width + 24 and rect.height >= edit_height + 30
    windower.text.set_location(edit.name, math.max(rect.x + 12, rect.x + rect.width - edit_width - 16),
        rect.y + 14)
    tint_label(edit)
    label_visibility(edit, shown and edit.enabled)
    sync_console(rect, screen)
    last_viewport = screen
end

local function measure_labels()
    local changed = false
    for _, label in pairs(labels) do
        if label.visible and label.pending then
            label.wait = label.wait + 1
            -- Font/text setters may not have reached the renderer in the
            -- same callback. A hidden zero or stale prior extent never
            -- replaces the layout immediately after a style change.
            if label.wait >= 3 then
                local width, height = windower.text.get_extents(label.name)
                if type(width) == 'number' and type(height) == 'number'
                    and width > 0 and height > 0 and width < 65536 and height < 65536 then
                    width, height = math.ceil(width), math.ceil(height)
                    if width ~= label.width or height ~= label.height then
                        label.width, label.height, label.stable = width, height, 0
                        changed = true
                    else
                        label.stable = label.stable + 1
                    end
                    label.source = 'settling'
                    if label.wait >= 12 and label.stable >= 3 then
                        local key = label.measurement_key
                        if not measurement_cache[key] then
                            measurement_order[#measurement_order + 1] = key
                            if #measurement_order > 64 then
                                measurement_cache[table.remove(measurement_order, 1)] = nil
                            end
                        end
                        measurement_cache[key] = {width = width, height = height}
                        label.source, label.pending = 'measured', false
                    end
                end
            end
            if label.wait >= 60 then label.pending = false end
        end
    end
    if changed then refresh() end
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
    local measurements = {}
    for _, key in ipairs({'title', 'input'}) do
        local label = labels[key]
        local native_width, native_height = windower.text.get_extents(label.name)
        measurements[key] = {width = label.width, height = label.height, source = label.source,
            native_width = native_width, native_height = native_height}
    end
    return {
        settings = settings, native_settings = windower.get_windower_settings() or {},
        rectangle = actual_rectangle, viewport = last_viewport, console_visible = console_visible,
        frame_visible = shown, preview = preview, edit = editing, frame = frame,
        native_position = native_position, primitive_count = #primitives,
        activity = {path = watcher.path, available = watcher.available,
            clock = watcher.clock, changes = watcher.changes, alpha = auto_alpha},
        position_setter = windower.console.set_position and 'console.set_position'
            or (windower.send_command and 'console_position command' or 'unavailable'),
        label_measurements = measurements,
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

local function safe_native_font(name)
    if type(name) ~= 'string' or #name < 1 or #name > 64
        or not name:match('^[%w_][%w_ %-]*$') then return nil end
    return name:find(' ', 1, true) and ('"' .. name .. '"') or name
end

local function sync_native_profile()
    if not windower.send_command then
        settings.activity.native_delay_owned = false
        return false
    end
    local native = settings.native
    local font = safe_native_font(native.font) or defaults.native.font
    local size = integer(native.size, 6, 24) or defaults.native.size
    local function color(key)
        return integer(native[key], 0, 255) or defaults.native[key]
    end
    windower.send_command('console_font ' .. font .. ' ' .. size)
    windower.send_command(string.format('console_color %d %d %d %d',
        color('alpha'), color('red'), color('green'), color('blue')))
    windower.send_command('console_fadedelay ' .. settings.activity.delay_ms)
    windower.send_command('console_displayactivity 1')
    windower.send_command('console_log ' .. (settings.activity.enabled and '1' or '0'))
    settings.activity.native_delay_owned = true
    return true
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
        message('Input label ' .. mode .. ' (shown with the console).')
    elseif action == 'divider' then
        local mode = args[1] and args[1]:lower()
        if #args ~= 1 or (mode ~= 'on' and mode ~= 'off') then return usage('divider on|off') end
        settings.input.divider = mode == 'on'
        save()
        message('Input divider ' .. mode .. '.')
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
    elseif action == 'nativefont' then
        local size = args[#args] and integer(args[#args], 6, 24)
        local font = table.concat(args, ' ', 1, #args - 1)
        if not size or not safe_native_font(font) then
            return usage('nativefont <font name> <size 6-24>')
        end
        settings.native.font, settings.native.size = font, size
        sync_native_profile()
        save()
        message('Native console font saved: ' .. font .. ' ' .. size .. '.')
    elseif action == 'nativecolor' then
        local value = numbers(args, 4, 0, 255)
        if not value then return usage('nativecolor <alpha> <red> <green> <blue> (0-255)') end
        settings.native.alpha, settings.native.red, settings.native.green, settings.native.blue =
            value[1], value[2], value[3], value[4]
        sync_native_profile()
        save()
        message('Native console text color saved.')
    elseif action == 'activity' then
        local mode = args[1] and args[1]:lower()
        if #args ~= 1 or (mode ~= 'on' and mode ~= 'off') then return usage('activity on|off') end
        settings.activity.enabled = mode == 'on'
        watcher.restart()
        auto_alpha = 0
        if windower.send_command then
            windower.send_command('console_log ' .. (settings.activity.enabled and '1' or '0'))
        end
        save()
        update_visibility()
        message('Log activity ' .. mode .. '. Native console logging follows this setting.')
    elseif action == 'fade' then
        local delay = args[1] and integer(args[1], 0, 60000)
        local duration = args[2] and integer(args[2], 50, 4000)
        if #args < 1 or #args > 2 or not delay or (args[2] and not duration) then
            return usage('fade <native hold ms 0-60000> [frame fade ms 50-4000]')
        end
        settings.activity.delay_ms = delay
        if duration then settings.activity.fade_ms = duration end
        settings.activity.native_delay_owned = windower.send_command ~= nil
        if windower.send_command then windower.send_command('console_fadedelay ' .. delay) end
        save()
        message(windower.send_command and 'Native hold and frame fade timing saved.'
            or 'Frame timing saved; native console command API unavailable.', not windower.send_command)
    elseif action == 'edit' then
        local mode = args[1] and args[1]:lower()
        if #args > 1 or (mode and mode ~= 'on' and mode ~= 'off') then return usage('edit [on|off]') end
        editing = mode and mode == 'on' or (not mode and not editing)
        refresh()
        update_visibility()
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
        update_visibility()
        message('Preview ' .. (preview and 'on' or 'off') .. '.')
    elseif action == 'reset' then
        if #args ~= 0 then return usage('reset') end
        for group, values in pairs(defaults) do
            for key, value in pairs(values) do settings[group][key] = value end
        end
        watcher.restart()
        auto_alpha = 0
        position_dirty = true
        sync_native_profile()
        save()
        update_visibility()
        message('Default frame settings restored.')
    elseif action == 'status' then
        if #args ~= 0 then return usage('status') end
        local rect = actual_rectangle
        message(string.format('v%s: drawn at %d,%d, %dx%d (%s width); gradient %d to %d; glow %d; input %s (%d + %d padding); console %s; edit %s; preview %s; trace %s; log activity %s (%s).',
            _addon.version, rect.x, rect.y, rect.width, rect.height,
            settings.extents.mode,
            settings.gradient.top, settings.gradient.bottom,
            settings.glow.alpha,
            settings.input.enabled and 'on' or 'off', settings.input.height, settings.input.padding,
            settings.console.linked and 'linked' or 'free', editing and 'on' or 'off',
            preview and 'on' or 'off', recorder.active and 'on' or 'off',
            settings.activity.enabled and 'on' or 'off', watcher.available and 'available' or 'unavailable'))
    elseif action == 'help' then
        if #args ~= 0 then return usage('help') end
        message('v' .. _addon.version .. ' | //cbg position <x> <y> | size <width> <height>')
        message('//cbg edit [on|off] | console on|off | offset <x> <y>')
        message('//cbg nativefont <font> <size> | nativecolor <alpha> <red> <green> <blue>')
        message('//cbg width screen|<pixels> | glow <alpha> [height]')
        message('//cbg gradient <top> <bottom> | alpha <0-255> | border <0-255>|link|free')
        message('//cbg color <alpha> <red> <green> <blue> | input on|off [height] | tab left|right')
        message('//cbg inputpad <0-32> | divider on|off | tabstyle red|native | label <text>')
        message('//cbg labelfont <font> | labelsize <title> <input> | labeloffset <-12 to 12>')
        message('//cbg diagnose | trace on|off. Files go to ConsoleBGPlus/data/.')
        message('//cbg preview [on|off] | status | reset. Changes save to data/settings.xml.')
        message('//cbg activity on|off | fade <hold ms> [fade ms]')
    else
        message('Unknown command. Use //cbg help.', true)
    end
end

refresh()
sync_native_profile()
local registration = config.register(settings, function()
    drag, position_dirty = nil, true
    watcher.restart()
    auto_alpha = 0
    refresh()
    sync_native_profile()
    update_visibility()
end)
windower.register_event('addon command', command)
windower.register_event('prerender', function()
    frame = frame + 1
    local console_visible = windower.console.visible()
    if manual_was_open and not console_visible then watcher.suppress() end
    manual_was_open = console_visible
    auto_alpha = watcher.poll(settings.activity)
    local manual = preview or editing or console_visible
    local wanted = manual or auto_alpha > 0
    if wanted then
        local screen = viewport()
        if screen.width ~= last_viewport.width or screen.height ~= last_viewport.height then
            for _, label in pairs(labels) do
                label.pending, label.wait, label.stable = true, 0, 0
            end
            refresh(screen)
        end
    end
    update_visibility()
    if wanted then measure_labels() end
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
