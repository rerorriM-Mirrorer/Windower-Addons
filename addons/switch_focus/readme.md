# Switch Focus #

* switch focus to another character running the addon.

----

**Addon Command:** `swf`, `switch`, `switch_focus`

#### Commands: ####
1. `help` : Shows the color-formatted chat-only command list (also shown for bare or invalid commands)
1. `to <name>` : switch focus to specified character.
    - `<name>` can be a partial.
    - other character must also have `switch_focus` loaded.
    - if switch fails checks for any box in lobby to give focus to.
1. `status` : report current client, focus, leader ID/name, discovered clients, and back target with the same colored chat format as help; read-only, no IPC.
1. `p1` : switch focus to the current in-game party leader, regardless of who holds leadership.
    - Detects the leader at command time; requires that character to have `switch_focus` loaded.
    - Does nothing if already on the leader or playing solo; never falls back to a lobby window.
1. `back` : switch focus back to character that **last sent you focus using `switch_focus`**.
1. `(n)ext` : switch focus to next character in alphabetical order.
1. `(p)rev` : switch focus to previous character in alphabetical order.

#### Example use: ####
```plian
//switch to nif
```
this will pass focus to the character whos name matches `nif`, this could be `Nifim` or `Niflheim`

## Current test status

- Live verified (2026-10-20): From Clairvaux, `//switch p1` successfully focused party leader Cioara after joining her party, using the prior revision.
- Live verified (2026-10-20): After unloading individually, `all ll switch_focus` loaded the addon across clients without freezing. `//switch status` displayed information in the prior revision.
- Caution: `all lr switch_focus` previously froze game rendering and input on all clients before `p1` was invoked. The simultaneous reload issue remains under investigation; prefer sequential reloading or unload individually then use `all ll`.
- The new colored formatting revision still needs a live display check; it doesn't change `p1`, client discovery, or IPC.

## Changelog

- 2026-10-20 (chat formatting): Colored help and status output using our shared BattleStations-inspired chat palette; bare/invalid commands now display help. Testing version 1.1.1-test.

- 2026-10-20 (diagnostic revision): Added `//switch status`; no change to startup IPC or focus dispatch. Reload one client at a time while investigating an all-client freeze.
- 2026-10-20 (testing branch): Added `//switch p1` for dynamic party-leader focus using `get_party().party1_leader`. Existing next/previous/back/to commands are retained.
