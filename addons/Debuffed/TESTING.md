# TESTING — Debuffed Icon Presentation

## Current delivery

**Batch:** Test 2.4 (2026-10-13)  
**Build ID:** `1.0.0.4-icons-test2.4`  
**Base:** `Debuffed_Icons_Test2_3_LayoutTimers_2026-10-10.zip` (previous delivery; specific Test 2.3 live results not independently confirmed)  
**Git:** No GitHub commit or push made in this batch; this is an installable ZIP for local testing.  
**Original tracker:** From `function handle_overwrites` through the incoming-chunk handler, byte-for-byte identical to Test 2.3 (scripted comparison).

### Installation precautions

Extract at `Windower/addons/` (archive contains `Debuffed/`). Avoid nesting `Debuffed/Debuffed/`. Preserve `Debuffed/data/settings.xml`. The `WORKFLOW.md` and `TESTING.md` files are in the ZIP root for developer reference; install only the `Debuffed/` folder. XivParty is needed separately for icon textures.

### Try these first

1. In game: `//lua reload Debuffed`. Confirm short intro and fade. Optionally use `//db status` to verify Test 2.4.
2. Run `//db slots 16` and `//db wrap 16`, since existing settings can still say 32.
3. Run `//db edit` and confirm 16 familiar **outlined edit squares** each containing a semi-transparent example icon and `1:10` countdown resetting after `0:00`. Check that moving field works and `//db edit off` removes the samples without losing the position.
4. Run `//db preview` outside edit mode. Confirm 11..0 labels on example icons over 12 seconds, then faded disappearance. Confirm that actual debuff tracker is unaffected.
5. Adjust `//db timersize 7`, `//db timerx -2`, `//db timery -4` while editing; confirm sample timers reposition/sizes update. Restore preferences.
6. Run `//db help`, verify the color-coded entries appear **only in FFXI chat**, not duplicated in console.
7. Test `//db restart`: chat reports restart, icons/edit presentation fade, addon comes back with intro. Test `//db unload`: fades and stays unloaded; restore with `//lua load Debuffed`.
8. Apply Dia to an enemy and ensure it appears first; verify real timer/target/debuff removal in combat. Test with other concurrent Windower clients when convenient.

### Offline checks completed

- Syntax: `luatex --luaonly` loadfile for both Lua modules: **PASS**.
- Renderer mock: intro; fade; 11..0 manual; 1:10→0:00→reset edit samples; guide + icon + timer layering; X/Y timer offsets; resizing; wrapping; live sprite; orderly cleanup; fade before unload: **PASS**.
- Command mock: default slots/wrap 16, help output via chat only, edit on, wrapping/slot changes, manual preview notice, shutdown delay, exactly one `lua r Debuffed` or `lua u Debuffed` after fade: **PASS**.
- Original tracking section compared to Test 2.3: **PASS / unchanged**.

**Not tested:** actual Windower runtime, XivParty texture rendering and color codes in the FFXI chat window, physical controller behavior, live effect expiration semantics. Do not assume offline simulations establish those.

### Known risks / follow-ups

- Many help lines may scroll the game chat; consider grouped/help topic pages if this becomes intrusive.
- The whole transparent icon rectangle remains mouse-draggable in normal mode, as in earlier builds.
- Icon count increases primitives and rendering load per client.
- The original effect duration uses `os.clock`, not real wall time; no tracking changes were attempted in this presentation batch.
- Native FFXI text extents and `Arial Bold Italic` presentation may differ from offline estimates.

## Earlier batches

- **Test 2.3 (2026-10-10):** timer typography, icon count, wrap, `//db`; earlier Test 2.2 behavior was visibly confirmed by the user; new Test 2.3 features were not individually confirmed. This is the source baseline, not a claim of full live validation.
- **Test 2.2:** chat log feedback and edit outlines; user liked the individual slot guides and startup animation after correcting nested folder installation.
- **Test 2.1:** startup sample preview texture timing fixes and diagnostics.
- **Test 2:** initial startup/exit fading and Dia-first sorting.
- **Test 1:** original Windower Debuffed tracking plus icon presentation adapter.

## User-provided test observations / requirements

- The startup animation was described as lovely; 32 individual edit square guides were liked.
- Earlier confusing “no animation” reports were partly caused by extracting archives into the already existing Debuffed directory, creating `Debuffed/Debuffed/`.
- User requested BattleStations-style help, chat-only help output, sample timer animations, 16/16 defaults, and standardized restart/unload behavior.
