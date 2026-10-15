# WORKFLOW — Dist development

**Canonical shared workflow:** https://github.com/rerorriM-Mirrorer/ffxi-NPCmirror/blob/main/WORKFLOW.md

This testing package contains a concise local copy of the relevant **AGATHOS**, **DESIGN**, and **WORKFLOW** principles. The canonical document remains the source of truth; update this copy when continuing development.

## AGATHOS

Good grows. Good widens the circle of possible benefit. A seeks good until A finds good. A makes more good possible.

## DESIGN

- Let additions feel native to FFXI: restrained typography, invisible operation whenever possible.
- Great defaults are more useful than a large configuration surface. Add features because they are helpful, not merely possible.
- Multibox changes should be quiet, cheap per frame, independent per character and resilient on small resolutions.
- Store user state through Windower `config`; prefer official libraries; keep implementation local and preserve settings on reload.
- Comment non-obvious behavior and the reasons for deliberate decisions so diffs teach the reader.
- Help/status should be useful, diagnostic output specific, and ordinary addon use low-noise.

## WORKFLOW

1. Read original addon, active fork, tested baseline, Windower libraries and this file before patching.
2. Make one coherent change at a time. Keep the known-good default intact unless user requests otherwise.
3. Test Lua syntax, mocked behavior, regressions, then the user's real in-game scenarios. Mock results never count as live game verification.
4. Maintain readable explanatory comments for decisions, not self-explanatory lines.
5. Keep README and cumulative TESTING aligned. In delivery ZIP place installable `Dist/` with its README alongside root TESTING.md and WORKFLOW.md.
6. Leave experimental commits on a development branch; do not silently merge into a tested baseline. Push changes only when ready and report the commit/branch.
7. Author: **A**. Preserve attribution and license where code descends from Sammeh's DistancePlus.

### Shared addon conventions

- Bare or unknown `//dist` commands display help, in game chat only.
- Implement `help`, `status`, `restart`, and `unload`. `restart` differs from a reload-settings option; dispatch a lifecycle command once.
- BattleStations-style help: header color 167; separators 140; `//dist` and arrow 200; syntax 207; descriptions neutral 0. Render via `windower.add_to_chat(0, line)` and `require('chat')` / `string.color`.
- Save draggable coordinates; offer lock/unlock and recovery for off-screen coordinates.
- Prefer uncomplicated settings rather than many toggles or modes. Keep baseline ranges fixed until intentionally changed.
- Release documentation should say what changed, which tests actually ran and any unresolved in-game questions.
