# GilFinder

Version 1.3.0-a.20261015.1. Original GilTracker by sylandro; modifications by A.
A compact gil widget with animated balance changes, saved dragging, layout
choices, scaling, and three visibility modes.

## Installation / rename from GilTracker

1. Unload the old addon on every running client: `//lua unload giltracker`.
2. Copy the included `gilfinder` folder into Windower/addons.
3. Load it on each desired character: `//lua load gilfinder`.
4. Replace `giltracker` with `gilfinder` in startup scripts or AddonManager
   lists. Replace old `//gt` or `//giltracker` macros with `//gil`.

Leave the old addon unloaded. Its folder/settings are untouched. Do not load
both widgets at once. The new folder name is separate from Windower's stock
GilTracker, so stock GilTracker updates target the old folder.

This personal package includes data/settings.xml based on settings(10).xml:
Cioara uses always mode at (-169,-2137); Killala uses input mode at
(-169,-2137); Myrr uses always mode at (-166,-2135). Other characters use the
hardcoded global defaults from that XML. Those globals are change mode,
60-second hold, 0.5-second fade, scale 1, amount left, 9px italic text, and
0.4-second counting followed by a 0.8-second color return. Colors: green
(166,207,179), pink (222,164,181), normal (253,252,250).

These are offsets from the right/bottom edges, not absolute screen positions.
Fully off-screen placements recover automatically on smaller clients. In an
existing GilFinder installation, back up data before deciding whether to use
the included personal settings or retain your current preferences. Defaults
merge through Windower config; no automatic import from the old addon runs.
The texture path is rebuilt from the new addon folder, never the old PC path.

## Commands

Bare `//gil`, `//gil help`, and invalid commands show colored chat-only help.

| Command | Behavior |
| --- | --- |
| `//gil status` | Version, mode, side, timing, scale, coordinates, editing and controller state |
| `//gil mode always` | Always visible |
| `//gil mode change` | Show after gaining or spending gil |
| `//gil mode input` | Show on keyboard/controller buttons; held buttons keep it visible |
| `//gil side left` / `//gil side right` | Amount to the left/right of the fixed icon |
| `//gil cutscenes [on\|off]` | Toggle cutscene/dialogue hiding; default OFF |
| `//gil delay <seconds>` | Hold time, 1–3600 inclusive, decimals accepted |
| `//gil scale <factor>` | Positive finite scale; 1 = original size |
| `//gil counttime <seconds>` | Counting duration; nonnegative, no upper limit |
| `//gil colortime <seconds>` | Color return duration; nonnegative, no upper limit |
| `//gil edit [on\|off]` | Toggle persistent positioning guides; explicit states are idempotent |
| `//gil unlock` / `//gil lock` | Start/end positioning with guides |
| `//gil pos reset` | Restore the hardcoded default position and preview |
| `//gil show` | Temporary preview |
| `//gil hide` | Manually hide until show/auto or Scroll Lock toggle |
| `//gil auto` | Clear manual hiding and resume the selected visibility mode |
| `//gil autohide [on\|off]` | Compatibility toggle between change and always |
| `//gil restart` | Fade out, then reload GilFinder once |
| `//gil unload` | Fade out, then unload GilFinder once |

Input mode ignores all mouse activity and stick axes. Controller buttons/POV
are read through the optional Windows reader; wrapper-generated keyboard
presses also work. Native PS5 reader support remains a live check. Input only
wakes the focused client. Triggers presented only as axes need wrapper key
output. `status` reports reader availability.

On first balance initialization, the widget previews for the configured hold
time. Change mode restarts that timer on gains/losses. Another balance change
retargets the count from the currently displayed number. Color follows the
latest transaction direction, then returns to the configured normal color.

Cutscene hiding is OFF by default, including NPC dialogue. Turning it on
suppresses the widget while player status is 4; the normal timer continues
running. Always/input/change modes all respect that optional suppression.

Edit mode keeps the widget visible with a guide above it until editing ends.
Dragging only intercepts visible widget hit areas. Scaling/side changes/show
preview it temporarily. `hide` overrides modes, previews and editing.
Scroll Lock remains the manual visibility toggle.

Windower's standard config, texts, images, packets and chat libraries are
required. Polling remains a fallback for balance updates (default 5 seconds).
Font sizes round to whole pixels; the stroke remains at least one pixel.
No sounds or extra controller wrapper are installed.

## Changelog

### 1.3.0-a.20261015.1 — GilFinder rename / personal defaults

- Renamed folder, entry point, metadata, commands and current help to
  gilfinder / `//gil`; retained upstream license and historical test records.
- Adopted settings(10).xml global defaults and its personal character overrides;
  replaced the old absolute icon path with addon-relative runtime resolution.
- Added optional cutscene hiding, default off, including dialogue status 4.
- Adopted NPCMirror's shared WORKFLOW: colored chat help; bare/invalid help;
  detailed status; edit on/off guides; show/hide/auto; position recovery;
  graceful, single-dispatch restart/unload; local implementation state.

### 1.2.0-a.20261013.2 — Test 2

- Left/right amount placement, initial display, green/pink animated counting,
  color restoration and change/input/always visibility modes.
- Keyboard hold handling and optional Windows controller button/POV reader.

### 1.2.0-a.20261013.1 — Test 1

- Shared icon/text dragging and saved position, scaling, 60-second autohide
  with 0.5-second fade, and adjustable 1–3600-second hold.

### Upstream baseline

GilTracker 1.1.0 from Windower/Lua, retrieved October 13, 2026. BSD license in
source retained. https://github.com/Windower/Lua/tree/dev/addons/giltracker
