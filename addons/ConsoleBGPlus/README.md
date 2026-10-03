# ConsoleBG+

An FFXI-style frame for the Windower 4 console, using XIVParty's violet stripes, silver rails, a transparency gradient, and native right-edge fade. Version **0.1.5** brings the Console title closer to the game's Say tab and applies a saved native console profile on load. The optional output watcher and fade from v0.1.4 remain available.

## Install or update

Extract the `ConsoleBGPlus` folder into `Windower/addons`. When updating, copy the new files into the existing folder and **keep your `data` folder**. The ZIP contains no settings file, so existing frame colors, position, width mode, glow, and input height are retained. This update does apply new native font/color defaults to clients that have not yet saved those fields.

Run in FFXI chat:

```text
//lua unload ConsoleBG
//lua reload ConsoleBGPlus
```

For a first install, use `//lua load ConsoleBGPlus` instead of reload. The addon needs Windower's built-in `config` library. Its 21 texture pieces unpack from `cbg_skin.lua`; XIVParty, Trust, and Balloon do not need to be installed.

New installations start at **32,16**, follow the screen width, and draw **348 pixels** tall, including four pixels of extra bottom space. The gradient defaults to **100 → 250**, with **200 strength over 24 pixels** of bottom glow. Native console text starts 50 pixels right and 15 pixels below the frame origin. The input strip remains optional. Existing frame settings retain their calibrated label font, offset, position, size, gradient, glow, and console offsets. Windower continues drawing console text and handling input.

On load, ConsoleBG+ sets the native console font to **Verdana 12**, the native color to **255 250 250 250** (alpha, red, green, blue), the native fade delay to the saved frame hold, and automatic native display on. It moves native text with the frame when linked. Native logging follows `activity on|off`, so a saved `activity on` restores `console_log 1` after reload; a saved `activity off` applies `console_log 0`. New installations use a **1000 ms hold and 1000 ms frame fade**. Your existing saved fade values take precedence. These commands establish known settings; the native font size and line spacing still need an in-game check at each chosen resolution.

## First test

```text
//cbg input on 14
//cbg tab left
//cbg edit on
```

Drag the **top edge** (18 pixels) to move the frame. Drag the **lower-right corner** to resize it. Text follows movement, and layout saves when you release the mouse. The frame stays visible during editing. Run `//cbg edit off` when finished, then unload/reload to check the saved layout. Edit mode starts off after every load and does not intercept clicks during ordinary play.

Resizing chooses a fixed width; `//cbg width screen` restores responsive width. In screen mode, horizontal dragging adjusts matching side margins. Resizing changes the background, not native console wrapping, output-line count, or prompt height. Choose a height that contains your console text.

The input label fits before the default native console text inset; long labels or larger fonts can occupy more room. Default red lettering is bold, italic, outlined, and has **no plaque**. `//cbg tabstyle native` switches to dark lettering on a grey plaque whose height matches the measured text height. `//cbg divider off` hides the input divider without moving or hiding the label. The **Console** title and input label are separate elements.

Windower can return `0 × 0` while a label is hidden and retain an old size immediately after changing its text or font. The addon keeps positive measurements, uses a bounded estimate for unseen text, and rechecks after visible render passes. Changing `$` back to `Input`, reopening the console, or changing fonts no longer requires another alignment command. A new font can settle over the first few visible frames.

## Automatic output and frame fade

The log watcher starts **off** for existing and new settings. To test it on one client, run these in FFXI chat:

```text
//cbg activity on
//cbg fade 1000 1000
//cbg edit off
//cbg preview off
//console_echo ConsoleBG_activity_test
```

`activity on` saves the choice per character and enables native `console_log 1`; `activity off` disables native logging. `fade 1000 1000` applies a 1000 ms native delay and stores a matching frame hold plus a 1000 ms frame fade. Adjust both values until the frame follows the native output by eye. Native `console_fadedelay` specifies the wait **before** its fade; Windower does not report its live opacity or fade curve. If the native command setter is unavailable, the addon keeps its own timing and reports that it could not change the native delay.

On load, the watcher begins at the end of `Windower/console.log`, then checks its length at most about eight times per second. New bytes show the background without an `Input` label or divider, because `console.visible()` still reports false for automatic output on the tested Hook. After the configured hold it fades the background, rails, and title over the chosen duration. Manually opening the console always restores the full frame and input styling; closing it discards earlier activity. `activity off` stops checking the file. Existing saved Meiryo and layout adjustments carry over.

The watcher never reads log contents. File writes may be buffered, so the frame may start late; `diagnose` reports whether the file was accessible, the timing clock, and how many size changes it observed. The path comes from Windower's addon directory; an unavailable file leaves manual visibility working normally. If several clients append to the same `console.log`, one client's output can wake another client's frame. Test one client before trying the four-client setup.

`//cbg activity on` is a visibility experiment, not a replacement for native console input. There is no documented getter for its typed line or caret position, so a decorative blinking cursor would stay at a fixed location when typing moves. The output text *could* be copied from the log into a separate movable text panel, with native automatic display disabled via `console_displayactivity 0`, but that would be a second renderer with wrapping, scrollback, and text-format handling. This version reads size only and leaves command entry in Windower's own console.

## Position and alignment

| Command | Effect |
| --- | --- |
| `//cbg edit on` / `//cbg edit off` | Enable or finish mouse layout editing. |
| `//cbg position 0 0` | Move the frame and, when linked, console text. |
| `//cbg size 1200 348` | Set outer width and height; select fixed width. Minimum 120 x 40. |
| `//cbg width screen` / `//cbg width 1200` | Follow screen width or choose fixed width. |
| `//cbg console on` / `//cbg console off` | Link console movement to the frame, or allow independent movement. Linked by default. |
| `//cbg offset 50 15` | Set the native console origin relative to the frame, using signed pixel offsets. |
| `//cbg input on 14` / `//cbg input off` | Show or hide the input label and optional divider. Strip height is 6-256 pixels. |
| `//cbg divider on` / `//cbg divider off` | Show or hide only the input divider; preserve the label anchor. |
| `//cbg inputpad 4` | Add 0-32 pixels of bottom space for descenders. This extends or shortens the bottom without moving text. |
| `//cbg tab left` / `//cbg tab right` | Choose the input tab side. |
| `//cbg label Input` | Change input label text; 1-16 bytes. This does not replace the native `$` prompt. |
| `//cbg tabstyle red` / `//cbg tabstyle native` | Choose red text alone or dark lettering on the compact grey plaque. |
| `//cbg labelfont Meiryo` | Change frame-label font only. `labelfont Verdana` restores it. |
| `//cbg nativefont Verdana 12` | Save and apply the native console font and size. This is independent of the title and Input labels. |
| `//cbg nativecolor 255 250 250 250` | Save and apply the native console color (alpha, red, green, blue). |
| `//cbg labelsize 8 7` | Set title and input-label sizes, each 6-16. Tab height accommodates measured font height. |
| `//cbg labeloffset -2` | Fine-tune input-label vertical position; -12 to 12 pixels. |

The divider sits the configured input height above the inside bottom. Lower heights move it down. Four pixels of bottom padding also move the divider down and give `j`, `g`, and `y` more room. Height is calibrated by eye; the addon cannot read the native font or input baseline. If a saved 26-pixel strip crosses output text, start with `input on 14` and adjust.

`size` and mouse resizing set the **outer** height. In XML, `extents.y` is the baseline height before `input.padding`: the default 344 + 4 draws 348. Changing padding later adds or removes bottom space. Viewport clipping does not overwrite your preferred size. The complete frame fits the UI viewport, including very small windows.

Console movement uses `windower.console.set_position`, with the `console_position` command as a fallback. Native positions are clamped inside the viewport. Linked movement also follows viewport clipping and character-setting changes. `console off` stops future position writes without restoring an unknown earlier native position; normal Windower `console_position` commands can then control text independently. The other saved native settings are reapplied on addon load and character-setting changes, and the corresponding settings commands apply them immediately. Windower has no documented getter for these values, so a direct native command can change them until ConsoleBG+ reapplies its profile.

## Color and opacity

| Command | Effect |
| --- | --- |
| `//cbg gradient 100 250` | Set top and bottom fill alpha, 0-255. |
| `//cbg alpha 200` | Set overall fill strength while retaining the gradient. |
| `//cbg border 240` | Set base border strength, 0-255. |
| `//cbg border link` / `//cbg border free` | Let rails and labels follow the fill gradient, or retain independent alpha. Independent by default. |
| `//cbg glow 200 24` | Set glow strength (0-255) and height (4-128 pixels). `glow 0` disables it. |
| `//cbg color 255 255 255 255` | Restore original colors and full fill strength. Values are alpha, red, green, blue. |
| `//cbg preview on` / `//cbg preview off` | Keep the background visible for inspection or return to normal visibility. |
| `//cbg activity on` / `//cbg activity off` | Watch console.log length for automatic output and switch native logging on/off with it. |
| `//cbg fade 1000 1000` | Set the native hold and frame hold to 1000 ms; fade the frame over 1000 ms. |
| `//cbg status` | Report actual geometry and current modes. |
| `//cbg reset` / `//cbg help` | Restore defaults or show commands. |

Linked border alpha multiplies base border strength by fill alpha and the local gradient. It follows the title, divider, and bottom separately. Rail textures contain only the silver pixels; the striped fill and glow continue underneath. This removes the dark texture bands above and below the body. For brighter silver while retaining the transparent top, use `border free` and `border 240`; these now strengthen the rails without making their former background strips opaque. The top rail is omitted beneath the title and replaced with fading caps placed close to the text.

## Diagnose console activity

`//cbg diagnose` writes **`ConsoleBGPlus/data/diagnostics.txt`** with addon settings, known Windower display/version fields, log accessibility/activity clock/size-change count, retained label bounds and their measurement state, raw native bounds, actual geometry, and the last native position this addon wrote. A hidden native `0x0` is reported separately from the positive bounds used for layout.

For automatic console display and fade behavior:

1. Run `//cbg edit off`, `//cbg preview off`, and `//cbg trace on`.
2. Close the console. Trigger ordinary output from FFXI chat, for example `//console_echo ConsoleBG_trace_test`, and wait for it to disappear. Also open and close the console manually.
3. Run `//cbg trace off` and `//cbg diagnose`. Share `data/visibility.log`, `data/diagnostics.txt`, and a screenshot of any mismatch.

The trace records visibility/layout changes to a file without printing to the console. It starts a fresh log when enabled, flushes after each change, stops at 512 changes, and closes on unload. UTC timestamps have one-second precision; frame numbers establish order, not exact fade duration. Neither input contents nor console output text is collected.

Normal display follows `windower.console.visible()` while the log watcher is off. The supplied in-game trace and screenshot on Hook **4.7.9.3** show automatic console output while that API remains false. The opt-in watcher adds a separate activity hint but cannot read native fade opacity, typed input, or the output buffer. It records no console input or output text.

## Validation and sources

Checked with a Lua API mock that returns zero bounds while hidden and delays font/text measurements until rendering. Activity checks cover log growth while the console stays closed, no replay of old lines, fade and manual override, input hiding on automatic output, log truncation, and opt-out. The native profile checks cover load, reload, character settings, font/color changes, logging choice, and idle rendering. Existing checks cover `$` → `Input` sizing, Meiryo metrics, divider/red/native modes, mouse ownership, release-only saves, viewport bounds, diagnostic failures and cleanup. Title cap overlap and the raised label were inspected offline. The timing and file accessibility of live Windower log writes, Windows font metrics, native font command, layering, and mouse behavior still need an in-game check.

- [Original ConsoleBG by StarHawk](https://github.com/Windower/Lua/tree/live/addons/ConsoleBG), version 0.9.0.1.
- [XIVParty textures by Tylas](https://github.com/Tylas11/XivParty/tree/master/assets/ffxi): `BgTop.png`, `BgMid.png`, and `BgBottom.png`. Attribution and terms are in `LICENSE.txt`.
- [Windower console commands](https://docs.windower.net/commands/console/) and [Lua API definitions](https://github.com/Windower/Lua/blob/live/definitions/windower.lua).

Development branch: [ConsoleBG+ in Lua-reference](https://github.com/rerorriM-Mirrorer/Lua-reference/tree/consolebg-plus/addons/ConsoleBGPlus).
