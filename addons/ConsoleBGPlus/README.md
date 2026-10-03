# ConsoleBG+

An FFXI-style frame for the Windower 4 console, with XIVParty's violet stripes, silver rails, a soft glow, and a fading right edge. Windower still draws the text and handles commands. ConsoleBG+ draws the frame around it.

## Install and update

Extract the ConsoleBGPlus folder into Windower/addons. When updating, replace the addon files and **keep your data folder**; the ZIP contains no settings file. In FFXI chat, run **//lua load ConsoleBGPlus** for a first install or **//lua reload ConsoleBGPlus** after updating. Unload the original ConsoleBG addon if it is running.

Fresh settings start at **16,48** with equal left and right margins, a 344-pixel full height, Verdana 12 native console text, and a 15-pixel Input strip. Automatic output shows a 322-pixel frame without the Input area: the 15-pixel strip plus 7 extra pixels are removed. Existing saved positions, input heights, colors, and activity choices stay as they are. **//cbg reset** applies the new defaults if you want to start over.

## Move and resize

Run **//cbg edit** to toggle edit mode. A band of pale diagonal lines marks the draggable top edge; drag anywhere along it to move the frame. The matching mark at the lower-right corner resizes it. Each grip gains a soft pink wash on hover; while pressed, the wash goes away and its lines turn pale pink. Release the mouse to save. Run **//cbg edit** again when you finish. Closing the native console with Insert also ends edit and preview modes.

In screen-width mode, dragging left or right keeps matching side margins. Resizing sets a fixed width; **//cbg width screen** returns to screen-width mode. When console movement is linked, the native text follows the frame.

## Commands

Type these in FFXI chat. Angle brackets mark required arguments, square brackets mark optional arguments, and a vertical bar separates choices. Command forms and descriptions are aligned below for quick reference.

    Layout
    //cbg edit [on|off]                         Toggle or set mouse edit mode
    //cbg position <x> <y>                      Move the frame to pixel coordinates
    //cbg size <width> <height>                 Set the outer size and fixed width
    //cbg width screen|<pixels>                Use equal side margins or fixed width
    //cbg console on|off                        Link or unlink native text movement
    //cbg offset <x> <y>                        Position native text relative to frame

    Input and labels
    //cbg input on|off [height]                 Show Input strip; fresh height is 15
    //cbg inputpad <0-32>                       Add extra space below the input line
    //cbg divider on|off                        Show or hide the input divider
    //cbg tab left|right                        Choose Input label side
    //cbg tabstyle red|native                   Red lettering or grey plaque
    //cbg label <text>                          Change the Input label (1-16 bytes)
    //cbg labelfont <font name>                 Change frame label font
    //cbg labelsize <title> <input>             Set label sizes (6-16)
    //cbg labeloffset <-12 to 12>              Move Input label vertically
    //cbg nativefont <font name> <size>         Set native console font (size 6-24)
    //cbg nativecolor <a> <r> <g> <b>           Set native console color (0-255)

    Appearance
    //cbg gradient <top> <bottom>              Set fill opacity at top and bottom
    //cbg alpha <0-255>                         Set overall fill strength
    //cbg border <0-255>|link|free              Set rail strength or gradient link
    //cbg glow <0-255> [height]                 Set bottom glow and height (4-128)
    //cbg color <a> <r> <g> <b>                 Tint the frame (0-255)
    //cbg preview [on|off]                      Keep the full frame visible to inspect

    Activity and settings
    //cbg activity on|off                       Follow automatic console output
    //cbg fade <hold_ms> [fade_ms]              Set native hold and frame fade
    //cbg closesound on|off                     Play a cue on manual console close
    //cbg trace on|off                          Record visibility and timing changes
    //cbg diagnose                              Save one settings/layout snapshot
    //cbg status                                Show current geometry and modes
    //cbg reset                                 Apply fresh defaults
    //cbg help                                  Show command groups in game

The default native font is Verdana 12 with color 255 250 250 250. The Input and Console labels use Verdana 8. **//cbg fade 1000 1000** gives automatic output a 1000 ms hold followed by a 1000 ms frame fade. On manual opening, the first rendered frame shows the compact output body; the next frame expands to full height with the Input area. Closing a manually opened console immediately removes the Input strip, divider, and tab, returns to the same compact output height, then fades over the saved 1000 ms duration. **//cbg activity on** also enables native console_log 1, which the output watcher needs. The watcher checks only the file's byte length, about eight times per second, and restarts the full hold whenever it sees growth. Activity off turns native logging off for this addon.

The bundled close cue plays once when a manually open native console closes in the focused game window. It does not play for automatic output fading or for opening the console. Use **//cbg closesound off** to silence it, or replace **assets/closeconsole.wav** with another short PCM WAV. The addon detects the native open-to-closed transition; Windower does not identify which key closed it.

## When something looks wrong

For a spacing issue, take a screenshot and run **//cbg diagnose** while the issue is visible. It writes ConsoleBGPlus/data/diagnostics.txt with saved settings, screen and frame size, measured label bounds, log availability, and the last native position **set by the addon**. Each run replaces the prior snapshot.

For a fade or repeated-output issue, run **//cbg trace on** before the test, wait for the frame to settle, trigger output during the hold and fade, then run **//cbg trace off** and **//cbg diagnose**. Share data/visibility.log, data/diagnostics.txt, and a screenshot if useful. Each trace on starts a fresh file. The trace records frame opacity steps, log byte growth, output age, and clock_ms elapsed since the trace began. It stops after 512 changes. Neither file records typed input or console output text.

The addon cannot read native console input, output text, or live fade opacity. If console.log is unavailable or its writes are delayed, automatic background timing may lag native output; manual opening still works. Existing calibration can vary by resolution, so use **//cbg position**, **//cbg offset**, and **//cbg input on 15** to adjust it.

## Credits

Derived from [ConsoleBG by StarHawk](https://github.com/Windower/Lua/tree/live/addons/ConsoleBG). Textures derive from [XIVParty by Tylas](https://github.com/Tylas11/XivParty/tree/master/assets/ffxi); terms and attribution are in LICENSE.txt. The addon uses Windower's built-in config library and does not require XIVParty to be installed.
