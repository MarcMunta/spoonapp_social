# SpoonApp Social

Este repositorio contiene la migración en curso de **SpoonApp** a un nuevo stack
con **Flutter** en el frontend y **FastAPI** para el backend. La antigua
aplicación Django sigue presente únicamente como referencia.

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
├── frontend/                  # Código Flutter
│   ├── lib/
│   │   ├── main.dart          # Punto de entrada
│   │   ├── pages/             # Vistas (Feed, Profile...)
│   │   ├── models/            # Modelos Dart
│   │   ├── services/          # Llamadas HTTP
│   │   └── providers/         # Gestión de estado
│   └── pubspec.yaml
│
├── backend/
│   ├── app/                   # Backend FastAPI
│   │   ├── main.py
│   │   ├── models/
│   │   ├── data.py
│   │   ├── requirements.txt
│   │   └── .env.example
│   └── ...                    # Código Django existente (referencia)
│
├── frontend_legacy/           # Antiguo frontend JavaScript
└── setup_env.sh
```

Este README irá ampliándose conforme avance la migración.
