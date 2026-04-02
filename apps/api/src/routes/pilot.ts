import type { FastifyPluginAsync } from "fastify";
import { requireScope } from "../plugins/auth.js";
import { requireExecutive } from "../services/authorization-service.js";
import {
  getLatestPilotBatch,
  getPilotBatch,
  launchPilotBatch,
  previewPilotCohort,
} from "../services/pilot-service.js";

export const pilotRoutes: FastifyPluginAsync = async (app) => {
  app.get("/pilot/cohort", async () => {
    return previewPilotCohort(10);
  });

  app.get("/pilot/latest", async () => {
    return getLatestPilotBatch();
  });

  app.get("/pilot/runs/:batchId", async (request, reply) => {
    const { batchId } = request.params as { batchId: string };
    const batch = await getPilotBatch(batchId);
    if (!batch) {
      return reply.notFound("Pilot batch not found");
    }
    return batch;
  });

  app.post("/pilot/run", async (request, reply) => {
    requireScope(request, "run:agents");
    requireExecutive(request);
    reply.code(202);
    return launchPilotBatch({
      requestedByType: request.actor.type,
      requestedById: request.actor.id,
      limit: 10,
    });
  });
};
