#!/usr/bin/env bash
# Simple wrapper to run the repository setup from the backend folder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
"$ROOT_DIR/setup_env.sh" "$@"
