-- Behavioral smoke/regression checks against the real addon using small
-- Windower API substitutes. They check policy, data freshness, and dragging;
-- they do not claim to reproduce FFXI drawing or real packet timing.
local root = 'addons/equipviewer/'
package.path = root..'?.lua;'..package.path
local time = 0
os.clock = function() return time end
local callbacks, objects, messages, pending = {}, {}, {}, {}
local saves, saved = 0, nil
local fixture = { logged_in = true, status = 0, equipment = {}, items = {} }

local function copy(value)
    if type(value) ~= 'table' then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = copy(v) end
    return result
end
local function emit(name, ...)
    for _, callback in ipairs(callbacks[name] or {}) do callback(...) end
end
local function tick(seconds)
    time = time + seconds
    local scheduled = pending
    pending = {}
    for _, fn in ipairs(scheduled) do fn() end
    emit('prerender')
end
local function command(...)
    emit('addon command', ...)
end
local function active(kind)
    local list = {}
    for _, object in ipairs(objects) do
        if not object.destroyed and (not kind or kind == object.kind) then list[#list + 1] = object end
    end
    return list
end
local function background() return active('image')[1] end
local function ammo() return active('text')[1] end
local function main_icon()
    for _, image in ipairs(active('image')) do
        if image.texture and image.texture:find('icons/', 1, true)
            and image.x == settings.pos.x and image.y == settings.pos.y then return image end
    end
end
local function main_encumbrance()
    for _, image in ipairs(active('image')) do
        if image.texture and image.texture:find('encumbrance.png', 1, true)
            and image.x == settings.pos.x and image.y == settings.pos.y then return image end
    end
end
local function all_hidden()
    for _, object in ipairs(active()) do assert(not object.shown, 'A hidden element became visible') end
    assert(not background():draggable(), 'Hidden background accepts dragging')
end
local function equipment(slot, slot_id, index, item_id, count)
    fixture.equipment[slot] = index
    fixture.equipment[slot..'_bag'] = 0
    fixture.items[index] = {id = item_id, count = count or 1}
    emit('incoming chunk', 0x050, {['Inventory Index'] = index, ['Equipment Slot'] = slot_id, ['Inventory Bag'] = 0})
    tick(0)
end

local methods = {}
function methods:visible(value)
    if value == nil then return self.shown end
    assert(type(value) == 'boolean', 'visible() must receive a boolean')
    self.shown = value
end
function methods:show() self.shown = true end
function methods:hide() self.shown = false end
function methods:alpha(value)
    if value == nil then return self.opacity end
    self.opacity = value
end
function methods:stroke_alpha(value) self.stroke = value end
function methods:draggable(value)
    if value == nil then return self.drag end
    self.drag = value
end
function methods:pos(x, y)
    if x == nil then return self.x, self.y end
    self.x, self.y = x, y
end
function methods:hover(x, y)
    return self.shown and x >= self.x and y >= self.y
        and x < self.x + self.width and y < self.y + self.height
end
function methods:path(value) self.texture = value end
function methods:clear() self.texture = nil end
function methods:update() end
function methods:text(value) self.value = value end
function methods:destroy() self.shown, self.destroyed = false, true end
local function new_object(kind, options)
    local object = setmetatable({kind = kind, x = options.pos and options.pos.x or 0,
        y = options.pos and options.pos.y or 0, width = options.size and options.size.width or 0,
        height = options.size and options.size.height or 0, drag = options.draggable or false,
        opacity = options.color and options.color.alpha or 255, shown = false}, {__index = methods})
    objects[#objects + 1] = object
    return object
end

_addon = {}
log = function(message) messages[#messages + 1] = message end
string.contains = function(value, needle) return value:find(needle, 1, true) ~= nil end
S = function(values)
    return {contains = function(_, needle)
        for _, value in ipairs(values) do if value == needle then return true end end
        return false
    end}
end
coroutine.sleep = function() end
debug.setmetatable(function() end, {__index = {schedule = function(fn, _, ...)
    local args = {...}
    pending[#pending + 1] = function() fn((unpack or table.unpack)(args)) end
end}})
windower = {
    addon_path = root, ffxi_path = 'FFXI/',
    register_event = function(name, callback)
        callbacks[name] = callbacks[name] or {}
        callbacks[name][#callbacks[name] + 1] = callback
    end,
    dir_exists = function() return true end,
    create_dir = function() end,
    file_exists = function() return true end,
    get_windower_settings = function() return {ui_x_res = 1280, ui_y_res = 720} end,
    ffxi = {
        get_info = function() return {logged_in = fixture.logged_in} end,
        get_player = function() return {status = fixture.status} end,
        get_items = function(bag, index)
            if bag == 'equipment' then return fixture.equipment end
            return fixture.items[index] or {id = 0, count = 0}
        end,
    },
}
package.preload.luau = function() return {} end
package.preload.functions = function() return {} end
package.preload.config = function()
    return {
        load = function(defaults) return copy(defaults) end,
        save = function(options) saves, saved = saves + 1, copy(options) end,
        reload = function(options)
            for key in pairs(options) do options[key] = nil end
            for key, value in pairs(copy(saved)) do options[key] = value end
        end,
    }
end
package.preload.images = function() return {new = function(options) return new_object('image', options) end} end
package.preload.texts = function() return {new = function(options) return new_object('text', options) end} end
package.preload.packets = function() return {parse = function(_, packet) return packet end} end
package.preload.icon_extractor = function() return {ffxi_path = function() end, item_by_id = function() end} end
package.preload.bit = function()
    return {
        lshift = function(value, bits) return value * 2^bits end,
        band = function(a, b)
            local result, place = 0, 1
            while a > 0 and b > 0 do
                if a % 2 == 1 and b % 2 == 1 then result = result + place end
                a, b, place = math.floor(a / 2), math.floor(b / 2), place * 2
            end
            return result
        end,
    }
end

local slots = {'main', 'sub', 'range', 'ammo', 'head', 'body', 'hands', 'legs',
    'feet', 'neck', 'waist', 'left_ear', 'right_ear', 'left_ring', 'right_ring', 'back'}
for _, slot in ipairs(slots) do fixture.equipment[slot], fixture.equipment[slot..'_bag'] = 0, 0 end
fixture.equipment.main, fixture.equipment.ammo = 1, 3
fixture.items[1], fixture.items[3] = {id = 100, count = 1}, {id = 300, count = 5}

-- Windower accepts 'literal':format(); standard Lua requires parentheses.
-- Normalize that existing shortcut in memory only, never in installed files.
local file = assert(io.open(root..'equipviewer.lua', 'r'))
local source = file:read('*a'); file:close()
source = source:gsub("('[^'\n]*')(:format%()", '(%1)%2')
assert((loadstring or load)(source, '@'..root..'equipviewer.lua'))()
emit('load')
assert(background().shown and background():draggable(), 'Default visible/draggable changed')
assert(ammo().shown and ammo().value == '5', 'Initial ammo not displayed')
print('PASS: load/default appearance')

command('hide'); tick(0.4); all_hidden()
equipment('main', 0, 2, 101)
emit('incoming chunk', 0x01B, {['Encumbrance Flags'] = 1})
fixture.items[3].count = 9
emit('incoming chunk', 0x020, {Bag = 0, Index = 3, Status = 5, Count = 9, Item = 300})
tick(0)
emit('status change', 1)
emit('incoming chunk', 0x0B, {})
emit('incoming chunk', 0x0A, {})
command('unlock'); tick(0); all_hidden()
assert(ammo().value == '9', 'Hidden ammo data is stale')
command('scale', '1.5'); tick(0); all_hidden()
assert(settings.size == 48 and background().width == 192, 'Scale behavior regressed')
command('show'); tick(0.2)
assert(background().shown and ammo().value == '9' and ammo().shown, 'Show failed to restore current data')
assert(main_encumbrance().shown, 'Hidden encumbrance update was lost')
print('PASS: persistent hide across gear/ammo/encumbrance/status/zone/unlock/scale, show restores data')

command('alpha', '128')
command('autohide', 'on')
tick(3.9); assert(background().shown, 'Auto hid before delay')
tick(0.2); assert(background():alpha() > 0 and background():alpha() < settings.bg.alpha, 'Missing fade out')
assert(ammo().stroke < settings.ammo_text.stroke.alpha, 'Ammo stroke failed to fade')
tick(0.2); all_hidden()
equipment('main', 0, 4, 102)
tick(0.06)
assert(background().shown and background():alpha() > 0 and background():alpha() < settings.bg.alpha, 'Missing fade in')
tick(0.12)
assert(main_icon():alpha() == 128, 'Fade lost configured icon opacity')
assert(main_icon().texture:find('102.bmp', 1, true), 'Hidden item update was lost')
tick(3); equipment('main', 0, 5, 103)
tick(2); assert(background().shown, 'Gear swap did not restart delay')
tick(2.4); all_hidden()
print('PASS: timed auto reveal, reversible fades, configured alpha, delayed expiry after another swap')

emit('mouse', 0, settings.pos.x + 1, settings.pos.y + 1)
tick(0.2); all_hidden()
command('hover', 'on'); tick(0.2)
assert(background().shown, 'Optional hidden-region hover failed')
emit('mouse', 0, 0, 0); tick(4.5); all_hidden()
command('hover', 'off')
command('autohide', 'on'); tick(0.2)
local bg = background()
emit('mouse', 1, bg.x + 1, bg.y + 1)
tick(6); assert(bg.shown, 'Grid hid during a held drag')
bg:pos(640, 330); tick(0)
assert(main_icon() and main_icon().x == 640 and main_icon().y == 330, 'Icons failed to follow drag')
assert(ammo().x == 640 + settings.size * 4 - 1280, 'Right-justified ammo failed to follow')
local previous_saves = saves
emit('mouse', 2, 641, 331)
assert(saves > previous_saves and saved.pos.x == 640 and saved.pos.y == 330, 'Drag release did not save XML position')
tick(3.9); assert(bg.shown, 'Release did not grant a fresh delay')
tick(0.5); all_hidden()
command('autohide', 'on'); tick(0.2)
emit('mouse', 1, bg.x + 1, bg.y + 1)
bg:pos(650, 340)
emit('mouse', 2, 651, 341) -- A complete short drag before the next render frame.
assert(saved.pos.x == 650 and saved.pos.y == 340, 'Fast drag release missed its final position')
print('PASS: optional hover, held drag, live icon/ammo movement, release/save/grace')

command('show'); tick(0.2)
fixture.status = 4; emit('status change', 4); all_hidden()
equipment('main', 0, 6, 104); all_hidden()
command('size', '32'); tick(0); all_hidden()
fixture.status = 0; emit('status change', 0); tick(0.2)
assert(background().shown, 'Show mode did not resume after cutscene')
emit('incoming chunk', 0x0B, {}); all_hidden()
emit('incoming chunk', 0x0A, {}); tick(0.2)
assert(background().shown, 'Show mode did not resume after zoning')
command('hide'); tick(0.4)
fixture.logged_in = false; emit('logout')
assert(#active() == 0, 'Logout leaked UI objects')
fixture.logged_in = true; emit('login'); tick(0.2); all_hidden()
assert(settings.visibility.mode == 'hide', 'Mode did not persist across login')
command('show'); tick(0.2)
command('justify')
assert(ammo().x == settings.pos.x + settings.size * 3, 'Left-justified ammo behavior regressed')
print('PASS: cutscene/zone suppression and resume, no logout objects, persisted mode, left ammo alignment')

local previous_delay, previous_fade, previous_hover = settings.visibility.delay, settings.visibility.fade_in, settings.visibility.hover
command('delay', 'nope'); command('delay', '-1'); command('delay', 'inf')
command('fade', '0.1'); command('fade', '-1', '0.2')
command('autohide', 'invalid'); command('hover', 'invalid')
assert(settings.visibility.delay == previous_delay and settings.visibility.fade_in == previous_fade
    and settings.visibility.hover == previous_hover, 'Malformed command corrupted settings')
command('fade', '0', '0'); command('hide'); all_hidden()
command('show'); assert(background().shown, 'Instant show failed')
command('autohide'); assert(settings.visibility.mode == 'auto', 'Bare auto toggle failed')
command('auto', 'off'); assert(settings.visibility.mode == 'show', 'Auto alias failed')
command('status')
assert(messages[#messages]:find('Mode=show', 1, true), 'Status omits mode')
emit('unload'); assert(#active() == 0, 'Unload leaked UI objects')
print('PASS: malformed commands, zero-duration fades, toggles/alias/status/unload')
print('All EquipViewer behavioral checks passed. Live FFXI testing remains pending.')
