#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Setting up Snowflake helper environment in ${ROOT_DIR}"
mkdir -p "${ROOT_DIR}/scripts"

if [[ ! -d "${ROOT_DIR}/_reference_code" ]]; then
  mkdir -p "${ROOT_DIR}/_reference_code"
fi

cat <<'EOF'
The full AGENT_BOOTSTRAP flow includes:
1. creating the Snowflake private key in ~/.ssh
2. creating a Python virtual environment in this project
3. starting Frosty MCP at http://localhost:8888/mcp
4. creating the project .cursor/mcp.json Frosty config
5. cloning the data-org pull repo and running the code mirror sync

Use /Users/mark.wopata/Documents/projects/ba-finance-dbt/AGENT_BOOTSTRAP.md as the source of truth.
EOF
