**Author:** Tako, Rubenator; fork changes by A<br>
**Version:** 3.3.3-dev.1 (testing)<br>
**Date:** October 8, 2026<br>

* Displays current equipment grid on screen. Also can show current Ammo count and current Encumbrance.

## Settings

* The equipment grid is draggable by default. Drag anywhere on the grid/background; the new position is saved automatically when you release the mouse, and EquipViewer prints the saved coordinates in chat.

* Most settings can be modified via commands, but you can edit the settings.xml directly for a few uncommon settings.

**Abbreviation:** `//ev`

## Visibility

The default remains always visible. Autohide is opt-in and reveals the grid after
equipment changes or encumbrance changes. It stays open for 4 seconds after the
last change, fading in over 0.12 seconds and out over 0.30 seconds. Routine ammo
consumption updates the count without repeatedly revealing the grid.

| Command | Behavior |
| --- | --- |
| `//ev show` | Save always-visible mode. Existing zone/cutscene hiding still applies. |
| `//ev hide` | Save hidden mode; equipment packets, status changes, and zoning cannot override it. |
| `//ev autohide [on\|off]` | Enable/disable auto mode; no argument toggles it. `//ev auto` is an alias. Off returns to always-visible mode. |
| `//ev delay [seconds]` | Set auto hold time from 0.1 to 60 seconds, or report it without an argument. |
| `//ev fade [in-seconds out-seconds]` | Set both fade durations from 0 to 5 seconds, or report them without arguments. Zero means instant. |
| `//ev hover [on\|off]` | Toggle optional mouse reveal in auto mode. Off by default. |
| `//ev status` | Report version, mode, current visibility/opacity, delay, hover, scale, and position. |

Hover means moving the pointer over the grid's saved rectangular location, even
when the grid is hidden. It does not intercept clicks while hidden. Manual hide
takes precedence over hover. Use `//ev autohide on` to resume auto behavior after
`show` or `hide`.

In auto mode, loading or changing size/scale briefly reveals the grid. Manual
hidden mode stays hidden during these changes. A held drag keeps auto mode open;
release saves the position and starts a fresh hold period. Fully hidden grids
cannot start a drag. Fades multiply your configured background/icon/text/stroke
opacity rather than replacing it.

The mode and timing settings persist under `<visibility>` in `data/settings.xml`.
Existing configurations receive the always-visible default. There is no controller
or combat dependency; this first batch uses equipment activity as its trigger.

## Commands

1. position <xpos> <ypos>: move display to position (from top left)
2. size <pixels>: set pixel size of each item slot (defaults to 32 -- same as the size of the item icons)
3. scale <factor>: scale multiplier for size of each item slot (1 is 32px) -- modifies same setting as size
4. alpha <opacity>: set opacity of icons (out of 255)
5. transparency <transparency>: inverse of alpha (out of 255) -- modifies same setting as alpha
6. background <red> <green> <blue> <alpha>: sets color and opacity of background (out of 255)
7. ammocount: toggles showing current ammo count (defaults to on/true)
8. encumbrance: toggles showing encumbrance Xs (defaultis on/true)
9. hideonzone: toggles hiding while crossing zone lines (default is on/true)
10. hideoncutscene: toggles hiding when in cutscene/npc menu/etc (default is on/true)
11. justify: toggles between ammo text being right or left justifed (default is right justified)
12. lock: prevents accidental dragging
13. unlock: enables dragging; dragged positions save automatically on mouse release
14. draggable <on|off>: explicitly enable/disable dragging (with no argument, toggles it)
15. help: displays explanations of each command

Legacy Command:
game_path <path>: sets path to FFXI folder where you want dats extracted from. Backslashes `\` must be escaped (like so: `\\`) or use forewardslash `/` instead. (legacy command as of `3.3.1` in which the game path is now pulled from the registry, but this command is still here in case you want to pull from dats that exist elsewhere)
	
### Example Commands
```
//ev pos 700 400
//ev size 64
//ev scale 1.5
//ev alpha 255
//ev transparency 200
//ev background 0 0 0 72
//ev ammocount
//ev encumbrance
//ev hideonzone
//ev hideoncutscene
//ev justify
//ev unlock
//ev lock
//ev draggable on
//ev help
```

## Changelog

### 3.3.3-dev.1 — October 8, 2026 — awaiting live testing

- Added persistent show/hide and opt-in gear-change autohide, delay/fade controls,
  optional hover reveal, and status output.
- Centralized visibility for the background, icons, encumbrance, ammo, and text
  stroke; hidden equipment/ammo data keeps updating.
- Preserved scale, opacity, alignment, and position-saving behavior. A held drag
  prevents auto expiry; final coordinates save even for a drag between frames.
- Added shared development documents and a cumulative root `TESTING.md`.

### 3.3.2 — October 3, 2026 — user reported dragging working well

- Added whole-grid dragging with live icon/encumbrance/ammo movement, XML position
  saving, chat confirmation, and lock/unlock/draggable controls.
- Retained upstream 3.3.1 equipment handling and scale/appearance settings.
