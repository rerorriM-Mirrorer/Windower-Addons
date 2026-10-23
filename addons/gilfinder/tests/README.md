# Simulated checks

These files are not loaded by the addon. With Python, lupa, and Pillow
installed, run `python path/to/gilfinder/tests/run.py` from any directory.
The runner uses Lua 5.1 and mocked Windower APIs. It does not launch FFXI.
Windows controller FFI and live packets are not certified by these checks.

Test 2 adds interactions.lua: menu boolean transitions, expanded glint triggers,
show/hide/auto semantics and panel lifecycle. The runner reuses the Windower
mock prelude from behavior.lua and injects a controllable scheduler/menu state.

1.5.2: glint.lua tests stale invalid current indices in stop/destroy using Lua
upvalue fault injection. run.py adds a progressing-clock menu integration check
that observes trigger/render timestamp ordering directly, independently of the
index clamp. Both regressions were checked to fail against v1.5.1 source.
