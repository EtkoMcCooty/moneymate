# Technology & Domain Research Brief (`docs/RESEARCH.md`)

> **Last Dependency & Toolchain Audit:** 2026-11-14 (TTL: 14 days)  
> **Target Ecosystem:** Flutter 3.50.0 / Dart 3.14.0 (Cross-Platform Mobile — Android & iOS)  
> **Research Mode:** Full Discovery  

---

## 1. Executive Summary & Domain Landscape
- **Project Problem Domain:** Offline-first personal finance tracker and analytics mobile application replacing rigid spreadsheets with custom pay-cycle periods, multi-month `.xlsx`/`.csv` ingestion, debt payoff tracking, and interactive trend visualisations.
- **Key Architectural Challenges:**
  1. Deterministic custom pay-cycle date alignment (e.g. 15th of Month $M$ to 14th of Month $M+1$ mapped to starting period `YYYY-MM`) across both manual ledger entries and spreadsheet imports.
  2. Zero-latency local relational querying across multi-year transaction histories using SQLite (`drift`).
  3. Seamless over-the-air APK update checking and installation on physical Android 11+ devices via GitHub Releases (`open_filex` / `url_launcher`).

---

## 2. Target Language & Runtime Baseline (Pillar 1 — Mandatory First Step)

> [!IMPORTANT]
> Always verify the latest stable or active LTS language release **before** selecting frameworks, packages, or idioms.

| Language / Runtime | Verified Latest Stable / Active LTS | Placeholder Token | Channel & Support Window | Justification |
| :--- | :--- | :--- | :--- | :--- |
| **Flutter SDK** | `3.50.0` (`stable`) | `{{FLUTTER_VERSION}}` | Stable channel (verified 2026-11) | Bundles Dart 3.14.0, decoupled `material_ui` support, and AGP 9.1 / Gradle 9.3+ compatibility |
| **Dart SDK** | `3.14.0` | N/A (bundled with Flutter) | Stable channel | Supports pattern matching, sealed classes, records, and strict type analysis |
| **Java (JDK)** | `17` LTS (`zulu`) | `{{JAVA_VERSION}}` | Active LTS | Verified compatible with Android Gradle build toolchain on GitHub-hosted Linux runners |

---

## 3. Target Language Best Practices & Modern Idioms (Pillar 2)

### 3.1 Modern Language Syntax & Release Idioms
- **Release-Specific Features:**
  - Use standalone `package:material_ui/material_ui.dart` (`^1.11.0`) in place of deprecated `package:flutter/material.dart` imports in Flutter 3.50+.
  - Leverage Dart 3 exhaustive `switch` expressions, pattern destructuring, and immutable state models with explicit `copyWith` methods.
  - Use `Color.withValues(alpha: ...)` for fractional opacity adjustments instead of deprecated `Color.withOpacity(...)`.
- **Code Blueprint:**
  ```dart
  import 'package:material_ui/material_ui.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';

  String formatPeriodLabel((int year, int month) period) => switch (period) {
    (final y, final m) when m >= 1 && m <= 12 => '$y-${m.toString().padLeft(2, '0')}',
    _ => throw ArgumentError('Invalid period tuple: $period'),
  };
  ```

### 3.2 Strict Typing, Compiler & Linter Flags
- **Type Safety Configuration:** Enforced via `analysis_options.yaml` using `package:flutter_lints/flutter.yaml` (`^6.0.0`).
- **Formatter & Linter Standard:** `flutter analyze` (must pass with 0 errors and 0 warnings on every commit and PR).

### 3.3 Module Layout & Packaging Standards
- **Vertical Slice Alignment:** Features are isolated under `lib/features/<slice>/` (`dashboard`, `importer`, `settings`, `shell`, `tracker`, `updater`), each encapsulating its own `models/`, `services/`, `state/`, and `views/`, while shared database, theme, and utility primitives live under `lib/core/`.
- **Manifest Standard:** `pubspec.yaml` with locked transitive versions in `pubspec.lock`.

### 3.4 Prohibited Legacy Language Habits
- ❌ `import 'package:flutter/material.dart';` -> ✅ `import 'package:material_ui/material_ui.dart';` (Flutter 3.50 standalone Material package)
- ❌ `color.withOpacity(0.5)` -> ✅ `color.withValues(alpha: 0.5)`
- ❌ `WillPopScope` -> ✅ `PopScope`

---

## 4. Framework & Package Version Matrix (Pillar 3)

| Layer / Role | Recommended Package / Tool | Verified Version | Registry & Health Status | Justification |
| :--- | :--- | :--- | :--- | :--- |
| **UI Design System** | `material_ui` | `^1.11.0` | `pub.dev` — Active / Stable | Decoupled Material 3 component library for Flutter 3.50+ |
| **State Management** | `flutter_riverpod` | `^3.4.3` | `pub.dev` — Active / Stable | Compile-safe reactive state management and dependency injection |
| **Local Database (ORM)** | `drift` / `drift_flutter` | `^2.35.3` / `^0.3.1` | `pub.dev` — Active / Stable | Typed SQLite queries, reactive streams, and schema migrations |
| **SQLite Native Libs** | `sqlite3_flutter_libs` | `^0.6.0+eol` | `pub.dev` — Stable | Bundles SQLite native binaries for Android and iOS |
| **Analytics & Charts** | `fl_chart` | `^1.3.0` | `pub.dev` — Active / Stable | Interactive cash-flow line charts and category breakdown visuals |
| **Spreadsheet Parsing** | `excel` / `csv` | `^4.0.6` / `^8.0.0` | `pub.dev` — Active / Stable | Multi-sheet `.xlsx` and `.csv` financial tracker ingestion |
| **File & OS Integration** | `file_picker` / `open_filex` / `url_launcher` | `^13.3.2` / `^5.0.0` / `^6.3.3` | `pub.dev` — Active / Stable | Native file selection and Android APK installation / browser fallback |
| **Metadata & Networking** | `package_info_plus` / `http` / `intl` | `^10.2.2` / `^1.6.0` / `^0.20.3` | `pub.dev` — Active / Stable | Version comparison, GitHub Releases API client, and GBP (£) formatting |
| **Codegen & Linting** | `drift_dev` / `build_runner` / `flutter_lints` | `^2.35.2` / `^2.17.1` / `^6.0.0` | `pub.dev` — Active / Stable | Drift DAO generation and strict static analysis |

---

## 5. Deprecation Traps & Ecosystem Gotchas (Pillar 4)

### 5.1 Forbidden Deprecations & Anti-Patterns

| ❌ Forbidden / Deprecated Pattern | ✅ Current Modern Standard | Reason / Breaking Change Context |
| :--- | :--- | :--- |
| `package:flutter/material.dart` | `package:material_ui/material_ui.dart` | Deprecated in Flutter 3.50 in favour of the decoupled `material_ui` package. |
| `Color.withOpacity(double)` | `Color.withValues(alpha: double)` | Deprecated due to wide-gamut colour precision loss. |
| Mixing `upload-artifact` and `download-artifact` major versions | Pair `actions/upload-artifact@v4` with `actions/download-artifact@v4` | Incompatible artifact backend protocols across mismatched major versions cause download failures in `cd.yml`. |

### 5.2 Ecosystem Pitfalls, Build Prerequisites & Security Invariants
- **CI Runner Memory Budget (7 GB RAM Limit):** GitHub-hosted `ubuntu-latest` runners have 7 GB RAM. Always constrain Gradle in `android/gradle.properties` and CI env (`-Xmx3072m -XX:MaxMetaspaceSize=768m` and `kotlin.daemon.jvmargs=-Xmx1536m`) to prevent Linux OOM-killer exit code `137` during `assembleRelease`.
- **Android 11+ (`API 30+`) Package Visibility:** `AndroidManifest.xml` must declare `<queries>` for `https` browser intents so `url_launcher` can open fallback GitHub Release download URLs on physical devices.
- **Privacy & Security Invariant:** 100% offline-first financial storage; user financial data never leaves the local SQLite database.

---

## 6. GitHub Actions & Toolchain Placeholder Matrix (Pillar 5)

### 6.1 GitHub Actions Placeholders (11 Tokens)

| Placeholder Token | Upstream Action Repository | Verified Version / Tag | Usage Context |
| :--- | :--- | :--- | :--- |
| `{{ACTIONS_CHECKOUT_VERSION}}` | `actions/checkout` | `v4` | Repository checkout in `.github/workflows/ci.yml` & `cd.yml` |
| `{{ACTIONS_UPLOAD_ARTIFACT_VERSION}}` | `actions/upload-artifact` | `v4` | Build artefact upload (`app-release-apk`, `test-results-log`) |
| `{{ACTIONS_DOWNLOAD_ARTIFACT_VERSION}}` | `actions/download-artifact` | `v4` | Build artefact download in `cd.yml` `release` job (paired with `upload-artifact@v4`) |
| `{{ACTIONS_SETUP_NODE_VERSION}}` | `actions/setup-node` | `N/A (unused stack)` | Unused in Flutter mobile project |
| `{{ACTIONS_SETUP_PYTHON_VERSION}}` | `actions/setup-python` | `N/A (unused stack)` | Unused in Flutter mobile project |
| `{{ACTIONS_SETUP_GO_VERSION}}` | `actions/setup-go` | `N/A (unused stack)` | Unused in Flutter mobile project |
| `{{ACTIONS_SETUP_JAVA_VERSION}}` | `actions/setup-java` | `v5` | Java 17 (`zulu`) & Gradle cache setup for Android APK builds |
| `{{FLUTTER_ACTION_VERSION}}` | `subosito/flutter-action` | `v2` | Flutter SDK stable channel & pub cache setup |
| `{{RUST_TOOLCHAIN_ACTION_VERSION}}` | `dtolnay/rust-toolchain` | `N/A (unused stack)` | Unused in Flutter mobile project |
| `{{RUST_CACHE_ACTION_VERSION}}` | `Swatinem/rust-cache` | `N/A (unused stack)` | Unused in Flutter mobile project |
| `{{GH_RELEASE_ACTION_VERSION}}` | `softprops/action-gh-release` | `v2` | Automated GitHub Release creation with sideload APK asset |

### 6.2 Language & Runtime Placeholders (6 Tokens)

| Placeholder Token | Target Runtime / Toolchain | Verified Stable / LTS Version | Channel / Notes |
| :--- | :--- | :--- | :--- |
| `{{NODE_VERSION}}` | Node.js | `N/A (unused stack)` | Unused in Flutter mobile project |
| `{{PYTHON_VERSION}}` | Python | `N/A (unused stack)` | Unused in Flutter mobile project |
| `{{GO_VERSION}}` | Go | `N/A (unused stack)` | Unused in Flutter mobile project |
| `{{JAVA_VERSION}}` | Java (JDK) | `17` | Active LTS (`zulu` distribution) for Android Gradle builds |
| `{{FLUTTER_VERSION}}` | Flutter SDK | `3.50.0` (`stable`) | Latest stable channel release |
| `{{RUST_TOOLCHAIN}}` | Rust Toolchain | `N/A (unused stack)` | Unused in Flutter mobile project |

---

## 7. Handoff & Root `GEMINI.md` Synchronisation
- [x] Updated `> **Last Dependency & Toolchain Audit:** 2026-11-14 (TTL: 14 days)` in `docs/RESEARCH.md`.
- [x] Synchronised root `GEMINI.md` audit timestamp, `Project Tier: Production`, and UK English standard.
- [x] Hydrated and verified `.github/workflows/ci.yml` (`sdlc-ci`) and `.github/workflows/cd.yml` (`sdlc-cd`).
