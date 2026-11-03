# Project Guidelines & Rules

> This file is auto-discovered by the agent environment at workspace root to enforce project constraints, coding standards, and commands across all turns.

## 1. Project Overview & Architecture
- **Project Name:** MoneyMate
- **Tech Stack:** Flutter 3.x, Dart 3.x, Drift / SQLite (offline-first local database), Riverpod (state management), `fl_chart` (analytics and trends), `excel` / `csv` (tracker importers)
- **Delivery Model:** Mobile App (Cross-Platform Android & iOS)
- **Default Currency:** British Pound Sterling (£ / GBP)
- **Target Device / Local Run:** `flutter run -d <device>` (or `flutter run -d chrome` / `flutter run -d windows` for rapid UI testing if configured)

## 2. Coding Standards & Conventions
- Maintain documentation integrity and preserve docstrings.
- **Architecture Pattern:** Follow **Vertical Slice Architecture** (feature folders under `lib/features/<slice>/` encapsulating UI views, state/viewmodels, and domain/data logic), with shared foundation code under `lib/core/`.
- Adhere strictly to project architecture and contracts documented in `docs/ARCHITECTURE.md`.
- **Tone & Plain Language (No Jargon):** All user-facing UI labels, placeholders, tooltips, dialogs, and messages must avoid financial, accounting, and technical jargon (e.g. avoid words like *"Ledger"*, *"Historical Trends"*, *"Pay Cycle Offset"*, *"Amortization"*, or *"Disposition"*). Use simple, friendly, everyday plain language instead (e.g. use *"Monthly Tracker"* / *"Bills & Expenses"*, *"Insights"* / *"Your Progress"*, *"Payday"* / *"Pay Period"*). Note: *"Disposable Income"* is explicitly approved and encouraged to match spreadsheet conventions.
- Ensure all business logic and financial calculations (disposable income, debt balance countdown, cycle date offsets) are backed by unit tests.
- **Root-Cause Defect Elimination (No Guessing / Brute-Force):** When any automated test fails, hit-test error occurs, or defect is discovered during development, developers and agents must NEVER guess, speculate, or apply reactive trial-and-error edits. Enforce the `sdlc-bug-hunt` methodology (inspect the widget hierarchy / call-chain, verify layout constraints, prove the root cause) before applying surgical fixes.
- Keep changes atomic, clean, and tested.

## 3. Package Management & Tooling
- **Package Manager:** `flutter pub`
- Always add packages via `flutter pub add <package>` and record dependencies cleanly in `pubspec.yaml` and `pubspec.lock`.

## 4. Verification & Testing Commands
- **Install Dependencies:** `flutter pub get`
- **Lint & Static Analysis:** `flutter analyze`
- **Run Tests:** `flutter test`
- **Build Artifact (Release APK):** `flutter build apk --release`

## 5. Device Testing & In-App Auto-Updater
- **Testing Workflow:** The user tests the application directly on physical mobile devices via the in-app "Check for updates" button in Settings (`lib/features/updater/`).
- **Known Issue / Diagnostics:** The update check / install mechanism is currently reported as not working on physical devices. Priority must be given to ensuring:
  1. The in-app updater properly queries releases from `EtkoMcCooty/moneymate` and displays descriptive feedback if no releases exist or network fails.
  2. Android `<queries>` permissions in `AndroidManifest.xml` allow `url_launcher` to launch browser download URLs (`https` / `http` intents) on Android 11+.
  3. CI/CD release workflow reliably publishes release APK binaries to the public repository.
