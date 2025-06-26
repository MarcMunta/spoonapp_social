#!/bin/bash

# Remove previous virtual environment if it exists
if [ -d "env" ]; then
  rm -rf env
  echo "Previous virtual environment removed."
fi

# Create a new virtual environment
python3 -m venv env
echo "Virtual environment created."

# Activate the virtual environment
source env/bin/activate

# Install requirements if the file exists
if [ -f "./backend/requirements.txt" ]; then
  pip3 install -r ./backend/requirements.txt
  echo "Dependencies installed from requirements.txt"
else
  echo "requirements.txt not found"
fi

# Ensure googletrans is installed even if requirements are missing
if ! pip3 show googletrans > /dev/null 2>&1; then
  pip3 install googletrans==4.0.0-rc1
  echo "googletrans installed."
fi

# Ensure requests is installed even if requirements are missing
if ! pip3 show requests > /dev/null 2>&1; then
  pip3 install requests
  echo "requests installed."
fi

# Compile translation files using msgfmt if available
MSGFMT_CMD="msgfmt"
if [ -x ./backend/tools/gettext/bin/msgfmt ]; then
  MSGFMT_CMD=./backend/tools/gettext/bin/msgfmt
elif [ -x ./backend/tools/gettext/bin/msgfmt.exe ]; then
  MSGFMT_CMD=./backend/tools/gettext/bin/msgfmt.exe
fi

if command -v "$MSGFMT_CMD" >/dev/null 2>&1 || [ -x "$MSGFMT_CMD" ]; then
  find ./locale -name '*.po' | while read -r po_file; do
    mo_file="${po_file%.po}.mo"
    "$MSGFMT_CMD" "$po_file" -o "$mo_file"
  done
  echo "Translation files compiled."
else
  echo "msgfmt not found; skipped translation compilation."
fi
