# Frontend

This directory contains the modern frontend for SpoonApp.

## Development

Install dependencies (requires Node.js) and build the bundle:

```bash
npm install
npm run build
```

Use `npm run dev` during development to rebuild on changes.

The compiled JavaScript is output to `../backend/static/scripts/main.js` and loaded by the Django template at `/static/scripts/main.js`.
