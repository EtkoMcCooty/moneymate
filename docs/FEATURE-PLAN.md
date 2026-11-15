> [!WARNING]
> **TEMPORARY IN-FLIGHT ARTEFACT (`docs/FEATURE-PLAN.md`):** This document is a just-in-time (JIT) technical blueprint for the active feature slice while work is in flight. Canonical project documentation (`GEMINI.md`, `docs/PRD.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`) remains locked to the current state of `main`. **Delete this file immediately upon PR merge** and run `sdlc-update-docs` to reconcile canonical documentation.

# Feature Plan: [e2e-smoke-polish] E2E Verification & Release Polish

> **Task Slug:** `[e2e-smoke-polish]`  
> **Branch:** `feat/e2e-smoke-polish`  
> **Milestone:** Milestone 6: Post-Review UX Polish & Production Readiness  
> **Status:** Ready for Merge  
> **Created:** 2026-11-15  
> **Artefact Location:** `docs/FEATURE-PLAN.md` (temporary — delete upon PR merge)  
> **Architecture Decision Records (ADRs):** None required — aligns with existing Vertical Slice Architecture (`docs/ARCHITECTURE.md`)

---

## 1. Objective & PRD Alignment

Deliver cross-slice end-to-end smoke verification, polish empty states across the Tracker and Insights screens, harden boundary/edge-case formatting guards, and verify the release Android APK build prior to closing Milestone 6 and shipping `v0.2.0`.

* **Linked User Stories:** `US-1` through `US-8` (`docs/PRD.md`) — full app flow from launch through Tracker CRUD, Insights visualisation, Settings theme/category management, and non-blocking startup updater integration.
* **Target Acceptance Scenarios (Gherkin):**
  ```gherkin
  Scenario: Cross-slice end-to-end user journey works seamlessly
    Given a fresh MoneyMateApp launch backed by Drift SQLite
    When the user adds an income item and an expense item in Monthly Tracker
    Then Disposable Income recalculates immediately and Insights displays live metrics and charts
    And switching Theme Mode in Settings updates the active app theme cleanly

  Scenario: Empty sections and malformed edge-case inputs degrade gracefully
    Given all categories are removed from the Tracker or non-finite / malformed values reach utility formatters
    When TrackerScreen or DashboardScreen renders
    Then helpful empty-state cards with plain-language navigation actions appear instead of blank space or crashes
    And CurrencyFormatter.format / PayCycleService.formatPeriodTitle fall back safely
  ```

---

## 2. Architecture & Tech Stack Alignment

* **Architecture Pattern:** Vertical Slice Architecture (`lib/features/tracker/`, `lib/features/dashboard/`, `lib/features/shell/`, `lib/core/utils/`).
* **State & Runtime Flow:** `MoneyMateApp` + `ProviderScope` with `navigationIndexProvider`, `trackerLedgerNotifierProvider`, `dashboardNotifierProvider`, `settingsNotifierProvider`, and `themeModeProvider`.
* **Verified Dependencies (`docs/RESEARCH.md`):** Flutter `3.50.0`, `material_ui: ^1.11.0`, `flutter_riverpod: ^3.5.0`, `drift: ^2.35.4` (audited `2026-11-14`, within 14-day TTL).
* **Project Conventions (`GEMINI.md`):** UK English in code comments/docs; plain, jargon-free user-facing copy (preserving *"Disposable Income"*).

---

## 3. File Matrix (Create, Modify, Delete)

| Action | File Path | Layer / Responsibility |
| :--- | :--- | :--- |
| `[M]` | `lib/core/utils/currency_formatter.dart` | Guard `format` against `NaN` / `Infinity` inputs |
| `[M]` | `lib/core/utils/pay_cycle_service.dart` | Guard `formatPeriodTitle` against malformed or out-of-range period keys |
| `[M]` | `lib/features/tracker/views/tracker_screen.dart` | Add actionable empty-sections card (`tracker_empty_sections_card`) when `sections.isEmpty` |
| `[M]` | `lib/features/dashboard/views/dashboard_screen.dart` | Add quick action buttons (`Go to Tracker`, `Import spreadsheet`) in `!state.hasData` empty state |
| `[M]` | `lib/features/shell/views/app_shell_screen.dart` | Refresh Tracker/Dashboard notifiers on tab switches so `IndexedStack` tabs stay synchronised across slices |
| `[M]` | `test/smoke_test.dart` | Upgrade from placeholder to a cross-slice app boot smoke test |
| `[C]` | `test/e2e_smoke_polish_test.dart` | Cross-slice E2E journey, empty-state polish, and edge-case validation tests |

---

## 4. Verification Plan

1. **Red Phase (`sdlc-write-tests`):** Author `test/e2e_smoke_polish_test.dart` and verify failure before implementing the polish/edge-case guards.
2. **Green Phase:** Apply minimal clean updates to `currency_formatter.dart`, `pay_cycle_service.dart`, `tracker_screen.dart`, `dashboard_screen.dart`, and `smoke_test.dart`.
3. **Full Suite & Release Build:**
   - `flutter test --concurrency=1` (100% pass)
   - `flutter analyze` (zero issues)
   - `flutter build apk --release` (succeeds cleanly)
4. **Pre-Merge Gates:**
   - [x] Red phase test confirmed failing first.
   - [x] Minimal clean code satisfies all tests.
   - [x] Full regression suite passes (100% green).
   - [x] Static analysis passes with zero warnings/errors (`flutter analyze`).
   - [x] Release APK builds cleanly (`flutter build apk --release`).
   - [x] `docs/ROADMAP.md` marked `- [x] [e2e-smoke-polish]` (`19 / 19`, `100%`) and `CHANGELOG.md` updated.
   - [ ] PR raised and audited via `sdlc-code-review`.
