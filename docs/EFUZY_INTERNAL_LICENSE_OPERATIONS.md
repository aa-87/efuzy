# EFUZY Internal License Operations Guide

## Purpose

This is an internal operator guide for issuing and supporting EFUZY client licenses.

It explains:

- how to issue licenses for clients
- what files and keys are required
- how offline verification works inside the app
- what claims to set for each customer type
- what to check when a customer reports a license problem

This guide is written for the current EFUZY licensing model:

- offline local license file
- JWT-based license container
- RS256 signing for production licenses
- `MIOAUTHJWT` verification inside the app
- public key on client systems
- private key kept only on the vendor side

---

## Security model

### What ships to the client

A customer install should have:

- the EFUZY application
- the local license file
- the RSA public key used to verify the license
- the install ID file

A customer install should **not** have:

- the RSA private signing key
- any vendor issuance tooling that depends on the private key

### Why this model is safe

EFUZY uses a signed JWT license.

For production offline licensing, the license should use **RS256**.

That means:

- you sign the license with a **private key**
- the app verifies the license with a **public key**
- the customer can verify the license locally
- the customer cannot generate new valid licenses without the private key

This is the correct model for a self-hosted product that must verify licenses offline.

---

## Current runtime files

### License file

Default path:

- `instance/license/efuzy.license`

This file contains the signed JWT as plain text.

### Install ID file

Default path:

- `instance/license/efuzy.install_id`

This file contains the local install ID.

If the license contains an `install_id` claim, the app requires it to match the local install ID file.

### Public key file

Default path:

- `instance/license/keys/efuzy_license_public.pem`

The app uses this file during RS256 verification.

### Private key file

Suggested vendor-side path:

- `vendor/keys/efuzy_license_private.pem`

This should remain on your internal systems only.

Do not ship it to customers.

---

## Current config keys used by licensing

These are the main config keys used by `EFUZYLIC`.

```json
{
  "efuzy": {
    "license": {
      "mode": "paid",
      "edition": "standard",
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
      "jwtClockSkewSeconds": 60,
      "longLivedDays": 3650,
      "requireValidOnStartup": 1
    }
  }
}
```

### Important notes

- `jwtAlgorithm` should be `RS256` for production use.
- `allowHmacJwt` should stay `0` unless you are deliberately using a compatibility path.
- `rs256PrivateKeyPath` is needed only on the issuer side.
- `rs256PublicKeyPath` is needed on client installs.
- `longLivedDays` is the default paid-license duration if `expires_at` is omitted.

---

## What the app validates

The app validates licenses through `STATUS^EFUZYLIC`.

High-level rules:

- `demo` mode does not require a license file
- `evaluation` mode requires a valid license and an expiry
- `paid` mode requires a valid paid-edition license
- the JWT signature is verified by `MIOAUTHJWT`
- `iss` must match `jwtIssuer`
- `aud` must match `jwtAudience`
- `product` must match `efuzy`
- `exp` is checked by JWT validation
- `expires_at` is also surfaced for EFUZY status output
- if `install_id` is present in the license, it must match the local install ID file
- if host binding is enabled and a `host` claim is present, it must match the local host identity
- `maintenance_until` does not block the app, but it marks support as expired

---

## Current verification flow in the app

This is the practical runtime flow.

### 1. Startup and health call the license checker

Main entrypoint:

```text
D STATUS^EFUZYLIC(.CONF,.RES)
```

This routine:

- normalizes the license config
- reads the local install ID
- reads the license file
- tries JWT parsing first
- falls back to legacy `key=value` format only if no JWT token is found
- validates product, edition, expiry, install ID, host, and maintenance status

### 2. JWT verification goes through `MIOAUTHJWT`

`EFUZYLIC` calls:

```text
S OK=$$VERIFY^MIOAUTHJWT(.JCONF,.REQ,.CTX,.JERR)
```

It configures:

- issuer
n- audience
- clock skew
- HMAC secret if compatibility mode is used
- `rs256Verify="RSVFY^EFUZYLIC"`

### 3. RS256 verification uses the EFUZY callback

Callback:

```text
RSVFY^EFUZYLIC(DATA,SIGBIN,CONF,CTX,HOBJ,POBJ,ERR)
```

This callback:

- loads the configured public key path
- writes temp files under the EFUZY temp area
- reconstructs the signature into binary form
- calls OpenSSL to verify the signature over the JWT signing input
- returns success or a structured error

### 4. Claims are copied into the EFUZY license structure

After successful verification:

- `MIOAUTHJWT` exposes claims under `CTX("auth","claim",...)`
- `EFUZYLIC` copies them into `RES("license",...)`
- EFUZY then applies its product and edition rules

### 5. The result is used by startup and health

Expected results include fields such as:

- `RES("ok")`
- `RES("status")`
- `RES("licensed")`
- `RES("format")="jwt"`
- `RES("algorithm")="RS256"`
- `RES("license",...)`
- `RES("supportActive")`
- `RES("warning")="maintenance_expired"` when support is expired

---

## Supported license modes

### Demo

Use for:

- public demo hosting
- internal demo environments

Behavior:

- no local license required
- `STATUS^EFUZYLIC` returns demo status
- startup does not require activation

### Evaluation

Use for:

- private customer trial
- short-lived proof-of-concept install

Behavior:

- must carry a valid expiry
- should usually use `edition=evaluation`
- startup fails after expiry

### Paid

Use for:

- normal commercial self-hosted customers

Behavior:

- requires a valid license
- should use a paid edition such as `standard`, `professional`, `enterprise`, or `source`
- may be long-lived
- may carry maintenance/support dates independently from license expiry

---

## Supported editions

Typical values:

- `evaluation`
- `standard`
- `professional`
- `enterprise`
- `source`
- `source_license`

For paid mode, use one of the paid editions.

---

## Claims you should issue

Recommended claims for all production JWT licenses:

- `iss`
- `aud`
- `sub`
- `jti`
- `typ=efuzy-license`
- `product=efuzy`
- `edition`
- `licensee`
- `mode`
- `iat`
- `nbf`
- `expires_at`
- `exp`

Recommended optional claims:

- `install_id`
- `maintenance_until`
- `host`
- `customer_id`
- `notes`

### Claim meaning

- `iss`: must match EFUZY config
- `aud`: must match EFUZY config
- `product`: protects against cross-product reuse
- `edition`: controls commercial tier
- `licensee`: customer display name
- `mode`: demo, evaluation, or paid intent
- `install_id`: binds the license to a specific install
- `maintenance_until`: support entitlement date
- `host`: optional host binding
- `expires_at` and `exp`: hard activation expiry

---

## Recommended internal license issuance process

Use this exact operator flow.

### Step 1. Collect customer data

Before issuing a license, collect:

- legal customer name
- purchased edition
- license mode
- install ID
- whether host binding is needed
- support/maintenance end date
- hard expiry date, if any
- quote/order/reference number

### Step 2. Obtain the customer install ID

Ask the customer for the contents of:

- `instance/license/efuzy.install_id`

Or generate it locally during deployment using the bootstrap process.

The safest operational model is:

- each deployment gets its own install ID
- each issued license is bound to that install ID

### Step 3. Decide the license shape

#### Standard paid install

Suggested fields:

- `mode=paid`
- `edition=standard`
- `install_id=<customer install id>`
- `maintenance_until=<support end date>`
- `expires_at=<long-lived end date or contract end date>`

#### Evaluation install

Suggested fields:

- `mode=evaluation`
- `edition=evaluation`
- `install_id=<customer install id>`
- `expires_at=<trial end date>`

#### Enterprise or source delivery

Suggested fields:

- `mode=paid`
- `edition=enterprise` or `source`
- `install_id=<customer install id>` unless you intentionally want a transferable license
- `maintenance_until=<support end date>`
- `expires_at=<contract end date or long-lived date>`

### Step 4. Issue the license using `ISSUE^EFUZYLIC`

Example internal issuance flow:

```text
D BOOTCONF^MIO(.CONF)
S CONF("efuzy","license","jwtAlgorithm")="RS256"
S CONF("efuzy","license","rs256PrivateKeyPath")="vendor/keys/efuzy_license_private.pem"
S CONF("efuzy","license","jwtIssuer")="efuzy-license"
S CONF("efuzy","license","jwtAudience")="efuzy"
S CONF("efuzy","license","opensslBin")="openssl"

S SPEC("mode")="paid"
S SPEC("edition")="professional"
S SPEC("licensee")="Acme Billing LLC"
S SPEC("install_id")="b2b6f7dd-d1df-4a3b-8fcb-fc8c7f22f001"
S SPEC("maintenance_until")="2027-03-31"
S SPEC("expires_at")="2028-03-31"
S SPEC("filePath")="out/Acme_Billing_efuzy.license"

D ISSUE^EFUZYLIC(.CONF,.SPEC,.RES)
ZW RES
```

Expected success signals:

- `RES("ok")=1`
- `RES("algorithm")="RS256"`
- `RES("written")=1`
- `RES("licensePath")` is present
- `RES("token")` is present

### Step 5. Deliver the correct files

For a normal offline paid install, send:

- the license file
- the public key file
- the install instructions that say where both files go

Do not send:

- the private key
- vendor signing notes
- any internal secret material

### Step 6. Record the issuance

Internally record at least:

- customer name
- edition
- mode
- install ID
- maintenance date
- expiry date
- JWT `jti`
- date issued
- operator name
- order/quote reference

This makes later support and renewal much easier.

---

## Example license issue profiles

### 30-day evaluation

```text
S SPEC("mode")="evaluation"
S SPEC("edition")="evaluation"
S SPEC("licensee")="Example Prospect"
S SPEC("install_id")="<install-id>"
S SPEC("expires_at")="2026-04-15"
```

### Standard paid customer

```text
S SPEC("mode")="paid"
S SPEC("edition")="standard"
S SPEC("licensee")="Example Billing LLC"
S SPEC("install_id")="<install-id>"
S SPEC("maintenance_until")="2027-03-31"
S SPEC("expires_at")="2028-03-31"
```

### Enterprise paid customer with no host lock

```text
S SPEC("mode")="paid"
S SPEC("edition")="enterprise"
S SPEC("licensee")="Large Health Ops"
S SPEC("install_id")="<install-id>"
S SPEC("maintenance_until")="2027-12-31"
S SPEC("expires_at")="2029-12-31"
```

### Host-bound paid customer

Only use this when you have a strong reason.

```text
S CONF("efuzy","license","hostStrategy")="name"
S SPEC("host")="billing-prod-01"
```

This increases support friction if the customer changes servers.

---

## Operational recommendations

### Recommended defaults

For most customers:

- use `RS256`
- bind to `install_id`
- do not use host binding unless necessary
- include `maintenance_until`
- include `expires_at`
- use long-lived paid expiries, not infinite licenses

### Why long-lived expiries are better than no expiry

They give you:

- a renewal control point
- better recovery if a license leaks
- easier contract alignment
- cleaner reissue behavior

### How to think about `maintenance_until`

This is not the hard activation end date.

It is the support entitlement date.

When it expires:

- the app can still be licensed
- `supportActive` becomes `0`
- `warning=maintenance_expired` appears in status

This is useful for support and renewal operations.

---

## How to inspect license status in a running app

Use:

```text
D BOOTCONF^MIO(.CONF)
D STATUS^EFUZYLIC(.CONF,.RES)
ZW RES
```

Important fields to check:

- `RES("ok")`
- `RES("status")`
- `RES("error")`
- `RES("licensed")`
- `RES("format")`
- `RES("algorithm")`
- `RES("license",...)`
- `RES("supportActive")`
- `RES("warning")`

### Typical successful paid result

```text
RES("ok")=1
RES("status")="licensed"
RES("licensed")=1
RES("format")="jwt"
RES("algorithm")="RS256"
RES("license","licensee")="Acme Billing LLC"
RES("license","edition")="professional"
RES("supportActive")=1
```

### Typical expired maintenance result

```text
RES("ok")=1
RES("status")="licensed"
RES("licensed")=1
RES("supportActive")=0
RES("warning")="maintenance_expired"
```

### Typical expired license result

```text
RES("ok")=0
RES("status")="expired"
RES("error")="license_expired"
```

---

## Common failure cases and what they mean

### `license_file_missing`

Cause:

- no local license file at the configured path

Fix:

- place the license file at `filePath`
- verify config matches the delivered location

### `license_public_key_missing`

Cause:

- client-side public key file is missing

Fix:

- place the correct public key at `rs256PublicKeyPath`
- verify the config path

### `license_bad_signature`

Cause:

- token was modified
- wrong public key file
- wrong private/public key pair used during issue and verify

Fix:

- confirm the correct key pair
- reissue the license if needed

### `license_invalid_token`

Cause:

- malformed JWT
- truncated file
- unexpected token content

Fix:

- inspect the file contents
- re-deliver or reissue the license

### `license_expired`

Cause:

- hard expiry date has passed

Fix:

- issue a renewed license

### `install_id_mismatch`

Cause:

- license was issued for a different install ID

Fix:

- confirm the customer’s actual `efuzy.install_id`
- reissue the license if needed

### `license_host_mismatch`

Cause:

- host binding was enabled and the current host does not match the claim

Fix:

- confirm whether the customer moved hosts
- reissue the license or relax host binding

### `license_product_mismatch`

Cause:

- wrong product claim

Fix:

- reissue using `product=efuzy`

---

## Suggested internal operating policy

Use this policy unless there is a special sales or legal reason not to.

### Public demo

- `mode=demo`
- no license file

### Private evaluation

- `mode=evaluation`
- 14 to 30 day expiry
- `install_id` bound
- no host binding unless necessary

### Standard and Professional

- `mode=paid`
- `install_id` bound
- 1 to 3 year expiry, depending on contract
- maintenance date aligned to support term

### Enterprise and source delivery

- `mode=paid`
- `install_id` bound unless contract says otherwise
- maintenance date always included
- consider a separate internal issuance record for each deployment

---

## Suggested key management policy

### Private key

- keep on vendor-controlled systems only
- do not store in customer repos
- do not email it
- do not include in delivery bundles
- restrict operator access
- back it up securely
- rotate only with a deliberate plan

### Public key

- safe to ship with customer installs
- may be embedded in the package or delivered separately
- treat it as versioned operational material

### If you rotate keys

You will need to:

- distribute the new public key to customers
- reissue licenses signed by the new private key
- maintain a clear internal record of which licenses used which key

---

## Practical issuance checklist

Before sending a license:

- confirm customer edition
- confirm license mode
- confirm install ID
- confirm maintenance date
- confirm hard expiry date
- confirm private key path
- issue the license
- inspect `RES("ok")=1`
- verify the generated file path
- record the issuance metadata
- deliver only the license and public key

---

## Practical support checklist

When a customer says the license is not working:

1. ask for the output of:

```text
D BOOTCONF^MIO(.CONF)
D STATUS^EFUZYLIC(.CONF,.RES)
ZW RES
```

2. inspect:

- `status`
- `error`
- `format`
- `algorithm`
- `licensee`
- `edition`
- `install_id`
- `supportActive`
- `warning`

3. confirm file locations:

- license file
- install ID file
- public key file

4. if needed, reissue the license using the exact customer install ID

---

## Internal summary

The current EFUZY model is:

- offline
- client-local
- JWT-based
- RS256 signed
- verified through `MIOAUTHJWT`
- enforced through `EFUZYLIC`

The most important operational rule is simple:

- **you keep the private key**
- **the client gets only the public key and the license file**

That gives EFUZY a practical and safe self-hosted commercial licensing model.
