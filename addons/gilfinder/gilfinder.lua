--[[    BSD License Disclaimer
        Copyright © 2017, sylandro
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of giltracker nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL sylandro BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'gilfinder'
_addon.author = 'sylandro; modifications by A'
_addon.version = '1.5.0-a.20261021.1'
_addon.commands = {'gil'}
_addon.language = 'English'

local config = require('config')
require('chat')
local images = require('images')
local texts = require('texts')
local packets = require('packets')
local controller = require('controller')
require('migrate').run()

local GIL_ITEM_ID = 65535
local CUTSCENE_STATUS_ID = 4
local SCROLL_LOCK_KEY = 70
local INVENTORY_FINISH_PACKET = 0x1D
local TREASURE_FIND_ITEM_PACKET = 0xD2
local LOGIN_ZONE_PACKET = 0x0A
local ITEM_UPDATE_PACKET = 0x20
local ITEM_MODIFY_PACKET = 0x1F

local separator_map = {
    none = '',
    space = ' ',
    period = '.',
    comma = ',',
    [''] = ',',
}

local hideKey = SCROLL_LOCK_KEY
local is_hidden_by_cutscene = false
local is_hidden_by_key = false

local defaults = {}
defaults.hideInCutscenes = false
defaults.glint = true
defaults.glintDuration = 0.7
defaults.visibility = 'change'
defaults.side = 'left'
defaults.countDuration = 0.4
defaults.colorDuration = 0.8
defaults.gainColor = {red=166, green=207, blue=179}
defaults.lossColor = {red=222, green=164, blue=181}
defaults.hideDelay = 60
defaults.fadeDuration = 0.5
defaults.scale = 1
defaults.locked = false
defaults.hideKey = SCROLL_LOCK_KEY
defaults.thousandsSeparator = ','
defaults.refreshInterval = 5
defaults.gilText = {}
defaults.gilText.bg = {}
defaults.gilText.bg.alpha = 100
defaults.gilText.bg.red = 0
defaults.gilText.bg.green = 0
defaults.gilText.bg.blue = 0
defaults.gilText.bg.visible = false
defaults.gilText.text = {}
defaults.gilText.text.font = 'sans-serif'
defaults.gilText.text.fonts = {'Arial','Trebuchet MS'}
defaults.gilText.text.size = 9
defaults.gilText.flags = {}
defaults.gilText.flags.italic = true
defaults.gilText.flags.bold = false
defaults.gilText.flags.right = true
defaults.gilText.flags.bottom = true
defaults.gilText.pos = {}
defaults.gilText.pos.x = -285
defaults.gilText.pos.y = -35
defaults.gilText.text.alpha = 255
defaults.gilText.text.red = 253
defaults.gilText.text.green = 252
defaults.gilText.text.blue = 250
defaults.gilText.text.stroke = {}
defaults.gilText.text.stroke.alpha = 200
defaults.gilText.text.stroke.red = 50
defaults.gilText.text.stroke.green = 50
defaults.gilText.text.stroke.blue = 50
defaults.gilText.text.stroke.width = 2
defaults.gilText.text.visible = true
defaults.gilImage = {}
defaults.gilImage.color = {}
defaults.gilImage.color.alpha = 255
defaults.gilImage.color.red = 255
defaults.gilImage.color.green = 255
defaults.gilImage.color.blue = 255
defaults.gilImage.visible = true

local settings = config.load(defaults)
-- Only visibility controls display. Legacy XML was migrated before loading.
settings.autohide = nil
config.save(settings)

local get_separator, ready_if_valid_treasure_packet, update_if_valid_item_packet, refresh_gil, initialize, update_gil, show, hide, format_value, is_cutscene, toggle_display_if_cutscene, toggle_display_if_hide_key_is_pressed

get_separator = function()
    local separator = separator_map[settings.thousandsSeparator] or settings.thousandsSeparator

    if type(separator) ~= 'string' then
        return defaults.thousandsSeparator
    end

    return separator
end

settings.gilImage.texture = {}
settings.gilImage.texture.path = windower.addon_path..'gil.png'
settings.gilImage.texture.fit = true
settings.gilImage.size = {}
settings.gilImage.size.height = 23
settings.gilImage.size.width = 23
settings.gilImage.draggable = false
settings.gilImage.repeatable = {}
settings.gilImage.repeatable.x = 1
settings.gilImage.repeatable.y = 1

-- Runtime geometry and fade alpha must never overwrite saved base settings.
local function copy(value)
    if type(value) ~= 'table' then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = copy(item) end
    return result
end
local gil_image = images.new(copy(settings.gilImage))
local gil_text = texts.new(copy(settings.gilText))
local inventory_loaded = false
local ready = false
local last_gil, last_change, last_input, preview_until
local displayed_gil, animation
local held_keys = {}
local function note_input(dik, down)
    if down then held_keys[dik] = true else held_keys[dik] = nil end
    last_input = os.clock()
end
local dragging
local current_opacity = 0
local editing = false
local lifecycle
local edit_text = texts.new({text={font='Arial',size=9,alpha=255,red=220,green=190,blue=205},
    bg={visible=true,alpha=160,red=20,green=20,blue=20},flags={draggable=false}})
edit_text:text('GilFinder: drag icon or amount | //gil lock')
edit_text:hide()
local function finite(n) return n and n == n and n > -math.huge and n < math.huge end
local coin_glint = require('glint').new(windower.addon_path)
local wallet_panel = require('wallet_panel').new()
local wallet_open = false
local menu_open
local departure_start
local function glint(now)
    if settings.glint then coin_glint.trigger(now or os.clock()) end
end
local function wake()
    preview_until = os.clock() + settings.hideDelay
    departure_start = nil
    if wallet_open then wallet_panel.resume(os.clock()) end
    glint()
end
local function wallet_sample()
    local info, player = windower.ffxi.get_info(), windower.ffxi.get_player()
    if not inventory_loaded or not info.logged_in or not player then return end
    return {name=player.name, server=info.server, gil=windower.ffxi.get_items('gil')}
end
local wallet = require('wallet').new({sample=wallet_sample, now=os.clock,
    schedule=function(fn,delay) coroutine.schedule(fn,delay) end,
    send=function(message) windower.send_ipc_message(message) end,
    report=function(message) windower.add_to_chat(207,'GilFinder: ' .. message) end,
    display=function(rows)
        if not wallet_open then return end
        wallet_panel.update(rows, settings, format_value, os.clock())
        wake()
    end})
windower.register_event('ipc message',function(message) if not lifecycle then wallet.receive(message) end end)
local layout_x_res, layout_y_res
local icon_left, icon_top
local layout
layout = function()
    local res = windower.get_windower_settings()
    layout_x_res, layout_y_res = res.ui_x_res, res.ui_y_res
    local scale = settings.scale
    gil_text:size(math.max(1, math.floor(settings.gilText.text.size * scale + 0.5)))
    gil_text:stroke_width(math.max(1, settings.gilText.text.stroke.width * scale))
    gil_image:size(23 * scale, 23 * scale)
    local x = settings.gilText.pos.x + (settings.gilText.flags.right and res.ui_x_res or 0)
    local y = settings.gilText.pos.y + (settings.gilText.flags.bottom and res.ui_y_res or 0)
    -- Preserve the original icon anchor; changing sides never moves the icon.
    local icon_x = x + scale
    icon_left, icon_top = icon_x, y - 23 * scale / 6
    gil_image:pos(icon_x, y - 23 * scale / 6)
    coin_glint.place(icon_x, y - 23 * scale / 6, 23 * scale)
    local width = gil_text:extents()
    local text_x = settings.side == 'right' and icon_x + 27 * scale or icon_x - scale
    if settings.side == 'right' and settings.gilText.flags.right then text_x = text_x + width end
    if settings.side == 'left' and not settings.gilText.flags.right then text_x = text_x - width end
    gil_text:pos(text_x - (settings.gilText.flags.right and res.ui_x_res or 0), settings.gilText.pos.y)
    -- Disable independent library dragging: both pieces belong to one widget.
    gil_text:draggable(false)
    -- Recover an off-screen group without changing valid personal coordinates.
    local tx = text_x - (settings.gilText.flags.right and width or 0)
    local left, right = math.min(tx, icon_x), math.max(tx + width, icon_x + 23 * scale)
    local top, bottom = y - 23 * scale / 6, y + 23 * scale
    local dx, dy = 0, 0
    if right < 0 or left > res.ui_x_res then dx = 8 - left end
    if bottom < 0 or top > res.ui_y_res then dy = 8 - top end
    if dx ~= 0 or dy ~= 0 then
        settings.gilText.pos.x = settings.gilText.pos.x + dx
        settings.gilText.pos.y = settings.gilText.pos.y + dy
        layout()
        return
    end
    edit_text:pos(math.max(0, math.min(left, res.ui_x_res - 290)), math.max(0, top - 20))
end
local function opacity(value)
    current_opacity = value
    gil_text:alpha(math.floor(settings.gilText.text.alpha * value))
    gil_text:stroke_alpha(math.floor(settings.gilText.text.stroke.alpha * value))
    gil_text:bg_alpha(math.floor(settings.gilText.bg.alpha * value))
    gil_image:alpha(math.floor(settings.gilImage.color.alpha * value))
    edit_text:alpha(math.floor(255 * value))
    edit_text:bg_alpha(math.floor(160 * value))
end
local function animate(now)
    if displayed_gil == nil then return end
    local color, mix = settings.gilText.text, 0
    if animation then
        local progress = settings.countDuration == 0 and 1 or math.min(1, (now - animation.start) / settings.countDuration)
        -- Retarget from the current number when another transaction arrives.
        displayed_gil = animation.from + (animation.target - animation.from) * progress
        color = animation.color
        local color_elapsed = now - animation.start - settings.countDuration
        mix = color_elapsed <= 0 and 1 or (settings.colorDuration == 0 and 0 or math.max(0, 1 - color_elapsed / settings.colorDuration))
        if mix == 0 then displayed_gil = animation.target; animation = nil end
    end
    local base = settings.gilText.text
    gil_text:color(math.floor(base.red + (color.red - base.red) * mix + 0.5),
        math.floor(base.green + (color.green - base.green) * mix + 0.5),
        math.floor(base.blue + (color.blue - base.blue) * mix + 0.5))
    local amount = math.floor(displayed_gil + 0.5)
    local formatted = format_value(amount)
    if gil_text:text() ~= formatted then gil_text:text(formatted); layout() end
end
local function render()
    local now = os.clock()
    animate(now)
    -- menu_open is a native boolean, unrelated to player cutscene status 4.
    local info = windower.ffxi.get_info()
    if type(info.menu_open) == 'boolean' and inventory_loaded and info.logged_in then
        local next_menu = info.menu_open
        if menu_open ~= nil and next_menu ~= menu_open and settings.visibility == 'change' then
            last_change = now
            wake()
        end
        menu_open = next_menu
    else menu_open = nil end
    if controller.focused and controller.focused() == false then held_keys = {} end
    if settings.visibility == 'input' and (next(held_keys) or controller.held(now)) then last_input = now end
    local value = 1
    if settings.visibility ~= 'always' and not dragging and not editing then
        local activity
        if settings.visibility == 'input' then activity = last_input else activity = last_change end
        if preview_until then activity = math.max(activity or -math.huge, preview_until - settings.hideDelay) end
        value = 0
        if activity then
            local elapsed = now - activity - settings.hideDelay
            -- Finish one farewell sweep, then roll up the wallet during the fade.
            if elapsed > 0 then
                if not departure_start then departure_start = activity + settings.hideDelay; glint(departure_start) end
                local lead = settings.glint and settings.glintDuration or 0
                value = math.max(0, 1 - math.max(0, now - departure_start - lead) / settings.fadeDuration)
                if now - departure_start >= lead and wallet_open then
                    wallet.cancel()
                    wallet_panel.close(departure_start + lead)
                end
            else
                if departure_start and wallet_open then wallet_panel.resume(now) end
                departure_start = nil; value = 1
            end
        end
    end
    if not inventory_loaded or is_hidden_by_key or (settings.hideInCutscenes and is_hidden_by_cutscene) then value = 0 end
    if lifecycle then value = math.min(value, lifecycle.opacity * math.max(0, 1 - (now - lifecycle.start) / settings.fadeDuration)) end
    if value > 0 and current_opacity == 0 and not departure_start then glint(now) end
    if value == 0 and departure_start and wallet_open then
        wallet_open = false; wallet.cancel(); wallet_panel.clear()
    end
    opacity(value)
    local res = windower.get_windower_settings()
    wallet_panel.render(now, value, settings, icon_left, icon_top, res.ui_x_res, res.ui_y_res)
    coin_glint.render(now,value * settings.gilImage.color.alpha / 255,settings.glint,settings.glintDuration)
    if value > 0 then show() else hide() end
    if editing and value > 0 then edit_text:show() else edit_text:hide() end
end
local function validate_settings()
    settings.autohide = nil
    local function number(key, fallback, minimum, maximum)
        local n = tonumber(settings[key])
        if not finite(n) then n = fallback end
        settings[key] = math.max(minimum, maximum and math.min(maximum, n) or n)
    end
    number('scale', 1, 0)
    if settings.scale <= 0 then settings.scale = 1 end
    number('hideDelay', 60, 1, 3600)
    number('fadeDuration', 0.5, 0)
    if settings.fadeDuration <= 0 then settings.fadeDuration = 0.5 end
    number('countDuration', 0.4, 0)
    number('colorDuration', 0.8, 0)
    number('glintDuration', 0.7, 0)
    if settings.glintDuration <= 0 then settings.glintDuration = 0.7 end
    if settings.side ~= 'left' and settings.side ~= 'right' then settings.side = 'left' end
    if settings.visibility ~= 'always' and settings.visibility ~= 'change' and settings.visibility ~= 'input' then settings.visibility = 'change' end

    for _, key in ipairs({'gainColor', 'lossColor'}) do
        for _, channel in ipairs({'red', 'green', 'blue'}) do
            local n = tonumber(settings[key][channel])
            settings[key][channel] = finite(n) and math.max(0, math.min(255, n)) or defaults[key][channel]
        end
    end
end
validate_settings()
layout()

local function refresh_gil_loop()
    while true do
        coroutine.sleep(math.max(tonumber(settings.refreshInterval) or defaults.refreshInterval, 1))
        if inventory_loaded then
            update_gil()
        end
    end
end

config.register(settings, function(settings)
    hideKey = settings.hideKey
    validate_settings()
    layout()
    render()
end)

windower.register_event('load',function()
    hide()
    if windower.ffxi.get_info().logged_in then
        initialize()
    end
    coroutine.schedule(refresh_gil_loop, 0)
end)

windower.register_event('login',function()
    gil_text:text('Loading...')
end)

windower.register_event('logout', function(...)
    inventory_loaded = false
    wallet.cancel()
    wallet_open = false
    wallet_panel.clear()
    menu_open, departure_start = nil, nil
    coin_glint.stop()
    last_gil, last_change, last_input, preview_until, dragging = nil, nil, nil, nil, nil
    displayed_gil, animation, held_keys = nil, nil, {}
    hide()
end)

windower.register_event('add item', function(_bag,_index,id,...)
    if (id == GIL_ITEM_ID) then ready = true end
end)

windower.register_event('remove item', function(_bag,_index,id,...)
    if (id == GIL_ITEM_ID) then ready = true end
end)

windower.register_event('incoming chunk',function(id,org,_modi,_is_injected,_is_blocked)
    if (id == LOGIN_ZONE_PACKET) then
        inventory_loaded = false
        wallet.cancel(); wallet_open = false; wallet_panel.clear()
        menu_open, departure_start = nil, nil
        coin_glint.stop()
        dragging = nil
        held_keys = {}
        hide()
    elseif (id == TREASURE_FIND_ITEM_PACKET) then
        ready_if_valid_treasure_packet(org)
    elseif (id == ITEM_UPDATE_PACKET) then
        update_if_valid_item_packet(org)
    elseif (id == INVENTORY_FINISH_PACKET) then
        refresh_gil()
    elseif (id == ITEM_MODIFY_PACKET) then
        update_if_valid_item_packet(org)
    end
end)

windower.register_event('status change', function(new_status_id)
    local is_cutscene_playing = is_cutscene(new_status_id)
    toggle_display_if_cutscene(is_cutscene_playing)
end)

windower.register_event('keyboard', function(dik, down, _flags, _blocked)
    if dik ~= hideKey then note_input(dik, down) end
    toggle_display_if_hide_key_is_pressed(dik, down)
    render()
end)

ready_if_valid_treasure_packet = function(packet_data)
    local p = packets.parse('incoming',packet_data)
    if (p.Count > 0) then ready = true end
end

update_if_valid_item_packet = function(packet_data)
    local p = packets.parse('incoming',packet_data)
    if (p.Item == GIL_ITEM_ID and p.Count >= 0) then
        update_gil()
    end
end

refresh_gil = function()
    if (ready and inventory_loaded) then
        update_gil()
        ready = false
    elseif (not inventory_loaded) then
        initialize()
    end
end

initialize = function()
    inventory_loaded = true
    if last_gil == nil then preview_until = os.clock() + settings.hideDelay end
    update_gil()
    is_hidden_by_cutscene = is_cutscene((windower.ffxi.get_player() or {}).status)
    render()
end

update_gil = function()
    local gil = windower.ffxi.get_items('gil')
    if not finite(gil) then return end
    local now = os.clock()
    if last_gil ~= nil and gil ~= last_gil then
        animate(now)
        glint(now)
        if settings.visibility == 'change' then
            departure_start = nil
            if wallet_open then wallet_panel.resume(now) end
        end
        animation = {from=displayed_gil or last_gil, target=gil, start=now,
            color=gil > last_gil and settings.gainColor or settings.lossColor}
        last_change = now
    elseif last_gil == nil then
        displayed_gil = gil
    end
    last_gil = gil
    render()
end

show = function()
    gil_text:show()
    gil_image:show()
end

hide = function()
    gil_text:hide()
    gil_image:hide()
    edit_text:hide()
    coin_glint.render(os.clock(),0,settings.glint,settings.glintDuration)
end

format_value = function(amount)
    local formatted = tostring(amount)
    local separator = get_separator()
    local k

    if separator == '' then
        return formatted
    end

    local replacement = '%1'..separator:gsub('%%', '%%%%')..'%2'

    while true do
        formatted, k = string.gsub(formatted, '^(%d+)(%d%d%d)', replacement)
        if k == 0 then break end
    end

    return formatted
end

is_cutscene = function(status_id)
    return status_id == CUTSCENE_STATUS_ID
end

toggle_display_if_cutscene = function(is_cutscene_playing)
    is_hidden_by_cutscene = is_cutscene_playing
    if is_cutscene_playing and settings.hideInCutscenes then dragging = nil end
    render()
end

toggle_display_if_hide_key_is_pressed = function(key_pressed, key_down)
    if key_pressed == hideKey and key_down and not (settings.hideInCutscenes and is_hidden_by_cutscene) then
        is_hidden_by_key = not is_hidden_by_key
        if is_hidden_by_key then dragging = nil end
        render()
    end
end

-- A: store offsets in the existing anchor system so old positions survive.
windower.register_event('mouse', function(kind, x, y, delta, blocked)
    if kind == 2 and dragging then
        dragging = nil
        config.save(settings)
        render()
        return true
    end
    if kind == 0 and dragging then
        settings.gilText.pos.x = dragging.px + x - dragging.x
        settings.gilText.pos.y = dragging.py + y - dragging.y
        layout()
        return true
    end
    if blocked or lifecycle or settings.locked or current_opacity <= 0 then return end
    if kind == 1 and (gil_text:hover(x, y) or gil_image:hover(x, y)) then
        dragging = {x=x, y=y, px=settings.gilText.pos.x, py=settings.gilText.pos.y}
        return true
    end
end)

windower.register_event('prerender', function()
    local res = windower.get_windower_settings()
    if res.ui_x_res ~= layout_x_res or res.ui_y_res ~= layout_y_res then layout() end
    render()
    if lifecycle and not lifecycle.dispatched and os.clock() - lifecycle.start >= settings.fadeDuration then
        lifecycle.dispatched = true
        hide()
        edit_text:hide()
        windower.send_command(lifecycle.kind == 'restart' and 'lua reload gilfinder' or 'lua unload gilfinder')
    end
end)
windower.register_event('unload', function()
    wallet.cancel()
    wallet_panel.destroy()
    coin_glint.destroy()
    config.save(settings)
    gil_text:destroy()
    gil_image:destroy()
    edit_text:destroy()
end)


local function report(message) windower.add_to_chat(207, 'GilFinder: ' .. message) end
local help_rows = {
    {'help', 'Show this command list'},
    {'status', 'Show version, mode, position and controller state'},
    {'mode [always|change|input]', 'Set or cycle always -> change -> input'},
    {'wallet [on|off|refresh]', 'Toggle the live wallet panel on this computer'},
    {'glint [on|off|preview]', 'Toggle coin glint or preview it'},
    {'side <left|right>', 'Place the amount beside the icon'},
    {'cutscenes [on|off]', 'Toggle hiding during cutscenes/dialogue (default off)'},
    {'delay <seconds>', 'Hold before fading; 1 to 3600 seconds'},
    {'scale <factor>', 'Scale the widget; positive finite factor'},
    {'counttime <seconds>', 'Count duration; zero for instant'},
    {'colortime <seconds>', 'Color return duration; zero for instant'},
    {'edit [on|off]', 'Toggle persistent positioning guides'},
    {'lock', 'Lock positioning and finish editing'},
    {'unlock', 'Enable dragging and positioning guides'},
    {'pos reset', 'Recover the widget to its default position'},
    {'show', 'Keep the widget visible (always mode)'},
    {'hide', 'Hide until show, auto, or the hide-key toggle'},
    {'auto [change|input]', 'Use timed visibility; change includes menu transitions'},
    {'autohide [on|off]', 'Compatibility alias for auto/show'},
    {'restart', 'Fade out and reload GilFinder'},
    {'unload', 'Fade out and unload GilFinder'},
}
local function help(error_message)
    if error_message then report(error_message) end
    windower.add_to_chat(0, string.color('---------------- GilFinder ----------------', 140))
    windower.add_to_chat(0, string.color('Commands', 167))
    for _, row in ipairs(help_rows) do
        windower.add_to_chat(0, string.color('//gil ', 200) .. string.color(row[1], 207)
            .. string.color(' -> ', 200) .. string.color(row[2], 0))
    end
end
local function preview() wake() end
local function set_edit(value)
    editing, settings.locked, dragging = value, not value, nil
    if value then is_hidden_by_key = false; preview() end
    report(value and 'Edit mode on; drag the icon or amount. //gil lock to finish.' or 'Edit mode off; position locked.')
end
local function toggle(arg, value)
    if arg == '' then return not value end
    if arg == 'on' then return true end
    if arg == 'off' then return false end
end
local handlers = {}
handlers.help = function() help() end
handlers.status = function()
    report(('v%s | %s | amount %s | delay %ss | scale %s | pos %s, %s'):format(
        _addon.version, settings.visibility, settings.side, settings.hideDelay, settings.scale,
        settings.gilText.pos.x, settings.gilText.pos.y))
    report(('Cutscene hiding %s | %s | edit %s | controller: %s'):format(
        settings.hideInCutscenes and 'on' or 'off', settings.locked and 'locked' or 'unlocked',
        editing and 'on' or 'off', controller.status))
    report(('Glint %s (%ss) | wallet %s | live, same computer | menu %s'):format(settings.glint and 'on' or 'off',settings.glintDuration, wallet_open and 'open' or 'closed', tostring(menu_open)))
end
handlers.mode = function(arg)
    if arg ~= '' and arg ~= 'always' and arg ~= 'change' and arg ~= 'input' then return false end
    if arg == '' then
        arg = ({always='change',change='input',input='always'})[settings.visibility]
    end
    settings.visibility = arg
    preview()
    report('Visibility: ' .. arg)
end
handlers.visibility = handlers.mode
handlers.wallet = function(arg)
    if arg ~= '' and arg ~= 'on' and arg ~= 'off' and arg ~= 'refresh' then return false end
    local open = arg == 'on' or arg == 'refresh' or (arg == '' and not wallet_open)
    if not open then
        wallet_open = false; wallet.cancel(); wallet_panel.close(os.clock())
    else
        is_hidden_by_key = false
        wallet_open = true
        wake()
        if not wallet.request() then wallet_open=false;wallet_panel.clear() end
    end
end
handlers.glint = function(arg)
    if arg == 'preview' then
        is_hidden_by_key = false
        preview()
        coin_glint.trigger(os.clock(),true)
        return
    end
    local value=toggle(arg,settings.glint)
    if value == nil then return false end
    settings.glint=value
    if not value then coin_glint.stop() end
    report('Coin glint ' .. (value and 'on' or 'off'))
end
handlers.side = function(arg)
    if arg ~= 'left' and arg ~= 'right' then return false end
    settings.side = arg; preview(); report('Amount: ' .. arg)
end
handlers.cutscenes = function(arg)
    local value = toggle(arg, settings.hideInCutscenes)
    if value == nil then return false end
    settings.hideInCutscenes = value
    if value and is_hidden_by_cutscene then dragging = nil end
    report('Cutscene hiding ' .. (value and 'on' or 'off'))
end
for _, spec in ipairs({{'delay','hideDelay',1,3600}, {'scale','scale',0},
    {'counttime','countDuration',0}, {'colortime','colorDuration',0}}) do
    local command, key, minimum, maximum = spec[1], spec[2], spec[3], spec[4]
    handlers[command] = function(arg)
        local n = tonumber(arg)
        if not finite(n) or n < minimum or (command == 'scale' and n == 0) or (maximum and n > maximum) then return false end
        settings[key] = n
        if command == 'scale' then preview() end
        report(command .. ': ' .. n)
    end
end
handlers.edit = function(arg)
    local value = toggle(arg, editing)
    if value == nil then return false end
    set_edit(value)
end
handlers.lock = function() set_edit(false) end
handlers.unlock = function() set_edit(true) end
handlers.pos = function(arg)
    if arg ~= 'reset' then return false end
    settings.gilText.pos.x, settings.gilText.pos.y = defaults.gilText.pos.x, defaults.gilText.pos.y
    is_hidden_by_key = false; preview(); report('Position reset.')
end
handlers.show = function() is_hidden_by_key = false; settings.visibility = 'always'; preview() end
handlers.hide = function() is_hidden_by_key = true; dragging = nil; wallet_open = false; wallet.cancel(); wallet_panel.clear() end
handlers.auto = function(arg)
    if arg ~= '' and arg ~= 'change' and arg ~= 'input' then return false end
    settings.visibility = arg == 'input' and 'input' or 'change'
    is_hidden_by_key = false
    preview()
    report('Visibility: ' .. settings.visibility)
end
handlers.autohide = function(arg)
    local value = toggle(arg, settings.visibility ~= 'always')
    if value == nil then return false end
    if value then handlers.auto('change') else handlers.show() end
end
local function lifecycle_command(kind)
    if lifecycle then return end
    wallet.cancel()
    config.save(settings)
    lifecycle = {kind=kind, start=os.clock(), opacity=current_opacity, dispatched=false}
    editing, dragging = false, nil
    report(kind == 'restart' and 'Restarting...' or 'Unloading...')
end
handlers.restart = function() lifecycle_command('restart') end
handlers.unload = function() lifecycle_command('unload') end
local no_args = {help=true,status=true,lock=true,unlock=true,show=true,hide=true,restart=true,unload=true}
windower.register_event('addon command', function(command, argument, ...)
    command = (command or 'help'):lower()
    local arg = (argument or ''):lower()
    if lifecycle then return end
    if select('#', ...) > 0 or not handlers[command] or (no_args[command] and arg ~= '') then help('Invalid command.'); return end
    if handlers[command](arg) == false then help('Invalid arguments for //gil ' .. command .. '.'); return end
    -- Successful interactions acknowledge responsiveness without undoing explicit hide.
    if command ~= 'hide' and not (command == 'glint' and arg == 'off') then
        glint()
        if not is_hidden_by_key then preview() end
    end
    if command == 'help' or command == 'status' or lifecycle then render(); return end
    config.save(settings)
    layout()
    render()
end)
