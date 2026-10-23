from pathlib import Path
import os
test_dir = Path(__file__).resolve().parent
os.chdir(test_dir.parent.parent if test_dir.parent.name == "gilfinder" else test_dir.parent)
from lupa.lua51 import LuaRuntime
for p in Path('gilfinder').glob('*.lua'):
    LuaRuntime().execute('assert(loadstring(...))',p.read_text())
    print('Lua 5.1 compiler PASS:',p.name)
LuaRuntime().execute((test_dir / 'behavior.lua').read_text())
# Exercise the unload dispatch separately from the restart path.
s=(test_dir / 'behavior.lua').read_text().replace("cmd('restart');cmd('restart')", "cmd('unload');cmd('unload')").replace("commands[1]=='lua reload gilfinder'", "commands[1]=='lua unload gilfinder'")
LuaRuntime().execute(s)
# Windower XML permits numeric element names; normalize those only for parsing.
import re
import xml.etree.ElementTree as ET
xml=Path('gilfinder/docs/Personal-settings-template.xml').read_text()
root=ET.fromstring(re.sub(r'<(/?)([0-9]+)>',r'<\1item\2>',xml))
def value(e):
    if list(e):
        return {int(c.tag[4:]) if c.tag.startswith('item') else c.tag:value(c) for c in e}
    t=(e.text or '').strip()
    if t in ('true','false'): return t=='true'
    try: return float(t) if '.' in t else int(t)
    except ValueError:return t
profiles={e.tag:value(e) for e in root}
prefix=(test_dir / 'behavior.lua').read_text().split("assert(_addon.name")[0]
for name in ['global','cioara','killala','myrr']:
    lua=LuaRuntime()
    def tbl(d): return lua.table_from({k:tbl(v) if isinstance(v,dict) else v for k,v in d.items()})
    lua.globals().PROFILE=tbl(profiles.get(name,{}))
    code=prefix.replace('stored=copy(d);return stored', '''stored=copy(d)
        local function merge(a,b) for k,v in pairs(b) do if type(v)=='table' then a[k]=a[k] or {};merge(a[k],v) else a[k]=v end end end
        merge(stored,PROFILE);return stored''')
    # Profile checks use the intended tall display, not the recovery test size.
    code=code.replace('ui_x_res=1280,ui_y_res=720','ui_x_res=3840,ui_y_res=2160')
    stored,widgets,events=lua.execute(code+'\nevents.config();events.load();return stored,widgets,events')
    expected=profiles[name]
    def check(actual,expected,path=''):
        for k,v in expected.items():
            if path+str(k)=='gilImage.texture.path':continue
            if isinstance(v,dict):check(actual[k],v,path+str(k)+'.')
            else:assert actual[k]==v,(name,path+str(k),actual[k],v)
    check(stored,expected)
    assert stored['hideInCutscenes'] is False
    events['status change'](4)
    assert widgets[1]['shown'] is True
    print('Personal XML profile PASS:',name)

for name in ['wallet.lua','migration.lua','glint.lua','currencies.lua']:
    LuaRuntime().execute((test_dir / name).read_text())

from PIL import Image
root=Path('gilfinder')
coin=Image.open(root/'gil.png').convert('RGBA')
frames=sorted((root/'images/glint').glob('*.png'))
assert len(frames)==20
for path in frames:
    im=Image.open(path).convert('RGBA')
    assert im.size==coin.size
    assert all(a<=b for a,b in zip(im.getchannel('A').tobytes(),coin.getchannel('A').tobytes()))
print('PASS: glint asset count, dimensions and coin alpha mask')

# Integration coverage for the animated panel and native menu transition state.
prefix=(test_dir/'behavior.lua').read_text().split("assert(_addon.name")[0]
prefix=prefix.replace('local now, gil, buttons, focused = 0, 100, false, true', 'local now, gil, buttons, focused, menu = 0, 100, false, true, false\nlocal scheduled = {}')
prefix=prefix.replace('logged_in=true,server=24','logged_in=true,server=24,menu_open=menu')
prefix=prefix.replace('coroutine.schedule=function() end', 'coroutine.schedule=function(fn,delay) if delay>0 then scheduled[#scheduled+1]=fn end end\nlocal function finish() local jobs=scheduled;scheduled={};for _,fn in ipairs(jobs) do fn() end end')
LuaRuntime().execute(prefix+(test_dir/'interactions.lua').read_text())

# A progressing clock exposes wake() taking a later timestamp inside render().
clock_prefix=prefix.replace('os.clock=function() return now end',
    'local tick=0;os.clock=function() tick=tick+0.00001;return now+tick end')
clock_prefix=clock_prefix.replace("dofile('gilfinder/gilfinder.lua')", """
local factory=require('glint').new
local future=false
require('glint').new=function(path)
 local g=factory(path)
 local trigger,render=g.trigger,g.render
 local started
 g.trigger=function(t,preview) started=t;trigger(t,preview) end
 g.render=function(t,...) if started and t<started then future=true end;render(t,...) end
 return g
end
dofile('gilfinder/gilfinder.lua')
""")
LuaRuntime().execute(clock_prefix+"""
events.config();events.load();frame(1)
menu=true;frame(2)
assert(not future,'menu glint must not start after its render timestamp')
events.unload()
print('PASS: progressing-clock menu trigger/render ordering')
""")

# Currency UI and wallet formatting/controls share the normal Windower mock.
ui_prefix=prefix.replace("package.preload.packets=function() return {parse=function(_,p) return p end} end", "local requests=0;package.preload.packets=function() return {parse=function(_,p) return p end,new=function(_,id) assert(id==0x10F);return {} end,inject=function() requests=requests+1 end} end")
LuaRuntime().execute(ui_prefix+(test_dir/'currency_ui.lua').read_text())
for name in ['sparks','sandoria','bastok','windurst']:
    im=Image.open(Path('gilfinder/images/currencies')/(name+'.png'))
    assert im.size==(23,23) and im.mode=='RGBA'
print('PASS: four provisional currency badge assets')
