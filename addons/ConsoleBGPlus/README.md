# ConsoleBG+

An FFXI-style frame for the Windower 4 console, with XIVParty's violet stripes, silver rails, a soft glow, and a fading right edge. Windower still draws the text and handles commands. ConsoleBG+ draws the frame around it.

Development status and live checklist: [TESTING.md](https://github.com/rerorriM-Mirrorer/Windower-Addons/blob/consolebg-plus/TESTING.md). The installable ZIP keeps that guide beside this README.

## Install and update

Extract the ConsoleBGPlus folder into Windower/addons. When updating, replace the addon files and **keep your data folder**; the ZIP contains no settings file. In FFXI chat, run **//lua load ConsoleBGPlus** for a first install or **//lua reload ConsoleBGPlus** after updating. Unload the original ConsoleBG addon if it is running.

Fresh settings start at **16,48** with equal left and right margins, a 344-pixel full height, Verdana 12 native console text, a 15-pixel Input strip, the native grey Input tab, and label sizes 8/7 for Console/Input. Automatic output shows a 322-pixel frame without the Input area: the 15-pixel strip plus 7 extra pixels are removed. Existing saved positions, label sizes, tab style, input heights, colors, and activity choices stay as they are. **//cbg reset** applies the new defaults if you want to start over.

## Move and resize

The visible frame is always draggable from its upper 18-pixel edge; hold either Ctrl for grid snapping. Body clicks pass through. During an activity-frame drag, the compact frame stays visible until release, then normal activity timing resumes.

Run **//cbg edit** to toggle the guides and enable resizing. A band of pale diagonal lines marks the draggable top edge; drag anywhere along it to move the frame. The matching mark at the lower-right corner resizes it. Each grip gains a soft pink wash on hover; while pressed, the wash goes away and its lines turn pale pink. Release the mouse to save. Run **//cbg edit** again when you finish. Closing the native console with Insert also ends edit and preview modes.

Hold **either Ctrl key** while dragging to floor the parent anchor to a shared screen-origin grid, initially **10 UI pixels**. **//cbg grid 7** saves a different spacing; bare **//cbg grid** reports it. Free dragging remains pixel-precise. The grid does not resize the widget or snap its individual children. Screen edges take precedence; Ctrl+resize keeps its existing behavior.

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
    //cbg calibrate                            Measure current font; fit 15 rows
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

Start with the installed Arial Rounded face:

```text
//cbg font "Arial Rounded MT Bold" 8
//cbg calibrate
```

The linked font command sets native console text and frame labels, restoring a saved layout for that exact font/size. A new pair gets an estimate derived from the original size-12 design: 15 output rows with fixed top/bottom margins and a separate Input row. It no longer keeps the output background at size-12 height. Font sizes remain 6-24; label sizes remain 6-16. Rails retain their native pixel dimensions. Existing layouts are not automatically recalibrated on upgrade or reload.

**//cbg calibrate** renders two invisible addon text probes (one and three lines), waits for stable positive extents, and estimates line spacing as `(three-line height - single-line height) / 2`. It fits 15 output rows, uses one line of that spacing for Input, and saves the result by font/size. Failure to settle within 90 render frames leaves the layout intact. Another layout command, a drag, settings reload, or unloading cancels a pending probe. No probe text is written to console.log.

**These are addon-text measurements, not measurements of the native console.** Windows font substitution and different renderer metrics can still affect the result. We cannot detect whether the requested face is installed. Compare all 15 native output rows, then open Input and check its extra row. Begin with Arial Rounded MT Bold at 8, 10, and 12; repeat for Tahoma and Verdana after the first face fits.

**//cbg calibrate status** reports spacing, source, margins, and height. **//cbg diagnose** also records single/three-line measurements, the requested font, and the viewport. To correct a native-renderer mismatch, use **//cbg calibrate 12.5 10 6 13**: this example means 12.5px line spacing, 10px top margin/native text offset, 6px bottom allowance, and 13px Input height. These are example values, not a verified preset. Omitted margins/Input keep current values. Spacing accepts 4-128 pixels; top/bottom accept 0-128 and Input 6-256. The frame is still clipped to the viewport if all 15 rows cannot fit.

Profiles save absolute height, Input height, label calibration, and native text offsets. Switching repeatedly does not compound rounding. Manual layout adjustments are retained when leaving a profile. Position, width, colors, fade, and activity controls remain shared settings. Reload reapplies the active saved font/layout. **//cbg reset** clears the profiles as well as restoring defaults.

Verdana 12 is an initial default, not a forced font. Load/reload reapplies the saved font. **//cbg nativefont** changes native text alone; labelfont and labelsize remain available for individual adjustments. Native text has no documented font/extent getter, so a different typeface may still need **//cbg offset**, **//cbg labeloffset**, or **//cbg input on <height>** after inspecting it with preview. Changing console_font outside the addon is not detected and is overwritten by the saved font on reload.

## When something looks wrong

For a spacing issue, take a screenshot and run **//cbg diagnose** while the issue is visible. It writes ConsoleBGPlus/data/diagnostics.txt with saved settings, screen and frame size, measured label bounds, log availability, and the last native position **set by the addon**. Each run replaces the prior snapshot.

For a fade or repeated-output issue, run **//cbg trace on** before the test, wait for the frame to settle, trigger output during the hold and fade, then run **//cbg trace off** and **//cbg diagnose**. Share data/visibility.log, data/diagnostics.txt, and a screenshot if useful. Each trace on starts a fresh file. The trace records frame opacity steps, log byte growth, output age, and clock_ms elapsed since the trace began. It stops after 512 changes. Neither file records typed input or console output text.

The addon cannot read native console input, output text, or live fade opacity. If console.log is unavailable or its writes are delayed, automatic background timing may lag native output; manual opening still works. Existing calibration can vary by resolution, so use **//cbg position**, **//cbg offset**, and **//cbg input on 15** to adjust it.

## Credits

Derived from [ConsoleBG by StarHawk](https://github.com/Windower/Lua/tree/live/addons/ConsoleBG). Textures derive from [XIVParty by Tylas](https://github.com/Tylas11/XivParty/tree/master/assets/ffxi); terms and attribution are in LICENSE.txt. The addon uses Windower's built-in config library and does not require XIVParty to be installed.



## Changelog

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
