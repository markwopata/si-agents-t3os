import { knowledgeDocumentUpsertSchema } from "@si/domain";
import type { FastifyPluginAsync } from "fastify";
import { requireScope } from "../plugins/auth.js";
import {
  ensureInitiativeContributionAccess,
  ensureInitiativeReadAccess,
  requireExecutive,
} from "../services/authorization-service.js";
import {
  getGlobalKnowledgeDocument,
  getInitiativeById,
  upsertKnowledgeDocument,
} from "../services/initiative-service.js";

export const knowledgeRoutes: FastifyPluginAsync = async (app) => {
  app.get("/knowledge/global", async (_request, reply) => {
    const doc = await getGlobalKnowledgeDocument();
    if (!doc) {
      return reply.notFound("Global knowledge document not found");
    }
    return doc;
  });

  app.put("/knowledge/global", async (request) => {
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

  app.get("/knowledge/initiatives/:initiativeId", async (request, reply) => {
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    const initiative = await getInitiativeById(initiativeId);
    if (!initiative?.knowledgeDocument) {
      return reply.notFound("Initiative knowledge document not found");
    }
    return initiative.knowledgeDocument;
  });

  app.put("/knowledge/initiatives/:initiativeId", async (request, reply) => {
    requireScope(request, "write:knowledge");
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeContributionAccess(request, initiativeId);
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
