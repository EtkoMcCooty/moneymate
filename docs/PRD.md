# Product Requirements Document (PRD)

## MoneyMate — Personal Finance Tracker

> **Document Version:** 1.0  
> **Status:** Approved  
> **Last Updated:** 2026-10-25  

---

## 1. Executive Summary & Goals
**MoneyMate** is an offline-first cross-platform mobile application designed to replace messy, rigid personal finance spreadsheets with an organized, interactive, and customizable financial management companion.

### Core Goals:
1. **Low-Friction Transition:** Allow users to either build a personal finance tracker from scratch or seamlessly import their existing spreadsheet tracker (`.xlsx` or `.csv`).
2. **Spreadsheet Flexibility + Mobile Intelligence:** Retain the full visibility of row-by-row line items with inline editing, custom per-month income, and contextual notes while delivering automated categorization and due-date tracking.
3. **Deep Financial Analytics:** Provide interactive dashboards comparing income, household expenses, personal outflows, debt balances, and savings across flexible timeframes.
4. **Custom Pay-Cycles:** Natively support pay cycles that start on any day of the month (e.g. 15th to 14th) rather than forcing calendar-month boundaries.
5. **Absolute Privacy:** 100% offline-first local storage (SQLite/Drift). No accounts, logins, or cloud tracking required.
6. **Continuous Delivery:** In-app auto-update notifications and installations directly linked to GitHub Releases for fast vertical-slice validation.

---

## 2. User Personas

### Persona A: The Spreadsheet Exiter (Primary)
- **Profile:** Manages household finances, bills, and savings on a custom Excel/Google Sheet.
- **Pain Points:** Spreadsheets are cumbersome to read and edit on mobile, lack multi-year trend comparisons, and are vulnerable to broken cell formulas.
- **Goal:** Import their sheet once, keep their categories and due dates intact, and manage everything effortlessly from their phone.

### Persona B: The Non-Standard Pay-Cycle Earner
- **Profile:** Paid on mid-month dates (e.g. 15th, 20th, 28th).
- **Pain Points:** Mainstream budgeting apps force 1st–30th/31st reporting, which splits their monthly paycheck and expenses across two different reports.
- **Goal:** Configure their cycle offset (e.g., 15th to 14th) so all metrics align with their real cash inflow.

### Persona C: The Debt & Savings Optimizer
- **Profile:** Actively paying off credit or loans while building an emergency fund.
- **Pain Points:** Difficulty visualizing whether total debt is shrinking month-over-month.
- **Goal:** Clearly differentiate monthly debt installment payments from the remaining principal debt balance.

---

## 3. User Stories & Acceptance Criteria

### US-1: Dual Tracker Initialization (Scratch or Import)
**As a** new user,  
**I want to** start either with a blank customized tracker or import my existing `.xlsx` / `.csv` file,  
**So that** I don't have to manually re-enter years of historical spreadsheet data.

```gherkin
Scenario: Create a fresh tracker from scratch
  Given the user opens MoneyMate for the first time
  When the user selects "Create New Tracker"
  And provides a tracker name and starting pay cycle
  Then a new tracker is initialized with default categories (Income, Household, Personal, Debts, Savings)
  And default currency is set to GBP (£)

Scenario: Import an existing Excel or CSV spreadsheet
  Given the user has an existing .xlsx or .csv tracker file
  When the user selects "Import Existing Spreadsheet" and chooses the file
  Then the file parser reads the sheets, headers, and rows
  And displays a pre-import preview showing parsed categories and date ranges
```

### US-2: Smart Column & Row Matching
**As a** user importing a sheet,  
**I want to** have my rows and columns automatically recognized and categorized,  
**So that** I do not have to manually map dozens of rows.

```gherkin
Scenario: Automatic categorization of known expense categories
  Given an imported spreadsheet containing row labels like "Rent (29th)", "Council Tax (5th)", and "Wage"
  When the parser analyzes the entries
  Then "Wage" is categorized under Income
  And "Rent (29th)" is categorized under Household Expenses with due day 29
  And "Council Tax (5th)" is categorized under Household Expenses with due day 5
  And user is prompted to confirm or reassign any ambiguous rows
```

### US-3: Full Tracker View & In-Line Customization
**As a** user reviewing my finances,  
**I want to** inspect and edit line items, monthly values, categories, and per-item notes in a full tracker ledger,  
**So that** I have full control over my numbers just like in a spreadsheet.

```gherkin
Scenario: In-line editing of monthly amount and note
  Given an active tracker with an expense item "Nursery Fees"
  When the user taps on the March amount cell
  And changes the value to £250.00 and adds note "[1] Half Nursery fees this month"
  Then the updated amount and note are persisted locally in SQLite
  And total expenses and disposable income for March recalculate instantly
```

### US-4: Configurable Pay Cycles & Due Dates
**As a** user paid on the 15th,  
**I want to** define my pay cycle range (15th of previous month to 14th of current month),  
**So that** my monthly reports match my actual pay period.

```gherkin
Scenario: Configure custom pay cycle start day
  Given the user navigates to Tracker Settings
  When the user sets Pay Cycle Start Day to "15"
  Then monthly periods are displayed as "Dec 15th - Jan 14th", "Jan 15th - Feb 14th", etc.
  And transactions are bucketed into cycles based on their cycle date
```

### US-5: Debt Balance vs Monthly Payoff
**As a** user paying off debts,  
**I want to** track both my monthly payment installment and the remaining debt balance,  
**So that** I can observe my total liabilities shrinking.

```gherkin
Scenario: Record debt payment and inspect remaining balance
  Given an active debt item "Monzo Flex" with initial balance £1,200.00
  When the user logs a monthly payoff payment of £150.00
  Then the remaining balance updates to £1,050.00
  And the dashboard reflects £150.00 paid this month and £1,050.00 total debt left
```

### US-6: Interactive Financial Analytics Dashboard
**As a** user,  
**I want to** explore interactive charts showing my income, expenses, savings, and disposable income over time,  
**So that** I can see financial trends and health at a glance.

```gherkin
Scenario: View multi-period financial trends
  Given financial data across 6 or more monthly cycles
  When the user opens the Analytics Dashboard
  Then a breakdown chart shows Income vs. Total Expenses vs. Disposable Income
  And the user can filter between 3-month, 6-month, 1-year, and all-time views
  And tapping on any period reveals category-level breakdowns
```

### US-7: Settings & Currency Localization
**As a** user based in the UK,  
**I want to** have British Pound (£) as the default currency, with options to adjust formatting,  
**So that** figures are displayed accurately for my region.

```gherkin
Scenario: Default currency display
  Given a freshly initialized app
  When any currency amount is displayed
  Then it formats with the "£" symbol (e.g., £1,250.00)
  And settings allows switching symbol or decimal format if desired
```

### US-8: In-App Auto-Updates (GitHub Releases)
**As an** active user / tester,  
**I want to** be notified when a new working vertical slice or release is published to GitHub Releases and update directly in-app,  
**So that** I always run the latest improvements without manual APK sideload downloads.

```gherkin
Scenario: Check and install available update
  Given the app is running version v1.0.0
  When the app checks GitHub Releases and finds release-v1.0.1
  Then an in-app banner notifies the user of the new release with release notes
  And tapping "Update Now" downloads the APK and prompts package installer installation
```

---

## 4. Non-Functional Requirements
- **Offline-First:** All read/write operations must function without internet connectivity.
- **Data Security & Privacy:** Data is stored in a private SQLite database sandbox on the device.
- **Snappy Performance:** Queries, dashboard re-renders, and tracker calculations must execute in < 100ms.
- **Accessibility:** Minimum 48x48dp touch targets, semantic labels, and support for system font scaling.

---

## 5. Future Considerations (v2+)
- Automated bank feed integration (Open Banking / Plaid).
- Cloud backup & cross-device sync (e.g. encrypted Google Drive / iCloud sync).
- Multi-currency live conversion.
