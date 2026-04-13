# SI Agent Admin Onboarding For Claude Code

This note is for a new SI Agent admin operator in the same vein as Jabbok: someone who can inspect the system broadly, make judgment calls, and help maintain initiative, knowledge, and platform workflows with Claude Code.

I will send your SI Agent API key separately. Do not paste that key into Git-tracked files, PRs, tickets, Slack, screenshots, or chat transcripts. If that happens, treat the key as burned and rotate it.

## What This Role Is

As an SI Agent admin, you are expected to work with the platform at an operator level, not just as a viewer.

Admin access in this repo maps to these capabilities:

- `read:initiatives`
- `write:initiatives`
- `read:knowledge`
- `write:knowledge`
- `read:observations`
- `write:observations`
- `read:platform`
- `write:platform`
- `run:agents`
- `manage:tokens`

That means you can:

- review and update initiative records
- curate global or initiative-specific knowledge
- inspect and correct observations or assessment artifacts
- run SI agent workflows
- manage API tokens
- perform platform-level admin work when using a live T3OS user session

## Important Auth Note

There are two different auth paths in this codebase:

1. A live human T3OS session
2. A user API token

Your SI Agent API key is useful for direct API calls and local automation, but some platform routes require a live human T3OS session and cannot be completed with the API key alone. In this repo, platform endpoints depend on a live user session token for actions like listing workspace members or changing workspace/platform data.

In practice:

- use the SI Agent API key for authenticated API work and local helper scripts
- use the web app with your real admin login for platform actions that require a live session

## Local Setup

From the repo root:

```bash
npm install
cp .env.example .env.local
docker compose up -d
npm run db:migrate
npm run dev
```

Default local URLs:

- web: `http://localhost:3000`
- api: `http://localhost:3001`

Keep real secrets in local-only environment storage. This repo already expects `.env.local` to stay uncommitted.

## How To Store The API Key Securely

Preferred approach on macOS: store the SI Agent key in Keychain, then load it into your shell environment without ever saving the raw secret in the repo.

### One-time secure save

Run this once, then paste the key only into the hidden prompt:

```bash
read -s SI_AGENT_ADMIN_TOKEN && echo
security add-generic-password -U -a "$USER" -s "si-agent-admin-token" -w "$SI_AGENT_ADMIN_TOKEN"
unset SI_AGENT_ADMIN_TOKEN
```

This avoids putting the raw key in shell history.

### Load it for Claude Code and local scripts

Add this to a local shell file such as `~/.zshrc` or `~/.zshenv`:

```bash
export SI_AGENT_API_BASE_URL="https://si-agents-api.onrender.com"
export SI_AGENT_ADMIN_TOKEN="$(security find-generic-password -a "$USER" -s "si-agent-admin-token" -w)"
```

If Claude Code is launched from that shell, it will inherit the environment variable automatically.

If you want to keep even the retrieval logic out of your main shell profile, put those two lines in a local-only file such as `~/.config/si-agent/env.zsh`, set it to `chmod 600`, and source it from `~/.zshrc`.

## What Not To Do With The Key

Do not:

- commit it to `.env`, `.env.local`, or any repo file
- paste it into Claude prompts, chat logs, issue trackers, or Slack
- hardcode it in scripts
- share it through screenshots or screen recordings

If the key appears in any of those places, assume it is compromised and rotate it.

## Quick Verification

This repo includes a helper script at [scripts/si-admin-api.mjs](/Users/mark.wopata/Documents/projects/SI-agent/scripts/si-admin-api.mjs).

After your environment variable is loaded, verify access with:

```bash
node scripts/si-admin-api.mjs GET /me
```

You should get a response showing your identity, auth source, workspace binding, and scopes.

## Recommended Claude Code Workflow

Use Claude Code as a repo-aware operator:

- inspect the existing code and docs first
- prefer small, auditable changes
- verify behavior with targeted commands or tests
- avoid changing auth or token handling casually
- treat platform writes as higher-risk actions and double-check scope before executing them

Good first checks:

```bash
node scripts/si-admin-api.mjs GET /me
node scripts/si-admin-api.mjs GET /api-tokens
```

For platform-heavy admin work, prefer the web app plus your real T3OS session instead of trying to force everything through the API key.

## Repo References

- [README.md](/Users/mark.wopata/Documents/projects/SI-agent/README.md)
- [apps/api/src/plugins/auth.ts](/Users/mark.wopata/Documents/projects/SI-agent/apps/api/src/plugins/auth.ts)
- [apps/api/src/routes/api-tokens.ts](/Users/mark.wopata/Documents/projects/SI-agent/apps/api/src/routes/api-tokens.ts)
- [apps/api/src/routes/platform.ts](/Users/mark.wopata/Documents/projects/SI-agent/apps/api/src/routes/platform.ts)
- [scripts/si-admin-api.mjs](/Users/mark.wopata/Documents/projects/SI-agent/scripts/si-admin-api.mjs)
