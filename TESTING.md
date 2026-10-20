# TESTING.md

## Latest observations and diagnostic revision — 2026-10-20

- **User-confirmed live:** Running `all lr switch_focus` froze rendering and input across clients *before* `//switch p1` was invoked. Cioara subsequently loaded the modified Lua individually and ran `//switch p1` while alone without a freeze.
- **Interpretation:** The revised `p1` handler is not called on load. Simultaneous reload contention and the unchanged original join/clear discovery messaging are hypotheses, not proven causes. The successful single-client test does not yet demonstrate cross-client focus switching.
- **New diagnostic:** `//switch status` prints local character/focus, party leader ID/name, known addon clients, and back target. This command sends no IPC; the existing load/reload discovery path is deliberately unchanged.
- **Safe next test:** Reload only one client at a time; inspect `//switch status` and confirm clients discovered, then try `//switch p1` with two clients already stably loaded. **Do not repeat `all lr switch_focus`** pending further investigation.
- **Verification:** Code reviewed by source comparison. Previous locally run Lua 5.4 parsing/mock tests were reported for an equivalent draft; the published source has not been retested inside the game. Lua 5.1/Windower behavior remains unverified.
- **Publication:** Testing branch only; `dev` unchanged. Existing historical observations remain below.

## Current Development Status — 2026-10-20

- **Scope:** `switch_focus` dynamic party-leader command.
- **Repository / branch:** `rerorriM-Mirrorer/Windower-Addons` / `feature/switch-focus-party-leader` (testing; not merged into `dev`).
- **Starting source:** `dev`, `addons/switch_focus/switch_focus.lua` blob `62f8700a8cd65693f694a75f9f19027080dcdb9e` (matches Windower/Lua `dev`).
- **Current batch:** `//switch p1` resolves the live party-leader ID to a character name, then issues the established exact-name focus IPC without the usual lobby fallback.
- **Known-good live baseline:** Not established for this feature; existing `switch_focus` behavior is unchanged by intent, but regression testing is pending.
- **Verification:** Source inspection and deterministic edit assertions; Lua 5.1 interpreter and live FFXI client are unavailable in this session.
- **Live finding (2026-10-20):** User reported all game clients freezing after installing the modified Lua and reloading it on all clients. Reload method was `all lr switch_focus` across all clients; `//switch p1` was not invoked before the freeze; no acceptance test has passed.
- **Unresolved/live checks:** Determine the freeze trigger and review the addon's existing reload-time IPC discovery before any further gameplay test. Once safe, verify ID-to-name resolution, role changes, solo use, unavailable clients, and existing commands.
- **Next:** ~~Load this test build on each participating Windower client, run the acceptance scenarios below, and report any console errors or failed focus transitions.~~ **Paused after the reported freeze:** restore the original Lua first, gather the precise sequence and any console log, then isolate single-client load/reload behavior before a multibox test.

## Current testing batch — switch_focus party leader (2026-10-20)

**STOP TEST — user-reported freeze (2026-10-20):** After replacing `switch_focus.lua` and reloading the addon on all clients, the user reported that the games froze. Exact reload order, whether rendering or only input stopped, and whether the new command was invoked are not yet known. This is a failed live load/smoke report, not a successful test of `p1`. Restore the previously working Lua and **do not retry this build on all clients** until the cause is isolated. Source inspection indicates the `p1` handler is not invoked by the load event; the original addon does send `clear`/`join` IPC messages during load, which is a possible but unconfirmed contributing factor. No new executable changes have been made in response to this report.

**Historical plan below is suspended pending investigation.**

**Installation:** Preserve the existing `switch_focus` folder as a known-good copy; place the testing version of `switch_focus.lua` in `Windower4/addons/switch_focus/` on every client and run `//lua r switch_focus` on each.

| Test | Action | Expected result | Observed |
| --- | --- | --- | --- |
| Different leader | With Clairvaux leading, issue `//switch p1` from Cioara | Clairvaux receives focus | Pending live |
| Leadership changes | Transfer lead to Myrr; issue `//switch p1` from Cioara | Myrr receives focus | Pending live |
| Already leading | Issue `//switch p1` from the currently focused leader | Focus remains; no lobby switch | Pending live |
| Solo client | Leave party and run `//switch p1` | Focus remains | Pending live |
| Client missing | Party leader's other client lacks `switch_focus`; run `//switch p1` | Focus remains; no lobby switch | Pending live |
| Separated zones | Have party leader in a different zone; run `//switch p1` | Follows leader if party roster exposes ID/name, otherwise prints clear warning | Pending live |
| Regression | Use `//switch p`, `//switch next`, `//switch back`, `//switch to <name>` | Prior commands still work | Pending live |

**Limitation:** No game or Lua interpreter execution was possible in this development session. No outcomes above are claimed as passed.

## Agent entry-point adoption — 2026-10-16

- Added [`AGENTS.md`](AGENTS.md) to direct repository-aware coding agents to read the current `WORKFLOW.md` and `TESTING.md` before making changes.
- **Commit:** [`f0651c0`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/f0651c0f9ed0104803611a2309f3039dba078c2a).
- **Scope:** Documentation only; no addon code changed, testing ZIP generated, or in-game test performed.
- **Continuity:** Earlier testing and development records below remain intact.

## Package layout convention — 2026-10-16

- **Repository:** Keep `WORKFLOW.md` and `TESTING.md` at the repository root.
- **Testing ZIPs:** Include both inside the installable addon folder alongside the README and code. For patch/test-only bundles without an addon folder, place both next to the delivered files. No redundant outer ZIP-root copies.
- **Reference commit:** [`bd228bd`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/bd228bdf02c3cb14b88de7d71a41fbe41568667e).
- **Verification:** Documentation only; no game code changed and no in-game tests performed for this instruction update.
- **History:** Previous ZIP-root conventions remain below as historical records, with dated corrections where they were stated as current instructions.

Read this first when preparing or evaluating a development/testing batch. This cumulative, project-specific record belongs at the repository ~~and testing-package~~ root alongside `WORKFLOW.md`. **Correction (2026-10-16):** In testing packages, put both guides alongside the addon or patch/test files, not at the outer ZIP root.

## Current testing batch — documentation adoption (2026-10-13)

- **Project:** Windower-Addons (including ConsoleBGPlus) (`rerorriM-Mirrorer/Windower-Addons`).
- **Batch:** Documentation-only adoption; no addon testing package or executable changes.
- **Starting default-branch commit:** `080ec5e34d386f6b07e6a654b104589dae71f51b` (`dev`).
- **Documents:** Added root `WORKFLOW.md` and `TESTING.md`.
- **Reference:** [NPCMirror consolidated workflow](https://github.com/rerorriM-Mirrorer/ffxi-NPCmirror/blob/main/WORKFLOW.md).
- **Verification:** Check root filenames and links; compare migration against its starting commit and confirm only Markdown documentation changed.
- **In-game testing:** Not performed for this documentation-only change; existing addon behavior has not been revalidated.

- **Recorded migration commit:** [`16a05d6`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/16a05d601ee5b23a9503f2e20bbeee9b9e9ab4c0).
- **Verified result:** Git comparison against the recorded starting commit lists Markdown changes only; `WORKFLOW.md` and `TESTING.md` exist at the repository root. No Lua source paths changed.

## Tests for the next functional batch

List the requested change, actions to perform, expected outcomes, previously working behavior to retest, and results actually observed. This repository may maintain multiple addons; name the addon and its testing branch in each future batch.

## Previous tests and checks

No historical test results were reconstructed or verified during this documentation migration. Preserve previous testing materials and bring forward only accurately attributed results when reviewed.

## Cumulative changelog

- **2026-10-13 — Navigation refinement:** Corrected the heading levels for the Testing Packages and Shared Development Conventions sections in `WORKFLOW.md` ([`ca3b01b`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/ca3b01bc98d1017a27d5bddc1f9fe15f89eaef7f)). Documentation only; no addon code changed.

- **2026-10-13:** Adopted the shared two-document development convention without changing executable addon behavior.

## Delivered packages and documents

| Date | Batch | Item | Type | Commit/reference | Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-10-13 | Documentation adoption | WORKFLOW.md; TESTING.md | Repository documents | [`16a05d6`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/16a05d601ee5b23a9503f2e20bbeee9b9e9ab4c0) | No testing package or Lua changes |

## User-provided materials, observations, and requests

- **2026-10-13 — Shared conventions:** Combine Agathos, Design, and Workflow into one `WORKFLOW.md` with linked table of contents; retain `TESTING.md` as the project-specific historical record; both documents belong in each active repository and testing-package root.
- Add earlier requests, tests, screenshots, files, and observations only when their provenance is verified; record date, batch, and reference.

## Corrections and retention

Correct errors with ~~strikethrough~~, an explanation, and the replacement. Remove historical testing information only by mutual agreement.
