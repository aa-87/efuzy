# EFUZY Licensing and Activation

## Purpose

This guide covers the current local licensing model for EFUZY.

It is designed for:

- public demo installs
- private evaluation installs
- paid self-hosted installs

## Modes

EFUZY supports three activation modes.

### `demo`

Use this for the public hosted demo.

Behavior:

- no local license file is required
- startup stays license-free
- health reports `license.status=demo`
- this is the safest default for evaluation hosting

### `evaluation`

Use this for a private customer trial.

Behavior:

- a local license file is required
- the license should carry an `expires_at` date
- startup fails cleanly after expiry

### `paid`

Use this for commercial self-hosted delivery.

Behavior:

- a local license file is required
- startup fails if the file is missing or invalid
- install ID matching can be enforced
- optional host binding can be enforced

## Config keys

Current config block:

```json
{
  "efuzy": {
    "license": {
      "mode": "demo",
      "edition": "demo",
      "filePath": "instance/license/efuzy.license",
      "installIdPath": "instance/license/efuzy.install_id",
      "hostStrategy": "none",
      "product": "efuzy",
      "requireValidOnStartup": 0
    }
  }
}
```

## Install ID

The installer seeds a local install ID file:

- `instance/license/efuzy.install_id`

`STARTUP^EFUZYBOOT` also ensures this file exists.

This gives you a stable value to bind a customer license to.

## License file format

The current local license file is a simple `key=value` text file.

Default path:

- `instance/license/efuzy.license`

Example paid license:

```text
product=efuzy
edition=professional
licensee=Example Billing LLC
install_id=2c7f6d44-4f7e-4c37-a501-7b0f49f0d71e
maintenance_until=2027-03-14
```

Example evaluation license:

```text
product=efuzy
edition=evaluation
licensee=Example Prospect
install_id=2c7f6d44-4f7e-4c37-a501-7b0f49f0d71e
expires_at=2026-04-30
maintenance_until=2026-04-30
```

Optional host-bound fields:

```text
host=app01.example.local
```

## Validation rules

Current validation rules are:

- `product` must be `efuzy`
- `demo` mode bypasses the local license file
- `evaluation` mode requires `edition=evaluation`
- `evaluation` mode requires `expires_at`
- `paid` mode requires a paid edition such as:
  - `standard`
  - `professional`
  - `enterprise`
  - `source`
- if `install_id` is present in the file, it must match the local install ID
- if `hostStrategy=name` and `host` is present in the file, it must match the configured host ID
- `maintenance_until` does not block startup, but it does mark support as expired in status output

## Health and startup behavior

Bootstrap and health now surface license state.

You can inspect it with:

```text
D BOOTCONF^MIO(.CONF)
D STATUS^EFUZYLIC(.CONF,.RES)
ZW RES
```

Operational effects:

- `STARTUP^EFUZYBOOT` fails for invalid paid or evaluation installs
- `STATUS^EFUZYHEALTH` includes `license_ok`
- `READY^EFUZYHEALTH` stays not ready when the activation state is invalid

## Commercial note

For a source-available self-hosted product, licensing is primarily:

- a delivery control
- an operational activation gate
- a commercial support signal

It is not a substitute for the purchase agreement.

That is expected for source delivery products.
