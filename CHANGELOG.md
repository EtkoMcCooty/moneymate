# Changelog

All notable changes to MoneyMate are documented here in plain, user-friendly language.

## [Unreleased]
- Added Month Quick-Jump picker in the Monthly Tracker, allowing you to instantly jump across years and months, see which months have recorded transactions with data indicator dots, and quickly return to your current pay period with a single tap.
- Redesigned the interface with an executive, modern look and feel featuring physical depth, refined dark mode, tactile button feedback, and tabular numbers for financial figures.
- Added a visual income allocation progress bar on the Monthly Tracker hero card showing the exact proportion of money going to bills, debts, and savings.
- Added interactive cash flow charts showing your money in, money out, and leftover disposable income over time.
- Added quick timeframe filters to view insights across 3 months, 6 months, 1 year, and all-time.
- Added overview summary cards highlighting your monthly disposable income, money in vs. out, savings rate, and remaining debt.
- Added 'Where your money goes' category spending breakdown showing the percentage and amount spent in each category.
- You can now tap any point on the cash flow chart to inspect that month's exact numbers and category spending.
- Added financial aggregation engine computing your money in, money out, savings rate, and leftover disposable income across 3 months, 6 months, 1 year, and all-time.
- Added debt payoff calculation that tracks remaining debt balances against logged payments.
- hotfix: Fixed spreadsheet importer duplicating items on re-import, miscategorizing section headers, and updated the tracker header to always display the active month and date span.
- hotfix: Fixed spreadsheet importer only detecting 12 months when workbooks contain multiple yearly tabs; you can now review each year or import all years at once.
- hotfix: Fixed spreadsheet import error when column headers use date ranges (such as 'Dec 15th - Jan 14th').
- Added smart category and due date recognition for imported spreadsheet rows (e.g., auto-detecting rent due days and income).
- Added visible 'Import spreadsheet' button in the Monthly Tracker and Settings.
- You can now pick and import Excel (.xlsx) and CSV spreadsheets directly from your phone, review and adjust matched categories and recurring due dates before saving, and import multiple months of spending in one tap.

## [v0.1.0+30] - 2026-11-03
- You can now enter an item's amount immediately when adding it to the tracker.
- You can now delete created items from the edit dialog, by swiping left, or by long-pressing.
- hotfix: Fixed due dates showing as '1th' instead of '1st'.
- hotfix: Color-coded category add buttons to match section types.

## [v0.1.0+24] - 2026-11-02
- In-line monthly cell editing and contextual notes for tracker items.
- Live recalculation of totals and leftover disposable income.
- Custom pay period cycle configuration (e.g., 15th to 14th).
- Interactive monthly tracker grid with collapsible categories.
- Direct in-app update notifications and APK installation.
