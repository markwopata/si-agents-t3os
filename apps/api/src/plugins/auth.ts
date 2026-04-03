import { createHash } from "node:crypto";
import { eq } from "drizzle-orm";
import fp from "fastify-plugin";
import type { FastifyRequest } from "fastify";
import { createRemoteJWKSet, jwtVerify, type JWTPayload } from "jose";
import { db } from "../db/client.js";
import { serviceTokens, userApiTokens } from "../db/schema.js";
import { env } from "../config/env.js";

export type AppRole = "admin" | "executive" | "member" | null;
const T3OS_CLAIMS = {
  workspaceId: "https://erp.estrack.com/workspace_id",
  userId: "https://erp.estrack.com/user_id",
} as const;
const FALLBACK_ADMIN_DISPLAY_NAMES = new Set(["mark wopata", "kim misher"]);
const FALLBACK_EXECUTIVE_DISPLAY_NAMES = new Set([
  "lindsey malhiot",
  "jabbok schlacks",
  "william schlacks",
  "willy schlacks",
]);
const jwksCache = new Map<string, ReturnType<typeof createRemoteJWKSet>>();

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
      authSource: "local_headers" | "t3os_jwt" | "api_token" | "service_token";
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

function configuredEmails(value: string): Set<string> {
  return new Set(
    value.split(",")
      .map((value) => value.trim().toLowerCase())
      .filter(Boolean),
  );
}

function adminEmails(): Set<string> {
  return configuredEmails(env.T3OS_ADMIN_EMAILS);
}

function executiveEmails(): Set<string> {
  return configuredEmails(env.T3OS_EXECUTIVE_EMAILS);
}

function intersectScopes(granted: string[], allowed: string[]): string[] {
  const allowedSet = new Set(allowed);
  return granted.filter((scope) => allowedSet.has(scope));
}

function normalizeDisplayName(value: string | null): string | null {
  if (!value) {
    return null;
  }

  const normalized = value.trim().toLowerCase().replace(/\s+/g, " ");
  return normalized.length > 0 ? normalized : null;
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

export function deriveHumanScopes(appRole: AppRole): string[] {
  if (appRole === "admin") {
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

  if (appRole === "executive") {
    return [
      "read:initiatives",
      "write:initiatives",
      "read:knowledge",
      "write:knowledge",
      "read:observations",
      "write:observations",
      "read:platform",
      "run:agents",
    ];
  }

  if (appRole === "member") {
    return [
      "read:initiatives",
      "read:knowledge",
      "write:knowledge",
      "read:observations",
      "write:observations",
      "run:agents",
      "manage:tokens",
    ];
  }

  return ["read:initiatives", "read:knowledge", "read:observations"];
}

function normalizeIssuer(issuer: string): string {
  return issuer.endsWith("/") ? issuer : `${issuer}/`;
}

function buildJwksUri(): string {
  if (env.T3OS_JWKS_URI?.trim()) {
    return env.T3OS_JWKS_URI.trim();
  }

  return new URL(".well-known/jwks.json", normalizeIssuer(env.T3OS_JWT_ISSUER)).toString();
}

function getJwks() {
  const jwksUri = buildJwksUri();
  const existing = jwksCache.get(jwksUri);
  if (existing) {
    return existing;
  }

  const jwks = createRemoteJWKSet(new URL(jwksUri));
  jwksCache.set(jwksUri, jwks);
  return jwks;
}

async function verifyT3osJwt(token: string): Promise<JWTPayload> {
  const { payload } = await jwtVerify(token, getJwks(), {
    issuer: normalizeIssuer(env.T3OS_JWT_ISSUER),
    audience: env.T3OS_JWT_AUDIENCE,
  });
  return payload;
}

function extractStringArrayClaim(payload: Record<string, unknown>, claim: string): string[] {
  const value = payload[claim];
  return Array.isArray(value) ? value.filter((entry): entry is string => typeof entry === "string") : [];
}

function extractJwtEmail(payload: Record<string, unknown>): string | null {
  const candidates = [
    payload.email,
    payload.preferred_username,
    payload.upn,
    payload["https://erp.estrack.com/email"],
    payload["https://equipmentshare.com/email"],
    payload["https://equipmentshare.com/user_email"],
  ];

  for (const candidate of candidates) {
    if (typeof candidate === "string" && candidate.trim().length > 0) {
      return candidate.trim().toLowerCase();
    }
  }

  return null;
}

function deriveJwtAppRole(
  _payload: Record<string, unknown>,
  email: string | null,
  displayName: string | null,
): AppRole {
  void _payload;
  return deriveConfiguredAppRole(email, displayName);
}

function deriveJwtScopes(payload: Record<string, unknown>, appRole: AppRole): string[] {
  void payload;
  return deriveHumanScopes(appRole);
}

export function deriveConfiguredAppRole(email: string | null, displayName: string | null): AppRole {
  if (email && adminEmails().has(email)) {
    return "admin";
  }

  if (email && executiveEmails().has(email)) {
    return "executive";
  }

  const normalizedDisplayName = normalizeDisplayName(displayName);
  if (normalizedDisplayName && FALLBACK_ADMIN_DISPLAY_NAMES.has(normalizedDisplayName)) {
    return "admin";
  }

  if (normalizedDisplayName && FALLBACK_EXECUTIVE_DISPLAY_NAMES.has(normalizedDisplayName)) {
    return "executive";
  }

  return "member";
}

export const authPlugin = fp(async (app) => {
  app.decorateRequest("actor", null as unknown as FastifyRequest["actor"]);

  app.addHook("preHandler", async (request) => {
    const header = request.headers.authorization;
    if (!header?.startsWith("Bearer ")) {
      const configuredAdminEmails = adminEmails();
      const configuredExecutiveEmails = executiveEmails();
      const headerEmail = getHeader(request, env.T3OS_USER_EMAIL_HEADER)?.trim().toLowerCase() ?? null;
      const headerName = getHeader(request, env.T3OS_USER_NAME_HEADER)?.trim() ?? null;
      const headerUserId = getHeader(request, env.T3OS_USER_ID_HEADER)?.trim() ?? null;
      const headerWorkspaceId = getHeader(request, env.T3OS_WORKSPACE_ID_HEADER)?.trim() ?? null;
      const requestedRole = getHeader(request, env.T3OS_APP_ROLE_HEADER)?.trim().toLowerCase() ?? null;
      const derivedRole: AppRole =
        requestedRole === "admin" || requestedRole === "executive" || requestedRole === "member"
          ? requestedRole
          : headerEmail && configuredAdminEmails.has(headerEmail)
            ? "admin"
            : headerEmail && configuredExecutiveEmails.has(headerEmail)
              ? "executive"
              : headerEmail && env.T3OS_TRUST_HEADER_AUTH
                ? "member"
                : env.DEV_AUTH_BYPASS
                  ? "admin"
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
      let payload: Record<string, unknown>;

      try {
        payload = (await verifyT3osJwt(token)) as Record<string, unknown>;
      } catch (error) {
        if (!env.DEV_AUTH_BYPASS) {
          request.actor = {
            type: "human",
            id: "unauthorized",
            email: null,
            displayName: null,
            appRole: null,
            workspaceId: null,
            t3osUserId: null,
            authSource: "t3os_jwt",
            platformAccessToken: null,
            scopes: [],
          };
          request.log.warn({ error }, "JWT verification failed");
          throw app.httpErrors.unauthorized("Invalid bearer token");
        }

        request.log.warn({ error }, "JWT verification failed; using dev decode fallback");
        payload = decodeJwtPayload(token) ?? {};
      }

      const email = extractJwtEmail(payload);
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
      const derivedRole: AppRole = env.DEV_AUTH_BYPASS
        ? "admin"
        : deriveJwtAppRole(payload, email, displayName);

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
        scopes: deriveJwtScopes(payload, derivedRole),
      };
      return;
    }

    const tokenHash = hashToken(token);
    const userApiTokenRecord = await db.query.userApiTokens.findFirst({
      where: eq(userApiTokens.tokenHash, tokenHash),
    });

    if (userApiTokenRecord) {
      const appRole = deriveConfiguredAppRole(
        userApiTokenRecord.ownerEmail ?? null,
        userApiTokenRecord.ownerDisplayName ?? null,
      );

      await db
        .update(userApiTokens)
        .set({ lastUsedAt: new Date() })
        .where(eq(userApiTokens.id, userApiTokenRecord.id));

      request.actor = {
        type: "human",
        id: userApiTokenRecord.ownerUserId,
        email: userApiTokenRecord.ownerEmail ?? null,
        displayName: userApiTokenRecord.ownerDisplayName ?? null,
        appRole,
        workspaceId: userApiTokenRecord.ownerWorkspaceId ?? null,
        t3osUserId: userApiTokenRecord.ownerUserId,
        authSource: "api_token",
        platformAccessToken: null,
        scopes: intersectScopes(userApiTokenRecord.scopes, deriveHumanScopes(appRole)),
      };
      return;
    }

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
