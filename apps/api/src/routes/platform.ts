import {
  createOrUpdateContactInputSchema,
  legacyContactMigrationInputSchema,
  updateContactInputSchema,
  inviteWorkspaceMemberInputSchema,
  updateWorkspaceMemberRolesInputSchema,
} from "@si/domain";
import type { FastifyPluginAsync, FastifyRequest } from "fastify";
import { requireScope } from "../plugins/auth.js";
import { requireAdmin } from "../services/authorization-service.js";
import {
  createPlatformContact,
  invitePlatformWorkspaceMember,
  listPlatformContacts,
  listPlatformWorkspaceMembers,
  removePlatformWorkspaceMember,
  updatePlatformContact,
  updatePlatformWorkspaceMemberRoles,
} from "../services/t3os-platform-service.js";
import {
  getLatestLegacyContactMigrationRun,
  executeLegacyContactsMigration,
  previewLegacyContactsMigration,
} from "../services/legacy-contact-migration-service.js";

function requireHumanPlatformToken(request: FastifyRequest): string {
  if (request.actor.type !== "human" || !request.actor.platformAccessToken) {
    throw new Error("T3OS user session is required for platform access");
  }
  return request.actor.platformAccessToken;
}

function resolveWorkspaceId(request: FastifyRequest, provided: unknown): string {
  if (typeof provided === "string" && provided.trim()) {
    return provided.trim();
  }
  if (request.actor.workspaceId) {
    return request.actor.workspaceId;
  }
  throw new Error("workspaceId is required");
}

export const platformRoutes: FastifyPluginAsync = async (app) => {
  app.get("/platform/contacts", async (request) => {
    requireScope(request, "read:platform");
    const token = requireHumanPlatformToken(request);
    const query = request.query as { workspaceId?: string; contactType?: "PERSON" | "BUSINESS" };
    const workspaceId = resolveWorkspaceId(request, query.workspaceId);
    const items = await listPlatformContacts({
      token,
      workspaceId,
      contactType: query.contactType,
    });
    return {
      workspaceId,
      items,
    };
  });

  app.get("/platform/workspace-members", async (request) => {
    requireScope(request, "read:platform");
    const token = requireHumanPlatformToken(request);
    const query = request.query as { workspaceId?: string };
    const workspaceId = resolveWorkspaceId(request, query.workspaceId);
    const items = await listPlatformWorkspaceMembers({
      token,
      workspaceId,
    });
    return {
      workspaceId,
      items,
    };
  });

  app.post("/platform/contacts", async (request) => {
    requireScope(request, "write:platform");
    requireAdmin(request);
    const token = requireHumanPlatformToken(request);
    const payload = createOrUpdateContactInputSchema.parse(request.body);
    return createPlatformContact({
      token,
      payload,
    });
  });

  app.patch("/platform/contacts/:contactId", async (request) => {
    requireScope(request, "write:platform");
    requireAdmin(request);
    const token = requireHumanPlatformToken(request);
    const { contactId } = request.params as { contactId: string };
    const payload = updateContactInputSchema.parse(request.body);
    return updatePlatformContact({
      token,
      contactId,
      payload,
    });
  });

  app.post("/platform/workspace-members/invite", async (request) => {
    requireScope(request, "write:platform");
    requireAdmin(request);
    const token = requireHumanPlatformToken(request);
    const payload = inviteWorkspaceMemberInputSchema.parse(request.body);
    return invitePlatformWorkspaceMember({
      token,
      workspaceId: resolveWorkspaceId(request, payload.workspaceId),
      email: payload.email,
      roles: payload.roles,
    });
  });

  app.patch("/platform/workspace-members/:userId/roles", async (request) => {
    requireScope(request, "write:platform");
    requireAdmin(request);
    const token = requireHumanPlatformToken(request);
    const { userId } = request.params as { userId: string };
    const payload = updateWorkspaceMemberRolesInputSchema.parse(request.body);
    return updatePlatformWorkspaceMemberRoles({
      token,
      workspaceId: resolveWorkspaceId(request, payload.workspaceId),
      userId,
      roles: payload.roles,
    });
  });

  app.delete("/platform/workspace-members/:userId", async (request) => {
    requireScope(request, "write:platform");
    requireAdmin(request);
    const token = requireHumanPlatformToken(request);
    const { userId } = request.params as { userId: string };
    const query = request.query as { workspaceId?: string };
    const workspaceId = resolveWorkspaceId(request, query.workspaceId);
    return {
      ok: await removePlatformWorkspaceMember({
        token,
        workspaceId,
        userId,
      }),
    };
  });

  app.get("/platform/migrations/legacy-contacts/latest", async (request) => {
    requireScope(request, "read:platform");
    requireAdmin(request);
    const query = request.query as { workspaceId?: string };
    const workspaceId = resolveWorkspaceId(request, query.workspaceId);
    return getLatestLegacyContactMigrationRun(workspaceId);
  });

  app.post("/platform/migrations/legacy-contacts/preview", async (request) => {
    requireScope(request, "write:platform");
    requireAdmin(request);
    const token = requireHumanPlatformToken(request);
    const payload = legacyContactMigrationInputSchema.parse({
      ...(request.body as Record<string, unknown>),
      workspaceId: resolveWorkspaceId(request, (request.body as { workspaceId?: string } | undefined)?.workspaceId),
    });
    return previewLegacyContactsMigration({
      token,
      actor: {
        type: request.actor.type,
        id: request.actor.id,
      },
      payload,
    });
  });

  app.post("/platform/migrations/legacy-contacts/execute", async (request) => {
    requireScope(request, "write:platform");
    requireAdmin(request);
    const token = requireHumanPlatformToken(request);
    const payload = legacyContactMigrationInputSchema.parse({
      ...(request.body as Record<string, unknown>),
      workspaceId: resolveWorkspaceId(request, (request.body as { workspaceId?: string } | undefined)?.workspaceId),
    });
    return executeLegacyContactsMigration({
      token,
      actor: {
        type: request.actor.type,
        id: request.actor.id,
      },
      payload,
    });
  });
};
