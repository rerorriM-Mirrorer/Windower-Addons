local migration=dofile('gilfinder/migrate.lua')
local input=[[<?xml version="1.1" ?><settings>
<global><autohide>true</autohide><visibility>change</visibility><scale>1.5</scale></global>
<cioara><autohide>false</autohide><visibility>input</visibility><gilText><pos><x>-169</x><y>-2137</y></pos></gilText></cioara>
<myrr><autohide>false</autohide></myrr>
</settings>]]
local out,changed=migration.convert(input)
assert(changed and not out:find('<autohide>'))
assert(out:find('<visibility>input</visibility>',1,true),'explicit mode beats contradictory old flag')
assert(out:find('<myrr><visibility>always</visibility></myrr>',1,true))
assert(out:find('<scale>1.5</scale>',1,true) and out:find('<y>-2137</y>',1,true))
local again,second=migration.convert(out);assert(again==out and not second)
local legacy=migration.convert('<settings><global><autohide>false</autohide></global><myrr><autohide>true</autohide></myrr></settings>')
assert(legacy:find('<global><visibility>always</visibility></global>',1,true))
assert(legacy:find('<myrr><visibility>change</visibility></myrr>',1,true))
local disk={['data/settings.xml']=input}
package.loaded.files=nil
package.preload.files=function() return {new=function(path)
 return {exists=function() return disk[path]~=nil end,read=function() return disk[path] end,
 write=function(_,text) disk[path]=text end}
end} end
migration.run();assert(disk['data/settings-before-wallet.xml']==input and disk['data/settings.xml']==out)
migration.run();assert(disk['data/settings-before-wallet.xml']==input)
print('PASS: visibility migration, explicit precedence, boolean-only sections, coordinate preservation, idempotence and backup')
