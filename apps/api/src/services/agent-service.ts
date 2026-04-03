import fs from "node:fs/promises";
import path from "node:path";
import { evaluateInitiative } from "@si/agent-core";
import { desc, eq, inArray } from "drizzle-orm";
import { env } from "../config/env.js";
import { db } from "../db/client.js";
import {
  agentEvidenceRefs,
  agentObservations,
  agentObservationReviews,
  agentRuns,
  initiativeStatusHistory,
  initiatives,
} from "../db/schema.js";
import { createId } from "../lib/id.js";
import { resolveFromProjectRoot } from "../lib/paths.js";
import { fetchGoogleEvidenceForInitiative } from "../integrations/google/reader.js";
import { fetchSlackEvidenceForInitiative } from "../integrations/slack/reader.js";
import {
  getStoredGoogleEvidenceForInitiative,
  getStoredSlackEvidenceForInitiative,
} from "./history-sync-service.js";
import { getDocumentExtractsForInitiative, summarizeDocumentExtractsForInitiative } from "./document-extraction-service.js";
import { getInitiativeById } from "./initiative-service.js";
import { getLatestKpiResearchForInitiative, runKpiResearchForInitiative } from "./kpi-research-service.js";
import { evaluateInitiativeWithOpenAi, openAiEvaluationEnabled } from "./openai-evaluation-service.js";
import { getLatestTrackerForInitiative } from "./tracker-service.js";

async function getGlobalKnowledgeContent(): Promise<string> {
  try {
    const knowledgePath = path.isAbsolute(env.GLOBAL_KNOWLEDGE_PATH)
      ? env.GLOBAL_KNOWLEDGE_PATH
      : resolveFromProjectRoot(env.GLOBAL_KNOWLEDGE_PATH);
    return await fs.readFile(knowledgePath, "utf8");
  } catch {
    return "";
  }
}

function buildAnnotationKnowledge(
  initiative: NonNullable<Awaited<ReturnType<typeof getInitiativeById>>>,
): string {
  const relevant = initiative.annotations.filter((annotation) =>
    ["operating_instruction", "analysis_instruction", "detail_note", "kpi_suggestion"].includes(
      annotation.annotationType,
    ),
  );

  if (relevant.length === 0) {
    return "";
  }

  return relevant
    .slice(0, 8)
    .map(
      (annotation) =>
        `## ${annotation.annotationType.replace(/_/g, " ")}: ${annotation.title}\n${annotation.content}`,
    )
    .join("\n\n");
}

function normalizeKpiEvidence(
  kpiResearch:
    | Awaited<ReturnType<typeof getLatestKpiResearchForInitiative>>
    | Awaited<ReturnType<typeof runKpiResearchForInitiative>>,
  refreshedAt: string | null,
) {
  return {
    latestResearchRunId:
      "latestResearchRunId" in kpiResearch
        ? kpiResearch.latestResearchRunId
        : kpiResearch.researchRunId,
    researchedAt: "researchedAt" in kpiResearch ? kpiResearch.researchedAt : refreshedAt,
    summary: "summary" in kpiResearch ? kpiResearch.summary : {},
    findings: kpiResearch.findings.map((finding) => ({
      id: finding.id,
      findingClass: finding.findingClass,
      sourceType: finding.sourceType,
      metricKey: finding.metricKey,
      label: finding.label,
      metricValue: finding.metricValue,
      unit: finding.unit,
      narrative: finding.narrative ?? "",
      sourceRef: finding.sourceRef ?? "",
      provenance: finding.provenance,
    })),
  };
}

async function resolveEvaluationResult(input: {
  initiative: NonNullable<Awaited<ReturnType<typeof getInitiativeById>>>;
  globalKnowledge: string;
  slackEvidence: Parameters<typeof evaluateInitiative>[0]["slackEvidence"];
  googleEvidence: Parameters<typeof evaluateInitiative>[0]["googleEvidence"];
  trackerEvidence: Parameters<typeof evaluateInitiative>[0]["trackerEvidence"];
  kpiEvidence: Parameters<typeof evaluateInitiative>[0]["kpiEvidence"];
  runConfig: NonNullable<Awaited<ReturnType<typeof getInitiativeById>>>["runConfig"];
}) {
  const heuristicResult = evaluateInitiative({
    initiative: input.initiative,
    globalKnowledge: input.globalKnowledge,
    slackEvidence: input.slackEvidence,
    googleEvidence: input.googleEvidence,
    trackerEvidence: input.trackerEvidence,
    kpiEvidence: input.kpiEvidence,
    runConfig: input.runConfig,
  });

  if (!openAiEvaluationEnabled()) {
    return {
      result: heuristicResult,
      evaluationMode: "heuristic" as const,
      evaluationModel: null,
    };
  }

  try {
    const llm = await evaluateInitiativeWithOpenAi({
      initiative: input.initiative,
      globalKnowledge: input.globalKnowledge,
      slackEvidence: input.slackEvidence,
      googleEvidence: input.googleEvidence,
      trackerEvidence: input.trackerEvidence,
      kpiEvidence: input.kpiEvidence ?? {
        latestResearchRunId: null,
        researchedAt: null,
        summary: {},
        findings: [],
      },
      heuristicResult,
    });

    return {
      result: llm.result,
      evaluationMode: "openai" as const,
      evaluationModel: llm.model,
    };
  } catch {
    return {
      result: heuristicResult,
      evaluationMode: "heuristic_fallback" as const,
      evaluationModel: env.OPENAI_EVALUATION_MODEL,
    };
  }
}

export async function runEvaluationForInitiative(input: {
  initiativeId: string;
  requestedByType: "human" | "service_token";
  requestedById: string;
  refreshKpisBeforeEvaluation?: boolean;
}): Promise<{ runId: string; observationId: string }> {
  const initiative = await getInitiativeById(input.initiativeId);
  if (!initiative) {
    throw new Error("Initiative not found");
  }

  const runId = createId("run");
  const startedAt = new Date().toISOString();
  await db.insert(agentRuns).values({
    id: runId,
    requestedByType: input.requestedByType,
    requestedById: input.requestedById,
    runScope: "single",
    initiativeId: input.initiativeId,
    status: "running",
  });

  try {
    const kpiResearch = input.refreshKpisBeforeEvaluation
      ? await runKpiResearchForInitiative(initiative, runId)
      : await getLatestKpiResearchForInitiative(initiative.id);

    const [storedSlackEvidence, storedGoogleEvidence, liveSlackEvidence, liveGoogleEvidence, trackerEvidence, documentKnowledge, documentExtracts] =
      await Promise.all([
        getStoredSlackEvidenceForInitiative(initiative),
        getStoredGoogleEvidenceForInitiative(initiative.id),
        fetchSlackEvidenceForInitiative(initiative),
        fetchGoogleEvidenceForInitiative(initiative),
        getLatestTrackerForInitiative(initiative.id),
        summarizeDocumentExtractsForInitiative(initiative.id, 8),
        getDocumentExtractsForInitiative(initiative.id, 8),
      ]);

    const slackEvidence =
      storedSlackEvidence.messages.length > 0 || !liveSlackEvidence.connected
        ? storedSlackEvidence
        : {
            connected: liveSlackEvidence.connected,
            unreadableChannels: liveSlackEvidence.channels
              .filter((channel) => !channel.readable)
              .map((channel) => channel.label),
            messages: liveSlackEvidence.channels.flatMap((channel) =>
              channel.messages.map((message) => ({
                channelId: channel.channelId,
                channelName: channel.channelName,
                label: channel.label,
                url: channel.url,
                ts: message.ts,
                userId: message.userId,
                text: message.text,
                permalink: message.permalink,
                attachments: message.attachments,
                replyCount: message.replyCount,
                replies: message.replies,
              })),
            ),
          };

    const googleEvidence =
      storedGoogleEvidence.files.length > 0 || !liveGoogleEvidence.connected
        ? storedGoogleEvidence
        : {
            connected: liveGoogleEvidence.connected,
            files: liveGoogleEvidence.files.map((file) => ({
              linkId: file.linkId,
              label: file.label,
              url: file.url,
              fileId: file.fileId,
              name: file.name,
              mimeType: file.mimeType,
              readable: file.readable,
              error: file.error,
              modifiedTime: file.modifiedTime,
              lastModifyingUser: file.lastModifyingUser,
              webViewLink: file.webViewLink,
              depth: file.depth,
              crawlPath: file.crawlPath,
              revisions: file.revisions.map((revision) => ({
                id: revision.id,
                modifiedTime: revision.modifiedTime,
                lastModifyingUser: revision.lastModifyingUser,
              })),
              children: file.children.map((child) => ({
                id: child.id,
                parentFileId: child.parentFileId,
                depth: child.depth,
                crawlPath: child.crawlPath,
                name: child.name,
                mimeType: child.mimeType,
                modifiedTime: child.modifiedTime,
                lastModifyingUser: child.lastModifyingUser,
                webViewLink: child.webViewLink,
                revisions: child.revisions.map((revision) => ({
                  id: revision.id,
                  modifiedTime: revision.modifiedTime,
                  lastModifyingUser: revision.lastModifyingUser,
                })),
              })),
            })),
          };

    const globalKnowledge = [await getGlobalKnowledgeContent(), buildAnnotationKnowledge(initiative), documentKnowledge]
      .filter(Boolean)
      .join("\n\n");

    const kpiEvidence = {
      ...normalizeKpiEvidence(
        kpiResearch,
        input.refreshKpisBeforeEvaluation ? startedAt : null,
      ),
    };

    const { result, evaluationMode, evaluationModel } = await resolveEvaluationResult({
      initiative,
      globalKnowledge,
      slackEvidence,
      googleEvidence,
      runConfig: initiative.runConfig,
      kpiEvidence,
      trackerEvidence: {
        connected: trackerEvidence.connected,
        trackerFileId: trackerEvidence.trackerFileId,
        trackerName: trackerEvidence.trackerName,
        parsedAt: trackerEvidence.parsedAt,
        summary: trackerEvidence.summary,
        summaryFields: trackerEvidence.summaryFields.map((field) => ({
          fieldKey: field.fieldKey,
          label: field.label,
          value: field.value,
        })),
        items: trackerEvidence.items.map((item) => ({
          rowNumber: item.rowNumber,
          itemType: item.itemType,
          description: item.description,
          prioritization: item.prioritization,
          phase: item.phase,
          impactPotential: item.impactPotential,
          impactValue: item.impactValue,
          confidence: item.confidence,
          currentValueEstimate: item.currentValueEstimate,
          status: item.status,
          notes: item.notes,
          lastEdited: item.lastEdited,
          submittedBy: item.submittedBy,
        })),
      },
    });

    const observationId = createId("observation");
    await db.insert(agentObservations).values({
      id: observationId,
      initiativeId: initiative.id,
      agentRunId: runId,
      statusRecommendation: result.statusRecommendation,
      progressAssessment: result.progressAssessment,
      confidenceScore: result.confidenceScore,
      topBlockers: result.topBlockers,
      suggestedNextActions: result.suggestedNextActions,
      evidenceSummary: result.evidenceSummary,
    });

    if (result.evidenceReferences.length > 0) {
      await db.insert(agentEvidenceRefs).values(
        result.evidenceReferences.map((reference) => ({
          id: createId("evidence"),
          observationId,
          sourceType: reference.sourceType,
          sourceId: reference.sourceId,
          title: reference.title,
          url: reference.url ?? null,
          excerpt: reference.excerpt,
          metadata: reference.metadata ?? {},
        })),
      );
    }

  const annotationRefs = initiative.annotations
    .filter((annotation) =>
      ["operating_instruction", "analysis_instruction", "detail_note", "kpi_suggestion"].includes(
        annotation.annotationType,
      ),
    )
    .slice(0, 6)
    .map((annotation) => ({
      id: createId("evidence"),
      observationId,
      sourceType: annotation.annotationType,
      sourceId: annotation.id,
      title: annotation.title,
      url: null,
      excerpt: annotation.content.slice(0, 240),
      metadata: {
        annotationType: annotation.annotationType,
        updatedAt: annotation.updatedAt,
      },
    }));

    if (annotationRefs.length > 0) {
      await db.insert(agentEvidenceRefs).values(annotationRefs);
    }

  const documentRefs = documentExtracts
    .filter((extract) => extract.extractionStatus === "completed" && extract.summary.trim())
    .slice(0, 6)
    .map((extract) => ({
      id: createId("evidence"),
      observationId,
      sourceType: extract.sourceType === "google_file" ? "google_drive" : "manual",
      sourceId: extract.id,
      title: `Document ${extract.title}`,
      url: typeof extract.metadata.webViewLink === "string" ? extract.metadata.webViewLink : null,
      excerpt: extract.summary.slice(0, 240),
      metadata: {
        extractor: extract.extractor,
        sourceType: extract.sourceType,
        sourceUpdatedAt: extract.sourceUpdatedAt,
      },
    }));

    if (documentRefs.length > 0) {
      await db.insert(agentEvidenceRefs).values(documentRefs);
    }

    await db.insert(initiativeStatusHistory).values({
      id: createId("history"),
      initiativeId: initiative.id,
      observationId,
      statusRecommendation: result.statusRecommendation,
      rationale: result.progressAssessment,
    });

    await db
      .update(agentRuns)
      .set({
        status: "completed",
        finishedAt: new Date(),
        summary: {
        statusRecommendation: result.statusRecommendation,
        confidenceScore: result.confidenceScore,
        evaluationMode,
        evaluationModel,
      },
    })
    .where(eq(agentRuns.id, runId));

    return {
      runId,
      observationId,
    };
  } catch (error) {
    await db
      .update(agentRuns)
      .set({
        status: "failed",
        finishedAt: new Date(),
        summary: {
          error: error instanceof Error ? error.message : "Evaluation failed",
        },
      })
      .where(eq(agentRuns.id, runId));

    throw error;
  }
}

export async function runEvaluationForAllInitiatives(input: {
  requestedByType: "human" | "service_token";
  requestedById: string;
  refreshKpisBeforeEvaluation?: boolean;
}): Promise<{ runIds: string[]; failures: Array<{ initiativeId: string; code: string; title: string; error: string }> }> {
  const activeInitiatives = await db.query.initiatives.findMany({
    where: eq(initiatives.isActive, true),
    orderBy: (table) => table.code,
  });

  const runIds: string[] = [];
  const failures: Array<{ initiativeId: string; code: string; title: string; error: string }> = [];
  let nextIndex = 0;
  const workerCount = Math.min(env.PORTFOLIO_CONCURRENCY, Math.max(activeInitiatives.length, 1));
  const workers = Array.from({ length: workerCount }, async () => {
    for (;;) {
      const initiative = activeInitiatives[nextIndex];
      nextIndex += 1;

      if (!initiative) {
        return;
      }

      try {
        const result = await runEvaluationForInitiative({
          initiativeId: initiative.id,
          requestedByType: input.requestedByType,
          requestedById: input.requestedById,
          refreshKpisBeforeEvaluation: input.refreshKpisBeforeEvaluation,
        });
        runIds.push(result.runId);
      } catch (error) {
        failures.push({
          initiativeId: initiative.id,
          code: initiative.code,
          title: initiative.title,
          error: error instanceof Error ? error.message : "Evaluation failed",
        });
      }
    }
  });

  await Promise.all(workers);

  return { runIds, failures };
}

export async function getRun(runId: string): Promise<Record<string, unknown> | null> {
  const run = await db.query.agentRuns.findFirst({
    where: eq(agentRuns.id, runId),
  });

  if (!run) {
    return null;
  }

  return {
    id: run.id,
    initiativeId: run.initiativeId,
    status: run.status,
    createdAt: run.createdAt.toISOString(),
    finishedAt: run.finishedAt?.toISOString() ?? null,
    summary: run.summary ?? {},
  };
}

export async function listInitiativeOpinions(initiativeId: string): Promise<Array<Record<string, unknown>>> {
  const rows = await db.query.agentObservations.findMany({
    where: eq(agentObservations.initiativeId, initiativeId),
    orderBy: [desc(agentObservations.createdAt)],
  });

  const evidenceRows =
    rows.length > 0
      ? await db
          .select()
          .from(agentEvidenceRefs)
          .where(inArray(agentEvidenceRefs.observationId, rows.map((row) => row.id)))
      : [];
  const reviewRows =
    rows.length > 0
      ? await db
          .select()
          .from(agentObservationReviews)
          .where(inArray(agentObservationReviews.observationId, rows.map((row) => row.id)))
      : [];

  const evidenceByObservationId = new Map<string, Array<Record<string, unknown>>>();
  const reviewByObservationId = new Map<string, Record<string, unknown>>();
  for (const row of evidenceRows) {
    const current = evidenceByObservationId.get(row.observationId) ?? [];
    current.push({
      id: row.id,
      sourceType: row.sourceType,
      sourceId: row.sourceId,
      title: row.title,
      url: row.url,
      excerpt: row.excerpt,
      metadata: row.metadata,
    });
    evidenceByObservationId.set(row.observationId, current);
  }

  for (const row of reviewRows) {
    reviewByObservationId.set(row.observationId, {
      id: row.id,
      observationId: row.observationId,
      verdict: row.verdict,
      note: row.note,
      reviewerType: row.reviewerType,
      reviewerId: row.reviewerId,
      updatedAt: row.updatedAt.toISOString(),
    });
  }

  return rows.map((row) => ({
    id: row.id,
    initiativeId: row.initiativeId,
    agentRunId: row.agentRunId,
    statusRecommendation: row.statusRecommendation,
    progressAssessment: row.progressAssessment,
    confidenceScore: row.confidenceScore,
    topBlockers: row.topBlockers,
    suggestedNextActions: row.suggestedNextActions,
    evidenceSummary: row.evidenceSummary,
    evidenceReferences: evidenceByObservationId.get(row.id) ?? [],
    review: reviewByObservationId.get(row.id) ?? null,
    createdAt: row.createdAt.toISOString(),
  }));
}
