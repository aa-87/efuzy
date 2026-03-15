# EFUZY Release Engineering

This guide defines the repeatable release path for a customer-ready EFUZY build.

## Goals

The release flow should be:

- repeatable
- easy to audit
- easy to hand off to a buyer
- clear about version and edition
- safe for self-hosted delivery

## Versioning scheme

EFUZY uses a simple SemVer-style format:

- `MAJOR.MINOR.PATCH`

Examples:

- `0.4.0`
- `0.4.1`
- `0.5.0`
- `1.0.0`

Guidance:

- increase `MAJOR` for intentional breaking commercial release changes
- increase `MINOR` for additive feature releases
- increase `PATCH` for safe fixes, packaging fixes, and doc fixes

The working version is stored in:

- `VERSION`
- `routines/EFUZYREL.m`

Keep both aligned until a single-source version path is introduced.

## Release inputs

A customer-ready release should include at minimum:

- source tree
- installer script
- configuration templates
- release manifest
- checksums
- changelog
- release notes
- release engineering docs

## Recommended release sequence

1. Confirm the tree is clean enough for packaging.
2. Update `VERSION`.
3. Update `routines/EFUZYREL.m` if the version changed.
4. Update `CHANGELOG.md`.
5. Compile in the target YottaDB environment.
6. Run smoke validation.
7. Build release archives.
8. Review checksums and manifest.
9. Deliver the release package.

## Compile step

If present, use:

```bash
scripts/compile_efuzy.sh
```

## Smoke validation step

Use:

```bash
scripts/release_smoke_efuzy.sh --ydb-env-file /path/to/ydb_env_set
```

Default smoke suite:

- `^EFUZYTESTS`

You can override the suite if needed:

```bash
scripts/release_smoke_efuzy.sh --ydb-env-file /path/to/ydb_env_set --suite EFUZYTESTS
```

## Packaging step

Use:

```bash
scripts/package_efuzy_release.sh --edition standard
```

Example with explicit version and output directory:

```bash
scripts/package_efuzy_release.sh --version 0.4.0 --edition professional --out-dir dist
```

Artifacts produced:

- `dist/efuzy-<version>-<edition>.tar.gz`
- `dist/efuzy-<version>-<edition>.zip` when `zip` is available
- `dist/SHA256SUMS.txt`

The staging directory will also contain:

- `RELEASE_MANIFEST.txt`
- `RELEASE_NOTES.txt`

## Delivery expectations

Before delivery, verify:

- archive opens cleanly
- checksums are present
- changelog is present
- install script is present
- config template is present
- docs are present

## Notes

This is an additive release process.

It does not replace the current MUMPS.IO stack.
It does not replace the parser stack.
It does not require a heavy SPA build step.
