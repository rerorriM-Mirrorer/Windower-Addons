local frames={}
package.preload.images=function() return {new=function(settings)
 local f={s=settings,shown=false}
 function f:hide() self.shown=false end
 function f:show() self.shown=true end
 function f:pos(x,y) self.x=x;self.y=y end
 function f:size(w,h) self.w=w;self.h=h end
 function f:alpha(a) self.a=a end
 function f:destroy() self.dead=true end
 frames[#frames+1]=f;return f
end} end
local g=dofile('gilfinder/glint.lua').new('gilfinder/')
assert(#frames==20)
g.place(10,20,34.5);g.render(0,1,true,.7)
for _,f in ipairs(frames) do assert(not f.shown and f.x==10 and f.w==34.5 and not f.s.draggable) end
g.trigger(0);g.render(.35,1,true,.7);assert(frames[11].shown)
g.render(.35,0,true,.7);assert(not frames[11].shown)
g.render(.8,1,true,.7);for _,f in ipairs(frames) do assert(not f.shown) end
g.trigger(1);g.render(1.1,1,false,.7);for _,f in ipairs(frames) do assert(not f.shown) end
g.trigger(2,true);g.render(2.3,.5,false,.7);local count=0;for _,f in ipairs(frames) do if f.shown then count=count+1;assert(f.a==105) end end;assert(count==1)
-- A render timestamp briefly earlier than the trigger used to produce
-- index <= 0 and frames[current] = nil on a subsequent draw.
g.stop()
g.trigger(100)
g.render(99,1,true,.7)
assert(frames[1].shown, 'negative relative time must clamp to frame one')
g.render(100.1,1,true,.7)
assert(not frames[1].shown and frames[3].shown,
    'frame progression must recover after clock/time ordering reversal')
g.destroy();for _,f in ipairs(frames) do assert(f.dead and not f.shown) end
print('PASS: glint frame timing, positioning/scaling, hidden alpha, disabled/forced preview, cleanup')
