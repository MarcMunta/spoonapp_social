#!/bin/bash

echo "📦 Configurando SpoonApp en macOS..."

# Verificar si está en macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Este script está diseñado solo para macOS."
    exit 1
fi

# Directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Usar Python 3.12 si existe
PYTHON_BIN=$(which python3.12 || which python3)
echo "🐍 Usando intérprete de Python: $PYTHON_BIN"

# Crear entorno si no existe
if [ ! -d "env" ]; then
    echo "✨ Creando entorno virtual 'env'..."
    $PYTHON_BIN -m venv env
else
    echo "✅ Entorno virtual 'env' ya existe."
fi

# Activar entorno
source env/bin/activate

# Instalar dependencias
if [ -f "requirements.txt" ]; then
    echo "📥 Instalando dependencias desde requirements.txt..."
    pip install -r requirements.txt
else
    echo "⚠️ requirements.txt no encontrado. Instalando dependencias básicas..."
    pip install django requests googletrans==4.0.0rc1
fi

# Lanzar servidor
echo "🚀 Iniciando servidor de desarrollo..."
python manage.py runserver
