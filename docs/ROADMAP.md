# Project Roadmap & Execution Ledger (Vertical Slice Architecture)

> **Overall Progress:** 3 / 13 tasks completed (23%)  
> **Last Updated:** 2026-10-25  

---

## 📌 Branch, PR & Architecture Conventions
- **Vertical Slices:** Each milestone delivers end-to-end, testable user value (UI screen, business logic, and backing storage delivered together).
- **Feature Branches:** `feat/<slug>` (e.g., `feat/app-scaffold`, `feat/github-updater-slice`)
- **Commit Format:** `feat(<slug>): <short description>`
- **Granularity Rule:** Each task is an atomic deliverable suitable for a single pull request with isolated unit/integration tests.
- **Default Currency:** British Pound Sterling (£ / GBP) across all displays and formatters.
- **Early Auto-Updates:** In-app updater is implemented in Milestone 1 so physical devices auto-update across all subsequent slices.

---

## 🗺️ Milestone Schedule

### Milestone 1: App Shell, DB & Auto-Update Foundation
- [x] [app-scaffold] App Shell & Theme: Initialize Flutter project, Riverpod, AppTheme (colors, typography, GBP £ currency formatting default), and bottom navigation shell (Tracker, Dashboard, Settings).
- [x] [db-foundation] Drift SQLite Database: Set up Drift database tables (trackers, categories, items, entries, debts, settings), DAOs, and database smoke unit tests.
- [x] [github-updater-slice] In-App Auto-Updater: GitHub Releases API client comparing local vs remote semver, update notification dialog, and APK installer trigger for instant continuous delivery.

### Milestone 2: Settings & Pay Cycle Configuration Slice (End-to-End)
- [ ] [pay-cycle-engine] Pay Cycle Math Engine: Domain service calculating custom pay period date spans (e.g. 15th to 14th) and period key mappings with comprehensive unit tests.
- [ ] [settings-slice] Settings View & State: Settings screen, Riverpod notifier, and Drift integration for pay cycle start day, currency format/symbol (£ default), and category management.

### Milestone 3: Tracker Ledger & In-Line Customization Slice (Core Value - End-to-End)
- [ ] [tracker-ledger-ui] Tracker Ledger Grid: Interactive ledger displaying Income, Household, Personal, Other, Debts, Savings, and Investments with collapsible sections.
- [ ] [tracker-item-crud] Item Management & Due Dates: Create, update, archive items with optional recurring due day tags (e.g., Rent on 29th) and debt balance tracking.
- [ ] [tracker-entry-editor] In-Line Entry & Note Editor: Inline monthly cell editing, context note modals (e.g. "[1] Half Nursery fees"), and instant recalculation of totals and disposable income.

### Milestone 4: Spreadsheet Importer Slice (Excel & CSV - End-to-End)
- [ ] [importer-parsers] Spreadsheet File Parsers: File ingestion engine for `.xlsx` and `.csv` files parsing multi-month columns, headers, and values with unit tests.
- [ ] [smart-matcher] Smart Category Matcher: Heuristic rule engine automatically categorizing row labels (e.g. "Rent (29th)" -> Household, day 29; "Wage" -> Income).
- [ ] [importer-ui-flow] Importer Flow & Review UI: File picker, pre-import category preview/adjustment modal, and atomic database commit.

### Milestone 5: Interactive Analytics Dashboard Slice (End-to-End)
- [ ] [dashboard-analytics-engine] Aggregation Engine: Domain engine computing financial metrics (income, expenses, debt payoff, savings, disposable income) over 3M, 6M, 1Y, and all-time.
- [ ] [dashboard-charts-ui] Interactive Charts & Visuals: `fl_chart` trend lines, period filters, and category distribution breakdown views.

### Milestone 6: E2E Smoke & Production Polish
- [ ] [e2e-smoke-polish] E2E Verification & Release Polish: Cross-slice smoke tests, empty state polish, edge case validation, and release APK build check.
