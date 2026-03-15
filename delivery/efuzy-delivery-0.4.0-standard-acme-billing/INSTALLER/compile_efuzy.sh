#!/usr/bin/env bash
set -Eeuo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SELF_DIR/.." && pwd)"
ENV_FILE="$ROOT/instance/env/efuzy.env"

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

cmdfile="$ROOT/instance/tmp/compile_efuzy_$$_$(date +%s).m"
trap 'rm -f "$cmdfile"' EXIT

find routines -maxdepth 1 -type f -name '*.m' | sort | while IFS= read -r file; do
  printf 'ZCOMPILE "%s"\n' "$file"
done > "$cmdfile"
printf 'HALT\n' >> "$cmdfile"

yottadb -direct < "$cmdfile"
