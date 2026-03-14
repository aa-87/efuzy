# efuzy User Guide

This guide is written for operators, billers, analysts, and admins who use the EFUZY workspace.

## 1. What EFUZY does

EFUZY is a browser-based workspace for file processing.

In the current MVP, it is used to convert X12 837 files into CSV outputs that can be reviewed, downloaded, and repeated.

The app is designed to feel like an operations workbench.

It is not a fake desktop.

Its job is to help you:

- bring files in
- review what was parsed
- choose output behavior
- publish artifacts
- inspect history later

## 2. Main pages

### Workspace

Use the Workspace page to:

- upload a file
- stage a file for processing
- see recent jobs
- jump to Profiles
- jump to Automation

### Preview

Use Preview before you publish.

This page is for checking:

- claim counts
- line counts
- warnings
- errors
- claim preview rows
- service line preview rows
- trace and export plan

### Profiles

Use Profiles to define how CSV output should look.

A profile controls:

- which columns are included
- the order of columns
- delimiter
- quote behavior
- whether a header row is written
- how the output filename is formed

### Automation

Use Automation for repeated folder-driven workflows.

Use it when files arrive in a predictable location and should be processed the same way every time.

### Jobs

Use the Jobs area to review completed work.

Open a job when you need to:

- download artifacts
- check warnings or errors
- re-check preview data
- confirm the applied profile
- inspect trace information

## 3. Standard workflow

### Step 1: Stage a file

Open the Workspace page.

Use the upload area to stage a new file.

After upload, the system creates a job and redirects to Preview.

### Step 2: Review the preview

On Preview, check:

- Does the claim count look right?
- Does the line count look right?
- Are the first claim rows sensible?
- Are there warnings that change how you should use the result?

Do not publish blindly.

### Step 3: Choose export behavior

Decide whether you want:

- canonical output only
- a profile-driven CSV
- rebuilt X12
- round-trip output
- trace output

For most operator cases, canonical output plus one profile is enough.

### Step 4: Publish

Run the job.

Once complete, open Job Detail.

### Step 5: Download artifacts

On Job Detail, download the files you need.

Common artifacts include:

- canonical claims CSV
- canonical lines CSV
- canonical manifest
- profile CSV
- rebuilt X12
- trace report

## 4. How to use Profiles

Profiles are the main way to shape operator-facing CSV output.

### Good profile design rules

- Keep names short and explicit.
- Use one profile per business use case.
- Put the most important identifiers first.
- Keep date and amount fields easy to scan.
- Avoid building one profile that tries to satisfy every user.

### Example profile patterns

#### Claim summary

Use when you need one row per claim.

Common fields:

- claim id
- claim date
- subscriber id
- patient name
- payer name
- total charge
- service line count

#### Service line detail

Use when you need one row per billed line.

Common fields:

- claim id
- line number
- procedure code
- modifier
- charge
- units
- service date

### Output naming rule

Use tokens that make the file understandable later.

Good examples:

- `{{source_base}}-claim-summary.csv`
- `{{source_base}}-service-lines.csv`
- `{{source_base}}-{{timestamp}}.csv`

Avoid vague names like:

- `output.csv`
- `result.csv`
- `final.csv`

## 5. Reading diagnostics

Warnings do not always mean the output is unusable.

Errors usually mean the job should not be trusted until reviewed.

When diagnostics appear:

1. Read the summary counts
2. Open the detailed messages
3. Check whether the issue changes business meaning
4. Decide whether to rerun with different options

## 6. Reading trace information

Trace helps explain where exported values came from.

Use it when you need to answer:

- Which segment produced this value?
- Is this value directly mapped or normalized?
- Why does this row look different than expected?

Use trace for review, not for normal quick downloads.

## 7. Job history

Use Job History to:

- reopen prior runs
- compare results over time
- download artifacts again
- verify whether a run completed or failed

A good habit is to open Job Detail instead of relying only on the job list.

## 8. Common operating patterns

### Fast daily processing

- Upload file
- Check counts and warnings
- Publish canonical + profile CSV
- Download profile output

### Validation-heavy review

- Upload file
- Review preview rows
- Enable rebuilt X12
- Enable round-trip
- Publish
- Review job detail and reports

### Repeat customer workflow

- Create one profile per customer or output contract
- Name the profile clearly
- Reuse the same profile from Preview or Automation

## 9. Troubleshooting from the UI

### I uploaded a file but see parse errors

Open Preview and Job Detail.

Check:

- warnings and errors
- whether the file is actually an 837
- whether the file is truncated
- whether the file uses an unexpected companion-guide shape

### My CSV output does not look right

Check:

- the applied profile
- selected columns
- row source
- delimiter
- quote mode
- output naming rule

Then rerun the job.

### The output file name is wrong

Check the profile naming rule.

Use explicit tokens such as:

- `{{source_base}}`
- `{{timestamp}}`
- `{{job_id}}`

### I do not see the file I expect in Job Detail

Check whether the job was run with:

- profile output enabled
- rebuilt X12 enabled
- round-trip enabled
- trace enabled

Some artifacts are optional.

## 10. Operator best practices

- Do not overwrite profiles casually.
- Keep one stable profile for each downstream consumer.
- Review warnings even when output exists.
- Keep a naming convention for profiles.
- Use job history as your operational audit trail.
- Keep staged and exported data under the project-owned local `tmp` tree.

## 11. Admin tips

- Keep the app behind a reverse proxy.
- Back up YottaDB data and project-owned logs.
- Recompile routines after source updates.
- Run `^EFUTESTS`, `^EFUZYTESTS`, and `^EFUPRODT` after upgrades.

## 12. Quick command reference

### Start the environment

```bash
source <install-root>/instance/env/efuzy.env
```

### Compile routines

```bash
bash <install-root>/scripts/compile_efuzy.sh
```

### Start the app

```bash
bash <install-root>/scripts/start_efuzy.sh
```

### Run tests

```text
D ^EFUTESTS
D ^EFUZYTESTS
D ^EFUPRODT
```

## 13. What to document inside your team

Each team should document:

- approved profiles
- naming standards
- required artifacts per workflow
- who reviews warnings and errors
- retention and cleanup policy for local exports
