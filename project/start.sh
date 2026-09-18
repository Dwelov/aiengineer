#!/usr/bin/env bash
#
# start.sh — run backend (FastAPI/uvicorn) + frontend (Next.js) together.
#
# Usage:
#   ./start.sh                  # run both backend + frontend
#   ./start.sh --backend-only   # run only backend
#   ./start.sh --frontend-only  # run only frontend
#   ./start.sh --help           # show help
#
# Env overrides:
#   BACKEND_PORT=8000 FRONTEND_PORT=3000 BACKEND_HOST=0.0.0.0 ./start.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT/backend"
FRONTEND_DIR="$ROOT/frontend/app"

BACKEND_HOST="${BACKEND_HOST:-0.0.0.0}"
BACKEND_PORT="${BACKEND_PORT:-8000}"
FRONTEND_PORT="${FRONTEND_PORT:-3000}"
FRONTEND_HOST="${FRONTEND_HOST:-0.0.0.0}"

RUN_BACKEND=true
RUN_FRONTEND=true

print_help() {
  sed -n '2,12p' "$0" | sed 's/^# \?//'
}

for arg in "$@"; do
  case "$arg" in
    --backend-only)  RUN_FRONTEND=false ;;
    --frontend-only) RUN_BACKEND=false ;;
    -h|--help|help)  print_help; exit 0 ;;
    *) echo "Unknown option: $arg (see --help)" >&2; exit 1 ;;
  esac
done

log()  { printf '\033[1;34m[%s]\033[0m %s\n' "$1" "$2"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$1" >&2; }
die()  { printf '\033[1;31m[error]\033[0m %s\n' "$1" >&2; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command '$1' not found. Please install it first."
}

PIDS=()
cleanup() {
  echo ""
  log "shutdown" "Stopping ${#PIDS[@]} process(es)..."
  for pid in ${PIDS[@]+"${PIDS[@]}"}; do
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
    fi
  done
  wait 2>/dev/null || true
  log "shutdown" "All stopped."
}
trap cleanup SIGINT SIGTERM EXIT

# --- Backend ---------------------------------------------------------------
# Detects a FastAPI app object so this works as backend code grows:
#   src/backend/main.py  -> module backend.main:app  (PYTHONPATH=src)
#   src/backend/app.py   -> module backend.app:app
#   src/backend/api.py   -> module backend.api:app
#   backend/main.py, main.py, app.py (repo-root style)
detect_backend_app() {
  local candidates=(
    "src/backend/main.py:backend.main:app"
    "src/backend/app.py:backend.app:app"
    "src/backend/api.py:backend.api:app"
    "src/backend/server.py:backend.server:app"
    "backend/main.py:backend.main:app"
    "backend/app.py:backend.app:app"
    "src/main.py:main:app"
    "src/app.py:app:app"
    "main.py:main:app"
    "app.py:app:app"
  )
  local entry file module
  for entry in "${candidates[@]}"; do
    file="${entry%%:*}"
    module="${entry##*:}"
    if [[ -f "$BACKEND_DIR/$file" ]] && grep -qE "^\s*app\s*=\s*FastAPI\(|FastAPI\(" "$BACKEND_DIR/$file" 2>/dev/null; then
      echo "$module"
      return 0
    fi
  done
  # Fallback: any file under src/ that defines `app = FastAPI(`
  local found
  found="$(grep -rlE "^\s*app\s*=\s*FastAPI\(" "$BACKEND_DIR/src" 2>/dev/null | head -n 1 || true)"
  if [[ -n "${found:-}" ]]; then
    # src/backend/foo.py -> backend.foo:app
    local rel="${found#"$BACKEND_DIR/src/"}"
    rel="${rel%.py}"
    rel="${rel//\//.}"
    echo "$rel:app"
    return 0
  fi
  return 1
}

start_backend() {
  [[ -d "$BACKEND_DIR" ]] || die "Backend dir not found: $BACKEND_DIR"
  [[ -f "$BACKEND_DIR/pyproject.toml" ]] || warn "No backend/pyproject.toml found — continuing anyway."

  (
    cd "$BACKEND_DIR"

    # Install / sync deps
    if command -v uv >/dev/null 2>&1; then
      log "backend" "Syncing Python deps with uv..."
      uv sync
    elif [[ -f ".venv/bin/activate" ]]; then
      # shellcheck disable=SC1091
      source ".venv/bin/activate"
      log "backend" "Using existing .venv (uv not found)."
    else
      warn "'uv' not found — creating .venv with stdlib venv and pip."
      need_cmd python3
      python3 -m venv .venv
      # shellcheck disable=SC1091
      source ".venv/bin/activate"
      pip install --upgrade pip
      if [[ -f "requirements.txt" ]]; then
        pip install -r requirements.txt
      else
        pip install -e ".[dev]" 2>/dev/null || pip install -e . 2>/dev/null || warn "Could not pip-install backend package; hoping deps exist."
      fi
    fi

    APP_MODULE="$(detect_backend_app || true)"
    export PYTHONPATH="$BACKEND_DIR/src:${PYTHONPATH:-}"

    if [[ -n "${APP_MODULE:-}" ]]; then
      log "backend" "Starting FastAPI (uvicorn $APP_MODULE) on $BACKEND_HOST:$BACKEND_PORT ..."
      if command -v uv >/dev/null 2>&1; then
        exec uv run uvicorn "$APP_MODULE" --host "$BACKEND_HOST" --port "$BACKEND_PORT" --reload
      else
        # shellcheck disable=SC1091
        [[ -f ".venv/bin/activate" ]] && source ".venv/bin/activate"
        exec python -m uvicorn "$APP_MODULE" --host "$BACKEND_HOST" --port "$BACKEND_PORT" --reload
      fi
    else
      warn "No FastAPI 'app' object found (looked for src/backend/main.py etc.)."
      warn "Running 'uv run backend' fallback so the process still starts."
      warn "To enable uvicorn, create backend/src/backend/main.py with:  app = FastAPI()"
      if command -v uv >/dev/null 2>&1; then
        exec uv run backend
      else
        # shellcheck disable=SC1091
        [[ -f ".venv/bin/activate" ]] && source ".venv/bin/activate"
        exec python -m backend 2>/dev/null || python -c "import backend; backend.main()"
      fi
    fi
  ) &
  PIDS+=($!)
}

# --- Frontend --------------------------------------------------------------
start_frontend() {
  [[ -d "$FRONTEND_DIR" ]] || die "Frontend dir not found: $FRONTEND_DIR (expected $FRONTEND_DIR)"
  [[ -f "$FRONTEND_DIR/package.json" ]] || die "No package.json in $FRONTEND_DIR"

  (
    cd "$FRONTEND_DIR"
    need_cmd npm

    if [[ ! -d "node_modules" ]]; then
      log "frontend" "node_modules missing — installing..."
      if [[ -f "package-lock.json" ]]; then
        npm ci
      else
        npm install
      fi
    fi

    log "frontend" "Starting Next.js dev server on $FRONTEND_HOST:$FRONTEND_PORT ..."
    export PORT="$FRONTEND_PORT"
    export HOSTNAME="$FRONTEND_HOST"
    exec npm run dev -- --port "$FRONTEND_PORT" --hostname "$FRONTEND_HOST"
  ) &
  PIDS+=($!)
}

# --- Main ------------------------------------------------------------------
log "start" "Project root: $ROOT"
$RUN_BACKEND  && start_backend
$RUN_FRONTEND && start_frontend

if [[ "$RUN_BACKEND" == true && "$RUN_FRONTEND" == true ]]; then
  log "start" "Backend  -> http://localhost:$BACKEND_PORT"
  log "start" "Frontend -> http://localhost:$FRONTEND_PORT"
  log "start" "Press Ctrl+C to stop both."
elif [[ "$RUN_BACKEND" == true ]]; then
  log "start" "Backend only -> http://localhost:$BACKEND_PORT"
else
  log "start" "Frontend only -> http://localhost:$FRONTEND_PORT"
fi

wait
