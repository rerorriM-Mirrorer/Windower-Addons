-- A: a presentation layer for the existing IPC snapshot. Rows never intercept input.
local texts = require('texts')
local panel = {}
local function copy(t)
    if type(t) ~= 'table' then return t end
    local r = {}; for k,v in pairs(t) do r[k] = copy(v) end; return r
end
local function clamp(v) return math.max(0, math.min(1,v)) end
function panel.new()
    local rows, opened, closing = {}, nil, nil
    local snapshot, formatter
    local self = {}
    function self.clear()
        for _,row in ipairs(rows) do row.name:destroy(); row.amount:destroy() end
        rows, opened, closing = {}, nil, nil
    end
    function self.update(samples, settings, format, now)
        -- Measure the complete snapshot before revealing any row: no column jitter.
        snapshot, formatter = samples, format
        local was_open = opened ~= nil and closing == nil
        self.clear()
        opened = was_open and now - 1 or now
        local servers, total = {}, 0
        for _,sample in ipairs(samples) do servers[sample.server] = true end
        local count=0; for _ in pairs(servers) do count=count+1 end
        local function add(name, amount)
            local style=copy(settings.gilText)
            style.flags.right, style.flags.bottom, style.flags.draggable = false,false,false
            style.pos={x=0,y=0}
            local amount_style=copy(style)
            amount_style.flags.right=true
            local row={name=texts.new(copy(style)),amount=texts.new(amount_style)}
            row.name:text(name);row.amount:text(format(amount))
            row.name:hide();row.amount:hide()
            rows[#rows+1]=row
        end
        for _,sample in ipairs(samples) do
            total=total+sample.gil
            add(sample.name .. (count>1 and (' [' .. sample.server .. ']') or ''),sample.gil)
        end
        if settings.walletTotal then add(('Total (%d)'):format(#samples),total) end
    end
    function self.restyle(settings, now)
        if opened and snapshot then self.update(snapshot,settings,formatter,now) end
    end
    function self.resume(now)
        if opened and closing then opened,closing=now-1,nil end
    end
    function self.close(now)
        if opened and not closing then closing=now end
    end
    function self.render(now, opacity, settings, x, y, screen_w, screen_h, amount_right)
        if not opened then return end
        if closing and now-closing>=math.max(0.3,settings.fadeDuration) then self.clear();return end
        local scale, name_w, amount_w, height = settings.scale,0,0,0
        for _,row in ipairs(rows) do
            for _,w in ipairs({row.name,row.amount}) do
                w:size(math.max(1,math.floor(settings.gilText.text.size*scale+0.5)))
                w:stroke_width(math.max(1,settings.gilText.text.stroke.width*scale))
            end
            local nw,nh=row.name:extents(); local aw,ah=row.amount:extents()
            name_w=math.max(name_w,nw);amount_w=math.max(amount_w,aw)
            height=math.max(height,nh,ah)
        end
        height=height+4*scale
        local gap=10*scale
        -- Every wallet number shares the main balance's ones-place anchor.
        -- Names have their own column on the opposite side of the coin.
        local ax=amount_right or (settings.side=='left' and x-settings.gap*scale
            or x+(23+settings.gap)*scale+amount_w)
        local nx=settings.side=='left' and math.max(x+23*scale,ax)+gap
            or math.min(x,ax-amount_w)-gap-name_w
        -- Recover the NAME column at an edge; never shift the numeric axis alone.
        if nx+name_w>screen_w-2 then nx=math.min(x,ax-amount_w)-gap-name_w end
        if nx<2 then nx=math.max(x+23*scale,ax)+gap end
        local down=y+23*scale+height*#rows<=screen_h-2
        local direction=down and 1 or -1
        local base=down and y+23*scale or y-height
        for i,row in ipairs(rows) do
            local t=closing and 1-clamp((now-closing)/0.3) or clamp((now-opened-(i-1)*0.1/math.max(1,#rows-1))/0.2)
            -- Compress toward the coin while closing; the same fixed columns remain.
            local row_y=base+direction*(i-1)*height*(closing and t or 1)-direction*5*scale*(1-t)
            row.name:pos(nx,row_y);row.amount:pos(ax-screen_w,row_y)
            local alpha=opacity*t
            for _,w in ipairs({row.name,row.amount}) do
                w:alpha(math.floor(settings.gilText.text.alpha*alpha))
                w:stroke_alpha(math.floor(settings.gilText.text.stroke.alpha*alpha))
                w:bg_alpha(math.floor(settings.gilText.bg.alpha*alpha))
                if alpha>0 then w:show() else w:hide() end
            end
        end
    end
    function self.destroy() self.clear() end
    return self
end
return panel
