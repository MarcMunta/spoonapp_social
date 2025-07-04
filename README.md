# SpoonApp Social

This Django project powers the SpoonApp social network. The repository separates
backend and frontend code. The backend resides in the `backend/` directory while
the modern JavaScript frontend lives inside the `frontend/` folder and is built
with [esbuild](https://esbuild.github.io/).

## Features
* Image posts with category tags
* Comments with nested replies and likes
* Post likes and share counter
* Stories that disappear after 24 hours
* Private messaging between friends (non-friends can only send one message)
* Friend requests and follower management
* User profiles with custom avatar, bio and chat bubble color
* Privacy settings, block list and hidden stories
* Notifications for messages and friend events
* User and location search
* Multi-language support (English/Spanish) with automatic language detection

Navigation notes: use the button in the top-left corner to toggle the left
sidebar. Clicking the SpoonApp logo or the home icon in the top bar always
returns you to the main feed.

## Frontend
See `frontend/README.md` for setup and build instructions. After building, the
bundle is placed in `backend/static/js/main.js` and automatically loaded on the home page.

## Running
Ensure Python and Node.js are installed, then install Python dependencies from
`requirements.txt`:

Build the virtual environment:

```mermaid
graph TD
    A["📂 Root folder: spoonapp_social"] --> B{Sistema operativo}
    B -->|Windows| C["Ejecuta: .\backend\setup_env.ps1"]
    B -->|macOS / Linux| D["Ejecuta: ./backend/setup_env.sh"]
    C --> E["Entorno virtual activo"]
    D --> E
```

Build the frontend:

```bash
cd frontend
npm install
npm run build
```

The translations are automatically compiled whenever `manage.py` is executed,
so you no longer need to run `django-admin compilemessages` manually. Selecting
a different language in the app also recompiles the translations automatically.
If you want to compile the translations outside of Django you can run:

```bash
./setup_env
```

This script invokes `./tools/gettext/bin/msgfmt` (or the system `msgfmt` if the
local binary is missing) and generates the `.mo` files inside the `locale/`
directories.

Run database migrations and start the development server:

```bash
cd backend
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

Listening on `0.0.0.0` lets mobile devices on the same network reach the
development server using your computer's IP address (e.g.
`http://192.168.1.x:8000`). With `DEBUG` enabled the project accepts
connections from any host. In production specify allowed hosts via the
`ALLOWED_HOSTS` environment variable.

If the `msgfmt` binary required for compiling translations is missing, `manage.py`
will attempt to install `gettext` using the available package manager
(APT on Linux, Homebrew on macOS or Chocolatey/Winget on Windows). The script also
checks for a bundled distribution under `backend/tools/gettext` and automatically
adds its `bin` directory to the `PATH` when found. If automatic installation fails,
install `gettext` manually. On Windows you can run
`choco install gettext` or `winget install -e --id GnuWin32.gettext`. Alternatively
download the prebuilt binaries from
[mlocati.github.io/gettext-iconv-windows](https://mlocati.github.io/articles/gettext-iconv-windows.html).

## Troubleshooting
If you get `ModuleNotFoundError: No module named \`PIL\`` when uploading images, Pillow is missing. Activate your virtual environment and run:

```bash
pip install -r backend/requirements.txt
```

This installs the Pillow package required by Django's image fields.

If the Flutter client prints `ClientException: Failed to fetch` when hitting `http://localhost:8000/api/stories/`, make sure the Django server is running:

```bash
cd backend
python manage.py runserver 0.0.0.0:8000
```

Visit `http://localhost:8000/api/stories/` in your browser to verify it returns JSON. When serving the API from a different host, configure [CORS](https://pypi.org/project/django-cors-headers/) so the Flutter app can access it.

## Story cleanup
Run the following command periodically to remove expired stories:

```bash
cd backend
python manage.py delete_expired_stories
```

You can schedule this with `cron` to run every hour so that stories
older than 24 hours are purged automatically.

## Uploading stories
Click the **+** button on your profile picture in the feed or profile page to
upload a new story from your computer. Once you select an image or video file,
the story is stored directly in the database with a 24‑hour expiration time.
