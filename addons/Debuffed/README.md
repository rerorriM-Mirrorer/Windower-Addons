# Debuffed — Icon Presentation Test 2.4

Original addon: Xathe, `Debuffed` v1.0.0.4 (Windower/Lua).  
Icon presentation, help, and transitions: A.  
Testing build: `1.0.0.4-icons-test2.4` (2026-10-13).

## Installation

1. Back up `Windower/addons/Debuffed/`, especially `data/settings.xml`.
2. Extract the ZIP into **`Windower/addons/`**, *not* into `Windower/addons/Debuffed/`. The archive already includes the `Debuffed` folder.
3. Confirm that the active file is `Windower/addons/Debuffed/Debuffed.lua`, **not** `Windower/addons/Debuffed/Debuffed/Debuffed.lua`.
4. Replace files when prompted; your `data/settings.xml` is **not included** in the archive.
5. Install XivParty separately with its original `assets/buffIcons/` directory. We read those existing textures and do not redistribute them.
6. While logged in, run `//lua reload Debuffed`.

Command aliases: `//db`, `//dbf`, `//debuffed`. `//db` is the short alias; `//dbf` remains available if a locally installed addon/plugin uses `db`.

## New in Test 2.4

- `//db preview` — full **12-second** visual preview: 11, 10, ... 0 (one count per second), then a 0.65-second fade-out. Samples are **not** reported as enemy debuffs. The *automatic* startup animation remains brief (1.2-second hold plus 0.65-second fade).
- `//db edit` — 16 outlined slot guides by default, with dimmed sample status icons and individual timer labels, cycling **1:10 → 0:00 → 1:10** until editing is turned off. Real tracked icons are temporarily hidden during edit mode. Timer X/Y offsets and timer size apply to these dummy labels too.
- Default `slots=16`, `wrap=16`, horizontal orientation (one row). **Existing saved settings override defaults**: run `//db slots 16` and `//db wrap 16` once if your prior installation retained `32`.
- `//db restart` — reports action in the FFXI chat log, fades visible UI for ~0.36s, then sends `lua r Debuffed` once.
- `//db unload` — same closing transition followed by `lua u Debuffed` once.
- `//db` or `//db help` — new BattleStations-inspired, color-coded in-game help with commands and explanations; no deliberate duplicate console output. Bad commands receive short errors instead of dumping the entire help.
- `//db status` — current version, mode, layout position and icon diagnostics.

## Commands

The bracket notation is `<required>` and `[optional]`. The `|` character indicates a choice, not something to type literally.

| Command | Function |
|---|---|
| `//db help` | Show the complete chat help |
| `//db edit [on\|off]` | Toggle or set the positioning/edit preview |
| `//db preview` | Replay the 11→0 sample countdown |
| `//db slots <1-64>` | Maximum visible real effects **and** number of slot guides |
| `//db wrap <0-64>` | Slots per row (horizontal) or column (vertical); 0 = no wrap |
| `//db display <icons\|text>` | Select icon rendering or classic text |
| `//db layout <horizontal\|vertical>` | Set primary fill direction |
| `//db iconsize <12-96>` | Icon size in pixels (default 24) |
| `//db iconspacing <0-40>` | Gap between slots (default 5) |
| `//db sort <priority\|id>` | Dia first or numeric buff status ID |
| `//db timers` | Toggle estimated live timer text |
| `//db timersize <6-24>` | Timer font size; default 8px Arial bold italic |
| `//db timerx <-32..32>` | Timer horizontal offset (positive moves right) |
| `//db timery <-32..32>` | Timer vertical offset (negative moves up) |
| `//db timeroffset <x> <y>` | Both offsets in one command |
| `//db targetname [on\|off]` | Toggle or set enemy name (default off) |
| `//db background [on\|off\|0-255]` | Transparent by default |
| `//db mode` | Switch blacklist/whitelist |
| `//db blacklist <add\|remove> <spell>` | Filter spell name |
| `//db whitelist <add\|remove> <spell>` | Filter spell name |
| `//db interval <seconds>` | Refresh interval (original tracker) |
| `//db hide` | Original hide-at-zero toggle (original behavior retained) |
| `//db iconpath [path]` | Read or override icon directory |
| `//db status` | Show basic settings and asset status |
| `//db diagnose` | Show renderer diagnostics |
| `//db restart` | Fade then reload the addon |
| `//db unload` | Fade then unload the addon |

For example: `//db timerx -2`, `//db timery -4`, `//db slots 16`, `//db wrap 8`.

## Technical behavior

- All debuff detection, action/packet handling, overwrite logic, durations, and wear-off tracking are Xathe's original functions and are **unchanged from Test 2.3**. The sample icons/timers never enter `debuffed_mobs`.
- Real timer labels remain estimates from the original tracker. Their behavior is independent of the simulated edit/preview countdowns.
- The transparent drag hit rectangle spans the configured grid and can intercept mouse input even when invisible.
- Fading disappearance of a real debuff is presentation-only (0.32s). The restart/unload closing fade is a separate transition (0.36s).
- The renderer uses image and text primitives proportional to configured `slots`. For multi-client play, use a modest slot count where practical.
- Long help output scrolls the chat log; topic-specific pages may be explored later after in-game feedback.

## Testing status

Lua parser checks and mocked renderer/command simulations passed, including manual and edit countdowns, layout resize, `restart`/`unload`, and primitive cleanup. **Not yet live-tested in FFXI**. See `../TESTING.md` in the testing archive for procedures and scope.

## Changelog

- **Test 2.4 (2026-10-13):** BattleStations-style chat help; 12-second countdown preview; editable 1:10 looping dummy timers with transparent samples + retained edit boxes; 16/16 defaults; fade-before-restart/unload; preserved tracking.
- **Test 2.3 (2026-10-10):** Arial bold-italic timer font and adjustable size/X/Y positions, configurable slots and wrapping, added `//db` alias.
- **Test 2.2 (2026-10-10):** Chat-log command feedback, fixed preview texture initialization, individual slot edit guides, updated A authorship.
- **Test 2.1 (2026-10-10):** More reliable startup sample-image loading and preview diagnostics.
- **Test 2 (2026-10-10):** Dia-first sorting, timer repositioning, opening and disappearing fades, drag/edit outlines.
- **Test 1 (2026-10-08):** Initial status-ID icons using installed XivParty art; kept original tracker.
