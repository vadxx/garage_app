# AGENTS.md — Garage App

This file is a guide for AI coding agents working on the `garage_app` project. It describes the project's purpose, architecture, conventions, build/test workflow, and important implementation details.

---

## Project overview

`garage_app` is a Flutter application for tracking a personal garage of cars, their maintenance history, and daily spendings. It supports Android and Windows and is designed to be offline-first, free, ad-free, and without tracking.

- **App name**: `garage_app`
- **Package ID / namespace**: `com.vadxx.garage_app`
- **Supported platforms**: Android, Windows
- **License**: MIT (`SPDX-License-Identifier: MIT`)
- **Author**: vadxx
- **Primary language for comments/docs**: English

### Key configuration files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Root Flutter app dependencies and metadata |
| `packages/backend/pubspec.yaml` | Local Dart package with business logic, DB, models |
| `analysis_options.yaml` | Flutter lints config; excludes `packages/**` from app analysis |
| `packages/backend/analysis_options.yaml` | Backend lints config (`package:lints/recommended.yaml`) |
| `slang.yaml` | CSV-based i18n generation config |
| `build.sh` | Project bootstrap/build script (runs code-gen, icon generation) |
| `test.sh` | Format check + backend tests + app widget tests |
| `.github/workflows/ci.yml` | GitHub Actions CI pipeline |

---

## Technology stack

- **Framework**: Flutter / Dart SDK `^3.12.0`
- **State management**: `flutter_riverpod` (Notifier, FutureProvider, ProviderScope overrides in tests)
- **Routing**: `go_router`
- **Local database**: `sqlite3` (Dart FFI)
- **Data models**: `freezed` + `freezed_annotation` (code-generated immutable classes)
- **Internationalization**: `slang` / `slang_flutter`, source is `lib/i18n/strings.i18n.csv`
- **File picker**: `file_picker` for CSV import/export
- **Path utilities**: `path` / `path_provider`
- **Icons**: `flutter_launcher_icons` generated from `app_icon.png`

### Backend package dependencies

The `packages/backend` package is intentionally independent of Flutter and contains:

- `sqlite3` for the database
- `csv` for import/export
- `freezed` for immutable models
- `test` for unit tests

---

## Code organization

```text
garage_app/
├── lib/                          # Flutter UI and state
│   ├── main.dart                 # App entry point
│   ├── app_router.dart           # go_router route definitions + navigation helpers
│   ├── extensions/               # Flutter-facing extensions on backend enums
│   │   └── settings_extensions.dart
│   ├── i18n/                     # Slang generated files + CSV source + barrel export
│   │   ├── strings.i18n.csv
│   │   ├── strings.g.dart
│   │   ├── strings_en.g.dart
│   │   ├── strings_ru.g.dart
│   │   ├── strings_de.g.dart
│   │   └── i18n.dart
│   ├── pages/                    # UI pages (screens) + shared helpers
│   │   ├── home_page.dart
│   │   ├── car_detail_page.dart
│   │   ├── add_edit_car_page.dart
│   │   ├── add_edit_car_work_page.dart
│   │   ├── settings_page.dart
│   │   ├── stats_group.dart
│   │   ├── helpers.dart
│   │   └── pages.dart
│   └── providers/                # Riverpod providers and notifiers
│       ├── repositories_provider.dart
│       ├── app_settings_provider.dart
│       ├── cars_provider.dart
│       ├── car_form_provider.dart
│       ├── car_works_provider.dart
│       ├── car_work_form_provider.dart
│       ├── car_stats_provider.dart
│       ├── csv_io.dart
│       └── providers.dart
├── packages/backend/
│   └── lib/
│       ├── backend.dart          # Public API (abstract repos, models, utils)
│       ├── sqlite_backend.dart   # SQLite-backed implementations (single import point)
│       ├── src/
│       │   ├── base_repository.dart      # Abstract repository interfaces
│       │   ├── csv_import_export.dart    # CSV import/export service
│       │   ├── currency_extensions.dart  # USD ↔ currency formatting/conversion
│       │   ├── distance_extensions.dart  # km ↔ mi formatting/conversion
│       │   ├── routes.dart               # Route path constants
│       │   ├── utils/date_utils.dart     # Epoch/date helpers
│       │   ├── models/                   # Freezed data models
│       │   │   ├── models.dart
│       │   │   ├── settings.dart
│       │   │   ├── car.dart
│       │   │   ├── car_work.dart
│       │   │   └── car_stats.dart
│       │   └── sqlite_repositories/      # SQLite repository implementations
│       │       ├── sqlite_repositories.dart
│       │       ├── repository.dart
│       │       ├── settings.dart
│       │       ├── cars.dart
│       │       └── cars_works.dart
│       └── test/                 # Backend unit tests
├── test/                         # Flutter widget and integration-style tests
└── android/, windows/            # Platform-specific projects
```

### UI layer (`lib/`)

- `main.dart` bootstraps the app, initializes Riverpod, sets the device locale via `LocaleSettings.useDeviceLocale()`, and awaits the `repositoriesProvider` before showing the router.
- `app_router.dart` defines all `go_router` routes using constants from `backend/src/routes.dart` and exposes typed navigation helpers (`goToSettings`, `goToCarDetail`, `goToAddCar`, `goToEditCar`, `goToAddCarWork`, `goToEditCarWork`, `goToHome`).
- `pages/` contains one file per screen and re-exports them via `pages.dart`. Shared widgets and helpers live in `pages/helpers.dart`.
- `providers/` contains Riverpod providers and re-exports them via `providers.dart`:
  - `repositories_provider.dart` — async init of `SqliteRepositories` via `path_provider`
  - `app_settings_provider.dart` — app settings state
  - `cars_provider.dart` — car list CRUD
  - `car_works_provider.dart` — works per car (`FutureProvider.family`)
  - `car_stats_provider.dart` — computed stats per car (`FutureProvider.family`)
  - `car_form_provider.dart` / `car_work_form_provider.dart` — form state + validation
  - `csv_io.dart` — import/export actions
- `extensions/settings_extensions.dart` maps backend enums (`Language`, `Theme`) to Flutter types (`Locale`, `ThemeMode`).
- `i18n/i18n.dart` is a barrel file that exports `package:slang_flutter/slang_flutter.dart` and the generated `strings.g.dart`.

### Backend layer (`packages/backend/`)

This is the single source of truth for business logic and persistence.

- **Models** (`src/models/`): `Car`, `CarWork`, `CarStats`, `AppSettings`. All are `@freezed` immutable classes with `fromSqlRow` constructors and `toSqlRow()` extensions.
- **Repositories** (`src/base_repository.dart` defines interfaces; `src/sqlite_repositories/` implements them):
  - `SettingsRepository`
  - `CarsRepository`
  - `CarWorksRepository`
  - `Repositories` aggregate interface with `init()`, `clearAll()`, and `transaction()` support
- **SQLite**: the database is opened once in `SqliteRepositories.init(appStoragePath)` (`src/sqlite_repositories/repository.dart`) and stored as `garage.db`. Each repository creates/migrates its own tables on construction.
- **Currency**: amounts are stored in USD internally and converted to the user's chosen currency (`usd`, `rub`, `eur`) for display/input.
- **Distance**: mileage is stored in kilometers and converted to `km`/`mi` for display/input.
- **CSV**: `CsvService.exportCsv()` / `importCsv()` handle full backup/restore. `importCsv()` rejects imports into a non-empty database unless `clearExisting` is `true`; the UI prompts the user for confirmation before replacing data.

---

## Build and test commands

All commands should be run from the repository root unless noted otherwise.

### Bootstrap / code generation

```bash
sh build.sh --platforms=android,windows
```

This script:

1. Runs `flutter create . --platforms=... --empty --org com.vadxx`
2. Applies a workaround for `file_picker` / Kotlin Gradle Plugin compatibility
3. Restores certain `gradle.properties` settings Flutter resets
4. In `packages/backend`: runs `flutter pub get` and `dart run build_runner build --delete-conflicting-outputs`
5. Generates i18n: `dart run slang`
6. Generates launcher icons: `dart run flutter_launcher_icons`

### Run the app

```bash
# Windows debug
flutter run -d windows

# Android debug (replace with your device ID)
flutter run -d V2352A

# Build APK and install
flutter build apk --target-platform android-arm64
flutter install -d V2352A
```

### Formatting and analysis

```bash
dart format .
flutter analyze
```

The CI runs `dart format --set-exit-if-changed .`.

### Testing

```bash
sh test.sh
```

This runs:

1. `dart format --set-exit-if-changed .`
2. `dart test` in `packages/backend/`
3. `flutter test` in the root app

You can also run individual parts:

```bash
cd packages/backend && dart test      # backend unit tests
flutter test                          # app widget tests
```

---

## Code style guidelines

- **Formatting**: follow `dart format`. Do not commit unformatted code; CI enforces this.
- **Lints**: root app uses `package:flutter_lints/flutter.yaml`. `packages/backend` uses `package:lints/recommended.yaml`. `analysis_options.yaml` excludes `packages/**` from the app's analyzer.
- **File headers**: Dart source files are expected to start with a copyright and SPDX license header:

  ```dart
  // Copyright (c) 2026 vadxx
  // SPDX-License-Identifier: MIT
  ```

- **Imports**:
  - Import the public backend API with `package:backend/backend.dart`.
  - Import the SQLite implementation **only** in `lib/providers/repositories_provider.dart` (it is a single-import dependency).
  - Use `import 'package:backend/backend.dart' as backend;` and alias when there are name collisions (e.g., `Theme`, `Language`), or use `hide Theme` / `show ...` as appropriate.
- **Naming**: follow Dart conventions (`PascalCase` classes, `lowerCamelCase` members, `lowercase_with_underscores` files).
- **Comments**: keep comments factual and close to the code they explain. Complex SQL queries are wrapped with `// dart format off` / `// dart format on`.
- **SQL migrations**: the app uses best-effort `ALTER TABLE` migrations wrapped in `try/catch` so existing databases are upgraded automatically.

---

## Testing instructions

### Backend tests

Located in `packages/backend/test/`. They run as plain Dart tests and use `sqlite3` in-memory databases for repository tests.

Key test files:

- `cars_sqlite_repository_test.dart`
- `cars_works_sqlite_repository_test.dart`
- `settings_sqlite_repository_test.dart`
- `csv_import_export_test.dart`
- `format_currency_test.dart`
- `distance_extensions_test.dart`
- `oil_health_test.dart`
- `date_utils_test.dart`

### App/widget tests

Located in `test/`. They use `ProviderScope.overrides` to inject fake repositories so the UI can be tested without SQLite.

Fake implementations live in `test/helpers/`:

- `FakeCarsRepository`
- `FakeCarWorksRepository`
- `FakeSettingsRepository`

Key widget tests:

- `routing_test.dart` — navigation smoke test
- `car_flow_test.dart` — add/edit/delete car flow
- `car_work_flow_test.dart` — add/edit/delete work flow
- `settings_page_test.dart` — settings interactions
- `currency_display_test.dart`, `form_currency_test.dart` — currency formatting
- `car_detail_distance_test.dart`, `stats_group_test.dart` — detail/statistics UI
- `widget_test.dart` — translation key verification

When writing new widget tests, follow the existing pattern: build the app with `ProviderScope(overrides: [...])` injecting fake repositories and a `TranslationProvider`.

---

## Localization (i18n)

Translations are maintained in `lib/i18n/strings.i18n.csv` (CSV format with `key,en,ru,de`).

After editing the CSV, regenerate Dart code:

```bash
dart run slang
```

Generated files (`strings.g.dart`, `strings_en.g.dart`, `strings_ru.g.dart`, `strings_de.g.dart`) are committed. Do not edit generated files by hand.

The base locale is English (`en`). In widgets, use `context.t.<key>` to access translations.

---

## Security considerations

- The app stores all data locally in an unencrypted SQLite database (`garage.db`) under the application's documents directory.
- There is no network access by design; no analytics, ads, or backend services.
- CSV import/export reads/writes files selected by the user via the platform file picker.
- No secrets, API keys, or remote configuration files are present.
- When modifying native Android/Windows build files, avoid introducing unnecessary permissions or network capabilities; keep the app offline-first.

---

## CI / deployment

The `.github/workflows/ci.yml` pipeline runs on pushes and pull requests to `main`:

1. `setup` — format check, run `build.sh --platforms=android`, upload workspace artifact
2. `analyze-app` — `flutter analyze`
3. `analyze-backend` — `dart analyze` in `packages/backend`
4. `test-backend` — `dart test` in `packages/backend`
5. `test-app` — `flutter test`
6. `build-debug` — `flutter build apk --debug --target-platform android-arm64`
7. `build-release` — `flutter build apk --release --target-platform android-arm64`, uploads `app-release.apk` as an artifact

No automated deployment to app stores is configured. Release APKs are produced as CI artifacts.

---

## Important implementation notes

- **Single backend import rule**: `packages/backend/lib/sqlite_backend.dart` should be imported only once in the entire app, inside `lib/providers/repositories_provider.dart`. All other code uses the abstract `backend.dart` API.
- **Currency storage**: prices, costs, and car values are stored in USD. Convert with `currencyToUsd()` before saving and `formatCurrency()` / `usdToCurrency()` when displaying or seeding form fields.
- **Distance storage**: mileage is stored in km. Convert with `unitToKm()` on input and `formatDistance()` / `distanceToUnit()` for display.
- **Stats recalculation**: `CarsRepository.recalculateCarStats()` updates `totalSpent`, `lastOilChangeKm`, and `topCategory` from works. It is invoked after inserting/updating/deleting works.
- **Oil health**: `oilHealth()` in `car_stats.dart` compares current mileage to the last oil change mileage and a configurable interval (`oilIntervalKm`, default 10,000 km).
- **CSV import**: by default requires an empty database. When the database is not empty, the UI asks the user to confirm replacement; if confirmed, `CsvService.importCsv()` is called with `clearExisting: true`.
- **Android build workaround**: `build.sh` and `android/build.gradle.kts` apply the Kotlin Android plugin globally because `file_picker v11.0.2` conditionally skips it when AGP ≥ 9. This can be removed once `file_picker` migrates to built-in Kotlin support.
