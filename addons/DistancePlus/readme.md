# DistancePlus

Enhances Windower's distance display with range-aware coloring, pet distance, ability-range hints, draggable persistent positions, and configurable styling.

## FFXI-style defaults (v1.5.0)

Fresh installs now use the `ffxi` theme by default:

- Background hidden (`alpha 0`)
- Stroke width `1.5`, color `20 10 12`
- Default-mode distance bands:
  - `<= 22`: near — `254 251 255`
  - `> 22` and `<= 30`: mid — `161 159 206`
  - `> 30`: far — `88 85 132`
- Close emphasis at `<= 15` defaults to `stroke`, adding `0.5` stroke width without changing the saved base style.

The distance-band presentation applies in **Default** mode. Bow/XBow/Gun/Magic/Ninjutsu retain their specialized range logic and use the selected theme's semantic colors.

## Position and styling

DistancePlus text elements are draggable and positions save automatically on mouse release.

Common commands:

```text
//dp status
//dp lock
//dp unlock
//dp pos <x> <y> [main|pet|abilities|height]

//dp bg on|off
//dp bg alpha <0-255>
//dp stroke <0-10>
//dp stroke color <r> <g> <b>
//dp font <font name>
//dp size <number>
//dp decimals <0-12>

//dp theme ffxi
//dp theme classic
//dp theme mono
//dp color near <r> <g> <b>
//dp color mid <r> <g> <b>
//dp color far <r> <g> <b>
```

Most style commands accept an optional final target: `main`, `pet`, `abilities`, `height`, or `all`.

## Distance bands and close-range testing

```text
//dp default
//dp bands on
//dp bands 22 30
//dp bands near 22
//dp bands far 30
//dp bands off

//dp close 15
//dp closeemphasis stroke
//dp closeemphasis size
//dp closeemphasis off
```

`//dp closeemphasis stroke` adds `0.5` to the rendered stroke inside the close threshold. `size` adds `1` to the rendered font size instead. These are display-only changes and do not overwrite the saved base font size or stroke width.

For compatibility with v1.4.1, `//dp cutoff <distance>` remains available as an alias for changing the near-band cutoff, and `//dp cutoff off` disables the bands.

## Original DistancePlus functions

- Higher-precision distance display
- Distance/model-size handling for supported actions
- Range coloring for job abilities, ranged attacks, magic, and Ninjutsu
- Pet distance display
- Optional height delta and ability list

Use `//dp help` in game for the current command summary.
