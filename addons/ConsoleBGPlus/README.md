# ConsoleBG+

An FFXI-style frame for the Windower 4 console, using XIVParty's violet stripes, silver rails, a transparency gradient, and native right-edge fade. Version **0.1.2** adds linked console movement, mouse layout controls, a compact input tab, fading title endcaps, bottom padding, and diagnostics.

## Install or update

Extract the `ConsoleBGPlus` folder into `Windower/addons`. When updating, copy the new files into the existing folder and **keep your `data` folder**. The ZIP contains no settings file, so existing colors, position, width mode, glow, and input height are retained.

Run in FFXI chat:

```text
//lua unload ConsoleBG
//lua reload ConsoleBGPlus
```

For a first install, use `//lua load ConsoleBGPlus` instead of reload. The addon needs Windower's built-in `config` library. Its 22 texture pieces unpack from `cbg_skin.lua`; XIVParty, Trust, and Balloon do not need to be installed.

New installations start at **32,16**, follow the screen width, and draw **348 pixels** tall, including four pixels of extra bottom space. The input strip remains optional. Existing settings acquire the new padding, label options, and linked console movement. Windower continues drawing console text and handling input; its font is retained.

## First test

```text
//cbg input on 14
//cbg tab left
//cbg edit on
```

Drag the **top edge** (18 pixels) to move the frame. Drag the **lower-right corner** to resize it. Text follows movement, and layout saves when you release the mouse. The frame stays visible during editing. Run `//cbg edit off` when finished, then unload/reload to check the saved layout. Edit mode starts off after every load and does not intercept clicks during ordinary play.

Resizing chooses a fixed width; `//cbg width screen` restores responsive width. In screen mode, horizontal dragging adjusts matching side margins. Resizing changes the background, not native console wrapping, output-line count, or prompt height. Choose a height that contains your console text.

The compact tab fits its measured label width. The default label and size fit before the usual native console text inset; long labels or larger fonts can occupy more room. Its default lettering is red, bold, italic, and outlined. `//cbg tabstyle native` switches to dark lettering on the grey plaque. The **Console** title and input tab are separate elements.

## Position and alignment

| Command | Effect |
| --- | --- |
| `//cbg edit on` / `//cbg edit off` | Enable or finish mouse layout editing. |
| `//cbg position 0 0` | Move the frame and, when linked, console text. |
| `//cbg size 1200 348` | Set outer width and height; select fixed width. Minimum 120 x 40. |
| `//cbg width screen` / `//cbg width 1200` | Follow screen width or choose fixed width. |
| `//cbg console on` / `//cbg console off` | Link console movement to the frame, or allow independent movement. Linked by default. |
| `//cbg offset 0 0` | Set the native console origin relative to the frame, using signed pixel offsets. |
| `//cbg input on 14` / `//cbg input off` | Show or hide the divider and tab. Strip height is 6-256 pixels. |
| `//cbg inputpad 4` | Add 0-32 pixels of bottom space for descenders. This extends or shortens the bottom without moving text. |
| `//cbg tab left` / `//cbg tab right` | Choose the input tab side. |
| `//cbg label Input` / `//cbg label $` | Change input tab text; 1-16 bytes. The native `$` prompt is still present. |
| `//cbg tabstyle red` / `//cbg tabstyle native` | Choose outlined red or dark native-style lettering. |
| `//cbg labelfont Meiryo` | Change frame-label font only. `labelfont Verdana` restores it. |
| `//cbg labelsize 8 7` | Set title and input-label sizes, each 6-16. Tab height accommodates measured font height. |
| `//cbg labeloffset -2` | Fine-tune input-label vertical position; -12 to 12 pixels. |

The divider sits the configured input height above the inside bottom. Lower heights move it down. Four pixels of bottom padding also move the divider down and give `j`, `g`, and `y` more room. Height is calibrated by eye; the addon cannot read the native font or input baseline. If a saved 26-pixel strip crosses output text, start with `input on 14` and adjust.

`size` and mouse resizing set the **outer** height. In XML, `extents.y` is the baseline height before `input.padding`: the default 344 + 4 draws 348. Changing padding later adds or removes bottom space. Viewport clipping does not overwrite your preferred size. The complete frame fits the UI viewport, including very small windows.

Console movement uses `windower.console.set_position`, with the `console_position` command as a fallback. Native positions are clamped inside the viewport. Linked movement also follows viewport clipping and character-setting changes. `console off` stops future position writes without restoring an unknown earlier native position; normal Windower `console_position` commands can then control text independently.

## Color and opacity

| Command | Effect |
| --- | --- |
| `//cbg gradient 110 235` | Set top and bottom fill alpha, 0-255. |
| `//cbg alpha 200` | Set overall fill strength while retaining the gradient. |
| `//cbg border 240` | Set base border strength, 0-255. |
| `//cbg border link` / `//cbg border free` | Let rails and labels follow the fill gradient, or retain independent alpha. Independent by default. |
| `//cbg glow 36 24` | Set glow strength (0-255) and height (4-128 pixels). `glow 0` disables it. |
| `//cbg color 255 255 255 255` | Restore original colors and full fill strength. Values are alpha, red, green, blue. |
| `//cbg preview on` / `//cbg preview off` | Keep the background visible for inspection or return to normal visibility. |
| `//cbg status` | Report actual geometry and current modes. |
| `//cbg reset` / `//cbg help` | Restore defaults or show commands. |

Linked border alpha multiplies base border strength by fill alpha and the local gradient. It follows the title, divider, and bottom separately. The original top rail is omitted beneath the title and replaced with fading caps, so a solid line does not remain behind the transparent notch.

## Diagnose console activity

`//cbg diagnose` writes **`ConsoleBGPlus/data/diagnostics.txt`** with addon settings, known Windower display/version fields, available settings keys, measured label bounds, actual geometry, and the last native position this addon wrote.

For automatic console display and fade behavior:

1. Run `//cbg edit off`, `//cbg preview off`, and `//cbg trace on`.
2. Close the console. Trigger ordinary output from FFXI chat, for example `//console_echo ConsoleBG_trace_test`, and wait for it to disappear. Also open and close the console manually.
3. Run `//cbg trace off` and `//cbg diagnose`. Share `data/visibility.log`, `data/diagnostics.txt`, and a screenshot of any mismatch.

The trace records visibility/layout changes to a file without printing to the console. It starts a fresh log when enabled, flushes after each change, stops at 512 changes, and closes on unload. UTC timestamps have one-second precision; frame numbers establish order, not exact fade duration. Neither input contents nor console output text is collected.

Normal display follows `windower.console.visible()`. It does not yet distinguish typing focus from automatic activity, read current native fade delay/opacity, or reproduce a synchronized fade. Native `console_displayactivity` and `console_fadedelay` remain Windower settings. The diagnostic test establishes what visibility reports on your Hook version before adding input-only display, cursor changes, sound, or matched fading.

## Validation and sources

Checked with a Lua API mock for mouse ownership, linked movement/offsets, release-only saving, resizing/viewport bounds, legacy settings, diagnostic failures and cleanup, position-command fallback, and idle rendering. Texture joins, caps, and labels were inspected offline. Windows font metrics, native layering, and mouse behavior still need an in-game check.

- [Original ConsoleBG by StarHawk](https://github.com/Windower/Lua/tree/live/addons/ConsoleBG), version 0.9.0.1.
- [XIVParty textures by Tylas](https://github.com/Tylas11/XivParty/tree/master/assets/ffxi): `BgTop.png`, `BgMid.png`, and `BgBottom.png`. Attribution and terms are in `LICENSE.txt`.
- [Windower console commands](https://docs.windower.net/commands/console/) and [Lua API definitions](https://github.com/Windower/Lua/blob/live/definitions/windower.lua).

Development branch: [ConsoleBG+ in Lua-reference](https://github.com/rerorriM-Mirrorer/Lua-reference/tree/consolebg-plus/addons/ConsoleBGPlus).
