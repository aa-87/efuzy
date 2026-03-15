#!/usr/bin/env bash
set -Eeuo pipefail

APP_NAME="efuzy"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="8081"
YDB_ENV_FILE="${EFUZY_YDB_ENV_FILE:-}"
SKIP_COMPILE="0"
ENV_FILE=""
LICENSE_MODE="demo"
LICENSE_FILE="instance/license/efuzy.license"

usage() {
  cat <<USAGE
Usage:
  scripts/install_efuzy.sh [options]

Options:
  --repo-root <path>       Existing EFUZY repo root. Default: current repo.
  --port <port>            Update server.listen.port in config/mws.conf.json. Default: 8081.
  --ydb-env-file <path>    Path to ydb_env_set.
  --env-file <path>        Output env file. Default: <repo>/instance/env/efuzy.env.
  --license-mode <mode>    demo, evaluation, or paid. Default: demo.
  --license-file <path>    License file path stored in config. Default: instance/license/efuzy.license.
  --skip-compile           Create layout and env file, but skip compilation.
  -h, --help               Show this help.

Notes:
  - This installer assumes the repository already exists.
  - It does not clone the repo.
  - It bootstraps the local runtime tree under tmp/efuzy.
  - Demo mode is license-free.
  - Evaluation and paid modes require a valid local license file on startup.
USAGE
}

log() { printf '[%s] %s\n' "$APP_NAME" "$*"; }
fail() { printf '[%s][ERROR] %s\n' "$APP_NAME" "$*" >&2; exit 1; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"; }

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo-root) REPO_ROOT="$2"; shift 2 ;;
      --port) PORT="$2"; shift 2 ;;
      --ydb-env-file) YDB_ENV_FILE="$2"; shift 2 ;;
      --env-file) ENV_FILE="$2"; shift 2 ;;
      --license-mode) LICENSE_MODE="$2"; shift 2 ;;
      --license-file) LICENSE_FILE="$2"; shift 2 ;;
      --skip-compile) SKIP_COMPILE="1"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) fail "Unknown argument: $1" ;;
    esac
  done
}

resolve_ydb_env_file() {
  local candidate

  if [[ -n "$YDB_ENV_FILE" && -f "$YDB_ENV_FILE" ]]; then
    printf '%s\n' "$YDB_ENV_FILE"
    return 0
  fi

  for candidate in /usr/local/etc/ydb_env_set /usr/local/lib/yottadb/*/ydb_env_set /opt/yottadb/*/ydb_env_set; do
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  if command -v find >/dev/null 2>&1; then
    candidate="$(find /usr/local /opt -type f -name ydb_env_set 2>/dev/null | sort | tail -n 1 || true)"
    if [[ -n "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  fi

  fail "Could not locate ydb_env_set. Pass --ydb-env-file explicitly."
}

validate_repo() {
  [[ -d "$REPO_ROOT/routines" ]] || fail "Missing routines directory under $REPO_ROOT"
  [[ -d "$REPO_ROOT/scripts" ]] || fail "Missing scripts directory under $REPO_ROOT"
  [[ -f "$REPO_ROOT/config/mws.conf.json" ]] || fail "Missing config/mws.conf.json under $REPO_ROOT"
}

create_layout() {
  mkdir -p \
    "$REPO_ROOT/tmp/efuzy/uploads" \
    "$REPO_ROOT/tmp/efuzy/staged" \
    "$REPO_ROOT/tmp/efuzy/jobs" \
    "$REPO_ROOT/tmp/efuzy/exports" \
    "$REPO_ROOT/tmp/efuzy/reports" \
    "$REPO_ROOT/tmp/efuzy/log" \
    "$REPO_ROOT/tmp/efuzy/run" \
    "$REPO_ROOT/tmp/efuzy/cache" \
    "$REPO_ROOT/tmp/efuzy/tmp" \
    "$REPO_ROOT/tmp/efuzy/work" \
    "$REPO_ROOT/tmp/efuzy/logs" \
    "$REPO_ROOT/instance/env" \
    "$REPO_ROOT/instance/tmp" \
    "$REPO_ROOT/instance/license"
}

write_env_file() {
  local ydb_env_set="$1"
  local env_path="$2"

  {
    printf 'export EFUZY_REPO_ROOT="%s"\n' "$REPO_ROOT"
    printf 'export EFUZY_RUNTIME_ROOT="tmp/efuzy"\n'
    printf 'export EFUZY_LOG_DIR="%s"\n' "$REPO_ROOT/tmp/efuzy/log"
    printf 'export EFUZY_LICENSE_MODE="%s"\n' "$LICENSE_MODE"
    printf 'export EFUZY_LICENSE_FILE="%s"\n' "$LICENSE_FILE"
    printf 'export MWS_CONF="%s"\n' "$REPO_ROOT/config/mws.conf.json"
    printf 'source "%s"\n' "$ydb_env_set"
    printf 'export ydb_routines="%s ${ydb_routines:-}"\n' "$REPO_ROOT/routines"
    printf 'cd "%s"\n' "$REPO_ROOT"
  } > "$env_path"
  chmod 0644 "$env_path"
}

seed_install_id() {
  local id_path="$REPO_ROOT/instance/license/efuzy.install_id"
  python - "$id_path" <<'PY'
from pathlib import Path
import sys
import uuid

path = Path(sys.argv[1])
path.parent.mkdir(parents=True, exist_ok=True)
if not path.exists() or not path.read_text().strip():
    path.write_text(str(uuid.uuid4()) + "\n")
PY
}

update_config() {
  local config_path="$REPO_ROOT/config/mws.conf.json"
  python - "$config_path" "$PORT" "$LICENSE_MODE" "$LICENSE_FILE" <<'PY'
import json
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
port = int(sys.argv[2])
license_mode = sys.argv[3].strip().lower()
license_file = sys.argv[4].strip() or "instance/license/efuzy.license"
if license_mode not in {"demo", "evaluation", "paid"}:
    raise SystemExit(f"Unsupported license mode: {license_mode}")

data = json.loads(config_path.read_text())
server = data.setdefault("server", {})
listen = server.setdefault("listen", {})
listen["port"] = port
server.setdefault("templateDir", "templates")

efuzy = data.setdefault("efuzy", {})
efuzy["rootDir"] = "tmp/efuzy"
ret = efuzy.setdefault("retention", {})
ret.setdefault("uploadsDays", 2)
ret.setdefault("jobsDays", 30)
ret.setdefault("allowDeletePublished", 0)
lic = efuzy.setdefault("license", {})
lic["mode"] = license_mode
lic["edition"] = {"demo": "demo", "evaluation": "evaluation", "paid": "standard"}[license_mode]
lic["filePath"] = license_file
lic["installIdPath"] = "instance/license/efuzy.install_id"
lic["hostStrategy"] = lic.get("hostStrategy", "none") or "none"
lic["product"] = "efuzy"
lic["requireValidOnStartup"] = 0 if license_mode == "demo" else 1

config_path.write_text(json.dumps(data, indent=2) + "\n")
PY
}

resolve_license_path() {
  if [[ "$LICENSE_FILE" = /* ]]; then
    printf "%s\n" "$LICENSE_FILE"
  else
    printf "%s/%s\n" "$REPO_ROOT" "$LICENSE_FILE"
  fi
}

main() {
  parse_args "$@"
  need_cmd python
  validate_repo
  create_layout

  local ydb_env_set
  ydb_env_set="$(resolve_ydb_env_file)"

  if [[ -z "$ENV_FILE" ]]; then
    ENV_FILE="$REPO_ROOT/instance/env/efuzy.env"
  fi

  log "Using repo root: $REPO_ROOT"
  log "Using ydb_env_set: $ydb_env_set"
  log "Using license mode: $LICENSE_MODE"
  write_env_file "$ydb_env_set" "$ENV_FILE"
  seed_install_id
  update_config

  if [[ "$SKIP_COMPILE" != "1" ]]; then
    local effective_license
    effective_license="$(resolve_license_path)"
    log "Compiling routines"
    bash "$REPO_ROOT/scripts/compile_efuzy.sh"
    if [[ "$LICENSE_MODE" != "demo" && ! -f "$effective_license" ]]; then
      log "Skipping bootstrap status check until license file exists: $effective_license"
    else
      log "Running bootstrap status check"
      bash "$REPO_ROOT/scripts/check_efuzy.sh" --status
    fi
  else
    log "Skipping compile by request"
    log "Skipping status check because routines were not compiled"
  fi

  cat <<EOF_DONE

Installation complete.

Env file:
  $ENV_FILE

Runtime root:
  $REPO_ROOT/tmp/efuzy

Install id file:
  $REPO_ROOT/instance/license/efuzy.install_id

License mode:
  $LICENSE_MODE

Next steps:
  bash "$REPO_ROOT/scripts/start_efuzy.sh"
  bash "$REPO_ROOT/scripts/check_efuzy.sh" --ready

EOF_DONE
}

main "$@"
