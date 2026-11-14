# [ADR-0003] Data Storage and State Management

* **Status:** Accepted
* **Date:** 2026-11-14
* **Deciders:** EtkoMcCooty, SDLC Engineering Agents

## Context & Problem Statement
Users manage sensitive personal income, bills, debts, and savings across multi-year horizons and non-standard pay periods (e.g. 15th to 14th). Data must remain private on-device, persist reliably offline, and compute cycle boundaries consistently across the tracker ledger, spreadsheet importer, and analytics dashboard.

## Decision Drivers
* 100% offline-first privacy with zero external account or server dependency.
* Relational integrity across trackers, categories, items, debt metadata, and period entries.
* Unambiguous mapping of mid-month pay spans (e.g. `15 Oct – 14 Nov 2026` -> `2026-10`) across manual entries and imported spreadsheets.

## Considered Options
* Unstructured JSON / shared-preferences file storage.
* Typed relational SQLite persistence via Drift (`drift` + `drift_flutter`) paired with `flutter_riverpod` and a centralised `PayCycleService` using start-month period keys (`YYYY-MM`).

## Decision Outcome
Chosen option: "Typed relational SQLite persistence via Drift paired with `flutter_riverpod` and start-month period keys (`YYYY-MM`)", because SQLite enforces relational constraints and sub-second aggregations while `PayCycleService.getPeriodKey` guarantees consistent cycle alignment across every vertical slice.

### Positive Consequences
* Compile-time checked SQL queries and typed schema migrations via `app_database.dart`.
* Consistent start-month mapping (`15 Oct – 14 Nov` -> `2026-10`) eliminates off-by-one-month drift between manual entries and spreadsheet imports.

### Negative Consequences & Trade-offs
* Requires regenerating `app_database.g.dart` via `dart run build_runner build` when Drift table schemas change.
* Spreadsheet imports replacing historical periods must execute atomically inside Drift transactions.
