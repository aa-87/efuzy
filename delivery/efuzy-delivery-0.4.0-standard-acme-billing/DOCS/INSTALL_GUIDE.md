# EFUZY Install Guide

## Purpose

This guide covers the repo-in-place install flow for EFUZY.

It assumes:

- the repository already exists on disk
- YottaDB is already installed
- you know the path to `ydb_env_set`

The installer does not clone the repository.

## Runtime layout

EFUZY now standardizes on a local runtime tree under `tmp/efuzy`.

Bootstrap creates:

- `tmp/efuzy/uploads`
- `tmp/efuzy/staged`
- `tmp/efuzy/jobs`
- `tmp/efuzy/exports`
- `tmp/efuzy/reports`
- `tmp/efuzy/log`
- `tmp/efuzy/run`
- `tmp/efuzy/cache`
- `tmp/efuzy/tmp`

## Required inputs

You need:

- the repo path
- a working YottaDB installation
- the `ydb_env_set` file path

## Install command

From the repo root:

```bash
bash scripts/install_efuzy.sh --ydb-env-file /path/to/ydb_env_set --port 8081
```

What this does:

- creates the runtime tree under `tmp/efuzy`
- writes `instance/env/efuzy.env`
- seeds `instance/license/efuzy.install_id`
- updates `config/mws.conf.json` with `efuzy.rootDir=tmp/efuzy`
- updates `server.listen.port` if you pass `--port`
- compiles routines unless `--skip-compile` is used
- runs a bootstrap status check

When `--license-mode` is `evaluation` or `paid`, the installer seeds the install ID first.

If the actual license file is not present yet, the installer skips the bootstrap status check so you can send the install ID to the customer fulfillment flow first.


## License mode examples

Public demo:

```bash
bash scripts/install_efuzy.sh --ydb-env-file /path/to/ydb_env_set --license-mode demo
```

Private evaluation:

```bash
bash scripts/install_efuzy.sh --ydb-env-file /path/to/ydb_env_set --license-mode evaluation
```

Paid self-hosted install:

```bash
bash scripts/install_efuzy.sh --ydb-env-file /path/to/ydb_env_set --license-mode paid
```

In `demo` mode, no local license file is required.

In `evaluation` and `paid` modes, startup requires a valid local license file at the configured `efuzy.license.filePath`.

## License paths

Default local files:

- `instance/license/efuzy.install_id`
- `instance/license/efuzy.license`

Use the install ID when issuing a customer-bound license.

## Environment file

The installer writes:

- `instance/env/efuzy.env`

That file sets:

- `EFUZY_REPO_ROOT`
- `EFUZY_RUNTIME_ROOT`
- `EFUZY_LOG_DIR`
- `MWS_CONF`
- `ydb_routines`

It also sources `ydb_env_set`.

## Compile manually

```bash
bash scripts/compile_efuzy.sh
```

Use this after routine changes.

## Start the app

```bash
bash scripts/start_efuzy.sh
```

This script runs `STARTUP^EFUZYBOOT` before `start^MIO`.

That means directory creation and runtime seeding happen before listener startup.

## Check status and readiness

Bootstrap status:

```bash
bash scripts/check_efuzy.sh --status
```

Live readiness:

```bash
bash scripts/check_efuzy.sh --ready
```

Use `--status` right after install.

Use `--ready` after the listener has started.

## Common install issues

### `ydb_env_set` not found

Pass the path explicitly:

```bash
bash scripts/install_efuzy.sh --ydb-env-file /path/to/ydb_env_set
```

### compile fails with missing routine labels

Re-run:

```bash
bash scripts/compile_efuzy.sh
```

Then fix the failing routine and compile again.

### readiness fails after startup

Run:

```bash
bash scripts/check_efuzy.sh --ready
```

Then review:

- missing directories
- route compile state
- listener pid state
- temp probe failures under `tmp/efuzy/tmp`
