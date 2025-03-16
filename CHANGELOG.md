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
