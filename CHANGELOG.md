# Changelog

All notable changes to EFUZY should be recorded in this file.

The project follows a simple SemVer-style scheme for customer-facing releases:

- `MAJOR.MINOR.PATCH`
- bump `MAJOR` for breaking commercial release changes
- bump `MINOR` for additive feature releases
- bump `PATCH` for safe fixes and packaging corrections

## [0.4.0] - 2026-03-14

### Added
- release metadata routine `EFUZYREL`
- release tests in `EFUZYRELT`
- packaging script `scripts/package_efuzy_release.sh`
- smoke release script `scripts/release_smoke_efuzy.sh`
- release engineering guide and checklist
- VERSION file for predictable packaging

### Notes
- this release focuses on repeatable customer-ready packaging
- source archives, checksums, and release manifest generation are now standardized
