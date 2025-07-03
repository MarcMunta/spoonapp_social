# SpoonApp Social

Este repositorio contiene la migración en curso de **SpoonApp** a un stack
compuesto por **Flutter** en el frontend y **FastAPI** para el backend. La
antigua aplicación Django se conserva solo como referencia.

## Requisitos
- Flutter >= 3.x
- Dart >= 3.x
- Python 3.11

## Instalación rápida

```bash
./setup_env.sh
```

Este script creará un entorno virtual en `backend/app/env`, instalará todas las dependencias y generará un archivo `.env` de ejemplo. Funciona tanto en macOS como en Windows (Git Bash o PowerShell).

Para el frontend ejecuta:

```bash
cd frontend
flutter pub get
```

## Ejecución en desarrollo

Backend FastAPI:

```bash
source backend/app/env/bin/activate  # En Windows: backend\app\env\Scripts\activate
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
GET /posts?offset=0&limit=10[&category=food]    # Lista paginada de posts
POST /posts   # Crear un post nuevo
GET /stories  # Lista de historias de ejemplo
POST /stories # Crear una historia
DELETE /stories/{id}?user=alice  # Borrar historia (propietario)
GET /notifications  # Lista de notificaciones de ejemplo
POST /notifications/{id}/read  # Marcar notificación como leída
GET /categories               # Lista de categorías disponibles
GET /chats               # Lista de chats del usuario
GET /chats/{id}/messages  # Mensajes de un chat
POST /chats/{id}/messages # Enviar mensaje
POST /login   # Devuelve un token si la contraseña es "password"
POST /signup  # Registra un usuario nuevo en memoria
GET /posts/{id}/comments  # Comentarios de un post
POST /posts/{id}/comments  # Crear un comentario
POST /posts/{id}/likes     # Marcar me gusta
DELETE /posts/{id}/likes   # Quitar me gusta
DELETE /posts/{id}         # Borrar un post (propietario)
DELETE /posts/{id}/comments/{cid}  # Borrar comentario (propietario)
GET /users/{username}      # Obtener perfil de usuario
PUT /users/{username}      # Actualizar perfil (bio, avatar, bubble_color)
GET /friend-requests       # Solicitudes de amistad (opcional ?user=)
POST /friend-requests      # Enviar solicitud de amistad
POST /friend-requests/{id}/accept  # Aceptar solicitud
GET /users?q=alice   # Buscar usuarios (opcional)
GET /blocks?blocker=alice  # Usuarios bloqueados por un usuario
POST /blocks               # Bloquear usuario
POST /blocks/{username}/unblock?blocker=alice  # Desbloquear
GET /story-blocks?owner=alice  # Usuarios a los que ocultas tus historias
POST /story-blocks             # Ocultar historias a un usuario
POST /story-blocks/{username}/unhide?owner=alice  # Dejar de ocultar
```
Tambien se pueden consultar y publicar comentarios en `PostDetailPage` usando el endpoint de comentarios. Los posts y sus comentarios incluyen ahora un campo `bubble_color` que indica el color elegido por cada usuario. Los posts muestran un botón de "me gusta" que envía peticiones a `/posts/{id}/likes`.

El feed dispone de un botón flotante para **crear nuevos posts** que utiliza `POST /posts`.
Al crear un post se pueden seleccionar categorías que luego se muestran en el feed.
Los autores pueden **eliminar sus propios posts** y comentarios gracias a los
endpoints `DELETE /posts/{id}` y
`DELETE /posts/{id}/comments/{cid}`.
Ahora la lista de posts se obtiene de forma paginada con los parámetros `offset`
y `limit`, y el feed implementa **scroll infinito** para cargar más contenido al
bajar. Además, pueden filtrarse por categoría usando `GET /posts?category=<slug>`
y en el feed existe un botón para elegir la categoría.

El frontend Flutter muestra estas historias con una animación **Hero** al tocar
cada círculo. Al abrirlas se reproducen en pantalla completa con avance
automático y se pueden pausar con una pulsación prolongada. Los posts se
renderizan mediante el widget personalizado
`PostCard`. Al pulsar sobre un post se abre un `PostDetailPage` con transición
`Hero` para la imagen. Las imágenes se cargan usando `cached_network_image` para
mejorar el rendimiento. Se añadieron páginas de **login** y **registro** en Flutter
que consumen los endpoints `/login` y `/signup`.
El token de autenticación se persiste localmente usando
`shared_preferences` para mantener la sesión entre reinicios.
También existe una página de **notificaciones** que consume `/notifications`.
Ahora se pueden marcar como leídas enviando `POST /notifications/{id}/read`.
La pantalla **Nuevo Post** permite publicar mensajes con una imagen opcional.
De igual forma existe **Nueva Historia** para crear historias con `/stories`.
Se añadieron pantallas de **chats** para enviar y recibir mensajes usando los
endpoints `/chats` y `/chats/{id}/messages`.
La página de perfil ahora tiene un interruptor para activar el tema oscuro o
claro. La preferencia se guarda localmente con `shared_preferences`.
Desde la página de perfil es posible acceder a **Editar Perfil** para cambiar la
biografía, el avatar y el color de burbuja mediante los endpoints `/users/{username}`.
Existe también una pantalla de **solicitudes de amistad** que muestra las
peticiones pendientes y permite aceptarlas a través de `/friend-requests`.
Se añadieron páginas de **usuarios bloqueados** y **buscador de usuarios** que
consumen los endpoints `/blocks` y `/users` respectivamente.
Existe también una página de **historias ocultas** para gestionar a quién
ocultas tus historias, que usa los endpoints `/story-blocks`.
Se añadió una pantalla de **categorías** desde el perfil para ver la lista
disponible mediante `GET /categories`.
Ahora la aplicación soporta **cambio de idioma** entre inglés y español. Un
nuevo **SettingsPage** permite elegir el idioma y la preferencia se guarda con
`shared_preferences`.

## Estructura

```
SpoonApp
│
├── frontend/                  # Código Flutter
│   ├── lib/
│   │   ├── main.dart          # Arranque con ProviderScope
│   │   ├── app.dart           # Configuración de rutas y tema
│   │   ├── pages/             # Vistas (Feed, Notifications, Chats, Profile, Story, PostDetail, Login, Signup, NewPost, NewStory, FriendRequests, BlockedUsers, HiddenStories, Categories, UserSearch, Settings)
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
