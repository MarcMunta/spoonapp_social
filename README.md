# SpoonApp Social

Este repositorio contiene el inicio de la migración de SpoonApp a un nuevo stack basado en Flutter para el frontend y FastAPI en el backend.

## Requisitos
- Flutter >= 3.x
- Dart >= 3.x
- Python 3.11

## Instalación rápida

```bash
./setup_env.sh
```

Esto creará un entorno virtual en `backend/app/env`, instalará las dependencias y generará un archivo `.env` de ejemplo.

Para el frontend ejecuta:

```bash
cd frontend
flutter pub get
```

## Ejecución en desarrollo

Backend FastAPI:

```bash
source backend/app/env/bin/activate
uvicorn main:app --reload
```

Frontend Flutter Web:

```bash
cd frontend
flutter run -d chrome
```

## Estructura

```
SpoonApp
│
├── frontend/            # Código Flutter
│   ├── lib/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── backend/
│   ├── app/             # Nuevo backend FastAPI
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   └── .env.example
│   └── ...              # Código Django existente
│
├── frontend_legacy/     # Antiguo frontend JavaScript
└── setup_env.sh
```

Este README irá ampliándose conforme avance la migración.
