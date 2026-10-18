# Current Development Status — EquipViewer

- **Repository / branch:** `rerorriM-Mirrorer/Windower-Addons` / `equipviewer-ctrl-grid-2026-10-18`.
- **Runtime:** `3.3.3-dev.2`, Windower 4; no additional companion addon.
- **Tested starting/source checkpoint:** `a43f5e2c02b3d4130576bdbe7cb0353fef6e14e8` on the existing autohide branch (runtime `3.3.3-dev.1`). The source branch and default `dev` remain unchanged by this delivery.
- **Most recent user-confirmed live behavior (2026-10-08):** `ev hide` hid the window; autohide revealed it on equipment changes and worked very well so far. The user was continuing testing. This confirms those observations, not the entire earlier matrix or new snapping.
- **Current automated checks:** Lua 5.1 parsing passed; smoke/regression passed with system Lua 5.4 and mocked Windower APIs. A second run executed the real source image-library mouse callback against mocked primitives. Both covered 70 resolution/scale/ammo-alignment combinations.
- **Unresolved/live:** Ctrl snapping still needs Windows/Windower/FFXI acceptance. Native text appearance, real XML serialization/reload, overlapping addon input, and dynamic resolution changes remain live checks.
- **Next step:** install Test 2; check free drag vs both Ctrl keys, modifier changes mid-drag, saved anchors after release/reload, and appearance at small/large scales. Do not promote this branch before acceptance.

## 2026-10-18 — Test 2: shared screen-grid snapping

**Ideal:** align the top-left corner with other addons on demand while normal dragging and internal layout remain unchanged. The existing parent is `settings.pos`, the background image's top-left; no independent sub-widget anchors exist.

**Code commit:** [b49dfe1](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/b49dfe1aa5ce0cd76e0de1eb3792ac438017c98e). This identifies code changes, not the final documentation/package head. The final published checkpoint is supplied in the handoff and Git history, avoiding a self-referential hash in this file.

### Installation — complete addon folder

1. Back up your existing `Windower/addons/equipviewer/` folder and `data/settings.xml`.
2. Copy the package's `equipviewer/` folder into `Windower/addons/`, merging rather than deleting your existing folder. Keep `data/` and cached `icons/`; neither is bundled or reset.
3. Contents: main Lua, unchanged `visibility.lua`, `icon_extractor.lua`, `encumbrance.png`, README, consolidated WORKFLOW, this TESTING guide, alignment notes, and regression harness. Existing Windower libraries/resources are still required.
4. Run `//lua reload equipviewer`, then `//ev status`. Expect `3.3.3-dev.2` and `Grid=10px`, unless another spacing was saved.
5. Use `//ev show` and `//ev unlock` for positioning. Hold either Ctrl during movement. `//ev grid` reports spacing; `//ev grid 7` saves seven UI pixels. Changing spacing does not move the widget.

Existing positions/settings remain. The new `drag_grid` default merges through config; no character XML is shipped. Roll back by restoring the backed-up folder/settings and reloading. This delivery retains the existing name `equipviewer`.

### Current live acceptance — new checks pending

| Check | Exercise | Expected | Live result |
| --- | --- | --- | --- |
| Free drag | Move without Ctrl, including screen edges | Existing smooth unrestricted placement, saved on release | Pending |
| Either/both Ctrl | Drag with left, right, or both; release one while holding the other | Floor snapping from (0,0); 273,57 → 270,50 at 10px | Pending |
| Modifier changes | Press/release Ctrl mid-drag; cross and return over cells | No accumulated grab-offset error; free motion resumes on movement | Pending |
| Quick release | Move and release before the next frame | Final snapped coordinates saved and confirmed | Pending |
| Persistence | Release; reload/logout/login | Same saved anchor and spacing; other settings retained | Pending |
| Lock/hidden | Try Ctrl+drag locked or hidden | No new drag capture or unexpected movement | Pending |
| Other input | Ctrl alone, blocked clicks/overlapping addons, Alt-Tab | No unsolicited snapping or consumed keyboard input | Pending |
| Bounds | Ctrl+drag beyond all edges, then without Ctrl | Snapped rectangle fits when possible; free drag stays unrestricted | Pending |
| Oversized widget | Exceed viewport on one/both axes | Anchor zero on oversized axes; full containment is impossible | Pending |
| Scale/resolution | Small/fractional/large scales and client resolutions | Grid stays in UI pixels; children stay relative to parent | Pending |
| Text | Both `ev justify` states, especially tiny scales | Native appearance acceptable, no new coordinate drift | Pending |
| Prior behavior | Autohide/fades/gear updates and drag hold/release | Existing behavior retained | Pending |

### Completed checks for Test 2

- Read GitHub WORKFLOW/TESTING and recursive tree at the source checkpoint. No `AGENTS.md` existed; consulted NPCMirror's canonical consolidated workflow. Read BarFiller2's `docs/ALIGNMENT.md`, BarFiller2/EnemyBar2 input code, and Windower image/text methods. No mouse-handler transplant or addon rename was made.
- Lua 5.1-aware parsing passed for main addon, visibility module, and tests, with existing Windower string-method shorthand normalized only in memory. New helpers/state are local; the main addon's global-name set is unchanged. Whitespace checks passed.
- Mocked smoke/regression passed, including previous visibility checks plus **70 combinations**: resolutions 960×540, 1280×720, 1600×900, 1920×1080, 3840×2160; scale factors 0.03125, 0.25, 0.75, 1, 1.333, 2.5, 3.125; both ammo alignments. These span 1px–100px slots and fractional sizes.
- Additional direct size checks used 200px/300px slots in a 960×540 viewport, exercising one/both oversized axes. Historical scale-command limits were preserved.
- Repeated with the real `images.lua` mouse-handler body from blob `b54021025436d54a3cae94c71c8d3ad48ef01ba0`, against mocked primitives. Checked capture offset, blocked-event propagation, release ordering, cell crossings, modifier changes, and existing behavior. This was not a native Windows/Windower session or a full native rendering-library run.
- Saved-position checks observe values passed to the config-save mock; actual XML serialization and persistence still need live acceptance. Fractional-offset assertions use a small numerical tolerance; production rounding was not changed.
- A tiny-widget test initially clicked outside its 4px-high handle. Correcting the test pointer to remain inside the actual handle made the real-callback run pass. No production code was changed to mask that fixture mistake.

From the repository root with standard Lua:

```text
lua tests/equipviewer/run.lua
lua tests/equipviewer/run.lua addons/libs/images.lua
```

The second command executes the source mouse callback with mocks. The identical harness is packaged as `equipviewer/tests/run.lua`; from a Windower root, use `lua addons/equipviewer/tests/run.lua addons/libs/images.lua`. These are standalone simulations, not in-client commands.

### Internal alignment findings — separately assessed

No inconsistent coordinate formulas were found beyond duplicated equivalent setup/movement ammo calculations, now shared through one helper. Positions and dimensions already derive directly from the original 32px design slot rather than scaling previously scaled coordinates. Existing fractional text offsets/font metrics remain unchanged. The clamp measures the grid rectangle, not native text extents; tiny-scale font appearance and dynamic resolution changes without a move/rebuild remain visual checks. See `docs/EQUIPVIEWER_ALIGNMENT.md`.

### Delivery register, observations, and dated corrections

- **Test 2 / 3.3.3-dev.2:** code/tests in `b49dfe1`; documentation follows on the same development branch. The complete install corresponds to the final identifiable published checkpoint given in the handoff.
- **2026-10-18 correction:** the preserved Test 1 wording ~~Current live checks — all pending~~ described its original delivery. The 2026-10-08 user report subsequently confirmed window hiding and equipment-change reveal. Broader packet/zone/persistence checks and new Ctrl snapping remain pending. The earlier tables below are historical delivery records.
- **2026-10-18 packaging update:** earlier instructions requested separate AGATHOS/DESIGN at the ZIP root. NPCMirror now consolidates them into WORKFLOW and places WORKFLOW/TESTING beside addon code. Test 2 follows the current rule. Historical repository documents and testing information are not deleted.
- **Current request recorded:** shared-grid Ctrl dragging; retain free input/layout/scaling and saved positions; inspect current GitHub records/reference first; test boundaries, resolutions, and extreme scales; report alignment concerns separately; push development changes without replacing a live baseline.

## Preserved Test 1 delivery record

The text below is the original 2026-10-08 delivery. Its branch/version, package layout, and pending labels are historical. The dated status and corrections above take precedence; no previous testing information has been removed.

# EquipViewer — testing batch 1: visibility

## Start here

**Version:** `3.3.3-dev.1`
**Date:** October 8, 2026
**Working branch:** `equipviewer-autohide-2026-10-08`
**Live-tested baseline:** `dev`, commit `080ec5e34d386f6b07e6a654b104589dae71f51b`
**Batch code commit:** [f08c4fd](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/f08c4fddf691eaecee5220a8855552621dd12812)
**Documentation/test commit:** the commit containing this edition of `TESTING.md`.

Ideal behavior: show the grid when equipment changes or you request it, then let
it recede gently. Manual hide stays hidden while equipment data remains current.

The established problem was that EquipViewer had no user-controlled visibility
mode, and equipment, zone, and status callbacks could directly show UI elements.
This batch gives those events one visibility policy, preserving the opt-in nature
of the new behavior. The default remains the previous visible grid.

## Installation

This is a **patch for an existing EquipViewer installation**, not a fresh install.

1. Back up `addons/equipviewer/equipviewer.lua` and `addons/equipviewer/data/settings.xml`.
2. Copy the package's `addons/equipviewer/equipviewer.lua`, `visibility.lua`, and
   `README.md` into your existing `Windower/addons/equipviewer/` folder.
3. Keep your existing `icon_extractor.lua`, `encumbrance.png`, `icons/`, and `data/`.
4. Run `//lua reload equipviewer`, then `//ev status`. Expect `3.3.3-dev.1` and `Mode=show`
   on the first load with an old settings file. Previously saved visibility modes
   are restored on later reloads.

The new `visibility.lua` is required alongside `equipviewer.lua`. Do not copy only
the main Lua file. Root development documents guide this batch; they are not
runtime dependencies.

## Current live checks — all pending

| Check | How to exercise it | Expected result | Live result |
| --- | --- | --- | --- |
| Baseline | Load, equip items, inspect ammo/encumbrance | Same layout and configured appearance as 3.3.2 | Pending |
| Manual hide | `//ev hide`; equip/unequip, fire ammo, zone, enter/leave an NPC menu | All elements stay hidden and cannot start dragging | Pending |
| Restore fresh data | Change gear/ammo while hidden; `//ev show` | Correct current gear, ammo, and encumbrance appear | Pending |
| Auto | `//ev autohide on`; wait, then swap equipment | Reveal, hold 4 seconds after the last swap, fade away | Pending |
| Timing | `//ev delay 2`; `//ev fade 0.12 0.30` | Hold and fade durations follow the settings | Pending |
| Frequent swaps | Swap several times, including GearSwap if used | Delay restarts; continuous changes keep the grid visible | Pending |
| Ammo consumption | Let auto mode hide, then fire without changing ammo item | Count updates; firing alone does not reveal the grid | Pending |
| Drag | Reveal auto mode, hold a drag longer than 4 seconds, move and release | Grid stays visible, parts move together, XML/chat confirms final position | Pending |
| Quick drag | Move and release quickly | Final coordinates still save | Pending |
| Lock | `//ev lock`, then `//ev unlock` | Lock prevents dragging; unlock respects current visibility mode | Pending |
| Scale | `//ev scale 1.5` while auto-hidden, then while manually hidden | Auto mode reveals briefly at 48 px/slot; manual hide stays hidden | Pending |
| Game suppression | Enter NPC menu or zone while shown/auto-active | Immediate hide; resume only as allowed by current mode and timer | Pending |
| Optional hover | `//ev hover on` in auto mode; move over saved grid area, then away | Reveal while hovering; hold/fade after leaving; `hide` takes precedence | Pending |
| Persistence | Reload/login after saving show, hide, or auto | Mode, timings, scale, opacity, and position retained | Pending |
| Alignment/resolution | Test both `//ev justify` states; small, normal, and large resolutions | Ammo stays aligned and all grid elements scale/move together | Pending |
| Multiple clients | Start with one client; then your usual multibox setup | Modes/settings act independently; no cross-client controls were added | Pending |

Useful sizes include 1280×720, 1920×1080, and 3840×2160. These are planned live
checks, not claims of tested resolutions.

Return to the old default with `//ev autohide off` or `//ev show`. To roll back,
restore the backed-up main Lua and settings file, then reload the addon. The extra
module may remain on disk unused by 3.3.2.

## Checks completed before delivery

- **Static:** Lua 5.1 syntax parsed with upstream `luaparse`, using Windower's
  existing string-literal method shorthand normalized in memory only. Main addon,
  new visibility module, and behavioral checks passed. New state/helpers are local;
  inherited upstream globals were reviewed rather than broadly rewritten.
- **API review:** compared used image/text visibility, alpha, stroke-alpha,
  draggable, and hover methods with the current Windower libraries.
- **Smoke/regression:** `tests/equipviewer/run.lua` loaded the real main addon and
  module with mocked Windower APIs and a controlled clock. It passed default load,
  hidden packet updates, show/hide persistence, auto expiry/reveal, configured alpha,
  ammo/stroke fading, hover, held/quick drag saving, scale, alignment, game suppression,
  logout/login/unload, malformed commands, aliases, and zero-duration fades.
- **Environment:** the smoke harness ran using the system Lua 5.4 shared library.
  Lua 5.1 compatibility was checked separately by the parser. Windower shorthand
  was normalized only for this standard-Lua harness.
- **Live FFXI:** not run here. Drawing quality, real packet timing, real image-library
  mouse ownership, multiple clients, and resolutions still require the checks above.

To reproduce behavioral checks with a standard Lua interpreter from the repository
root: `lua tests/equipviewer/run.lua`. No FFXI client is needed for that harness.

## Previous results and baseline

- Before this batch, the user reported the 3.3.2 dragging work was working
  “marvelously.” This is a user observation, not a new live test by this batch.
- The earlier delivery compared the uploaded `equipviewer(1).lua` and `README(1).md`
  with the fork, retained the tested Lua, corrected README metadata, and pushed
  `080ec5e`. The baseline code was retrieved again before editing this batch.
- Upstream `Windower/Lua` EquipViewer was also read. Its 3.3.1 main Lua matched the
  pre-drag fork baseline; current fork changes were confined to the known drag work.

## Delivery register

| Delivery | Content | Status |
| --- | --- | --- |
| Earlier 3.3.2 delivery / `080ec5e` | Whole-grid drag and saved position | User reported dragging working well |
| Batch 1 / 3.3.3-dev.1 | Visibility modes/fades, module, README, checks, root development documents | Automated checks passed; live testing pending |

## Materials, observations, and requests

- Earlier user-provided files: `equipviewer(1).lua`, `README(1).md`.
- Current request: confirm scale support; add autohide and `ev show`/`ev hide`,
  practicing NPCMirror's refined workflow.
- User asked what hover meant. It means the mouse entering the saved grid rectangle.
  For this first batch, gear-change reveal is the proposed default; hover is optional
  and disabled by default. This design choice has not yet received live feedback.
- The fast-drag regression check initially failed to save coordinates when no
  render frame happened between movement and release. Checking actual coordinates
  on release corrected the failure; the repeated harness then passed.
- Shared references read from `rerorriM-Mirrorer/ffxi-NPCmirror`: `WORKFLOW.md`,
  `DESIGN.md`, and `AGATHOS.md`. This branch adopts copies at its root, and the
  testing package repeats those copies at its root. Existing history stays on `dev`.

This record is cumulative. Correct errors with strikethrough plus a note and the
corrected entry. Remove historical material only by mutual agreement.
