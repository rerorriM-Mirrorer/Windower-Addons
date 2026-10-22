-- Mocked Windower regression suite. Run with Lua 5.1, not inside FFXI.
package.path = 'gilfinder/?.lua;' .. package.path
package.preload.files=function() return {new=function() return {exists=function() return false end} end} end
local events, widgets, stored, saves, messages, commands = {}, {}, nil, 0, {}, {}
local now, gil, buttons, focused = 0, 100, false, true
os.clock=function() return now end
local function copy(t) if type(t)~='table' then return t end local r={} for k,v in pairs(t) do r[k]=copy(v) end return r end
package.preload.chat=function() string.color=function(t) return t end return {} end
package.preload.config=function() return {load=function(d) stored=copy(d);return stored end,save=function() saves=saves+1 end,register=function(s,f) events.config=function() f(s) end end} end
package.preload.controller=function() return {status='mock',held=function() return buttons and focused end,focused=function() return focused end} end
local function new(s)
 local w={s=s,shown=false,content=''}
 for _,n in ipairs{'size','stroke_width','stroke_alpha','bg_alpha','alpha','draggable','color','path'} do w[n]=function(self,...) self[n..'_value']={...} end end
 function w:text(t) if t==nil then return self.content end self.content=t end
 function w:extents() return #self.content*7,14 end
 function w:pos(x,y) self.x=x;self.y=y end
 function w:show() self.shown=true end
 function w:hide() self.shown=false end
 function w:destroy() self.destroyed=true end
 function w:hover(x,y) return self.shown and x==10 and y==10 end
 widgets[#widgets+1]=w;return w
end
package.preload.images=function() return {new=new} end
package.preload.texts=function() return {new=new} end
package.preload.packets=function() return {parse=function(_,p) return p end} end
_addon={}
windower={addon_path='gilfinder/',get_windower_settings=function() return {ui_x_res=1280,ui_y_res=720} end,add_to_chat=function(_,m) messages[#messages+1]=m end,send_command=function(c) commands[#commands+1]=c end,send_ipc_message=function() end,register_event=function(n,f) events[n]=f end,ffxi={get_info=function() return {logged_in=true,server=24} end,get_player=function() return {status=0,name='Cioara'} end,get_items=function() return gil end}}
coroutine.schedule=function() end
local function frame(t) now=t;events.prerender() end
local function cmd(c,a) events['addon command'](c,a) end
local function balance(n) gil=n;events['incoming chunk'](0x20,{Item=65535,Count=gil}) end
dofile('gilfinder/gilfinder.lua')
assert(_addon.name=='gilfinder' and #_addon.commands==1 and _addon.commands[1]=='gil')
assert(_G.update_gil==nil and _G.defaults==nil and _G.config==nil,'no implementation globals')
events.config();stored.glint=false;events.load();assert(widgets[1].shown and widgets[2].content=='100')
frame(60.25);assert(widgets[1].alpha_value[1]==127);frame(61);assert(not widgets[1].shown)
balance(200);assert(widgets[1].shown and widgets[2].content=='100' and widgets[2].color_value[1]==166)
frame(61.2);assert(widgets[2].content=='150');balance(80);assert(widgets[2].content=='150' and widgets[2].color_value[1]==222)
frame(61.6);assert(widgets[2].content=='80');frame(62.5);assert(widgets[2].color_value[1]==253);frame(122);assert(not widgets[1].shown)
cmd('show');local ix=widgets[1].x;cmd('side','right');assert(widgets[1].x==ix and widgets[2].x+1280-#widgets[2].content*7>ix+23)
cmd('side','left');assert(widgets[1].x==ix and widgets[2].x+1280<ix)
cmd('scale','1.5');assert(widgets[1].size_value[1]==34.5)
assert(events.mouse(1,10,10,0,false));events.mouse(0,30,40,0,false);assert(events.mouse(2,30,40,0,false));assert(stored.gilText.pos.x==-265 and stored.gilText.pos.y==-5)
cmd('lock');assert(not events.mouse(1,10,10,0,false));cmd('mode','input');frame(183);assert(not widgets[1].shown)
balance(90);assert(not widgets[1].shown);events.mouse(1,10,10,0,false);assert(not widgets[1].shown)
events.keyboard(30,true);assert(widgets[1].shown);frame(300);assert(widgets[1].shown);events.keyboard(30,false);frame(361);assert(not widgets[1].shown)
buttons=true;frame(400);assert(widgets[1].shown);frame(500);assert(widgets[1].shown);buttons=false;frame(561);assert(not widgets[1].shown)
events.keyboard(30,true);focused=false;frame(562);focused=true;frame(623);assert(not widgets[1].shown)
cmd('mode','always');frame(999);assert(widgets[1].shown)
events['status change'](4);assert(widgets[1].shown,'cutscene hiding defaults off')
cmd('cutscenes','on');assert(not widgets[1].shown);cmd('cutscenes','off');assert(widgets[1].shown)
cmd('cutscenes','on');events['status change'](0);assert(widgets[1].shown)
cmd('edit','on');cmd('edit','on');assert(not stored.locked and widgets[3].shown)
frame(1100);assert(widgets[3].shown);cmd('edit','off');cmd('edit','off');assert(stored.locked and not widgets[3].shown)
stored.gilText.pos.y=-2137;events.config();assert(widgets[1].y>=0,'off-screen profile recovers on small resolution')
cmd('pos','reset');assert(stored.gilText.pos.x==-285 and stored.gilText.pos.y==-35)
cmd('hide');assert(not widgets[1].shown);cmd('auto');assert(widgets[1].shown);cmd('show')
local before=#messages;cmd();assert(#messages>before+10 and messages[#messages]:find('//gil unload',1,true))
before=#messages;cmd('bogus');assert(#messages>before+10)
before=#messages;cmd('mode','bad');assert(#messages>before+10)
events.logout();assert(not widgets[1].shown);gil=9999;events.load();assert(widgets[2].content=='9,999' and widgets[2].color_value[1]==253)
cmd('mode','change');frame(1161);assert(not widgets[1].shown);cmd('counttime','0');cmd('colortime','0');balance(10000);frame(1161.01);assert(widgets[2].content=='10,000' and widgets[2].color_value[1]==253)
cmd('delay','0');assert(stored.hideDelay==60);cmd('delay','3601');assert(stored.hideDelay==60);cmd('delay','1');assert(stored.hideDelay==1);cmd('delay','3600');assert(stored.hideDelay==3600)
cmd('scale','0');assert(stored.scale==1.5);cmd('counttime','-1');assert(stored.countDuration==0)
assert(stored.gilText.text.size==9 and stored.gilText.text.alpha==255)
cmd('mode','always');cmd('mode');assert(stored.visibility=='change');cmd('mode');assert(stored.visibility=='input');cmd('mode');assert(stored.visibility=='always' and stored.autohide==nil)
cmd('glint','on');balance(11000);frame(1161.20)
local seen=0;for i=4,23 do if widgets[i].shown then seen=seen+1 end end;assert(seen==1,'gain shows one glint frame')
balance(10500);frame(1161.21);seen=0;for i=4,23 do if widgets[i].shown then seen=seen+1 end end;assert(seen==1,'loss also glints')
cmd('glint','off');cmd('glint','preview');assert(stored.glint==false,'preview preserves disabled preference')
frame(1161.25);seen=0;for i=4,23 do if widgets[i].shown then seen=seen+1 end end;assert(seen==1)
cmd('wallet');cmd('show');cmd('restart');cmd('restart');frame(1161.50);assert(widgets[1].alpha_value[1]>0 and widgets[1].alpha_value[1]<255)
frame(1162);frame(1163);assert(#commands==1 and commands[1]=='lua reload gilfinder')
events.unload();assert(saves>1 and widgets[1].destroyed and widgets[2].destroyed and widgets[3].destroyed)
print('PASS: regression behavior, rename, cutscenes, edit idempotence/guides, help, recovery, graceful restart/cleanup, no implementation globals')
