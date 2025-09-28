# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

- [Added] for new features.
- [Changed] for changes in existing functionality.
- [Deprecated] for soon-to-be removed features.
- [Removed] for now removed features.
- [Fixed] for any bug fixes.
- [Security] in case of vulnerabilities.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

- [Added] for new features.
- [Changed] for changes in existing functionality.
- [Deprecated] for soon-to-be removed features.
- [Removed] for now removed features.
- [Fixed] for any bug fixes.
- [Security] in case of vulnerabilities.

## [1.11.0] - 2025-09-28

### Added
- `ReportView` registered in `views.dart` and accesible desde `MyHomeView` mediante el botón **“Informes”**.
- Gráficas en `ReportView`:
    - `PieChartWidget` (gastos por categoría) con `PiePainter`.
    - `BarsChartWidget` (gastos mensuales) con `BarsPainter`.
    - `LegendWidget` para colores por categoría y totales.
    - Render con `CustomPaint` (sin paquetes externos).
- Constantes de UI:
    - Mapa `categoryColors` para paleta consistente.
- Seed de datos para desarrollo:
    - `appManager` en `config.dart` ahora usa `AppEnvironment.dev`.
    - `demoLedgerModel`, `defaultIncomeLedger2024`, `defaultExpenseLedger2024` en `fake_service_w_s_database.dart`.
    - `FakeServiceWSDatabase` inicia con `demoLedgerModel`.

### Changed
- `OkanePageBuilder`: se elimina el título del `AppBar`; queda solo con fondo transparente.
- `LedgerRepositoryImpl`: deserialización simplificada usando `LedgerModel.fromJson` (reemplaza `LedgerModelMapper.fromAnyMap`).

### Fixed
- `BlocIncomeForm.updateBaseCategories`: ahora sugiere categorías correctas según el flag `isIncome`.


## [1.10.0] - 2025-09-24

### Added
- App-wide theming pipeline using `BlocTheme` + `ProviderTheme` + `ServiceTheme`.
- Base `ThemeData` derived from brand seed color (Material 3 `ColorScheme`) with light & dark variants.
- Centralized typography, icon theme and surface/elevation defaults in `app_theme.dart`.
- Integration with `AppManager`/root app to broadcast `ThemeData` reactively (ready for runtime switches).
- Examples in code comments (MD) showing how to consume theme in widgets (buttons, text, surfaces).

### Changed
- Replaced hard-coded colors with theme tokens across UI widgets (AppBar, Scaffold, buttons, text).
- Harmonized paddings and component states to follow the new color scheme.

### Build
- Implements dev mode and release actions.
- No third-party packages added for theming (keeps stack clean).

## [1.9.0] - 2025-09-22

### Fixed
- Store requirements and warnings wording and handling.

## [1.8.0] - 2025-09-20

### Added
- Implemented the `LocalStorage` foundation for persistence.

## [1.7.0] - 2025-06-02

### Added

* Implemented the `ProjectorWidget` to enable responsive scaling based on Figma measurements.
* Created `OkanePageBuilder` to unify responsive layout, loading indicators, error handling, and notifications.
* Finalized `SplashScreenView` for app initialization logic including loading and navigation.
* Completed the main view of the app using `MyHomeView`, now integrated with the app flow.

### Changed

* Enhanced `env.dart` to align with latest environment setup and page architecture.

## [1.6.0] - 2025-06-02

### Added

* Connected the domain `LedgerRepository` to the `LedgerWsGateway` through a new implementation in `ledger_ws_gateway_impl.dart`.
* Implemented a fully functional fake service (`fake_service_w_s_database.dart`) to simulate backend ledger operations.
* Verified complete behavior of the ledger logic including income, expense, and balance updates through integration tests.
* Introduced `AppConfig` setup with robust environment support via `env.dart` and `config.dart` to allow switching between environments (e.g., dev, prod).

### Changed

* Adjusted `my_home_view.dart` to integrate with the current state management and updated app configuration context.
* Refined test scenarios in `bloc_user_ledger_test.dart` to ensure alignment with final service integration.



## [1.5.0] - 2025-06-01

### Added

* Introduced `BlocErrorItem` to handle structured error management within the application.
* Added unit tests for `BlocErrorItem` and improved coverage for `BlocUserLedger`.
* Integrated use cases for financial operations: `add_income_use_case`, `add_expense_usecase`, `get_balance_usecase`, `can_spend_usecase`, `get_ledger_usecase`, and `listen_ledger_usecase`.
* Added `LedgerWsGateway` for websocket communication.
* Created `LedgerRepository` to abstract data access logic from services.
* Added mock implementations of all use cases to facilitate isolated testing.
* Integrated `mocktail` as a testing dependency in `pubspec.yaml`.

### Changed

* Refactored `BlocUserLedger` to align with new domain logic and error handling practices.
* Updated `pubspec.yaml` to include latest versions and `mocktail` dependency.

## [1.2.0] - 2025-03-16

### Added
- Implemented `BlocUserLedger` for managing financial movements.
- Added unit tests for `BlocUserLedger` to ensure correct behavior.
- Created `ErrorItem` to handle error messages related to financial transactions.
- Created `LedgerException` to manage exceptions in financial operations.
- Added `MoneyUtils`, which provides financial and monetary conversion utilities, including the summation of financial movements.

## [1.1.0] - 2025-01-24

### Added
- Created `CONTRIBUTING.md` for the contributors of the Okane app.

## [1.1.0] - 2025-01-24

### Added
- Created `config.dart` and `global_theme` for the initial configuration of the Okane app.
- Added Roboto font files and their usage license to the `assets` directory for use and download.
- Successfully implemented the `jocaaguraarchetype` package for general dependency injection configuration.

### Updated
- Added the `coverage` folder to `.gitignore` to prevent it from being stored in the repository.

## [1.0.1] - 2025-01-22

### Added
- Created `codeql.yml` and `validate_pr.yaml` workflow files to cover the initial actions for the Okane repository.
- Updated the `README` file to include information about the Figma design and the new approach for sharing the repository as open source.
- Added an MIT license file to allow users to copy and use the repository under the respective terms and conditions.

## [1.0.0] - 2025-01-22

### Added
- Initialized the new **Okane** repository with basic configurations to replace the outdated code previously published on the Play Store.
- Set up a public repository to continue using GitHub Actions for workflows and validations.
- Enabled collaboration with the general public through issues and pull requests.
