# 837 Export Profiles v1

This package adds a profile-driven CSV export layer on top of the normalized 837 model.

It is additive.
It does not replace the existing parser, validator, or CSV helpers.

## Routines

- `EFU837XCFG.m`
  - profile definitions
  - row source
  - ordered field definitions
- `EFU837XFORM.m`
  - normalized path resolution
  - simple transforms
- `EFU837XP.m`
  - profile-based CSV export
  - parse + export helper
- `EFU837XCFGT.m`
  - quiet-on-success tests

## Included profiles

- `claim_summary`
- `service_lines`
- `subscriber_patient`
- `provider_context`
- `combined_compact`
- `combined_verbose`

## Public calls

### Export from an already parsed root

```mumps
D EXPORT^EFU837XP("claim_summary",ROOT,"out/claim_summary.csv",.RES)
```

### Parse then export

```mumps
D EXPORTPARSE^EFU837XP("combined_compact","in/sample.edi","out/sample.csv",$NA(^TMP($J,"EFU837XP")),.OPT,.RES)
```

### Build one row in memory

```mumps
D BUILDROW^EFU837XP("service_lines",ROOT,CID,LN,.ROW)
```

## Profile path rules

Supported path prefixes:

- `claim.`
- `line.`
- `sub.`
- `patient.`
- `prov.billing.`
- `prov.attending.`

Examples:

- `claim.claim_id`
- `line.procedure_code`
- `sub.dob`
- `prov.billing.id`
- `prov.attending.name`

## Test run

```mumps
ZL "EFU837XCFG.m","EFU837XFORM.m","EFU837XP.m","EFU837XCFGT.m"
D ^EFU837XCFGT
```

## Notes

This package keeps the current exporter stable.
It gives you a cleaner path to:

1. profile versioning
2. custom CSV shapes
3. customer-specific export overlays
4. canonical CSV schemas for later CSV -> X12 work
