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
python manage.py runserver
```

If the `msgfmt` binary required for compiling translations is missing, `manage.py`
will attempt to install `gettext` using the available package manager
(APT on Linux, Homebrew on macOS or Chocolatey/Winget on Windows). The script also
checks for a bundled distribution under `backend/tools/gettext` and automatically
adds its `bin` directory to the `PATH` when found. If automatic installation fails,
install `gettext` manually. On Windows you can run
`choco install gettext` or `winget install -e --id GnuWin32.gettext`. Alternatively
download the prebuilt binaries from
[mlocati.github.io/gettext-iconv-windows](https://mlocati.github.io/articles/gettext-iconv-windows.html).
