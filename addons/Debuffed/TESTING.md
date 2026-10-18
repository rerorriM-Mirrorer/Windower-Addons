# TESTING — Debuffed Icon Presentation

## Current development — Test 2.4.4 Grid 1 (2026-10-18)

- **Repo / source branch:** `rerorriM-Mirrorer/Windower-Addons`, starting at `work/debuffed-icons` commit `667da6e`; candidate on `work/debuffed-ctrl-grid` (keeps live-used version separate).
- **Scope:** Icon field positioning only. Native `images.lua` retains mouse capture; callback simply observes left/right Ctrl (DIK 29/157) without consuming keyboard input. The field's single draggable backdrop is the absolute screen-origin grid anchor.
- **Commands:** `//db grid` reads spacing; `//db grid <1-200>` persists an integer pixel spacing, default 10, independent of icon size or layout.
- **Bounds:** Clamp top-left anchor using actual rendered widget width/height and Windower UI resolution. A widget larger than the viewport is pinned to origin on the overflowing axis; resize layout to restore movement. Live resolution changes re-bound the field.
- **Source preservation:** Tracker section `function handle_overwrites` through the incoming-chunk handler remains byte-for-byte identical to Test 2.4.3. Existing fade, preview, and restart/unload shutdown sequence is unmodified apart from passing the Ctrl flag to its existing position flush.
- **Packaging:** Install the `Debuffed/` directory into `Windower/addons/`. Do not overwrite `data/settings.xml` and do not nest addon folders. See README for XivParty icon dependency. Place workflow/testing guidance alongside the addon according to the current canonical rules.

### Verification completed — offline only

- **Lua parser:** `texlua` loadfile syntax checks for `Debuffed.lua` and `icon_renderer.lua`: PASS. `texlua` is not a full Windower 4/Lua 5.1 compatibility or input test.
- **Renderer mock:** PASS — free dragging to precise pixels; screen-origin Ctrl snapping (10 and custom 16px); immediate return to free drag; bounds on 320×240, 960×540, 1280×720, 1600×900, 3840×2160; viewport resize without mouse motion; oversized field fallback; saved-position debounce; 12px and 96px icons with repeated resizing and no cumulative geometry drift; icon/outline/sample/timer common anchoring; preview/exit and teardown paths.
- **Modifier path:** PASS by code inspection — DIK 29/157 are separately tracked, and the passive `keyboard` callback returns no keyboard-blocking result. Full key-down/mouse-drag integration is NOT tested in a Windower client.
- **Regression diff:** PASS — original tracker unchanged; only version, grid defaults/command, passive modifier observation, positional clamp/snap path, and documentation modified. No new scale factor introduced; existing `iconsize` remains pixel-based.
- **Actual FFXI verification:** NOT performed; please verify free drag, both Ctrl keys, edit preview, live icon positioning, settings persistence across reload, narrow-window boundaries, target switches, restart, and unload.

### In-game verification checklist (pending)

1. Back up installed `Debuffed/` and its settings; install test build and `//lua r Debuffed`; check `//db status` and `//db grid` (10px).
2. Drag field freely to a non-grid position, e.g. `(273,57)`; confirm smooth pixel placement. Hold **left Ctrl** while moving and check `(270,50)`-style snapping. Repeat with **right Ctrl**; check release restores free dragging.
3. Run `//db grid 16`, test screen-origin multiples of 16, then `//db grid 10`; reload and confirm grid/position persist.
4. Test near each screen edge, on large screen and smaller multibox window (e.g. 3840×2160 desktop, 1600×900, 1280×720 and 960×540 clients). Confirm readable onscreen field and sensible behavior if configured field exceeds viewport.
5. Try `//db edit on`, 12px and 96px `//db iconsize` (restoring 24 afterward), horizontal/vertical wrap, target name, and real debuffs. Check children remain aligned to the field while dragging or after settings changes.
6. Confirm preview starts, its 11..0 counter and the edit countdown still run; `//db restart`, `//db unload`, and saved position still work. Check classic text fallback is unchanged.

### Pre-existing layout observations — reported separately, not redesigned

- Debuffed already uses the draggable backdrop as one anchor; guide samples deliberately inset by one pixel, and timer labels are centered from text extents when available. No pre-existing coordinate-system split was found in the icon layout.
- Text/font metrics, outline strokes and fixed-pixel insets may appear a pixel off at extreme icon sizes or different DPI; that should be assessed in-game before changing unrelated rendering design.
- Existing transparent drag rectangle can still intercept mouse input even when alpha is zero; fixing this would change the known-good drag interaction and was intentionally kept outside the current scope.
- The separate classic text fallback does not share the backdrop's drag anchor; it is deliberately untouched.

---

## Previous development — Test 2.4.3 (2026-10-13)

## Current delivery

**Batch:** Test 2.4.3 (2026-10-13)  
**Build ID:** `1.0.0.4-icons-test2.4.3`  
**Base:** Test 2.4.2 compact-timer source, GitHub revision `0735414` on `work/debuffed-icons`.  
**Git:** Test 2.4 restored in `a92dda3`, color refinement in `02f38d1`, 2.4.2 compact timers repaired at `0735414`. Latest 2.4.3 revision is maintained on `work/debuffed-icons`; `dev` untouched.  
**Original tracker:** From `function handle_overwrites` through the incoming-chunk handler, byte-for-byte identical to Test 2.3 (scripted comparison).
**Delta from 2.4.2:** Chat help prints neutral white descriptions and full `//db` command prefix with `->` arrow; edit dummy timer counts 61..0 instead of 70..0. Manual preview, live tracker and restart/unload unchanged.

### Installation precautions

Extract at `Windower/addons/` (archive contains `Debuffed/`). Avoid nesting `Debuffed/Debuffed/`. Preserve `Debuffed/data/settings.xml`. The `WORKFLOW.md` and `TESTING.md` files are in the ZIP root for developer reference; install only the `Debuffed/` folder. XivParty is needed separately for icon textures.

### Try these first

1. In game: `//lua reload Debuffed`. Confirm short intro and fade. Optionally use `//db status` to verify Test 2.4.3.
2. Run `//db slots 16` and `//db wrap 16`, since existing settings can still say 32.
3. Run `//db edit` and confirm 16 familiar **outlined edit squares** each containing a semi-transparent example icon. The timer should show `1m` for the first 2 seconds (61 and 60 remaining), then `59`, `58` ... `0`, resetting to `1m` each cycle. Check that moving field works and `//db edit off` removes the samples without losing the position.
4. Run `//db preview` outside edit mode. Confirm 11..0 labels on example icons over 12 seconds, then faded disappearance. Confirm that actual debuff tracker is unaffected.
5. Adjust `//db timersize 7`, `//db timerx -2`, `//db timery -4` while editing; confirm sample timers reposition/sizes update. Restore preferences.
6. Run `//db help`, verify the full BattleStations-like palette: yellow/warm borders, contrasting title/section, accented `//db` and `->`, light syntax, **white** descriptions. Help appears **only in FFXI chat**, not duplicated in console.
7. Test `//db restart`: chat reports restart, icons/edit presentation fade, addon comes back with intro. Test `//db unload`: fades and stays unloaded; restore with `//lua load Debuffed`.
8. Apply Dia to an enemy and ensure it appears first; verify real timer/target/debuff removal in combat. Test with other concurrent Windower clients when convenient.

### Offline checks completed

- Syntax: `luatex --luaonly` loadfile for both Lua modules: **PASS**.
- Renderer mock (earlier baseline): intro; fade; 11..0 manual; 1:10→0:00→reset edit samples; guide + icon + timer layering; X/Y timer offsets; resizing; wrapping; live sprite; orderly cleanup; fade before unload: **PASS** (from Test 2.4.1; the timer-format change is separately checked below).
- Command mock: default slots/wrap 16, help output via chat only, edit on, wrapping/slot changes, manual preview notice, shutdown delay, exactly one `lua r Debuffed` or `lua u Debuffed` after fade: **PASS**.
- Original tracking section compared to Test 2.3: **PASS / unchanged**.

**Not tested:** actual Windower runtime, XivParty texture rendering and color codes in the FFXI chat window, physical controller behavior, live effect expiration semantics. Do not assume offline simulations establish those.

- Test 2.4.2 timer formatting cases (unchanged): `1796s → 29m`, `70s → 1m`, `60s → 1m`, `59.9s → 59`, `1s → 1`, plus edit 70..0 and manual 11..0: **PASS** (offline; pending in-game).

### Known risks / follow-ups

- Many help lines may scroll the game chat; consider grouped/help topic pages if this becomes intrusive.
- The whole transparent icon rectangle remains mouse-draggable in normal mode, as in earlier builds.
- Icon count increases primitives and rendering load per client.
- The original effect duration uses `os.clock`, not real wall time; no tracking changes were attempted in this presentation batch.
- Native FFXI text extents and `Arial Bold Italic` presentation may differ from offline estimates.

## Earlier batches

- **Test 2.4.2 (2026-10-13):** Native-style timers, 70-second edit preview; published and verified with corrective Git revision `0735414`.

- **Test 2.4.1 (2026-10-13):** BattleStations color hierarchy on top of Test 2.4; committed as `02f38d1`.

- **Test 2.4 (2026-10-13):** preserved in Git as commit `a92dda3` after the original testing ZIPs had remained uncommitted. This catch-up does **not** fabricate separate historical commits. Added animated 11..0 preview, edit sample countdowns, 16-slot defaults, fade-aware reload/unload, colored help. User liked the help appearance, but the precise color palette was not yet verified in-game.


- **Test 2.3 (2026-10-10):** timer typography, icon count, wrap, `//db`; earlier Test 2.2 behavior was visibly confirmed by the user; new Test 2.3 features were not individually confirmed. This is the source baseline, not a claim of full live validation.
- **Test 2.2:** chat log feedback and edit outlines; user liked the individual slot guides and startup animation after correcting nested folder installation.
- **Test 2.1:** startup sample preview texture timing fixes and diagnostics.
- **Test 2:** initial startup/exit fading and Dia-first sorting.
- **Test 1:** original Windower Debuffed tracking plus icon presentation adapter.

## User-provided test observations / requirements

- The startup animation was described as lovely; 32 individual edit square guides were liked.
- Earlier confusing “no animation” reports were partly caused by extracting archives into the already existing Debuffed directory, creating `Debuffed/Debuffed/`.
- User requested BattleStations-style help, chat-only help output, sample timer animations, 16/16 defaults, and standardized restart/unload behavior.

## Test 2.4.3 specific checks

- **Offline syntax:** LuaTeX `loadfile` for `Debuffed.lua` and `icon_renderer.lua`: **PASS**.
- **Mocked help output:** 33 ordered chat lines, 26 `//db` examples, white base color `0`, accented `->`, zero calls to console: **PASS**. Actual in-game color rendering is unverified.
- **Timer bounds:** edit time 61s→`1m`, 60s→`1m`, 59s→`59`, 1s→`1`, 0s→`0`, 62s loop reset→`1m`; 29m56s→`29m`; manual preview 11..0 code unchanged: **PASS**.
- **Regression scope:** diff from 2.4.2 changes only build marker, help output, edit dummy timer counter, and documentation. Restart/unload and packet tracker untouched: **PASS** (static). User previously reported restart and unload working in FFXI.
- **Live status:** FFXI render and colors for Test 2.4.3 untested; do not label as live-verified.

- Inspect chat help `//db help`: every entry must begin with distinct-colored `//db`; arrow should be `->` (verify FFXI glyph renders cleanly); descriptions should be true neutral white, not pale command color; headings and separators remain as before. No console duplicate.
- `//db edit on`: verify first sample reads `1m` for about two seconds, then `59` `58` ... `0` and resets; outline squares remain visible and semi-transparent icons persist. Manual `//db preview` still counts `11` to `0`.
- Regression: `//db restart` and `//db unload` should still fade and dispatch exactly once. Live tracking must still work.
- Offline results and untested conditions will be recorded after build tests.
