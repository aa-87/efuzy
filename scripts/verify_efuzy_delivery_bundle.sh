#!/usr/bin/env bash
set -Eeuo pipefail

BUNDLE_DIR=""

usage() {
  cat <<'USAGE'
Usage:
  scripts/verify_efuzy_delivery_bundle.sh --bundle-dir <path>
USAGE
}

fail() { printf '[efuzy-delivery-verify][ERROR] %s\n' "$*" >&2; exit 1; }
log() { printf '[efuzy-delivery-verify] %s\n' "$*"; }

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --bundle-dir) BUNDLE_DIR="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) fail "Unknown argument: $1" ;;
    esac
  done
}

req() {
  local p="$1"
  [[ -f "$BUNDLE_DIR/$p" ]] || fail "Missing required file: $p"
}

main() {
  parse_args "$@"
  [[ -n "$BUNDLE_DIR" ]] || fail "--bundle-dir is required"
  [[ -d "$BUNDLE_DIR" ]] || fail "Bundle directory not found: $BUNDLE_DIR"
  req START_HERE.txt
  req DELIVERY_NOTICE.txt
  req DELIVERY_MANIFEST.txt
  req DELIVERY_SHA256SUMS.txt
  req RELEASE/SHA256SUMS.txt
  req DOCS/INSTALL_GUIDE.md
  req DOCS/ADMIN_GUIDE.md
  req DOCS/LICENSING.md
  req DOCS/DELIVERY_GUIDE.md
  req DOCS/BUYER_HANDOFF_CHECKLIST.md
  docs_pkg=$(find "$BUNDLE_DIR" -maxdepth 1 -type f -name 'efuzy-docs-*.tar.gz' | head -n 1 || true)
  [[ -n "$docs_pkg" ]] || fail "Missing docs package archive"
  installer_pkg=$(find "$BUNDLE_DIR" -maxdepth 1 -type f -name 'efuzy-installer-*.tar.gz' | head -n 1 || true)
  [[ -n "$installer_pkg" ]] || fail "Missing installer package archive"
  req INSTALLER/install_efuzy.sh
  req INSTALLER/compile_efuzy.sh
  req INSTALLER/check_efuzy.sh
  req INSTALLER/start_efuzy.sh
  log "Delivery bundle looks complete: $BUNDLE_DIR"
}

main "$@"
