#!/usr/bin/env bash
set -Eeuo pipefail

APP_NAME="efuzy"
INSTALL_ROOT="${HOME}/efuzy-app"
PORT="8081"
REPO_URL=""
REPO_BRANCH=""
YDB_INSTALL_DIR="/opt/yottadb/efuzy"
SKIP_YDB="0"
SKIP_COMPILE="0"
FORCE_CLONE="0"

usage() {
  cat <<'EOF'
Usage:
  install_efuzy.sh --repo-url <git-url> [options]

Options:
  --repo-url <url>        Git URL for the EFUZY repository. Required.
  --branch <name>         Optional Git branch or tag.
  --install-root <path>   Install root. Default: $HOME/efuzy-app
  --port <port>           HTTP listen port. Default: 8081
  --ydb-install-dir <p>   YottaDB install dir. Default: /opt/yottadb/efuzy
  --skip-yottadb          Do not install YottaDB.
  --skip-compile          Create environment and helper scripts, but do not compile routines.
  --force-clone           Remove existing repo directory before cloning.
  -h, --help              Show this help.

Examples:
  ./install_efuzy.sh --repo-url https://example.com/your/efuzy.git
  ./install_efuzy.sh --repo-url https://example.com/your/efuzy.git --branch main --install-root "$HOME/efuzy-prod" --port 8081
EOF
}

log() { printf '[%s] %s\n' "$APP_NAME" "$*"; }
fail() { printf '[%s][ERROR] %s\n' "$APP_NAME" "$*" >&2; exit 1; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"; }
run_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo-url) REPO_URL="$2"; shift 2 ;;
      --branch) REPO_BRANCH="$2"; shift 2 ;;
      --install-root) INSTALL_ROOT="$2"; shift 2 ;;
      --port) PORT="$2"; shift 2 ;;
      --ydb-install-dir) YDB_INSTALL_DIR="$2"; shift 2 ;;
      --skip-yottadb) SKIP_YDB="1"; shift ;;
      --skip-compile) SKIP_COMPILE="1"; shift ;;
      --force-clone) FORCE_CLONE="1"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) fail "Unknown argument: $1" ;;
    esac
  done

  [[ -n "$REPO_URL" ]] || fail "--repo-url is required"
}

detect_pkg_manager() {
  if command -v apt-get >/dev/null 2>&1; then
    echo apt
  elif command -v dnf >/dev/null 2>&1; then
    echo dnf
  elif command -v yum >/dev/null 2>&1; then
    echo yum
  else
    fail "Supported package manager not found (apt, dnf, yum)"
  fi
}

install_prereqs() {
  local pm
  pm="$(detect_pkg_manager)"
  log "Installing prerequisite packages with $pm"

  case "$pm" in
    apt)
      run_root apt-get update
      run_root apt-get install -y --no-install-recommends \
        file binutils libelf-dev libicu-dev nano wget curl git ca-certificates \
        findutils gzip procps pkg-config unzip make gcc
      ;;
    dnf)
      run_root dnf install -y \
        file binutils findutils elfutils-libelf-devel libicu wget curl git \
        ca-certificates procps-ng nano gzip pkgconf-pkg-config unzip make gcc
      ;;
    yum)
      run_root yum install -y \
        file binutils findutils elfutils-libelf-devel libicu wget curl git \
        ca-certificates procps-ng nano gzip pkgconfig unzip make gcc
      ;;
  esac
}

warn_removeipc() {
  if [[ -f /etc/systemd/logind.conf ]] && grep -Eq '^\s*RemoveIPC\s*=\s*yes' /etc/systemd/logind.conf; then
    log "WARNING: /etc/systemd/logind.conf has RemoveIPC=yes. YottaDB documents require RemoveIPC=no on systemd systems."
  fi
}

install_yottadb() {
  [[ "$SKIP_YDB" == "1" ]] && { log "Skipping YottaDB install by request"; return 0; }

  install_prereqs
  warn_removeipc

  local workdir script
  workdir="$(mktemp -d)"
  script="$workdir/ydbinstall.sh"
  trap 'rm -rf "$workdir"' RETURN

  log "Downloading ydbinstall.sh"
  curl -fsSL https://download.yottadb.com/ydbinstall.sh -o "$script"
  chmod +x "$script"

  log "Installing YottaDB into $YDB_INSTALL_DIR"
  run_root --preserve-env=ydb_icu_version "$script" --installdir "$YDB_INSTALL_DIR" --utf8 --verbose
}

resolve_ydb_env_set() {
  local candidate prefix

  if command -v pkg-config >/dev/null 2>&1 && pkg-config --exists yottadb 2>/dev/null; then
    prefix="$(pkg-config --variable=prefix yottadb)"
    candidate="$prefix/ydb_env_set"
    [[ -f "$candidate" ]] && { printf '%s\n' "$candidate"; return 0; }
  fi

  for candidate in /usr/local/etc/ydb_env_set /usr/local/lib/yottadb/*/ydb_env_set "$YDB_INSTALL_DIR"/ydb_env_set; do
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  candidate="$(find /usr/local /opt -type f -name ydb_env_set 2>/dev/null | sort | tail -n 1 || true)"
  [[ -n "$candidate" ]] || fail "Could not locate ydb_env_set after install"
  printf '%s\n' "$candidate"
}

clone_repo() {
  local repo_dir
  repo_dir="$INSTALL_ROOT/repo"
  mkdir -p "$INSTALL_ROOT"

  if [[ "$FORCE_CLONE" == "1" && -d "$repo_dir" ]]; then
    log "Removing existing repository directory"
    rm -rf "$repo_dir"
  fi

  if [[ -d "$repo_dir/.git" ]]; then
    log "Repository already exists. Updating"
    git -C "$repo_dir" fetch --all --tags --prune
    if [[ -n "$REPO_BRANCH" ]]; then
      git -C "$repo_dir" checkout "$REPO_BRANCH"
      git -C "$repo_dir" pull --ff-only origin "$REPO_BRANCH"
    else
      git -C "$repo_dir" pull --ff-only
    fi
  else
    log "Cloning repository"
    if [[ -n "$REPO_BRANCH" ]]; then
      git clone --branch "$REPO_BRANCH" --single-branch "$REPO_URL" "$repo_dir"
    else
      git clone "$REPO_URL" "$repo_dir"
    fi
  fi
}

create_layout() {
  mkdir -p \
    "$INSTALL_ROOT/tmp/efuzy/uploads" \
    "$INSTALL_ROOT/tmp/efuzy/jobs" \
    "$INSTALL_ROOT/tmp/efuzy/work" \
    "$INSTALL_ROOT/tmp/efuzy/exports" \
    "$INSTALL_ROOT/tmp/efuzy/logs" \
    "$INSTALL_ROOT/tmp/efuzy/run" \
    "$INSTALL_ROOT/instance/env" \
    "$INSTALL_ROOT/instance/logs" \
    "$INSTALL_ROOT/instance/tmp" \
    "$INSTALL_ROOT/instance/yottadb" \
    "$INSTALL_ROOT/scripts" \
    "$INSTALL_ROOT/repo/config"
}

write_env_file() {
  local ydb_env_set
  ydb_env_set="$1"

  cat > "$INSTALL_ROOT/instance/env/efuzy.env" <<EOF
export EFUZY_INSTALL_ROOT="$INSTALL_ROOT"
export EFUZY_REPO_ROOT="$INSTALL_ROOT/repo"
export EFUZY_DATA_ROOT="$INSTALL_ROOT/tmp/efuzy"
export ydb_dir="$INSTALL_ROOT/instance/yottadb"
export ydb_tmp="$INSTALL_ROOT/instance/tmp"
source "$ydb_env_set"
export ydb_log="$INSTALL_ROOT/tmp/efuzy/logs"
export MWS_CONF="$INSTALL_ROOT/repo/config/mws.conf.json"
export ydb_routines="$INSTALL_ROOT/repo/routines $ydb_routines"
cd "$INSTALL_ROOT/repo"
EOF
  chmod 0644 "$INSTALL_ROOT/instance/env/efuzy.env"
}

write_config() {
  cat > "$INSTALL_ROOT/repo/config/mws.conf.json" <<EOF
{
  "server": {
    "listen": { "port": $PORT },
    "templateDir": "templates",
    "static": {
      "enabled": 0,
      "root": "public",
      "mount": "/static"
    },
    "errors": {
      "enabled": 1,
      "maxEntries": 2000,
      "capture4xx": 1,
      "capture404": 1
    }
  },
  "efuzy": {
    "rootDir": "tmp/efuzy"
  }
}
EOF
}

write_helper_scripts() {
  cat > "$INSTALL_ROOT/scripts/compile_efuzy.sh" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SELF_DIR/.." && pwd)"
source "$ROOT/instance/env/efuzy.env"
cd "$ROOT/repo"
cmdfile="$ROOT/instance/tmp/compile_efuzy_$$_$(date +%s).m"
find routines -maxdepth 1 -type f -name '*.m' | sort | while IFS= read -r file; do
  printf 'ZCOMPILE "%s"\n' "$file"
done > "$cmdfile"
printf 'HALT\n' >> "$cmdfile"
yottadb -direct < "$cmdfile"
rm -f "$cmdfile"
EOF
  chmod +x "$INSTALL_ROOT/scripts/compile_efuzy.sh"

  cat > "$INSTALL_ROOT/scripts/start_efuzy.sh" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SELF_DIR/.." && pwd)"
source "$ROOT/instance/env/efuzy.env"
cd "$ROOT/repo"
yottadb -run start^MIO
EOF
  chmod +x "$INSTALL_ROOT/scripts/start_efuzy.sh"

  cat > "$INSTALL_ROOT/scripts/test_efuzy.sh" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SELF_DIR/.." && pwd)"
source "$ROOT/instance/env/efuzy.env"
cd "$ROOT/repo"
cat <<'YDB' | yottadb -direct
D ^EFUTESTS
D ^EFUZYTESTS
D ^EFUPRODT
HALT
YDB
EOF
  chmod +x "$INSTALL_ROOT/scripts/test_efuzy.sh"
}

main() {
  parse_args "$@"
  need_cmd git
  need_cmd curl

  install_yottadb
  clone_repo
  create_layout

  local ydb_env_set
  ydb_env_set="$(resolve_ydb_env_set)"
  write_env_file "$ydb_env_set"
  write_config
  write_helper_scripts

  if [[ "$SKIP_COMPILE" != "1" ]]; then
    log "Compiling routines"
    bash "$INSTALL_ROOT/scripts/compile_efuzy.sh"
  else
    log "Skipping compile by request"
  fi

  cat <<EOF

Installation complete.

Environment file:
  $INSTALL_ROOT/instance/env/efuzy.env

Compile helper:
  $INSTALL_ROOT/scripts/compile_efuzy.sh

Start helper:
  $INSTALL_ROOT/scripts/start_efuzy.sh

Test helper:
  $INSTALL_ROOT/scripts/test_efuzy.sh

Next steps:
  source "$INSTALL_ROOT/instance/env/efuzy.env"
  bash "$INSTALL_ROOT/scripts/compile_efuzy.sh"
  bash "$INSTALL_ROOT/scripts/start_efuzy.sh"

EOF
}

main "$@"
