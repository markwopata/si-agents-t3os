# SI-Agent T3OS

Local-first Strategic Initiatives management platform with:

- Fastify API
- React/Vite frontend
- Postgres runtime state
- import pipeline for the SI workbook
- agent runner for SI status/opinion generation

## Quick Start

1. `docker compose up -d`
2. `npm install`
3. `npm run db:migrate`
4. `npm run dev`

Frontend runs at `http://localhost:3000` and API runs at `http://localhost:3001`.
