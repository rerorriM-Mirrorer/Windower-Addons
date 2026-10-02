# ConsoleBG+

A framed, FFXI-style background for the Windower 4 console. It uses XIVParty's violet striped texture and silver borders, with a configurable transparency gradient. Windower continues to draw the console text and handle its input.

## Install

1. Extract the `ConsoleBGPlus` folder into `Windower/addons`. The main file should be at `Windower/addons/ConsoleBGPlus/ConsoleBGPlus.lua`.
2. In the FFXI chat box, run:

   ```text
   //lua unload ConsoleBG
   //lua load ConsoleBGPlus
   ```

3. Press **Insert** to open the console. The initial frame is positioned at **32,16**, sized **1070 x 344** pixels to surround the console shown in the reference screenshots.

The addon needs only Windower's built-in `config` library. Its small texture files are included in `cbg_skin.lua` and unpack automatically into `assets` on first load. XIVParty, Trust, and Balloon do not need to be installed.

## Adjust the frame

Commands below are entered in FFXI chat. Inside the Windower console, omit `//`.

| Command | Effect |
| --- | --- |
| `//cbg position 32 16` | Move the frame. |
| `//cbg size 1070 344` | Set its width and height in pixels. |
| `//cbg gradient 110 235` | Set fill opacity at the top and bottom. `0` is transparent; `255` is opaque. |
| `//cbg alpha 200` | Reduce overall fill opacity while retaining the gradient. |
| `//cbg border 240` | Set border opacity independently. |
| `//cbg color 255 255 255 255` | Restore the original texture colors and full fill strength. Values are alpha, red, green, blue; RGB values tint the source texture. |
| `//cbg input on 26` | Add a thin divider 26 pixels above the inside bottom, behind the existing `$` prompt. |
| `//cbg input off` | Hide that divider. |
| `//cbg preview on` | Keep the background visible while the console is closed, for positioning. |
| `//cbg preview off` | Return to normal console visibility. |
| `//cbg status` | Report the actual frame position and size. |
| `//cbg reset` | Restore the default frame settings. |
| `//cbg help` | Show the command list. |

Settings save automatically in `ConsoleBGPlus/data/settings.xml` using Windower's normal character settings. If the game window becomes smaller, the visible frame is kept inside it without overwriting the saved dimensions. Corners stay at their native size and the stripes repeat at their native pixel spacing.

The frame position is independent of the console's text position. Windower's `console_position <x> <y>` command controls the text separately. This first version follows `windower.console.visible()` and does not read the console buffer to resize around individual lines. The optional input divider follows console visibility; it does not detect cursor blinking or implement a separate input box.

## First test

Open and close the console, check that the frame surrounds your text, and try `gradient 80 235` if you want a more transparent top. After a size or opacity adjustment, unload/reload the addon and confirm that the change survives. `input on 26` is optional: adjust its height if the divider crosses your prompt text.

The release was checked with a Lua API mock and an offline rendering preview. Final alignment, transparency, and primitive layering need verification in Windower.

## Sources

- [Original ConsoleBG by StarHawk](https://github.com/Windower/Lua/tree/live/addons/ConsoleBG), version 0.9.0.1.
- [XIVParty FFXI textures by Tylas](https://github.com/Tylas11/XivParty/tree/master/assets/ffxi): `BgTop.png`, `BgMid.png`, and `BgBottom.png`. The texture bundle contains slices of these images; attribution and redistribution notices are in `LICENSE.txt`.
- [Windower console commands](https://docs.windower.net/commands/console/).

Development branch: [ConsoleBG+ in Lua-reference](https://github.com/rerorriM-Mirrorer/Lua-reference/tree/consolebg-plus/addons/ConsoleBGPlus).
