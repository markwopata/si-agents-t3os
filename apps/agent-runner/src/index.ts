import { config as loadDotenv } from "dotenv";

loadDotenv();

const apiBaseUrl = process.env.SI_API_BASE_URL || "http://localhost:3001";
const serviceToken = process.env.SI_AGENT_SERVICE_TOKEN;
const intervalMinutes = Number(process.env.AGENT_RUN_INTERVAL_MINUTES || "60");
const runOnStart = (process.env.AGENT_RUN_ON_START || "true") === "true";
const mode = process.env.AGENT_RUN_MODE || "watch";
const target = process.env.AGENT_RUN_TARGET || "portfolio_refresh";
const dailyHour = Number(process.env.AGENT_RUN_DAILY_HOUR || "6");
const dailyMinute = Number(process.env.AGENT_RUN_DAILY_MINUTE || "0");

type RunTarget = "portfolio_refresh" | "run_all_evaluations";

function authHeaders(): Record<string, string> {
  return serviceToken
    ? {
        Authorization: `Bearer ${serviceToken}`,
      }
    : {};
}

async function triggerTarget(): Promise<void> {
  const endpoint =
    target === "run_all_evaluations" ? "/agent/run-all" : "/portfolio/refresh";
  const response = await fetch(`${apiBaseUrl}${endpoint}`, {
    method: "POST",
    headers: authHeaders(),
  });

  if (!response.ok) {
    throw new Error(await response.text());
  }

  const payload = (await response.json()) as
    | { runIds: string[] }
    | { runId: string; status: string };

  if ("runIds" in payload) {
    console.log(
      `[agent-runner] completed ${target} at ${new Date().toISOString()} with ${payload.runIds.length} evaluation runs`,
    );
  } else {
    console.log(
      `[agent-runner] launched ${target} at ${new Date().toISOString()} with refresh run ${payload.runId}`,
    );
  }
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
