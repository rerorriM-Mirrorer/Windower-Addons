--[[
Copyright © 2019, Xathe
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of Debuffed nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Xathe BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- Icon-rendering test adaptation: A, 2026-10-08; presentation update 2026-10-13.
-- Packet/action/debuff tracking functions below are preserved from Xathe's
-- Windower version 1.0.0.4. The new renderer only reads debuffed_mobs.
_addon.name = 'Debuffed'
_addon.author = 'Xathe (Asura); icon presentation: A'
_addon.version = '1.0.0.4-icons-test2.4.2'
_addon.commands = {'dbf', 'db', 'debuffed'}

config = require('config')
packets = require('packets')
res = require('resources')
texts = require('texts')
require('logger')
require('chat') -- FFXI chat color helpers; output stays out of the console
local IconRenderer = require('icon_renderer')

-- Windower's logger writes to the console. Use the FFXI chat log for user
-- commands, help, and test diagnostics so they are visible during gameplay.
local function notice(message)
    local output = '[Debuffed] ' .. tostring(message)
    if windower.add_to_chat then
        windower.add_to_chat(207, output)
    else
        print(output)
    end
end

defaults = {}
defaults.interval = .1
defaults.mode = 'blacklist'
defaults.timers = true
defaults.hide_below_zero = false
defaults.whitelist = S{}
defaults.blacklist = S{}
defaults.colors = {}
defaults.colors.player = {}
defaults.colors.player.red = 255
defaults.colors.player.green = 255
defaults.colors.player.blue = 255
defaults.colors.others = {}
defaults.colors.others.red = 255
defaults.colors.others.green = 255
defaults.colors.others.blue = 0

-- Icon presentation defaults. Position is shared with the classic text view.
defaults.pos = {x = 160, y = 230}
defaults.display = 'icons'
defaults.layout = 'horizontal'
defaults.iconsize = 24
defaults.iconspacing = 5
defaults.slots = 16 -- displayed effects AND individual edit/preview guides (1..64)
defaults.wrap = 16  -- icons per row/column; 0 = no wrap
defaults.timersize = 8
defaults.timerx = 0   -- horizontal offset, positive = right
defaults.timery = -3 -- vertical offset, negative = up
defaults.sort = 'priority' -- Dia status ID 134 first; other effects by ID
defaults.targetname = false
defaults.iconpath = '../XivParty/assets/buffIcons/'
defaults.background_alpha = 0
defaults.edit = false
-- Match the no-background default in both icon and text display modes.
defaults.bg = {visible = false, alpha = 90, red = 0, green = 0, blue = 0}

settings = config.load(defaults)
box = texts.new('${current_string}', settings)
box:hide() -- the chosen presentation is shown by update_box()
local icon_view = IconRenderer.new(settings)
local warned_no_icons = false

list_commands = T{
    w = 'whitelist',
    wlist = 'whitelist',
    white = 'whitelist',
    whitelist = 'whitelist',
    b = 'blacklist',
    blist = 'blacklist',
    black = 'blacklist',
    blacklist = 'blacklist'
}

sort_commands = T{
    a = 'add',
    add = 'add',
    ['+'] = 'add',
    r = 'remove',
    remove = 'remove',
    ['-'] = 'remove'
}

player_id = 0
frame_time = 0
debuffed_mobs = {}
local shutdown_action = nil -- restart/unload are dispatched only after UI fades
local shutdown_dispatched = false

-- Presentation adapter: filters the existing per-status tracker table for the
-- icon view. No modifications to debuffed_mobs or packet interpretation.
local function icon_entries(target)
    local entries = {}
    local data = debuffed_mobs[target.id]
    if data then
        for effect, spell in pairs(data) do
            local spell_res = res.spells[spell.id]
            if spell_res then
                local name = spell_res.name
                if (settings.mode == 'whitelist' and settings.whitelist:contains(name))
                        or (settings.mode == 'blacklist' and not settings.blacklist:contains(name)) then
                    entries[#entries + 1] = {
                        effect = effect, spell = spell, name = name,
                        -- This is the original estimate, not an observed wear-off.
                        remains = math.max(0, spell.timer - os.clock()),
                    }
                end
            end
        end
    end
    -- pairs() has unspecified order. In the default priority order Dia (134)
    -- leads, then all other active effects pack left-to-right by numeric ID.
    -- This affects ONLY presentation, never how the tracker stores effects.
    table.sort(entries, function(a, b)
        if settings.sort ~= 'id' then
            if a.effect == 134 and b.effect ~= 134 then return true end
            if b.effect == 134 and a.effect ~= 134 then return false end
        end
        return a.effect < b.effect
    end)
    return entries
end

function update_box()
    -- Icon mode is presentation-only. Fall back to original text if the
    -- XivParty asset directory is absent; do not show empty rectangles.
    if settings.display == 'icons' and icon_view:has_icons() then
        local target = windower.ffxi.get_mob_by_target('t')
        local valid = target and target.valid_target
            and (target.claim_id ~= 0 or target.spawn_type == 16)
        box:hide()
        icon_view:render(valid and target or nil, valid and icon_entries(target) or {})
        return
    end

    icon_view:hide()
    if settings.display == 'icons' and not warned_no_icons then
        warned_no_icons = true
        notice(('XivParty icons not found at %s. Showing original text instead.'):format(settings.iconpath))
    end
    box:bg_visible(settings.background_alpha > 0)
    if settings.background_alpha > 0 then box:bg_alpha(settings.background_alpha) end
    box:show()
    local lines = L{}
    local target = windower.ffxi.get_mob_by_target('t')

    if target and target.valid_target and (target.claim_id ~= 0 or target.spawn_type == 16) then
        local data = debuffed_mobs[target.id]

        if data then
            for effect, spell in pairs(data) do
                local name = res.spells[spell.id].name
                local remains = math.max(0, spell.timer - os.clock())

                if settings.mode == 'whitelist' and settings.whitelist:contains(name) or settings.mode == 'blacklist' and not settings.blacklist:contains(name) then
                    if settings.timers and remains > 0 then
                        lines:append(('\\cs(%s)%s: %.0f\\cr'):format(get_color(spell.actor), name, remains))
                    elseif remains < 0 and settings.hide_below_zero then
                        debuffed_mobs[target.id][effect] = nil
                    else
                        lines:append(('\\cs(%s)%s\\cr'):format(get_color(spell.actor), name))
                    end
                end
            end
        end
    end

    if lines:length() == 0 then
        box.current_string = ''
    else
        local prefix = settings.targetname and ('Debuffed [' .. target.name .. ']\n\n') or ''
        box.current_string = prefix .. lines:concat('\n')
    end
end

function get_color(actor)
    if actor == player_id then
        return ('%s,%s,%s'):format(settings.colors.player.red, settings.colors.player.green, settings.colors.player.blue)
    else
        return ('%s,%s,%s'):format(settings.colors.others.red, settings.colors.others.green, settings.colors.others.blue)
    end
end

-- Original tracking starts here. This block is intentionally not reworked.
function handle_overwrites(target, new, t)
    if not debuffed_mobs[target] then
        return true
    end

    for effect, spell in pairs(debuffed_mobs[target]) do
        local old = res.spells[spell.id].overwrites or {}

        -- Check if there isn't a higher priority debuff active
        if table.length(old) > 0 then
            for _,v in ipairs(old) do
                if new == v then
                    return false
                end
            end
        end

        -- Check if a lower priority debuff is being overwritten
        if table.length(t) > 0 then
            for _,v in ipairs(t) do
                if spell.id == v then
                    debuffed_mobs[target][effect] = nil
                end
            end
        end
    end
    return true
end

function apply_debuff(target, effect, spell, actor)
    if not debuffed_mobs[target] then
        debuffed_mobs[target] = {}
    end

    -- Check overwrite conditions
    local overwrites = res.spells[spell].overwrites or {}
    if not handle_overwrites(target, spell, overwrites) then
        return
    end

    -- Create timer
    debuffed_mobs[target][effect] = {id=spell, timer=(os.clock() + (res.spells[spell].duration or 0)), actor=actor}
end

function handle_shot(target)
    if not debuffed_mobs[target] or not debuffed_mobs[target][134] then
        return true
    end

    local current = debuffed_mobs[target][134].id
    if current < 26 then
        debuffed_mobs[target][134].id = current + 1
    end
end

function inc_action(act)
    if act.category ~= 4 then
        if act.category == 6 and act.param == 131 then
            handle_shot(act.targets[1].id)
        end
        return
    end

    -- Damaging spells
    if S{2,252}:contains(act.targets[1].actions[1].message) then
        local target = act.targets[1].id
        local spell = act.param
        local effect = res.spells[spell].status
        local actor = act.actor_id

        if effect then
            apply_debuff(target, effect, spell, actor)
        end

    -- Non-damaging spells
    elseif S{236,237,268,271}:contains(act.targets[1].actions[1].message) then
        local target = act.targets[1].id
        local effect = act.targets[1].actions[1].param
        local spell = act.param
        local actor = act.actor_id

        if res.spells[spell].status and res.spells[spell].status == effect then
            apply_debuff(target, effect, spell, actor)
        end
    end
end

function inc_action_message(arr)

    -- Unit died
    if S{6,20,113,406,605,646}:contains(arr.message_id) then
        debuffed_mobs[arr.target_id] = nil

    -- Debuff expired
    elseif S{64,204,206,350,531}:contains(arr.message_id) then
        if debuffed_mobs[arr.target_id] then
            debuffed_mobs[arr.target_id][arr.param_1] = nil
        end
    end
end

windower.register_event('login','load', function()
    player_id = (windower.ffxi.get_player() or {}).id
end)

windower.register_event('logout','zone change', function()
    debuffed_mobs = {}
end)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x028 then
        inc_action(windower.packets.parse_action(data))
    elseif id == 0x029 then
        local arr = {}
        arr.target_id = data:unpack('I',0x09)
        arr.param_1 = data:unpack('I',0x0D)
        arr.message_id = data:unpack('H',0x19)%32768

        inc_action_message(arr)
    end
end)

windower.register_event('prerender', function()
    -- Poll each frame so icons follow the background smoothly while dragging.
    icon_view:sync_position()
    if shutdown_action then
        -- The fallback classic text view also fades before leaving.
        if not icon_view.visible then
            local factor = icon_view:exit_factor()
            box:alpha(math.floor(255 * factor))
        end
        if not shutdown_dispatched and icon_view:exit_ready() then
            shutdown_dispatched = true
            windower.send_command('lua ' .. (shutdown_action == 'restart' and 'r' or 'u') .. ' Debuffed')
        end
        return -- freeze tracking presentation while shutting down
    end
    local curr = os.clock()
    if curr > frame_time + settings.interval then
        frame_time = curr
        update_box()
    end
end)

local function toggle_bool(field, value)
    if value == 'on' then settings[field] = true
    elseif value == 'off' then settings[field] = false
    elseif not value then settings[field] = not settings[field]
    else notice('Expected on or off.'); return false end
    return true
end

local function update_display()
    icon_view:set_position(settings.pos.x, settings.pos.y)
    update_box()
end

windower.register_event('unload', function()
    icon_view:destroy()
    texts.destroy(box)
end)

-- BattleStations-inspired chat help. Color individual fragments exactly as
-- BattleStations does (primary=200, secondary=207, info=0, warning=140,
-- contrasting heading=167). Unlike BattleStations, do not write a duplicate
-- stripped version to the console. Use ipairs-equivalent explicit ordering.
-- <required>, [optional], and a|b for choices.
local HELP_COLORS = {primary = 200, secondary = 207, info = 0, warn = 140, heading = 167}
local function colored(str, color)
    return tostring(str):color(color)
end

local function help_emit(message)
    if windower.add_to_chat then windower.add_to_chat(207, message)
    else print(message) end
end

local function help_border()
    help_emit(colored(string.rep('=', 38), HELP_COLORS.warn))
end

local function help_heading(name)
    help_emit(colored('Debuffed Help: ', HELP_COLORS.primary)
        .. colored(name, HELP_COLORS.heading))
end

local function help_section(name)
    help_emit(colored('---- ', HELP_COLORS.warn)
        .. colored(name, HELP_COLORS.heading)
        .. colored(' ----', HELP_COLORS.warn))
end

local function help_entry(syntax, description)
    help_emit(colored('db', HELP_COLORS.primary)
        .. ' ' .. colored(syntax, HELP_COLORS.secondary)
        .. ' ' .. colored('=>', HELP_COLORS.primary)
        .. ' ' .. colored(description, HELP_COLORS.info))
end

local function show_help()
    help_border()
    help_heading('Commands')
    help_border()
    help_section('Display')
    help_entry('edit [on|off]', 'Position sample icons and timers')
    help_entry('preview', '12-second sample countdown')
    help_entry('display <icons|text>', 'Choose presentation')
    help_entry('slots <1-64>', 'Number of effect slots')
    help_entry('wrap <0-64>', 'Slots per row (0 = no wrap)')
    help_entry('iconsize <12-96>', 'Icon size in pixels')
    help_entry('iconspacing <0-40>', 'Gap between icons')
    help_entry('sort <priority|id>', 'Dia-first or numerical order')
    help_entry('layout <horizontal|vertical>', 'Grid direction')
    help_entry('targetname [on|off]', 'Show enemy name')
    help_entry('background [on|off|0-255]', 'Background opacity')
    help_section('Timers')
    help_entry('timers', 'Toggle real timers')
    help_entry('timersize <6-24>', 'Timer font size')
    help_entry('timerx <pixels>', 'Move timers left or right')
    help_entry('timery <pixels>', 'Move timers up or down')
    help_entry('timeroffset <x> <y>', 'Move timers on both axes')
    help_section('Tracking and Addon')
    help_entry('mode', 'Switch blacklist/whitelist')
    help_entry('blacklist <add|remove> <spell>', 'Exclude a spell')
    help_entry('whitelist <add|remove> <spell>', 'Include a spell')
    help_entry('interval <seconds>', 'Refresh frequency')
    help_entry('hide', 'Toggle original zero-timer option')
    help_entry('iconpath [path]', 'XivParty status icon directory')
    help_entry('status', 'Current settings')
    help_entry('diagnose', 'Icon path and rendering details')
    help_entry('restart', 'Fade out then reload Debuffed')
    help_entry('unload', 'Fade out then unload Debuffed')
    help_border()
end

local function start_shutdown(action)
    if shutdown_action then
        notice('Already ' .. (shutdown_action == 'restart' and 'restarting' or 'unloading') .. '.')
        return
    end
    shutdown_action = action
    -- Flush any pending drag position through the normal renderer path first.
    icon_view:sync_position()
    icon_view:begin_exit()
    notice(action == 'restart' and 'Restarting Debuffed...' or 'Unloading Debuffed...')
end

windower.register_event('addon command', function(command1, command2, ...)
    if shutdown_action then return end
    local args = L{...}
    command1 = command1 and command1:lower() or nil
    command2 = command2 and command2:lower() or nil

    local name = args:concat(' ')
    if not command1 or command1 == 'help' or command1 == '?' then
        show_help()
    elseif command1 == 'restart' then
        start_shutdown('restart')
    elseif command1 == 'unload' then
        start_shutdown('unload')
    elseif command1 == 'display' then
        if command2 == 'icons' or command2 == 'text' then
            settings.display = command2
            notice(('Display: %s'):format(command2))
            settings:save()
            update_display()
        else
            notice('Usage: //dbf display icons|text')
        end
    elseif command1 == 'layout' then
        if command2 == 'horizontal' or command2 == 'vertical' then
            settings.layout = command2
            notice(('Icon layout: %s'):format(command2))
            settings:save()
            update_display()
        else
            notice('Usage: //dbf layout horizontal|vertical')
        end
    elseif command1 == 'iconsize' then
        local size = tonumber(command2)
        if size and size >= 12 and size <= 96 then
            settings.iconsize = math.floor(size)
            settings:save()
            update_display()
        else
            notice('Usage: //dbf iconsize 12..96 (default 24)')
        end
    elseif command1 == 'iconspacing' then
        local spacing = tonumber(command2)
        if spacing and spacing >= 0 and spacing <= 40 then
            settings.iconspacing = math.floor(spacing)
            settings:save()
            update_display()
        else
            notice('Usage: //dbf iconspacing 0..40 (default 5)')
        end
    elseif command1 == 'slots' then
        local count = tonumber(command2)
        if not command2 then
            notice(('Visible slots: %d (1..64).'):format(tonumber(settings.slots) or 16))
        elseif count and count == math.floor(count) and count >= 1 and count <= 64 then
            settings.slots = count
            settings:save()
            update_display()
            notice(('Visible slots: %d.'):format(count))
        else
            notice('Usage: //db slots 1..64')
        end
    elseif command1 == 'wrap' then
        local count = tonumber(command2)
        if not command2 then
            notice(('Wrap after: %d (0 = no wrapping).'):format(tonumber(settings.wrap) or 16))
        elseif count and count == math.floor(count) and count >= 0 and count <= 64 then
            settings.wrap = count
            settings:save()
            update_display()
            notice(count == 0 and 'Wrapping off.' or ('Wrap after: %d.'):format(count))
        else
            notice('Usage: //db wrap 0..64 (0 = no wrapping)')
        end
    elseif command1 == 'timersize' then
        local value = tonumber(command2)
        if not command2 then
            notice(('Timer font: Arial bold italic, %dpx.'):format(tonumber(settings.timersize) or 8))
        elseif value and value == math.floor(value) and value >= 6 and value <= 24 then
            settings.timersize = value
            icon_view:set_timer_style() -- update existing primitives without reloading
            settings:save()
            update_display()
            notice(('Timer size: %dpx.'):format(value))
        else
            notice('Usage: //db timersize 6..24')
        end
    elseif command1 == 'timerx' or command1 == 'timery' or command1 == 'timeroffset' then
        -- 'timeroffset -3' remains a simple Y-only shorthand.
        -- 'timeroffset <x> <y>' adjusts both axes in one command.
        local value, second = tonumber(command2), tonumber(args[1])
        if not command2 then
            notice(('Timer offset: x=%d y=%d.'):format(tonumber(settings.timerx) or 0, tonumber(settings.timery) or -3))
        elseif value and value == math.floor(value) and value >= -32 and value <= 32
                and (command1 ~= 'timeroffset' or not args[1]
                    or (second and second == math.floor(second) and second >= -32 and second <= 32)) then
            if command1 == 'timerx' then
                settings.timerx = value
            elseif command1 == 'timery' or (command1 == 'timeroffset' and not args[1]) then
                settings.timery = value
            else
                settings.timerx, settings.timery = value, second
            end
            settings:save()
            update_display()
            notice(('Timer offset: x=%d y=%d.'):format(tonumber(settings.timerx) or 0, tonumber(settings.timery) or -3))
        else
            notice('Usage: //db timerx -32..32 | timery -32..32 | timeroffset <x> <y>')
        end
    elseif command1 == 'sort' then
        if command2 == 'id' or command2 == 'priority' then
            settings.sort = command2
            notice(('Icon sort: %s'):format(command2))
            settings:save()
            update_display()
        else
            notice('Usage: //dbf sort priority|id (priority puts Dia first)')
        end
    elseif command1 == 'preview' then
        if settings.display ~= 'icons' then
            notice('Preview needs icon mode. Use //dbf display icons first.')
        elseif not icon_view:has_icons() then
            notice(('Preview cannot find XivParty icons: %s'):format(settings.iconpath))
        else
            icon_view:preview() -- 12s countdown, visual-only; no tracker changes
            update_box()
            local count, total, x, y, sample = icon_view:preview_diagnostics()
            notice(('Preview: %d/%d sample icons at (%d, %d); countdown 11 to 0.'):format(count, total, x, y))
            if count < total then notice('Missing preview images. Dia sample: ' .. sample) end
        end
    elseif command1 == 'diagnose' or command1 == 'status' then
        local count, total, x, y, sample = icon_view:preview_diagnostics()
        notice(('v%s; display=%s; edit=%s; icons=%d/%d'):format(_addon.version,
            tostring(settings.display), tostring(settings.edit), count, total))
        notice(('Field=(%d,%d); slots=%s; wrap=%s; icon directory=%s'):format(x, y, tostring(settings.slots), tostring(settings.wrap), settings.iconpath))
        notice('Dia preview texture: ' .. sample)
    elseif command1 == 'targetname' or command1 == 'edit' then
        if toggle_bool(command1, command2) then
            notice(('%s: %s'):format(command1, settings[command1] and 'on' or 'off'))
            settings:save()
            update_display()
        end
    elseif command1 == 'background' then
        if command2 == 'on' then settings.background_alpha = 90
        elseif command2 == 'off' then settings.background_alpha = 0
        elseif command2 and tonumber(command2) and tonumber(command2) >= 0 and tonumber(command2) <= 255 then
            settings.background_alpha = math.floor(tonumber(command2))
        elseif not command2 then
            settings.background_alpha = settings.background_alpha > 0 and 0 or 90
        else
            notice('Usage: //dbf background on|off|0..255'); return
        end
        settings:save()
        update_display()
    elseif command1 == 'iconpath' then
        -- Useful if XivParty is in a nonstandard location. Paths relative to
        -- Debuffed/ are accepted; use forward slashes even on Windows.
        local path = command2
        if path and path ~= '' then
            settings.iconpath = path
            icon_view:set_icon_path(path)
            warned_no_icons = false
            settings:save()
            update_display()
        else
            notice(('Icon path: %s'):format(settings.iconpath))
        end
    elseif command1 == 'm' or command1 == 'mode' then
        if settings.mode == 'blacklist' then
            settings.mode = 'whitelist'
        else
            settings.mode = 'blacklist'
        end
        notice(('Changed to %s mode.'):format(settings.mode))
        settings:save()
    elseif command1 == 't' or command1 == 'timers' then
        settings.timers = not settings.timers
        notice(('Timer display %s.'):format(settings.timers and 'enabled' or 'disabled'))
        settings:save()
    elseif command1 == 'i' or command1 == 'interval' then
        settings.interval = tonumber(command2) or .1
        notice(('Refresh interval set to %s seconds.'):format(settings.interval))
        settings:save()
    elseif command1 == 'h' or command1 == 'hide' then
        settings.hide_below_zero = not settings.hide_below_zero
        notice(('Timers that reach 0 will be %s.'):format(settings.hide_below_zero and 'hidden' or 'shown'))
        settings:save()
    elseif list_commands:containskey(command1) then
        if sort_commands:containskey(command2) then
            local spell = res.spells:with('name', windower.wc_match-{name})
            command1 = list_commands[command1]
            command2 = sort_commands[command2]

            if spell == nil then
                error(('No spells found that match: %s'):format(name))
            elseif command2 == 'add' then
                settings[command1]:add(spell.name)
                notice(('Added spell to %s: %s'):format(command1, spell.name))
            else
                settings[command1]:remove(spell.name)
                notice(('Removed spell from %s: %s'):format(command1, spell.name))
            end
            settings:save()
        end
    else
        notice(('Unknown command: %s. Use //db help.'):format(tostring(command1)))
    end
end)

-- Start the visual preview immediately when loaded in-game, rather than
-- waiting for the original 0.1 CPU-second tracking refresh. The login hook
-- covers addon auto-loads that happen before the character enters the world.
windower.register_event('login', function()
    update_box()
end)
local startup_info = windower.ffxi.get_info()
if startup_info and startup_info.logged_in then
    update_box()
end
