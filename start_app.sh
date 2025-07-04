#!/usr/bin/env bash

# Conveniente script para iniciar el backend y el frontend
# tras instalar todas las dependencias necesarias.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Asegurar que el entorno está configurado
"$SCRIPT_DIR/setup_env.sh"

BACKEND_DIR="$SCRIPT_DIR/backend/app"

# Activar entorno virtual
if [ -f "$BACKEND_DIR/env/bin/activate" ]; then
  source "$BACKEND_DIR/env/bin/activate"
else
  source "$BACKEND_DIR/env/Scripts/activate"
fi

# Arrancar el backend en la terminal actual
cd "$BACKEND_DIR"
echo "Iniciando backend..."
uvicorn main:app --reload &
BACKEND_PID=$!
cd "$SCRIPT_DIR"

# Comando para el frontend
FRONTEND_CMD="cd \"$SCRIPT_DIR/frontend\" && flutter run -d chrome"

# Abrir nueva terminal si es posible
if command -v gnome-terminal >/dev/null 2>&1; then
  echo "Abriendo ventana para el frontend..."
  gnome-terminal -- bash -c "$FRONTEND_CMD; exec bash"
else
  # Si no hay terminal gráfica disponible, ejecutar en la actual
  eval "$FRONTEND_CMD"
fi

# Esperar a que el backend finalice cuando se cierre el frontend
wait $BACKEND_PID
