local factory = dofile('gilfinder/wallet.lua')
local peers, queue, displays, logs, sent = {}, {}, {}, {}, {}
local clock=0
local function sample(name,server,gil) return {name=name,server=server,gil=gil} end
local balances={sample('Cioara',24,100),sample('Myrr',24,200),sample('Lionstag',24,300)}
for i=1,3 do
    peers[i]=factory.new({sample=function()
        local s=balances[i];return s and sample(s.name,s.server,s.gil)
    end,now=function() return clock end,
    schedule=function(fn,delay) queue[#queue+1]=fn end,
    send=function(message)
        sent[#sent+1]=message
        for _, peer in ipairs(peers) do peer.receive(message) end
    end,
    report=function(message) logs[#logs+1]=message end,
    display=function(rows) displays[i]=rows end})
end
local function flush() local q=queue;queue={};for _,fn in ipairs(q) do fn() end end
peers[1].request();local query=sent[1];peers[2].receive(query)
assert(#sent==3,'one query and one reply per other client; duplicate query ignored')
local reply=sent[2];peers[1].receive(reply)
flush();assert(#displays[1]==3 and displays[1][1].name=='Cioara' and displays[1][3].name=='Myrr')
local total=0;for _,r in ipairs(displays[1]) do total=total+r.gil end;assert(total==600)
assert(displays[2]==nil and displays[3]==nil,'only requester displays wallet')
-- Delayed/unrelated/malformed replies cannot enter a later request.
peers[1].request();peers[1].receive(reply);peers[1].receive('other-addon|R|999')
peers[1].receive('GFW1|Q|'..string.rep('x',300));flush();assert(#displays[1]==3)
-- Out-of-order overlapping requests: old timer must not close the new request.
peers[1].request();peers[1].request();flush();assert(#displays[1]==3)
-- Logged-out/zoning clients have no sample. Do not substitute stale cache or zero.
balances[3]=nil;clock=10;peers[1].request();flush();assert(#displays[1]==2)
-- Identical names on different servers are distinct entries.
balances[3]=sample('Myrr',25,400);peers[1].request();flush();assert(#displays[1]==3 and displays[1][3].server==25)
-- Reader is fresh on every request, not the displayed/interpolated HUD number.
balances[1].gil=555;peers[1].request();flush();assert(displays[1][1].gil==555)
peers[1].request();peers[1].cancel();displays[1]=nil;flush();assert(displays[1]==nil)
balances[1]=nil;peers[1].request();assert(#logs>0 and #queue==0)
-- A lone client is included even without self-echo IPC.
local one
one=factory.new({sample=function() return sample('Franklet',24,42) end,now=function() return 0 end,
 schedule=function(fn) queue[#queue+1]=fn end,send=function() end,report=function() end,
 display=function(rows) assert(#rows==1 and rows[1].gil==42) end})
one.request();flush()
print('PASS: wallet aggregation/deduplication, request isolation, partial responses, server identity, fresh balances, cancellation, self without echo')
