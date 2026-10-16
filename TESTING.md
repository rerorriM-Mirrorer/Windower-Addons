# TESTING.md

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
