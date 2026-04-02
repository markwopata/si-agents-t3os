import type { PortfolioRefreshRun } from "@si/domain";
import { asc, desc, eq } from "drizzle-orm";
import { env } from "../config/env.js";
import { db } from "../db/client.js";
import { initiatives, portfolioRefreshRuns } from "../db/schema.js";
import { createId } from "../lib/id.js";
import { runEvaluationForInitiative } from "./agent-service.js";
import { extractDocumentsForInitiative } from "./document-extraction-service.js";
import { syncGoogleHistoryForInitiative, syncSlackHistoryForInitiative } from "./history-sync-service.js";
import { getInitiativeById } from "./initiative-service.js";
import { runKpiResearchForInitiative } from "./kpi-research-service.js";
import { refreshPrioritySignals } from "./ranking-service.js";
import { parseTrackerForInitiative } from "./tracker-service.js";

type RefreshSummaryEntry = Record<string, unknown>;
type PortfolioActor = {
  requestedByType: "human" | "service_token";
  requestedById: string;
};

const activePortfolioRuns = new Map<string, Promise<void>>();

function withTimeout<T>(promise: Promise<T>, label: string, timeoutMs: number): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const timeoutHandle = setTimeout(() => {
      reject(new Error(`${label} timed out after ${timeoutMs}ms`));
    }, timeoutMs);

    promise
      .then((value) => {
        clearTimeout(timeoutHandle);
        resolve(value);
      })
      .catch((error) => {
        clearTimeout(timeoutHandle);
        reject(error);
      });
  });
}

async function updatePortfolioRun(
  runId: string,
  input: {
    requestedByType: "human" | "service_token";
    requestedById: string;
    totalCount: number;
    processed: RefreshSummaryEntry[];
    failures: RefreshSummaryEntry[];
    currentInitiativeId?: string | null;
    currentCode?: string | null;
    status?: string;
    error?: string | null;
  },
): Promise<void> {
  await db
    .update(portfolioRefreshRuns)
    .set({
      status: input.status ?? "running",
      summary: {
        requestedByType: input.requestedByType,
        requestedById: input.requestedById,
        totalCount: input.totalCount,
        processedCount: input.processed.length,
        failureCount: input.failures.length,
        currentInitiativeId: input.currentInitiativeId ?? null,
        currentCode: input.currentCode ?? null,
        processed: input.processed,
        failures: input.failures,
        error: input.error ?? null,
      },
      finishedAt: input.status === "completed" || input.status === "failed" ? new Date() : null,
    })
    .where(eq(portfolioRefreshRuns.id, runId));
}

function asSummaryEntries(value: unknown): RefreshSummaryEntry[] {
  return Array.isArray(value) ? value.filter((entry): entry is RefreshSummaryEntry => !!entry && typeof entry === "object") : [];
}

function extractActor(summary: Record<string, unknown>): PortfolioActor {
  return {
    requestedByType: summary.requestedByType === "service_token" ? "service_token" : "human",
    requestedById: typeof summary.requestedById === "string" && summary.requestedById
      ? summary.requestedById
      : "system-recovery",
  };
}

async function listPortfolioInitiativeIds(includeInactive = false): Promise<string[]> {
  const rows = includeInactive
    ? await db.select({ id: initiatives.id }).from(initiatives).orderBy(asc(initiatives.code))
    : await db
        .select({ id: initiatives.id })
        .from(initiatives)
        .where(eq(initiatives.isActive, true))
        .orderBy(asc(initiatives.code));

  return rows.map((row) => row.id);
}

function startPortfolioRefreshProcessing(
  runId: string,
  initiativeIds: string[],
  input: PortfolioActor,
  initialState?: {
    processed: RefreshSummaryEntry[];
    failures: RefreshSummaryEntry[];
  },
): void {
  if (activePortfolioRuns.has(runId)) {
    return;
  }

  const promise = processPortfolioRefresh(runId, initiativeIds, input, initialState).finally(() => {
    activePortfolioRuns.delete(runId);
  });
  activePortfolioRuns.set(runId, promise);
}

async function processPortfolioRefresh(
  runId: string,
  initiativeIds: string[],
  input: PortfolioActor,
  initialState?: {
    processed: RefreshSummaryEntry[];
    failures: RefreshSummaryEntry[];
  },
): Promise<void> {
  const processed: RefreshSummaryEntry[] = [...(initialState?.processed ?? [])];
  const failures: RefreshSummaryEntry[] = [...(initialState?.failures ?? [])];
  const completedIds = new Set(
    [...processed, ...failures]
      .map((entry) => (typeof entry.initiativeId === "string" ? entry.initiativeId : null))
      .filter((value): value is string => Boolean(value)),
  );

  try {
    for (const initiativeId of initiativeIds) {
      if (completedIds.has(initiativeId)) {
        continue;
      }

      const initiative = await getInitiativeById(initiativeId);
      if (!initiative) {
        failures.push({
          initiativeId,
          error: "Initiative not found",
        });
        continue;
      }

      await updatePortfolioRun(runId, {
        ...input,
        totalCount: initiativeIds.length,
        processed,
        failures,
        currentInitiativeId: initiative.id,
        currentCode: initiative.code,
      });

      try {
        const slackSync = await withTimeout(
          syncSlackHistoryForInitiative(initiative),
          `Slack sync for ${initiative.code}`,
          env.PORTFOLIO_STEP_TIMEOUT_MS,
        );
        const googleSync = await withTimeout(
          syncGoogleHistoryForInitiative(initiative),
          `Google sync for ${initiative.code}`,
          env.PORTFOLIO_STEP_TIMEOUT_MS,
        );
        const extraction = await withTimeout(
          extractDocumentsForInitiative({
            initiativeId: initiative.id,
            slackRunIds: slackSync.runIds,
            googleRunId: googleSync.runId,
          }),
          `Document extraction for ${initiative.code}`,
          env.PORTFOLIO_STEP_TIMEOUT_MS,
        );
        const tracker = await withTimeout(
          parseTrackerForInitiative(initiative.id, googleSync.runId),
          `Tracker parsing for ${initiative.code}`,
          env.PORTFOLIO_STEP_TIMEOUT_MS,
        );
        const evaluation = await withTimeout(
          runEvaluationForInitiative({
            initiativeId: initiative.id,
            requestedByType: input.requestedByType,
            requestedById: input.requestedById,
          }),
          `Evaluation for ${initiative.code}`,
          env.PORTFOLIO_STEP_TIMEOUT_MS,
        );
        const kpiResearch = await withTimeout(
          runKpiResearchForInitiative(initiative, evaluation.runId),
          `KPI research for ${initiative.code}`,
          env.PORTFOLIO_STEP_TIMEOUT_MS,
        );

        processed.push({
          initiativeId: initiative.id,
          code: initiative.code,
          title: initiative.title,
          slackSync,
          googleSync,
          extraction,
          trackerParseRunId: tracker?.latestParseRunId ?? null,
          agentRunId: evaluation.runId,
          observationId: evaluation.observationId,
          kpiResearchRunId: kpiResearch.researchRunId,
          kpiFindingCount: kpiResearch.findings.length,
        });
        completedIds.add(initiative.id);
      } catch (error) {
        failures.push({
          initiativeId: initiative.id,
          code: initiative.code,
          title: initiative.title,
          error: error instanceof Error ? error.message : "Portfolio refresh failed",
        });
        completedIds.add(initiative.id);
      }

      await updatePortfolioRun(runId, {
        ...input,
        totalCount: initiativeIds.length,
        processed,
        failures,
      });
    }

    const rankings = await refreshPrioritySignals();

    await updatePortfolioRun(runId, {
      ...input,
      totalCount: initiativeIds.length,
      processed,
      failures,
      status: "completed",
    });

    await db
      .update(portfolioRefreshRuns)
      .set({
        summary: {
          requestedByType: input.requestedByType,
          requestedById: input.requestedById,
          totalCount: initiativeIds.length,
          processedCount: processed.length,
          failureCount: failures.length,
          currentInitiativeId: null,
          currentCode: null,
          processed,
          failures,
          rankingUpdated: true,
          rankingCount: rankings.length,
          error: null,
        },
      })
      .where(eq(portfolioRefreshRuns.id, runId));
  } catch (error) {
    await updatePortfolioRun(runId, {
      ...input,
      totalCount: initiativeIds.length,
      processed,
      failures,
      status: "failed",
      error: error instanceof Error ? error.message : "Portfolio refresh failed",
    });
  }
}

export async function recoverPortfolioRefreshRuns(): Promise<void> {
  const running = await db.query.portfolioRefreshRuns.findMany({
    where: eq(portfolioRefreshRuns.status, "running"),
    orderBy: [desc(portfolioRefreshRuns.createdAt)],
  });

  if (running.length === 0) {
    return;
  }

  const [latest, ...older] = running;
  if (!latest) {
    return;
  }

  for (const record of older) {
    const summary = (record.summary ?? {}) as Record<string, unknown>;
    const actor = extractActor(summary);
    await updatePortfolioRun(record.id, {
      ...actor,
      totalCount: typeof summary.totalCount === "number" ? summary.totalCount : 0,
      processed: asSummaryEntries(summary.processed),
      failures: asSummaryEntries(summary.failures),
      currentInitiativeId: null,
      currentCode: null,
      status: "failed",
      error: "Superseded by a newer portfolio refresh run during recovery.",
    });
  }

  if (activePortfolioRuns.has(latest.id)) {
    return;
  }

  const summary = (latest.summary ?? {}) as Record<string, unknown>;
  const processed = asSummaryEntries(summary.processed);
  const failures = asSummaryEntries(summary.failures);
  const actor = extractActor(summary);
  const initiativeIds = await listPortfolioInitiativeIds();

  startPortfolioRefreshProcessing(
    latest.id,
    initiativeIds,
    actor,
    {
      processed,
      failures,
    },
  );
}

function toPortfolioRun(record: typeof portfolioRefreshRuns.$inferSelect): PortfolioRefreshRun {
  return {
    runId: record.id,
    status: record.status,
    summary: record.summary ?? {},
    createdAt: record.createdAt.toISOString(),
    finishedAt: record.finishedAt?.toISOString() ?? null,
  };
}

export async function launchPortfolioRefresh(input: {
  requestedByType: "human" | "service_token";
  requestedById: string;
  includeInactive?: boolean;
}): Promise<PortfolioRefreshRun> {
  const runningRecord = await db.query.portfolioRefreshRuns.findFirst({
    where: eq(portfolioRefreshRuns.status, "running"),
    orderBy: [desc(portfolioRefreshRuns.createdAt)],
  });

  if (runningRecord) {
    const summary = (runningRecord.summary ?? {}) as Record<string, unknown>;
    const actor = extractActor(summary);
    const initiativeIds = await listPortfolioInitiativeIds(Boolean(input.includeInactive));
    startPortfolioRefreshProcessing(
      runningRecord.id,
      initiativeIds,
      actor,
      {
        processed: asSummaryEntries(summary.processed),
        failures: asSummaryEntries(summary.failures),
      },
    );
    return toPortfolioRun(runningRecord);
  }

  const initiativeIds = await listPortfolioInitiativeIds(Boolean(input.includeInactive));

  const runId = createId("portfolio_refresh");
  await db.insert(portfolioRefreshRuns).values({
    id: runId,
    status: "running",
    summary: {
      requestedByType: input.requestedByType,
      requestedById: input.requestedById,
      totalCount: initiativeIds.length,
      processedCount: 0,
      failureCount: 0,
      currentInitiativeId: null,
      currentCode: null,
      processed: [],
      failures: [],
      error: null,
    },
  });

  startPortfolioRefreshProcessing(
    runId,
    initiativeIds,
    {
      requestedByType: input.requestedByType,
      requestedById: input.requestedById,
    },
  );

  return getPortfolioRefreshRun(runId) as Promise<PortfolioRefreshRun>;
}

export async function getPortfolioRefreshRun(runId: string): Promise<PortfolioRefreshRun | null> {
  const record = await db.query.portfolioRefreshRuns.findFirst({
    where: eq(portfolioRefreshRuns.id, runId),
  });
  return record ? toPortfolioRun(record) : null;
}

export async function getLatestPortfolioRefreshRun(): Promise<PortfolioRefreshRun | null> {
  const record = await db.query.portfolioRefreshRuns.findFirst({
    orderBy: [desc(portfolioRefreshRuns.createdAt)],
  });
  return record ? toPortfolioRun(record) : null;
}
