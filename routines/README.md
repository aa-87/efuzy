# EFU837 Parser Foundation for efuzy / MUMPS.IO

## Purpose

This package is a production-minded X12 837 parser foundation for the efuzy workflow system.

It is not a toy script.
It is not a full TR3 implementation.
It is a layered, streaming-safe parser foundation that is designed to grow.

Immediate target:

- ingest an X12 837 file
- parse safely without loading the whole file into one scalar
- extract claims, service lines, subscriber and patient context, payer context, and provider context
- build normalized views that can later drive configurable CSV export
- produce diagnostics and preview statistics

Longer-term target:

- 837P
- 837I
- 837D
- 835
- 270/271
- 834
- validation profiles
- preview and diagnostics screens
- job history and replay
- partner-specific mapping profiles

---

## Source material review

This implementation was designed from the uploaded source material.

### Uploaded sample

The uploaded EDI sample is:

- `X223-837-institutional-claim.edi`

Observed facts from the sample:

- It is an **837 Institutional** style example, not 837 Professional.
- `ST03 = 005010X223A2`
- service lines use `SV2`, which is institutional service detail
- billing provider hierarchy appears with `HL*...*20`
- subscriber hierarchy appears with `HL*...*22`
- there is no separate patient `HL*...*23` in the sample
- the subscriber therefore acts as the patient in this particular file
- claim-level provider example includes `NM1*71`
- claim-level dates include `DTP*434`
- service-line dates include `DTP*472`
- claim diagnoses and conditions appear across multiple `HI` segments
- there is a secondary / other subscriber block after the claim starts

Important: the sample is useful and real-world.
It is **not** treated as the standard.
It is used to validate structure and edge cases that the parser should support.

### Uploaded companion guides

Three PDFs were uploaded:

- `837p_compguide.pdf`
- `EDI-837P-CG-005010X222A1.pdf`
- `WCMBP_837_Companion_Guide.pdf`

Important observations:

1. Two of the guides are clearly **837P** companion guides.
2. The sample is **837I**, not 837P.
3. The WCMBP guide is broader and mentions professional, institutional, and dental.
4. Companion guides are **not** full X12 TR3 replacements.
5. They are still useful for:
   - delimiter conventions
   - envelope conventions
   - general transaction interchange rules
   - payer / transport context
   - date formatting expectations

### Delimiter facts observed from uploaded material

The guides align with standard delimiter handling:

- element separator comes from ISA byte 4
- segment terminator comes from ISA byte 106
- component separator comes from ISA16
- repetition separator comes from ISA11

The uploaded sample uses:

- element separator: `*`
- segment terminator: `~`
- component separator: `:`
- repetition separator: `>`

The parser reads these dynamically from the file.
It does not hardcode them.

---

## What is implemented now

### Fully implemented in this MVP

- streaming scanner with delimiter detection from ISA
- chunk-based segment extraction
- no full-file read into one giant scalar
- envelope parsing:
  - ISA / IEA
  - GS / GE
  - ST / SE
  - BHT
- hierarchy parsing:
  - HL loop state
  - billing provider loop detection for `HL03=20`
  - subscriber loop detection for `HL03=22`
  - patient loop detection for `HL03=23`
- claim parsing:
  - CLM
  - CL1
  - DTP at claim level
  - HI composites
  - OI
- service line parsing:
  - LX
  - SV1
  - SV2
  - SV3
  - DTP at line level
- party/provider parsing:
  - submitter `NM1*41`
  - receiver `NM1*40`
  - billing provider `NM1*85`
  - subscriber / patient `NM1*IL`
  - payer `NM1*PR`
  - claim-level provider roles:
    - 71
    - 72
    - 73
    - 77
    - 82
    - DN
    - PW
- addresses:
  - N3
  - N4
- identifiers:
  - REF
- demographics:
  - DMG
  - PAT
- primary normalized export-facing views:
  - claim summary
  - service line
  - subscriber
  - provider context
- diagnostics:
  - errors
  - warnings
  - counts
  - segment counts
  - transaction counts
- quiet-on-success tests

### Partially implemented

- generic 837 loop support beyond the observed sample path
- patient loop support is present, but not deeply validated against a real uploaded 2000C patient sample
- professional and dental service detail support is scaffolded through `SV1` and `SV3`, but the uploaded real-world validation sample is institutional
- provider roles are stored generically, but only a subset is flattened into default normalized views
- REF routing is practical but not exhaustive for every implementation-guide-specific loop combination

### Scaffolded for future expansion

- payer-profile validation sets
- strict loop-order validation tables
- richer 837P professional-specific claim/service semantics
- richer 837D dental semantics
- CAS, AMT, PWK, CRC, CR1, CR2, CR3, MEA, QTY, LIN, etc.
- external CSV profile registry
- preview-only fast path that stops after N claims
- resumable / checkpoint parse jobs
- persisted job diagnostics under your workflow engine
- trading-partner-specific normalization overlays

---

## Architecture

The parser is split into layers.

### 1. Streaming scanner

Routine: `EFU837S`

Responsibilities:

- open a file safely
- detect delimiters from the ISA segment
- read the file in chunks
- buffer only enough text to emit the next segment
- emit one segment at a time without the segment terminator

Why this design:

- avoids loading the entire file into memory
- keeps hot-path logic simple
- isolates file I/O and segment boundary logic
- lets the parser operate one segment at a time

How buffering works:

1. read chunk
2. append chunk to a small rolling buffer
3. search for the segment terminator
4. emit the bytes before the first terminator as one segment
5. keep only the remainder
6. continue

This is MAXSTRING-safer than reading the whole file because the buffer grows only until the next terminator.
A single segment still needs to fit in a local scalar, but that is a practical and acceptable assumption for 837 files.
If you later need hard limits, add a max segment size guard in `EFU837S`.

### 2. Structural parser

Routine: `EFU837P`

Responsibilities:

- tokenize each segment
- update envelope state
- track hierarchy and active loop context
- build a canonical, parser-owned data structure
- attach diagnostics as issues are detected

Why this design:

- keeps business structure separate from file reading
- keeps parsing deterministic
- avoids storing all raw segments
- stores only data that is useful downstream

### 3. Validation layer

Routine: `EFU837VAL`

Responsibilities:

- post-parse validation sweep
- missing envelope checks
- transaction closure checks
- claim-level required field checks
- aggregate parse health summary

Why this design:

- incremental validation catches local issues early
- post-parse validation catches global consistency issues

### 4. Normalization layer

Routine: `EFU837N`

Responsibilities:

- flatten parsed data into stable export-facing views
- infer patient=subscriber where the file implies that pattern
- create consistent claim and line projections
- keep downstream CSV export code simple

Why this design:

- export code should not need to understand every raw loop nuance
- preview screens and configurable mapping benefit from a stable normalized model

### 5. Mapping layer

Routine: `EFU837MAP`

Responsibilities:

- expose default header sets
- expose row builders for claim, line, subscriber, and provider views

Why this design:

- lets your future CSV engine stay generic
- lets profile code ask for rows without re-walking the raw parse graph

### 6. Utility layer

Routine: `EFU837U`

Responsibilities:

- diagnostics helper
- string split helper
- composite split helper
- DTP normalization helper
- simple formatting helpers

---

## Routine inventory

### `EFU837U.m`

Utility helpers.

Public entry points:

- `INIT(ROOT,.OPT)`
- `ADDDIAG(ROOT,SEV,CODE,MSG,SEGNO,SEGID)`
- `SPLIT(STR,SEP,.OUT)`
- `COMP(STR,SEP,.OUT)`
- `DTP(QUAL,FORM,VAL,TROOT)`
- `NAME(TROOT,.TOK)`

### `EFU837S.m`

Streaming scanner.

Public entry points:

- `DETECT(PATH,.DEL,.ERR)`
- `OPEN(PATH,.SCAN,.OPT,.ERR)`
- `NEXT(.SCAN,.SEG,.EOF,.ERR)`
- `CLOSE(.SCAN)`

### `EFU837P.m`

Main parser.

Public entry points:

- `PARSE(PATH,ROOT,.OPT,.RES)`  
  parse + normalize + validate

- `PARSEONLY(PATH,ROOT,.OPT,.RES)`  
  parse only

- `PREVIEW(PATH,ROOT,.OPT,.RES)`  
  parse for stats and validation without normalization

### `EFU837VAL.m`

Validation sweep.

Public entry points:

- `POST(ROOT,.RES)`

### `EFU837N.m`

Normalization.

Public entry points:

- `BUILD(ROOT,.OPT,.RES)`

### `EFU837MAP.m`

Export-facing mapping helpers.

Public entry points:

- `HEADERS(TYPE,.OUT)`
- `ROWCLAIM(ROOT,CID,.ROW)`
- `ROWLINE(ROOT,CID,LN,.ROW)`
- `ROWSUB(ROOT,CID,.ROW)`
- `ROWPROV(ROOT,CID,.ROW)`

### `EFU837T.m`

Quiet-on-success tests.

Public entry points:

- `START`
- `ALL`

---

## Internal data model

All parser output is rooted under the caller-supplied global root.

Typical call:

```mumps
NEW ROOT,OPT,RES
SET ROOT=$NA(^TMP($J,"EFU837"))
DO PARSE^EFU837P("/path/to/file.edi",ROOT,.OPT,.RES)
```

### Meta

```text
@ROOT@("meta","file","path")
@ROOT@("meta","delim","elem")
@ROOT@("meta","delim","seg")
@ROOT@("meta","delim","comp")
@ROOT@("meta","delim","rep")
@ROOT@("meta","isa",...)
@ROOT@("meta","iea",...)
```

### Statistics

```text
@ROOT@("stats","segment_total")
@ROOT@("stats","segment","NM1")
@ROOT@("stats","transactions")
@ROOT@("stats","claims")
@ROOT@("stats","lines")
@ROOT@("stats","warning")
@ROOT@("stats","error")
```

### Diagnostics

```text
@ROOT@("diag","warning",n,"code")
@ROOT@("diag","warning",n,"msg")
@ROOT@("diag","warning",n,"segno")
@ROOT@("diag","warning",n,"segid")

@ROOT@("diag","error",n,"code")
...
```

### Canonical parse structures

```text
@ROOT@("tx",tx,"submitter",...)
@ROOT@("tx",tx,"receiver",...)
@ROOT@("tx",tx,"billing",...)

@ROOT@("sub",sid,...)
@ROOT@("patient",pid,...)

@ROOT@("claim",cid,...)
@ROOT@("claim",cid,"diag",n,...)
@ROOT@("claim",cid,"provider",role,...)
@ROOT@("claim",cid,"other_sub",n,...)
@ROOT@("claim",cid,"line",ln,...)
```

### Normalized views

```text
@ROOT@("norm","claim",cid,...)
@ROOT@("norm","line",cid,ln,...)
@ROOT@("norm","party","subscriber",cid,...)
@ROOT@("norm","party","patient",cid,...)
@ROOT@("norm","provider","billing",cid,...)
@ROOT@("norm","provider","claim",cid,role,...)
```

---

## Safety and performance decisions

### Why locals are acceptable in some places

Locals are used for:

- one segment string
- one token array
- one small composite array
- one small scanner buffer

This is safe because they are bounded by one segment or one chunk.

### Why globals are used for parse output

The parse result is global-backed because:

- large files can contain many claims
- local arrays can become memory-heavy quickly
- workflow/job/export layers need a stable handoff structure
- globals make cleanup and incremental follow-up easier

### Why the parser does not store all raw segments

Storing every raw segment would increase memory and global churn without helping CSV export or preview much.
The parser stores:

- structural metadata
- fields needed downstream
- diagnostics
- counts

This is the right default for production parsing.
If you later need a forensic mode, add an option to persist raw segments.

### How MAXSTRING risk is reduced

The parser avoids the biggest MAXSTRING trap:

- it never loads the entire file into one scalar

Instead it reads a rolling chunk and emits one segment at a time.

Remaining practical assumption:

- one segment must still fit in a local scalar

For real 837 files, that is usually reasonable.
If you want stronger safety, add:

- maximum segment length guard
- spill-to-global segment assembly for oversized segments

### State model

The parser uses a small local state object for the active path:

- current transaction
- current HL
- current subscriber
- current patient
- current claim
- current line
- current other-subscriber block
- current last-addressable entity for `N3`, `N4`, and `REF`

That state is tiny and hot-path friendly.

### Cleanup

Caller controls cleanup of the parse root.

Typical pattern:

```mumps
K ^TMP($J,"EFU837")
```

This is deliberate.
It lets downstream layers inspect the parse result after parsing finishes.

---

## Sample-based structural observations

From the uploaded institutional sample, the visible segment flow is:

```text
ISA
GS
ST
BHT
NM1*41
PER
NM1*40
HL*20
PRV
NM1*85
N3
N4
REF
HL*22
SBR
NM1*IL
N3
N4
DMG
NM1*PR
REF
CLM
DTP
CL1
HI
HI
HI
HI
HI
NM1*71
REF
SBR
OI
NM1*IL
N3
N4
NM1*PR
LX
SV2
DTP
LX
SV2
DTP
SE
GE
IEA
```

Practical design implications:

- the parser must not assume only one `HI`
- the parser must support other-subscriber information after `CLM`
- the parser must support institutional `SV2`
- the parser must tolerate missing explicit patient loop when subscriber is patient
- the parser must preserve claim and service dates separately

---

## Example usage

### Full parse

```mumps
NEW ROOT,OPT,RES
SET ROOT=$NA(^TMP($J,"EFU837"))
SET OPT("chunk")=8192
DO PARSE^EFU837P("/data/in/claim.edi",ROOT,.OPT,.RES)

WRITE !,"ok=",RES("ok")
WRITE !,"claims=",RES("claims")
WRITE !,"lines=",RES("lines")
WRITE !,"errors=",RES("errors")
WRITE !,"warnings=",RES("warnings")
```

### Preview only

```mumps
NEW ROOT,OPT,RES
SET ROOT=$NA(^TMP($J,"EFU837PRE"))
SET OPT("chunk")=4096
DO PREVIEW^EFU837P("/data/in/claim.edi",ROOT,.OPT,.RES)
```

### Build claim export rows

```mumps
NEW ROOT,OPT,RES,CID,ROW
SET ROOT=$NA(^TMP($J,"EFU837"))
DO PARSE^EFU837P("/data/in/claim.edi",ROOT,.OPT,.RES)

SET CID=0
FOR  SET CID=$ORDER(@ROOT@("norm","claim",CID)) QUIT:'CID  DO
. DO ROWCLAIM^EFU837MAP(ROOT,CID,.ROW)
. ; hand ROW() to your CSV writer
```

### Build line export rows

```mumps
NEW CID,LN,ROW
SET CID=0
FOR  SET CID=$ORDER(@ROOT@("norm","line",CID)) QUIT:'CID  DO
. SET LN=0
. FOR  SET LN=$ORDER(@ROOT@("norm","line",CID,LN)) QUIT:'LN  DO
. . DO ROWLINE^EFU837MAP(ROOT,CID,LN,.ROW)
```

---

## Normalized output example based on uploaded sample

### Claim summary example

```text
claim_id              = 756048Q
total_charge          = 89.93
from_date             = 19960911
thru_date             = 19960911
facility_code         = 14
claim_freq            = 1
subscriber_name       = DOE, JOHN T
subscriber_member_id  = 030005074A
patient_name          = DOE, JOHN T
patient_member_id     = 030005074A
primary_payer_name    = MEDICARE B
other_payer_name      = STATE TEACHERS
billing_provider_name = JONES HOSPITAL
billing_provider_npi  = 9876540809
attending_provider    = JONES, JOHN J
diag_codes            = 3669|4019|79431|A1|A2|B1|B2|A2|09
```

### Service line examples

```text
line 1
  service_kind   = SV2
  revenue_code   = 0305
  procedure_qual = HC
  procedure_code = 85025
  charge         = 13.39
  uom            = UN
  qty            = 1
  svc_date       = 19960911

line 2
  service_kind   = SV2
  revenue_code   = 0730
  procedure_qual = HC
  procedure_code = 93005
  charge         = 76.54
  uom            = UN
  qty            = 3
  svc_date       = 19960911
```

Note: the normalized diagnosis projection is deliberately simple in this MVP.
It preserves codes without trying to fully semantically classify every HI qualifier family.
That deeper semantic classification belongs in later normalization profiles.

---

## Diagnostics example

Possible diagnostics emitted now:

- `open_failed`
- `missing_isa`
- `missing_iea`
- `missing_se`
- `isa_iea_mismatch`
- `gs_ge_mismatch`
- `st_se_mismatch`
- `se_count_mismatch`
- `lx_without_claim`
- `sv_without_lx`
- `hi_without_claim`
- `dtp_orphan`
- `orphan_ref`
- `claim_id_missing`
- `no_claims`

Each diagnostic is stored with:

- severity
- code
- message
- segment number
- segment id

This is good input for:

- preview screens
- job logs
- workflow execution summaries
- support diagnostics

---

## Extension guide

### Add a new segment

1. add a branch in `ONSEG^EFU837P`
2. create a handler label like `HAMT`
3. route the data into canonical parse structures
4. update normalization if needed
5. add tests

### Add a new provider role

1. extend the `NM1` role branch in `HNM1^EFU837P`
2. persist under `@ROOT@("claim",cid,"provider",role,...)`
3. optionally expose it in `EFU837N` and `EFU837MAP`

### Add payer-specific validation

1. keep base parser generic
2. add profile-specific checks in a separate validation routine, for example:
   - `EFU837VALCMS`
   - `EFU837VALUHC`
   - `EFU837VALWCM`
3. run those after `POST^EFU837VAL`

### Add 837P support more deeply

The parser already supports:

- envelope
- subscriber/patient
- claim
- service line shell
- `SV1`

To expand 837P well:

- strengthen loop order validation for X222
- add professional-service semantic parsing
- add `2310B`, `2310C`, etc. projections as needed
- add `PWK`, `CRC`, `CR1`, `CR3`, `QTY`, `MEA`, `LIN`, `CTP` where relevant
- validate against real 837P samples

### Add 837D support

The parser already supports:

- generic envelope handling
- generic party handling
- generic claim and line handling
- `SV3` shell

To expand 837D well:

- add dental loop semantics
- add tooth/surface detail normalization
- validate with real 837D samples

---

## Acceptance criteria

This package should be considered working for the current MVP when the following are true:

1. delimiter detection succeeds from the ISA segment
2. scanner can parse files using small chunk sizes without changing output
3. one institutional sample parses into:
   - 1 transaction
   - 1 claim
   - 2 service lines
4. envelope metadata is extracted
5. claim header values are extracted
6. claim diagnosis values are extracted
7. service line procedure and revenue values are extracted
8. subscriber and payer names are extracted
9. billing provider is extracted
10. normalized claim and line rows are produced
11. malformed cases emit deterministic errors/warnings
12. tests remain quiet on success

---

## What to test next with additional files

You asked specifically what to test next.
These are the highest-value next files to add:

1. real 837P sample with `SV1`
2. real 837I file with:
   - multiple claims
   - multiple subscriber loops
   - explicit patient `HL*23`
3. 837 file with multiple transactions in one interchange
4. file with CRLF after segment terminators
5. file using non-default delimiters
6. file with large numbers of service lines
7. file with secondary and tertiary payer loops
8. malformed file with broken envelope counts
9. file with very long `HI` or `REF` usage
10. real partner samples from your target billing workflows

---

## Recommended next implementation steps

1. add a strict loop profile table for X223 and X222
2. add a configurable segment-size guard in the scanner
3. add stop-after-N-claims preview mode
4. add partner-profile validation hooks
5. add a streaming CSV writer layer on top of `EFU837MAP`
6. add richer claim/provider role normalization
7. add 837P validation samples
8. add 837D validation samples
9. add persistence hooks for efuzy job history
10. add a diagnostics summary formatter for UI preview screens

---

## New in this revision

### 1. Transaction-only sample support

The parser now supports two framing modes.

- `interchange`
  - file starts with `ISA`
  - delimiters are read from the fixed ISA positions
  - missing `IEA` remains a real error
- `transaction`
  - file starts with `ST`
  - delimiters are inferred heuristically
  - missing `ISA` and `IEA` become warnings, not hard errors

This matters because several files in `Examples 1/edi_files/837` are transaction-only examples.
They are valid and useful test material.
They should not fail only because an outer interchange wrapper is absent.

### 2. CSV export layer

A new routine is included:

- `EFU837CSV`

Public entry points:

- `EXPORT^EFU837CSV(PATH,OUTBASE,ROOT,.OPT,.RES)`
- `EXPORTDIR^EFU837CSV(INDIR,OUTDIR,WORKROOT,.OPT,.RES)`

Generated files for each input:

- `<outbase>.csv`
  - combined claim + line rows
  - one row per service line
  - claim values repeat across lines
- `<outbase>-Claims.csv`
  - one row per claim
- `<outbase>-Lines.csv`
  - one row per line
- `<outbase>-Subscribers.csv`
  - one row per claim / subscriber view
- `<outbase>-Providers.csv`
  - one row per claim / provider context view

### 3. External example suites

`EFU837T` now supports two layers of external validation.

- Example 1 benchmark suite
  - parses every 837 file from `Examples 1/edi_files/837`
  - exports CSV for each file
  - compares produced row counts against the provided benchmark CSV files when present
  - uses embedded expected counts for files that only had benchmark JSON
- Example 2 coverage suite
  - parses every professional, institutional, and dental sample from `Examples 2`
  - validates transaction kind, guide, claim count, and line count
  - exports combined CSV and validates row count against parsed service line count

Run the full suite like this:

```mumps
D ALL^EFU837T("/path/to/extracted/files")
```

Where the extracted folder contains:

- `Examples 1/`
- `Examples 2/`

### 4. Practical framing and delimiter tradeoffs

For `ISA`-framed files, delimiter handling remains strict.
That is the production path.

For `ST`-first files, delimiter handling is best-effort and intentionally conservative.
It assumes:

- the element separator can be inferred from the first segment
- the segment terminator is the first of `~`, line-feed, or carriage-return seen early in the file
- the component separator defaults to `:` unless an early segment strongly suggests otherwise
- the repetition separator defaults to `^` in transaction-only mode

This is enough for the uploaded sample sets.
It is also a sane tradeoff for documentation examples and trimmed transaction fixtures.

---

## Example-driven validation scope

This revision was explicitly tuned against the uploaded example pack.

### Example 1

Used as the primary benchmark source for:

- transaction-only parsing tolerance
- output row counts
- batch CSV generation behavior
- coverage of older guides such as `X298` and `X299`

### Example 2

Used as the primary structural coverage source for:

- 837P / `X222A1`
- 837I / `X223A2`
- 837D / `X224A2`
- multiple scenario-specific line mixes
- multi-claim institutional example coverage

### What the tests prove now

- the parser can ingest ISA-framed and ST-first files
- the parser identifies 837P, 837I, and 837D correctly for the uploaded samples
- claim and service-line counts are stable across the uploaded examples
- the CSV exporter writes deterministic row counts
- Example 1 benchmark CSV row counts are matched where benchmark CSV exists

### What the tests do not claim

- full TR3 semantic correctness for every optional loop
- full payer-profile compliance
- complete REF / AMT / PWK / CAS / CRC coverage
- exact column-by-column parity with third-party benchmark converters

That work remains future expansion.
The current goal is a strong parser and export foundation with real example coverage.
