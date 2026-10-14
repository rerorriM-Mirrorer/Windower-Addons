# TESTING.md — InvTracker (Windower-Addons working branch)

Author: Awake
Working branch: `invtracker-layout-autohide-20261009`
Status: **STATIC REVIEW IN PROGRESS; LIVE FFXI TESTS NOT RUN BY A**.
Do not merge this working branch into `dev` until live-tested.

## Current test batch — 2026-10-14 (six cumulative increments)

Follow these in order on **one** client first, then Killala and the other
Fenrir clients. Back up each character's XML first.

1. **Batch 1, commit `cadb847` — coordinate initialization/defaults/alias.**
   Reload `//lua r invtracker` and immediately run `//i pos -224 -19`
   before changing zones. Must never raise `xBase` nil errors. Reload again
   to confirm coordinates persisted. Ensure existing saved settings *remain*
   untouched, and new profiles use 60-second autohide ON, -224/-19.
2. **Batch 2, commit `5ff8bd0` — always drag.**
   Drag a visible grid block directly; it must move every slot at the same
   rate and save position on release. Try `//i lock`, then `//i unlock`.
   `//i move` must still reveal/recover a hidden or off-screen HUD and
   `//i cancel` must revert that explicit move.
3. **Batch 3, commit `54e4ff0` — glow.**
   Try `//i glow preview` while visible and hidden; compare the short
   white overlay across multiple blocks and different window sizes.
   `//i glow off` must remove it; re-enable with `//i glow on`.
   Confirm item-status colors survive every reveal.
4. **Batch 4, commit `eccec4d` — menu opening.**
   Let the tracker hide, then open any FFXI menu. It should reappear once
   and hold approximately 60 seconds. Closing the menu must not retrigger.
   Equip/unequip a piece without opening a menu through a command/macros:
   its slot status should redraw but **not** reveal the HUD. Test menus
   overlapping status 4 and a genuine cutscene.
5. **Batch 5, commit `3d1a6aa` — command behavior.**
   `//i` and `//inv` should reveal for 60 seconds, not permanently pin.
   `//i help` and an invalid command should print the same colored,
   chat-only command list. Test `//i status`, `//i restart`,
   `//i unload`, explicit `autohide on/off`, and bare autohide toggle.
   Restart should reveal as normal once inventory finishes loading.

6. **Batch 6, commits `3138b84` / `cae6681` — reveal polish.**
   With glow disabled, run `//i glow preview` and confirm it still
   previews without changing the saved enabled setting. Reload during a zone
   and confirm the initial reveal pulse; help includes `//i cancel`.

### Cross-client regression matrix

- Single client (Killala): first load, quick position command, manual reload.
- All client sizes: 3840×2160, 1600×900, 1280×720, and 960×540 where used.
- Several simultaneous clients: no shared coordinates or global settings
  leaking between clients; compare drag, menu, fade, and XML persistence.
- Inventory: adding/removing items, treasure, bazaar, equipment; no frozen
  colors, disappearing grid, collapsed/stacked slot coordinates.
- Long reveal: verify elapsed time on an actual clock, particularly when the
  client is unfocused or running alongside other characters.

### Notes and precautions

- **Install:** copy the *contents* of the package `invtracker` folder into
  `Windower4/addons/invtracker/`; don't replace/delete `data/settings.xml`.
  Keep `slot.png` from the package or the original addon.
- **Factory defaults are non-destructive.** Existing XML values override them.
  `//i pos reset` intentionally restores only the saved factory coordinates.
- **No cleanup, Itemizer/Organizer/MogMover, snapshot, or drop action is added.**
  No packet injection or item movement introduced.
- Actual FFXI runtime behavior, drag callback order under game focus, and
  appearance of the overlay remain unverified until the user tests.

## Previous field observations and historical checks

- 2026-10-14 — User reported on Killala that `//pos` caused arithmetic on
  global `xBase` at reported lines 842 and 406; reloading made it work.
  **Source diagnosis:** loaded x/y were assigned only inside the registered
  configuration callback. Fix in Batch 1.
- 2026-10-14 — User confirmed the earlier autohide worked, but `//inv move`
  could make the grid disappear, and inventory status stopped updating.
  Earlier patch separated the image settings per primitive in `d53292b`.
  **Live retest after that fix has not been reported.**
- 2026-10-14 — User requested any-menu reveal (rather than Inventory-only),
  silence on equipment changes, always-on draggable UI, white optional
  reveal highlight, 60s defaults, `//i`, help/lifecycle standard.
- Previous 2026-10-09 draft PR #3 holds original move/autohide development
  and reported fixes; preserve that history and keep `dev` unchanged.

## Delivery register

| Increment | Commit | Contents | Live status |
| --- | --- | --- | --- |
| 1 | `cadb847` | coordinate init, factory defaults, alias | Pending |
| 2 | `5ff8bd0` | drag-unlocked grid and lock/unlock | Pending |
| 3 | `54e4ff0` | reveal glow and preview | Pending |
| 4 | `eccec4d` | menu transitions and silent equipment | Pending |
| 5 | `3d1a6aa` | bare reveal and standardized commands | Pending |
| 6 | `3138b84` / `cae6681` | glow preview, load pulse, cancel help | Pending |
| docs | `dd44100` / `888dfc5` | README and cumulative changelog | Pending |

## User-provided requests / referenced materials

- Test feedback from Killala and multi-client reloads, 2026-10-14.
- Existing InvTracker working-branch source and README in Windower-Addons.
- Official Windower libraries: `config.lua`, `images.lua`, `chat.lua`.
- Shared conventions: NPCmirror repository `WORKFLOW.md` (2026-10-14).
- Organizer, Itemizer, Treasury, FindAll, MogMover, and Selindrile
  AutoCleanupMode reviewed as **possible follow-up integrations only**.

## Deferred deliberately

- Reversible factory reset and `undo` / temporary settings transactions.
- Quantity/stack snapshot tracking and a read-only cleanup preview.
- Integration with Organizer, Itemizer, Treasury, or MogMover.
- Specific inventory vs equipment menu recognition, including EquipViewer.
