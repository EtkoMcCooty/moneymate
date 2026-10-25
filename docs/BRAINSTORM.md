# Project Brainstorm & Discovery

> **Status:** Discovery Completed
> **Last Updated:** 2026-10-25

---

## 1. Problem Statement & Vision
- **Problem Statement:** Tracking personal finances using spreadsheets is disorganized, rigid, and tedious. Users struggle to visualize long-term trends, compare financial health (income, expenses, debts, investments, savings) across months/years, or adapt to non-standard pay cycles (e.g., 15th to 14th).
- **Vision:** *MoneyMate* empowers individuals to take complete control of their personal finances through a clean, customizable, and automated mobile app. It seamlessly bridges the gap between spreadsheet flexibility and mobile app intelligence by allowing users to either import existing spreadsheet trackers (with smart categorization) or build customized trackers from scratch.

## 2. Target Audience & Personas
- **Primary Audience:** Any individual wanting or needing to get their personal finances under control.
- **Key Personas:**
  - *The Spreadsheet Exiter:* Someone currently using Excel/Google Sheets with custom categories and payment dates who wants an organized, interactive mobile dashboard without losing their existing data.
  - *The Custom Pay-Cycle Earner:* Users paid on specific days of the month (e.g., 15th, 25th) rather than standard calendar month start/end.
  - *The Goal-Driven Planner:* Individuals monitoring disposable income, debt payoff progression, and savings/investment accumulation over multi-year horizons.

## 3. Scope (In-Scope vs Out-of-Scope)
### In-Scope (v1 MVP Must-Haves)
- [ ] **Dual Tracker Initialization:** Create a tracker from scratch or import from an existing spreadsheet (supporting both `.xlsx` Excel and `.csv` files).
- [ ] **Smart Column / Row Matching:** Intelligent classification of lines into Income, Expenses (Household, Personal, Other), Debts, Savings, and Investments.
- [ ] **Full Tracker View & In-Line Customization:** Dedicated, interactive tracker view where users can inspect all line items, edit amounts, add/remove categories, adjust per-month income, and attach context notes per entry.
- [ ] **Configurable Pay Cycles & Due Dates:** Support for custom billing/pay period start days (e.g., 15th to 14th) and recurring bill due dates (e.g. Rent on 29th, Council Tax on 5th).
- [ ] **Debt Payoff & Savings Progress:** Explicit tracking of monthly debt payments vs. remaining total debt balance, plus savings accumulation.
- [ ] **Interactive Financial Analytics Dashboard:** Visual comparison of income, expenses, debt reduction, savings, and disposable income across customizable time periods (monthly, yearly, custom).
- [ ] **Customizable App Settings:** Currency symbol/formatting (defaulting to **GBP / £**), category management, pay cycle definitions.
- [ ] **In-App Auto-Updates (GitHub Releases):** Built-in release check comparing app version against GitHub Releases to notify and update the Android APK seamlessly as new slices ship.

### Out-of-Scope (Future Milestones / v2)
- Multi-currency live exchange rate conversions.
- Open Banking / direct automated bank API sync (Plaid / TrueLayer).
- Multi-user joint accounts / collaborative household sharing.
- Advanced AI financial forecasting or automated stock portfolio tracking.

## 4. Tech Stack & Dependencies
- **Core Framework:** Flutter (Dart 3+)
- **Target OS:** Android & iOS (Cross-platform)
- **Local Persistence:** SQLite via `drift` (or `sqflite`) for robust relational querying, typed tables, and offline-first performance
- **File Parsing:** `excel` (.xlsx) and `csv` packages for spreadsheet ingestion
- **State Management:** Riverpod
- **Data Visualization / Charts:** `fl_chart` for interactive financial time-series charts
- **App Updates:** GitHub Releases API integration + Android package installer (`ota_update` or `open_filex`) for seamless in-app sideload updates

## 5. Target Environment & Delivery Model
- **Delivery Model Category:** Mobile App (Cross-Platform)
- **Target Platform(s):** Android & iOS
- **CI/CD & Release Strategy:** Automated GitHub Actions build producing signed/unsigned release APKs attached directly to GitHub Releases on tag or merge to `main`.
- **Local Dev / Device Execution:** `flutter run -d <device>` / Android Virtual Device / iOS Simulator
- **Auto-Update Delivery:** App queries GitHub Releases endpoint to detect new releases and prompts the user to download and install updates.

## 6. Constraints & Non-Functional Requirements
- **Privacy & Security:** 100% offline-first. Financial data never leaves the user's device. No account creation or third-party servers required.
- **Data Integrity & Importer Flexibility:** Spreadsheet importer must gracefully handle variations in column names, currency symbols (£, $, €), empty cells, and multi-month layouts like the user's template.
- **Responsiveness & Performance:** Instant chart rendering across multi-year data sets with sub-second queries.
- **Continuous Delivery:** Every milestone slice produces a testable, installable APK.

## 7. Open Questions & Risks
- **iOS Update Mechanism:** While Android supports in-app APK downloading/updating, iOS does not allow side-loaded binary updates outside TestFlight/App Store. For iOS, the update checker will inform the user of new releases or redirect to TestFlight/release notes.
