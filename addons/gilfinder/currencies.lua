-- A: narrowly scoped currency observation/request layer; no purchases or IPC.
local currencies = {}
local definitions = {
    {id='sparks',name='Sparks of Eminence',short='Sparks',field='Sparks of Eminence',icon='sparks',aliases={'sp','sparks','eminence','roe'}},
    {id='sandoria',name="Conquest Points (San d'Oria)",short="San d'Oria CP",field="Conquest Points (San d'Oria)",icon='sandoria',aliases={'sandoria','sandy','sandoria cp'}},
    {id='bastok',name='Conquest Points (Bastok)',short='Bastok CP',field='Conquest Points (Bastok)',icon='bastok',aliases={'bastok','bastok cp'}},
    {id='windurst',name='Conquest Points (Windurst)',short='Windurst CP',field='Conquest Points (Windurst)',icon='windurst',aliases={'windurst','windy','windurst cp'}},
}
local function normalize(s) return s:lower():gsub('[%s%p]','') end
function currencies.search(term)
    local key=normalize(term or '')
    if key=='' or key=='all' or key=='currencies' then return definitions end
    if key=='cp' or key=='conquest' then return {definitions[2],definitions[3],definitions[4]} end
    for _,d in ipairs(definitions) do
        if normalize(d.name)==key or d.id==key then return {d} end
        for _,a in ipairs(d.aliases) do if normalize(a)==key then return {d} end end
    end
    local matches={}
    for _,d in ipairs(definitions) do
        if normalize(d.name):find(key,1,true) then matches[#matches+1]=d end
    end
    return matches
end
local function distance(a,b)
    local prev={};for j=0,#b do prev[j]=j end
    for i=1,#a do
        local row={[0]=i}
        for j=1,#b do row[j]=math.min(row[j-1]+1,prev[j]+1,prev[j-1]+(a:sub(i,i)==b:sub(j,j) and 0 or 1)) end
        prev=row
    end
    return prev[#b]
end
function currencies.suggest(term)
    local best,score
    for _,d in ipairs(definitions) do for _,a in ipairs(d.aliases) do
        local n=distance(normalize(term),normalize(a))
        if not score or n<score then best,score=d,n end
    end end
    if score and score<=2 then return best end
end
function currencies.new(api)
    local values,last_request,last_tick,pending={},nil,nil,false
    local self={}
    function self.reset() values,last_request,last_tick,pending={},nil,nil,false end
    function self.request(now)
        if not api.ready() then return false,'Character inventory is not ready.' end
        if last_request and now-last_request<2 then pending=true;return true end
        local ok,err=pcall(api.request)
        if not ok then return false,'Currency request failed: ' .. tostring(err) end
        last_request=now;pending=false
        return true
    end
    function self.tick(now)
        if not api.ready() then return end
        if pending and (not last_request or now-last_request>=2) then pending=false;self.request(now) end
        if not last_tick or now-last_tick>=60 then last_tick=now;self.request(now) end
    end
    function self.receive(id,data,now)
        if not api.ready() or (id~=0x113 and id~=0x110) then return end
        local ok,p=pcall(api.parse,id,data)
        if not ok or type(p)~='table' then return end
        local changes={}
        local valid=0
        for _,d in ipairs(definitions) do
            local n=id==0x110 and d.id=='sparks' and p['Sparks Total'] or (id==0x113 and p[d.field])
            if type(n)=='number' and n==n and n>=0 and n<=2147483647 and n==math.floor(n) then
                valid=valid+1
                local old=values[d.id]
                values[d.id]={amount=n,seen=now}
                if old and old.amount~=n then changes[#changes+1]={definition=d,amount=n,previous=old.amount} end
            end
        end
        -- The first sample establishes a baseline; it is not an earned amount.
        if valid>0 then api.updated(changes,now) end
    end
    function self.rows(selection)
        local rows={}
        for _,d in ipairs(selection) do
            local v=values[d.id]
            rows[#rows+1]={definition=d,amount=v and v.amount or nil,seen=v and v.seen or nil}
        end
        return rows
    end
    function self.status(now)
        local n,oldest=0,nil
        for _,v in pairs(values) do n=n+1;oldest=math.max(oldest or 0,now-v.seen) end
        return n,oldest
    end
    return self
end
return currencies
