-- A: preloaded tiny frames avoid loading textures during a gain animation.
local images = require('images')
local glint = {}
function glint.new(path)
    local frames, start, current, forced = {}, nil, nil, false
    for i=1,20 do
        frames[i] = images.new({texture={path=path .. ('images/glint/%02d.png'):format(i),fit=true},
            size={width=23,height=23},color={alpha=255,red=255,green=255,blue=255},draggable=false,visible=false})
        frames[i]:hide()
    end
    local self = {}
    function self.place(x,y,size)
        for _, frame in ipairs(frames) do frame:pos(x,y);frame:size(size,size) end
    end
    function self.trigger(now,preview)
        -- Coalesce simultaneous commands, reappearance and balance changes.
        if start and now - start < (self.duration or 0.7) and not preview then return end
        start = now; forced = preview == true
    end
    function self.stop()
        start, forced = nil, false
        if current then frames[current]:hide();current=nil end
    end
    function self.render(now,opacity,enabled,duration)
        self.duration = duration
        local index
        if (enabled or forced) and start and now - start < duration then
            index = math.min(20, math.floor((now - start)/duration*20)+1)
        elseif start then self.stop() end
        if current and current ~= index then frames[current]:hide() end
        current = index
        if current then
            frames[current]:alpha(math.floor(210*opacity))
            if opacity > 0 then frames[current]:show() else frames[current]:hide() end
        end
    end
    function self.destroy()
        self.stop()
        for _, frame in ipairs(frames) do frame:destroy() end
    end
    return self
end
return glint
