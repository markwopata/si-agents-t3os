import { createHash } from "node:crypto";
import { eq } from "drizzle-orm";
import fp from "fastify-plugin";
import type { FastifyRequest } from "fastify";
import { db } from "../db/client.js";
import { serviceTokens } from "../db/schema.js";
import { env } from "../config/env.js";

type AppRole = "executive" | "participant" | "viewer" | null;
const T3OS_CLAIMS = {
  workspaceId: "https://erp.estrack.com/workspace_id",
  userId: "https://erp.estrack.com/user_id",
} as const;

declare module "fastify" {
  interface FastifyRequest {
    actor: {
      type: "human" | "service_token";
      id: string;
      email: string | null;
      displayName: string | null;
      appRole: AppRole;
      workspaceId: string | null;
      t3osUserId: string | null;
      authSource: "local_headers" | "t3os_jwt" | "service_token";
      platformAccessToken: string | null;
      scopes: string[];
    };
  }
}

function hashToken(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}

export function requireScope(request: FastifyRequest, scope: string): void {
  if (request.actor.type === "human" && env.DEV_AUTH_BYPASS) {
    return;
  }

  if (!request.actor.scopes.includes(scope)) {
    throw new Error(`Missing required scope: ${scope}`);
  }
}

function getHeader(request: FastifyRequest, name: string): string | undefined {
  const value = request.headers[name.toLowerCase()];
  if (Array.isArray(value)) {
    return value[0];
  }
  return value;
}

function executiveEmails(): Set<string> {
  return new Set(
    env.T3OS_EXECUTIVE_EMAILS.split(",")
      .map((value) => value.trim().toLowerCase())
      .filter(Boolean),
  );
}

function looksLikeJwt(token: string): boolean {
  return token.split(".").length === 3;
}

function decodeJwtPayload(token: string): Record<string, unknown> | null {
  try {
    const [, payload] = token.split(".");
    if (!payload) {
      return null;
    }
    const normalized = payload.replace(/-/g, "+").replace(/_/g, "/");
    const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, "=");
    return JSON.parse(Buffer.from(padded, "base64").toString("utf8")) as Record<string, unknown>;
  } catch {
    return null;
  }
}

function deriveHumanScopes(appRole: AppRole): string[] {
  if (appRole === "executive") {
    return [
      "read:initiatives",
      "write:initiatives",
      "read:knowledge",
      "write:knowledge",
      "read:observations",
      "write:observations",
      "read:platform",
      "write:platform",
      "run:agents",
      "manage:tokens",
    ];
  }

  if (appRole === "participant") {
    return [
      "read:initiatives",
      "read:knowledge",
      "write:knowledge",
      "read:observations",
      "read:platform",
      "run:agents",
    ];
  }

  return ["read:initiatives", "read:knowledge", "read:observations", "read:platform"];
}

export const authPlugin = fp(async (app) => {
  app.decorateRequest("actor", null as unknown as FastifyRequest["actor"]);

  app.addHook("preHandler", async (request) => {
    const header = request.headers.authorization;
    if (!header?.startsWith("Bearer ")) {
      const configuredExecutiveEmails = executiveEmails();
      const headerEmail = getHeader(request, env.T3OS_USER_EMAIL_HEADER)?.trim().toLowerCase() ?? null;
      const headerName = getHeader(request, env.T3OS_USER_NAME_HEADER)?.trim() ?? null;
      const headerUserId = getHeader(request, env.T3OS_USER_ID_HEADER)?.trim() ?? null;
      const headerWorkspaceId = getHeader(request, env.T3OS_WORKSPACE_ID_HEADER)?.trim() ?? null;
      const requestedRole = getHeader(request, env.T3OS_APP_ROLE_HEADER)?.trim().toLowerCase() ?? null;
      const derivedRole: AppRole =
        requestedRole === "executive" || requestedRole === "participant" || requestedRole === "viewer"
          ? requestedRole
          : headerEmail && configuredExecutiveEmails.has(headerEmail)
            ? "executive"
            : headerEmail && env.T3OS_TRUST_HEADER_AUTH
              ? "participant"
              : env.DEV_AUTH_BYPASS
                ? "executive"
                : null;

      request.actor = {
        type: "human",
        id: headerUserId ?? "local-dev-user",
        email: headerEmail,
        displayName: headerName,
        appRole: derivedRole,
        workspaceId: headerWorkspaceId,
        t3osUserId: headerUserId,
        authSource: "local_headers",
        platformAccessToken: null,
        scopes: env.DEV_AUTH_BYPASS || env.T3OS_TRUST_HEADER_AUTH ? deriveHumanScopes(derivedRole) : [],
      };
      return;
    }

    const token = header.slice("Bearer ".length);
    if (looksLikeJwt(token)) {
      const configuredExecutiveEmails = executiveEmails();
      const payload = decodeJwtPayload(token) ?? {};
      const email =
        typeof payload.email === "string" ? payload.email.trim().toLowerCase() : null;
      const displayName =
        typeof payload.name === "string"
          ? payload.name
          : typeof payload.nickname === "string"
            ? payload.nickname
            : null;
      const t3osUserId =
        typeof payload[T3OS_CLAIMS.userId] === "string"
          ? String(payload[T3OS_CLAIMS.userId])
          : typeof payload.sub === "string"
            ? payload.sub
            : null;
      const workspaceId =
        typeof payload[T3OS_CLAIMS.workspaceId] === "string"
          ? String(payload[T3OS_CLAIMS.workspaceId])
          : null;
      const requestedRole = getHeader(request, env.T3OS_APP_ROLE_HEADER)?.trim().toLowerCase() ?? null;
      const derivedRole: AppRole =
        requestedRole === "executive" || requestedRole === "participant" || requestedRole === "viewer"
          ? requestedRole
          : email && configuredExecutiveEmails.has(email)
            ? "executive"
            : env.DEV_AUTH_BYPASS
              ? "executive"
              : "participant";

      request.actor = {
        type: "human",
        id: t3osUserId ?? "t3os-user",
        email,
        displayName,
        appRole: derivedRole,
        workspaceId,
        t3osUserId,
        authSource: "t3os_jwt",
        platformAccessToken: token,
        scopes: deriveHumanScopes(derivedRole),
      };
      return;
    }

    const tokenHash = hashToken(token);
    const record = await db.query.serviceTokens.findFirst({
      where: eq(serviceTokens.tokenHash, tokenHash),
    });

    if (!record) {
      request.actor = {
        type: "human",
        id: "unauthorized",
        email: null,
        displayName: null,
        appRole: null,
        workspaceId: null,
        t3osUserId: null,
        authSource: "service_token",
        platformAccessToken: null,
        scopes: [],
      };
      throw app.httpErrors.unauthorized("Invalid service token");
    }

    request.actor = {
      type: "service_token",
      id: record.id,
      email: null,
      displayName: record.label,
      appRole: null,
      workspaceId: null,
      t3osUserId: null,
      authSource: "service_token",
      platformAccessToken: null,
      scopes: record.scopes,
    };
  });
});
