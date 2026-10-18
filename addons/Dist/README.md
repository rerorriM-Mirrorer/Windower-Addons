# Dist — 0.1.0 (independent DistancePlus default display)

**Author:** A. Developed from DistancePlus by Sammeh; the original copyright and license are retained in `dist.lua`.

A deliberately minimal FFXI/Windower distance label. It measures the selected target, falling back to a subtarget, and displays the result to one decimal place. It always uses the three-color **Default** behavior from our DistancePlus 1.5.4 fork. No automatic job detection, specialized range modes, height, pet distance, abilities, theme lists, or configurable range logic.

## Installation

1. Copy the `Dist` folder into `Windower/addons/`.
2. In the in-game console, use `//lua l Dist`.
3. If you already run DistancePlus, unload it with `//lua u DistancePlus` to avoid seeing two distance displays. You can keep both installed. No DistancePlus files or data are altered.
4. For first-time testing, `//dist status`, then target a nearby player/NPC/monster.

Saved positioning belongs to **Dist's own** settings, not DistancePlus settings. A fresh install uses right-justified `(-178, 21)`.

## Display

| Target distance | Color (RGB) | Font size |
| --- | --- | --- |
| ≤22 yalms | Warm white (254, 251, 255) | 12 pt (+1 emphasis) |
| >22 through 30 yalms | Lavender (161, 159, 206) | 11 pt |
| >30 yalms | Muted purple (88, 85, 132) | 11 pt |

- Verdana, one decimal, stroke width `1` in warm near-black `(20, 10, 12)`; transparent background.
- +2 px *render-only* horizontal offset in the near band, following DistancePlus 1.5.1.
- Hides when no valid target exists. Hides during status `4` cutscenes/events, like EnemyBar2. Also hides on logout or a zone-change event.
- Drag to move the label; the Windower `texts` library saves the final position.
- Clamps position to current UI boundaries, including after client-resolution changes; 4 px margin where possible.
- No explicit zoning state detector beyond the status-4 behavior: crystal teleport loading screens still need live testing.

## Commands

```text
//dist                  -- help
//dist help             -- help
//dist status           -- current settings and position
//dist pos -178 21      -- set right-relative position
//dist pos reset        -- restore safe starting position
//dist lock             -- disable dragging
//dist unlock           -- allow dragging
//dist size 11          -- set base font size (near range is +1)
//dist restart          -- restart addon
//dist unload           -- unload addon
```

Unknown commands show help. There is no `//dist default`, because **Default is the only mode**.

## Changelog

- **0.1.0 (2026-10-15)** — First independent build. Extracts and simplifies DistancePlus Default's three distance bands, static palette, font emphasis, right-edge centering, position persistence/clamping, and EnemyBar2-compatible cutscene hiding. Adds minimal help, status, size, movement and lifecycle commands. Not yet tested live in FFXI.
