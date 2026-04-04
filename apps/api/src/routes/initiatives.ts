import {
  initiativeAnnotationCreateSchema,
  initiativeAgentQueryRequestSchema,
  initiativeAskRequestSchema,
  initiativeRankingUpdateSchema,
  initiativeRunConfigUpsertSchema,
  initiativeCreateSchema,
  initiativeUpdateSchema,
  linksReplaceSchema,
  peopleReplaceSchema,
  periodSnapshotsReplaceSchema,
} from "@si/domain";
import type { FastifyPluginAsync } from "fastify";
import { fetchGoogleEvidenceForInitiative } from "../integrations/google/reader.js";
import { fetchSlackEvidenceForInitiative } from "../integrations/slack/reader.js";
import { recordAuditEvent } from "../lib/audit.js";
import { recordAgentQueryLog } from "../lib/query-log.js";
import { requireScope } from "../plugins/auth.js";
import { askInitiativeQuestion } from "../services/ask-service.js";
import {
  ensureAnnotationDeleteAccess,
  ensureInitiativeContributionAccess,
  ensureInitiativeReadAccess,
  listAccessibleInitiativeIdsForActor,
  requireAdmin,
  requireExecutive,
} from "../services/authorization-service.js";
import {
  extractDocumentsForInitiative,
  getDocumentExtractsForInitiative,
} from "../services/document-extraction-service.js";
import {
  getStoredGoogleEvidenceForInitiative,
  getStoredSlackEvidenceForInitiative,
  syncGoogleHistoryForInitiative,
  syncSlackHistoryForInitiative,
} from "../services/history-sync-service.js";
import {
  addInitiativeAnnotation,
  archiveInitiative,
  createInitiative,
  deleteInitiativeAnnotation,
  getInitiativeById,
  listInitiativeAnnotations,
  listInitiatives,
  replaceInitiativeLinks,
  replaceInitiativePeople,
  replaceInitiativeSnapshots,
  updateInitiative,
} from "../services/initiative-service.js";
import { getLatestKpiResearchForInitiative, runKpiResearchForInitiative } from "../services/kpi-research-service.js";
import { runInitiativeAgentQuery } from "../services/initiative-agent-query-service.js";
import { getInitiativeRawEvidence } from "../services/raw-evidence-service.js";
import { recomputePriorityRanking, saveManualPriorityRanking } from "../services/ranking-service.js";
import { getInitiativeRunConfig, upsertInitiativeRunConfig } from "../services/run-config-service.js";
import { hydrateInitiativePeopleFromT3os } from "../services/t3os-platform-service.js";
import { getLatestTrackerForInitiative, parseTrackerForInitiative } from "../services/tracker-service.js";

export const initiativeRoutes: FastifyPluginAsync = async (app) => {
  app.get("/initiatives", async (request) => {
    const rows = await listInitiatives();
    const accessibleIds = await listAccessibleInitiativeIdsForActor(request);
    return accessibleIds === null
      ? rows
      : rows.filter((initiative) => accessibleIds.includes(initiative.id));
  });

  app.get("/initiatives/:initiativeId", async (request, reply) => {
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }
    if (request.actor.type === "human" && request.actor.platformAccessToken && request.actor.workspaceId) {
      try {
        initiative.people = await hydrateInitiativePeopleFromT3os({
          token: request.actor.platformAccessToken,
          workspaceId: request.actor.workspaceId,
          people: initiative.people,
        });
      } catch (error) {
        request.log.warn({ error, initiativeId }, "Unable to hydrate initiative people from T3OS");
      }
    }
    return initiative;
  });

  app.get("/initiatives/:initiativeId/slack-evidence", async (request, reply) => {
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }
    const stored = await getStoredSlackEvidenceForInitiative(initiative);
    if (stored.messages.length > 0 || stored.issues.length > 0) {
      const channelMap = new Map<string, {
        channelId: string;
        channelName: string | null;
        label: string;
        url: string;
        readable: boolean;
        error: string | null;
        messages: Array<{
          ts: string;
          userId: string | null;
          text: string;
          permalink: string | null;
          attachments: Array<{
            id: string;
            title: string | null;
            name: string | null;
            mimeType: string | null;
            fileType: string | null;
            prettyType: string | null;
            sizeBytes: number | null;
            permalink: string | null;
            privateUrl: string | null;
            privateDownloadUrl: string | null;
            textExcerpt: string | null;
          }>;
          replyCount: number;
          replies: Array<{
            ts: string;
            userId: string | null;
            text: string;
            attachments: Array<{
              id: string;
              title: string | null;
              name: string | null;
              mimeType: string | null;
              fileType: string | null;
              prettyType: string | null;
              sizeBytes: number | null;
              permalink: string | null;
              privateUrl: string | null;
              privateDownloadUrl: string | null;
              textExcerpt: string | null;
            }>;
          }>;
        }>;
      }>();

      for (const message of stored.messages) {
        const current = channelMap.get(message.channelId) ?? {
          channelId: message.channelId,
          channelName: message.channelName,
          label: message.label,
          url: message.url,
          readable: true,
          error: null,
          messages: [],
        };
        current.messages.push({
          ts: message.ts,
          userId: message.userId,
          text: message.text,
          permalink: message.permalink,
          attachments: message.attachments,
          replyCount: message.replyCount,
          replies: message.replies,
        });
        channelMap.set(message.channelId, current);
      }

      for (const issue of stored.issues) {
        const channelId = issue.sourceId ?? `issue-${issue.id}`;
        if (channelMap.has(channelId)) {
          const current = channelMap.get(channelId)!;
          current.readable = false;
          current.error = issue.message;
          continue;
        }
        channelMap.set(channelId, {
          channelId,
          channelName: null,
          label: String(issue.metadata.channelLabel ?? issue.sourceId ?? "Slack channel"),
          url: String(issue.metadata.channelUrl ?? ""),
          readable: false,
          error: issue.message,
          messages: [],
        });
      }

      return {
        connected: stored.connected,
        initiativeId,
        channels: Array.from(channelMap.values()),
        issues: stored.issues,
        fetchedAt: new Date().toISOString(),
      };
    }

    const live = await fetchSlackEvidenceForInitiative(initiative);
    return {
      ...live,
      issues: [],
    };
  });

  app.get("/initiatives/:initiativeId/google-evidence", async (request, reply) => {
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }

    const stored = await getStoredGoogleEvidenceForInitiative(initiativeId);
    if (stored.files.length > 0 || stored.issues.length > 0) {
      return {
        ...stored,
        fetchedAt: new Date().toISOString(),
      };
    }

    const live = await fetchGoogleEvidenceForInitiative(initiative);
    return {
      ...live,
      issues: [],
    };
  });

  app.get("/initiatives/:initiativeId/tracker", async (request, reply) => {
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }

    return getLatestTrackerForInitiative(initiativeId);
  });

  app.get("/initiatives/:initiativeId/kpi-research", async (request, reply) => {
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }

    return getLatestKpiResearchForInitiative(initiativeId);
  });

  app.get("/initiatives/:initiativeId/annotations", async (request, reply) => {
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }
    return listInitiativeAnnotations(initiativeId);
  });

  app.post("/initiatives/:initiativeId/annotations", async (request, reply) => {
    requireScope(request, "write:knowledge");
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeContributionAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }

    const annotation = await addInitiativeAnnotation({
      initiativeId,
      annotation: initiativeAnnotationCreateSchema.parse(request.body),
      createdByType: request.actor.type,
      createdById: request.actor.id,
    });
    return annotation;
  });

  app.delete("/initiatives/:initiativeId/annotations/:annotationId", async (request, reply) => {
    requireScope(request, "write:knowledge");
    const { initiativeId, annotationId } = request.params as { initiativeId: string; annotationId: string };
    await ensureAnnotationDeleteAccess(request, initiativeId, annotationId);
    const deleted = await deleteInitiativeAnnotation(initiativeId, annotationId);
    if (!deleted) {
      return reply.notFound("Initiative annotation not found");
    }
    return { ok: true };
  });

  app.get("/initiatives/:initiativeId/raw-evidence", async (request, reply) => {
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }

    const { limit, offset, all } = (request.query as {
      limit?: string;
      offset?: string;
      all?: string;
    }) ?? {};
    return getInitiativeRawEvidence(
      initiativeId,
      all === "true" ? null : limit ? Number(limit) : undefined,
      offset ? Number(offset) : undefined,
    );
  });

  app.get("/initiatives/:initiativeId/document-extracts", async (request, reply) => {
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }

    const { limit } = (request.query as { limit?: string }) ?? {};
    return getDocumentExtractsForInitiative(initiativeId, limit ? Number(limit) : undefined);
  });

  app.post("/initiatives/:initiativeId/agent-query", async (request, reply) => {
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }

    const parsed = initiativeAgentQueryRequestSchema.parse(request.body ?? {});
    if (
      parsed.mode === "assess" ||
      parsed.mode === "full" ||
      parsed.refreshPolicy !== "never"
    ) {
      requireScope(request, "run:agents");
    }

    try {
      const result = await runInitiativeAgentQuery({
        initiativeId,
        requestedByType: request.actor.type,
        requestedById: request.actor.id,
        mode: parsed.mode,
        refreshPolicy: parsed.refreshPolicy,
        staleAfterMinutes: parsed.staleAfterMinutes,
        refreshKpis:
          parsed.refreshKpis ??
          (parsed.mode === "assess" || parsed.mode === "full"),
      });

      await recordAgentQueryLog({
        actor: request.actor,
        route: "/initiatives/:initiativeId/agent-query",
        entityType: "initiative",
        entityId: initiativeId,
        requestPayload: {
          mode: parsed.mode,
          refreshPolicy: parsed.refreshPolicy,
          staleAfterMinutes: parsed.staleAfterMinutes,
          refreshKpis:
            parsed.refreshKpis ??
            (parsed.mode === "assess" || parsed.mode === "full"),
        },
        responseSummary: {
          hasRawData: Boolean(result.rawData),
          hasInsights: Boolean(result.insights),
          hasAssessment: Boolean(result.assessment),
        },
        status: "succeeded",
      });

      return result;
    } catch (error) {
      await recordAgentQueryLog({
        actor: request.actor,
        route: "/initiatives/:initiativeId/agent-query",
        entityType: "initiative",
        entityId: initiativeId,
        requestPayload: {
          mode: parsed.mode,
          refreshPolicy: parsed.refreshPolicy,
          staleAfterMinutes: parsed.staleAfterMinutes,
          refreshKpis:
            parsed.refreshKpis ??
            (parsed.mode === "assess" || parsed.mode === "full"),
        },
        status: "failed",
        errorText: error instanceof Error ? error.message : String(error),
      });
      throw error;
    }
  });

  app.post("/initiatives/:initiativeId/ask", async (request, reply) => {
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }

    const parsed = initiativeAskRequestSchema.parse(request.body);
    try {
      const result = await askInitiativeQuestion({
        initiativeId,
        question: parsed.question,
        includeRawEvidence: parsed.includeRawEvidence,
      });

      await recordAgentQueryLog({
        actor: request.actor,
        route: "/initiatives/:initiativeId/ask",
        entityType: "initiative",
        entityId: initiativeId,
        prompt: parsed.question,
        requestPayload: parsed,
        responseSummary: {
          confidence: result.confidence,
          evidenceCount: result.evidence.length,
          followUpCount: result.followUps.length,
          answerPreview: result.answer.slice(0, 240),
        },
        status: "succeeded",
      });

      return result;
    } catch (error) {
      await recordAgentQueryLog({
        actor: request.actor,
        route: "/initiatives/:initiativeId/ask",
        entityType: "initiative",
        entityId: initiativeId,
        prompt: parsed.question,
        requestPayload: parsed,
        status: "failed",
        errorText: error instanceof Error ? error.message : String(error),
      });
      throw error;
    }
  });

  app.get("/initiatives/:initiativeId/run-config", async (request, reply) => {
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }
    return getInitiativeRunConfig(initiativeId);
  });

  app.put("/initiatives/:initiativeId/run-config", async (request, reply) => {
    requireScope(request, "write:knowledge");
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeContributionAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }
    return upsertInitiativeRunConfig({
      initiativeId,
      config: initiativeRunConfigUpsertSchema.parse(request.body),
      updatedByType: request.actor.type,
      updatedById: request.actor.id,
    });
  });

  app.post("/initiatives/:initiativeId/sync-history", async (request, reply) => {
    requireScope(request, "run:agents");
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeContributionAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }

    const [slackSync, googleSync] = await Promise.all([
      syncSlackHistoryForInitiative(initiative),
      syncGoogleHistoryForInitiative(initiative),
    ]);
    const extraction = await extractDocumentsForInitiative({
      initiativeId,
      slackRunIds: slackSync.runIds,
      googleRunId: googleSync.runId,
    });
    const tracker = await parseTrackerForInitiative(initiativeId, googleSync.runId);

    return {
      ok: true,
      slackSync,
      googleSync,
      extraction,
      trackerParseRunId: tracker?.latestParseRunId ?? null,
    };
  });

  app.post("/initiatives/:initiativeId/research-kpis", async (request, reply) => {
    requireScope(request, "run:agents");
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeContributionAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }

    return runKpiResearchForInitiative(initiative);
  });

  app.put("/initiatives/ranking", async (request) => {
    requireScope(request, "write:initiatives");
    requireExecutive(request);
    const parsed = initiativeRankingUpdateSchema.parse(request.body);
    return saveManualPriorityRanking(parsed.orderedIds);
  });

  app.post("/initiatives/ranking/recompute", async (request) => {
    requireScope(request, "write:initiatives");
    requireExecutive(request);
    return recomputePriorityRanking();
  });

  app.post("/initiatives", async (request) => {
    requireScope(request, "write:initiatives");
    requireAdmin(request);
    const created = await createInitiative(initiativeCreateSchema.parse(request.body));
    await recordAuditEvent({
      actor: request.actor,
      action: "initiative.created",
      entityType: "initiative",
      entityId: created.id,
      payload: created,
    });
    return created;
  });

  app.patch("/initiatives/:initiativeId", async (request, reply) => {
    requireScope(request, "write:initiatives");
    requireAdmin(request);
    const { initiativeId } = request.params as { initiativeId: string };
    const updated = await updateInitiative(
      initiativeId,
      initiativeUpdateSchema.parse(request.body),
    );
    if (!updated) {
      return reply.notFound("Initiative not found");
    }

    await recordAuditEvent({
      actor: request.actor,
      action: "initiative.updated",
      entityType: "initiative",
      entityId: initiativeId,
      payload: updated,
    });

    return updated;
  });

  app.delete("/initiatives/:initiativeId", async (request) => {
    requireScope(request, "write:initiatives");
    requireAdmin(request);
    const { initiativeId } = request.params as { initiativeId: string };
    await archiveInitiative(initiativeId);
    await recordAuditEvent({
      actor: request.actor,
      action: "initiative.archived",
      entityType: "initiative",
      entityId: initiativeId,
      payload: {},
    });
    return { ok: true };
  });

  app.put("/initiatives/:initiativeId/people", async (request) => {
    requireScope(request, "write:initiatives");
    requireAdmin(request);
    const { initiativeId } = request.params as { initiativeId: string };
    const parsed = peopleReplaceSchema.parse(request.body);
    await replaceInitiativePeople(initiativeId, parsed.people);
    return { ok: true };
  });

  app.put("/initiatives/:initiativeId/links", async (request) => {
    requireScope(request, "write:initiatives");
    requireAdmin(request);
    const { initiativeId } = request.params as { initiativeId: string };
    const parsed = linksReplaceSchema.parse(request.body);
    await replaceInitiativeLinks(initiativeId, parsed.links);
    return { ok: true };
  });

  app.put("/initiatives/:initiativeId/period-snapshots", async (request) => {
    requireScope(request, "write:initiatives");
    requireAdmin(request);
    const { initiativeId } = request.params as { initiativeId: string };
    const parsed = periodSnapshotsReplaceSchema.parse(request.body);
    await replaceInitiativeSnapshots(initiativeId, parsed.snapshots);
    return { ok: true };
  });
};
