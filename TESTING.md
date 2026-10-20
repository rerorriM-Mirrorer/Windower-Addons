# TESTING.md

## Current Development Status — 2026-10-20

- **Scope:** `switch_focus` dynamic party-leader command.
- **Repository / branch:** `rerorriM-Mirrorer/Windower-Addons` / `feature/switch-focus-party-leader` (testing; not merged into `dev`).
- **Starting source:** `dev`, `addons/switch_focus/switch_focus.lua` blob `62f8700a8cd65693f694a75f9f19027080dcdb9e` (matches Windower/Lua `dev`).
- **Current batch:** `//switch p1` resolves the live party-leader ID to a character name, then issues the established exact-name focus IPC without the usual lobby fallback.
- **Known-good live baseline:** Not established for this feature; existing `switch_focus` behavior is unchanged by intent, but regression testing is pending.
- **Verification:** Source inspection and deterministic edit assertions; Lua 5.1 interpreter and live FFXI client are unavailable in this session.
- **Unresolved/live checks:** Confirm ID-to-name resolution when the leader is in the same zone and when separated by a zone; confirm leader changes, solo use, missing destination addon, and `prev`/`next`/`back`/`to` regressions.
- **Next:** Load this test build on each participating Windower client, run the acceptance scenarios below, and report any console errors or failed focus transitions.

## Current testing batch — switch_focus party leader (2026-10-20)

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
