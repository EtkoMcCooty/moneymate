# [ADR-0004] CI/CD Separation and Release Strategy

* **Status:** Accepted
* **Date:** 2026-11-14
* **Deciders:** EtkoMcCooty, SDLC Engineering Agents

## Context & Problem Statement
Previously, MoneyMate used a single monolithic `.github/workflows/ci-cd.yml` with `contents: write` permissions that ran release steps on pull requests and pushes. Under the revamped `sdlc-skills` (`v2.0.2`) architecture, Continuous Integration and Continuous Delivery must be separated with least-privilege permissions while preserving physical-device testing via the in-app updater and plain-language `CHANGELOG.md` release notes.

## Decision Drivers
* Enforce least privilege (`contents: read` for CI checks, `contents: write` only for CD release publication).
* Prevent pull requests from triggering release packaging or publishing artefacts.
* Preserve MoneyMate's 3-tier `CHANGELOG.md`-first release note extraction (including `hotfix:` filtering) for the in-app updater dialog (`lib/features/updater/`).
* Keep Android release APK builds within GitHub runner 7 GB RAM limits.

## Considered Options
* Keep a combined `.github/workflows/ci-cd.yml` workflow with conditional deploy jobs.
* Split into dedicated `.github/workflows/ci.yml` (`sdlc-ci`) and `.github/workflows/cd.yml` (`sdlc-cd`) hydrated from `docs/RESEARCH.md`.

## Decision Outcome
Chosen option: "Split into dedicated `.github/workflows/ci.yml` and `.github/workflows/cd.yml`", because it isolates PR verification from release permissions, aligns with `sdlc-ci`/`sdlc-cd`, and preserves automated APK delivery on `main` pushes and `v*.*.*` SemVer tags.

### Positive Consequences
* Pull requests run fast, read-only verification (`flutter analyze`, `flutter test`, and release APK compilation check) with PR concurrency cancellation.
* Release publication in `cd.yml` separates `build-release` from `release` via artefact handover and extracts plain-language notes from `CHANGELOG.md` first before falling back to sanitised Git commits.

### Negative Consequences & Trade-offs
* Two workflow files must stay synchronised with verified action/runtime versions in `docs/RESEARCH.md` across the 14-day audit TTL.
