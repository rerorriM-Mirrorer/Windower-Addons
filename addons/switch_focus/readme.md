# Switch Focus #

* switch focus to another character running the addon.

----

**Addon Command:** `swf`, `switch`, `switch_focus`

#### Commands: ####
1. `help` : Shows a menu of commands in game
1. `to <name>` : switch focus to specified character.
    - `<name>` can be a partial.
    - other character must also have `switch_focus` loaded.
    - if switch fails checks for any box in lobby to give focus to.
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

## Changelog

- 2026-10-20 (testing branch): Added `//switch p1` for dynamic party-leader focus using `get_party().party1_leader`. Existing next/previous/back/to commands are retained.
