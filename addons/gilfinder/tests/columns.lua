events.config();events.load()
local query
windower.send_ipc_message=function(m) query=m:match('^GFW1|Q|(.+)$') end
cmd('wallet','on')
events['ipc message']('GFW1|R|'..query..'|24|Lionstag|12345678')
finish();frame(.4)
local function columns()
 local axis=widgets[2].x+1280
 local amount_count=0
 for i=24,#widgets do
  local w=widgets[i]
  if not w.destroyed and w.s.flags.right then
   assert(w.x+1280==axis,'wallet ones-place axis must equal main gil amount axis')
   amount_count=amount_count+1
  elseif not w.destroyed then
   if stored.side=='left' then assert(w.x>widgets[1].x+23,'name column is across coin from amounts')
   else assert(w.x+#w.content*7<widgets[1].x,'name column is across coin from amounts') end
  end
 end
 assert(amount_count==(stored.walletTotal and 3 or 2))
end
columns();cmd('side','right');columns()
events['addon command']('wallet','total','on');columns()
cmd('side','left');columns()
-- A refresh may change values, but must not rewind the currency entrance.
local catalog=require('currencies')
local tray=require('currency_tray').new('gilfinder/')
local sample={definition=catalog.search('sp')[1],amount=12345}
local before=#widgets
tray.show({sample},stored,tostring,1,false)
local amount,icon=widgets[before+2],widgets[before+3]
tray.render(1.4,1,stored,500,100,1280,720,false)
local x,y=amount.x,amount.y
tray.show({sample},stored,tostring,2,true)
tray.render(2,1,stored,500,100,1280,720,false)
assert(amount.alpha_value[1]==255 and amount.x==x and amount.y==y,'unchanged refresh must not replay entrance or move rows')
local writes={}
local original=amount.text
amount.text=function(self,value)
 if value then writes[#writes+1]=value end
 return original(self,value)
end
sample.amount,sample.previous=123456,12345
tray.show({sample},stored,tostring,3,true)
tray.render(3.2,1,stored,500,100,1280,720,false)
assert(#writes==1,'visible amount must never be replaced by a measurement string')
assert(amount.x==x,'digit growth must retain the currency numeric axis')
tray.destroy();events.unload()
print('PASS: main/wallet shared ones-place axis, separate name column on both sides, total axis, no refresh entrance or visible measurement substitution')
