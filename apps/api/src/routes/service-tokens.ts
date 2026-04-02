import { serviceTokenCreateSchema } from "@si/domain";
import type { FastifyPluginAsync } from "fastify";
import { requireScope } from "../plugins/auth.js";
import { requireExecutive } from "../services/authorization-service.js";
import {
  createServiceToken,
  deleteServiceToken,
  listServiceTokens,
} from "../services/service-token-service.js";

export const serviceTokenRoutes: FastifyPluginAsync = async (app) => {
  app.get("/service-tokens", async (request) => {
    requireScope(request, "manage:tokens");
    requireExecutive(request);
    return listServiceTokens();
  });

  app.post("/service-tokens", async (request) => {
    requireScope(request, "manage:tokens");
    requireExecutive(request);
    const token = await createServiceToken(serviceTokenCreateSchema.parse(request.body));
    return token;
  });

  app.delete("/service-tokens/:tokenId", async (request) => {
    requireScope(request, "manage:tokens");
    requireExecutive(request);
    const { tokenId } = request.params as { tokenId: string };
    await deleteServiceToken(tokenId);
    return { ok: true };
  });
};
