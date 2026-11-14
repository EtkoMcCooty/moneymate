# [ADR-0001] Record Architecture Decisions

* **Status:** Accepted
* **Date:** 2026-11-14
* **Deciders:** EtkoMcCooty, SDLC Engineering Agents

## Context & Problem Statement
As MoneyMate evolves across feature slices and platform updates, key architectural decisions (such as runtime stack choices, local storage models, and release automation boundaries) must remain discoverable and auditable across sessions without relying on ephemeral chat memory.

## Decision Drivers
* Preserve clear technical rationale alongside canonical architecture specs (`docs/ARCHITECTURE.md`).
* Align MoneyMate with the `sdlc-skills` File-as-State Machine standard (`docs/adr/`).
* Keep historical context lightweight and concise using standard Markdown artefacts.

## Considered Options
* Store architectural rationale only inside `docs/ARCHITECTURE.md` prose.
* Maintain numbered Michael Nygard Architecture Decision Records (ADRs) in `docs/adr/` indexed by `docs/adr/README.md`.

## Decision Outcome
Chosen option: "Maintain numbered Michael Nygard Architecture Decision Records (ADRs) in `docs/adr/`", because it isolates immutable decision history from evolving current-state architecture diagrams.

### Positive Consequences
* Future feature slices and maintainers can inspect *why* an architectural boundary or trade-off exists.
* Integrates cleanly with `sdlc-build-feature`, `sdlc-patch`, and `sdlc-code-review`.

### Negative Consequences & Trade-offs
* Requires creating and indexing a new ADR whenever a genuine architectural shift occurs.
