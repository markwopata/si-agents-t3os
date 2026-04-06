import { config as loadDotenv } from "dotenv";
import { existsSync } from "node:fs";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

loadDotenv();

const apiBaseUrl = process.env.SI_API_BASE_URL || "http://localhost:3001";
const serviceToken = process.env.SI_AGENT_SERVICE_TOKEN;
const intervalMinutes = Number(process.env.AGENT_RUN_INTERVAL_MINUTES || "60");
const runOnStart = (process.env.AGENT_RUN_ON_START || "true") === "true";
const mode = process.env.AGENT_RUN_MODE || "watch";
const target = process.env.AGENT_RUN_TARGET || "portfolio_refresh";
const dailyHour = Number(process.env.AGENT_RUN_DAILY_HOUR || "6");
const dailyMinute = Number(process.env.AGENT_RUN_DAILY_MINUTE || "0");
const directPortfolioWorker = (process.env.AGENT_DIRECT_PORTFOLIO_WORKER || "false") === "true";
const currentDir = path.dirname(fileURLToPath(import.meta.url));

function findRepoRoot(startDir: string): string {
  let cursor = startDir;

  for (;;) {
    const packageJsonPath = path.join(cursor, "package.json");
    const appsApiPath = path.join(cursor, "apps/api");
    if (existsSync(packageJsonPath) && existsSync(appsApiPath)) {
      return cursor;
    }

    const parent = path.dirname(cursor);
    if (parent === cursor) {
      break;
    }
    cursor = parent;
  }

  return process.cwd();
}

type RunTarget = "portfolio_refresh" | "run_all_evaluations" | "sync_all_evidence";

function authHeaders(): Record<string, string> {
  return serviceToken
    ? {
        Authorization: `Bearer ${serviceToken}`,
      }
    : {};
}

async function triggerTarget(): Promise<void> {
  const endpoint =
    target === "run_all_evaluations"
      ? "/agent/run-all"
      : target === "sync_all_evidence"
        ? "/agent/sync-all"
        : "/portfolio/refresh";
  const response = await fetch(`${apiBaseUrl}${endpoint}`, {
    method: "POST",
    headers: authHeaders(),
  });

  if (!response.ok) {
    throw new Error(await response.text());
  }

  const payload = (await response.json()) as
    | { runIds: string[] }
    | { runId: string; status: string }
    | { initiativeCount: number; syncedCount: number; failures: Array<unknown> };

  if ("runIds" in payload) {
    console.log(
      `[agent-runner] completed ${target} at ${new Date().toISOString()} with ${payload.runIds.length} evaluation runs`,
    );
  } else if ("initiativeCount" in payload) {
    console.log(
      `[agent-runner] completed ${target} at ${new Date().toISOString()} with ${payload.syncedCount}/${payload.initiativeCount} initiatives synced and ${payload.failures.length} failures`,
    );
  } else {
    console.log(
      `[agent-runner] launched ${target} at ${new Date().toISOString()} with refresh run ${payload.runId}`,
    );
  }
}

async function runDirectPortfolioWorker(): Promise<void> {
  const { processNextPortfolioRefreshRun } = await importPortfolioWorkerModule();

  let processedCount = 0;
  for (;;) {
    const run = await processNextPortfolioRefreshRun();
    if (!run) {
      console.log(
        `[agent-runner] direct portfolio worker found no queued runs after ${processedCount} processed`,
      );
      return;
    }

    processedCount += 1;
    console.log(
      `[agent-runner] direct portfolio worker processed ${run.runId} with status ${run.status}`,
    );
  }
}

async function importPortfolioWorkerModule(): Promise<{
  processNextPortfolioRefreshRun: () => Promise<
    | {
        runId: string;
        status: string;
      }
    | null
  >;
}> {
  const repoRoot = findRepoRoot(currentDir);
  const candidates = [
    path.resolve(repoRoot, "apps/api/dist/apps/api/src/services/portfolio-service.js"),
    path.resolve(repoRoot, "apps/api/dist/services/portfolio-service.js"),
    path.resolve(repoRoot, "apps/api/src/services/portfolio-service.ts"),
    path.resolve(repoRoot, "apps/api/src/services/portfolio-service.js"),
    path.resolve(currentDir, "../../api/dist/apps/api/src/services/portfolio-service.js"),
    path.resolve(currentDir, "../../api/dist/services/portfolio-service.js"),
    path.resolve(currentDir, "../../api/src/services/portfolio-service.ts"),
    path.resolve(currentDir, "../../api/src/services/portfolio-service.js"),
  ];

  for (const candidate of candidates) {
    if (!existsSync(candidate)) {
      continue;
    }

    return import(pathToFileURL(candidate).href);
  }

  throw new Error(
    `[agent-runner] unable to locate portfolio worker module. Checked: ${candidates.join(", ")}`,
  );
}

function msUntilNextDailyRun(hour: number, minute: number): number {
  const now = new Date();
  const next = new Date(now);
  next.setHours(hour, minute, 0, 0);
  if (next.getTime() <= now.getTime()) {
    next.setDate(next.getDate() + 1);
  }
  return next.getTime() - now.getTime();
}

function scheduleDaily(run: () => Promise<void>): void {
  const waitMs = msUntilNextDailyRun(dailyHour, dailyMinute);
  console.log(
    `[agent-runner] daily mode armed for ${String(dailyHour).padStart(2, "0")}:${String(dailyMinute).padStart(2, "0")} local time`,
  );
  setTimeout(() => {
    void run().catch((error) => {
      console.error("[agent-runner] daily run failed", error);
    });
    scheduleDaily(run);
  }, waitMs);
}

async function main(): Promise<void> {
  const run = async () => {
    if (directPortfolioWorker) {
      await runDirectPortfolioWorker();
      return;
    }

    await triggerTarget();
  };

  if (runOnStart) {
    await run();
  }

  if (mode === "once") {
    return;
  }

  if (mode === "daily") {
    scheduleDaily(run);
    return;
  }

  const intervalMs = intervalMinutes * 60_000;
  console.log(`[agent-runner] watching ${target} with interval ${intervalMinutes} minute(s)`);
  setInterval(() => {
    void run().catch((error) => {
      console.error("[agent-runner] interval run failed", error);
    });
  }, intervalMs);
}

void main().catch((error) => {
  console.error("[agent-runner] startup failed", error);
  process.exitCode = 1;
});
