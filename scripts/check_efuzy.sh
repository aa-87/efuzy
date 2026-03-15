#!/usr/bin/env bash
set -Eeuo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SELF_DIR/.." && pwd)"
ENV_FILE="$ROOT/instance/env/efuzy.env"
MODE="ready"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --status) MODE="status"; shift ;;
    --ready) MODE="ready"; shift ;;
    *) echo "[efuzy] unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ ! -f "$ENV_FILE" ]]; then
  echo "[efuzy] missing env file: $ENV_FILE" >&2
  echo "[efuzy] run scripts/install_efuzy.sh first" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"
cd "$ROOT"

if ! command -v yottadb >/dev/null 2>&1; then
  echo "[efuzy] yottadb command not found" >&2
  exit 1
fi

cmdfile="$ROOT/instance/tmp/check_efuzy_$$_$(date +%s).m"
outfile="$ROOT/instance/tmp/check_efuzy_$$_$(date +%s).out"
trap 'rm -f "$cmdfile" "$outfile"' EXIT

{
  printf 'N CONF,RES,MODE,NAME\n'
  printf 'S MODE="%s"\n' "$MODE"
  cat <<'YDB'
D BOOTCONF^MIO(.CONF)
I MODE="status" D STATUS^EFUZYHEALTH(.CONF,.RES)
E  D READY^EFUZYHEALTH(.CONF,.RES)
W "ok=",+$G(RES("ok")),!
W "status=",$G(RES("status")),!
W "root=",$G(RES("root")),!
I $G(RES("error"))'="" W "error=",$G(RES("error")),!
S NAME=""
F  S NAME=$O(RES("checks",NAME)) Q:NAME=""  D
. W "check.",NAME,"=",+$G(RES("checks",NAME,"ok"))
. I $G(RES("checks",NAME,"info"))'="" W "|",$G(RES("checks",NAME,"info"))
. W !
HALT
YDB
} > "$cmdfile"

yottadb -direct < "$cmdfile" | tee "$outfile"

grep -q '^ok=1$' "$outfile"
