# EquipViewer parent-anchor and Ctrl-drag alignment — Test 2

## Source and reference

- Starting source: `Windower-Addons`, `equipviewer-autohide-2026-10-08`,
  `a43f5e2c02b3d4130576bdbe7cb0353fef6e14e8` (runtime `3.3.3-dev.1`).
- Reference: [BarFiller2 docs/ALIGNMENT.md](https://github.com/rerorriM-Mirrorer/BarFiller2/blob/ed38c54c83b0c4148409c78bfeca14d5a8389794/docs/ALIGNMENT.md).
- BarFiller2 and EnemyBar2 input/layout code were read. Their anchor conventions
  inform the result; their different mouse handlers were not transplanted.
- No `AGENTS.md` occurs in the starting source tree. Root workflow/testing were read
  directly from GitHub, followed by NPCMirror's current consolidated `WORKFLOW.md`.

## Screen coordinates and native input

`settings.pos.x/y` is the background image's top-left corner in Windower UI coordinates.
There is one independently draggable parent; the item and encumbrance grids and ammo
label are children. Windower's `images.lua` retains mouse ownership and the initial
pointer offset. We observe the moved background during prerender and on release.

With Ctrl down (DirectInput 29 or 157), clamp each raw parent coordinate to
`0 .. max(0, UI_resolution - 4 * slot_size)`, then calculate
`floor(coordinate / grid_spacing) * grid_spacing`. Both axes use origin zero;
the default spacing is 10 UI pixels. There are no separate child-grid snaps.
Release processing also covers movement ending before the next prerender callback.

The keyboard callback never blocks input. Blocked key releases still clear modifier
state; losing focus or logging out clears both Ctrl flags. No new mouse handler was
added for snapping. Ctrl without movement, clicking another/blocked UI, locked or
hidden grids, and changes to spacing do not start a snap or a drag.

## Local coordinates and scale audit

| Drawable | Position/size source |
| --- | --- |
| Background | Parent `(x,y)`; width/height `4 * slot_size` |
| Item icon | Parent plus `(display_pos % 4, floor(display_pos/4)) * slot_size` |
| Encumbrance mark | Same cell mapping and dimensions as its corresponding item |
| Ammo, left-justified | Parent plus `(3 * slot_size, 0.58 * slot_size)` |
| Ammo, right-justified | Right edge `x + 4 * slot_size`, same Y; `texts.lua` expects X minus `ui_x_res` |
| Font size | Existing `0.27 * slot_size`; stroke settings unchanged |

The scale command already derives slot size from the original `32 * scale`.
Repeated moves and scale changes rebuild offsets directly; they do not scale already
scaled positions. Thus no new design-space layer or per-child rounding is needed.
The only duplicated coordinate formulas found were setup vs movement for ammo;
both now call the same helper, preserving their previous numeric results.

## Separate existing visual limitations

No inconsistent internal coordinate calculations were found in this audit, and
the simulations found no accumulated positional drift across repeated scales.
This is not a visual/native-font pass. Existing fractional offsets (`0.58` and
`0.27` multipliers), native font metrics/rasterization, and the fixed stroke may
produce different optical alignment or legibility at tiny scales. They were not
redesigned or independently snapped. The bounds check covers the grid rectangle,
not measured font extents. Dynamic resolution changes without a move/rebuild and
native text placement remain live visual checks.

Normal dragging was already unrestricted in this addon and has no existing
screen clamp. That behavior remains. Snapped placement is bounded when the grid
fits. If it is wider/taller than the viewport, that axis anchors at zero without
pretending the entire grid can fit. Recovery remains `//ev pos 100 100`.

## Verification limits

The regression harness checks parent coordinates, all child cell offsets and
dimensions, both ammo alignments, saved-coordinate requests, and input behavior.
Five resolutions × seven scales × two ammo alignments give 70 combinations.
The optional mode extracts and executes the real `images.lua` mouse callback against
mock primitives. Neither mode renders FFXI, uses Windows input, serializes real
character XML, or verifies native font appearance. See `TESTING.md` for live checks.
