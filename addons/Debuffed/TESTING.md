# TESTING — Debuffed Icon Presentation

## Current delivery

**Batch:** Test 2.4.2 (2026-10-13)  
**Build ID:** `1.0.0.4-icons-test2.4.2`  
**Base:** Test 2.4.1 help-color refinement, commit `02f38d1` on `work/debuffed-icons` (all other behavior unchanged)  
**Git:** Test 2.4 recovered as a real GitHub commit `a92dda3`; Test 2.4.1 is a separate help-color refinement on `work/debuffed-icons`. Both await live validation.  
**Original tracker:** From `function handle_overwrites` through the incoming-chunk handler, byte-for-byte identical to Test 2.3 (scripted comparison).
**Delta from 2.4.1:** UI timer formatting only: truncated minutes/hours and seconds only below one minute; edit-loop sample format updated; manual preview unchanged. Docs/build ID updated. Original tracking still untouched.

### Installation precautions

Extract at `Windower/addons/` (archive contains `Debuffed/`). Avoid nesting `Debuffed/Debuffed/`. Preserve `Debuffed/data/settings.xml`. The `WORKFLOW.md` and `TESTING.md` files are in the ZIP root for developer reference; install only the `Debuffed/` folder. XivParty is needed separately for icon textures.

### Try these first

1. In game: `//lua reload Debuffed`. Confirm short intro and fade. Optionally use `//db status` to verify Test 2.4.1.
2. Run `//db slots 16` and `//db wrap 16`, since existing settings can still say 32.
3. Run `//db edit` and confirm 16 familiar **outlined edit squares** each containing a semi-transparent example icon. The timer should show `1m` for its first 11 seconds, then `59`, `58` ... `0`, resetting to `1m` each cycle. Check that moving field works and `//db edit off` removes the samples without losing the position.
4. Run `//db preview` outside edit mode. Confirm 11..0 labels on example icons over 12 seconds, then faded disappearance. Confirm that actual debuff tracker is unaffected.
5. Adjust `//db timersize 7`, `//db timerx -2`, `//db timery -4` while editing; confirm sample timers reposition/sizes update. Restore preferences.
6. Run `//db help`, verify the full BattleStations-like palette: yellow/warm borders, contrasting title/section, accented `db` and `=>`, light syntax, neutral descriptions. Help appears **only in FFXI chat**, not duplicated in console.
7. Test `//db restart`: chat reports restart, icons/edit presentation fade, addon comes back with intro. Test `//db unload`: fades and stays unloaded; restore with `//lua load Debuffed`.
8. Apply Dia to an enemy and ensure it appears first; verify real timer/target/debuff removal in combat. Test with other concurrent Windower clients when convenient.

### Offline checks completed

- Syntax: `luatex --luaonly` loadfile for both Lua modules: **PASS**.
- Renderer mock: intro; fade; 11..0 manual; 1:10→0:00→reset edit samples; guide + icon + timer layering; X/Y timer offsets; resizing; wrapping; live sprite; orderly cleanup; fade before unload: **PASS** (from Test 2.4.1; the timer-format change is separately checked below).
- Command mock: default slots/wrap 16, help output via chat only, edit on, wrapping/slot changes, manual preview notice, shutdown delay, exactly one `lua r Debuffed` or `lua u Debuffed` after fade: **PASS**.
- Original tracking section compared to Test 2.3: **PASS / unchanged**.

**Not tested:** actual Windower runtime, XivParty texture rendering and color codes in the FFXI chat window, physical controller behavior, live effect expiration semantics. Do not assume offline simulations establish those.

- Test 2.4.2 timer formatting cases: `1796s → 29m`, `70s → 1m`, `60s → 1m`, `59.9s → 59`, `1s → 1`, plus edit 70..0 and manual 11..0: **PASS** (offline; pending in-game).

### Known risks / follow-ups

- Many help lines may scroll the game chat; consider grouped/help topic pages if this becomes intrusive.
- The whole transparent icon rectangle remains mouse-draggable in normal mode, as in earlier builds.
- Icon count increases primitives and rendering load per client.
- The original effect duration uses `os.clock`, not real wall time; no tracking changes were attempted in this presentation batch.
- Native FFXI text extents and `Arial Bold Italic` presentation may differ from offline estimates.

## Earlier batches

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
