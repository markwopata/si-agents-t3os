import {
  executivePortfolioQueryRequestSchema,
  knowledgeDocumentUpsertSchema,
} from "@si/domain";
import type { FastifyPluginAsync } from "fastify";
import { requireScope } from "../plugins/auth.js";
import {
  ensureInitiativeReadAccess,
  requireExecutive,
} from "../services/authorization-service.js";
import { getExecutiveInitiativeContext } from "../services/executive-agent-service.js";
import { queryExecutivePortfolio } from "../services/executive-portfolio-query-service.js";
import {
  getGlobalKnowledgeDocument,
  getInitiativeById,
  upsertKnowledgeDocument,
} from "../services/initiative-service.js";
import { getInitiativeRawEvidence } from "../services/raw-evidence-service.js";

function asPositiveInt(value: unknown, fallback: number, max: number): number {
  const numeric = Number(value);
  if (!Number.isFinite(numeric) || numeric <= 0) {
    return fallback;
  }
  return Math.min(Math.trunc(numeric), max);
}

function asNonNegativeInt(value: unknown, fallback: number, max: number): number {
  const numeric = Number(value);
  if (!Number.isFinite(numeric) || numeric < 0) {
    return fallback;
  }
  return Math.min(Math.trunc(numeric), max);
}

export const executiveRoutes: FastifyPluginAsync = async (app) => {
  app.post("/executive/portfolio/query", async (request) => {
    requireExecutive(request);
    const parsed = executivePortfolioQueryRequestSchema.parse(request.body ?? {});
    return queryExecutivePortfolio(parsed);
  });

  app.get("/executive/initiatives/:initiativeId/context", async (request, reply) => {
    requireExecutive(request);
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }

    const query = request.query as {
      includeRawEvidence?: string;
      rawEvidenceLimit?: string;
      opinionLimit?: string;
    };

    return getExecutiveInitiativeContext({
      initiativeId,
      includeRawEvidence: query.includeRawEvidence === "true",
      rawEvidenceLimit: asPositiveInt(query.rawEvidenceLimit, 120, 200),
      opinionLimit: asPositiveInt(query.opinionLimit, 12, 100),
    });
  });

  app.get("/executive/initiatives/:initiativeId/raw-package", async (request, reply) => {
    requireExecutive(request);
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }

    const query = request.query as { limit?: string; offset?: string; all?: string };
    const fetchedAt = new Date().toISOString();
    const rawData = await getInitiativeRawEvidence(
      initiativeId,
      query.all === "true" ? null : asPositiveInt(query.limit, 200, 1000),
      asNonNegativeInt(query.offset, 0, 50_000),
    );
    return {
      initiativeId,
      fetchedAt,
      rawData,
      storedRawData: {
        label: "stored_raw_evidence",
        freshness: "stored",
        generatedAt: null,
        fetchedAt,
        data: rawData,
      },
    };
  });

  app.put("/executive/knowledge/global", async (request) => {
    requireScope(request, "write:knowledge");
    requireExecutive(request);
    const body = (request.body ?? {}) as Record<string, unknown>;
    const parsed = knowledgeDocumentUpsertSchema.parse({
      ...body,
      documentType: "global",
      initiativeId: null,
    });
    await upsertKnowledgeDocument(parsed);
    return getGlobalKnowledgeDocument();
  });

  app.put("/executive/initiatives/:initiativeId/knowledge", async (request, reply) => {
    requireScope(request, "write:knowledge");
    requireExecutive(request);
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative) {
      return reply.notFound("Initiative not found");
    }

    const body = (request.body ?? {}) as Record<string, unknown>;
    const parsed = knowledgeDocumentUpsertSchema.parse({
      ...body,
      initiativeId,
      documentType: "initiative",
    });
    await upsertKnowledgeDocument(parsed);
    return (await getInitiativeById(initiativeId))?.knowledgeDocument;
  });
};
