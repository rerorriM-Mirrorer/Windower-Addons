# TESTING.md

## Current testing batch — 2026-10-21 (single-line prev loop correction)

- **Repository / branch:** `rerorriM-Mirrorer/Windower-Addons` / `feature/switch-focus-party-leader`, based on tested `1.1.2-test` behavior. `dev` remains unchanged.
- **Request:** Correct the previously identified wrong-variable comparison in `switch.cmd.prev()` only.
- **Implementation:** Changed exactly one Lua source line, `while (next ~= name) do` → `while (prev ~= name) do` in `addons/switch_focus/switch_focus.lua`. Commit `f83bc187`. No settings, version, commands, IPC, discovery, startup, `next`, or `p1` logic changed.
- **Static check:** Verified the original wrong comparison occurred once, and reverse replacement of the one changed line recovers the prior source verbatim. Published source and scope to be checked against GitHub.
- **Live verification:** **Pending** for `//switch prev` and alias `//switch p` under 2- and 3-client conditions, including the last-to-first wrap. `//switch p1` and client discovery were previously confirmed in live FFXI on the prior version; not retested for this one-line change.
- **Unchanged unresolved risks:** The `next` and `prev` functions still assume a valid client-list index and nonzero list length; failure handling remains unchanged. Simultaneous broadcast reloads via `all lr switch_focus` previously froze all clients and have not been shown fixed.
- **Safe test:** Keep the known-good previous file; replace the Lua, then reload `switch_focus` on individual clients only (or load it during normal individual client startup). Check `//switch status`; try `//switch prev` between 2 or 3 available clients and `//switch p1` from a party follower. Avoid `all lr switch_focus`.
- **Package:** GitHub source update only; no testing ZIP created for this single-line change. Preserve all historical test notes below.

## Latest confirmed live baseline and future ideas — 2026-10-20

- **Live startup verified (v1.1.2-test):** Following the earlier all-client freeze, the user restarted the game clients. `switch_focus` loaded automatically during each client's individual startup, without reported freezing.
- **Live discovery verified:** `//switch status` showed both Cioara and Clairvaux as discovered/available on the current revision.
- **Live focus verified (v1.1.2-test):** `//switch p1` worked with the current revision after individual client startup. Exact source/destination for this repeat was not specified; an earlier observed example switched Clairvaux to leader Cioara.
- **Live UI feedback:** User likes the current colored help and status output; no further formatting changes requested.
- **Not verified:** No successful test of `all lr switch_focus` has been reported since the deferred discovery patch. The two earlier freeze reproductions remain open. Loading automatically as each game client starts is **not** proof simultaneous reload works.
- **User ideas (not implementation requests):** Optionally make bare `//switch` behave as `next`; optionally notify participating clients with a `Switched from X to Y` message; explore expert-level improvements.
- **Code-review follow-ups (not changed):** Legacy `prev` compares `next ~= name` instead of the local `prev`. Both cycling commands assume a valid local box index and nonempty list, and may repeatedly remove candidates under failure; these deserve bounded failure handling. The existing focus IPC acknowledges a request before calling `windower.take_focus()`; a future protocol can distinguish receipt from confirmed focus. Other candidates: configurable bare action, opt-in local/all notifications, presence freshness/rescan, and protection against focus races from broadcast commands.
- **Development action for this note:** Documentation-only TESTING.md update, no executable Lua changes. Keep the current tested code available as rollback while developing any of the ideas separately.

## Live follow-up — 2026-10-20 (v1.1.2-test)

- **User-observed success:** After loading/reloading the clients with the new `switch_focus` revision, `//switch status` reported **both Cioara and Clairvaux available**. This verifies two-client discovery visibility during this live session.
- **Not yet specified:** The exact load sequence for this observation (`all lr` versus individual reload or unload-then-`all ll`) has not been confirmed. Accordingly, do **not** mark the simultaneous reload freeze resolved.
- **Previously verified:** `//switch p1` from Clairvaux focused Cioara while she was party leader on the earlier test version. Its operation on v1.1.2-test is pending confirmation.
- **Recommended next:** Confirm load method and `//switch p1` from the follower while both clients remain stable. Preserve prior two freeze reports in the cumulative record.
- **Changes in this record:** Documentation only; no Lua changes or additional simulated tests for this follow-up.

## Current Development Status — 2026-10-20 (reload race investigation)

- **Repository / branch:** `rerorriM-Mirrorer/Windower-Addons` / `feature/switch-focus-party-leader`; no changes to `dev`.
- **Live observation, repeated:** Two tries at `all lr switch_focus` froze rendering and input across clients, once before and once after colored status/help, without invoking `//switch p1`. By contrast, individually unloading addons followed by `all ll switch_focus` was successful; status displayed data. In live gameplay, `//switch p1` on Clairvaux successfully focused Cioara as party leader.
- **Investigated original IPC behavior:** The original `join` handler responds immediately to every newly encountered character name with another global `join`. On simultaneous reload, each client also broadcasts `clear` and `join` in rapid succession. Immediate reply bursts and racing clears are plausible contributors, **not a confirmed freeze root cause**.
- **Experimental change, version `1.1.2-test` (commit `928735b7`):** Coalesce multiple new-client discoveries into at most one scheduled `join` reply per 0.20-second burst. Add a single delayed startup `join` after 0.55 seconds to heal stale roster state following near-simultaneous `clear` messages. No changes to `p1`, `to`, `back`, `next`, `prev`, focus IPC, help, or status outside version label; old `clear`/`join` protocol retained for compatibility.
- **Synthetic test:** Pure-Python event-order model (100 random seeds) with 4 clients showed original average ~27.8 outgoing discovery announcements versus ~18.7 with the deferred/coalesced approach; completion was 77/100 for original vs 100/100 for model of revised approach. With 6 clients, averages ~63.6 vs ~29.0, and completeness 72/100 vs 100/100. These figures apply **only to an abstract event simulation**, not a measurement of Windower IPC or a reproduction of the freeze.
- **Runtime verification:** Live gameplay of this new version is **pending**; Lua 5.1 execution has not been performed. Source-level checks confirm unchanged `p1`/`to` handlers. **Isolated Lua 5.3 mocked callback check passed**: startup `clear`/`join` dispatch, coalesced response to three near-simultaneous joins, one delayed announcement, and callback character-identity guard. This mocked test does not load the full Windower addon or reproduce the game freeze. Do not claim that `all lr` is fixed.
- **Safe acceptance sequence:** (1) Retain last working Lua. (2) Update disk copies and unload each client individually. (3) Run `all ll switch_focus` and confirm no freeze. (4) Run `//switch status` on at least two clients and confirm the known list contains participants. (5) Run `//switch p1` from Clairvaux with Cioara leading, and optionally verify reverse direction after leadership handoff. (6) **Do not immediately retry the all-client `all lr`**, which has twice frozen the games; investigate after earlier checks and with recovery available.
- **Rollback:** Previous published feature state `e0ebd42` (colored help/status, unmodified startup discovery); previous usable manual sequence was individually unload then `all ll`. If the new discovery causes problems, restore the prior Lua from that commit.
- **Next:** Ask for outcomes for staged load, roster completeness, `p1`, and any unexpected blank client entries. Isolate simultaneous reload with controlled two-client comparisons before general use.

## Current Development Status — 2026-10-20 (colored help/status)

- **Repository / branch:** `rerorriM-Mirrorer/Windower-Addons` / `feature/switch-focus-party-leader` (working test branch, `dev` unchanged).
- **Working test baseline:** Prior test revision `6f74b13`, `//switch p1` and plain `//switch status`; new formatting revision is not yet tested in FFXI.
- **Confirmed live success:** On Clairvaux, after he joined Cioara's party, `//switch p1` successfully focused leader Cioara. User reports `//switch status` displaying status data.
- **Load sequence:** `all lr switch_focus` froze rendering and input on all clients with no `p1` invocation. Later, the user unloaded the addon individually on each client and ran `all ll switch_focus` successfully with no freeze. These observations narrow the trigger but do not establish the root cause.
- **Current code change:** Help and status now use `require('chat')`, `string.color()` and `windower.add_to_chat(0,...)`. Color palette: separators 140, headings 167, `//switch` prefix and arrows 200, syntax/labels 207, neutral values/descriptions 0. Invalid/bare commands display help. Updated testing version to `1.1.1-test`. Party-leader switching, IPC handlers, and load/unload callbacks are unchanged.
- **Static verification:** Source checks compare the formatting revision to the earlier published version and confirm retained IPC and leader switch paths. No Lua 5.1 execution or Windower runtime verification of this latest revision.
- **Acceptance:** Replace only the Lua on a chosen client, reload that client individually, run `//switch status`, `//switch help`, bare `//switch`, then `//switch p1` with Clairvaux in Cioara's party. Confirm the color, label order, and unchanged focus behavior. Avoid `all lr switch_focus` until the simultaneous reload freeze is diagnosed.
- **Next:** Collect results for chat formatting, then investigate simultaneous reload discovery in isolation rather than treating the safe `all ll` run as proof it is fixed.

## Latest observations and diagnostic revision — 2026-10-20

- **User-confirmed live:** Running `all lr switch_focus` froze rendering and input across clients *before* `//switch p1` was invoked. Cioara subsequently loaded the modified Lua individually and ran `//switch p1` while alone without a freeze.
- **Interpretation:** The revised `p1` handler is not called on load. Simultaneous reload contention and the unchanged original join/clear discovery messaging are hypotheses, not proven causes. The successful single-client test does not yet demonstrate cross-client focus switching.
- **New diagnostic:** `//switch status` prints local character/focus, party leader ID/name, known addon clients, and back target. This command sends no IPC; the existing load/reload discovery path is deliberately unchanged.
- **Safe next test:** Reload only one client at a time; inspect `//switch status` and confirm clients discovered, then try `//switch p1` with two clients already stably loaded. **Do not repeat `all lr switch_focus`** pending further investigation.
- **Verification:** Code reviewed by source comparison. Previous locally run Lua 5.4 parsing/mock tests were reported for an equivalent draft; the published source has not been retested inside the game. Lua 5.1/Windower behavior remains unverified.
- **Publication:** Testing branch only; `dev` unchanged. Existing historical observations remain below.

## Previous Development Status — 2026-10-20 (before live follow-up)

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
