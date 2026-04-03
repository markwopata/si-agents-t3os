# SI-Agent T3OS

Local-first Strategic Initiatives management platform with:

- Fastify API
- React/Vite frontend
- Postgres runtime state
- import pipeline for the SI workbook
- agent runner for SI status/opinion generation

## Quick Start

1. `cp .env.example .env.local`
2. `docker compose up -d`
3. `npm install`
4. `npm run db:migrate`
5. `npm run dev`

Frontend runs at `http://localhost:3000` and API runs at `http://localhost:3001`.

## Environment Notes

- Keep real secrets in `.env.local` for local development and in your host's secret manager for deployed environments.
- The canonical JWT settings are `T3OS_JWT_ISSUER` and `T3OS_JWT_AUDIENCE`.
- `DEV_AUTH_BYPASS` is for local development only and must stay `false` in hosted environments.
- `TOKEN_ENCRYPTION_SECRET` protects stored Slack/Google tokens, so use a long random value outside local dev and do not rotate it casually.
