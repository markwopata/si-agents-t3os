import type { FastifyPluginAsync } from "fastify";

export const sessionRoutes: FastifyPluginAsync = async (app) => {
  app.get("/me", async (request) => ({
    id: request.actor.id,
    type: request.actor.type,
    email: request.actor.email,
    displayName: request.actor.displayName,
    appRole: request.actor.appRole,
    workspaceId: request.actor.workspaceId,
    t3osUserId: request.actor.t3osUserId,
    authSource: request.actor.authSource,
    scopes: request.actor.scopes,
  }));
};
