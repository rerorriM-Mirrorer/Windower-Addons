# invtracker
This addon displays a grid detailing empty and filled inventory slots, similar to the FFXIV Inventory Grid HUD widget.

![Imgur](https://i.imgur.com/PgiMxRZ.png)

## How to edit the settings
1. Login to your character in FFXI
2. Edit the addon settings file: **_Windower4\addons\invtracker\data\settings.xml_**
3. Save the file
4. Press Insert in FFXI to access the windower console
5. Type ``` lua r invtracker ``` to reload the addon
6. Press Insert in FFXI again to close the windower console

## Issues:
1. There is no way to get the inventory sort order, so all items in the grid will be ordered by status and item count.

## Awake testing build: layout-safe movement and autohide

This is a test build; it has **not** been live-tested in FFXI. The existing
inventory grouping and item tracking have not been intentionally changed.

- `//inv move` — click and drag **anywhere on the screen**. Every slot follows
  one shared movement delta. Releasing the left mouse button saves the position and restarts the
  visibility hold timer.
- `//inv cancel` — leave move mode without saving a drag.
- `//inv pos X Y` — set the traditional, resolution-relative coordinates.
- `//inv pos reset` — restore the original offset (`-365 -50`).
- `//inv autohide` — toggle on/off; `//inv autohide on` / `//inv autohide off` set the state explicitly. Opt in/out of reveal on inventory
  or equipment activity; default is **off**.
- `//inv hold 4` — set seconds to remain fully visible following activity
  (range 0.5–30; default 4).
- `//inv show` — pin visible until changed manually.
- `//inv hide` — hide now; when autohide is on, new inventory/equipment activity
  can reveal the tracker again.
- `//inv status` / `//inv help` — display current options.

With autohide enabled, the HUD fades in quickly when you add/remove an item,
change equipment, change bazaar state, or receive treasure; it remains visible
for four seconds, then fades out more gently. Cutscene and Scroll Lock hiding
continue to take precedence. Position changes affect only the grid origin,
not the arrangement of inventory slots.

**Test sequence:** Back up `data/settings.xml`, replace only
`addons/invtracker/invtracker.lua`, reload with `//lua r invtracker`, then
try `//inv move`, confirm the grid shape remains unchanged while dragging,
reload to verify its saved location, and finally try
`//inv autohide on` with an item added/removed. Check both short/fat and
low-resolution UI layouts and that a cutscene does not reveal the tracker.

### Test build .2 corrections (2026-10-09)

- Every background/border primitive has independent images.lua settings
  (position, alpha and color). Sharing settings made drag collapse multiple
  slots at the same coordinates and interfered with status redraws.
- Native per-slot dragging is disabled: only `//inv move` controls movement.
- Redrawing inventory status restores image visibility when the HUD is shown.
  Underlying inventory packet/update logic is unchanged.
- Bare `//inv autohide` toggles on/off; explicit on/off remain supported.
- Moving the HUD starts a fresh auto-hide hold period on release.

Regression checks: drag and release (HUD should remain visible), add/remove an
inventory item both with autohide on and off (slot colors/count change),
reload (position persists), and run the bare autohide command twice.
