import { resolve } from "node:path";
import process from "node:process";
import { config as loadDotenv } from "dotenv";

const repoRoot = resolve(import.meta.dirname, "..");

loadDotenv({ path: resolve(repoRoot, ".env") });
loadDotenv({ path: resolve(repoRoot, ".env.local"), override: true });
loadDotenv();

const [, , methodArg, pathArg, bodyArg] = process.argv;

const method = (methodArg || "GET").toUpperCase();
const requestPath = pathArg || "/me";
const apiBaseUrl = (process.env.SI_AGENT_API_BASE_URL || "https://si-agents-api.onrender.com").replace(/\/$/, "");
const token = process.env.SI_AGENT_ADMIN_TOKEN?.trim();

if (!token) {
  console.error("Missing SI_AGENT_ADMIN_TOKEN. Add it to .env.local before using this helper.");
  process.exit(1);
}

if (!requestPath.startsWith("/")) {
  console.error(`Path must start with '/'. Received: ${requestPath}`);
  process.exit(1);
}

let body;

if (bodyArg) {
  try {
    body = JSON.parse(bodyArg);
  } catch (error) {
    console.error("Body must be valid JSON.");
    console.error(error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}

const response = await fetch(`${apiBaseUrl}${requestPath}`, {
  method,
  headers: {
    Authorization: `Bearer ${token}`,
    ...(body ? { "Content-Type": "application/json" } : {}),
  },
  ...(body ? { body: JSON.stringify(body) } : {}),
});

const text = await response.text();

console.log(`HTTP ${response.status} ${response.statusText}`);

if (!text) {
  process.exit(response.ok ? 0 : 1);
}

try {
  console.log(JSON.stringify(JSON.parse(text), null, 2));
} catch {
  console.log(text);
}

process.exit(response.ok ? 0 : 1);
