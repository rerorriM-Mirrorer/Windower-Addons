_addon = {}
_addon.name = 'switch_focus'
_addon.version = '1.1.2-test'
_addon.author = 'WindowerDevTeam'
_addon.commands = {'swf', 'switch', 'switch_focus'}

require('tables')
require('strings')
require('chat')
local box_list = require('box_list')

local back_name
local switch = {cmd = {}}
local switch_ack = false
local join_reply_queued = false

-- Shared chat-only formatting, following WORKFLOW.md's BattleStations palette.
local function chat_line(value)
    windower.add_to_chat(0, value)
end

local function separator()
    chat_line(string.color(string.rep('-', 42), 140))
end

local function heading(section)
    chat_line(string.color('Switch Focus v' .. _addon.version .. ' - ' .. section, 167))
end

local function field(label, value)
    chat_line('  ' .. string.color(label, 207) .. string.color(' -> ', 200)
        .. string.color(tostring(value), 0))
end

local function help_command(syntax, description)
    chat_line('  ' .. string.color('//switch', 200) .. string.color(syntax, 207)
        .. string.color(' -> ', 200) .. string.color(description, 0))
end

function switch.command(cmd, ...)
    local args = T{...}:map(string.lower)
    local command = switch.cmd[cmd and cmd:lower() or 'help']
    if command then
        command(args)
    else
        switch.cmd.help()
    end
end
windower.register_event('addon command', switch.command)

function switch.cmd.help()
    separator()
    heading('Commands')
    separator()
    help_command(' help', 'Show this command list')
    help_command(' status', 'Show the current client, leader and focus state')
    help_command(' p1', 'Focus the current party leader')
    help_command(' to <name>', 'Focus a named client (partial names accepted)')
    help_command(' back', 'Return focus to the last sender')
    help_command(' next', 'Focus the next client alphabetically (alias: n)')
    help_command(' prev', 'Focus the previous client alphabetically (alias: p)')
    separator()
end

function switch.cmd.status()
    local player = windower.ffxi.get_player()
    local party = windower.ffxi.get_party()
    local name = player and player.name or '(not logged in)'
    local known = {}
    for i = 1, box_list:len() do
        known[#known + 1] = box_list[i]
    end

    local leader_id = party and party.party1_leader
    local leader_name
    if leader_id then
        if player and player.id == leader_id then
            leader_name = player.name
        end
        for i = 0, 5 do
            local member = party['p' .. i]
            if not leader_name and member and member.name and member.name ~= ''
                and (member.id == leader_id or (member.mob and member.mob.id == leader_id)) then
                leader_name = member.name
            end
        end
        if not leader_name then
            local mob = windower.ffxi.get_mob_by_id(leader_id)
            leader_name = mob and mob.name
        end
    elseif player and party and party.party1_count == 1 then
        leader_name = player.name .. ' (solo)'
    end

    separator()
    heading('Status')
    separator()
    field('Client', name)
    field('Focused', windower.has_focus() and 'yes' or 'no')
    field('Party leader', leader_name or 'unavailable')
    field('Leader ID', leader_id and tostring(leader_id) or 'none')
    field(string.format('Known clients (%d)', #known),
        #known > 0 and table.concat(known, ', ') or 'none')
    field('Back target', back_name or 'none')
    separator()
end

function switch.cmd.to(args, exact_only)
    local name = args[1]

    -- Dynamic-role callers require an exact match; manual 'to' keeps partial matching.
    if not exact_only and not box_list:get_index_of(name) then
        for i = 1, box_list:len() do
            local value = box_list[i]
            if windower.wc_match(value, name .. '*') then
                name = value
                break
            end
        end
    end
    local player_name = windower.ffxi.get_player().name:lower()
    windower.send_ipc_message(string.format('to,%s,%s', player_name, name:lower()))
    coroutine.sleep(0.1)

    if (windower.has_focus() and not exact_only) then
        windower.send_ipc_message(string.format('to,%s,@lobby', player_name, name:lower()))
    end
end

function switch.cmd.p1()
    local player = windower.ffxi.get_player()
    local party = windower.ffxi.get_party()
    if not player or not party then
        windower.add_to_chat(123, 'switch_focus: Cannot identify the party leader while logged out.')
        return
    end

    -- party1_leader holds a character ID, not a position in the party list.
    -- It can change independently of the p0-p5 slot order.
    local leader_id = party.party1_leader
    if not leader_id then
        if party.party1_count == 1 then
            return -- Solo: the current character already has focus.
        end
        windower.add_to_chat(123, 'switch_focus: Party leader ID is not available yet.')
        return
    end
    if leader_id == player.id then
        return -- Do not trigger the normal lobby fallback when already leading.
    end

    local leader_name
    for i = 0, 5 do
        local member = party['p' .. i]
        if member and member.name and member.name ~= ''
            and (member.id == leader_id or (member.mob and member.mob.id == leader_id)) then
            leader_name = member.name
            break
        end
    end

    -- Nearby leaders can be found even if their party slot omits an ID.
    if not leader_name then
        local mob = windower.ffxi.get_mob_by_id(leader_id)
        leader_name = mob and mob.name
    end

    if not leader_name then
        windower.add_to_chat(123, 'switch_focus: Leader name is unavailable; keeping the current focus.')
        return
    end
    if leader_name:lower() == player.name:lower() then
        return
    end

    -- Reuse name-targeted IPC but never fall back to an unrelated lobby client.
    switch.cmd.to({leader_name:lower()}, true)
end

function switch.cmd.back()
    if back_name then
        windower.send_ipc_message(string.format('to,%s,%s', windower.ffxi.get_player().name:lower(), back_name:lower()))
    end
end

function switch.cmd.next()
    local player_name = windower.ffxi.get_player().name:lower()
    local index = box_list:get_index_of(player_name)

    local next = box_list[(index % box_list:len()) + 1]
    while (next ~= player_name) do
        switch_ack = false
        switch.cmd.to({next})

        coroutine.sleep(0.1)

        if (switch_ack or not windower.has_focus()) then
            switch_ack = false
            break
        end

        windower.send_ipc_message('clear,' .. next)
        box_list:remove(next)

        next = box_list[(index % box_list:len()) + 1]
    end
end
switch.cmd.n = switch.cmd.next

function switch.cmd.prev()
    local name = windower.ffxi.get_player().name:lower()
    local index = box_list:get_index_of(name)

    local prev = box_list[((index - 2) % box_list:len()) + 1]
    while (prev ~= name) do
        switch_ack = false
        switch.cmd.to({prev})

        coroutine.sleep(0.1)

        if (switch_ack or not windower.has_focus()) then
            switch_ack = false
            break
        end

        windower.send_ipc_message('clear,' .. prev)
        box_list:remove(prev)

        prev = box_list[((index - 2) % box_list:len()) + 1]
    end
end
switch.cmd.p = switch.cmd.prev

switch.ipc = {}
local function ipc_message(raw_msg)
    raw_msg = raw_msg and raw_msg:lower()
    local msg = string.split(raw_msg, ',')
    if switch.ipc[msg[1]] then
        switch.ipc[msg[1]](msg)
    end
end
windower.register_event('ipc message', ipc_message)

function switch.ipc.to(msg)
    local from_name = msg[2]
    local to_name = msg[3]
    local player =  windower.ffxi.get_player()
    if not windower.has_focus() and ((player and to_name == player.name:lower()) or (to_name == '@lobby' and not windower.ffxi.get_info().logged_in)) then
        back_name = from_name
        windower.send_ipc_message(string.format('ack,%s,%s', from_name, to_name))
        windower.take_focus()
    end
end

function switch.ipc.ack(msg)
    local from_name = msg[2]
    local player =  windower.ffxi.get_player()
    if player and from_name == player.name:lower() then
        switch_ack = true
    end
end

-- Original client discovery echoed each new join immediately from inside the IPC
-- callback. Multiple simultaneous reloads could make those replies bunch together.
-- Consolidate replies from one event burst, and send after the callback returns.
function switch.ipc.join(msg)
    local name = msg[2]
    if not name or name == '' then
        return
    end

    local player = windower.ffxi.get_player()
    if not player then
        return
    end
    local own_name = player.name:lower()
    if not box_list:get_index_of(name) then
        box_list:add(name)
        if name ~= own_name and not join_reply_queued then
            join_reply_queued = true
            coroutine.schedule(function()
                join_reply_queued = false
                local current = windower.ffxi.get_player()
                if current and current.name:lower() == own_name then
                    windower.send_ipc_message('join,' .. own_name)
                end
            end, 0.20)
        end
    end
end

function switch.ipc.clear(msg)
    local name = msg[2]
    box_list:remove(name)
end

local function on_login(name)
    local own_name = name:lower()
    box_list:add(own_name)
    windower.send_ipc_message('clear,' .. own_name) -- Retain discovery with previously loaded clients.
    windower.send_ipc_message('join,' .. own_name)

    -- One late announcement repairs a roster if simultaneous unload/load sends a
    -- clear after our first join. This is bounded, not a recurring polling loop.
    coroutine.schedule(function()
        local player = windower.ffxi.get_player()
        if player and player.name:lower() == own_name then
            windower.send_ipc_message('join,' .. own_name)
        end
    end, 0.55)
end
windower.register_event('login', on_login)

local function on_logout(name)
    windower.send_ipc_message('clear,' .. name:lower())
end
windower.register_event('logout',  on_logout)

local function on_load()
    if windower.ffxi.get_info().logged_in then
        on_login(windower.ffxi.get_player().name)
    end
end
windower.register_event('load', on_load)

local function on_unload()
    if windower.ffxi.get_info().logged_in then
        on_logout(windower.ffxi.get_player().name)
    end
end
windower.register_event('unload', on_unload)
