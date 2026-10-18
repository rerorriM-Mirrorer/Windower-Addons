--[[
Copyright © 2017, Sammeh of Quetzalcoatl
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of DistancePlus nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sammeh BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- Dist: a focused, independent descendant of Sammeh's DistancePlus.
-- Derived from our three-band Default mode; implementation by A.
_addon.name = 'Dist'
_addon.author = 'A (based on DistancePlus by Sammeh)'
_addon.version = '0.1.0'
_addon.command = 'dist'

local config = require('config')
local texts = require('texts')
local chat = require('chat')

-- Fixed visual rules, intentionally not user-configurable yet. This is one
-- distance display, not a framework for magic/bow/gun/job-specific modes.
local HOME_X, HOME_Y = -178, 21
local MARGIN, NEAR, MID = 4, 22, 30
local RGB = {
    near = {254, 251, 255},
    mid  = {161, 159, 206},
    far  = {88, 85, 132},
}

local defaults = {
    display = {
        pos = {x = HOME_X, y = HOME_Y},
        text = {
            font = 'Verdana', size = 11, alpha = 255,
            red = 254, green = 251, blue = 255,
            stroke = {width = 1, alpha = 255, red = 20, green = 10, blue = 12},
        },
        flags = {right = true, draggable = true, bold = false, italic = false},
        bg = {visible = false, alpha = 0, red = 0, green = 0, blue = 0},
        padding = 0,
    },
}

local settings = config.load(defaults)
-- Passing the root Settings value makes the stock texts library persist a
-- successful drag when the mouse button is released.
local distance = texts.new('${value||%.1f}', settings.display, settings)
distance:hide()

local in_event = false
local last_color, last_size = nil, nil
local last_screen_w, last_screen_h = nil, nil
local last_render_x, last_render_y = nil, nil
local unloading = false

local function msg(color, message)
    windower.add_to_chat(color or 207, 'Dist: '..message)
end

local function dimensions()
    local info = windower.get_windower_settings()
    if not info then return nil end
    local w, h = tonumber(info.ui_x_res), tonumber(info.ui_y_res)
    if not w or not h or w <= 0 or h <= 0 then return nil end
    return w, h
end

-- DistancePlus and texts.lua use negative X for right-justified text. Clamp
-- its entire rendered rectangle, including our near-distance +2px nudge.
local function clamp_position(w, h, offset)
    if not w or not h then return false end
    local x, y = distance:pos()
    local text_w, text_h = distance:extents()
    text_w, text_h = math.max(0, tonumber(text_w) or 0), math.max(0, tonumber(text_h) or 0)
    local margin = math.min(MARGIN, w / 2, h / 2)
    local min_x = math.min(-margin - offset, -w + margin + text_w - offset)
    local max_x = -margin - offset
    local min_y = margin
    local max_y = math.max(min_y, h - margin - text_h)
    local new_x = math.max(min_x, math.min(max_x, x))
    local new_y = math.max(min_y, math.min(max_y, y))
    if new_x ~= x or new_y ~= y then
        distance:pos(new_x, new_y)
        last_render_x, last_render_y = nil, nil
        return true
    end
    return false
end

local function apply_appearance(value)
    local band = value <= NEAR and 'near' or (value <= MID and 'mid' or 'far')
    local rgb = RGB[band]
    local font_size = (tonumber(settings.display.text.size) or 11) + (band == 'near' and 1 or 0)
    if last_color ~= band then
        -- Use the primitive API, not distance:color/size: dynamic highlighting
        -- must never overwrite the user's saved base appearance.
        windower.text.set_color(distance._name, 255, rgb[1], rgb[2], rgb[3])
        last_color = band
    end
    if last_size ~= font_size then
        windower.text.set_font_size(distance._name, font_size)
        last_size = font_size
    end
    return band == 'near' and 2 or 0
end

local function position_on_screen(offset, save_adjustment)
    local w, h = dimensions()
    if not w then return end
    local resized = w ~= last_screen_w or h ~= last_screen_h
    last_screen_w, last_screen_h = w, h
    if clamp_position(w, h, offset) and save_adjustment then
        config.save(settings)
        if resized then msg(207, ('recovered position for %dx%d UI.'):format(w, h)) end
    end
    local x, y = distance:pos()
    local render_x = w + x + offset
    if render_x ~= last_render_x or y ~= last_render_y then
        -- x+offset is a rendering-only adjustment: the saved x remains fixed.
        windower.text.set_location(distance._name, render_x, y)
        last_render_x, last_render_y = render_x, y
    end
end

local function hide_display()
    if distance:visible() then distance:hide() end
end

-- Preserve EnemyBar2's simple status-4 event/cutscene convention. The display
-- returns according to target availability, not a stale pre-event visibility.
windower.register_event('status change', function(status)
    in_event = status == 4
    if in_event then hide_display() end
end)

windower.register_event('logout', hide_display)
windower.register_event('zone change', hide_display)

windower.register_event('prerender', function()
    local info = windower.ffxi.get_info()
    if in_event or (info and info.logged_in == false) then
        hide_display()
        return
    end

    local target = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
    if not target or type(target.distance) ~= 'number' then
        hide_display()
        -- We still check viewport bounds when no target exists, so shrinking
        -- a multibox client cannot strand the label until another target.
        position_on_screen(0, true)
        return
    end

    local value = math.sqrt(math.max(0, target.distance))
    distance.value = value
    local offset = apply_appearance(value)
    position_on_screen(offset, true)
    if not distance:visible() then distance:show() end
end)

-- texts.lua drags first and emits a drag event afterward. Correcting the
-- object here (not just next frame) ensures its auto-save writes safe coords.
distance:register_event('drag', function()
    local w, h = dimensions()
    local offset = last_color == 'near' and 2 or 0
    clamp_position(w, h, offset)
    last_render_x, last_render_y = nil, nil
end)

local function help()
    local function line(command, description)
        local prefix = '//dist'
        windower.add_to_chat(0,
            prefix:color(200)..' '..command:color(207)..'  '..('->'):color(200)..' '..description:color(0))
    end
    windower.add_to_chat(0, ('Dist  v%s  |  Distance display'):format(_addon.version):color(167))
    windower.add_to_chat(0, ('-------------------------------------'):color(140))
    line('help', 'Show commands (also for bare/unknown commands)')
    line('status', 'Show display and position information')
    line('pos <x> <y>', 'Place the display (right-relative X)')
    line('pos reset', 'Restore the original safe position')
    line('lock | unlock', 'Prevent or allow dragging')
    line('size <points>', 'Change base font size (near is +1)')
    line('restart | unload', 'Restart or unload this addon')
end

local function status()
    local x, y = distance:pos()
    msg(207, ('v%s | Default (fixed) | 1 decimal | near<=22, mid<=30, far>30'):format(_addon.version))
    msg(207, ('pos=(%.0f, %.0f) | size=%s | draggable=%s | event=%s'):format(
        x, y, tostring(settings.display.text.size),
        tostring(distance:draggable()), in_event and 'yes' or 'no'))
end

local function set_position(x, y)
    distance:pos(x, y)
    last_render_x, last_render_y = nil, nil
    local offset = last_color == 'near' and 2 or 0
    local w, h = dimensions()
    clamp_position(w, h, offset)
    config.save(settings)
    local saved_x, saved_y = distance:pos()
    msg(207, ('position saved (%.0f, %.0f).'):format(saved_x, saved_y))
end

windower.register_event('addon command', function(command, ...)
    if not command then help(); return end
    local args = {...}
    command = command:lower()
    if command == 'help' or command == '?' then
        help()
    elseif command == 'status' then
        status()
    elseif command == 'pos' or command == 'position' then
        if args[1] and args[1]:lower() == 'reset' and #args == 1 then
            set_position(HOME_X, HOME_Y)
        else
            local x, y = tonumber(args[1]), tonumber(args[2])
            if not x or not y or #args ~= 2 then
                msg(123, 'Usage: //dist pos <x> <y>  |  //dist pos reset')
            else
                set_position(x, y)
            end
        end
    elseif command == 'lock' or command == 'unlock' then
        if #args ~= 0 then help(); return end
        distance:draggable(command == 'unlock')
        config.save(settings)
        msg(207, 'dragging '..(command == 'unlock' and 'enabled.' or 'disabled.'))
    elseif command == 'size' then
        local n = tonumber(args[1])
        if #args ~= 1 or not n or n < 6 or n > 72 then
            msg(123, 'Usage: //dist size <6-72>')
        else
            -- Save base size only. The +1 near-range emphasis stays transient.
            settings.display.text.size = n
            last_size = nil
            config.save(settings)
            msg(207, ('base font size = %s.'):format(n))
        end
    elseif (command == 'restart' or command == 'unload') and #args == 0 then
        if unloading then return end
        unloading = true
        hide_display()
        msg(207, command == 'restart' and 'restarting.' or 'unloading.')
        windower.send_command(command == 'restart' and 'lua r Dist' or 'lua u Dist')
    else
        help()
    end
end)
