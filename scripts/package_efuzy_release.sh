#!/usr/bin/env bash
set -Eeuo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SELF_DIR/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$REPO_ROOT/VERSION" 2>/dev/null || true)"
EDITION="standard"
OUT_DIR="$REPO_ROOT/dist"
INCLUDE_ZIP="1"

usage() {
  cat <<'USAGE'
Usage:
  scripts/package_efuzy_release.sh [options]

Options:
  --repo-root <path>     Repo root. Default: parent of this script.
  --version <semver>     Release version. Default: contents of VERSION.
  --edition <name>       Edition tag. Default: standard.
  --out-dir <path>       Output directory. Default: <repo>/dist.
  --no-zip               Do not create .zip archive.
  -h, --help             Show this help.
USAGE
}

fail() { printf '[efuzy-release][ERROR] %s\n' "$*" >&2; exit 1; }
log() { printf '[efuzy-release] %s\n' "$*"; }
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

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo-root) REPO_ROOT="$2"; shift 2 ;;
      --version) VERSION="$2"; shift 2 ;;
      --edition) EDITION="$2"; shift 2 ;;
      --out-dir) OUT_DIR="$2"; shift 2 ;;
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
  [[ -f "$REPO_ROOT/docs/RELEASE_ENGINEERING.md" ]] || fail "Missing docs/RELEASE_ENGINEERING.md"
  [[ -f "$REPO_ROOT/scripts/install_efuzy.sh" ]] || fail "Missing scripts/install_efuzy.sh"
  [[ -d "$REPO_ROOT/routines" ]] || fail "Missing routines directory"
  [[ -d "$REPO_ROOT/templates" ]] || fail "Missing templates directory"
}

prepare_dirs() {
  mkdir -p "$OUT_DIR"
  STAGE_DIR="$OUT_DIR/efuzy-${VERSION}-${EDITION}"
  rm -rf "$STAGE_DIR"
  mkdir -p "$STAGE_DIR"
}

copy_repo() {
  log "Staging repository into $STAGE_DIR"
  (
    cd "$REPO_ROOT"
    tar \
      --exclude='./.git' \
      --exclude='./dist' \
      --exclude='./tmp' \
      --exclude='./instance' \
      --exclude='./.DS_Store' \
      --exclude='./*.o' \
      -cf - .
  ) | (
    cd "$STAGE_DIR"
    tar -xf -
  )
}

write_manifest() {
  local manifest="$STAGE_DIR/RELEASE_MANIFEST.txt"
  cat > "$manifest" <<MANIFEST
app=efuzy
version=$VERSION
edition=$EDITION
built_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
package_name=efuzy-${VERSION}-${EDITION}
archive_tar_gz=efuzy-${VERSION}-${EDITION}.tar.gz
archive_zip=efuzy-${VERSION}-${EDITION}.zip
checksums=SHA256SUMS.txt
MANIFEST
}

write_release_notes() {
  local notes="$STAGE_DIR/RELEASE_NOTES.txt"
  cat > "$notes" <<NOTES
EFUZY release $VERSION ($EDITION)

Included:
- application source tree
- installer script
- config templates
- templates and routines
- release manifest
- checksums
- changelog
- release engineering docs

Recommended first steps:
1. Read README.md
2. Read docs/RELEASE_ENGINEERING.md
3. Run scripts/install_efuzy.sh
4. Compile in your target YottaDB environment
5. Run smoke validation before customer delivery
NOTES
}

create_archives() {
  TAR_PATH="$OUT_DIR/efuzy-${VERSION}-${EDITION}.tar.gz"
  ZIP_PATH="$OUT_DIR/efuzy-${VERSION}-${EDITION}.zip"
  log "Creating tar.gz archive"
  tar -C "$OUT_DIR" -czf "$TAR_PATH" "efuzy-${VERSION}-${EDITION}"
  if [[ "$INCLUDE_ZIP" == "1" ]]; then
    if command -v zip >/dev/null 2>&1; then
      log "Creating zip archive"
      (
        cd "$OUT_DIR"
        rm -f "$ZIP_PATH"
        zip -qr "$ZIP_PATH" "efuzy-${VERSION}-${EDITION}"
      )
    else
      log "zip not installed. Skipping zip archive."
    fi
  fi
}

write_checksums() {
  local sumcmd
  sumcmd="$(checksum_cmd)"
  local sums="$OUT_DIR/SHA256SUMS.txt"
  : > "$sums"
  (
    cd "$OUT_DIR"
    eval "$sumcmd \"$(basename "$TAR_PATH")\"" >> "$sums"
    if [[ -f "$ZIP_PATH" ]]; then
      eval "$sumcmd \"$(basename "$ZIP_PATH")\"" >> "$sums"
    fi
  )
}

main() {
  parse_args "$@"
  verify_inputs
  prepare_dirs
  copy_repo
  write_manifest
  write_release_notes
  create_archives
  write_checksums
  log "Release artifacts written to $OUT_DIR"
}

main "$@"
