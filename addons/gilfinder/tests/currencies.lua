local catalog=dofile('gilfinder/currencies.lua')
assert(#catalog.search('cp')==3 and #catalog.search('sp')==1 and catalog.search('sp')[1].id=='sparks')
assert(#catalog.search('conquest points')==3 and #catalog.search('wind')==1)
assert(#catalog.search('sparsk')==0 and catalog.suggest('sparsk').id=='sparks')
assert(#catalog.search('.*')==4,'punctuation never interpreted as Lua pattern')
local ready,requests,updates,changed=true,0,0,{}
local c=catalog.new({ready=function() return ready end,request=function() requests=requests+1 end,
 parse=function(_,p) if p=='bad' then error('bad packet') end return p end,
 updated=function(rows) updates=updates+1;changed=rows end})
c.tick(0);assert(requests==1)
c.request(.1);c.tick(1);assert(requests==1);c.tick(2);assert(requests==2,'throttled request deferred, not lost')
local packet={['Sparks of Eminence']=100,["Conquest Points (San d'Oria)"]=1,['Conquest Points (Bastok)']=2,['Conquest Points (Windurst)']=3}
c.receive(0x113,packet,3);assert(updates==1 and #changed==0,'first reply is baseline')
c.receive(0x110,{['Sparks Total']=120},4);assert(#changed==1 and changed[1].previous==100 and changed[1].amount==120)
packet['Sparks of Eminence']=90;packet['Conquest Points (Windurst)']=1
c.receive(0x113,packet,5);assert(#changed==2,'batch both losses')
local n=updates;c.receive(0x113,'bad',6);c.receive(0x113,{['Sparks of Eminence']=-1},6);assert(updates==n)
ready=false;c.receive(0x110,{['Sparks Total']=999},7);assert(c.rows(catalog.search('sp'))[1].amount==90)
c.reset();assert(c.rows(catalog.search('sp'))[1].amount==nil,'no balances leak across sessions')
assert(c.request(8)==false);ready=true;c.tick(8);assert(requests==3)
local known=c.status(8);assert(known==0)
print('PASS: currency aliases/substrings/suggestions, requests/throttle/defer, baseline/change batches, invalid packets and session reset')
