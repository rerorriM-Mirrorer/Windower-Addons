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
