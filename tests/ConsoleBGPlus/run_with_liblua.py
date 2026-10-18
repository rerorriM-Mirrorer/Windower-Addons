"""Run the Lua mock checks using a local Lua 5.4 shared library.

Use a Lua 5.1/LuaJIT CLI when available instead: lua tests/ConsoleBGPlus/run.lua.
The shared-library route is a development fallback, not a Windower runtime test.
"""
import ctypes
import ctypes.util
import os
from pathlib import Path

root = Path(__file__).resolve().parents[2]
os.chdir(root)
(root / 'reference').mkdir(exist_ok=True)
os.environ['CBGPLUS_EXPORT_LAYOUT'] = '1'
library = ctypes.util.find_library('lua5.4')
if not library:
    raise SystemExit('Lua 5.4 shared library not found; use a Lua CLI for run.lua.')
lua = ctypes.CDLL(library)
lua.luaL_newstate.restype = ctypes.c_void_p
lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
lua.luaL_loadfilex.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_char_p]
lua.luaL_loadfilex.restype = ctypes.c_int
lua.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_void_p]
lua.lua_pcallk.restype = ctypes.c_int
lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.POINTER(ctypes.c_size_t)]
lua.lua_tolstring.restype = ctypes.c_char_p
lua.lua_close.argtypes = [ctypes.c_void_p]
state = lua.luaL_newstate()
try:
    lua.luaL_openlibs(state)
    result = lua.luaL_loadfilex(state, b'tests/ConsoleBGPlus/run.lua', None)
    if result == 0:
        result = lua.lua_pcallk(state, 0, -1, 0, 0, None)
    if result:
        error = lua.lua_tolstring(state, -1, None)
        raise SystemExit(error.decode('utf-8', errors='replace'))
finally:
    lua.lua_close(state)
