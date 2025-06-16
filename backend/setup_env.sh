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
