#!/usr/bin/env bash
set -Eeuo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SELF_DIR/.." && pwd)"
YDB_ENV_FILE="${YDB_ENV_FILE:-}"
SUITE="EFUZYTESTS"
DO_COMPILE="1"

usage() {
  cat <<'USAGE'
Usage:
  scripts/release_smoke_efuzy.sh [options]

Options:
  --ydb-env-file <path>  Path to ydb_env_set or equivalent shell env file.
  --suite <routine>      Smoke suite entry routine. Default: EFUZYTESTS.
  --skip-compile         Do not compile before smoke run.
  -h, --help             Show this help.
USAGE
}

fail() { printf '[efuzy-smoke][ERROR] %s\n' "$*" >&2; exit 1; }
log() { printf '[efuzy-smoke] %s\n' "$*"; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"; }

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --ydb-env-file) YDB_ENV_FILE="$2"; shift 2 ;;
      --suite) SUITE="$2"; shift 2 ;;
      --skip-compile) DO_COMPILE="0"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) fail "Unknown argument: $1" ;;
    esac
  done
}

load_env() {
  [[ -n "$YDB_ENV_FILE" ]] || fail "--ydb-env-file is required"
  [[ -f "$YDB_ENV_FILE" ]] || fail "Env file not found: $YDB_ENV_FILE"
  # shellcheck disable=SC1090
  source "$YDB_ENV_FILE"
  export ydb_routines="$REPO_ROOT/routines ${ydb_routines:-}"
  cd "$REPO_ROOT"
}

compile_if_needed() {
  [[ "$DO_COMPILE" == "1" ]] || return 0
  if [[ -x "$REPO_ROOT/scripts/compile_efuzy.sh" ]]; then
    log "Running compile_efuzy.sh"
    "$REPO_ROOT/scripts/compile_efuzy.sh"
  else
    log "compile_efuzy.sh not found. Skipping compile step."
  fi
}

run_suite() {
  need_cmd yottadb
  local cmdfile
  cmdfile="$REPO_ROOT/tmp/.efuzy_release_smoke_$$_$(date +%s).m"
  mkdir -p "$REPO_ROOT/tmp"
  cat > "$cmdfile" <<MEOF
D ^$SUITE
HALT
MEOF
  log "Running smoke suite ^$SUITE"
  yottadb -direct < "$cmdfile"
  rm -f "$cmdfile"
}

main() {
  parse_args "$@"
  load_env
  compile_if_needed
  run_suite
  log "Smoke validation complete"
}

main "$@"
