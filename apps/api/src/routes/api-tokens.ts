import { apiTokenCreateSchema } from "@si/domain";
import type { FastifyPluginAsync } from "fastify";
import { recordAuditEvent } from "../lib/audit.js";
import {
  type AppRole,
  deriveConfiguredAppRole,
  deriveHumanScopes,
  requireScope,
} from "../plugins/auth.js";
import { isAdminActor } from "../services/authorization-service.js";
import {
  createUserApiToken,
  deleteUserApiToken,
  listUserApiTokens,
} from "../services/user-api-token-service.js";
import { listPlatformWorkspaceMembers } from "../services/t3os-platform-service.js";

function resolveTargetRole(email: string | null, displayName: string | null): AppRole {
  return deriveConfiguredAppRole(email, displayName);
}

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
    const payload = apiTokenCreateSchema.parse(request.body);
    let ownerUserId = request.actor.id;
    let ownerEmail = request.actor.email;
    let ownerDisplayName = request.actor.displayName;
    let ownerWorkspaceId = request.actor.workspaceId;
    let allowedScopes = request.actor.scopes;

    const isDelegatedCreate =
      isAdminActor(request) &&
      (payload.ownerUserId || payload.ownerEmail || payload.ownerDisplayName || payload.ownerWorkspaceId);

    if (isDelegatedCreate) {
      if (request.actor.type !== "human" || !request.actor.platformAccessToken) {
        throw new Error("Admin delegated token creation requires a live T3OS user session");
      }

      const workspaceId = payload.ownerWorkspaceId ?? request.actor.workspaceId;
      if (!workspaceId) {
        throw new Error("ownerWorkspaceId is required for delegated token creation");
      }

      const members = await listPlatformWorkspaceMembers({
        token: request.actor.platformAccessToken,
        workspaceId,
      });

      const requestedEmail = payload.ownerEmail?.trim().toLowerCase() ?? null;
      const requestedUserId = payload.ownerUserId?.trim() ?? null;

      const matchedMember = members.find((member) => {
        const memberEmail = member.user?.email?.trim().toLowerCase() ?? null;
        if (requestedUserId && member.userId === requestedUserId) {
          return true;
        }
        if (requestedEmail && memberEmail === requestedEmail) {
          return true;
        }
        return false;
      });

      if (!matchedMember) {
        throw new Error("Could not find a workspace member matching the selected user");
      }

      ownerUserId = matchedMember.userId;
      ownerEmail = matchedMember.user?.email?.trim().toLowerCase() ?? requestedEmail;
      ownerDisplayName =
        payload.ownerDisplayName?.trim() ||
        matchedMember.user?.name?.trim() ||
        matchedMember.user?.email?.trim() ||
        ownerEmail;
      ownerWorkspaceId = workspaceId;

      const targetRole = resolveTargetRole(ownerEmail, ownerDisplayName);
      allowedScopes = deriveHumanScopes(targetRole);
    }

    const token = await createUserApiToken({
      ownerUserId,
      ownerEmail,
      ownerDisplayName,
      ownerWorkspaceId,
      allowedScopes,
      token: payload,
    });

    await recordAuditEvent({
      actor: request.actor,
      action: "api_token.created",
      entityType: "api_token",
      entityId: token.id,
      payload: {
        ownerUserId,
        ownerEmail,
        ownerDisplayName,
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
