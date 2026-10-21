-- A: an on-demand snapshot over local Windower IPC. No game packets or balance cache.
local wallet = {}
function wallet.new(api)
    local active, serial = nil, 0
    local answered = {}
    local instance = tostring({}):gsub('[^%w]', '')
    local function valid_token(token)
        return token and #token <= 128 and token:match('^[%w_%.%-]+$')
    end
    local function valid_sample(s)
        return s and type(s.name) == 'string' and s.name:match('^%a+$') and #s.name <= 16
            and type(s.server) == 'number' and s.server == math.floor(s.server) and s.server > 0 and s.server <= 65535
            and type(s.gil) == 'number' and s.gil >= 0 and s.gil <= 4294967295 and s.gil == math.floor(s.gil)
    end
    local function key(s) return s.server .. ':' .. s.name:lower() end
    local function add(s)
        if active and valid_sample(s) then active.rows[key(s)] = s end
    end
    local function finish(token)
        if not active or active.token ~= token then return end
        local rows = {}
        for _, row in pairs(active.rows) do rows[#rows + 1] = row end
        active = nil
        table.sort(rows, function(a,b)
            if a.server ~= b.server then return a.server < b.server end
            return a.name:lower() < b.name:lower()
        end)
        api.display(rows)
    end
    local self = {}
    function self.request()
        local own = api.sample()
        if not valid_sample(own) then api.report('Wallet unavailable until your character inventory is ready.'); return end
        serial = serial + 1
        local token = own.name .. '-' .. own.server .. '-' .. instance .. '-' .. serial
        active = {token=token, rows={}}
        add(own) -- IPC need not echo to the sender; count self explicitly, once.
        api.schedule(function() finish(token) end, 1)
        api.send('GFW1|Q|' .. token)
        api.report('Checking live wallets on this computer...')
    end
    function self.receive(message)
        if type(message) ~= 'string' or #message > 256 then return end
        local token = message:match('^GFW1|Q|([%w_%.%-]+)$')
        if valid_token(token) then
            if active and token == active.token then return end
            local now = api.now()
            for t, expiry in pairs(answered) do if now >= expiry then answered[t] = nil end end
            if answered[token] then return end
            local own = api.sample()
            if not valid_sample(own) then return end
            answered[token] = now + 5
            api.send(('GFW1|R|%s|%d|%s|%.0f'):format(token, own.server, own.name, own.gil))
            return
        end
        local t, server, name, amount = message:match('^GFW1|R|([%w_%.%-]+)|(%d+)|(%a+)|(%d+)$')
        if not active or t ~= active.token then return end
        add({server=tonumber(server), name=name, gil=tonumber(amount)})
    end
    function self.cancel() active = nil; answered = {} end
    return self
end
return wallet
