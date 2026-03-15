# EFUZY

EFUZY is a self-hosted file-processing workflow workspace.

## Delivery and fulfillment

Customer-ready delivery bundles can be prepared after a release package is built.

Release packaging:

```bash
scripts/package_efuzy_release.sh --edition standard
```

Buyer delivery packaging:

```bash
scripts/build_efuzy_delivery_bundle.sh \
  --version 0.4.0 \
  --edition standard \
  --customer "Acme Billing" \
  --quote-id Q-1001
```

Bundle verification:

```bash
scripts/verify_efuzy_delivery_bundle.sh \
  --bundle-dir delivery/efuzy-delivery-0.4.0-standard-acme-billing
```
