#!/usr/bin/env bash
set -Eeuo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SELF_DIR/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$REPO_ROOT/VERSION" 2>/dev/null || true)"
EDITION="standard"
CUSTOMER="customer"
QUOTE_ID=""
RELEASE_DIR="$REPO_ROOT/dist"
OUT_DIR="$REPO_ROOT/delivery"
INCLUDE_ZIP="1"

usage() {
  cat <<'USAGE'
Usage:
  scripts/build_efuzy_delivery_bundle.sh [options]

Options:
  --repo-root <path>       Repo root. Default: parent of this script.
  --release-dir <path>     Release artifacts directory. Default: <repo>/dist.
  --out-dir <path>         Delivery output directory. Default: <repo>/delivery.
  --version <semver>       Version. Default: contents of VERSION.
  --edition <name>         Edition. Default: standard.
  --customer <name>        Customer or buyer label. Default: customer.
  --quote-id <id>          Optional quote/order/reference id.
  --no-zip                 Do not create zip archive for the final delivery bundle.
  -h, --help               Show this help.
USAGE
}

fail() { printf '[efuzy-delivery][ERROR] %s\n' "$*" >&2; exit 1; }
log() { printf '[efuzy-delivery] %s\n' "$*"; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"; }
checksum_cmd() {
  if command -v sha256sum >/dev/null 2>&1; then
    echo "sha256sum"
  elif command -v shasum >/dev/null 2>&1; then
    echo "shasum -a 256"
  else
    fail "Missing required checksum tool: sha256sum or shasum"
  fi
}

sanitize() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-{2,}/-/g'
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo-root) REPO_ROOT="$2"; shift 2 ;;
      --release-dir) RELEASE_DIR="$2"; shift 2 ;;
      --out-dir) OUT_DIR="$2"; shift 2 ;;
      --version) VERSION="$2"; shift 2 ;;
      --edition) EDITION="$2"; shift 2 ;;
      --customer) CUSTOMER="$2"; shift 2 ;;
      --quote-id) QUOTE_ID="$2"; shift 2 ;;
      --no-zip) INCLUDE_ZIP="0"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) fail "Unknown argument: $1" ;;
    esac
  done
}

verify_inputs() {
  need_cmd tar
  need_cmd find
  [[ -n "$VERSION" ]] || fail "VERSION is empty. Pass --version or create VERSION file."
  [[ -f "$REPO_ROOT/README.md" ]] || fail "Missing README.md"
  [[ -f "$REPO_ROOT/CHANGELOG.md" ]] || fail "Missing CHANGELOG.md"
  [[ -f "$REPO_ROOT/docs/INSTALL_GUIDE.md" ]] || fail "Missing docs/INSTALL_GUIDE.md"
  [[ -f "$REPO_ROOT/docs/ADMIN_GUIDE.md" ]] || fail "Missing docs/ADMIN_GUIDE.md"
  [[ -f "$REPO_ROOT/docs/LICENSING.md" ]] || fail "Missing docs/LICENSING.md"
  [[ -f "$REPO_ROOT/scripts/install_efuzy.sh" ]] || fail "Missing scripts/install_efuzy.sh"
  [[ -f "$RELEASE_DIR/efuzy-${VERSION}-${EDITION}.tar.gz" ]] || fail "Missing release archive: $RELEASE_DIR/efuzy-${VERSION}-${EDITION}.tar.gz"
  [[ -f "$RELEASE_DIR/SHA256SUMS.txt" ]] || fail "Missing release checksums: $RELEASE_DIR/SHA256SUMS.txt"
  [[ -d "$RELEASE_DIR/efuzy-${VERSION}-${EDITION}" ]] || fail "Missing staged release directory: $RELEASE_DIR/efuzy-${VERSION}-${EDITION}"
}

prepare_paths() {
  CUSTOMER_SAFE="$(sanitize "$CUSTOMER")"
  [[ -n "$CUSTOMER_SAFE" ]] || CUSTOMER_SAFE="customer"
  BUNDLE_NAME="efuzy-delivery-${VERSION}-${EDITION}-${CUSTOMER_SAFE}"
  STAGE_DIR="$OUT_DIR/$BUNDLE_NAME"
  RELEASE_STAGE="$RELEASE_DIR/efuzy-${VERSION}-${EDITION}"
  mkdir -p "$OUT_DIR"
  rm -rf "$STAGE_DIR"
  mkdir -p "$STAGE_DIR/RELEASE" "$STAGE_DIR/DOCS" "$STAGE_DIR/INSTALLER"
}

copy_release_assets() {
  cp "$RELEASE_DIR/efuzy-${VERSION}-${EDITION}.tar.gz" "$STAGE_DIR/RELEASE/"
  [[ -f "$RELEASE_DIR/efuzy-${VERSION}-${EDITION}.zip" ]] && cp "$RELEASE_DIR/efuzy-${VERSION}-${EDITION}.zip" "$STAGE_DIR/RELEASE/" || true
  cp "$RELEASE_DIR/SHA256SUMS.txt" "$STAGE_DIR/RELEASE/"
  [[ -f "$RELEASE_STAGE/RELEASE_MANIFEST.txt" ]] && cp "$RELEASE_STAGE/RELEASE_MANIFEST.txt" "$STAGE_DIR/RELEASE/" || true
  [[ -f "$RELEASE_STAGE/RELEASE_NOTES.txt" ]] && cp "$RELEASE_STAGE/RELEASE_NOTES.txt" "$STAGE_DIR/RELEASE/" || true
}

copy_docs_assets() {
  cp "$REPO_ROOT/README.md" "$STAGE_DIR/DOCS/"
  cp "$REPO_ROOT/CHANGELOG.md" "$STAGE_DIR/DOCS/"
  cp "$REPO_ROOT/docs/INSTALL_GUIDE.md" "$STAGE_DIR/DOCS/"
  cp "$REPO_ROOT/docs/ADMIN_GUIDE.md" "$STAGE_DIR/DOCS/"
  cp "$REPO_ROOT/docs/LICENSING.md" "$STAGE_DIR/DOCS/"
  [[ -f "$REPO_ROOT/docs/RELEASE_ENGINEERING.md" ]] && cp "$REPO_ROOT/docs/RELEASE_ENGINEERING.md" "$STAGE_DIR/DOCS/" || true
  [[ -f "$REPO_ROOT/docs/RELEASE_CHECKLIST.md" ]] && cp "$REPO_ROOT/docs/RELEASE_CHECKLIST.md" "$STAGE_DIR/DOCS/" || true
  cp "$REPO_ROOT/docs/DELIVERY_GUIDE.md" "$STAGE_DIR/DOCS/"
  cp "$REPO_ROOT/docs/BUYER_HANDOFF_CHECKLIST.md" "$STAGE_DIR/DOCS/"
}

copy_installer_assets() {
  cp "$REPO_ROOT/scripts/install_efuzy.sh" "$STAGE_DIR/INSTALLER/"
  cp "$REPO_ROOT/scripts/compile_efuzy.sh" "$STAGE_DIR/INSTALLER/"
  cp "$REPO_ROOT/scripts/check_efuzy.sh" "$STAGE_DIR/INSTALLER/"
  cp "$REPO_ROOT/scripts/start_efuzy.sh" "$STAGE_DIR/INSTALLER/"
  cp "$REPO_ROOT/config/mws.conf.json" "$STAGE_DIR/INSTALLER/"
}

build_nested_packages() {
  (
    cd "$STAGE_DIR/DOCS"
    tar -czf "../efuzy-docs-${VERSION}-${EDITION}.tar.gz" .
  )
  (
    cd "$STAGE_DIR/INSTALLER"
    tar -czf "../efuzy-installer-${VERSION}-${EDITION}.tar.gz" .
  )
}

write_start_here() {
  cat > "$STAGE_DIR/START_HERE.txt" <<EOF2
EFUZY buyer delivery bundle

Customer: $CUSTOMER
Quote/Order: ${QUOTE_ID:-n/a}
Version: $VERSION
Edition: $EDITION
Built at: $(date -u +%Y-%m-%dT%H:%M:%SZ)

Recommended order:
1. Read DOCS/INSTALL_GUIDE.md
2. Read DOCS/ADMIN_GUIDE.md
3. Review DOCS/LICENSING.md
4. Verify RELEASE/SHA256SUMS.txt
5. Unpack RELEASE/efuzy-${VERSION}-${EDITION}.tar.gz
6. Run INSTALLER/install_efuzy.sh inside the unpacked release tree
EOF2
}

write_delivery_notice() {
  cat > "$STAGE_DIR/DELIVERY_NOTICE.txt" <<EOF2
EFUZY commercial delivery

This package is intended for self-hosted customer delivery.

Customer: $CUSTOMER
Quote/Order: ${QUOTE_ID:-n/a}
Version: $VERSION
Edition: $EDITION
Package name: $BUNDLE_NAME

Included:
- release archive(s)
- release manifest and release notes
- checksums
- documentation package
- installer package

This delivery does not itself activate the product.
Activation and licensing behavior are controlled by the local install and license mode.
EOF2
}

write_delivery_manifest() {
  {
    printf 'bundle_name=%s\n' "$BUNDLE_NAME"
    printf 'customer=%s\n' "$CUSTOMER"
    printf 'quote_id=%s\n' "${QUOTE_ID:-}"
    printf 'version=%s\n' "$VERSION"
    printf 'edition=%s\n' "$EDITION"
    printf 'built_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'release_archive=%s\n' "RELEASE/efuzy-${VERSION}-${EDITION}.tar.gz"
    if [[ -f "$STAGE_DIR/RELEASE/efuzy-${VERSION}-${EDITION}.zip" ]]; then
      printf 'release_archive_zip=%s\n' "RELEASE/efuzy-${VERSION}-${EDITION}.zip"
    fi
    printf 'release_checksums=%s\n' 'RELEASE/SHA256SUMS.txt'
    printf 'docs_package=%s\n' "efuzy-docs-${VERSION}-${EDITION}.tar.gz"
    printf 'installer_package=%s\n' "efuzy-installer-${VERSION}-${EDITION}.tar.gz"
  } > "$STAGE_DIR/DELIVERY_MANIFEST.txt"
}

write_bundle_checksums() {
  local sumcmd
  sumcmd="$(checksum_cmd)"
  (
    cd "$STAGE_DIR"
    : > DELIVERY_SHA256SUMS.txt
    while IFS= read -r rel; do
      eval "$sumcmd \"$rel\"" >> DELIVERY_SHA256SUMS.txt
    done < <(find . -maxdepth 2 -type f ! -name 'DELIVERY_SHA256SUMS.txt' | sed 's#^./##' | sort)
  )
}

archive_bundle() {
  tar -C "$OUT_DIR" -czf "$OUT_DIR/${BUNDLE_NAME}.tar.gz" "$BUNDLE_NAME"
  if [[ "$INCLUDE_ZIP" == "1" ]] && command -v zip >/dev/null 2>&1; then
    (
      cd "$OUT_DIR"
      rm -f "${BUNDLE_NAME}.zip"
      zip -qr "${BUNDLE_NAME}.zip" "$BUNDLE_NAME"
    )
  fi
}

main() {
  parse_args "$@"
  verify_inputs
  prepare_paths
  copy_release_assets
  copy_docs_assets
  copy_installer_assets
  build_nested_packages
  write_start_here
  write_delivery_notice
  write_delivery_manifest
  write_bundle_checksums
  archive_bundle
  log "Delivery bundle written to $STAGE_DIR"
}

main "$@"
