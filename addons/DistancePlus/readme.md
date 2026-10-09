# DistancePlus

Enhances Windower's distance display with range-aware coloring, pet distance, ability-range hints, draggable persistent positions, and configurable styling.

## FFXI-style defaults (v1.5.2)

Fresh installs now use the `ffxi` theme by default:

- Background hidden (`alpha 0`)
- Font `Verdana` (main/pet/height size `11`, ability list size `10`)
- 1 decimal of precision
- Stroke width `1`, color `20 10 12`
- Default-mode distance bands:
  - `<= 22`: near — `254 251 255`
  - `> 22` and `<= 30`: mid — `161 159 206`
  - `> 30`: far — `88 85 132`
- Close emphasis at `<= 22` defaults to `size`, adding `1` to the rendered font size and nudging the right-justified distance `2 px` to the right without changing the saved base position.
- The older `<= 15` experiment remains inactive in the code.

The distance-band presentation applies in **Default** mode. Bow/XBow/Gun/Magic/Ninjutsu retain their specialized range logic and use the selected theme's semantic colors.

## Position and styling

DistancePlus text elements are draggable and positions save automatically on mouse release. A resolution change can leave elements off-screen; use the reset commands to recover them.

Common commands:

```text
//dp status
//dp lock
//dp unlock
//dp pos <x> <y> [main|pet|abilities|height]
//dp pos reset [main|pet|abilities|height|all]  # omitted target resets main

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

//dp close 22
//dp closeemphasis stroke
//dp closeemphasis size
//dp closeemphasis off
```

`//dp closeemphasis size` is the new default and enlarges the displayed number by `1`. `stroke` remains available to add `0.5` to the rendered outline. These are display-only changes and do not overwrite the saved base font size or stroke width.

For compatibility with v1.4.1, `//dp cutoff <distance>` remains available as an alias for changing the near-band cutoff, and `//dp cutoff off` disables the bands.

## Manual modes and optional job detection (v1.5.2)

```text
//dp default    # Three distance bands (white / lavender / muted purple)
//dp magic      # Magic-range coloring
//dp gun        # Gun-range coloring
//dp autojob off
//dp autojob on
//dp autojob    # Toggle without an argument
//dp status
```

**AutoJob is off by default.** Manual mode selection is saved to `settings.xml`, so it survives addon reloads, logins, and job changes. With AutoJob on, the original job-based selection runs on login/job change and immediately when enabled. Turning it off restores the last manually selected mode.

`//dp pos reset` restores only the main display to its original safe coordinates. Use `//dp pos reset all` to recover all four text objects without modifying their styling.

## Original DistancePlus functions

- Higher-precision distance display
- Distance/model-size handling for supported actions
- Range coloring for job abilities, ranged attacks, magic, and Ninjutsu
- Pet distance display
- Optional height delta and ability list

Use `//dp help` in game for the current command summary.
