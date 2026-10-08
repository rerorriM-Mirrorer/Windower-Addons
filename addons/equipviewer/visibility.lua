-- A: visibility policy is independent of rendering so packet updates cannot
-- override a manual hide, and fades can be checked without an FFXI client.
local Visibility = {}
Visibility.__index = Visibility

local function duration(value, fallback)
    value = tonumber(value)
    if not value or value ~= value or value < 0 or value == math.huge then
        return fallback
    end
    return value
end

function Visibility.new(now, mode)
    return setmetatable({
        alpha = mode == 'show' and 1 or 0,
        deadline = 0,
        last_time = now,
    }, Visibility)
end

function Visibility:reveal(now, delay)
    self.deadline = now + duration(delay, 4)
end

function Visibility:step(now, options, suppressed, dragging, hovered)
    local elapsed = math.max(0, now - self.last_time)
    self.last_time = now
    local mode = options.mode
    if mode ~= 'show' and mode ~= 'hide' and mode ~= 'auto' then
        mode = 'show'
    end

    -- Holding a drag or optionally hovering keeps auto mode open, but never
    -- overrides manual hide or the game's zoning/cutscene suppression.
    if mode == 'auto' and not suppressed and (dragging or (options.hover and hovered)) then
        self:reveal(now, options.delay)
    end
    local wanted = not suppressed and mode ~= 'hide'
        and (mode ~= 'auto' or now < self.deadline)

    if suppressed then
        self.alpha = 0
    else
        local target = wanted and 1 or 0
        local seconds = duration(wanted and options.fade_in or options.fade_out, wanted and 0.12 or 0.30)
        if seconds == 0 then
            self.alpha = target
        elseif wanted then
            self.alpha = math.min(1, self.alpha + elapsed / seconds)
        else
            self.alpha = math.max(0, self.alpha - elapsed / seconds)
        end
    end

    return self.alpha, wanted
end

return Visibility
