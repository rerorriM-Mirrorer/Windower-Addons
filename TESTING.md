# Current Development Status

- Repository/branch: rerorriM-Mirrorer/Windower-Addons, `consolebg-plus`; ConsoleBGPlus v0.1.24 / Windower 4. Starting source: `239983c864308d4ec6899d4e9687d63028f3b92e` (v0.1.23). Published head is in the handoff.
- Calibration now uses 16 output rows plus one Input row. New font/size estimates and manual overrides use the same corrected formula. Existing saved fits retain their height until explicitly recalibrated. Legacy profiles without a row field are identified as 15-row fits; new fits save rows=16.
- Most recent native evidence: the supplied v0.1.22 screenshot and diagnostic at 1280x720, Arial Rounded MT Bold 8, spacing proxy 13, saved height 237. User confirms 16 output rows plus Input. No live acceptance of v0.1.23/v0.1.24 has yet been reported.
- Verification: complete mocked Windower suite through liblua 5.4 and Lua 5.1 syntax checks. Updated three-font 8/10/12 matrix, profile switching/reload, exact fractional overrides and extreme font/resolution checks pass. Explicit upgrade test preserves 237px, then calibrating with 13px spacing changes it to 250px once, preserves 250px on repeated calibration, and restores the 16-row result after reload.
- Pending live check: keep data, reload, choose Arial Rounded MT Bold 8, run calibrate. With the same 13px spacing and margins, saved height should become 250px, drawing 242px with the normal 8px top trim. Input-open screenshot plus diagnose will show whether the addon-text proxy needs a native-spacing correction.

## 2026-10-18 — v0.1.24 calibration acceptance

1. Keep data/settings.xml and optionally back it up before recalibrating. Install and reload; the current saved height should remain intact.
2. Run `//cbg font "Arial Rounded MT Bold" 8`, then `//cbg calibrate`. Wait for the summary showing fit 16 output rows.
3. Capture Input-open with 16 output rows and one Input row. Run diagnose and save that diagnostic before another overwrites it. No manual resizing before this first comparison.
4. Repeat calibration: height should not accumulate. Toggle edit on/off to check the header; drag anywhere and test Ctrl as before.
5. Native font fit remains a live test. This patch intentionally changes only the row-count multiplier and fit metadata, retaining margins, probe measurement method, header trim, drag behavior and Input construction.

The older records below retain their original formulas and observations. Their statements about a pending correction are superseded by v0.1.24.

# Previous Development Status — v0.1.23

- Repository/branch: rerorriM-Mirrorer/Windower-Addons, `consolebg-plus`; ConsoleBGPlus v0.1.23 / Windower 4. Starting checkpoint: `faef7844c5691946129375feb54a5bd3514606ed` (v0.1.22). Published head will be in the handoff.
- Normal/activity views now trim up to 8px of unused top background; edit restores the header upward. Native text, Input/tab/divider and bottom positions remain fixed. Existing font profiles and saved anchor are unchanged.
- Entire visible frame drags, with the edit-mode lower-right resize corner taking precedence. Ctrl floors the existing saved parent anchor to the shared screen-origin grid. The visible top rail is a child at parent_y + top_trim, so its edge can differ from a grid multiple while the saved anchor remains on-grid.
- Verification: complete mocked Windower suite through liblua 5.4; Lua 5.1 syntax/scope inspection. Tests include body/corner dragging, hidden and retracted-header hit rejection, both Ctrl keys and four-resolution/extreme-font matrix from earlier batches, native text/Input/bottom invariance across edit toggles, restored dimensions after edit off, and custom offsets 0/7/10/15. No FFXI test of this new patch performed here.
- Latest live materials: diagnostics(6).txt and diagnostics(7).txt, plus image(20261019-034213).png. v0.1.22 at 1280x720, Arial Rounded MT Bold 8; proxy spacing 13px, saved full height 237px, Input 13px. Screenshot demonstrates restored font/profile and Input view, but is not a blanket acceptance of dragging or other fonts.
- Correction: earlier ~~15 output rows plus Input~~ is **16 output rows plus Input (17 total)**, confirmed by screenshot and user recount. Historical proxy formulas/tests below used 15; existing fitted heights are deliberately preserved by this patch. Native line spacing versus addon proxy still needs refinement before replacing those profiles automatically.
- Next live check: install keeping data, toggle edit, confirm stationary text/Input/bottom and tighter normal top, drag from the center with/without Ctrl, resize in edit, then provide a screenshot/diagnostic if the fit needs adjustment.

## 2026-10-18 — v0.1.23 acceptance steps

1. Preserve data/settings.xml. Reload; normal top should retract by 8px with the usual 15px native-text offset (less for smaller custom offsets).
2. Toggle edit on/off repeatedly. Only the upper boundary/header and Console title should change; native text, Input/divider/tab and bottom must not jump. Extra edit space must not appear during normal log activity.
3. Drag from the body, Input strip, normal lower-right corner, and top. With edit on, lower-right remains resize. With edit off, that corner moves the whole frame. Release saves once.
4. Ctrl+body drag must snap the single saved parent anchor, keep children together, and retain existing screen-boundary safeguards. Hidden frame and retracted top area must not claim new presses; outside/blocked events remain unclaimed.
5. Original 237px size-8 layout should render 229px tall with its visible top 8px lower, restoring 237px in edit. Saved/native content positions stay fixed. Use diagnose to compare parent_anchor_y and normal_top_trim.

The prior records remain below. Their top-strip-only and body-click-pass-through descriptions are superseded by v0.1.23.

# Previous Development Status — v0.1.22

- Repository/branch: rerorriM-Mirrorer/Windower-Addons, `consolebg-plus`; ConsoleBGPlus v0.1.22, Windower 4. Starting checkpoint: `b54b5f688f1bb0d7b118cb341dd6363c183df892` (v0.1.21). No live acceptance of v0.1.21 calibration has been reported yet; v0.1.20 remains the most recent user-confirmed behavior.
- Visible upper edge now drags with edit off. Edit mode retains guides and lower-right resizing. Both Ctrl keys and existing grid/bounds/saved positions are preserved. A grabbed activity frame stays compact and visible until release, then resumes normal timing.
- Verification: complete mocked Windower regression suite passes through liblua 5.4; Lua 5.1 syntax checks pass. New simulated checks cover manual and activity dragging with edit off, Ctrl snapping, blocked release, release-only saving, expired activity after release, body/resize clicks passing through outside edit, and hidden-input rejection. No live FFXI test performed.
- Pending: native manual/activity dragging, reload, edit guides/resizing, and the existing font calibration checklist. Final published commit is in the handoff.

## 2026-10-18 — v0.1.22 live check and calibration handoff

1. Keep data/settings.xml when updating. Drag the visible top edge with edit off, then with Ctrl. Check that text follows and position survives reload.
2. With edit off, body and lower-right clicks should pass through. Enable edit for guides/resizing; disable it afterward. Hidden frame must never capture a new press.
3. Grab an automatic activity frame and hold beyond its fade duration. It should remain compact until release, then hide if its timer has expired. Native console text is still controlled by Windower; holding the background does not extend native text timing.
4. For calibration, first capture the unadjusted result after `//cbg calibrate`: output-only screenshot and Input-open screenshot with 15 output rows, plus `//cbg diagnose` snapshots. Save/rename each diagnostics.txt before the next overwrites it.
5. If the fit needs manual resizing, take those first captures before changing it. Resize in edit mode, leave edit mode, then capture another screenshot and diagnostic as the manually corrected reference. Include data/settings.xml if practical. Do not recalibrate between the manual adjustment and its diagnostic, since calibration recalculates height.

The v0.1.21 record below is retained. Its statement that edit-off frames reject top-edge presses describes the old behavior and is superseded by this batch; hidden frames still reject presses.

# Previous Development Status — v0.1.21

- Repository: rerorriM-Mirrorer/Windower-Addons; development branch `consolebg-plus`, draft PR #1. Runtime: ConsoleBGPlus v0.1.21, Windower 4. No external companion addon dependency.
- Starting source: v0.1.20, `45823e35f0c90545323f100c5035a0ef937a6ca1`. Most recent user report: v0.1.20 activity and other behavior work well; Verdana 8 leaves an overly tall body. User confirms 15 output rows plus one Input row.
- Published code checkpoints: Ctrl+drag `fe83bd0745d9e82626ca7abcaea1223300ed761b`; font profiles and calibration `53f82d4e7252ca13004354174476117cad4dd5bc`. The final delivery commit is given in the handoff; this document cannot name its own commit.
- Automated checks: complete existing and expanded mocked Windower regression suite through liblua 5.4; Lua 5.1 syntax parsing of all addon modules and the test harness using luaparse. No Windows, native font measurements, or FFXI gameplay testing performed here.
- Pending live acceptance: Arial Rounded MT Bold 8/10/12, then Tahoma and Verdana; both Ctrl keys/free drag/grid, reload, Input seam, automatic activity and two-client behavior. Next step: compare size 8 native output and Input against the measured frame.
- Guidance: no AGENTS.md, WORKFLOW.md, TESTING.md, AGATHOS.md, or DESIGN.md exists in the fetched branch tree. Adopted NPCMirror main's current consolidated WORKFLOW.md (read directly from GitHub on 2026-10-18); original addon README and CHANGELOG history retained. Multi-addon repository README remains an index to the addon-specific usage guide.

## Install this test batch

1. Back up `ConsoleBGPlus/data/settings.xml`. Keep the v0.1.20 ZIP as a rollback.
2. Replace the `ConsoleBGPlus` folder's delivered files in Windower/addons, preserving `data`. Do not run the original ConsoleBG simultaneously.
3. Reload ConsoleBGPlus. Existing saved layout/font/activity choices remain; no automatic measurement or forced reset occurs on load. Native saved font/position still reapplies.
4. The installable folder contains README.md, WORKFLOW.md, and this guide. No settings.xml or personal diagnostic logs are shipped. Texture PNGs are reconstructed by the existing skin code.

## Live font calibration

1. Run `//cbg font "Arial Rounded MT Bold" 8`, then `//cbg calibrate`. Wait for the measured summary. `//cbg calibrate status` reports the active result.
2. Fill all 15 output rows, capture output-only and manually opened views (15 output plus Input). Run `//cbg diagnose` for each, saving separate diagnostics before the next overwrites it. Keep edit/preview off when observing automatic output.
3. Compare top gap, first/last glyph bounds, native line spacing, Input baseline, rail/tab seam, and bottom allowance. The probes measure addon text, which may differ from the native console. If measurements fail or differ, exact overrides are `//cbg calibrate <line pixels> [top [bottom [input]]]`; example values in README are illustrative.
4. Repeat at 10 and 12. Switch back to 8 and reload: the measured/corrected size-8 profile should return exactly. Then repeat with the installed Tahoma face and Verdana.
5. First compare on one resolution; repeat at 960x540/1280x720 and the larger display. Record Windower UI resolution from diagnose. Oversized text/frame remains screen-clipped; no promise that 15 size-24 rows fit a small window.
6. Confirm independent frame/native activity switches, sounds, logging and load pulse still behave as in the prior batch. Only the explicitly invoked font/calibration commands adjust dimensions.

## Live dragging

1. `//cbg edit on`: drag the existing upper grip freely. Positions should retain single-pixel precision and save on release. Text and Input should follow the same parent anchor.
2. Hold left Ctrl; drag from an off-grid position. Both anchor coordinates floor to multiples of 10 from screen origin (0,0). Repeat with right Ctrl; hold both and release one. Normal dragging returns when both are released.
3. `//cbg grid 7` changes and saves spacing; bare grid reports it. Restore 10 afterward. Font changes do not change grid spacing.
4. Test every edge in fixed-width and screen-width modes. Repeat at 960x540, 1280x720, 1366x768, and 3840x2160; test font extremes 6 and 24. Frame must remain bounded. Screen-width mode intentionally changes width as the horizontal margin changes.
5. Resize using the existing lower-right grip, with and without Ctrl; resizing should remain unrestricted. Release after another addon claims mouse input, then confirm dragging ends. Closed edit mode/hidden frame must not claim new mouse presses.
6. Reload and check saved coordinates. Alt-tab while holding Ctrl, release outside the game, then return: the next free drag should not stick to the grid.

## 2026-10-18 — v0.1.21 checks and observations

The v0.1.20 source was fetched directly from GitHub; its original mock suite passed before editing. BarFiller2 main had no docs/ALIGNMENT.md; the current `dev/ctrl-drag-grid` copy was read directly. It specifies floor snapping, DirectInput Ctrl codes 29/157, and scale-independent UI coordinates.

Anchor: `settings.pos.x/y`, normalized by cbg_layout into the top-left screen/UI anchor. Related geometry derives from that anchor; native text uses its saved offset. No independent widgets or global widget scale exist. Rails and texture pixels retain native dimensions. The patch changes the existing mouse handler rather than adding a second drag owner.

Expanded simulated checks cover both Ctrl keys, free dragging, invalid grids, saved positions, focus loss, screen/fixed widths, offscreen motion, and the four resolutions at font sizes 6 and 24. The existing suite covers blocked mouse ownership, release-only saves, resizing/bounds, settings reload, manual/automatic transitions, alpha fades, sound, bottom border layering, and cleanup.

Calibration checks cover single/three-line proxy measurements, stable render settling, the three requested fonts at 8/10/12, exact fractional-spacing overrides, round trips between profiles, persistence across unload/reload, cancelled probes, zero-measurement timeouts without layout writes, invalid arguments, diagnostics, and cleanup on unload. Proxy heights in these tests are synthetic, not font calibration data.

The complete addon/test Lua source parses as Lua 5.1. Behavioral tests run through liblua 5.4 because Lua 5.1/LuaJIT is unavailable. Available definitions and upstream texts/config libraries were inspected; config accepts nested dynamic profile keys. This is static/API inspection, not a native Windower pass.

Existing alignment points recorded separately: Input and Console labels still depend on font metrics while rails retain fixed pixel dimensions; the normal 15px top offset and edit grip still share header space. Input-off mode retains the old compact/full seven-pixel distinction. No automatic top-padding redesign, expanding edit header, activity-opacity change, or legacy mode is included in this batch. These require separate live review after font calibration.

## Earlier history retained

There was no root TESTING.md at the starting checkpoint. The following is a bounded record from the supplied conversation, not reconstructed test evidence:

- v0.1.18: user reported the Input seam looked good after removing the dark seven-pixel lip.
- v0.1.19: logging preserved with activity disabled; shared console.log cannot identify which client grew it.
- v0.1.20: independent native/frame activity, linked font command, faster fresh/reset fade and readouts delivered; latest user report says other behavior works well and size-8 body is too tall.
- Original v0.1.20 delivery notes and two-client checklist remain in `addons/ConsoleBGPlus/CHANGELOG.md` (CHANGELOG.md beside this guide in the package).

## Delivery register

- v0.1.21: three coherent development commits (grid, calibration, documentation/package checkpoint), on `consolebg-plus`; no change to dev/main or merge of draft PR #1. Full test ZIP corresponds to the final published source checkpoint named in the handoff.
