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
  one shared movement delta. Releasing the left mouse button saves the position.
- `//inv cancel` — leave move mode without saving a drag.
- `//inv pos X Y` — set the traditional, resolution-relative coordinates.
- `//inv pos reset` — restore the original offset (`-365 -50`).
- `//inv autohide on` / `//inv autohide off` — opt in/out of reveal on inventory
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
