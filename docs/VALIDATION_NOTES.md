# Example-pack findings used for the test fix

## Real tree layout

The uploaded archive extracts to a tree shaped like:

- `Examples 1/edi_files/837/...`
- `Examples 1/converted_files/837/...`
- `Examples 2/...`

The paths use spaces in `Examples 1` and `Examples 2`.

## Example 1 benchmark reality

The 837 converted benchmark folder does **not** contain every possible CSV variant.

Examples:

- `837I-inst-claim.csv` exists
- `837I-inst-claim-Claims.csv` does **not** exist
- `837D-all-fields.json` exists
- `837D-all-fields.csv` does **not** exist
- `837I-X299-all-fields.json` exists
- `837I-X299-all-fields.csv` does **not** exist
- `837P-X298-all-fields.json` exists
- `837P-X298-all-fields.csv` does **not** exist

Because of that, the example tests must check benchmark CSV files only when those exact files are actually present.

## Example 1 raw-file observations

Derived from the uploaded sources:

- `837D-all-fields.dat` -> guide `005010X224`, 1 claim, 2 service lines
- `837I-X299-all-fields.dat` -> guide `005010X299`, 1 claim, 1 service line
- `837I-all-fields.dat` -> guide `005010X223A2`, 1 claim, 2 service lines
- `837I-inst-claim.dat` -> guide `005010X223`, 1 claim, 2 service lines
- `837P-X298-all-fields.dat` -> guide `005010X298`, 1 claim, 1 service line
- `837P-all-fields.dat` -> guide `005010X222A2`, 1 claim, 4 service lines
- `multi-tran.dat` -> 3 claims, 7 service lines

## Important data-quality note

`837I-all-fields.dat` contains envelope control mismatches in the uploaded source itself:

- `ISA13` != `IEA02`
- `GS06` != `GE02`

That means it is useful as a **source-coverage** example, but not a good strict-pass parser benchmark for a parser that intentionally treats those mismatches as errors.

## Test strategy after this fix

The external example suites now do this:

- validate the real source files exist
- use a light raw scanner to validate guide / flavor / claim count / line count
- compare benchmark CSV row counts only when the benchmark files actually exist
- keep the parser/exporter strict behavior covered by the core embedded tests
