# InvTracker — inventory grid HUD

Originally by sylandro. Enhanced by Awake (FFXI / Windower 4).
**Testing build:** `1.0.1-a.20261014.7` — not yet tested in a live game client.

InvTracker displays grouped inventory, equipment, storage, temporary item, and
treasure slots. **The original status sorting, per-bag layout, and grid rendering
remain in place.** Its HUD fades out when not in use and can be dragged.

## Install

Copy the package's `invtracker/` folder over
`Windower4/addons/invtracker/`, **preserving `data/settings.xml`** and any
character-specific settings. The existing `slot.png` is included. Then use
`//lua r invtracker`. The game's previously configured positions remain
unchanged; the new factory coordinates apply to fresh configurations or
`//i pos reset`.

See `TESTING.md` at the ZIP root before testing on multiple clients.

## Defaults

| Setting | Fresh-install default |
| --- | --- |
| Autohide | ON |
| Reveal duration | 60 seconds |
| Fade in / out | 0.13 / 0.32 seconds |
| Factory position | X = -224, Y = -19 (resolution-relative) |
| Dragging | ON, unlocked |
| Equipment block displayed | OFF (new configurations) |
| Reveal on loaded inventory / new zone | ON |
| Reveal when *any* in-game menu opens | ON |
| Reveal when items are added or removed, treasure changes, or bazaar updates | ON |
| Reveal when equipment changes | OFF (equipment status still redraws) |
| Short white reveal highlight | ON, 0.65 seconds; one overlay per displayed block |

## Commands (all aliases: `//i`, `//inv`, `//invtracker`)

| Command | Result |
| --- | --- |
| `//i` | Reveal for the current hold duration **and display colored help** |
| `//i help` | BattleStations-inspired colored chat help |
| `//i status` | Version, visibility, current position and settings |
| `//i equipment [on\|off]` | Toggle the equipment block; save and rebuild layout |
| `//i autohide [on\|off]` | Toggle automatic visibility or set explicitly |
| `//i hold <seconds>` | Hold duration, 0.5–3600 seconds (default 60) |
| `//i show` | Pin visible until another visibility command/event |
| `//i hide` | Hide immediately, subject to later triggers |
| `//i move` | Reveal and drag anywhere once to reposition |
| `//i cancel` | Cancel an explicit move and restore position |
| `//i lock [on\|off]` | Prevent dragging or set lock explicitly |
| `//i unlock` | Allow normal dragging on visible grid |
| `//i pos <x> <y>` | Save resolution-relative position |
| `//i pos reset` | Restore factory position |
| `//i glow [on\|off]` | Toggle optional highlight |
| `//i glow preview` | Preview white highlight |
| `//i restart` | Reload InvTracker |
| `//i unload` | Unload InvTracker |

Invalid commands show the help menu. Bare `//i` and bare `//inv` perform the
primary 60-second reveal **and** display the same colored help menu.

**Existing character XML:** older installations can keep
`<equipment><visible>true</visible></equipment>` regardless of the new factory
`false` setting. Enter `//i equipment off` on each affected character to
persist the choice and automatically reload the addon. `//i equipment on`
restores that region. This doesn't change your coordinates, other inventory
blocks, or other characters' saved XML.

## Visibility and input details

Only a *new* transition from menu closed to menu open refreshes visibility.
Equipment changes still update the HUD's item-status colors but do not wake it.
The old Scroll Lock hide toggle remains; menu-open checks work around the
game's broad cutscene/menu status when a menu is actually open.

To drag, click an existing slot block while visible. Each block is a draggable
hit region; empty screen space is not intercepted. If the HUD is hidden or
off-screen, `//i move` enables a one-time click-and-drag anywhere on the screen.
Releasing the mouse saves the position and starts a new reveal duration.
`//i cancel` cancels an active explicit move (legacy command, still supported).

The glow is a brief, translucent white overlay using the existing 1px `slot.png`.
It is **not** a true blurred shader; preview its appearance at your resolution
and disable it with `//i glow off` if the illumination is too strong.

**Timing:** This test branch retains Windower's commonly used `os.clock()`
timebase to avoid altering previously working fades. Long-duration wall-clock
accuracy still needs live confirmation on slower or multiboxed clients.

**Note:** `//i` does **not** open the game's native inventory menu. It reveals
the HUD only. No direct inventory/item movements are performed by InvTracker.

## Known limitations

- FFXI's true inventory sorting order isn't exposed by this version; slots are
  grouped using the original status/count sorting.
- Existing configs have priority over factory defaults.
- No new snapshot/quantity-difference tracking, cleanup engine, reset/undo,
  or specific-menu recognition is included in this release.
- Automatic inventory quantity updates still depend on the original Windower
  inventory events and the addon refresh path. This is the next subsystem to
  review if live tests reveal stale stack counts.

## Cumulative changelog

- **2026-10-14 / Batch 7:** Factory equipment block hidden (new installs);
  `//i equipment on|off` or bare toggle saves and rebuilds an existing
  character's layout; bare `//i` reveals **and** prints colored help.
  Commit `303ed91`.

- **2026-10-14 / Batch 6:** Fixed forced glow preview with glow disabled and
  starting the reveal pulse on inventory initialization; explicit move cancel
  added to in-game help. Commits `3138b84`, `cae6681`.

- **2026-10-14 / Batch 1:** Initialized x/y from loaded XML before any position
  command; fresh defaults autohide on, hold 60, position -224/-19; `//i` alias.
  Commit `cadb847`.
- **2026-10-14 / Batch 2:** Drag existing visible slot groups without entering
  move mode; lock/unlock; preserve recovery move mode. Commit `5ff8bd0`.
- **2026-10-14 / Batch 3:** Optional white reveal pulse and preview. Commit
  `54e4ff0`.
- **2026-10-14 / Batch 4:** Reveal on any menu opening, but not on equipment
  changes; retained silent equipment redraw. Commit `eccec4d`.
- **2026-10-14 / Batch 5:** Bare `//i` timed reveal; colored formatted help,
  status, restart and unload. Commit `3d1a6aa`.
- **2026-10-09 / Earlier test build:** Independent settings per slot fixed
  grid-collapse during drag; bare autohide toggle; retained layout/status code.
  Commits `d53292b`, `d7d7a17`.
- **Earlier upstream:** sylandro's original InvTracker grid and sort logic.
