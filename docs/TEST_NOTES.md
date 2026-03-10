# EFU837T regression fix

This update fixes two issues:

1. `CSVROWS` now counts non-empty CSV data rows robustly and ignores the header.
2. External example suites now resolve the example base more safely and fail clearly if the supplied base does not actually contain `Examples 1` / `Examples 2`.

Recommended invocation:

```mumps
D ^EFU837T
```

Or provide the actual extracted base explicitly:

```mumps
D ALL^EFU837T("/absolute/path/to/files")
```
