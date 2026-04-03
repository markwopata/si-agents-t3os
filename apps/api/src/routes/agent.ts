import type { FastifyPluginAsync } from "fastify";
import { observationReviewUpsertSchema } from "@si/domain";
import { requireScope } from "../plugins/auth.js";
import {
  ensureInitiativeContributionAccess,
  ensureInitiativeReadAccess,
  requireExecutive,
} from "../services/authorization-service.js";
import {
  getRun,
  listInitiativeOpinions,
  runEvaluationForAllInitiatives,
  runEvaluationForInitiative,
} from "../services/agent-service.js";
import { syncEvidenceForAllInitiatives } from "../services/history-sync-service.js";
import { getObservationReview, upsertObservationReview } from "../services/observation-review-service.js";

export const agentRoutes: FastifyPluginAsync = async (app) => {
  app.post("/agent/run-all", async (request) => {
    requireScope(request, "run:agents");
    requireExecutive(request);
    const body = ((request.body ?? {}) as { refreshKpis?: boolean; hydrateLiveEvidence?: boolean });
    return runEvaluationForAllInitiatives({
      requestedByType: request.actor.type,
      requestedById: request.actor.id,
      refreshKpisBeforeEvaluation: body.refreshKpis ?? true,
      hydrateLiveEvidence: body.hydrateLiveEvidence ?? false,
    });
  });

  app.post("/agent/sync-all", async (request) => {
    requireScope(request, "run:agents");
    requireExecutive(request);
    const body = ((request.body ?? {}) as { staleAfterMinutes?: number });
    return syncEvidenceForAllInitiatives({
      requestedByType: request.actor.type,
      requestedById: request.actor.id,
      staleAfterMinutes: body.staleAfterMinutes ?? 60,
    });
  });

  app.post("/agent/run/:initiativeId", async (request) => {
    requireScope(request, "run:agents");
    const { initiativeId } = request.params as { initiativeId: string };
    const body = ((request.body ?? {}) as { refreshKpis?: boolean; hydrateLiveEvidence?: boolean });
    await ensureInitiativeContributionAccess(request, initiativeId);
    return runEvaluationForInitiative({
      initiativeId,
      requestedByType: request.actor.type,
      requestedById: request.actor.id,
      refreshKpisBeforeEvaluation: body.refreshKpis ?? true,
      hydrateLiveEvidence: body.hydrateLiveEvidence ?? true,
    });
  });

  app.get("/initiatives/:initiativeId/opinions", async (request) => {
    const { initiativeId } = request.params as { initiativeId: string };
    await ensureInitiativeReadAccess(request, initiativeId);
    return listInitiativeOpinions(initiativeId);
  });

  app.get("/agent/runs/:runId", async (request, reply) => {
    const { runId } = request.params as { runId: string };
    const run = await getRun(runId);
    if (!run) {
      return reply.notFound("Agent run not found");
    }
    return run;
  });

  app.get("/observations/:observationId/review", async (request) => {
    const { observationId } = request.params as { observationId: string };
    return getObservationReview(observationId);
  });

  app.put("/observations/:observationId/review", async (request) => {
    requireScope(request, "write:observations");
    const { observationId } = request.params as { observationId: string };
    return upsertObservationReview({
      observationId,
      review: observationReviewUpsertSchema.parse(request.body),
      reviewerType: request.actor.type,
      reviewerId: request.actor.id,
    });
  });
};
