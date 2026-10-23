events.config();events.load();assert(stored.walletTotal==false and stored.gap==1)
assert(requests==1,'initial currency request')
local ix=widgets[1].x
cmd('gap','-3');assert(widgets[1].x==ix and widgets[2].x+1280==ix+3)
cmd('gap','5');assert(widgets[2].x+1280==ix-5)
cmd('side','right');local text_left=widgets[2].x+1280-#widgets[2].content*7
assert(text_left==ix+28,'coin width plus gap')
cmd('gap','nan');assert(stored.gap==5)
cmd('wallet','on');finish();frame(.4)
assert(#widgets==25 and widgets[25].s.flags.right,'one wallet row, no total')
events['addon command']('wallet','total','on');frame(.5)
assert(stored.walletTotal and #widgets==29 and widgets[29].content=='100')
events['addon command']('wallet','total','off');assert(not stored.walletTotal)
cmd('wallet','off');frame(1.1)
-- Unknown is distinct from a real zero; initial samples must not pop a tray.
local n=#widgets
events['incoming chunk'](0x113,{['Sparks of Eminence']=0,["Conquest Points (San d'Oria)"]=10,['Conquest Points (Bastok)']=20,['Conquest Points (Windurst)']=30})
assert(#widgets==n,'first currency sample is silent')
cmd('sp');frame(1.4)
assert(#widgets==n+4 and widgets[#widgets-2].content=='0','shortcut shows zero, not unknown')
assert(widgets[#widgets-2].s.flags.right and widgets[#widgets-1].shown)
local old=#widgets
cmd('sparsk');assert(#widgets==old,'suggestion does not silently choose')
cmd('cp');frame(1.8)
assert(#widgets==old+10,'cp shows three separate national balances')
assert(widgets[#widgets-2].content=='30')
frame(10);assert(widgets[#widgets-1].destroyed,'tray times out')
-- Two updates arriving together merge into one tray and count from old amounts.
events['incoming chunk'](0x113,{['Sparks of Eminence']=40,['Conquest Points (Windurst)']=25})
frame(10.2);local latest=#widgets-1
assert(widgets[latest-1].shown and widgets[latest-1].color_value[1]==222,'currency loss is pink')
frame(10.6);assert(widgets[latest-1].content=='25')
-- Wallet takes priority; pending currency changes wait without overlapping it.
cmd('wallet','on');finish();frame(10.7);assert(not widgets[latest].shown)
cmd('wallet','off');frame(11.3);assert(widgets[latest].shown)
cmd('auto');cmd('delay','1');cmd('wallet','on');finish();frame(11.4)
frame(13.3);frame(13.6);frame(13.7);assert(widgets[latest].shown,'queued tray gets its turn after natural wallet expiry')
cmd('hide');assert(widgets[latest].destroyed)
cmd('show');events['incoming chunk'](0x0A,{});events['incoming chunk'](0x1D,{})
cmd('sp');frame(14);assert(widgets[#widgets-2].content=='--','zone clears currency baseline')
frame(17.1);assert(messages[#messages]:find('timed out',1,true))
events.logout();events.unload();for _,w in ipairs(widgets) do assert(w.destroyed) end
print('PASS: wallet total/default/native anchors, signed coin gap, currency shortcut/query/zero/unknown, batch animation, wallet priority, timeout and cleanup')
