-- A read-only activity hint from Windower's optional console.log.
-- We inspect only its length: no console text or input is parsed or saved.
local activity = {}

local function log_path(addon_path)
    local normalized = addon_path:gsub('\\', '/'):gsub('/+$', '')
    local parent, directory = normalized:match('^(.*)/([^/]+)/[^/]+$')
    if directory and directory:lower() == 'addons' then
        return parent .. '/console.log'
    end
    if normalized:lower():match('^addons/[^/]+$') then return './console.log' end
    return nil
end

local function default_clock()
    local ok, socket = pcall(require, 'socket')
    if ok and type(socket) == 'table' and type(socket.gettime) == 'function' then
        return socket.gettime, 'socket.gettime'
    end
    -- Windower also uses os.clock in its timeit library. This is a less
    -- precise fallback for installations without socket.core.
    return os.clock, 'os.clock'
end

function activity.new(addon_path, injected_clock)
    local clock, source = default_clock()
    if injected_clock then clock, source = injected_clock, 'test clock' end
    local watcher = {path = log_path(addon_path), clock = source, available = false,
        changes = 0, size = nil, last_checked = nil, last_output = nil, alpha = 0}

    function watcher.suppress()
        watcher.last_output, watcher.alpha = nil, 0
    end

    function watcher.restart()
        watcher.suppress()
        watcher.size, watcher.last_checked = nil, nil
    end

    function watcher.poll(options)
        if options.enabled ~= true or not watcher.path then
            watcher.suppress()
            return 0
        end
        local now = clock()
        if not watcher.last_checked or now < watcher.last_checked or now - watcher.last_checked >= 0.12 then
            watcher.last_checked = now
            local file = io.open(watcher.path, 'rb')
            if file then
                local size = file:seek('end')
                file:close()
                watcher.available = size ~= nil
                if size then
                    if watcher.size and size > watcher.size then
                        watcher.last_output, watcher.changes = now, watcher.changes + 1
                    elseif watcher.size and size < watcher.size then
                        -- A replaced or truncated log starts at a new baseline.
                        watcher.suppress()
                    end
                    watcher.size = size
                end
            else
                watcher.available, watcher.size = false, nil
            end
        end
        local elapsed = watcher.last_output and now - watcher.last_output
        if not elapsed or elapsed < 0 then watcher.alpha = 0; return 0 end
        local hold = math.max(0, tonumber(options.delay_ms) or 3000) / 1000
        local fade = math.max(1, tonumber(options.fade_ms) or 450) / 1000
        if elapsed <= hold then watcher.alpha = 255; return 255 end
        local progress = (elapsed - hold) / fade
        if progress >= 1 then watcher.alpha = 0; return 0 end
        progress = progress * progress * (3 - 2 * progress)
        watcher.alpha = math.max(0, math.min(255, math.floor(255 * (1 - progress) + 0.5)))
        return watcher.alpha
    end

    return watcher
end

return activity
