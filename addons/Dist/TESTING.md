# Dist — TESTING (first file to read)

## Batch 0.1.0 — 2026-10-15

**Project:** Standalone `Dist` addon forked conceptually from the Default display of DistancePlus 1.5.4. No existing addons need replacing.

**Installation:** Unzip `Dist/` to `Windower/addons/`. Use `//lua l Dist`. To avoid duplicate distance overlays, unload `DistancePlus` first with `//lua u DistancePlus`; both folders can remain installed. Dist writes its own settings independent of DistancePlus.

**Commands:** `//dist` shows help; `//dist status` reports position; `//dist pos reset` recovers the HUD; `//dist unlock` permits moving. Use `//dist restart` after editing files.

### Live test checklist (NOT YET RUN)

- [ ] Load `//lua l Dist` with DistancePlus unloaded; no errors in Windower console.
- [ ] Target NPC/PC/monster: distance displayed to one decimal.
- [ ] Target at <22, 22, 25, 30, >30 yalms: white / lavender / muted purple changes at correct boundaries. Near text grows +1 pt and nudges right 2 px.
- [ ] Clear target and use a subtarget; verify priority and hide when neither exists.
- [ ] Interact with NPC event and Home Point crystal; overlay hides while status is 4 and returns afterward.
- [ ] Warp across zones; note if overlay appears prematurely during loading.
- [ ] Drag and save, then reload; position persists.
- [ ] Change client UI resolution to 1280×720 or smaller; text remains within bounds.
- [ ] `//dist pos reset` moves back to safe coordinates; lock/unlock and size commands work.
- [ ] Run on two or more characters simultaneously with no shared settings or command interference.
- [ ] `//dist unload` and `//dist restart` work from in-game chat.

### Checks completed outside FFXI

- Lua source successfully parsed with `texlua` (Lua-aware loadfile check).
- **18 mocked checks passed** in `tests/smoke.lua`, including colors and font size in each band, target/subtarget fallback, event status 4, return from events, position clamping with smaller resolution, reset, drag correction, help, persistence callbacks and single-dispatch unload.
- Existing DistancePlus 1.5.4 and its `//dp` command are unmodified.

### Source basis and limitations

- Reviewed live GitHub sources: `rerorriM-Mirrorer/Windower-Addons` `distanceplus-ffxi-ui` at 1.5.4, upstream `Windower/Lua` `addons/distance/distance.lua` (the `Distance` name is already taken), and `Windower/Lua` `addons/libs/texts.lua`.
- DistancePlus Default-style colors, thresholds and geometry were copied deliberately; other range calculations were deleted.
- The `status change == 4` convention was previously confirmed in `rerorriM-Mirrorer/enemybar2`; it does not guarantee full loading-screen detection.
- Tests use mocks; no claim of actual Windower/FFXI compatibility until live testing.

### Delivery register

- 2026-10-15 — First standalone clean-install ZIP (`Dist_0.1.0_test.zip`), Dist folder + root `TESTING.md` + `WORKFLOW.md`. Published as draft PR #4 (https://github.com/rerorriM-Mirrorer/Windower-Addons/pull/4); initial code commit `affa6e94673534474238357dff1221188b4f0950` on `dist-minimal-20261015`. Live-test status remains unverified.
