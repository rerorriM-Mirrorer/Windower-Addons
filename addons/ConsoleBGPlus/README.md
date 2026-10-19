# ConsoleBG+

An FFXI-style frame for the Windower 4 console, with XIVParty's violet stripes, silver rails, a soft glow, and a fading right edge. Windower still draws the text and handles commands. ConsoleBG+ draws the frame around it.

Development status and live checklist: [TESTING.md](https://github.com/rerorriM-Mirrorer/Windower-Addons/blob/consolebg-plus/TESTING.md). The installable ZIP keeps that guide beside this README.

## Install and update

Extract the ConsoleBGPlus folder into Windower/addons. When updating, replace the addon files and **keep your data folder**; the ZIP contains no settings file. In FFXI chat, run **//lua load ConsoleBGPlus** for a first install or **//lua reload ConsoleBGPlus** after updating. Unload the original ConsoleBG addon if it is running.

Fresh settings start at **16,48** with equal left and right margins, a saved 344-pixel full height (336 visible outside edit mode), Verdana 12 native console text, a 15-pixel Input strip, the native grey Input tab, and label sizes 8/7 for Console/Input. Automatic output shows a 314-pixel frame outside edit mode (322 with the header restored) without the Input area: the 15-pixel strip plus 7 extra pixels are removed. Existing saved positions, label sizes, tab style, input heights, colors, and activity choices stay as they are. **//cbg reset** applies the new defaults if you want to start over.

## Move and resize

Drag anywhere inside the visible frame; hold either Ctrl for grid snapping. The lower-right corner resizes in edit mode and otherwise drags. Hidden frames do not capture input. During an activity-frame drag, the compact frame stays visible until release, then normal activity timing resumes.

Run **//cbg edit** to toggle the guides and enable resizing. A band of pale diagonal lines marks the top grip; the entire frame remains draggable. The normal view trims up to eight pixels from unused top space, leaving at least seven pixels before the saved native-text origin. Edit mode restores that space upward without shifting native text, Input, or the bottom rail. Custom offsets with less spare space get a smaller trim. The matching mark at the lower-right corner resizes it. Each grip gains a soft pink wash on hover; while pressed, the wash goes away and its lines turn pale pink. Release the mouse to save. Run **//cbg edit** again when you finish. Closing the native console with Insert also ends edit and preview modes.

Hold **either Ctrl key** while dragging to floor the parent anchor to a shared screen-origin grid, initially **10 UI pixels**. **//cbg grid 7** saves a different spacing; bare **//cbg grid** reports it. Free dragging remains pixel-precise. Normal Ctrl+drag uses the trimmed visible top edge; edit Ctrl+drag uses the expanded header edge. The saved parent is translated to keep all children together. At tight screen bounds with no valid grid point, bounds win. The grid does not resize the widget or snap individual children. Screen edges take precedence; Ctrl+resize keeps its existing behavior.

In screen-width mode, dragging left or right keeps matching side margins. Resizing sets a fixed width; **//cbg width screen** returns to screen-width mode. When console movement is linked, the native text follows the frame.

## Commands

Type these in FFXI chat. Angle brackets mark required arguments, square brackets mark optional arguments, and a vertical bar separates choices. Command forms and descriptions are aligned below for quick reference.

**//cbg pos**, **size**, **offset**, **nativefont**, **labelfont**, **labelsize**, **font**, and **fade** report current values when given no arguments. **//cbg width** restores screen-width mode, just like width screen.

**//cbg tabstyle** and **//cbg tabstyle toggle** both switch between the native grey plaque and red lettering.

    Layout
    //cbg grid [pixels]                        Ctrl+drag grid, default 10 UI pixels
    //cbg edit [on|off]                         Toggle or set mouse edit mode
    //cbg position [<x> <y>]                      Move the frame to pixel coordinates
    //cbg size [<width> <height>]                 Set the outer size and fixed width
    //cbg width [screen|<pixels>]                Use equal side margins or fixed width
    //cbg console on|off                        Link or unlink native text movement
    //cbg offset [<x> <y>]                        Position native text relative to frame

    Input and labels
    //cbg input on|off [height]                 Show Input strip; fresh height is 15
    //cbg inputpad <0-32>                       Add extra space below the input line
    //cbg divider on|off                        Show or hide the input divider
    //cbg tab left|right                        Choose Input label side
    //cbg tabstyle [red|native|toggle]          Toggle or set Input tab style
    //cbg label <text>                          Change the Input label (1-16 bytes)
    //cbg labelfont [<font name>]                 Change frame label font
    //cbg labelsize [<title> <input>]             Set label sizes (6-16)
    //cbg labeloffset <-12 to 12>              Move Input label vertically
    //cbg font [<font name> <size>]             Linked font/size; no args reports it
    //cbg preset [8|10|12]                       Rounded reference settings
    //cbg test [size]                          Fill 16 native rows; save named diagnostic
    //cbg trim [<extra top> <Input bottom>]     Per-font trims; 0-32 and 0-8 pixels
    //cbg calibrate                            Measure current font; fit 16 rows
    //cbg calibrate status                     Report current font calibration
    //cbg calibrate <line> [top [bottom [input]]]  Set exact pixel calibration
    //cbg nativefont [<font name> <size>]         Set native console font (size 6-24)
    //cbg nativecolor <a> <r> <g> <b>           Set native console color (0-255)

    Appearance
    //cbg gradient <top> <bottom>              Set fill opacity at top and bottom
    //cbg alpha <0-255>                         Set overall fill strength
    //cbg border <0-255>|link|free              Set rail strength or gradient link
    //cbg glow <0-255> [height]                 Set bottom glow and height (4-128)
    //cbg color <a> <r> <g> <b>                 Tint the frame (0-255)
    //cbg preview [on|off]                      Keep the full frame visible to inspect

    Activity and settings
    //cbg activity [on|off]                       Toggle automatic frame; keep logging
    //cbg nativeactivity [on|off]               Toggle native automatic text
    //cbg fade [<hold_ms> [fade_ms]]              Set native hold and frame fade
    //cbg opensound on|off                      Play a cue on manual console open
    //cbg closesound on|off                     Play a cue on manual console close
    //cbg trace on|off                          Record visibility and timing changes
    //cbg diagnose                              Save one settings/layout snapshot
    //cbg status                                Show current geometry and modes
    //cbg reset                                 Apply fresh defaults
    //cbg help                                  Show command groups in game

Fresh/reset settings use a 450 ms background fade; existing saved timings stay intact. Run **//cbg fade 1000 450** to try it without resetting your layout.

The default native font is Verdana 12 with color 255 250 250 250. The Console label uses Verdana 8 and Input uses Verdana 7. **//cbg fade 1000 450** gives automatic output and the load-in frame pulse a 1000 ms hold followed by a 450 ms frame fade. The compact frame appears on addon load even if console.log is unavailable; it does not create native console text or play a sound. If the native console is already open or opens during the pulse, manual display takes over. On manual opening, the first rendered frame shows the compact output body; the next frame adds a darker Input panel beneath the unchanged output fill. Its darker fill begins at the silver top rail, with no dark lip above it, while the compact bottom rail stays hidden. Closing a manually opened console immediately removes the Input panel, upper rail, and tab, returns to the same compact output height, then fades over the saved frame fade duration. **//cbg activity off** stops the frame watcher without changing native automatic text. **//cbg nativeactivity off** disables Windower's automatic text without changing the frame watcher. Bare commands toggle either saved choice. Both keep **console_log 1**, and manual Insert opening and the load pulse still work. Native activity defaults to on, including when upgrading an older settings file; use nativeactivity off to save a different choice.

Clients launched from the same Windower installation watch the same console.log. Its growth does not identify a source client: another client's messages can trigger any enabled frame watcher. To keep native messages on an alt without the background, use **//cbg activity off** and **//cbg nativeactivity on**. The addon does not change another client's settings. The watcher checks file length about eight times per second and starts at the current end of the file when re-enabled.

The bundled open and close cues play once at each native console visibility transition in the focused game window. Automatic output and preview do not play sounds. Use **//cbg opensound off** or **//cbg closesound off** to silence either cue. Replace **assets/consoleopen.wav** or **assets/closeconsole.wav** with another short PCM WAV if desired. The addon detects native visibility changes; Windower does not identify which key opened or closed it. The supplied open recording is a working draft for testing.

## Linked font calibration

Calibration now fits **16 output rows plus one Input row (17 total)**. Existing saved layouts keep their previous height on upgrade/load/font switching. Run **//cbg calibrate** to replace the active fit with the corrected count. **//cbg calibrate status** and diagnostics distinguish legacy 15-row fits from new 16-row fits.


Start with the installed Arial Rounded face:

```text
//cbg font "Arial Rounded MT Bold" 8
//cbg calibrate
```

The linked font command sets native console text and frame labels, restoring a saved layout for that exact font/size. A new pair gets an estimate derived from the original size-12 design: 16 output rows with fixed top/bottom margins and a separate Input row. It no longer keeps the output background at size-12 height. Font sizes remain 6-24; label sizes remain 6-16. Rails retain their native pixel dimensions. Existing layouts are not automatically recalibrated on upgrade or reload.

**//cbg calibrate** renders two invisible addon text probes (one and three lines), waits for stable positive extents, and estimates line spacing as `(three-line height - single-line height) / 2`. It fits 16 output rows, uses one line of that spacing for Input, and saves the result by font/size. Failure to settle within 90 render frames leaves the layout intact. Another layout command, a drag, settings reload, or unloading cancels a pending probe. No probe text is written to console.log.

**These are addon-text measurements, not measurements of the native console.** Windows font substitution and different renderer metrics can still affect the result. We cannot detect whether the requested face is installed. Compare all 16 native output rows, then open Input and check its extra row. Begin with Arial Rounded MT Bold at 8, 10, and 12; repeat for Tahoma and Verdana after the first face fits.

**//cbg calibrate status** reports spacing, source, margins, and height. **//cbg diagnose** also records single/three-line measurements, the requested font, and the viewport. To correct a native-renderer mismatch, use **//cbg calibrate 12.5 10 6 13**: this example means 12.5px line spacing, 10px top margin/native text offset, 6px bottom allowance, and 13px Input height. These are example values, not a verified preset. Omitted margins/Input keep current values. Spacing accepts 4-128 pixels; top/bottom accept 0-128 and Input 6-256. The frame is still clipped to the viewport if all 16 rows cannot fit.

Profiles save absolute height, Input height, label calibration, and native text offsets. Switching repeatedly does not compound rounding. Manual layout adjustments are retained when leaving a profile. Position, width, colors, fade, and activity controls remain shared settings. Reload reapplies the active saved font/layout. **//cbg reset** clears the profiles as well as restoring defaults.

Verdana 12 is an initial default, not a forced font. Load/reload reapplies the saved font. **//cbg nativefont** changes native text alone; labelfont and labelsize remain available for individual adjustments. Native text has no documented font/extent getter, so a different typeface may still need **//cbg offset**, **//cbg labeloffset**, or **//cbg input on <height>** after inspecting it with preview. Changing console_font outside the addon is not detected and is overwritten by the saved font on reload.

## Fine trim per font and size

`//cbg trim 5 2` removes five more pixels from the normal top and raises the Input strip's bottom border by two pixels. It leaves native text, the divider/upper Input rail, Input label, saved full height and font spacing unchanged. Edit mode restores the top header; its Input bottom remains trimmed. Automatic output uses the tighter top but has no Input bottom trim.

These values save with the current font/size profile; bare `//cbg trim` reports them. `//cbg trim 0 0` restores the previous drawing. Extra top accepts 0-32 pixels, bounded to leave at least two pixels before the native-text origin; Input bottom accepts 0-8, bounded to retain a usable strip. Small viewports apply additional bounds. No proportional scaling is applied to these corrections.

For the user-tested Arial Rounded MT Bold 8 fit (12.4px spacing, 13px Input, saved full height 234), use `//cbg trim 5 2` **without recalibrating**. This preserves the extra pixel of divider clearance for the output line's `g` descender. Other fonts and sizes keep their own trim values, initially zero.

## Bundled references and simpler testing

The addon includes settings as reference presets; keep your existing data folder. No whole settings.xml replacement is needed. On Arial Rounded MT Bold, `//cbg preset 8` restores the accepted 234px/12.4px/trim 5 3 reference. `//cbg preset 10` restores the latest **working** size-10 reference: 284px height, 15.3px spacing, 16px Input, trim 5 5. Size 10 may still need more divider clearance; it is not declared final. Presets replace that font/size calibration but preserve position, width, colors, timing and activity choices. No preset applies automatically on load.

To apply and sample the corrected size-12 trial in one step, open the native console and run `cbg test preset 12`. This deliberately replaces its previous calibration; `cbg test preset 8` restores and samples the accepted size-8 reference. Size 12 remains provisional; its trims stay neutral until reviewed.

With the native console open, run `cbg test 12` (or `//cbg test 12` from FFXI chat while console is open). It switches the current font family to that size, keeps existing saved fits, measures a new estimate when needed, waits for label settling, fills **16 numbered native console rows** including `g j p q y`, and saves a uniquely named `data/fonttest-<font>_<size>-<UTC timestamp>-<counter>.txt`. The Input row remains native and ready for inspection. The command stays on that font/size so you can capture it. Bare test samples the current fit after a manual adjustment. Bare preset applies the available reference for the current size.

Use `test 8` to return to the saved size-8 fit. A bundled preset seeds an as-yet unsaved Arial Rounded 8/10/12 profile during a test; an existing saved profile takes precedence. A known manual/reference fit is never re-probed by test. To deliberately replace it with a new measurement, use calibrate separately.

The test writes sample output into console.log and replaces the visible console buffer's last 16 rows. It does not send FFXI chat, inject keys, type into Input, automatically take screenshots, or judge native appearance. Close the console, change layout, drag, or reload to cancel a pending test. Measurement failure reports an error instead of emitting a completed sample. Named test diagnostics are retained; ordinary diagnose still replaces diagnostics.txt.

## Font calibration sequence

The current live reference is Arial Rounded MT Bold 8: manual 12.4px spacing, 15px top offset, 13px Input height, saved full height 234px, and trim 5 3. Preserve that profile while testing other sizes.

Next use `//cbg font "Arial Rounded MT Bold" 10`, then `//cbg calibrate`. Capture Input-open with all 16 output rows plus Input and run diagnose. Inspect first-row top clearance, last-row descenders above the divider, and Input glyph bottoms. Adjust each independently; do not transfer size-8 pixel trims proportionally. Repeat at 12, then the installed Tahoma face at 8/10/12, then Verdana. Input-open is sufficient for the first comparison; activity/output-only is a follow-up once the fit works.

Switch back to size 8 to verify the accepted profile returns, then reload. Finally check the same profiles on the smaller and larger UI resolutions, recording those resolutions in each diagnostic. Save/rename diagnostics.txt before another capture overwrites it. A profile is confirmed only at the font/size/resolutions actually inspected in-game.

## When something looks wrong

For a spacing issue, take a screenshot and run **//cbg diagnose** while the issue is visible. It writes ConsoleBGPlus/data/diagnostics.txt with saved settings, screen and frame size, measured label bounds, log availability, and the last native position **set by the addon**. Each run replaces the prior snapshot.

For a fade or repeated-output issue, run **//cbg trace on** before the test, wait for the frame to settle, trigger output during the hold and fade, then run **//cbg trace off** and **//cbg diagnose**. Share data/visibility.log, data/diagnostics.txt, and a screenshot if useful. Each trace on starts a fresh file. The trace records frame opacity steps, log byte growth, output age, and clock_ms elapsed since the trace began. It stops after 512 changes. Neither file records typed input or console output text.

The addon cannot read native console input, output text, or live fade opacity. If console.log is unavailable or its writes are delayed, automatic background timing may lag native output; manual opening still works. Existing calibration can vary by resolution, so use **//cbg position**, **//cbg offset**, and **//cbg input on 15** to adjust it.

## Credits

Derived from [ConsoleBG by StarHawk](https://github.com/Windower/Lua/tree/live/addons/ConsoleBG). Textures derive from [XIVParty by Tylas](https://github.com/Tylas11/XivParty/tree/master/assets/ffxi); terms and attribution are in LICENSE.txt. The addon uses Windower's built-in config library and does not require XIVParty to be installed.



### Short padding comparison

Choose the font/size you actually want to use, open the native console, then enter `cbg test trim`. An optional screenshot-directory argument works as in auto capture. The command prints16 sample rows once, then gives about10 seconds to type `Agjpqy` into the native console WITHOUT Enter. Leave it there with the game focused: three PNG/TXT pairs capture automatically, with suffixes trim_current, trim_balanced and trim_tight.

Current uses your saved trims; balanced previews extra-top5/Input-bottom3; tight previews5/5. They use temporary drawing overrides only. Text, parent position, row spacing, Input divider and font stay fixed. Later variants neither reprint sample rows nor send font/input commands, so the typed descenders remain for comparison. The sequence automatically restores the saved layout and prior edit state after the third capture. Stop, failure or interruption also restores them. No trial values are saved or silently applied on load. Diagnostic trim_trial records the variant while its saved-settings section remains unchanged.

Send the data ZIP and say which version you prefer. We can then save the chosen values using the existing trim command. Start with your everyday font/size; representative small/large fonts can follow if needed, rather than another57-case sweep. Default capture watches Windower's screenshot folder; supply its actual leaf directory if customized. Do not press Enter on the sample word or type another console command during capture. Failed capture ends this short comparison; restart test trim after addressing it. This feature does not populate or read native Input text.

### Automatic screenshot trial

Open the native console and run `cbg test auto tahoma`. It runs the existing19-case family suite with the current spacing estimates. After the first sample settles (at least3 further rendered frames and0.5s), it sends Windower `screenshot png` without hide. It watches the default `windower.windower_path/screenshots/` folder for exactly one new PNG with PNG signature and IEND trailer, then copies that file beside its diagnostic as the same fonttest basename with `.png` instead of `.txt`. Original screenshots remain in Windower's folder. No screenshot directory, format default, keybind, or plugin setting is changed.

The first completed file pauses. Inspect the matching PNG in data: it must include the console, ConsoleBGPlus and the complete16-row sample. If usable, reopen/focus the game and run `cbg test go` to capture the remaining18 automatically. Each subsequent case waits for its PNG, then an extra second before advancing. Completion restores the starting font. Use `test auto verdana` for the next19-case batch. Send a ZIP of data containing both screenshots and diagnostics. File markers confirm completion only, not correct/visible image content; first-frame visual acceptance is required. This remains untested with native Windower capture.

For a custom screenshot folder, use `cbg test auto tahoma "C:/path/to/screenshots"`. Supply the folder where Windower already writes; this command does not redirect it. Organized/nested screenshot folders (e.g. plugins) must point to the actual leaf folder. No recursive scanning, moving, deleting, or renaming of existing screenshots occurs. Keep other clients/manual screenshot producers idle during the batch; multiple new PNGs cause a pause, but a single unrelated PNG cannot be distinguished from this client's capture.

Missing/incomplete PNG, unreadable directory, ambiguous files, command/copy error or20-second timeout pauses without advancing. Conversion that produces only BMP is not accepted. Use test repeat after the failure is reported to retry the same case; this pauses again for inspection. Next/repeat cannot replace an in-flight file capture; stop may cancel the session. Closing console, losing focus, changing resolution, layout commands, settings reload or grabbing the frame cancels queued capture/automatic advancement. Already issued native screenshot commands cannot be withdrawn; let them finish before restarting. Test status reports the suite; stop restores the starting font. For manual fallback, stop and use test suite tahoma/verdana as before.

### Updated estimates and upload batches

The v0.1.29 screenshots at1280x720 show native row pitch near95% of addon proxy pitch: Rounded16 about23.75 versus25, Rounded20 about29.45 versus31, Rounded24 about36.1 versus38; Tahoma12 about19 versus20. This is an inference from supplied images, not a native font getter or a guarantee for other systems.

`cbg test suite tahoma` runs19 cases, one per size6–24; upload19 screenshots plus the data ZIP together. Then `cbg test suite verdana` runs the next19. `rounded` and `current` are also accepted. Next/repeat/status/stop retain their existing behavior. A single-family suite restores the starting font after its final next; reload starts a new session rather than resuming the prior queue.

Suites now use updated estimates for unknown or previously proxy-measured pairs. `cbg test estimate [size]` applies this deliberately to a single pair. It derives spacing from95% of a fresh raw probe, retains raw single/multi heights, uses a provisional4px allowance before Input and an Input height equal to rounded-up estimated pitch. Manual/reference fits remain authoritative. Repeating the command never scales an already scaled result. No estimates change on load. Ordinary test and raw calibrate retain their behavior; explicit numeric calibration is unchanged. Known size8/10 references and revised size12 trial remain intact.

Tahoma8/12 already captured with the old proxy are intentionally included again to check the new model. Top and bottom trim choices remain separate from this spacing estimate. Sizes23/24 previously clipped at the720px viewport; document clipping independently, and inspect on a taller UI when needed. Collect first; visually correct any remaining mismatch afterward.

### Guided full calibration pass

Keep your data folder and optionally back up settings.xml. Open the native console and enter `cbg test suite`. This explicitly applies the revised Rounded size12 reference first, then visits57 font/size cases. Installed font availability cannot be queried; Windows may substitute a missing face. Existing other saved fits take precedence over proxy measurements. Unknown pairs use the addon-text proxy and still require native visual inspection.

For each ready sample, take a screenshot containing all16 output rows and Input, then enter `cbg test next`. The automatic diagnostic contains the font, size, source, viewport and geometry. Inspect first-row top clearance, uniform row pitch, last-row descenders against the divider, Input baseline and bottom, and label/tab alignment. For Input descenders, type `Agjpqy` without pressing Enter, capture, then clear it before entering the next command. Native input text cannot be filled or measured by the addon. Use `cbg test repeat` after an adjustment or interrupted probe; it samples the adjusted fit without reapplying a reference. A failed measurement/diagnostic does not unlock next. `cbg test status` reports progress.

At representative sizes8/12/24 for each family, also inspect edit on/off (only the header should move), and an output-only activity view after closing the console. `//cbg test capture` from chat records the current mode without reopening the console or replacing the sample. Only call an output capture successful if the frame/native text are actually visible; normal activity/fade settings remain unchanged. Edit/layout commands pause advancement; repeat after returning to the normal view.

Repeat the suite on each available UI resolution (at least960x540,1280x720 and the larger display). Oversized cases warn when the fit exceeds the viewport; record clipping rather than treating it as a measured native fit. A taller UI is required to inspect all rows at extreme sizes. The addon cannot resize the game window, take screenshots, verify installed fonts, or judge glyph bounds. All fonts ever installed cannot be exhaustively validated by this suite; use `test suite current` for additional families.

At the end, next restores the starting font, as does stop. Completed font profiles remain saved; the suite cannot resume its queue across reload. Check font round trips and reload persistence, free/both-Ctrl dragging at screen edges, edit resizing, and ordinary activity afterward. These input checks are automated in the mock suite but still require live acceptance. Collect screenshots and all matching fonttest logs together; native visual corrections may require another pass.

## Changelog

### 0.1.32 — short padding comparison

- test trim compares current,5/3 and5/5 in three automatic screenshots of one chosen font/size. Ten-second typing window; sample emitted once; no font/input commands between variants.
- Drawing overrides leave saved settings and text/divider geometry intact and restore on completion/interruption. Native label clipping remains a separate unresolved renderer observation.

### 0.1.31 — opt-in PNG capture trial

- Automatic single-family screenshot tests, first-file inspection pause and explicit go continuation. Wait for completed PNG, match/copy to diagnostic basename, restore starting font after19 cases.
- Capture failures/timeouts/ambiguity and user interruptions pause; ordinary/manual tests stay available. Native screenshot support still needs live verification.

### 0.1.30 — evidence-based trial estimates

- Estimate tests use0.95 of fresh raw probe pitch with provisional4px pre-Input allowance; source native-estimate and raw extents recorded. Manual/reference profiles preserved, no automatic load migration, no repeated scaling.
- Family-specific19-case suites fit19 screenshots plus one data ZIP. Start with suite tahoma, then suite verdana. Full suite still covers57 cases.

### 0.1.29 — complete guided calibration pass

- `test suite` covers Arial Rounded MT Bold, Tahoma and Verdana at every integer size6–24. `test suite current` covers only the current family. Cases begin12/8/10, then the remaining sizes in ascending order.
- Each case prints16 rows and saves a unique diagnostic, then waits for `test next`. `test repeat` retries the current fit after adjustments/interruption; `test status` reports progress; `test stop` restores the starting font. Completion also restores it. Session progress is transient; completed fit profiles and diagnostics persist.
- `test capture` saves a unique diagnostic of the current Input/edit/output mode without writing sample rows or changing layout. Useful when comparing modes or resolutions.
- Rounded size12 trial adds3px clearance before Input (bottom allowance4, full height333). Existing saved size12 fits change only on explicit preset or suite reference application. Sizes8/10 remain unchanged.

### 0.1.28 — explicit reference test

- `//cbg test preset 12` applies the provisional Arial Rounded MT Bold 12 fit, prints 16 sample rows, and saves a unique diagnostic in one command. This explicitly replaces the target font-size fit; ordinary test continues preserving saved fits.
- Size-12 trial: 18px spacing, 330px full height, Input 19, top/bottom allowances 15/1, no extra trims. Inferred from the supplied native screenshot, pending live acceptance. Sizes 8/10 remain unchanged. `test preset 8` restores and samples the accepted size-8 reference.

### 0.1.27 — reference settings and native test helper

- Bundled accepted size-8 and working size-10 Rounded settings, applied explicitly.
- One-command font-size test prints 16 native sample rows and saves a unique diagnostic; existing fits are preserved.

### 0.1.26 — visible-edge grid alignment

- Ctrl+drag aligns the visible top-left in both normal and edit views, translating back to the stable saved parent.
- Retained the accepted Arial Rounded MT Bold 8 reference and documented the next font/size checks.

### 0.1.25 — per-font top and Input-bottom trim

- Added saved trim controls that preserve divider/native text positions and the manually fitted full height.
- Extra top retracts only outside edit mode; Input bottom trim is independent of the upper rail.
- Diagnostics report both effective trims.

### 0.1.24 — corrected output-row calibration

- New estimates and explicit calibration use 16 output rows plus one separate Input row.
- Existing profiles keep their saved height until recalibrated; status/diagnostics report fit row count.

### 0.1.23 — compact header and whole-frame dragging

- Normal and activity views retract up to 8px of unused top background; edit mode restores the header upward while native text/Input/bottom remain fixed.
- Entire visible frame drags; edit mode reserves the lower-right corner for resize. Existing parent-anchor grid and saved font profiles are retained.
- Diagnostics report the parent anchor and visible top trim.

### 0.1.22 — always-draggable frame

- Visible top edge drags without edit mode, including activity frames; edit mode retains guides and resizing.
- Active drag holds the frame visible; release saves and resumes normal timing.

### 0.1.21 — calibration and Ctrl+drag test

- Screen-origin Ctrl+drag parent-anchor snapping with saved grid spacing; free drag and resize retained.
- Fifteen-row font sizing, opt-in invisible text measurements, exact pixel overrides, and per-font/size absolute profiles.
- Calibration/grid diagnostics and current root WORKFLOW/TESTING guidance.
- Lua 5.1 syntax and Lua 5.4 mocked checks pass; native font fit and mouse behavior await live acceptance.

### 0.1.20 — previous batch

- Independent frame/native activity controls, linked font command, 450ms fresh/reset fade, and bare setting readouts.
- Original delivery notes and two-client checklist remain in CHANGELOG.md.
