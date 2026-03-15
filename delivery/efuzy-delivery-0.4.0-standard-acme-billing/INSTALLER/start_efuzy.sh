#!/usr/bin/env bash
set -Eeuo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SELF_DIR/.." && pwd)"
ENV_FILE="$ROOT/instance/env/efuzy.env"
LOG_FILE="$ROOT/tmp/efuzy/log/startup.log"

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

if "$ROOT/scripts/check_efuzy.sh" --ready >/dev/null 2>&1; then
  echo "[efuzy] already ready"
  exit 0
fi

mkdir -p "$ROOT/tmp/efuzy/log" "$ROOT/instance/tmp"

cmdfile="$ROOT/instance/tmp/startup_boot_$$_$(date +%s).m"
outfile="$ROOT/instance/tmp/startup_boot_$$_$(date +%s).out"
trap 'rm -f "$cmdfile" "$outfile"' EXIT

cat > "$cmdfile" <<'YDB'
N CONF,RES
D BOOTCONF^MIO(.CONF)
D STARTUP^EFUZYBOOT(.CONF,.RES)
W "ok=",+$G(RES("ok")),!
W "root=",$G(RES("root")),!
I $G(RES("error"))'="" W "error=",$G(RES("error")),!
HALT
YDB

yottadb -direct < "$cmdfile" | tee "$outfile"
if ! grep -q '^ok=1$' "$outfile"; then
  echo "[efuzy] bootstrap failed" >&2
  exit 1
fi

yottadb -run start^MIO >> "$LOG_FILE" 2>&1

if "$ROOT/scripts/check_efuzy.sh" --ready; then
  echo "[efuzy] started"
  exit 0
fi

echo "[efuzy] start completed but readiness failed" >&2
exit 1
