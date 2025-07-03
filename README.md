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

### Endpoints de ejemplo

El backend FastAPI expone endpoints de prueba para la app Flutter:

```text
GET /posts    # Lista de posts de ejemplo
POST /posts   # Crear un post nuevo
GET /stories  # Lista de historias de ejemplo
GET /notifications  # Lista de notificaciones de ejemplo
GET /chats               # Lista de chats del usuario
GET /chats/{id}/messages  # Mensajes de un chat
POST /chats/{id}/messages # Enviar mensaje
POST /login   # Devuelve un token si la contraseña es "password"
POST /signup  # Registra un usuario nuevo en memoria
GET /posts/{id}/comments  # Comentarios de un post
POST /posts/{id}/comments  # Crear un comentario
POST /posts/{id}/likes     # Marcar me gusta
DELETE /posts/{id}/likes   # Quitar me gusta
GET /users/{username}      # Obtener perfil de usuario
PUT /users/{username}      # Actualizar perfil (bio, avatar)
```
Tambien se pueden consultar y publicar comentarios en `PostDetailPage` usando el endpoint de comentarios. Los posts muestran un botón de "me gusta" que envía peticiones a `/posts/{id}/likes`.
El feed dispone de un botón flotante para **crear nuevos posts** que utiliza `POST /posts`.

El frontend Flutter muestra estas historias con una animación **Hero** al tocar
cada círculo y los posts se renderizan mediante el widget personalizado
`PostCard`. Al pulsar sobre un post se abre un `PostDetailPage` con transición
`Hero` para la imagen. Las imágenes se cargan usando `cached_network_image` para
mejorar el rendimiento. Se añadieron páginas de **login** y **registro** en Flutter
que consumen los endpoints `/login` y `/signup`.
El token de autenticación se persiste localmente usando
`shared_preferences` para mantener la sesión entre reinicios.
También existe una página de **notificaciones** que consume `/notifications`.
La pantalla **Nuevo Post** permite publicar mensajes con una imagen opcional.
Se añadieron pantallas de **chats** para enviar y recibir mensajes usando los
endpoints `/chats` y `/chats/{id}/messages`.
La página de perfil ahora tiene un interruptor para activar el tema oscuro o
claro. La preferencia se guarda localmente con `shared_preferences`.
Desde la página de perfil es posible acceder a **Editar Perfil** para cambiar la
biografía y el avatar mediante los endpoints `/users/{username}`.

## Estructura

```
SpoonApp
│
├── frontend/                  # Código Flutter
│   ├── lib/
│   │   ├── main.dart          # Arranque con ProviderScope
│   │   ├── app.dart           # Configuración de rutas y tema
│   │   ├── pages/             # Vistas (Feed, Notifications, Chats, Profile, Story, PostDetail, Login, Signup, NewPost)
│   │   ├── models/            # Modelos Dart
│   │   ├── services/          # Llamadas HTTP
│   │   ├── providers/         # Gestión de estado (posts, stories, notifications, chats, auth, theme)
│   │   └── widgets/           # Widgets reutilizables (StoryCircle, PostCard)
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
