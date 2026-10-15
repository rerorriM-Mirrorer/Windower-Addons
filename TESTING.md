# GilFinder testing record

## Rename Test 1 — October 15, 2026

Version: 1.3.0-a.20261015.1. Derived from GilTracker Test 2.
Development branch: gilfinder-personal-2026-10-15 in Windower-Addons.
The package is built from the delivery commit on that branch; main/dev remain
unchanged. See the accompanying delivery commit link.

### Install and precautions

Copy gilfinder into addons, unload giltracker on every client, then
`//lua load gilfinder`. Update startup/AddOnManager lists and old macros to
use gilfinder / //gil. README is inside the addon folder. Included personal
settings are from settings(10).xml; back up existing GilFinder data if present.
Old GilTracker files are not overwritten. Do not run both addons together.

### Current verification

Passed Lua 5.1 syntax checks and a Lua parser pass on both Lua modules.
Passed mocked regression runs covering counting/color/retargeting, fade and
initial preview, both layouts, shared drag/lock/save, input hold/release,
mouse exclusion, focus loss, three modes, logout baseline, command bounds,
unchanged base settings, name/alias, implementation locals, cutscenes off/on,
chat help, idempotent edit guides, off-screen recovery, and single-dispatch
fade/cleanup for both restart and unload.
Personal XML values and character modes/positions checked against the upload.
No live FFXI confirmation for this build. Native PS5 reader, packet timing,
native font extents, XML persistence and multiple-client behavior remain live.

### Live checklist

1. Load Cioara/Myrr: original XML mode/placement should appear. Load Killala:
   input mode should remain selected. Use //gil status to confirm each.
2. Enter NPC dialogue. Gil remains visible under normal mode/timer behavior.
   //gil cutscenes on hides it at status 4; off restores normal mode behavior.
3. //gil alone and an invalid command display colored chat help only.
4. //gil edit on twice keeps editing on. Guide sits above the amount/icon.
   Drag, scale, swap sides, lock, reload and confirm saved preferences.
5. //gil pos reset recovers placement; smaller windows recover fully
   off-screen XML coordinates without changing valid larger-window positions.
6. Test gaining/spending gil and all three modes. In input mode mouse/sticks
   do not wake it; keyboard/PS5 buttons should. Inspect controller status.
7. //gil restart fades then returns once; //gil unload fades and stays unloaded.

### Delivery register / user materials

- Original upstream: GilTracker 1.1.0, retained BSD license.
- October 13 Test 1 and Test 2: earlier package records retained below.
- October 13 complete Frank-PC package: implementation unchanged from Test 2.
- October 15: settings(10).xml supplied; personal defaults/rename approved.
- Canonical WORKFLOW.md read from ffxi-NPCmirror/main on October 15, 2026.
- User observed hiding in NPC dialogue; optional suppression now defaults off.
- A is the modification author; sylandro's upstream attribution remains.

## Earlier GilTracker records — historical names/commands retained

# GilTracker testing record

## Complete installation package — October 13, 2026

Repackaged Test 2 for Frank's PC without changing addon behavior. Reran the
mocked behavior suite successfully, including manual hiding and controller
module syntax/unavailable-FFI fallback. Runtime files match the saved Test 2
archive byte for byte. Live checks remain pending. See INSTALL.md.

## Test 2 — October 13, 2026

Build: 1.2.0-a.20261013.2. Status: ready for live testing; not live-confirmed.

### Install

Unload GilTracker, back up addons/giltracker, and copy the packaged giltracker
folder into addons. Preserve your data folder. `//lua load giltracker`.

### First live checks

1. Load: balance initially shows. `//gt delay 3` gives a quick timeout test.
2. Receive gil: count rises in muted green, returns to normal, then fades.
   Spend gil: count falls in muted pink and returns to normal.
3. `//gt side right`, then `//gt side left`: spacing looks right and the icon
   stays in the same place. Test scale 1 and 1.5 at both client resolutions.
4. `//gt unlock`: drag either part; the other follows. Lock and reload: saved
   position, side, scale and mode return correctly.
5. `//gt mode input`: wait for its preview to expire. Press/hold/release a
   keyboard key and a PS5 face button. Input keeps it visible; release lets it
   fade. Mouse motion/clicks and stick motion should not wake it.
6. Check `//gt status` after testing controller input. If it reports no joystick,
   note which wrapper-generated controller buttons still wake the widget.
7. `//gt mode always`: stays visible. Scroll Lock and cutscenes still hide it.
   In change mode, zoning should not produce a fresh 60-second preview.
8. Restore preferred delay, likely `//gt delay 60`.

### Automated checks — passed

Lua execution with mocked Windower APIs checked initial preview/fade; animated
gain/loss; midpoint retargeting; color restoration; both layouts with fixed icon
anchor; scale; shared drag/save; locking; all three modes; held keyboard and
controller; mouse exclusion; focus loss; cutscene hiding; logout/login baseline;
zero-duration animation; command bounds; unchanged saved base font/alpha.

Windows FFI/actual joystick driver, live text extents, native input callback
ordering, packet timing, settings.xml writeback and multi-client behavior remain
live checks. Mocked controller tests do not certify the Windows reader.

## Test 1 — retained record

Build 1.2.0-a.20261013.1 passed mocked checks for initial hidden state, gains and
losses, half-fade, restart during fade, timeout, scale, shared drag, lock,
cutscenes, logout/login, and invalid commands. No live confirmation recorded.

~~Initial balance should stay hidden.~~ Superseded by the user's Test 2 request:
show initially, then follow the selected visibility mode.


## Prior Windower-Addons repository records — retained

# TESTING.md

Read this first when preparing or evaluating a development/testing batch. This cumulative, project-specific record belongs at the repository and testing-package roots alongside `WORKFLOW.md`.

## Current testing batch — documentation adoption (2026-10-13)

- **Project:** Windower-Addons (including ConsoleBGPlus) (`rerorriM-Mirrorer/Windower-Addons`).
- **Batch:** Documentation-only adoption; no addon testing package or executable changes.
- **Starting default-branch commit:** `080ec5e34d386f6b07e6a654b104589dae71f51b` (`dev`).
- **Documents:** Added root `WORKFLOW.md` and `TESTING.md`.
- **Reference:** [NPCMirror consolidated workflow](https://github.com/rerorriM-Mirrorer/ffxi-NPCmirror/blob/main/WORKFLOW.md).
- **Verification:** Check root filenames and links; compare migration against its starting commit and confirm only Markdown documentation changed.
- **In-game testing:** Not performed for this documentation-only change; existing addon behavior has not been revalidated.

- **Recorded migration commit:** [`16a05d6`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/16a05d601ee5b23a9503f2e20bbeee9b9e9ab4c0).
- **Verified result:** Git comparison against the recorded starting commit lists Markdown changes only; `WORKFLOW.md` and `TESTING.md` exist at the repository root. No Lua source paths changed.

## Tests for the next functional batch

List the requested change, actions to perform, expected outcomes, previously working behavior to retest, and results actually observed. This repository may maintain multiple addons; name the addon and its testing branch in each future batch.

## Previous tests and checks

No historical test results were reconstructed or verified during this documentation migration. Preserve previous testing materials and bring forward only accurately attributed results when reviewed.

## Cumulative changelog

- **2026-10-13 — Navigation refinement:** Corrected the heading levels for the Testing Packages and Shared Development Conventions sections in `WORKFLOW.md` ([`ca3b01b`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/ca3b01bc98d1017a27d5bddc1f9fe15f89eaef7f)). Documentation only; no addon code changed.

- **2026-10-13:** Adopted the shared two-document development convention without changing executable addon behavior.

## Delivered packages and documents

| Date | Batch | Item | Type | Commit/reference | Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-10-13 | Documentation adoption | WORKFLOW.md; TESTING.md | Repository documents | [`16a05d6`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/16a05d601ee5b23a9503f2e20bbeee9b9e9ab4c0) | No testing package or Lua changes |

## User-provided materials, observations, and requests

- **2026-10-13 — Shared conventions:** Combine Agathos, Design, and Workflow into one `WORKFLOW.md` with linked table of contents; retain `TESTING.md` as the project-specific historical record; both documents belong in each active repository and testing-package root.
- Add earlier requests, tests, screenshots, files, and observations only when their provenance is verified; record date, batch, and reference.

## Corrections and retention

Correct errors with ~~strikethrough~~, an explanation, and the replacement. Remove historical testing information only by mutual agreement.
