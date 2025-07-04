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

if command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter dependencies"
  (cd "$SCRIPT_DIR/frontend" && flutter pub get)
else
  echo "Flutter not found. Skipping flutter pub get"
fi

echo "Environment ready. Activate with: source backend/app/env/bin/activate (Unix) or backend\\app\\env\\Scripts\\activate (Windows)"
