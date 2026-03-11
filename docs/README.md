# EFUX12T additive suite

This package adds a broader external-file test layer on top of the passing `EFU837T` suite.

## What changed

The previous additive suite mixed three different concerns:

1. raw X12 coverage
2. X12 -> CSV conversion checks
3. exact vendor-benchmark CSV equality

That third category is not currently a valid hard-fail test because the current exporter writes a compact normalized schema, while the Example 1 vendor benchmark CSVs are much wider.

Examples from the uploaded pack:

- `837I-all-fields.csv` has 361 columns
- `837P-all-fields.csv` has 353 columns
- current `EFU837MAP` combined export has 28 columns

So exact file equality is a product goal, not a valid passing test today.

## What this suite now enforces

- Example 1 raw 837 coverage for all 18 files
- Example 2 raw 837 coverage for all 29 files
- raw smoke coverage for Example 1 non-837 files:
  - 271
  - 274
  - 277
  - 810
  - 834
  - 835
- conversion-ready 837 X12 -> CSV row-count checks against Example 1 benchmark CSVs for a safe subset

## Conversion-ready 837 subset

The new `T301` row-count benchmark check covers files where a benchmark CSV exists and where a compact exporter comparison is meaningful right now:

- `837I-inst-claim.dat`
- `anesthesia.dat`
- `chiro.dat`
- `cob-payera-payerb.dat`
- `cob-prov-payera.dat`
- `commercial-replacement.dat`
- `home-infusion-ndc.dat`
- `multi-tran.dat`
- `ppo-repriced.dat`
- `wheelchair.dat`

## Lenient export mode

The patched parser utilities add:

- `OPT("lenient")=1`
- `OPT("accept_bad_envelope")=1`

These downgrade envelope-control problems like:

- missing `IEA`
- `ISA13` / `IEA02` mismatch
- `GS06` / `GE02` mismatch

from hard errors to warnings.

That is useful for real-world trading-partner files and for some of the Example 1 benchmark files.

## Recommended run order

```mumps
ZL "EFU837U.m","EFU837VAL.m","EFU837P.m","EFUX12T.m"
D ALL^EFUX12T("edi")
D STRICT837^EFUX12T("edi")
```

## What still needs to be built for full benchmark parity

### X12 -> CSV
- benchmark-profile-aware column mapping
- wider 837P / 837I / 837D export schemas
- benchmark header-name alignment
- per-guide export profiles

### CSV -> X12
- canonical import schema
- profile-specific X12 builders
- envelope synthesis
- claim/service loop builders
- round-trip tests:
  - X12 -> normalized CSV
  - CSV -> X12
  - X12 -> CSV again
  - semantic compare

## Practical next step

Build a dedicated conversion layer:

- `EFUX12CVT` for profile-aware export/import
- `EFUX12X` for CSV -> X12 builders
- `EFUX12CVTT` for benchmark and round-trip tests

That can use the already-stable parser layer as the ingestion front end.
