# ConsoleBG+

A framed, FFXI-style background for the Windower 4 console. It uses XIVParty's violet striped texture and silver borders, with a configurable transparency gradient, full native right-edge fade, and a subtle lavender lift near the bottom. Windower continues to draw the console text and handle its input; the addon leaves your chosen console font unchanged.

## Install

1. Extract the `ConsoleBGPlus` folder into `Windower/addons`. The main file should be at `Windower/addons/ConsoleBGPlus/ConsoleBGPlus.lua`.
2. In the FFXI chat box, run:

   ```text
   //lua unload ConsoleBG
   //lua load ConsoleBGPlus
   ```

3. Press **Insert** to open the console. The initial frame is positioned at **32,16**, is **344** pixels tall, and follows the game window width with matching side margins. At 1920 pixels wide, it draws **1856 x 344**. A small **Console** title sits above the top border.

To update from v0.1.0, copy the new files into your existing `ConsoleBGPlus` folder and run `//lua reload ConsoleBGPlus`. The ZIP contains no `data/settings.xml`, so your position, colours, gradient, and input setting are preserved. The new width mode defaults to screen width. `//cbg size 1070 344` restores the original compact size if you prefer it.

The addon needs only Windower's built-in `config` library. Its small texture files are included in `cbg_skin.lua` and unpack automatically into `assets` on first load. XIVParty, Trust, and Balloon do not need to be installed.

## Adjust the frame

Commands below are entered in FFXI chat. Inside the Windower console, omit `//`.

| Command | Effect |
| --- | --- |
| `//cbg position 32 16` | Move the frame. |
| `//cbg size 1070 344` | Set its width and height in pixels. |
| `//cbg width screen` | Follow the current game window width, with matching side margins. |
| `//cbg width 1200` | Set a fixed width without changing height. |
| `//cbg gradient 110 235` | Set fill opacity at the top and bottom. `0` is transparent; `255` is opaque. |
| `//cbg alpha 200` | Reduce overall fill opacity while retaining the gradient. |
| `//cbg border 240` | Set border opacity independently. |
| `//cbg glow 36 24` | Set the bottom glow's strength and height. `glow 0` disables it; strength is 0-255, height is 4-128 pixels. |
| `//cbg color 255 255 255 255` | Restore the original texture colors and full fill strength. Values are alpha, red, green, blue; RGB values tint the source texture. |
| `//cbg input on 26` | Add a tapered divider 26 pixels above the inside bottom and a small grey **Input** tab on the divider. |
| `//cbg input off` | Hide the divider and its tab. |
| `//cbg tab right` | Put the input tab near the right end of the divider, away from the normal console output and `$` prompt. This is the default. |
| `//cbg tab left` | Put the tab at the left, like FFXI's **Say** tab. This may overlap the final output line because Windower's console does not reserve a tab row. |
| `//cbg preview on` | Keep the background visible while the console is closed, for positioning. |
| `//cbg preview off` | Return to normal console visibility. |
| `//cbg status` | Report the actual frame position and size. |
| `//cbg reset` | Restore the default frame settings. |
| `//cbg help` | Show the command list. |

Settings save automatically in `ConsoleBGPlus/data/settings.xml` using Windower's normal character settings. Screen width mode responds to viewport changes without overwriting your saved fixed width. A fixed-size frame is clipped to fit a smaller viewport. Corner pieces and the 64-pixel right fade stay at their native size; the stripes repeat at their native pixel spacing. The default bottom glow is intentionally subtle and can be adjusted separately from opacity.

The frame position is independent of the console's text position. Windower's `console_position <x> <y>` command controls the text separately. The background does not constrain or wrap console text. Screen width mode gives long lines more room; it does not read the console buffer to resize around individual lines. The optional input strip and tab follow console visibility; they do not yet detect whether the input buffer is empty or replace Windower's existing `$` prompt. The top-right title and the input tab are two separate elements. Their small labels use Verdana without changing the console's font.

## First test

Open and close the console, check the smooth right edge, and try `gradient 50 255` for a more transparent top. Try `glow 60 24` to compare a stronger bottom glow. Change window width with `width screen` enabled, then confirm the frame remains inside it. After an adjustment, unload/reload the addon and confirm it survives. `input on 26` is optional: adjust its height if the divider crosses your prompt text. Compare `tab right` and `tab left` before choosing one.

The release was checked with a Lua API mock and an offline rendering preview. Final alignment, transparency, and primitive layering need verification in Windower.

## Sources

- [Original ConsoleBG by StarHawk](https://github.com/Windower/Lua/tree/live/addons/ConsoleBG), version 0.9.0.1.
- [XIVParty FFXI textures by Tylas](https://github.com/Tylas11/XivParty/tree/master/assets/ffxi): `BgTop.png`, `BgMid.png`, and `BgBottom.png`. The texture bundle contains slices of these images; attribution and redistribution notices are in `LICENSE.txt`.
- [Windower console commands](https://docs.windower.net/commands/console/).

Development branch: [ConsoleBG+ in Lua-reference](https://github.com/rerorriM-Mirrorer/Lua-reference/tree/consolebg-plus/addons/ConsoleBGPlus).
