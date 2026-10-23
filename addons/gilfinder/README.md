# GilFinder

Version 1.6.0-a.20261023.1. Original GilTracker by sylandro; modifications by A.
A compact gil widget with animated balance changes, a responsive coin glint, live multibox
wallet, saved dragging, layout choices, scaling, and three visibility modes.
Current verification and live checklist: TESTING.md shipped beside this file.

## Installation / rename from GilTracker

1. Unload the old addon on every running client: `//lua unload giltracker`.
2. Copy the included `gilfinder` folder into Windower/addons.
3. Load it on each desired character: `//lua load gilfinder`.
4. Replace `giltracker` with `gilfinder` in startup scripts or AddonManager
   lists. Replace old `//gt` or `//giltracker` macros with `//gil`.

Leave the old addon unloaded. Its folder/settings are untouched. Do not load
both widgets at once. The new folder name is separate from Windower's stock
GilTracker, so stock GilTracker updates target the old folder.

## Updating and settings

Copy the complete gilfinder folder into addons, then `//gil restart` on each
running client (or use `//lua reload gilfinder`). Load the update on EVERY
client you want listed in the wallet. This package contains no active
`data/settings.xml`, so your existing character settings are preserved.
Fresh installations get hardcoded global defaults: change mode, 60-second
hold, 0.5-second fade, scale 1, amount left, 9px italic text, and 0.4-second
counting followed by 0.8-second color return. Glint defaults on, lasting 0.7s.

For an optional fresh personal setup, copy docs/Personal-settings-template.xml
to data/settings.xml before loading. That template preserves settings(10).xml
preferences: Cioara always at (-169,-2137); Killala input at (-169,-2137);
Myrr always at (-166,-2135). Do not copy it over newer personal settings.
Coordinates are offsets from the right/bottom edges. Fully off-screen positions
recover on smaller windows; valid positions stay unchanged.

The old `autohide` XML flag is migrated out on load. Explicit `visibility` wins;
boolean-only legacy sections are converted into an equivalent mode. The first
migration saves data/settings-before-wallet.xml as a backup. All character
sections, positions, scales, colors, and unrelated options remain in place.
`visibility` is now the only saved setting controlling the mode. The old
`//gil autohide` command remains a convenience for change/always.

## Live wallet

`//gil wallet` toggles a wallet list beside the coin. `wallet on`, `off`, and
`refresh` are explicit actions. It collects fresh balances from logged-in,
inventory-ready characters running GilFinder on the SAME computer. After a
one-second collection window, names and right-aligned amounts unfold into fixed
columns over about 0.3 seconds, followed by an optional total (off by default).
Only the requesting client opens a panel. The IPC protocol remains compatible
with Wallet & Glint Test 1; updating every client is recommended.

The list follows `side`: amount left means amounts then names; amount right
means names then amounts. It inherits font, scale and the coin's drag anchor.
It opens downward where space permits, upward near the bottom, and shifts
horizontally to fit. Refresh replaces the snapshot without replaying its entrance.
Names include numeric server IDs when the results span multiple servers.

Opening or refreshing resets the HUD timer and reveals it. The list remains
open until dismissed or the HUD naturally fades; always mode keeps it open.
Departure plays the coin glint, then rolls up the list while the HUD fades.
New applicable activity can interrupt departure. Zoning/logout clears the list.
It does not intercept mouse input; drag the coin or main amount to move it.

Total covers responding characters only. Clients without GilFinder, offline,
loading, zoning, and other-computer clients are excluded. This is an on-demand
snapshot, with no offline cache or transfer accounting. Values can change after
the snapshot; use `wallet refresh` to sample again. No game-server packets are sent.

**Glint stability fix (2026-10-22):** The animation clamps all rendered frame indices to 1–20 and safely skips unavailable frames. This prevents a repeated prerender nil-index error if timestamp/order anomalies occur. Underlying time reversal has not been independently confirmed in-game. Keep prior saved data intact.

Wallet amounts now use native right justification: each row's ones place shares
one fixed column anchor on either side. Names occupy a separate column.
`//gil wallet total on|off` controls the combined total (bare `wallet total`
toggles). It defaults OFF, including existing installations with no saved choice.
The total preference updates an open panel without a new IPC query.

`//gil gap <UI units>` adjusts main amount-to-coin spacing on either side.
Positive values separate them; negative values overlap them. Default 1, scaled
with the widget. Right-side spacing was previously hardcoded to 4 and now uses
the same setting as the left. It never moves the coin/glint anchor. This controls
the main amount, not the independent wallet column spacing.

## Sparks and Conquest Points - first currency tray

`//gil sp` / `//gil sparks` reveals Sparks of Eminence. `//gil cp` reveals three
separate Conquest Point balances: San d'Oria, Bastok, Windurst. Nation-specific
shortcuts: `//gil sandoria`, `//gil bastok`, `//gil windurst` (`sandy`/`windy`
also accepted). `//gil curr` shows all four; `//gil curr <search>` searches labels.

Exact names and aliases win, otherwise all substring matches appear. A near
spelling suggests a command without choosing it. Existing addon commands keep
priority. Search is case insensitive and punctuation/spacing insensitive.

Currency changes unroll into a tray beside the coin, count from their previous
amount with gain/loss colors, hold 8 seconds, then roll up. `//gil currencydelay
<seconds>` changes that separate hold (1..3600). Rows follow side/scale/font and
open upward when there is insufficient room below. Provisional 23px SP/SD/BA/WI
badges identify the currencies; final lore-inspired art and individual glints
are deferred. The existing gil coin glints on observed changes when enabled.

The first received sample establishes a silent baseline. Unknown values display
`--`, never a fabricated zero. Explicit queries show the last observed value
while asking for a fresh snapshot; a missing reply times out in chat after about
3 seconds. `status` reports sample count/oldest age. No offline currency cache
is saved. Zoning/logout clears samples and presentation.

Uses Windower's currency-menu request (0x10F) and native replies (0x113), plus
passive Sparks updates (0x110). Requests occur after inventory initialization,
on menu open/close in every visibility mode, on explicit currency queries, and
via a 60-second fallback. Requests are separated by at least 2 seconds; a query
during that interval is deferred. Changes appear when a fresh server sample is
observed, which can lag a purchase. No purchase packets are sent. NPCmirror does
not need to call GilFinder; its purchases can be observed like other purchases.

An open gil wallet takes priority. Currency changes queue while it is open,
then receive a fresh display hold when it closes. Explicit currency queries
close the gil wallet to use that space. `hide` clears both. Currency queries
are for the current character; the existing multiclient wallet remains gil-only
in this first pass. No requirement to install Currencies separately.

Cioara's fractional/resolution layout work remains on hold. This build retains
existing positioning and recovery behavior.

## Coin glint

Automatic triggers:

- First balance display on load/login, and reappearance after hiding.
- Gil gained or spent, alongside green/pink counting.
- Native menu opening or closing in change/automatic mode.
- Accepted `//gil` commands, including wallet open/close/refresh.
- A farewell sweep before natural timed fading and wallet roll-up.

Overlapping triggers share a sweep. Explicit hiding keeps the HUD hidden;
commands do not undo that override unless they explicitly reveal it (`show`,
`auto`, wallet opening, positioning preview). Invalid commands do not glint.
`//gil glint off` disables automatic glints. `glint preview` still plays one
without changing the preference. `glint on` or bare `glint` enables/toggles it.
The overlay follows position, scale, opacity and cutscene hiding, without mouse
input or sound. glintDuration in XML accepts positive finite seconds (default
0.7). Preloaded coin-masked frames avoid texture loading during animation.

## Commands

Bare `//gil`, `//gil help`, and invalid commands show colored chat-only help.

| Command | Behavior |
| --- | --- |
| `//gil status` | Version, mode, side, timing, scale, coordinates, editing and controller state |
| `//gil mode` | Cycle always -> change -> input |
| `//gil wallet` | Toggle wallet panel; `wallet on`, `off`, `refresh` also supported |
| `//gil wallet total [on\|off]` | Toggle combined total; default off |
| `//gil gap <UI units>` | Positive separates main amount and coin; negative overlaps |
| `//gil sp` / `//gil cp` | Reveal Sparks / three nation Conquest Point balances |
| `//gil curr [search]` | Show supported currencies or search their labels |
| `//gil currencydelay <seconds>` | Currency tray hold, default 8; 1..3600 |
| `//gil glint [on\|off\|preview]` | Toggle responsive highlight or preview it |
| `//gil mode always` | Always visible |
| `//gil mode change` | Show on gil changes and native menu open/close |
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
| `//gil show` | Keep visible; selects always mode |
| `//gil hide` | Manually hide until show/auto or Scroll Lock toggle |
| `//gil auto [change\|input]` | Clear manual hiding and start timed mode; defaults to change |
| `//gil autohide [on\|off]` | Compatibility toggle between change and always |
| `//gil restart` | Fade out, then reload GilFinder once |
| `//gil unload` | Fade out, then unload GilFinder once |

Input mode ignores all mouse activity and stick axes. Controller buttons/POV
are read through the optional Windows reader; wrapper-generated keyboard
presses also work. Native PS5 reader support remains a live check. Input only
wakes the focused client. Triggers presented only as axes need wrapper key
output. `status` reports reader availability.

On first balance initialization, the widget previews for the configured hold
time. Change mode restarts that timer on gains/losses and native menu open/close
transitions. Leaving a menu open does not keep the widget visible. Windower
reports whether any menu is open, so switching between submenus without a
boolean transition is not a trigger. With glint on, expiry adds one farewell
sweep before the configured fade. Another balance change
retargets the count from the currently displayed number. Color follows the
latest transaction direction, then returns to the configured normal color.

Cutscene hiding is OFF by default, including NPC dialogue. Turning it on
suppresses the widget while player status is 4; the normal timer continues
running. Always/input/change modes all respect that optional suppression.

Edit mode keeps the widget visible with a guide above it until editing ends.
Dragging only intercepts visible main-widget hit areas. Scaling and side
changes preview it temporarily; show selects always mode. `hide` overrides modes, previews and editing.
Scroll Lock remains the manual visibility toggle.

Windower's standard config, texts, images, packets and chat libraries are
required. Polling remains a fallback for balance updates (default 5 seconds).
Font sizes round to whole pixels; the stroke remains at least one pixel.
No sounds or extra controller wrapper are installed.

## Changelog

### 1.6.0-a.20261023.1 - Wallet formatting and first currency tray

- Native right anchors align wallet amounts on both sides; totals optional/off.
- Added signed scaled gap control between the main amount and the fixed coin.
- Added Sparks and three nation CP samples, exact aliases/substrings/suggestions,
  query/observed-change tray, counting/colors and provisional badges.
- Added bounded currency requests, sample/unknown diagnostics, silent baseline,
  timeout and cleanup; wallet retains presentation priority.
- Preserved 1.5.2 glint guards/timestamp fix and existing saved settings.
- Resolution/fractional baseline remains deferred pending Cioara's settings.

### 1.5.2-a.20261022.1 - Glint cleanup and timestamp review

- Guard stop/cleanup frame access as well as drawing; clear stale indices safely.
- Reuse the render timestamp for menu-triggered wakes and glints so the trigger
  cannot start slightly later than its first draw. Retain the frame lower clamp.
- Add invalid-index cleanup and progressing-clock integration regressions.
- User confirms unfolding wallet works; further line-20 report requires live
  retest/full error text to match its exact source. Settings and wallet retained.

### 1.5.1-a.20261022.1 - Wallet Panel & Responsive Glint Test 2

- Added animated fixed-column HUD wallet, total, side-following arrangement,
  edge-aware direction, refresh, dismissal and cleanup.
- Added startup, reappearance, loss, accepted-command, menu-transition and
  farewell glints, coalesced when triggers overlap.
- Change mode now wakes on native menu open/close; show keeps visible and
  auto [change|input] selects timed behavior. Existing input mode retained.
- Preserved same-computer IPC compatibility, saved settings and prior history.

### 1.4.0-a.20261020.1 — Wallet & Glint Test 1

- Added on-demand same-computer wallet over Windower IPC, with request isolation,
  per-character deduplication and fresh integer balance sampling.
- Added a masked gain glint, on/off/preview commands, visibility-aware rendering
  and cleanup; preview leaves the enabled preference unchanged.
- Removed the redundant saved autohide flag with a backed-up per-section XML
  migration. Explicit visibility takes precedence; bare mode cycles settings.
- Update package preserves existing data; moved personal seed XML into docs.
- Refreshed WORKFLOW and testing status; previous records retained.

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
