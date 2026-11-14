# Project Patch Ledger (`docs/PATCHES.md`)

> **Document Purpose:** Permanent chronological ledger of completed off-roadmap patches (`fix`, `refactor`, `style`, `docs`, `perf`, `chore`) delivered via `sdlc-patch`. Planned feature slices remain tracked in `docs/ROADMAP.md`.

---

## Summary Table

| Date | Patch Slug | Category | Summary | Key Files Modified | Commit / PR Ref |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `2026-11-03` | `fix/tracker-ordinal-and-buttons` | `fix` | Colour-coded category add-item buttons by section type and fixed `1st`/`2nd`/`3rd` due date ordinals | `lib/core/utils/pay_cycle_service.dart`, `lib/features/tracker/views/tracker_screen.dart` | `6a5bd6e` |
| `2026-11-03` | `fix/spreadsheet-import-visibility` | `fix` | Added visible import spreadsheet entry buttons in Tracker and Settings | `lib/features/importer/views/import_spreadsheet_dialog.dart`, `lib/features/settings/views/settings_screen.dart`, `lib/features/tracker/views/tracker_screen.dart` | `748b5a0` / `#12` (`a3417c6`) |
| `2026-11-03` | `fix/ci-gradle-memory` | `fix` | Optimised Gradle/Kotlin daemon JVM heap limits (`-Xmx3072m`) for 7 GB CI runners and upgraded `setup-java` to `v5` | `android/gradle.properties`, `.github/workflows/ci-cd.yml` (superseded by `ci.yml`/`cd.yml`), `GEMINI.md` | `b43d2e0` / `08fbbc6` |
| `2026-11-04` | `fix/spreadsheet-period-key-range` | `fix` | Normalised pay-cycle date span column headers (e.g. `Dec 15th - Jan 14th`) and enforced `periodKey` constraint | `lib/features/importer/services/spreadsheet_parser_service.dart`, `lib/features/importer/services/spreadsheet_import_commit_service.dart` | `88bcc9d` / `#15` (`ca1e655`) |
| `2026-11-04` | `fix/spreadsheet-multi-year-tabs` | `fix` | Detected multi-year workbook tabs and added all-sheets spreadsheet import | `lib/features/importer/models/parsed_spreadsheet.dart`, `lib/features/importer/state/import_workflow_notifier.dart`, `lib/features/importer/views/import_spreadsheet_dialog.dart` | `e47927c` / `#16` (`882d0c5`) |
| `2026-11-05` | `fix/importer-in-column-sections-and-clean-replace` | `fix` | Recognised in-column section headers, prevented duplicate items via clean replace on re-import, and fixed category mapping | `lib/features/importer/services/spreadsheet_parser_service.dart`, `lib/features/importer/services/spreadsheet_import_commit_service.dart`, `lib/features/importer/services/smart_matcher_service.dart` | `d39e622` / `#17` (`b10542c`) |
| `2026-11-06` | `style/executive-ui-craft-redesign` | `style` | Redesigned theme and screens with executive depth (`CraftDecorations`), tactile press interactions (`TactilePress`), and tabular typography | `lib/core/theme/app_theme.dart`, `lib/core/theme/craft_decorations.dart`, `lib/core/theme/tactile_press.dart`, feature views | `b6e17f5` / `#20` (`ae0dde3`) |
| `2026-11-11` | `chore/flutter-3-50-material-ui-upgrade` | `chore` | Migrated `package:flutter/material.dart` imports to standalone `package:material_ui/material_ui.dart` and upgraded AGP 9.1.1 / Gradle 9.3.1 for Flutter 3.50 compatibility | `pubspec.yaml`, `pubspec.lock`, all UI files in `lib/` and `test/`, Android Gradle config | `751d53e` / `955cf6b` / `936ebfb` (in `#21` `330c563`) |

---

## Detailed Patch Log

### `2026-11-03` — `fix/tracker-ordinal-and-buttons` (`fix`)
* **Summary:** Fixed due date ordinal formatting so `1` renders as `1st` instead of `1th`, and colour-coded category add-item buttons to match section types.
* **Key Files Modified:**
  * `lib/core/utils/pay_cycle_service.dart` — Added `formatOrdinal` helper handling `11th`–`13th` exceptions and `1st`/`2nd`/`3rd`.
  * `lib/features/tracker/views/tracker_screen.dart` — Styled add-item buttons using section colours.
  * `test/core/utils/pay_cycle_service_test.dart`, `test/features/tracker/tracker_item_crud_test.dart`, `test/features/tracker/tracker_screen_test.dart` — Added ordinal and UI colour regression tests.
* **Verification:** `flutter test` & `flutter analyze` passed. No architectural change.
* **Commit / PR Ref:** `6a5bd6e`

### `2026-11-03` — `fix/spreadsheet-import-visibility` (`fix`)
* **Summary:** Exposed clear `Import spreadsheet` action buttons in both the Monthly Tracker and Settings views and updated importer dialog UX.
* **Key Files Modified:**
  * `lib/features/importer/views/import_spreadsheet_dialog.dart` — Added dialog workflow integration.
  * `lib/features/settings/views/settings_screen.dart`, `lib/features/tracker/views/tracker_screen.dart` — Surfaced visible import buttons.
  * `test/features/settings/settings_screen_test.dart`, `test/features/tracker/tracker_screen_test.dart` — Added widget tests verifying import triggers.
* **Verification:** `flutter test` & `flutter analyze` passed. No architectural change.
* **Commit / PR Ref:** `748b5a0` / PR `#12` (`a3417c6`)

### `2026-11-03` — `fix/ci-gradle-memory` (`fix`)
* **Summary:** Bounded Gradle and Kotlin daemon JVM memory (`-Xmx3072m -XX:MaxMetaspaceSize=768m`) to eliminate Linux OOM kills on 7 GB GitHub Actions runners and documented the constraint in `GEMINI.md`.
* **Key Files Modified:**
  * `android/gradle.properties` — Configured bounded Gradle/Kotlin JVM flags.
  * `.github/workflows/ci-cd.yml` — Upgraded `actions/setup-java` to `v5` (later split into `.github/workflows/ci.yml` and `.github/workflows/cd.yml` per ADR-0004).
  * `GEMINI.md` — Recorded CI runner memory constraint rule.
* **Verification:** Verified green APK build on GitHub Actions CI. Later formalised in `docs/adr/0004-ci-cd-and-release-strategy.md`.
* **Commit / PR Ref:** `b43d2e0`, `08fbbc6`

### `2026-11-04` — `fix/spreadsheet-period-key-range` (`fix`)
* **Summary:** Fixed spreadsheet parsing errors when column headers use date range spans such as `Dec 15th - Jan 14th` and enforced normalised `YYYY-MM` period keys.
* **Key Files Modified:**
  * `lib/features/importer/services/spreadsheet_parser_service.dart` — Normalised date-span column headers into canonical period keys.
  * `lib/features/importer/services/spreadsheet_import_commit_service.dart` — Enforced period-key integrity on database commit.
  * `test/features/importer/period_header_repro_test.dart` — Added deterministic reproduction tests.
* **Verification:** `flutter test` & `flutter analyze` passed. No architectural change.
* **Commit / PR Ref:** `88bcc9d` / PR `#15` (`ca1e655`)

### `2026-11-04` — `fix/spreadsheet-multi-year-tabs` (`fix`)
* **Summary:** Enabled multi-tab workbook detection so users can review individual yearly tabs or import all years at once instead of stopping at 12 months.
* **Key Files Modified:**
  * `lib/features/importer/models/parsed_spreadsheet.dart`, `lib/features/importer/models/import_workflow_models.dart` — Added multi-sheet workbook state.
  * `lib/features/importer/services/spreadsheet_parser_service.dart`, `lib/features/importer/state/import_workflow_notifier.dart`, `lib/features/importer/views/import_spreadsheet_dialog.dart` — Added sheet selector and all-sheets commit support.
  * `test/features/importer/multi_sheet_excel_patch_test.dart` — Added multi-sheet `.xlsx` parsing and commit tests.
* **Verification:** `flutter test` & `flutter analyze` passed. No architectural change.
* **Commit / PR Ref:** `e47927c` / PR `#16` (`882d0c5`)

### `2026-11-05` — `fix/importer-in-column-sections-and-clean-replace` (`fix`)
* **Summary:** Fixed spreadsheet importer duplicating items on re-import, misclassifying in-column section headers, and mapping categories inaccurately.
* **Key Files Modified:**
  * `lib/features/importer/services/spreadsheet_parser_service.dart`, `lib/features/importer/services/smart_matcher_service.dart` — Handled in-column section headers and refined matching.
  * `lib/features/importer/services/spreadsheet_import_commit_service.dart`, `lib/features/tracker/views/tracker_screen.dart` — Enforced clean replace on re-import and consistent tracker header span display.
  * `test/features/importer/in_column_sections_and_deduplication_test.dart` — Added deduplication and section parsing tests.
* **Verification:** `flutter test` & `flutter analyze` passed. No architectural change.
* **Commit / PR Ref:** `d39e622` / PR `#17` (`b10542c`)

### `2026-11-06` — `style/executive-ui-craft-redesign` (`style`)
* **Summary:** Applied an executive UI polish featuring elevated card surfaces (`CraftDecorations`), tactile button feedback (`TactilePress`), tabular numerals, and refined dark mode contrast across screens.
* **Key Files Modified:**
  * `lib/core/theme/app_theme.dart`, `lib/core/theme/craft_decorations.dart`, `lib/core/theme/tactile_press.dart` — Introduced reusable craft theme primitives.
  * `lib/features/dashboard/views/`, `lib/features/settings/views/settings_screen.dart`, `lib/features/shell/views/app_shell_screen.dart`, `lib/features/tracker/views/tracker_screen.dart` — Applied refined layouts and visual hierarchy.
* **Verification:** `flutter test` & `flutter analyze` passed. No architectural change.
* **Commit / PR Ref:** `b6e17f5`, `f6cf64b` / PR `#20` (`ae0dde3`)

### `2026-11-11` — `chore/flutter-3-50-material-ui-upgrade` (`chore`)
* **Summary:** Migrated deprecated `package:flutter/material.dart` imports to standalone `package:material_ui/material_ui.dart` and updated Android Gradle/AGP configuration for Flutter 3.50 compatibility.
* **Key Files Modified:**
  * `pubspec.yaml`, `pubspec.lock` — Added `material_ui: ^1.11.0`.
  * `lib/` & `test/` UI source files — Switched imports to `package:material_ui/material_ui.dart`.
  * `android/` Gradle build configuration — Updated AGP 9.1.1 and Gradle wrapper.
* **Verification:** `flutter test` & `flutter analyze` passed; documented in `docs/RESEARCH.md` and `docs/adr/0002-technology-stack-and-runtime.md`.
* **Commit / PR Ref:** `751d53e`, `955cf6b`, `936ebfb` (merged in PR `#21` `330c563`)
