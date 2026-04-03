import { apiTokenCreateSchema } from "@si/domain";
import type { FastifyPluginAsync } from "fastify";
import { recordAuditEvent } from "../lib/audit.js";
import { requireScope } from "../plugins/auth.js";
import { isAdminActor } from "../services/authorization-service.js";
import {
  createUserApiToken,
  deleteUserApiToken,
  listUserApiTokens,
} from "../services/user-api-token-service.js";

export const apiTokenRoutes: FastifyPluginAsync = async (app) => {
  app.get("/api-tokens", async (request) => {
    requireScope(request, "manage:tokens");
    const query = (request.query ?? {}) as { all?: string };

    return listUserApiTokens({
      ownerUserId: request.actor.id,
      includeAllForAdmin: isAdminActor(request) && query.all === "true",
    });
  });

  app.post("/api-tokens", async (request) => {
    requireScope(request, "manage:tokens");
    const token = await createUserApiToken({
      ownerUserId: request.actor.id,
      ownerEmail: request.actor.email,
      ownerDisplayName: request.actor.displayName,
      ownerWorkspaceId: request.actor.workspaceId,
      allowedScopes: request.actor.scopes,
      token: apiTokenCreateSchema.parse(request.body),
    });

    await recordAuditEvent({
      actor: request.actor,
      action: "api_token.created",
      entityType: "api_token",
      entityId: token.id,
      payload: {
        ownerUserId: request.actor.id,
      },
    });

    return token;
  });

  app.delete("/api-tokens/:tokenId", async (request) => {
    requireScope(request, "manage:tokens");
    const { tokenId } = request.params as { tokenId: string };

    await deleteUserApiToken({
      tokenId,
      ownerUserId: request.actor.id,
      includeAllForAdmin: isAdminActor(request),
    });

    await recordAuditEvent({
      actor: request.actor,
      action: "api_token.deleted",
      entityType: "api_token",
      entityId: tokenId,
      payload: {},
    });

    return { ok: true };
  });
};
