# EFUZY Licensing and Activation

## Purpose

This guide covers the current local licensing model for EFUZY.

It is designed for:

- public demo installs
- private evaluation installs
- paid self-hosted installs
- internal license issuance by the vendor

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
- the license is a signed JWT
- the recommended production format is an RS256-signed JWT
- the license must carry an expiry
- startup fails cleanly after expiry

### `paid`

Use this for commercial self-hosted delivery.

Behavior:

- a local license file is required
- the license is a signed JWT
- the recommended production format is an RS256-signed JWT
- startup fails if the file is missing or invalid
- install ID matching can be enforced
- optional host binding can be enforced
- paid licenses can be issued with a long-lived expiry window

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
      "jwtIssuer": "efuzy-license",
      "jwtAudience": "efuzy",
      "jwtAlgorithm": "RS256",
      "rs256PublicKeyPath": "instance/license/keys/efuzy_license_public.pem",
      "rs256PrivateKeyPath": "",
      "opensslBin": "openssl",
      "allowHmacJwt": 0,
      "jwtSecret": "",
      "jwtClockSkewSeconds": 60,
      "longLivedDays": 3650,
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

The default license file is now a signed JWT stored as plain text.

Default path:

- `instance/license/efuzy.license`

The verifier uses `MIOAUTHJWT` helpers.

For production offline licensing, the recommended model is:

- vendor signs with an RSA private key
- client verifies with an RSA public key
- the public key path is configured in `efuzy.license.rs256PublicKeyPath`
- the private key is only needed on the vendor-side issuer path

Optional HS256 compatibility remains available only when a shared secret is explicitly configured.

The RS256 issuer and verifier helpers expect an `openssl` binary to be available on the host.

The JWT payload should include claims such as:

- `iss`
- `aud`
- `sub`
- `product`
- `edition`
- `licensee`
- `install_id` (optional)
- `host` (optional)
- `maintenance_until` (optional but recommended)
- `expires_at` and `exp` for evaluation, and recommended for paid

Legacy `key=value` license files are still accepted for backward compatibility.

## Internal issuance helper

EFUZY now includes an internal issuer helper:

```text
D ISSUE^EFUZYLIC(.CONF,.SPEC,.RES)
ZW RES
```

Typical `SPEC` fields are:

- `mode`
- `edition`
- `licensee`
- `install_id`
- `host`
- `expires_at`
- `maintenance_until`
- `filePath`

Example:

```text
D BOOTCONF^MIO(.CONF)
S CONF("efuzy","license","rs256PrivateKeyPath")="vendor/keys/efuzy_license_private.pem"
S SPEC("mode")="paid"
S SPEC("edition")="professional"
S SPEC("licensee")="Example Billing LLC"
S SPEC("install_id")="2c7f6d44-4f7e-4c37-a501-7b0f49f0d71e"
S SPEC("filePath")="instance/license/efuzy.license"
D ISSUE^EFUZYLIC(.CONF,.SPEC,.RES)
ZW RES
```

For paid licenses, if `expires_at` is omitted, the issuer uses a long-lived default based on `longLivedDays`.

## Validation rules

Current validation rules are:

- `product` must be `efuzy`
- `demo` mode bypasses the local license file
- `evaluation` mode requires `edition=evaluation`
- `evaluation` mode requires an expiry
- `paid` mode requires a paid edition such as:
  - `standard`
  - `professional`
  - `enterprise`
  - `source`
- JWT signature, issuer, audience, and expiry are checked through `MIOAUTHJWT`
- RS256 license verification uses the configured public key path and the `RSVFY^EFUZYLIC` callback
- if `install_id` is present in the license, it must match the local install ID
- if `hostStrategy=name` and `host` is present in the license, it must match the configured host ID
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


## Offline security model

The client-local paid model is now designed around public-key verification.

That means:

- the customer install only needs the public key
- the vendor keeps the private key off customer systems
- a compromised customer install cannot issue new valid licenses

This is the recommended EFUZY commercial licensing model for offline self-hosted delivery.
