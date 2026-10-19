## v0.1.32

- Short test trim comparison of current/balanced5-3/tight5-5 for the current font/size. Single16-row sample,10s to type native descenders, three matched PNG/TXT pairs, automatic restoration.
- Trims are transient drawing overrides. No saved-setting writes, text/divider movement or font/input commands between captures. Intermittent label clipping remains separate; no speculative renderer redesign.

## v0.1.31

- Add test auto <family> [existing screenshot directory] and test go for opt-in Windower PNG captures. First completed file pauses for inspection; subsequent cases advance only after a matched PNG is copied beside its diagnostic.
- Observe file signature/end marker,20s timeout and ambiguity/write failures. Focus/console/resolution/layout interruptions cancel queued captures. No screenshot settings changes; manual suites retained. Native capture unverified here.

## v0.1.30

- Derive opt-in trial native spacing estimates from95% of fresh addon probe pitch, with4px bottom allowance and ceiling pitch for Input. Raw extents retained; manual/reference fits preserved.
- Add named single-family suites (rounded/tahoma/verdana/current),19 cases each, for screenshot+ZIP upload batches. Full57-case suite uses updated estimates too. No load-time migration.

## v0.1.29

- Guided57-case suite for three families, all sizes6–24; current-family option, explicit advance/repeat/status/stop and starting-font restoration.
- Unique current-mode captures without native output writes. Failures/interruption require a retry; no automatic advancement.
- Rounded12 trial increases divider clearance3px (height333, bottom allowance4). Other references unchanged. Full live checklist is in README/TESTING.

## v0.1.28

- Add explicit test preset [size] to apply a bundled fit and run its sample/diagnostic together. Ordinary tests preserve saved fits.
- Add provisional Rounded Bold 12 reference inferred from native screenshot: spacing18, full height330, Input19, neutral trims. Pending live verification.

# ConsoleBG+ changes

## 0.1.27 — reference settings and native sample tests

- preset 8/10 applies bundled Arial Rounded reference settings while preserving unrelated preferences.
- test [size] preserves known fits, measures new estimates, fills 16 numbered native rows and saves a unique diagnostic.
- Size 10 is a working reference; divider clearance still needs visual acceptance.


## 0.1.26 — visible-edge Ctrl snapping

- Normal mode snaps the trimmed top edge; edit mode snaps the expanded header. Saved parent and child offsets remain unified.
- Added the font calibration sequence from the accepted Arial Rounded MT Bold 8 / trim 5 3 reference.


## 0.1.25 — per-font trim

- `//cbg trim 5 2` tests five extra pixels off the top and two off the Input bottom while keeping the divider/native text stationary.
- Trim saves per font/size and survives switching/reload. Bare trim reports; trim 0 0 restores prior drawing.


## 0.1.24 — 16 output rows plus Input

- Calibration/new font estimates use 16 output rows and one Input row.
- Saved legacy height stays until explicit recalibration; status/diagnostics identify the saved row count.


## 0.1.23 — compact header and whole-frame drag

- Drag the entire visible frame; lower-right resize stays in edit mode.
- Up to eight pixels of normal top space retract; edit restores the header without moving text, Input or the bottom edge.
- Existing saved calibration/geometry remains. Diagnostics distinguish saved parent anchor from visible top.


## 0.1.22 — always-draggable frame

- Visible top edge can be dragged with edit mode off. Ctrl snapping and release-only saves remain.
- Edit mode still exposes guides and enables lower-right resizing.
- A grabbed activity frame remains compact and visible until release; hidden frame/body clicks pass through.


## 0.1.21 — test batch

- Ctrl+drag floors one frame anchor to a saved 10px screen-origin grid; free dragging and resize preserved.
- New font/size pairs get a 15-row estimate; calibrate measures addon-text spacing and stores absolute profiles. Exact pixel corrections are supported.
- Start with `//cbg font "Arial Rounded MT Bold" 8`, then `//cbg calibrate`. Use `//cbg calibrate status` and `//cbg diagnose` for the comparison.
- Full instructions and current verification status: TESTING.md, included beside this file in the ZIP.
- The history below describes v0.1.20; its fixed output-body font behavior is superseded by v0.1.21.


## 0.1.20 — test batch

- Independent frame activity and nativeactivity switches; both preserve logging.
- Linked font command scales the existing Input and label calibration and saves the native font.
- Fresh/reset background fade is 450 ms, with the existing 1000 ms hold. Existing saved timing is kept.
- Bare position/size/offset/font/timing commands report values; bare width restores screen-width mode.
- Status and diagnostics identify the activity choices and the shared-log limitation.

## Two-client test

1. Back up data/settings.xml on each computer before trying font calibration.
2. After replacing addon files, keep data and reload ConsoleBGPlus.
3. On client A: `//cbg activity on`, `//cbg nativeactivity on`.
4. On client B: `//cbg activity off`, `//cbg nativeactivity on`.
5. Produce distinctive console output on each. B should show native automatic text without the frame. A may show the frame for either client's shared-log growth.
6. Open and close each console with Insert; check tab, compact close, and sounds.
7. Try `//cbg fade 1000 450`. Open/close and repeat output during the hold/fade.
8. Try `//cbg font Verdana 14`, inspect with preview, then reload and confirm it remains saved. Test a second installed font and both resolutions. Native alignment still needs live confirmation.
9. Use bare font/pos/size/offset/fade for readouts. Turn preview off before timing tests; trace on before reproducing an issue, trace off and diagnose afterward.

Offline checks are mocked Windower API checks; they do not establish native rendering or multi-client file-writing behavior.

