# [ADR-0002] Technology Stack and Runtime

* **Status:** Accepted
* **Date:** 2026-11-14
* **Deciders:** EtkoMcCooty, SDLC Engineering Agents

## Context & Problem Statement
MoneyMate requires a cross-platform mobile UI framework capable of fast offline financial charting, spreadsheet parsing (`.xlsx` and `.csv`), strict static type safety, and predictable release packaging for physical Android testing on a `Production` tier quality bar.

## Decision Drivers
* Cross-platform Android & iOS delivery from a single typed codebase.
* Smooth interactive charts (`fl_chart`) and decoupled Material 3 UI components (`material_ui`) on Flutter 3.50 / Dart 3.14.
* Clean feature isolation via Vertical Slice Architecture (`lib/features/<slice>/`).
* Compile-safe dependency injection and reactive state management.

## Considered Options
* Flutter 3.50 (`material_ui`, Dart 3.14) + `flutter_riverpod` + `fl_chart` + `excel`/`csv`.
* React Native / Expo with TypeScript.
* Native Kotlin + SwiftUI dual codebases.

## Decision Outcome
Chosen option: "Flutter 3.50 (`material_ui`, Dart 3.14) + `flutter_riverpod` + `fl_chart` + `excel`/`csv`", because it delivers native performance, deterministic UI rendering across devices, strong Dart 3 static analysis (`flutter analyze`), and cohesive vertical slice packaging.

### Positive Consequences
* Single codebase targets Android and iOS with consistent GBP (£) formatting and custom theme styling (`CraftDecorations`).
* Fast unit and widget test execution via `flutter test`.
* Decoupled `material_ui` aligns with Flutter 3.50+ best practices.

### Negative Consequences & Trade-offs
* Requires maintaining Android Gradle / Java 21 LTS compatibility and constraining CI JVM heap sizes (`-Xmx3072m`) on 7 GB runners.
* Code generation via `build_runner` is required after Drift schema changes.
