-- A: transient currency rows share the coin anchor but never intercept input.
local texts,images=require('texts'),require('images')
local tray={}
local function copy(t) if type(t)~='table' then return t end local r={} for k,v in pairs(t) do r[k]=copy(v) end return r end
local function clamp(v) return math.max(0,math.min(1,v)) end
function tray.new(path)
    local rows,opened,paused={},nil,false
    local measure
    local self={}
    function self.clear()
        for _,r in ipairs(rows) do r.name:destroy();r.amount:destroy();r.icon:destroy() end
        if measure then measure:destroy();measure=nil end
        rows,opened,paused={},nil,false
    end
    function self.show(samples,settings,format,now,merge)
        local old={}
        local continuing=merge and opened~=nil
        if merge then for _,r in ipairs(rows) do old[r.definition.id]=r end else self.clear() end
        for _,s in ipairs(samples) do
            local d=s.definition
            local r=old[d.id]
            if not r then
                local style=copy(settings.gilText)
                style.flags.right,style.flags.bottom,style.flags.draggable=false,false,false
                style.pos={x=0,y=0}
                local amount_style=copy(style);amount_style.flags.right=true
                r={definition=d,direction=0,name=texts.new(style),amount=texts.new(amount_style),
                    icon=images.new({texture={path=path..'images/currencies/'..d.icon..'.png',fit=true},
                        size={width=23,height=23},color={alpha=255,red=255,green=255,blue=255},visible=false,draggable=false})}
                r.name:text(d.short)
                r.name:hide();r.amount:hide();r.icon:hide()
                rows[#rows+1]=r
            end
            if r.target~=s.amount then
                r.from=r.displayed or s.previous or s.amount
                r.target,r.changed=s.amount,now
                r.direction=s.previous and s.amount and (s.amount>s.previous and 1 or -1) or 0
            end
            r.format=format
        end
        if not measure then
            local style=copy(settings.gilText)
            style.flags.right,style.flags.bottom,style.flags.draggable=false,false,false
            style.pos={x=0,y=0}
            measure=texts.new(style);measure:hide()
            measure:text(format(8888888888))
        end
        -- A reply updates values; only a newly opened tray plays the entrance.
        if not continuing then opened=now end
        self.last_activity=now
    end
    function self.active() return opened~=nil end
    function self.render(now,opacity,settings,x,y,sw,sh,suspended)
        if not opened then return end
        if suspended then
            paused=true
            for _,r in ipairs(rows) do r.name:hide();r.amount:hide();r.icon:hide() end
            return
        elseif paused then opened,paused=now,false;self.last_activity=now end
        local elapsed=now-opened
        local idle=now-(self.last_activity or opened)
        if idle>=settings.currencyDelay+0.3 then self.clear();return end
        local exit=clamp((idle-settings.currencyDelay)/0.3)
        local nw,aw,height=0,0,23*settings.scale
        for _,r in ipairs(rows) do
            for _,w in ipairs({r.name,r.amount}) do
                w:size(math.max(1,math.floor(settings.gilText.text.size*settings.scale+0.5)))
                w:stroke_width(math.max(1,settings.gilText.text.stroke.width*settings.scale))
            end
            local p=settings.countDuration==0 and 1 or clamp((now-(r.changed or now))/settings.countDuration)
            r.displayed=r.target and ((r.from or r.target)+(r.target-(r.from or r.target))*p) or nil
            r.amount:text(r.displayed and r.format(math.floor(r.displayed+0.5)) or '--')
            -- Reserve a full 10-digit numeric slot using a hidden measurement
            -- primitive. Never substitute measurement text into a visible amount.
            measure:size(math.max(1,math.floor(settings.gilText.text.size*settings.scale+0.5)))
            measure:stroke_width(math.max(1,settings.gilText.text.stroke.width*settings.scale))
            local width=measure:extents()
            local name_width=r.name:extents();nw=math.max(nw,name_width);aw=math.max(aw,width)
            local color=r.direction==1 and settings.gainColor or settings.lossColor
            local mix=r.direction~=0 and (1-clamp((now-(r.changed or now)-settings.countDuration)/math.max(.001,settings.colorDuration))) or 0
            if settings.colorDuration==0 and p==1 then mix=0 end
            local base=settings.gilText.text
            r.amount:color(math.floor(base.red+(color.red-base.red)*mix),math.floor(base.green+(color.green-base.green)*mix),math.floor(base.blue+(color.blue-base.blue)*mix))
        end
        local scale=settings.scale
        local width=nw+aw+39*scale
        local left=settings.side=='left' and x-width-4*scale or x+27*scale
        left=math.max(2,math.min(left,sw-width-2))
        local down=y+23*scale+(height+3*scale)*#rows<=sh-2
        local direction=down and 1 or -1
        for i,r in ipairs(rows) do
            local p=clamp((elapsed-(i-1)*.03)/.2)*(1-exit)
            local ry=(down and y+23*scale or y-height)+direction*(i-1)*(height+3*scale)*(1-exit)-direction*5*scale*(1-p)
            r.icon:pos(left,ry);r.icon:size(23*scale,23*scale)
            local names=left+27*scale
            local nx,ax
            if settings.side=='left' then ax=names+aw;nx=ax+8*scale else nx=names;ax=names+nw+8*scale+aw end
            r.name:pos(nx,ry+3*scale);r.amount:pos(ax-sw,ry+3*scale)
            local alpha=opacity*p
            for _,w in ipairs({r.name,r.amount}) do
                w:alpha(math.floor(settings.gilText.text.alpha*alpha));w:stroke_alpha(math.floor(settings.gilText.text.stroke.alpha*alpha));w:bg_alpha(math.floor(settings.gilText.bg.alpha*alpha))
                if alpha>0 then w:show() else w:hide() end
            end
            r.icon:alpha(math.floor(255*alpha));if alpha>0 then r.icon:show() else r.icon:hide() end
        end
    end
    function self.destroy() self.clear() end
    return self
end
return tray
