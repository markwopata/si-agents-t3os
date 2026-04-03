import type { PilotRun } from "@si/domain";
import { desc, eq, inArray } from "drizzle-orm";
import { db } from "../db/client.js";
import { initiatives, pilotBatches } from "../db/schema.js";
import { createId } from "../lib/id.js";
import { runEvaluationForInitiative } from "./agent-service.js";
import { extractDocumentsForInitiative } from "./document-extraction-service.js";
import {
  listPilotCandidates,
  syncGoogleHistoryForInitiative,
  syncSlackHistoryForInitiative,
} from "./history-sync-service.js";
import { getInitiativeById } from "./initiative-service.js";
import { runKpiResearchForInitiative } from "./kpi-research-service.js";
import { parseTrackerForInitiative } from "./tracker-service.js";

export async function previewPilotCohort(limit = 10): Promise<PilotRun["cohort"]> {
  return listPilotCandidates(limit);
}

async function updateBatchProgress(
  batchId: string,
  input: {
    requestedByType: "human" | "service_token";
    requestedById: string;
    totalCount: number;
    processed: Array<Record<string, unknown>>;
    failures: Array<Record<string, unknown>>;
    currentInitiativeId?: string | null;
    currentCode?: string | null;
    status?: "running" | "completed" | "failed";
    error?: string | null;
  },
): Promise<void> {
  await db
    .update(pilotBatches)
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
    .where(eq(pilotBatches.id, batchId));
}

async function processPilotBatch(
  batchId: string,
  cohort: PilotRun["cohort"],
  input: {
    requestedByType: "human" | "service_token";
    requestedById: string;
  },
): Promise<void> {
  const processed: Array<Record<string, unknown>> = [];
  const failures: Array<Record<string, unknown>> = [];

  try {
    for (const candidate of cohort) {
      await updateBatchProgress(batchId, {
        ...input,
        totalCount: cohort.length,
        processed,
        failures,
        currentInitiativeId: candidate.initiativeId,
        currentCode: candidate.code,
      });

      const initiative = await getInitiativeById(candidate.initiativeId);
      if (!initiative) {
        failures.push({
          initiativeId: candidate.initiativeId,
          code: candidate.code,
          title: candidate.title,
          error: "Initiative not found",
        });
        continue;
      }

      try {
        const slackSync = await syncSlackHistoryForInitiative(initiative);
        const googleSync = await syncGoogleHistoryForInitiative(initiative);
        const extraction = await extractDocumentsForInitiative({
          initiativeId: initiative.id,
          slackRunIds: slackSync.runIds,
          googleRunId: googleSync.runId,
        });
        const tracker = await parseTrackerForInitiative(initiative.id, googleSync.runId);
        const kpiResearch = await runKpiResearchForInitiative(initiative);
        const evaluation = await runEvaluationForInitiative({
          initiativeId: initiative.id,
          requestedByType: input.requestedByType,
          requestedById: input.requestedById,
          refreshKpisBeforeEvaluation: false,
        });

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
      } catch (error) {
        failures.push({
          initiativeId: initiative.id,
          code: initiative.code,
          title: initiative.title,
          error: error instanceof Error ? error.message : "Pilot processing failed",
        });
      }

      await updateBatchProgress(batchId, {
        ...input,
        totalCount: cohort.length,
        processed,
        failures,
      });
    }

    await updateBatchProgress(batchId, {
      ...input,
      totalCount: cohort.length,
      processed,
      failures,
      status: failures.length > 0 ? "failed" : "completed",
    });
  } catch (error) {
    await updateBatchProgress(batchId, {
      ...input,
      totalCount: cohort.length,
      processed,
      failures,
      status: "failed",
      error: error instanceof Error ? error.message : "Pilot batch failed",
    });
  }
}

export async function launchPilotBatch(input: {
  requestedByType: "human" | "service_token";
  requestedById: string;
  limit?: number;
}): Promise<{ batchId: string; cohort: PilotRun["cohort"] }> {
  const cohort = await listPilotCandidates(input.limit ?? 10);
  const batchId = createId("pilot");

  await db.insert(pilotBatches).values({
    id: batchId,
    status: "running",
    cohortCodes: cohort.map((candidate) => candidate.code),
    summary: {
      requestedByType: input.requestedByType,
      requestedById: input.requestedById,
      totalCount: cohort.length,
      processedCount: 0,
      failureCount: 0,
      currentInitiativeId: null,
      currentCode: null,
      processed: [],
      failures: [],
    },
  });

  void processPilotBatch(batchId, cohort, {
    requestedByType: input.requestedByType,
    requestedById: input.requestedById,
  });

  return {
    batchId,
    cohort,
  };
}

export async function getPilotBatch(batchId: string): Promise<PilotRun | null> {
  const batch = await db.query.pilotBatches.findFirst({
    where: eq(pilotBatches.id, batchId),
  });
  if (!batch) {
    return null;
  }

  const initiativesForBatch =
    batch.cohortCodes.length > 0
      ? await db.select().from(initiatives).where(inArray(initiatives.code, batch.cohortCodes))
      : [];

  const initiativeByCode = new Map(initiativesForBatch.map((initiative) => [initiative.code, initiative]));

  return {
    batchId: batch.id,
    status: batch.status,
    cohort: batch.cohortCodes.map((code) => {
      const initiative = initiativeByCode.get(code);
      return {
        initiativeId: initiative?.id ?? code,
        code,
        title: initiative?.title ?? code,
        group: initiative?.group ?? "",
        trackerDetected: true,
        trackerName: null,
      };
    }),
    summary: batch.summary ?? {},
    createdAt: batch.createdAt.toISOString(),
    finishedAt: batch.finishedAt?.toISOString() ?? null,
  };
}

export async function getLatestPilotBatch(): Promise<PilotRun | null> {
  const latest = await db.query.pilotBatches.findFirst({
    orderBy: [desc(pilotBatches.createdAt)],
  });
  if (!latest) {
    return null;
  }

  return getPilotBatch(latest.id);
}
