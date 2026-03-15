# EFUZY Authentication Model and Per-User Data Storage

## Purpose

This document explains the current EFUZY demo authentication model and how EFUZY stores data under each user.

It is based on the current MIO and EFU/FUZ routines in the repo, especially the new demo-auth and ownership logic.

This model improves isolation for the public evaluation flow.
It is **HIPAA-conscious**, but it is **not by itself a full HIPAA compliance guarantee**.
Full compliance still depends on deployment controls, encryption, backups, retention, auditing, operations, and legal agreements.

---

## 1. High-level model

The public-facing website under `FUZ*` exposes a demo page.
That page now sends the user into an EFUZY demo access flow instead of dropping them directly into the workspace.

The EFUZY application under `EFU*` and `EFUZY*` now uses a **demo account + session** model:

1. A user opens the public demo page.
2. The call-to-action points to `/efuzy/demo`.
3. The user creates an evaluation username and password, or signs in.
4. EFUZY creates a server-side session record.
5. EFUZY sets an HTTP-only cookie.
6. Protected EFUZY pages and APIs require that session.
7. Files, jobs, profiles, automation records, and generated artifacts are tied to that signed-in user.

This keeps one demo user from seeing another user’s staged files, job history, profiles, or automation records.

---

## 2. Public site flow

The public site logic lives under `FUZ*`.
The demo page text was updated to encourage evaluation login creation.

Key behavior:

- Public route: `/demo`
- Application demo route: `/efuzy/demo`
- Public CTA label: **Create evaluation login**
- Public CTA target: `CONF("fuz","demoHref")`, which now defaults to `/efuzy/demo`

Relevant routines:

- `FUZ.m`
- `FUZUI.m`
- `FUZPT.m`
- `FUZT.m`

---

## 3. Auth entry points

The demo auth layer is implemented in `EFUZYAUTH.m`.

### Public routes added

These routes are registered without prior auth because they are the entry point into the evaluation flow:

- `GET /efuzy/demo`
- `POST /efuzy/demo/signup`
- `POST /efuzy/demo/login`
- `POST /efuzy/logout`

### Route purpose

- `/efuzy/demo` renders the demo access page.
- `/efuzy/demo/signup` creates an evaluation account.
- `/efuzy/demo/login` authenticates an existing evaluation account.
- `/efuzy/logout` deletes the server-side session and clears the cookie.

---

## 4. User account model

Evaluation users are stored in the `^MIO("EFUZY","auth",...)` global tree.

### User records

A created user is stored like this:

```mumps
^MIO("EFUZY","auth","user",userId,"id")
^MIO("EFUZY","auth","user",userId,"username")
^MIO("EFUZY","auth","user",userId,"passwordSalt")
^MIO("EFUZY","auth","user",userId,"passwordHash")
^MIO("EFUZY","auth","user",userId,"status")
^MIO("EFUZY","auth","user",userId,"createdAt")
^MIO("EFUZY","auth","user",userId,"updatedAt")
```

### Username lookup index

```mumps
^MIO("EFUZY","auth","idx","username",normalizedUsername,userId)=""
```

### Username rules

The username is normalized to lowercase.
The accepted format is:

- 3 to 64 characters
- letters
- numbers
- dot (`.`)
- underscore (`_`)
- dash (`-`)

### Password model

Passwords are not stored in plain text.
The current model uses:

- a per-user salt
- an optional configured pepper
- a SHA-256 hash of `salt : pepper : password`

Important note:
This is stronger than plain text storage, but it is still a lightweight demo-account password model.
For a hardened production auth system, you would usually want a slower password hashing strategy with stronger operational controls.

---

## 5. Session model

After signup or login, EFUZY creates a server-side session.

### Session records

Sessions are stored here:

```mumps
^MIO("EFUZY","auth","session",sessionId,"id")
^MIO("EFUZY","auth","session",sessionId,"userId")
^MIO("EFUZY","auth","session",sessionId,"username")
^MIO("EFUZY","auth","session",sessionId,"createdAt")
^MIO("EFUZY","auth","session",sessionId,"lastSeenAt")
^MIO("EFUZY","auth","session",sessionId,"expiresAtEpoch")
```

### Cookie behavior

The browser receives a cookie with these important properties:

- cookie name default: `efuzy_demo_session`
- path: `/efuzy`
- `HttpOnly`
- `SameSite=Lax`
- `Max-Age` based on session TTL
- optional `Secure` flag when configured

### Session lifetime

`TTL^EFUZYAUTH` reads `CONF("efuzy","demoAuth","sessionTtlSeconds")`.
If not set or too small, it defaults to `43200` seconds, which is 12 hours.

### Session validation

Protected pages and APIs call `REQUIRE^EFUZYAUTH`.
That function:

1. reads the session cookie
2. loads the server-side session record
3. checks expiration
4. deletes expired sessions
5. populates:
   - `CTX("auth","userId")`
   - `CTX("auth","username")`
   - `CONF("efuzy","userId")`
   - `CONF("efuzy","username")`

Once that happens, the rest of the EFUZY request runs with a current user context.

---

## 6. Protected application model

Most EFUZY pages and APIs now require a valid session.

That means the workspace is no longer meant to be an anonymous shared area.
The request must first pass through `REQUIRE^EFUZYAUTH`.

### Protected areas now depend on signed-in user context

Examples include:

- workspace page
- preview page
- job detail page
- upload endpoint
- run endpoint
- retry endpoint
- profiles save/delete
- automation save/delete
- job history JSON
- file listing JSON
- export download
- artifact download

### Failure behavior

- For page requests, the user is redirected to `/efuzy/demo`.
- For API requests, EFUZY returns a `401` JSON response with:
  - `ok=0`
  - `error="auth_required"`
  - `redirect="/efuzy/demo"`

---

## 7. Ownership model

The core isolation design is **record ownership**.
Each important EFUZY object can be stamped with the signed-in user.

Ownership is applied through helper functions in `EFUZYAUTH.m`:

- `STAMPFILE`
- `STAMPJOB`
- `STAMPPROF`
- `STAMPAUTO`

These functions ultimately write:

- `ownerId`
- `ownerUsername`

and also populate per-user indexes under:

```mumps
^MIO("EFUZY","idx","user",userId,...)
```

### Owner fields by record type

#### Files

```mumps
^MIO("EFUZY","file",fileId,"ownerId")
^MIO("EFUZY","file",fileId,"ownerUsername")
```

#### Jobs

```mumps
^MIO("EFUZY","job",jobId,"ownerId")
^MIO("EFUZY","job",jobId,"ownerUsername")
```

#### Profiles

```mumps
^MIO("EFUZY","cfg","profile",profileId,"ownerId")
^MIO("EFUZY","cfg","profile",profileId,"ownerUsername")
```

#### Automation records

```mumps
^MIO("EFUZY","cfg","auto",autoId,"ownerId")
^MIO("EFUZY","cfg","auto",autoId,"ownerUsername")
```

### Ownership checks

Access control uses these helpers:

- `OWNFILE^EFUZYAUTH`
- `OWNJOB^EFUZYAUTH`
- `OWNPROF^EFUZYAUTH`
- `OWNAUTO^EFUZYAUTH`

Those helpers compare the current `CONF("efuzy","userId")` against the record’s stored `ownerId`.

If the owner does not match, EFUZY blocks the action.

---

## 8. Per-user indexes

The app also keeps per-user indexes to make filtered listing efficient.

### File index

```mumps
^MIO("EFUZY","idx","user",userId,"file",fileId)=""
```

### Job index

```mumps
^MIO("EFUZY","idx","user",userId,"job",jobId)=""
```

### Job status index

```mumps
^MIO("EFUZY","idx","user",userId,"job","status",status,jobId)=""
```

### Profile index

```mumps
^MIO("EFUZY","idx","user",userId,"profile",profileId)=""
```

### Automation index

```mumps
^MIO("EFUZY","idx","user",userId,"auto",autoId)=""
```

These indexes are used by listing helpers so the UI and APIs return only the current user’s records.

---

## 9. Filesystem storage model

The filesystem boundary is handled by `EFUZYFS.m`.

### Base root

`ROOT^EFUZYFS` works like this:

- If `CONF("efuzy","rootDir")` is blank, EFUZY uses `tmp/efuzy`
- If `CONF("efuzy","userId")` is set, EFUZY appends `/u-<userId>`

So the effective user root becomes:

```text
tmp/efuzy/u-<userId>
```

### Important subdirectories

#### Upload staging

```text
tmp/efuzy/u-<userId>/uploads/
```

#### Export output

```text
tmp/efuzy/u-<userId>/exports/
```

#### Job work area

Workbases are built in `EFUZY.m` as:

```text
tmp/efuzy/u-<userId>/work/<mode>-<jobId>-<fileId>
```

That work area is then used by the 837 preview/export job layer to write temporary and generated artifacts.

### Why this matters

This means two different demo users do not share the same upload and export folder.
That is the filesystem part of the isolation model.

---

## 10. File staging under a user

Uploads are staged by `STAGEUPLOAD^EFUZYFS`.

The flow is:

1. Parse multipart upload.
2. Generate a new `fileId`.
3. Sanitize the filename.
4. Build a user-specific path under `uploads/`.
5. Ensure the upload directory exists.
6. Stream the upload to disk.
7. Store metadata in `^MIO("EFUZY","file",fileId,...)`.
8. Stamp the file with `ownerId` and `ownerUsername`.

### Example staged file path

```text
tmp/efuzy/u-7/uploads/42-my_claim_file.837
```

### Stored file metadata

```mumps
^MIO("EFUZY","file",42,"id")=42
^MIO("EFUZY","file",42,"name")="my_claim_file.837"
^MIO("EFUZY","file",42,"path")="tmp/efuzy/u-7/uploads/42-my_claim_file.837"
^MIO("EFUZY","file",42,"contentType")=...
^MIO("EFUZY","file",42,"size")=...
^MIO("EFUZY","file",42,"createdAt")=...
^MIO("EFUZY","file",42,"ownerId")=7
^MIO("EFUZY","file",42,"ownerUsername")="alice"
```

---

## 11. Job records under a user

Jobs are created by `CREATEQ^EFUZYJOB`.

A job stores the workflow and the staged file it is tied to.
Then it is stamped to the current user.

### Core job fields

```mumps
^MIO("EFUZY","job",jobId,"id")
^MIO("EFUZY","job",jobId,"fileId")
^MIO("EFUZY","job",jobId,"workflowType")
^MIO("EFUZY","job",jobId,"runMode")
^MIO("EFUZY","job",jobId,"status")
^MIO("EFUZY","job",jobId,"warningCount")
^MIO("EFUZY","job",jobId,"errorCount")
^MIO("EFUZY","job",jobId,"createdAt")
^MIO("EFUZY","job",jobId,"ownerId")
^MIO("EFUZY","job",jobId,"ownerUsername")
```

### Status tracking

Job status is indexed globally and per user.
That supports quick listing by user and by status.

### Retry behavior

When a job is retried, the new job keeps the same owner boundary.
The retry path carries ownership forward so a user cannot use retry to cross accounts.

---

## 12. Job artifacts under a user

The X12 processing layer writes work files and downloadable outputs under the user-specific work root.

This includes items such as:

- preview data
- parse summaries
- trace files
- rebuilt EDI
- canonical exports
- profile exports
- manifests

The important design point is that the workbase comes from the current user root.
So generated artifacts stay inside that user’s subtree instead of a shared global temp path.

### Example work tree

```text
tmp/efuzy/u-7/work/
  preview-15-42-claims.csv
  preview-15-42-lines.csv
  preview-15-42-trace.txt
  export-15-42-profile.csv
  export-15-42-rebuilt.edi
```

Exact filenames vary by mode and workflow.
The security boundary is the parent user root.

---

## 13. Profiles under a user

Export profiles are stored under:

```mumps
^MIO("EFUZY","cfg","profile",profileId,...)
```

### Profile ownership

On save, EFUZY stamps the profile with the current user.
Read, update, list, and delete operations all check ownership.

### Important behavior

- If a profile belongs to another user, `GET^EFUZYCFG` returns failure.
- `LOADPROFL^EFUZYCFG` only loads the current user’s profiles when `userId` is present.
- `DELPROF^EFUZYCFG` removes the record and the matching per-user profile index entry.

### Seed profiles

EFUZY can seed default profiles.
That seeding is now user-aware.
The seeded marker can live under a user-specific seed node so one user’s defaults do not imply another user’s defaults were initialized.

---

## 14. Automation records under a user

Automation definitions are stored under:

```mumps
^MIO("EFUZY","cfg","auto",autoId,...)
```

The same ownership idea applies here.
Automation save, list, and delete are intended to stay inside the signed-in user boundary.

This matters because automation often points to workflow behavior.
Without ownership checks, one demo user could see or alter another user’s workflow definitions.

---

## 15. Listing and history behavior

The UI and JSON endpoints were updated so they list only the signed-in user’s objects when a user context exists.

### Files

`LOADFILES^EFUZYFS` and `LISTFILES^EFUZYFS` use the per-user file index.

### Jobs

`LOADRECENT^EFUWFHIST`, `LISTJSON^EFUWFHIST`, and `GETJSON^EFUWFHIST` respect job ownership.

### Profiles

`LOADPROFL^EFUZYCFG` and `GET^EFUZYCFG` respect profile ownership.

### Automation

The workspace and API helpers use the same current-user filtering model.

The result is that the signed-in user sees only their own:

- staged files
- recent jobs
- profile list
- automation list
- preview pages
- downloads
- job detail

---

## 16. Download and artifact access

Artifact download paths are guarded by ownership checks.

Before EFUZY sends a download, it verifies that the job belongs to the current user.
That blocks direct URL guessing across users.

This applies to:

- export download
- job artifact download
- job detail access
- preview page access
- retry actions

In practice, even if user A learns user B’s job ID, the server should return a not-found or blocked response instead of serving the file.

---

## 17. HIPAA-conscious aspects of the current design

The current design is helpful from a HIPAA-oriented isolation point of view because it adds:

- authenticated access before entering the app workspace
- server-side sessions
- HTTP-only cookies
- account-level ownership fields
- account-level record checks
- per-user global indexes
- per-user filesystem roots
- reduced chance of cross-user file exposure in the public demo

That is a meaningful step up from an anonymous shared demo.

---

## 18. What this does **not** guarantee by itself

Even with the current changes, this alone is not enough to claim full HIPAA compliance.

You would still need to validate and likely strengthen all of the following:

- TLS everywhere in deployment
- encryption at rest
- backup encryption and retention rules
- audit logging and tamper review
- access management and password policy
- incident response procedures
- data lifecycle and purge policy
- least-privilege admin access
- hosting and operational hardening
- formal documentation and BAAs where required
- controls around whether any real PHI is allowed in the environment at all

For the public demo, the safest message remains:

**Use synthetic or evaluation-only data. Do not upload production PHI.**

---

## 19. Example end-to-end record flow

Here is the practical flow for one demo user named `alice`.

### Step 1: account creation

EFUZY creates:

```mumps
^MIO("EFUZY","auth","user",7,...)
^MIO("EFUZY","auth","idx","username","alice",7)=""
```

### Step 2: login session

EFUZY creates:

```mumps
^MIO("EFUZY","auth","session",sid,...)
```

Browser receives:

```text
efuzy_demo_session=<sid>; Path=/efuzy; HttpOnly; SameSite=Lax; Max-Age=43200
```

### Step 3: upload file

Staged file goes to:

```text
tmp/efuzy/u-7/uploads/42-demo.837
```

Metadata becomes:

```mumps
^MIO("EFUZY","file",42,"ownerId")=7
^MIO("EFUZY","idx","user",7,"file",42)=""
```

### Step 4: create job

Job metadata becomes:

```mumps
^MIO("EFUZY","job",15,"fileId")=42
^MIO("EFUZY","job",15,"ownerId")=7
^MIO("EFUZY","idx","user",7,"job",15)=""
```

### Step 5: generated artifacts

Work products are written under:

```text
tmp/efuzy/u-7/work/
```

### Step 6: UI listing

Workspace lists only:

- files from `^MIO("EFUZY","idx","user",7,"file",...)`
- jobs from `^MIO("EFUZY","idx","user",7,"job",...)`
- profiles from `^MIO("EFUZY","idx","user",7,"profile",...)`
- automation from `^MIO("EFUZY","idx","user",7,"auto",...)`

Another user should not see those records because their request runs with a different `userId`.

---

## 20. Main routines involved

### Public site

- `FUZ.m`
- `FUZUI.m`
- `FUZPT.m`
- `FUZT.m`

### Demo auth and ownership

- `EFUZYAUTH.m`
- `EFUZYAUTHT.m`

### Workspace and route handlers

- `EFUZY.m`
- `EFUZYUI.m`
- `EFUZYROUTEPT.m`
- `EFUZYROUTEPT2.m`
- `EFUZYTESTS.m`

### Filesystem and staged uploads

- `EFUZYFS.m`

### Jobs and job history

- `EFUZYJOB.m`
- `EFUWFHIST.m`
- `EFUWFOUT.m`
- `EFUX12JOB.m`
- `EFUX12WEB.m`

### Profiles and automation

- `EFUZYCFG.m`

---

## 21. Recommended next hardening steps

If you want this model to become more production-ready, the next useful steps would be:

1. Add explicit purge jobs for expired demo users, sessions, staged uploads, and work artifacts.
2. Add stronger password hashing.
3. Add audit records for login, upload, export, delete, and download events.
4. Add configurable retention windows per record class.
5. Add encryption-at-rest guidance for the filesystem roots.
6. Add a formal admin-only support path that never breaks user ownership checks without audit logging.
7. Add tests for purge, session expiry, and unauthorized artifact download attempts.

---

## Summary

The current EFUZY demo model is now based on **evaluation accounts, server-side sessions, owner-stamped records, per-user indexes, and per-user filesystem roots**.

That means a user’s:

- login session
- staged uploads
- jobs
- exports
- profiles
- automation records
- job artifacts

are meant to live inside that user boundary both in globals and on disk.

This is the right direction for a public evaluation workflow that needs better privacy and separation.
It should still be presented as an **evaluation-safe, HIPAA-conscious design**, not as a complete compliance claim on its own.
