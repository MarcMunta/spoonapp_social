#!/bin/bash

if [ -d "env" ]; then
  rm -rf env
  echo "Entorno virtual anterior eliminado."
fi

python3 -m venv env
echo "Entorno virtual creado."

source env/bin/activate

if [ -f "./backend/requirements.txt" ]; then
  pip3 install -r ./backend/requirements.txt
  echo "Dependencias instaladas desde requirements.txt"
else
  echo "No se encontró requirements.txt"
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
  echo "Archivos de traducción compilados."
else
  echo "No se encontró msgfmt; se omitió la compilación de traducciones."
fi
