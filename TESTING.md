# Current Development Status - GilFinder 1.6.0 currency tray test

- Repository: rerorriM-Mirrorer/Windower-Addons.
- Branch: gilfinder-currencies-2026-10-23; existing branches/main unchanged.
- Runtime: Windower 4 / Lua 5.1; no external addon required.
- Starting/source checkpoint: 4e82393ef1a6d94076863c72744c7c32181fbb0c (1.5.2).
- Most recent user-confirmed live behavior: unfolding/multiclient gil wallet works.
  No new live confirmation of glint fixes, native wallet column anchors or currencies.
- Automated: Lua 5.1 compile; existing regression/lifecycle/glint/IPC/migration/
  profile suites; new currency request/state/search/packet validation, tray UI,
  signed gap and wallet total/default tests pass in local Linux simulation.
- Remaining: native font/ones-place alignment on both sides; currency replies,
  query timing and purchase-update latency; no FFXI runtime available here.
- Next: run the checklist below on a test client. Fractional resolution baseline
  remains ON HOLD until user supplies Cioara's preferred defaults.

## 2026-10-23 - Wallet formatting and currency tray first pass

Contains complete gilfinder/ install with all prior glint fixes, native wallet
amount anchors, total on/off (default off), signed main-text gap, currency state
and tray modules, four provisional badges and their generator, tests and docs.
No active data/settings.xml is included; existing settings are preserved.
Final source commit is linked in the handoff; this status records its baseline.

Verified with python addons/gilfinder/tests/run.py using lupa.lua51/Pillow:
all modules compile; prior behavior, restart/unload, four XML profiles, wallet
IPC, migration, glint timing/fault-injection/clock ordering, panel interactions
pass. New checks cover aliases/substring/suggestions; silent first samples;
batched gain/loss; invalid and failed parses; request throttle/deferred refresh;
zero vs unknown; default total off and explicit on/off; native amount flag and
shared anchors; positive/negative gap and stable coin anchor; tray timeout,
wallet priority and lifecycle cleanup. Four 23x23 RGBA badge assets verified.
These are simulated checks, not Windows/Windower live acceptance.

Live checklist:

1. Copy gilfinder/ into Windower/addons, reload; //gil status shows 1.6.0-a.20261023.1.
2. //gil wallet: amounts of different lengths share their ones-place edge in
   both side left and side right. Test with proportional/italic personal fonts.
3. //gil wallet total on, then off: toggle only total, keep rows/alignment stable.
   New installations and previous configs without a choice default to off.
4. //gil gap 5 and gap -2 on both sides: text moves, coin/glint stay fixed.
   Return to a preferred gap (default 1).
5. //gil sp, cp, curr, windurst: compare values against native currency menu.
   Zero is valid; -- is unknown. Verify requests/replies and no console spam.
6. //gil sparsk suggests Sparks; //gil curr conquest shows three separate nations.
7. Earn/spend Sparks and buy with CP through NPCmirror or native interaction:
   first sample silent, actual changes count with green/pink; verify latency.
   Replies may arrive naturally or after menu transition/60s fallback query.
8. Open gil wallet while currencies change: no overlapping lists; queued tray
   appears after dismissal. Explicit currency query replaces the wallet panel.
9. Delay 8s by default then roll-up; currencydelay adjusts that hold separately.
   Check side, scale, bottom edge direction, hide, logout/zone/restart/unload.
10. Retest AddonManager audit and glint events to confirm prior fixes remain.

Packet rationale and unverified live cases are in docs/PACKETS.md. No purchasing
or multiclient currency IPC is implemented here; multiclient wallet remains gil.

## Previous cumulative records (preserved)

# Current Development Status - GilFinder 1.5.2

- Repository: rerorriM-Mirrorer/Windower-Addons.
- Branch: fix/gilfinder-glint-index-20261022; main and personal branch unchanged.
- Runtime: Windower 4, Lua 5.1; no new companion requirements.
- Starting/source checkpoint: 87c4425a9b78555c5e787768a3af5fbbac75285f (v1.5.1).
- Latest live feedback: user confirms the unfolding wallet works great. Reported
  a further error around line 20; exact message and installed source unknown.
  User is currently testing v1.5.1 from the AddonManager conversation.
- Automated: full local Lua 5.1/mock regression suite passes, including glint
  timing reversal, invalid-index cleanup and progressing-clock menu ordering.
  Each new regression also fails against the corresponding v1.5.1 source.
- Remaining: live FFXI acceptance of v1.5.2, including AddonManager audit,
  menu transitions, glint stop/off, restart/unload. This is Linux simulation.
- Next step: install the complete v1.5.2 test package and confirm no repeat error;
  capture full message/version if a further error appears.

## 2026-10-22 - v1.5.2 glint cleanup and timestamp review

Compared the actual Library v1.5.1 ZIP with published fix branch baseline.
The drawing guard clamps frame 1..20, but stop() still unconditionally indexes
frames[current]. That is another unchecked path, not proof of the precise
reported line-20 cause (line 20 in the ZIP is the stop function declaration).
Guard cleanup, clear its index first and test injected old indices 0, -1, 21.
The old source fails this test with glint.lua:22 nil-frame indexing.

Identified a concrete ordering path: render captures os.clock(), then a native
menu transition invokes wake(), which previously captured a later os.clock().
The trigger could therefore be later than that render's now without any clock
reversal. wake(now) now accepts and uses the existing render timestamp for both
activity and glint. A mocked clock advancing on each call reproduces the old
ordering and passes the fix. Keep v1.5.1's lower clamp as additional protection.

No evidence establishes AddonManager as the cause. Wallet presentation, IPC,
visibility preferences, positions and animation assets remain unchanged.

Checks run: python addons/gilfinder/tests/run.py with lupa.lua51 and Pillow;
module compilation, both lifecycle paths, four personal XML profiles, IPC,
migration, 20 asset masks, glint, panel/menu integration and clock ordering pass.
Fault-injection and advancing-clock tests fail against their old source versions.

Complete installation: copy gilfinder/ over Windower/addons/gilfinder; reload
on each client. No active settings.xml is included. //gil status must show
1.5.2-a.20261022.1. Try wallet, glint preview/off/on, menu transitions, then
//am audit; restart/unload should stop cleanly. Preserve full error text if any.
The handoff records the actual published commit; this file identifies baseline.

## Previous delivery records (preserved)

# GilFinder glint-index guard — 2026-10-22

**Branch:** `fix/gilfinder-glint-index-20261022`
**Version:** `1.5.1-a.20261022.1`
**Status:** Patch committed, **live FFXI retest pending**.

**Reported in-game observation:** On Cioara during AddonManager's quiet-console `//am audit`, the user saw repeated `gilfinder/glint.lua:30` “attempt to index field … (nil value)” messages. The concurrently inconclusive AddonManager audit is recorded separately. The fact that these coincided does not establish that AddonManager caused GilFinder's error.

**Source finding:** In the preceding published `glint.lua`, rendering computed an upper-bounded frame index but did not clamp below 1; if `now < start`, the result can be 0 or negative. When `current` is outside the preallocated 1–20 range, `frames[current]:hide()` at source line 30 attempts to call `hide` on a nil frame. It is a plausible cause, not proven to be the only runtime cause.

**Fix:** Clamp rendered frame index to `1..20`, and access old/current frame objects defensively. Preserve the 20 preloaded textures, duration, trigger behavior, settings, IPC, and other features. Add a simulated timing-reversal regression in `addons/gilfinder/tests/glint.lua`.

**Live checklist:** (1) Back up working `gilfinder/` and `data/`, install the new complete folder and reload GilFinder. (2) Confirm `//gil status` shows `1.5.1-a.20261022.1`. (3) Trigger a normal and preview glint, then menu and gil-change events. (4) Repeat `//am audit` with console capture; verify no repeated GilFinder Lua error. (5) Test client with wallet and visibility settings preserved. (6) Capture `console.log` excerpts if the error persists.

**Automated evidence:** GilFinder `tests/glint.lua` now covers rendering just before the trigger timestamp, then forward again, ensuring frames 1–20 remain valid. Report the result of its GitHub Actions job at delivery; **no live FFXI result is claimed**.

---

# Current Development Status

- Repository: rerorriM-Mirrorer/Windower-Addons; branch gilfinder-personal-2026-10-15.
- Batch: Wallet Panel & Responsive Glint Test 2, v1.5.0-a.20261021.1.
- Runtime: Windower 4 / Lua 5.1 on Windows; no external companion required.
- Starting source checkpoint: 9c3b59d8e455309906f97e93e42c66ec75b0f441.
- User-confirmed live baseline: coin glint and same-computer multiclient wallet
  worked. Optional controller reader reported unavailable; that limitation remains.
- Automated: Lua 5.1 compilation; mocked behavior/lifecycle, saved profiles,
  IPC, migration, glint asset/timing, and panel/menu interaction suites pass.
- Remaining: live FFXI animation, font extents, menu transitions and multiclient
  panel acceptance on Franklet/Lionstag. No native FFXI session in this environment.
- Next: install this complete test build, verify the checklist below, then tune
  visual timing/placement from live feedback. Keep main unchanged.

## 2026-10-21 - Wallet Panel & Responsive Glint Test 2

Complete install package includes gilfinder code, coin, all 20 glint frames,
controller/IPC/migration/panel modules, docs and repeatable tests. README,
WORKFLOW and TESTING are inside gilfinder/. No active settings.xml is shipped.
Copy over addons/gilfinder and reload each client. Existing saved settings and
legacy visibility migration remain intact. Version is visible in //gil status.
The final published commit is identified in the handoff and GitHub history.

Automated checks: `python addons/gilfinder/tests/run.py` (Python with lupa and
Pillow). All modules compile using Lua 5.1; both restart and unload dispatch once;
four personal profiles preserve settings; IPC dedup/partial results/request
isolation and migration backup/idempotence pass. Integration covers startup,
command/menu/farewell glints, held-menu timeout, persistent show, hide override,
column switching, bottom-edge unfolding, refresh, cancel-before-reply, timed
roll-up, zoning and destruction. Simulated checks are not live Windows passes.

Live checklist:

1. //gil status reports 1.5.0-a.20261021.1; reload produces an initial glint.
2. //gil wallet unrolls names/amounts and Total (count) on requester only.
   Verify Franklet/Lionstag, alphabetical rows, right-aligned amounts, side left
   and right, scale/drag, and upward opening near the bottom edge.
3. wallet refresh updates fresh balances without replaying entrance; wallet off
   rolls up. Rapid on/off while querying cannot reopen from a late reply.
4. //gil auto, delay 2: open/close a menu to reveal and reset the timer. A held
   menu times out; submenu navigation with unchanged menu_open is not a trigger.
5. Expiry glints then rolls up/fades. New menu activity during departure restores
   the wallet. //gil show stays visible; //gil hide stays hidden until explicitly
   revealed. //gil auto input preserves existing keyboard/controller behavior.
6. Gain and spend gil: green/pink counting and glint. Test glint off and forced
   preview. Repeat with optional cutscene hiding, zoning/logout and restart.
7. Return delay to your preferred value (default 60). Existing always-mode
   characters stay always visible after installation.

## Preserved previous delivery status and cumulative history

# Current Development Status — GilFinder Wallet & Glint Test 1

- Repository: rerorriM-Mirrorer/Windower-Addons.
- Working branch: gilfinder-personal-2026-10-15 (dev/main unchanged).
- Runtime: GilFinder 1.4.0-a.20261020.1; standard Windower Lua libraries;
  no new external controller companion. Starting source: published 6820990.
- Latest user-confirmed behavior: October 15, widget looked good and was kept
  visible continuously. No user live confirmation of wallet/glint yet.
- Automated checks: Lua 5.1 compilation; retained mocked behavior suite;
  new wallet aggregation/isolation, glint render/assets, mode cycle, personal
  profile and XML migration/backup checks all pass in Linux simulation.
- Remaining live checks: real Windower IPC across focused/background clients,
  native glint appearance/opacity at client resolutions, native config/XML
  persistence, PS5 reader, gain packet timing and lifecycle cleanup.
- Next step: install this build on each desired client; try //gil wallet and
  //gil glint preview, then compare wallet rows with each character's gil.
- Publication: final source commit is identified in the delivery/GitHub branch,
  rather than self-referencing this status file.

## Wallet & Glint Test 1 — October 20, 2026

### Contents and installation

Complete gilfinder folder: entry point, original coin, controller reader, new
wallet/glint/migration modules, 20 tiny highlight frames, reproducible asset
builder, tests and docs. WORKFLOW and this cumulative record are included
inside the addon folder under the current packaging convention.

Copy gilfinder into addons and retain existing data. No active settings.xml is
included in this package. Restart/reload GilFinder on EVERY client you want to
query; then run //gil wallet in the client where you want the chat report.
Fresh installations use global defaults; optional original personal settings
are in docs/Personal-settings-template.xml, for manual copying only.

### Current tests and results

Passed in Python/lupa Lua 5.1 on Linux:
- All Lua modules compile, including unchanged controller module.
- Original simulated HUD regression checks, updated with glint and mode cycle.
- Wallet: three-client aggregation/total, requester-only display, self without
  echo, duplicate query/reply filtering, stale/overlapping request isolation,
  incomplete responder sets, identical names on different servers, current
  sampled balance, invalid/unrelated messages, logout/restart cancellation.
- Glint: preloaded frame progression, icon positioning/scale, hidden opacity,
  enable/disable and preview preserving preference, gain vs loss, cleanup.
- Assets: 20 correct-size RGBA frames, alpha constrained by original coin mask;
  visually inspected an enlarged contact sheet of the rendered sweep.
- Migration: explicit visibility beats old boolean; boolean-only global and
  character sections convert; coordinates remain; backup created once;
  subsequent conversion is a no-op. Personal profile fixtures retain modes.

Simulation is not live acceptance. Real IPC delivery, server labels, native
texture rendering and saved-data writes still need Windower/FFXI checks.

### Live checklist

1. In your current always-visible setup, confirm position, scale, colors and
   mode survive reloading. data/settings-before-wallet.xml should preserve the
   old config if an autohide flag needed migration.
2. //gil glint preview: a single quiet light ribbon sweeps across the coin.
   Try at small scales and after swapping amount side. No widget movement.
3. Gain gil: green count plus glint. Spend gil: pink count, no gain glint.
   Load or requery a wallet: no fake gain/glint. Disable glint and preview it;
   its disabled setting should remain disabled afterward.
4. Load the update on two or three characters on the same computer. //gil wallet
   lists those inventory-ready responders and an accurate total in requesting
   chat only. An offline/older-addon/zoning client is not silently counted.
5. Run wallet twice quickly, or from two clients: reports should stay isolated.
   No client switching or transfer accounting is involved.
6. Bare //gil mode cycles always -> change -> input -> always. Existing //gil
   autohide remains a command convenience, with no saved boolean authority.
7. Recheck cutscene option, dragging, hidden click behavior, input mode, and
   //gil restart / //gil unload cleanup. Keep original saved preferences.

### User requests / delivery record

October 15: save one visibility mode; bare mode cycling queued for next pass.
October 18 discussion: coin glint and multibox balance query selected.
October 20: user requested implementation, excluded transfer tracking.
Source baseline is 6820990; previous cumulative records are retained below.
Current canonical WORKFLOW read from ffxi-NPCmirror at delivery time.

---

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
