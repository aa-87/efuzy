# EFU 837 Validation Core v1

This package adds a production-minded validation layer on top of the current passing EFU 837 parser stack.

It is designed to coexist with the current routines instead of replacing them.

## Included routines

- `EFUX12DIAG.m`
  - structured validator diagnostics
  - stable severity buckets
  - stable diagnostic storage shape
- `EFU837MODEL.m`
  - normalized model v1 builder
  - stable `model_version=1`
- `EFU837SPEC.m`
  - first-pass rule tables for 837P / 837I / 837D
  - guide kind and required service-segment rules
  - first-pass loop/cardinality rules
- `EFU837VR.m`
  - rule-driven validator
  - strict mode and lenient mode
- `EFU837SPECT.m`
  - additive quiet-on-success tests for the new validation core

## Scope of this package

Implemented now:

- structured validator diagnostics under `@ROOT@("vdiag",...)`
- normalized model-v1 nodes under `@ROOT@("model",...)`
- guide recognition for:
  - `005010X222A1`
  - `005010X223A2`
  - `005010X224A2`
  - plus `X298` / `X299` family recognition through guide detection
- required service-kind rules:
  - 837P -> `SV1`
  - 837I -> `SV2`
  - 837D -> `SV3`
- strict vs lenient envelope handling
- claim/service structural checks
- basic date/amount sanity checks

Not implemented yet:

- full TR3 situational-rule engine
- full element-level requiredness tables
- full loop-order matrix for every loop and sub-loop
- full code-list validation
- CSV writer/importer changes
- round-trip X12 writer

## Expected integration style

The intended current flow is:

1. `PARSEONLY^EFU837P` or `PARSE^EFU837P`
2. `BUILD^EFU837MODEL`
3. `RUN^EFU837VR`
4. downstream export / preview / job logic

`EFU837VR` will build the model automatically if `model_version` is not already present.

## Diagnostic storage

Validator diagnostics are written to:

- `@ROOT@("vdiag","item",n,...)`
- `@ROOT@("vdiag","by_sev",...)`
- `@ROOT@("vdiag","count")`

This keeps them separate from the current parser's existing diagnostics.

## Minimal usage

```mumps
ZL "EFUX12DIAG.m","EFU837MODEL.m","EFU837SPEC.m","EFU837VR.m","EFU837SPECT.m"

S ROOT=$NA(^TMP($J,"EFU837"))
D PARSEONLY^EFU837P("/path/to/file.edi",ROOT,.OPT,.PRES)
D RUN^EFU837VR(ROOT,.OPT,.VRES)
ZWR VRES
```

Strict mode:

```mumps
N VRES
D STRICT^EFU837VR(ROOT,.VRES)
```

Lenient mode:

```mumps
N VRES
D LENIENT^EFU837VR(ROOT,.VRES)
```

## Tests

Run:

```mumps
ZL "EFUX12DIAG.m","EFU837MODEL.m","EFU837SPEC.m","EFU837VR.m","EFU837SPECT.m"
D ^EFU837SPECT
```

The test routine is additive and is intended to sit beside the existing `EFU837T` / `EFUX12T` suites.

## Suggested next package after this one

The next highest-ROI package after Validation Core v1 is:

- `EFU837XCFG`
- `EFU837XFORM`
- expanded `EFU837MAP`

That package should turn the current CSV export path into a profile-driven export system.
