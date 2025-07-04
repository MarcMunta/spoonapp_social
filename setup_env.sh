#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Choose python executable cross-platform
PYTHON_BIN="$(command -v python3 || command -v python)"
if [ -z "$PYTHON_BIN" ]; then
  echo "Python is required but was not found" >&2
  exit 1
fi

cd "$SCRIPT_DIR/backend/app"

# Create virtual environment
$PYTHON_BIN -m venv env

# Activate depending on platform
if [ -f env/bin/activate ]; then
  source env/bin/activate
else
  # Windows Git Bash / PowerShell
  source env/Scripts/activate
fi

pip install -r requirements.txt

cp .env.example .env 2>/dev/null || true

# Install Flutter dependencies only if Flutter is available
if command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter dependencies"
  (cd "$SCRIPT_DIR/frontend" && flutter pub get)
fi

RUN_FLAG=false
if [[ "$1" == "--start" ]]; then
  RUN_FLAG=true
fi

if [ "$RUN_FLAG" = true ]; then
  echo "Starting backend..."
  uvicorn main:app --reload &
  BACKEND_PID=$!
  # Launch Flutter in Chrome only if it is available
  if command -v flutter >/dev/null 2>&1; then
    echo "Starting Flutter app in Chrome..."
    (cd "$SCRIPT_DIR/frontend" && flutter run -d chrome) &
    FLUTTER_PID=$!
    wait $FLUTTER_PID
  else
    wait $BACKEND_PID
  fi
else
  echo "Environment ready. Activate with: source backend/app/env/bin/activate (Unix) or backend\\app\\env\\Scripts\\activate (Windows)"
  echo "Run './setup_env.sh --start' to launch the backend and Flutter app"
fi
