# SpoonApp Social

This Django project powers the SpoonApp social network. The repository now separates
backend and frontend code. The backend is a standard Django project located in this
root directory. The modern JavaScript frontend is contained in the `frontend/` folder
and built with [esbuild](https://esbuild.github.io/).

## Frontend
See `frontend/README.md` for setup and build instructions. After building, the
bundle is placed in `static/main.js` and automatically loaded on the home page.

## Running
Ensure Python and Node.js are installed, then install Python dependencies:

```bash
pip install Django Pillow
```

Build the frontend:

```bash
cd frontend
npm install
npm run build
```

Run the Django development server:

```bash
python manage.py runserver
```
