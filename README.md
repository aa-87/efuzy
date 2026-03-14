# efuzy

Self-hosted, SSR-first file-processing workspace built on YottaDB and the MUMPS.IO stack.

## What efuzy is

efuzy is a production-minded workspace for structured file processing.

The current MVP is:

- X12 837 to configurable CSV

The long-term platform direction is:

- more X12 families
- more file types
- more output shapes
- job history and automation
- traceability and audit support
- deterministic rebuild and round-trip checks

The product is intentionally not a heavy SPA. It is built around:

- YottaDB / GT.M-compatible M code
- MUMPS.IO web server routines
- MIOTPL SSR templates
- Tailwind-based UI
- local `tmp` working directories under the project

## Core product goals

- stream large X12 inputs safely
- avoid MAXSTRING failures
- keep outputs deterministic
- preserve traceability
- support operator-friendly CSV exports
- make jobs, artifacts, and diagnostics easy to review

## Current MVP scope

The current working app centers on one workflow:

1. Stage an 837 file
2. Preview claims and service lines
3. Review diagnostics and trace
4. Choose export behavior and optional profile
5. Publish artifacts
6. Review job history and downloads

## Main application areas

### Workspace

The workspace is the operator entry point.

It is used to:

- upload files
- stage files
- run jobs
- see recent jobs
- open profiles
- open automation rules

### Preview

The preview page is the operational review page before publish.

It shows:

- summary counts
- claim preview rows
- service line preview rows
- warnings and errors
- trace summaries
- export plan

### Profiles

Profiles define operator-facing CSV exports.

A profile can control:

- export mode
- row source
- selected fields
- field order
- delimiter
- quote mode
- header behavior
- output naming rule

### Automation

Automation rules support folder-driven workflows.

They are designed for:

- watched input folders
- output folder targets
- profile-driven exports
- unattended repeat processing

### Jobs

Jobs are the audit and artifact view.

A completed job can expose:

- canonical claims CSV
- canonical lines CSV
- canonical manifest
- profile CSV outputs
- rebuilt X12
- trace report
- parse summary
- job manifest

## Technical architecture

### Web stack

The app builds on the MUMPS.IO stack:

- `MIOHTTP` for HTTP parsing and responses
- `MIOROUTE` for route registration and dispatch
- `MIOMW` for middleware
- `MIOAUTH`, `MIOAUTHJWT`, `MIOAUTHZ` for auth and authorization
- `MIOTPL` for SSR rendering
- Tailwind CSS for UI presentation

### EFUZY application layer

Key EFUZY app routines include:

- `EFUZY.m` – page controllers and JSON endpoints
- `EFUZYUI.m` – SSR view-model building
- `EFUZYCFG.m` – profiles and automation config
- `EFUZYFS.m` – filesystem helpers and staging paths
- `EFUZYJOB.m` – local EFUZY job tracking helpers
- `EFUZYT.m` / `EFUZYTESTS.m` – app-level tests and runners

### X12 engine layer

Key X12 routines include:

- `EFU837S` – scanner and delimiter detection
- `EFU837P` – parse foundation
- `EFU837N` – normalization
- `EFU837MODEL` – normalized model
- `EFU837VAL` / `EFU837VR` – validation
- `EFUX12DIAG` – structured diagnostics
- `EFU837MAP` – normalized export mapping
- `EFU837CSV` / `EFU837CSV2` – CSV output helpers
- `EFU837XCFG`, `EFU837XFORM`, `EFU837XP` – profile-driven export
- `EFU837CAN` – canonical package generation
- `EFU837W` / `EFU837WVAL` – deterministic write path
- `EFU837RT` / `EFU837TRACE` – compare and trace helpers
- `EFUX12JOB` – artifact-oriented publish pipeline
- `EFUX12WEB` – route-friendly service payload shaping

## HTTP surface

### SSR pages

The EFUZY app exposes SSR-first pages such as:

- `/efuzy`
- `/efuzy/workspace`
- `/efuzy/preview/:jobId`
- `/efuzy/profiles`
- `/efuzy/profiles/:id`
- `/efuzy/automation`
- `/efuzy/jobs/:id`

### JSON endpoints

The app also uses controller endpoints for staged actions such as:

- `/efuzy/api/upload`
- `/efuzy/api/run`
- `/efuzy/api/jobs`
- `/efuzy/api/job/:id`
- `/efuzy/api/profile/save`
- `/efuzy/api/profile/delete`
- `/efuzy/api/automation/save`
- `/efuzy/api/automation/delete`

### X12 service endpoints

The X12 service layer preserves these public shapes:

- `POST /x12/837/preview`
- `POST /x12/837/export`
- `GET /x12/jobs`
- `GET /x12/jobs/:id`

## Filesystem model

For security and portability, the current project standard is to keep application working files under local project directories, not `/tmp`.

Recommended structure:

```text
<install-root>/
  repo/
    routines/
    templates/
    config/
    docs/
    edi/
  tmp/
    efuzy/
      uploads/
      jobs/
      work/
      exports/
      logs/
      run/
  instance/
    env/
    logs/
    tmp/
    yottadb/
  scripts/
```

## Configuration model

The app expects a MIO config file.

By default, `MIOCONF` looks at:

- `./config/mws.conf.json`

Recommended EFUZY config values include:

- `server.listen.port`
- `server.templateDir`
- `server.static.enabled`
- `efuzy.rootDir`

Example:

```json
{
  "server": {
    "listen": { "port": 8081 },
    "templateDir": "templates",
    "static": { "enabled": 0, "root": "public", "mount": "/static" },
    "errors": { "enabled": 1, "maxEntries": 2000, "capture4xx": 1, "capture404": 1 }
  },
  "efuzy": {
    "rootDir": "tmp/efuzy"
  }
}
```

## Environment variables

A practical EFUZY shell session should have:

- `MWS_CONF`
- `ydb_dir`
- `ydb_dist`
- `ydb_gbldir`
- `ydb_routines`
- `ydb_tmp`
- `ydb_log`

A good local project model is:

- `ydb_dir=<install-root>/instance/yottadb`
- `ydb_tmp=<install-root>/instance/tmp`
- `ydb_log=<install-root>/tmp/efuzy/logs`
- `MWS_CONF=<install-root>/repo/config/mws.conf.json`

## Installation overview

This setup pack includes `scripts/install_efuzy.sh`.

The installer is designed to:

- install system prerequisites
- install YottaDB with `ydbinstall.sh`
- clone the application repository
- create the EFUZY folder layout
- generate a project environment file
- generate a default `config/mws.conf.json`
- generate helper scripts for compile and startup
- optionally compile all routines

### Example

```bash
chmod +x scripts/install_efuzy.sh
./scripts/install_efuzy.sh   --repo-url https://example.com/your/efuzy.git   --install-root "$HOME/efuzy-app"   --port 8081
```

## Starting the app

After installation:

```bash
source <install-root>/instance/env/efuzy.env
cd <install-root>/repo
bash <install-root>/scripts/compile_efuzy.sh
bash <install-root>/scripts/start_efuzy.sh
```

Then open the configured port in a browser.

## Testing

The project contains many quiet-on-success routines.

Common runners include:

- `^EFUTESTS`
- `^EFUZYTESTS`
- `^EFUPRODT`

Typical session:

```text
D ^EFUTESTS
D ^EFUZYTESTS
D ^EFUPRODT
```

## Production-readiness checklist

Before calling a deployment production-ready, verify:

- all core test suites pass
- all EFUZY and X12 suites pass
- upload, preview, publish, and download flows work in the browser
- profile edits are honored in generated exports
- all generated CSVs contain real newline bytes
- local `tmp` paths are being used consistently
- auth and route metadata are enforced where required
- logs and error capture are directed to project-owned locations
- backup and retention policy for YottaDB data is defined
- reverse proxy and TLS are configured outside the M routine web server

## Security notes

- Keep EFUZY working files under the project tree, not world-shared temp space.
- Keep YottaDB logs and temp files in project-owned directories.
- Put the MIO listener behind a real front-end reverse proxy.
- Treat uploaded X12 files and generated CSVs as sensitive operational data.
- Limit shell and filesystem access to the deployment owner group.

## Troubleshooting

### The server starts but pages do not render

Check:

- `MWS_CONF`
- `server.templateDir`
- that templates are present under `repo/templates`

### A route returns `LABELMISSING`

Usually means:

- a routine was updated but not compiled
- the route target label was renamed or removed

Recompile the changed routine and restart the process.

### CSV downloads are one long line

This means the active export path is not writing explicit newline bytes.

Re-check the compiled export routines and regenerate the job.

### Multipart form actions fail

Re-check the active `PARSEFORM^EFUZY` implementation and rerun the route tests.

## Recommended next documentation files

This setup pack also includes a dedicated user guide.

Use the user guide for:

- operator workflows
- profile usage
- troubleshooting from the browser
- day-to-day running guidance
