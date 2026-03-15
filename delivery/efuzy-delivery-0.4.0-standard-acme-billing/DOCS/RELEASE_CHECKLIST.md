# EFUZY Release Checklist

## Before compile

- [ ] `VERSION` updated
- [ ] `routines/EFUZYREL.m` version updated if needed
- [ ] `CHANGELOG.md` updated
- [ ] new docs added to release tree
- [ ] new scripts marked executable

## Compile

- [ ] compile routines in target YottaDB environment
- [ ] compile errors reviewed and fixed

## Smoke validation

- [ ] run `scripts/release_smoke_efuzy.sh`
- [ ] confirm `^EFUZYTESTS` passes for the release candidate

## Packaging

- [ ] run `scripts/package_efuzy_release.sh`
- [ ] confirm tar.gz archive exists
- [ ] confirm zip archive exists or note why it is absent
- [ ] confirm `SHA256SUMS.txt` exists
- [ ] confirm `RELEASE_MANIFEST.txt` exists in staged package
- [ ] confirm `RELEASE_NOTES.txt` exists in staged package

## Delivery review

- [ ] installer script present
- [ ] config template present
- [ ] docs present
- [ ] changelog present
- [ ] version matches manifest and archive name
- [ ] checksums verified
