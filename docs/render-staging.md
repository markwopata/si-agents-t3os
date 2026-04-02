# Render Staging Setup

This repo is prepared for a staging Render deployment with:

- `si-agents-api` as the web service
- `si-agents-refresh` as the scheduled portfolio refresh runner

## Services

### `si-agents-api`

Purpose:
- Fastify API
- Slack and Google OAuth callbacks
- T3OS platform proxy routes
- SI CRUD, evidence, ranking, and knowledge APIs

Entrypoint:
- build: `npm install && npm run build`
- pre-deploy migrate: `npm run db:migrate -w @si/api`
- start: `npm run start -w @si/api`

Health check:
- `/health`

### `si-agents-refresh`

Purpose:
- daily full portfolio refresh

Entrypoint:
- build: `npm install && npm run build`
- start: `npm run start -w @si/agent-runner`

Schedule:
- `0 6 * * *`

## Required environment variables

### API service

- `WEB_APP_URL`
- `CORS_ALLOWED_ORIGINS`
- `DATABASE_URL`
- `TOKEN_ENCRYPTION_SECRET`
- `T3OS_EXECUTIVE_EMAILS`
- `AUTH0_ISSUER_BASE_URL`
- `AUTH0_AUDIENCE`
- `FROSTY_BASE_URL`
- `SLACK_CLIENT_ID`
- `SLACK_CLIENT_SECRET`
- `SLACK_REDIRECT_URI`
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `GOOGLE_REDIRECT_URI`

Recommended staging values:

- `WEB_APP_URL=https://staging-si-agent.t3os.ai`
- `CORS_ALLOWED_ORIGINS=https://staging-si-agent.t3os.ai,http://localhost:3000`
- `T3OS_GRAPHQL_URL=https://staging-api.equipmentshare.com/es-erp-api/graphql`
- `DEV_AUTH_BYPASS=false`
- `T3OS_TRUST_HEADER_AUTH=false`

### Refresh runner

- `SI_API_BASE_URL`
- `SI_AGENT_SERVICE_TOKEN`

Recommended staging value:

- `SI_API_BASE_URL=https://<your-render-api-host>`

## Important notes

- The API is now CORS-allowlisted via `CORS_ALLOWED_ORIGINS`.
- The current bearer-token flow is T3OS-aware, but hosted deployment still needs full Auth0/JWKS verification before this should be treated as production-safe.
- Slack and Google redirect URIs must point at the hosted API domain, not localhost.
- This repo currently has no Git remote configured, so Render cannot create a repo-backed service from this machine until the repo is pushed or linked.
