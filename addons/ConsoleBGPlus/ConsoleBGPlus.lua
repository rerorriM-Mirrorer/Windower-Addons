-- ConsoleBG+ is derived from ConsoleBG by StarHawk, Copyright 2015 Windower.
-- Redistribution terms and the XIVParty texture notice are in LICENSE.txt.
_addon.name = 'ConsoleBGPlus'
_addon.author = 'StarHawk; ConsoleBG+ contributors'
_addon.version = '0.1.1'
_addon.commands = {'consolebgplus', 'cbgplus', 'cbg'}

local config = require('config')
local layout = require('cbg_layout')
local skin = require('cbg_skin')
local defaults = {
    bg = {alpha = 255, red = 255, green = 255, blue = 255},
    pos = {x = 32, y = 16},
    extents = {x = 1070, y = 344, mode = 'screen'},
    gradient = {top = 110, bottom = 235},
    border = {alpha = 240},
    glow = {alpha = 36, height = 24},
    input = {enabled = false, height = 26, tab = 'right'},
}
local settings = config.load(defaults)
local primitives, shown, preview = {}, false, false
local last_viewport, actual_rectangle = nil, nil
local labels = {}

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
    windower.text.set_bold(name, false)
    windower.text.set_right_justified(name, false)
    windower.text.set_bg_visibility(name, false)
    windower.text.set_bg_border_size(name, 0)
    windower.text.set_color(name, 240, red, green, blue)
    windower.text.set_stroke_width(name, stroke)
    windower.text.set_stroke_color(name, 220, 15, 14, 28)
    labels[key] = {name = name, enabled = false}
end

new_label('title', 'Console', 8, 235, 234, 245, 1)
new_label('input', 'Input', 7, 25, 24, 43, 0)

local function refresh(screen)
    screen = screen or viewport()
    local title_width, title_height = windower.text.get_extents(labels.title.name)
    local pieces
    pieces, actual_rectangle = layout.build(settings, screen, title_width)
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
    if rect.title_slot then
        windower.text.set_location(title.name, rect.title_slot.x, rect.title_slot.y)
    end
    windower.text.set_visibility(title.name, shown and title.enabled)
    local input = labels.input
    local tab = rect.input_tab
    input.enabled = tab ~= nil
    if tab then
        local _, input_height = windower.text.get_extents(input.name)
        windower.text.set_location(input.name, tab.x + 4, tab.y + math.max(0, math.floor((tab.height - input_height) / 2)))
    end
    windower.text.set_visibility(input.name, shown and input.enabled)
    last_viewport = screen
end

local function save()
    config.save(settings)
    refresh()
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
        settings.extents.x, settings.extents.y = value[1], value[2]
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
        local height = args[2] and integer(args[2], 12, 256) or nil
        if #args < 1 or #args > 2 or (mode ~= 'on' and mode ~= 'off')
            or (args[2] and not height) then
            return usage('input on|off [height in pixels, 12-256]')
        end
        settings.input.enabled = mode == 'on'
        if height then settings.input.height = height end
        save()
        message('Input strip and tab ' .. mode .. ' (shown with the console).')
    elseif action == 'tab' then
        local side = args[1] and args[1]:lower()
        if #args ~= 1 or (side ~= 'left' and side ~= 'right') then return usage('tab left|right') end
        settings.input.tab = side
        save()
        message('Input tab placed on the ' .. side .. '.')
    elseif action == 'preview' then
        local mode = args[1] and args[1]:lower()
        if #args > 1 or (mode and mode ~= 'on' and mode ~= 'off') then
            return usage('preview [on|off]')
        end
        if mode then preview = mode == 'on' else preview = not preview end
        visibility(preview or windower.console.visible())
        message('Preview ' .. (preview and 'on' or 'off') .. '.')
    elseif action == 'reset' then
        if #args ~= 0 then return usage('reset') end
        for group, values in pairs(defaults) do
            for key, value in pairs(values) do settings[group][key] = value end
        end
        save()
        message('Default frame settings restored.')
    elseif action == 'status' then
        if #args ~= 0 then return usage('status') end
        local rect = actual_rectangle
        message(string.format('v%s: drawn at %d,%d, %dx%d (%s width); gradient %d to %d; glow %d; input %s; preview %s.',
            _addon.version, rect.x, rect.y, rect.width, rect.height,
            settings.extents.mode,
            settings.gradient.top, settings.gradient.bottom,
            settings.glow.alpha,
            settings.input.enabled and 'on' or 'off', preview and 'on' or 'off'))
    elseif action == 'help' then
        if #args ~= 0 then return usage('help') end
        message('v' .. _addon.version .. ' | //cbg position <x> <y> | size <width> <height>')
        message('//cbg width screen|<pixels> | glow <alpha> [height]')
        message('//cbg gradient <top> <bottom> | alpha <0-255> | border <0-255>')
        message('//cbg color <alpha> <red> <green> <blue> | input on|off [height] | tab left|right')
        message('//cbg preview [on|off] | status | reset. Changes save to data/settings.xml.')
    else
        message('Unknown command. Use //cbg help.', true)
    end
end

refresh()
local registration = config.register(settings, function() refresh() end)
windower.register_event('addon command', command)
windower.register_event('prerender', function()
    local wanted = preview or windower.console.visible()
    if wanted then
        local screen = viewport()
        if screen.width ~= last_viewport.width or screen.height ~= last_viewport.height then
            refresh(screen)
        end
    end
    if wanted ~= shown then visibility(wanted) end
end)
windower.register_event('unload', function()
    for _, primitive in ipairs(primitives) do windower.prim.delete(primitive.name) end
    primitives = {}
    for _, label in pairs(labels) do windower.text.delete(label.name) end
    labels = {}
    if config.unregister then config.unregister(settings, registration) end
end)
