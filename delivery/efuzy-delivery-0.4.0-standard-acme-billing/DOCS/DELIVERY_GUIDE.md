# EFUZY Delivery Guide

This guide explains how to prepare a buyer-ready delivery bundle.

## Goal

The delivery bundle should give a buyer everything they need in one place:

- the release archive
- release notes
- checksums
- install and admin documents
- licensing guidance
- startup scripts

## Expected inputs

Before building a delivery bundle, create a versioned release package first.

Expected release assets:

- `dist/efuzy-<version>-<edition>.tar.gz`
- `dist/efuzy-<version>-<edition>.zip` (optional)
- `dist/SHA256SUMS.txt`
- `dist/efuzy-<version>-<edition>/RELEASE_MANIFEST.txt`
- `dist/efuzy-<version>-<edition>/RELEASE_NOTES.txt`

## Build the buyer bundle

Example:

```bash
scripts/build_efuzy_delivery_bundle.sh \
  --version 0.4.0 \
  --edition standard \
  --customer "Acme Billing" \
  --quote-id Q-1001
```

Output directory:

- `delivery/efuzy-delivery-<version>-<edition>-<customer>/`
- `delivery/efuzy-delivery-<version>-<edition>-<customer>.tar.gz`
- `delivery/efuzy-delivery-<version>-<edition>-<customer>.zip` (if `zip` is installed)

## Bundle layout

Top level:

- `START_HERE.txt`
- `DELIVERY_NOTICE.txt`
- `DELIVERY_MANIFEST.txt`
- `DELIVERY_SHA256SUMS.txt`

Release assets:

- `RELEASE/efuzy-<version>-<edition>.tar.gz`
- `RELEASE/efuzy-<version>-<edition>.zip` (optional)
- `RELEASE/SHA256SUMS.txt`
- `RELEASE/RELEASE_MANIFEST.txt`
- `RELEASE/RELEASE_NOTES.txt`

Documentation assets:

- `DOCS/README.md`
- `DOCS/CHANGELOG.md`
- `DOCS/INSTALL_GUIDE.md`
- `DOCS/ADMIN_GUIDE.md`
- `DOCS/LICENSING.md`
- `DOCS/DELIVERY_GUIDE.md`
- `DOCS/BUYER_HANDOFF_CHECKLIST.md`
- `efuzy-docs-<version>-<edition>.tar.gz`

Installer assets:

- `INSTALLER/install_efuzy.sh`
- `INSTALLER/compile_efuzy.sh`
- `INSTALLER/check_efuzy.sh`
- `INSTALLER/start_efuzy.sh`
- `INSTALLER/mws.conf.json`
- `efuzy-installer-<version>-<edition>.tar.gz`

## Verify the bundle

Example:

```bash
scripts/verify_efuzy_delivery_bundle.sh \
  --bundle-dir delivery/efuzy-delivery-0.4.0-standard-acme-billing
```

## Recommended buyer handoff order

1. Send the delivery archive.
2. Send the checksum file or keep it inside the bundle.
3. Tell the buyer to start with `START_HERE.txt`.
4. Confirm which edition they received.
5. Confirm how licensing will be delivered.
6. Confirm onboarding and support expectations.

## Important note

The delivery bundle is a fulfillment package.
It does not replace installation, activation, or onboarding.
