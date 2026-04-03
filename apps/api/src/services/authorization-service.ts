import { eq, sql } from "drizzle-orm";
import type { FastifyRequest } from "fastify";
import { db } from "../db/client.js";
import { initiativeAnnotations, initiativePeople } from "../db/schema.js";

function httpError(statusCode: number, message: string): Error & { statusCode: number } {
  return Object.assign(new Error(message), { statusCode });
}

export function isExecutiveActor(request: FastifyRequest): boolean {
  return (
    request.actor.type === "service_token" ||
    request.actor.appRole === "admin" ||
    request.actor.appRole === "executive"
  );
}

export function isAdminActor(request: FastifyRequest): boolean {
  return request.actor.type === "service_token" || request.actor.appRole === "admin";
}

export function requireAdmin(request: FastifyRequest): void {
  if (isAdminActor(request)) {
    return;
  }
  throw httpError(403, "Admin permission required");
}

export function requireExecutive(request: FastifyRequest): void {
  if (isExecutiveActor(request)) {
    return;
  }
  throw httpError(403, "Executive permission required");
}

export async function listAccessibleInitiativeIdsForActor(
  request: FastifyRequest,
): Promise<string[] | null> {
  if (isExecutiveActor(request)) {
    return null;
  }

  const email = request.actor.email?.toLowerCase();
  if (!email) {
    return [];
  }

  const rows = await db
    .select({ initiativeId: initiativePeople.initiativeId })
    .from(initiativePeople)
    .where(sql`lower(${initiativePeople.email}) = ${email}`);

  return Array.from(new Set(rows.map((row) => row.initiativeId)));
}

export async function ensureInitiativeReadAccess(
  request: FastifyRequest,
  initiativeId: string,
): Promise<void> {
  const accessible = await listAccessibleInitiativeIdsForActor(request);
  if (accessible === null || accessible.includes(initiativeId)) {
    return;
  }
  throw httpError(403, "You do not have access to this initiative");
}

export async function ensureInitiativeContributionAccess(
  request: FastifyRequest,
  initiativeId: string,
): Promise<void> {
  if (isExecutiveActor(request)) {
    return;
  }

  if (request.actor.appRole !== "member") {
    throw httpError(403, "Member, executive, or admin access is required");
  }

  await ensureInitiativeReadAccess(request, initiativeId);
}

export async function ensureAnnotationDeleteAccess(
  request: FastifyRequest,
  initiativeId: string,
  annotationId: string,
): Promise<void> {
  if (isExecutiveActor(request)) {
    return;
  }

  await ensureInitiativeContributionAccess(request, initiativeId);
  const annotation = await db.query.initiativeAnnotations.findFirst({
    where: eq(initiativeAnnotations.id, annotationId),
  });
  if (!annotation) {
    throw httpError(404, "Initiative annotation not found");
  }

  if (annotation.createdByType === request.actor.type && annotation.createdById === request.actor.id) {
    return;
  }

  throw httpError(403, "Only the annotation author or an executive/admin can delete this entry");
}
