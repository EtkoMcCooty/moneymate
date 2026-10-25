# MoneyMate 💷

> Personal finance tracker replacing rigid spreadsheets with interactive tracking and analytics.

MoneyMate is an offline-first cross-platform mobile application designed to replace cumbersome personal finance spreadsheets with an organized, interactive, and customizable financial management companion.

---

## 🚀 Key Features

- **Spreadsheet Flexibility + Mobile Intelligence:** Keep full row-by-row line item visibility, inline editing, custom per-month amounts, and contextual notes.
- **Custom Pay Cycles:** Support pay cycles starting on any day of the month (e.g. 15th to 14th) rather than forcing calendar-month boundaries.
- **Offline-First & Private:** 100% local SQLite storage powered by Drift. No accounts, logins, or cloud tracking required.
- **Continuous Delivery:** Automated CI/CD pipeline on GitHub Actions building release APKs on every commit and release.

---

## 🛠️ Tech Stack & Tooling

- **Framework:** Flutter 3.x / Dart 3.x
- **Database:** Drift ORM with SQLite
- **State Management:** Flutter Riverpod
- **Currency:** British Pound Sterling (£ / GBP) by default
- **Architecture:** Vertical Slice Architecture (`lib/features/<slice>/`) with shared foundation under `lib/core/`

---

## 🧪 Commands

```bash
# Install dependencies
flutter pub get

# Run static analysis and lint checks
flutter analyze

# Execute test suite
flutter test

# Build release APK
flutter build apk --release
```
