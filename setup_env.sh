#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/backend/app"

python3 -m venv env
source env/bin/activate
pip install -r requirements.txt

cp .env.example .env 2>/dev/null || true

if command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter dependencies"
  (cd "$SCRIPT_DIR/frontend" && flutter pub get)
else
  echo "Flutter not found. Skipping flutter pub get"
fi

echo "Environment ready. Activate with: source backend/app/env/bin/activate"
