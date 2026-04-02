import type { FastifyPluginAsync } from "fastify";
import { requireScope } from "../plugins/auth.js";
import { requireExecutive } from "../services/authorization-service.js";
import {
  getLatestPortfolioRefreshRun,
  getPortfolioRefreshRun,
  launchPortfolioRefresh,
} from "../services/portfolio-service.js";

export const portfolioRoutes: FastifyPluginAsync = async (app) => {
  app.get("/portfolio/refresh/latest", async () => {
    return getLatestPortfolioRefreshRun();
  });

  app.get("/portfolio/refresh/runs/:runId", async (request, reply) => {
    const { runId } = request.params as { runId: string };
    const run = await getPortfolioRefreshRun(runId);
    if (!run) {
      return reply.notFound("Portfolio refresh run not found");
    }
    return run;
  });

  app.post("/portfolio/refresh", async (request, reply) => {
    requireScope(request, "run:agents");
    requireExecutive(request);
    reply.code(202);
    return launchPortfolioRefresh({
      requestedByType: request.actor.type,
      requestedById: request.actor.id,
    });
  });
};
