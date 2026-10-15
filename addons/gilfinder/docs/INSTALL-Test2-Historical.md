> Historical Test 2 installation notes. Current installation is in ../README.md.

# GilTracker — complete installation for Frank's PC

Latest build: 1.2.0-a.20261013.2 (Test 2, all changes included).
The same addon folder works for every character/client; no character-specific
binds or controller-wrapper changes are needed for installation.

1. In each running FFXI client, enter `//lua unload giltracker` if it is loaded.
2. Back up your existing Windower/addons/giltracker folder.
3. Copy this package's giltracker folder into Windower/addons and replace the
   matching Lua/icon files. Keep the existing giltracker/data folder: this
   package contains no settings.xml and will not overwrite character settings.
4. In each desired client, enter `//lua load giltracker`.

For a fresh install, settings are created automatically for each character.
If startup scripts already load giltracker, leave those entries in place.
Otherwise add `lua load giltracker` to the startup script you use for these
clients if you want it loaded automatically next time.

Defaults: initial display; change mode; 60-second hold; 0.5-second hide fade;
amount on the left; green/pink animated counting; scale 1; dragging unlocked.
Existing saved preferences take priority over these defaults.

## Quick setup per character

- `//gt show` — display it temporarily.
- `//gt unlock` — drag icon or amount into place.
- `//gt scale 1.5` — adjust to that client's resolution.
- `//gt side right` — amount to the right of the icon (or side left).
- `//gt mode change` — display after receiving/spending gil.
- `//gt mode input` — display on keyboard/controller buttons.
- `//gt mode always` — keep visible.
- `//gt delay 60` — hold time, 1–3600 seconds.
- `//gt lock` — finish positioning.

TESTING.md contains the live checklist and verification record. All mocked
behavior checks were rerun successfully for this package. Actual PS5 button
reading, visual spacing, native settings persistence and multi-client input
still need an in-game test. This package incorporates every Test 1/Test 2
implementation; it does not claim the live checklist has already passed.
