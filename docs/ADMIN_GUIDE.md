# EFUZY Admin Guide

## Purpose

This guide covers startup, health checks, retention, and day-two operations.

## Startup flow

Recommended order:

```bash
bash scripts/install_efuzy.sh --ydb-env-file /path/to/ydb_env_set
bash scripts/start_efuzy.sh
bash scripts/check_efuzy.sh --ready
```

## Runtime helpers

### `EFUZYBOOT`

Primary entry points:

- `ENSURE^EFUZYBOOT(.CONF,.RES)`
- `STARTUP^EFUZYBOOT(.CONF,.RES)`
- `DIRS^EFUZYBOOT(.CONF,.RES)`
- `CHECKENV^EFUZYBOOT(.CONF,.RES)`

Use cases:

- create runtime directories
- verify local `tmp/efuzy` enforcement
- seed runtime globals
- verify core routine availability

### `EFUZYHEALTH`

Primary entry points:

- `STATUS^EFUZYHEALTH(.CONF,.RES)`
- `READY^EFUZYHEALTH(.CONF,.RES)`

Use `STATUS` when you want bootstrap and filesystem state.

Use `READY` when you want live readiness.

`READY` checks:

- runtime directory presence
- route compile state
- listener pid presence
- temp file create/delete probe under `tmp/efuzy/tmp`


### `EFUZYLIC`

Primary entry points:

- `STATUS^EFUZYLIC(.CONF,.RES)`
- `CHECK^EFUZYLIC(.CONF,.RES)`
- `ENSUREID^EFUZYLIC(.CONF,.RES)`

Use cases:

- inspect activation state
- create the local install ID if missing
- fail startup for invalid paid or evaluation installs

Current activation model:

- `demo` stays license-free
- `evaluation` requires a valid expiring license
- `paid` requires a valid local commercial license

### `EFUZYRET`

Primary entry point:

- `RUN^EFUZYRET(.CONF,.OPT,.RES)`

Default behavior:

- purges stale staged/upload file records
- purges stale completed and failed jobs
- preserves queued and running jobs
- preserves published jobs unless explicitly allowed

## Retention settings

Current config keys:

```json
{
  "efuzy": {
    "retention": {
      "uploadsDays": 2,
      "jobsDays": 30,
      "allowDeletePublished": 0
    }
  }
}
```

## Manual M session examples

### bootstrap

```text
D BOOTCONF^MIO(.CONF)
D STARTUP^EFUZYBOOT(.CONF,.RES)
ZW RES
```

### status

```text
D BOOTCONF^MIO(.CONF)
D STATUS^EFUZYHEALTH(.CONF,.RES)
ZW RES
```

### readiness

```text
D BOOTCONF^MIO(.CONF)
D READY^EFUZYHEALTH(.CONF,.RES)
ZW RES
```


### activation

```text
D BOOTCONF^MIO(.CONF)
D STATUS^EFUZYLIC(.CONF,.RES)
ZW RES
```

A paid install should show:

- `ok=1`
- `status="licensed"`

An evaluation install should show:

- `ok=1`
- `status="evaluation"`

A public demo should show:

- `ok=1`
- `status="demo"`

### retention

```text
D BOOTCONF^MIO(.CONF)
S OPT("uploadsDays")=1
S OPT("jobsDays")=14
D RUN^EFUZYRET(.CONF,.OPT,.RES)
ZW RES
```

## Logs

Current local log target for the helper scripts:

- `tmp/efuzy/log/startup.log`

Keep this directory writable by the deployment owner.

## Safe deployment rules

- keep `efuzy.rootDir` under local `tmp/efuzy`
- do not redirect EFUZY runtime paths to `/tmp`
- keep uploads and exports inside the repo-owned runtime tree
- keep the listener behind a reverse proxy
- treat staged files and generated artifacts as sensitive

## Upgrade notes

After pulling new source:

```bash
bash scripts/compile_efuzy.sh
bash scripts/check_efuzy.sh --status
bash scripts/start_efuzy.sh
bash scripts/check_efuzy.sh --ready
```

Use the status check before live startup when possible.
