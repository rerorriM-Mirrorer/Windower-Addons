# Current Development Status

- Repository/branch: rerorriM-Mirrorer/Windower-Addons, consolebg-plus; ConsoleBGPlus v0.1.34 / Windower4. Tested starting checkpoint: d19a1f89f25b94af9fc84a0bd15ae029f0a86a6d (v0.1.33). Final published head is in handoff; baseline branches unchanged.
- Linked font selection now starts invisible probing for new/unmeasured/estimate/addon-proxy fits, derives native-estimate spacing from fresh raw pitch times0.95, and saves the 16-row/Input fit. Saved native-estimate/manual/reference profiles restore directly. Per-pair trims and unrelated settings remain; no sample output, screenshot, input injection or requirement to open the console. Internal suite/restoration calls retain their own measurement lifecycle. No automatic migration on load/reload.
- Latest live evidence: data(4).zip confirms v0.1.33 restores all16 rows before trim captures, but its active raw proxy spacing13 puts the divider236. data(5).zip latest complete Tahoma8 triplet091406/091418/091420 uses native-estimate12.35, divider226, all16 output rows and typed Input. Assistant recommends trim5/5; user has not explicitly confirmed saving that choice. Rounded8 accepted5/3 remains separate.
- Correction: ~~capitalization selected separate Tahoma profiles~~ was an incorrect initial diagnosis in conversation. calibration.key already lowercases font names; code and uploaded settings confirm this. The observed source changed to addon-proxy/raw13; the uploaded files do not establish which exact command produced it. No case migration or user-data rewrite was needed.
- Verification: full mocked Windower regression via liblua5.4 and Lua5.1 syntax pass. New tests exercise closed-console automatic fitting,6/8/24 sizes, no sample writes, case-insensitive profile/trim restoration, manual preservation, failed measurement, intervening command/settings callback cancellation and reload persistence without compounding. Existing57-case/four-resolution, grid/drag/boundary/screenshot checks remain passing in simulation. No native v0.1.34 execution by Codex.
- Pending: live automatic selection/switch/reload acceptance; other-resolution and output-only/edit visual checks; intermittent clipped Input label remains separate/unresolved. No further full font sweep requested.

## 2026-10-19 — v0.1.34 automatic fitting check

1. Keep data/settings.xml, update/reload. Select a previously unused installed font/size with cbg font "Tahoma" 9 (choose another unused pair if9 is already measured). After several render frames calibration feedback should report native-estimate. No test rows/screenshots should appear. Console may be closed.
2. Switch to a saved manual/reference pair, then back. The fit and trims must restore exactly with no new probe; reload must preserve it. Existing raw addon-proxy fits remeasure only when explicitly selected; nativefont remains native-only. Bare font reports without remeasurement.
3. Optional: open console and test the current fit, then test trim only if padding needs visual comparison. Selecting another font, dragging, another layout command, settings callback or unload cancels pending measurement. Failed probe leaves the selected provisional/saved fit intact.
4. Confirm ordinary/Ctrl drag, edit resize, activity and Input behavior remain unchanged. The95% model is inferred from native screenshots at1280x720, not direct native glyph measurement or certification for every installed face. Existing manual calibrate remains raw/explicit, and test estimate remains available for refreshing non-manual estimates.

# Previous Development Status — v0.1.33

- Repository/branch: rerorriM-Mirrorer/Windower-Addons, consolebg-plus; ConsoleBGPlus v0.1.33 / Windower4. Tested starting checkpoint:6310b6c01896ac4c64296da423f110b3daabb0e2 (v0.1.32). Final published head is in handoff. Baseline branches unchanged.
- Latest material:data(3).zip contains three matched Tahoma8 trim PNG/TXT pairs plus an earlier current diagnostic without PNG. Current0/0,balanced5/3,tight5/5 use identical divider226; typed Agjpqy is visible. Assistant recommends5/5 for this pair based on visible descender clearance, but user has not selected/saved it. Earlier Rounded8 preference5/3 remains separate.
- Observed runner defect: native Saving Screenshot messages scroll the output between v0.1.32 variants. Input comparison remains usable, but the last native output row changes, preventing a fair row16 clearance comparison. New code refills16 rows before each trim capture and waits at least3 rendered frames/0.15s. First10s typing window retained. Typed Input untouched; no font/input commands or settings saves.
- Verification: full mocked Windower regression via liblua5.4 and Lua5.1 syntax pass. Added finite16-row native buffer simulation injects Saving Screenshot feedback after every capture and verifies each of all3 captures again contains exactly rows01–16 in order. Existing typing window, no settings saves/font-input commands, unchanged divider/geometry, restoration and57-case/four-resolution checks retained. No native v0.1.33 FFXI execution here.
- Pending: one clean Tahoma8 trim comparison; user trim preference; intermittent clipped Input label remains separate and unresolved. Other-resolution/output-only/edit live checks remain pending. No new automatic trim defaults or baseline promotion.

## 2026-10-19 — v0.1.33 short rerun

1. Keep data/settings.xml, update/reload and stay on Tahoma8/current saved calibration. Open console and run cbg test trim. Type Agjpqy WITHOUT Enter during the approximately10s window.
2. Stay focused: three variants capture automatically. Each PNG should contain rows01–16 with no previous Saving Screenshot message in their place. Native screenshot feedback can appear after a capture; it is replaced before the next. Input text must remain intact.
3. Verify top gap, output row16 descenders/divider and typed Input descenders/lower rail. Original saved trims/edit mode restore afterward. Send data ZIP and preferred current/balanced/tight variant. No trim choice saves until explicitly requested.
4. First sample plus three refills totals64 output writes. This supersedes v0.1.32's no-later-sample-write behavior; older records below remain intact. Interruption/capture error behavior and custom screenshot-directory option are unchanged.

# Previous Development Status — v0.1.32

- Repository/branch: rerorriM-Mirrorer/Windower-Addons, consolebg-plus; ConsoleBGPlus v0.1.32 / Windower4. Tested starting checkpoint:e760c282aedb1710308d4e8a28b0455a41b5ab00 (v0.1.31). Final published head is in the handoff. Baseline branches unchanged.
- Live materials reviewed: data(1).zip contains20 readable Tahoma PNG/TXT pairs covering sizes6–24 plus repeated11. data(2).zip contains19 readable Verdana PNG/TXT pairs covering6–24. Automatic native screenshots include ConsoleBGPlus and sample rows. The95% spacing model tracks observed rows; Tahoma23/24 clip at lower anchor, whereas Verdana23/24 fit after the anchor moved higher. This is native evidence at1280x720, not all-resolution certification.
- Separate issue: repeated Tahoma11 capture at062908 clips the Input label, despite the same24x11 reported label bounds as062816. Code inspection has not established a cause; no speculative label/layout redesign. Input descender clearance and trim preferences still require visual acceptance.
- New test trim [screenshot directory] captures current saved trims,balanced5/3,tight5/5 at current font/size. Initial16-row sample only; about10s to type Agjpqy without Enter; later variants preserve native input text by issuing no font/input commands or further sample writes. Temporary drawing overrides preserve saved settings, native anchor and divider. Completion/stop/failure/interruption restores saved layout and prior edit mode. Three uniquely paired PNG/TXT files identify variants.
- Verification: full mocked Windower suite via liblua5.4 and Lua5.1 syntax pass. New checks cover typing window, exactly3 screenshot requests, only16 output writes, no settings saves/font-input commands, explicit trial metadata, identical dividers, geometry restoration on completion/stop/focus loss. Earlier57-case/four-resolution, dragging, profile, capture failure and cleanup checks retained. No live v0.1.32 execution here.
- Next: one comparison at the user's everyday font/size, inspect typed descenders and choose preferred trim; then representative other sizes/modes if useful. No further full size sweep requested. Default source screenshots folder can be overridden explicitly; actual screenshot settings stay unchanged.

## 2026-10-19 — v0.1.32 short comparison

1. Keep data/settings.xml, update/reload. Choose the font/size normally used and open native console. Run cbg test trim (or test trim "C:/actual/screenshots/folder"). No font/profile reset is needed.
2. When16 sample rows appear, type Agjpqy WITHOUT Enter. You have about10s before capture. Stay focused with console open. Three variants capture automatically: trim_current,trim_balanced(5/3),trim_tight(5/5). All text and the Input divider should remain stationary; only visible top/bottom padding changes.
3. After the third capture the original layout/edit mode returns. Clear the unexecuted sample word. ZIP data and identify the preferred variant. The trial does not save trims; explicit existing trim command can save the user's choice later.
4. Stop, console close, focus loss, resolution/layout change, grabbing the frame, settings reload or capture/diagnostic failure ends the short comparison and restores saved layout. An already-issued native screenshot cannot be withdrawn. Retry with test trim after any outstanding file write completes.
5. Examine g/j/p/q/y in both row16 and Input, upper gap, rail/tab alignment and label completeness. Keep intermittent clipped labels separate from spacing/trim evaluation. Repeat only representative additional fonts/sizes after this preference check.

## 2026-10-19 — documentation correction and v0.1.31 retained record

The v0.1.31 handoff described a new Current Development Status entry, but its published root TESTING.md began with Previous Development Status—v0.1.30: the intended insertion was overwritten during file preparation. The earlier source history below is preserved. This explicit record supplies the missing delivery status from commit/code/test evidence rather than claiming that entry shipped.

v0.1.31 was published as e760c282aedb1710308d4e8a28b0455a41b5ab00, adding cbg_capture.lua, automatic19-case family captures, first-PNG inspection pause/test go, matching PNG copies,20s timeout and interruption handling. Mock regressions/Lua5.1 parsing passed before delivery; native execution was not performed by Codex. Subsequent user-provided Tahoma/Verdana ZIPs above supply native capture evidence. Original v0.1.31 README/CHANGELOG entries remain intact.

# Previous Development Status — v0.1.30

- Repository/branch: rerorriM-Mirrorer/Windower-Addons, consolebg-plus; ConsoleBGPlus v0.1.30 / Windower4. Tested starting checkpoint:45aa50b175118c8f3237e2a162c2c9c8fcd61beb (v0.1.29). Final published hash is in the handoff. Baseline branches unchanged.
- Received data.zip and Screenshots85–104: all19 Rounded size logs,18 matching Rounded screenshots (14 missing), Tahoma12/8 logs+screenshots. Native pitch inferred near95% of raw addon probe (e.g. Rounded16~23.75/25,20~29.45/31,24~36.1/38; Tahoma12~19/20). This evidence is from1280x720 and does not verify other systems/fonts. Revised Rounded12 divider clears row16 in Screenshot85; not blanket acceptance of all margins. Sizes23/24 are clipped by existing viewport height.
- New estimate tests/suite cases use a fresh raw probe times0.95, provisional4px pre-Input allowance, Input ceil(estimated pitch), source native-estimate and retained raw single/multi extents. Existing source manual/reference/trial-reference fits stay authoritative. Previously proxy-derived fits update only on explicit estimate tests or suite cases; no load migration or compounding. Raw calibrate and ordinary test unchanged.
- Named19-case suites support rounded/tahoma/verdana/current; default57-case suite retained. User can upload19 screenshots plus data ZIP. Next pass: suite tahoma, then suite verdana. Old Tahoma8/12 proxy samples are deliberately recaptured to validate updated estimates. Font substitution/native glyph bounds still need visual review.
- Verification: complete mocked Windower suite via liblua5.4 passes, including all57 cases at four simulated resolutions, existing grid/drag/save/profile/extreme-size tests, new raw-to95% derivation, repeated estimate idempotence, manual-fit preservation and exact19-sample named batches. All addon/test Lua parses as Lua5.1. No native Windows/FFXI run here.
- Pending: Tahoma/Verdana visual acceptance, Input descenders, trims, output/edit modes, other resolutions and clipping. Future correction may be required; inferred estimates are not certified native measurements.

## 2026-10-19 — v0.1.30 next collection

1. Keep data/settings.xml, update/reload. The old transient suite queue resets; saved fits remain. Open native console and enter cbg test suite tahoma.
2. For each ready sample take one screenshot, then cbg test next. There are19 font sizes; send19 screenshots plus a fresh ZIP of data together. This intentionally retests Tahoma12/8 using updated estimates. Capture name/log font and size identify the case.
3. After final next ends/restores starting font, run cbg test suite verdana for the next19-case batch. Additional families can use suite current. Next/repeat/status/stop/capture remain available; repeat remeasures an estimate from raw rather than scaling the previous estimate.
4. Inspect first/last glyph clearance and Input seam/bottom; type Agjpqy without Enter for Input descenders, clear before the next command. Keep top/bottom trims separate from spacing. Source native-estimate records inference; single/multi are raw. Manual/reference fits are preserved.
5. Record viewport clipping independently; use a taller UI to inspect complete extreme-size fits. Existing edit/output-mode, profile reload and dragging checklists remain applicable. The uploaded material contains no Verdana results yet.

# Previous Development Status — v0.1.29

- Repository/branch: rerorriM-Mirrorer/Windower-Addons, consolebg-plus; ConsoleBGPlus v0.1.29 / Windower4. Tested starting checkpoint: bb02119cdff122c5105409805f38d5eacb63f420 (v0.1.28). Final published hash is in the handoff; baseline branches unchanged.
- Latest live material: Screenshot (83).png and fonttest-Arial_Rounded_MT_Bold_12-20261019-055610-1.txt, v0.1.28,1280x720. Trial spacing18/height330 places Input in its strip, but row16 descenders nearly touch divider. New trial changes only bottom allowance1->4/full height330->333. Neutral extra trims remain. This is not final visual acceptance.
- Guided suite covers three fonts (Arial Rounded MT Bold/Tahoma/Verdana), all integer sizes6–24,57 cases; current-family option covers19. Native samples/unique diagnostics are automatic; each case waits for next. Explicit suite start applies revised Rounded12 reference; other saved fits retained. Stop/completion restores starting font; completed measurements remain. Session queue does not survive reload.
- Verification: full mocked Windower suite via liblua5.4 and Lua5.1 syntax checks pass. New57-case sequence plus a full57-case sweep at each of four simulated resolutions tests every font/size, sixteen sample writes per case, no timed advancement, premature-next handling, retry, mode-tagged captures without console writes, closed-console pause, completion/stop restoration and invalid suite input. Earlier grid/free drag/boundaries/four resolutions/extreme sizes/profile persistence tests remain passing in simulation. No Windows/FFXI execution here.
- Pending native acceptance: revised12 divider, all other font-size visual metrics, installed font substitution, label/tab alignment, Input glyph bottoms, output-only and edit modes, viewport clipping, multi-resolution and reload/input checks. This package collects the foreseeable calibration evidence in one build; it cannot guarantee no further visual corrections are needed.

## 2026-10-19 — v0.1.29 one-pass collection checklist

1. Keep data/settings.xml, update/reload, open console, run cbg test suite. Default order is Rounded/Tahoma/Verdana; within each12,8,10 then remaining6–24. Use test suite current for an additional installed font family. Input must be enabled.
2. At each ready message capture16 output rows plus Input; save the screenshot with its font/size. Automatic named diagnostic remains in data. Inspect top gap, pitch, last-row descenders/divider, Input baseline/bottom and labels/tab. Type Agjpqy without Enter for Input descenders, capture then clear. Native input cannot be injected/measured automatically.
3. cbg test next advances only when ready; repeat retries the current adjusted fit. status reports progress; stop or final next restores starting font. No automatic screenshot capture, timer-based next, or keystroke injection. Failed probe/diagnostic blocks next. Reopen console and repeat after interruption.
4. At8/12/24 of each family compare edit on/off and output-only activity. test capture saves unique mode-tagged diagnostics without changing layout or native rows. Use it from chat with console closed for output mode, while frame/native text are visible; output visibility remains governed by existing activity timers. After layout changes return to normal and repeat before next.
5. Repeat at960x540,1280x720 and available larger UI resolution. Diagnostics record actual viewport. Extreme sizes may clip; suite warns when full fit exceeds viewport. Capture clipping and repeat on a taller UI rather than interpreting a clipped result as a complete native fit. Do not silently resize/reposition the user's game.
6. After collection, switch font profiles away/back and reload; verify saved values exactly. Test free drag, both Ctrl keys, screen edges, edit resize and hidden-frame rejection, activity/fades and multi-client behavior. Automated coverage is simulated; mark live checks only after observation.
7. Send screenshots and fonttest logs together. Windows face substitution and native glyph geometry require visual review; all completed fit profiles persist, but queue progress resets on reload. No claim of exhaustive support for arbitrary installed fonts.

# Previous Development Status — v0.1.28

- Repository/branch: rerorriM-Mirrorer/Windower-Addons, consolebg-plus; ConsoleBGPlus v0.1.28 / Windower 4. Tested starting checkpoint: 0ffe1303e6c4c90fb65d2acd02078640ab596424 (v0.1.27). Final published head is in the handoff. No baseline branch promotion.
- User successfully ran the v0.1.27 size-12 sample: image(20261019-053620).png and fonttest-Arial_Rounded_MT_Bold_12-20261019-053529-1.txt. Diagnostic reports proxy spacing19, height352, Input19, top/bottom15/7, no extra trims, 1280x720. Screenshot indicates native pitch approximately18 and Input above the intended strip. Native pitch is inferred, not an API measurement.
- New explicit test preset [size] applies the bundled reference then completes the existing sample and unique diagnostic sequence. Ordinary test preserves existing fits. Rounded size12 trial uses spacing18, height330, Input19, margins15/1, neutral trims. Accepted size8 and provisional size10 references unchanged. Position/width/activity preferences remain intact.
- Verification: full mocked Windower suite passes through liblua5.4; Lua5.1 syntax checks pass. Added checks cover replacement of existing fit only on explicit reference test, sixteen writes, profile round trips, accepted size8 preservation, unsupported references and closed-console no-mutation. Existing drag/grid/boundary/resolution/extreme-font checks pass in simulation. No Windows/FFXI execution here.
- Pending: native size12 divider/descenders/Input bottom, top clearance, output-only fit, other fonts and resolutions. Next step is the single-command live check below.

## 2026-10-19 — v0.1.28 live check

1. Keep data/settings.xml; replace delivered files and reload. Open the native console, with Arial Rounded MT Bold selected, and enter cbg test preset 12.
2. Wait for ready feedback. Capture all16 output rows and Input. Share the uniquely named data/fonttest-...txt. Check row16 descenders against the divider, Input descenders against the bottom rail, and first-row clearance. Do not trim before this capture.
3. Bare cbg test repeats the current fit without replacing it. cbg test preset 8 explicitly restores and samples the accepted size8 reference. Switching back with cbg test 12 must restore the saved trial; reload should preserve it.
4. Confirm free/Ctrl body dragging, edit resize, boundaries, activity and independent client behavior remain unchanged. Other fonts should reject test preset without changing settings; ordinary test still supports them.

# Previous Development Status — v0.1.27

- Repository/branch: rerorriM-Mirrorer/Windower-Addons, `consolebg-plus`; ConsoleBGPlus v0.1.27, Windower 4. Starting checkpoint: `cc3503caa43fc9316d1ef61a5084d89608ca1170` (v0.1.26). Published final head is in the handoff.
- Bundled settings references: accepted Arial Rounded MT Bold 8 (height 234, spacing 12.4, Input 13, trim 5 3); working size 10 (height 284, spacing 15.3, Input 16, trim 5 5). Presets apply explicitly and preserve unrelated preferences. User authorized inclusion of settings and simplified/self-running tests. No full user settings.xml replacement is shipped.
- Latest material: image(20261019-050805).png and diagnostics(20261019-050814).txt at 1280x720, v0.1.26, Arial Rounded MT Bold 10. Manual spacing 15.3, top/bottom 15/1, full height 284, Input 16, trim 5 5; divider y360, native origin70,115. Screenshot note suggests more space above Input may still be needed. This is a working reference, not final visual approval.
- New test [size] switches the current family/size, preserves saved manual/reference fits, probes unknown estimates, waits for settling, prints 16 native rows with descenders and writes a unique timestamped diagnostic. It pauses on the chosen size for a user screenshot; it cannot judge native appearance or drive the user's FFXI client from this environment.
- Verification: complete mocked Windower suite via liblua 5.4; Lua 5.1 syntax. New checks cover both presets, unrelated settings preserved, 16 sample writes, unique diagnostic names for repeated tests, automatic new-size probing, intervening-command and console-close cancellation, probe failure, invalid sizes and cleanup. No live test of v0.1.27 here.
- Pending live check: keep data, update/reload, open native console, run cbg test 12. Capture the sample and attach its named diagnostic. Use cbg test for a fresh sample/diagnostic after manual adjustment. Then inspect size10's descender clearance and return to size8. Other fonts/resolutions remain unconfirmed.

## 2026-10-19 — v0.1.27 acceptance

1. Keep data/settings.xml. Test retains current manual fits; no reset is needed. Preset 8 or 10 deliberately replaces the current Rounded font-size reference only; position/width and activity/timing/colors remain.
2. Open console and run cbg test 12. Wait for ready feedback in FFXI chat; 16 numbered native rows should fill the output and leave the native Input line below them. Check descenders on row16 against the divider and typed Input descenders against the lower border.
3. Attach screenshot plus data/fonttest-...txt from that run. Repeat bare test and confirm a different file is created. Ordinary diagnose still overwrites diagnostics.txt.
4. Try size8 and size10: existing custom/manual fits should return. If no profile exists, a bundled Rounded reference may seed it. Confirm size8 trim5/3; size10 trim5/5 is still provisional.
5. For pending test cancellation, start an unknown-size probe and close console or change layout; it should not print a later surprise sample. A failed probe should leave the current layout without emitting a success sample.
6. Recheck dragging, grid, edit header, saved profile switching/reload and activity. Sample output writes to the shared console.log and can trigger other clients' activity watchers, as any native output can.

The previous cumulative records remain below.

# Previous Development Status — v0.1.26

- Repository/branch: rerorriM-Mirrorer/Windower-Addons, `consolebg-plus`; ConsoleBGPlus v0.1.26 / Windower 4. Starting source: `1628743ccdad3901eb0d01d4063ea15450d92134` (v0.1.25). Published final head is in the handoff.
- Ctrl+drag now floors the visible top-left edge to the shared UI grid in the current mode: trimmed normal edge or expanded edit header. Saved parent coordinates are translated by the current top trim; native text and all child primitives move together. Bounds remain authoritative if a very small viewport offers no grid point.
- Latest live acceptance: user reports trim 5 3 looks good at Arial Rounded MT Bold 8; prior saved height 234, manual spacing 12.4, Input height 13, native top offset 15. User observed that visible-edge alignment appeared to work only in edit mode; prior snapping used the parent above the trimmed border, now corrected. No v0.1.26 FFXI test performed here.
- Verification: complete mocked Windower regression suite via liblua 5.4 and Lua 5.1 syntax checks. New tests cover visible normal/edit edges at grid multiples, extreme mouse coordinates at both bounds, and persistence across settings reload. Existing tests cover both Ctrl keys, free drag, native text linkage, viewport clipping, trim/profile isolation, calibration, activity behavior and cleanup.
- Next: live Ctrl+body drag with edit off/on; keep trim 5 3/current calibration. Then begin Arial Rounded MT Bold 10, followed by 12, Tahoma 8/10/12 and Verdana 8/10/12. No automatic font or calibration changes occur in this update.

## v0.1.26 acceptance and font sequence

1. Keep data, update, reload. With edit off, Ctrl+drag from the body: visible top and left should land on grid multiples. Test either Ctrl. Enable edit and repeat for the expanded header. Release Ctrl for free dragging. Toggling edit changes which top edge is visible; grid placement happens during Ctrl+drag.
2. Check edges and reload. The saved parent may no longer itself be a grid multiple because it is above the trimmed visible top. It must still drive the entire group consistently.
3. Keep the accepted size-8 profile. Run font "Arial Rounded MT Bold" 10, then calibrate. Capture Input-open showing all 16 output rows and Input, and diagnose. First compare unadjusted results; manually fit only after that capture.
4. Inspect first-row clearance, last-row descenders/divider clearance, Input glyph bottoms, and bottom rail. Record spacing, full height, Input height, top offset and trims separately. Do not multiply size-8 trims to create other sizes.
5. Repeat at size 12, then Tahoma and Verdana 8/10/12. Confirm switching back to size 8 and reloading restore its accepted fit. Check smaller/larger UI resolutions afterward. Input-open alone is adequate initially; activity/output-only can follow when the main geometry fits.
6. Diagnose still overwrites diagnostics.txt; save/rename between captures. Include settings.xml when collecting the final profile set.

Older status/history below remains intact; statements that Ctrl snapping uses the untrimmed parent as its alignment reference are superseded by this batch.

# Previous Development Status — v0.1.25

- Repository/branch: rerorriM-Mirrorer/Windower-Addons, `consolebg-plus`; ConsoleBGPlus v0.1.25, Windower 4. Starting checkpoint: `d1b8ef22fb366e4442a975aff2e83a70682df742` (v0.1.24). Final published head is in the handoff.
- New per-font/size trim command independently retracts extra normal top space and raises only the Input bottom border. Native text, Input divider/label, spacing and saved height stay fixed. Existing profiles start with zero extra trims; no automatic application on upgrade.
- Latest live reference: diagnostics(9)/(10) and matching screenshots. User preferred saved full height 234 over 233 at Arial Rounded MT Bold 8, 1280x720, 12.4px manual spacing and 13px Input. Divider shifted from 254 to 255 with text unchanged. User clarified this clears the `g` descender above the Input upper rail; it was not primarily prompt breathing room. Preserve that divider.
- Verification: complete mocked Windower regression suite through liblua 5.4 and Lua 5.1 syntax checks. Targeted tests verify trim 5/2 moves top +5, bottom -2, divider/native text/Input label stationary, edit restores top only, separate-font isolation, reload, invalid input and tiny/large viewport clipping. No live FFXI test of v0.1.25 performed.
- Next live check: keep data/settings.xml, update/reload, stay on the saved Arial Rounded MT Bold 8 fit, run `//cbg trim 5 2` without recalibrating. Capture Input-open and diagnose; inspect output descenders and Input glyph bottoms. Other sizes need independent observations.

## 2026-10-18 — v0.1.25 acceptance

1. Keep data and the existing 234px saved fit. Reload and run trim 5 2. No recalibration is required or desired for this comparison.
2. Top should retract another 5px in normal/activity views. Native text stays fixed. Toggle edit: header restores upward, while text, divider and Input label remain stationary.
3. Input bottom rises 2px; its upper rail must retain the user's 1px descender clearance. Check `g`, `j`, `p`, `q`, `y` on the last output row and in a typed Input line.
4. Test trim 0 0 to reverse the drawing adjustment, then trim 5 2 to restore. Repeating either command must not accumulate. Other font/size profiles retain independent values; reload should restore the current pair.
5. Drag anywhere, Ctrl-drag, and resize in edit. Screen bounds and hidden-frame input behavior should remain as before. Auto output has no Input bottom trim; its output body height should only change by the extra top trim.

The previous records below remain intact. The assistant's earlier explanation of the 1px adjustment as prompt breathing room was superseded by the user's descender-clearance explanation above.

# Previous Development Status — v0.1.24

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
