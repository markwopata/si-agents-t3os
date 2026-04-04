import { and, desc, eq, gte } from "drizzle-orm";
import { agentQueryLogs } from "../db/schema.js";
import { db } from "../db/client.js";
import { createId } from "./id.js";

type QueryLogActor = {
  type: "human" | "service_token";
  id: string;
  email?: string | null;
  appRole?: string | null;
  workspaceId?: string | null;
  authSource?: string | null;
};

type QueryLogStatus = "succeeded" | "failed";
type QueryLogType = "query" | "request";

function truncate(value: string, maxLength: number): string {
  return value.length > maxLength ? `${value.slice(0, maxLength - 1)}…` : value;
}

function sanitizeForLog(value: unknown, depth = 0): unknown {
  if (depth > 3) {
    return "[truncated]";
  }

  if (value === null || value === undefined) {
    return value;
  }

  if (typeof value === "string") {
    return truncate(value, 500);
  }

  if (typeof value === "number" || typeof value === "boolean") {
    return value;
  }

  if (Array.isArray(value)) {
    return value.slice(0, 10).map((entry) => sanitizeForLog(entry, depth + 1));
  }

  if (typeof value === "object") {
    const entries = Object.entries(value as Record<string, unknown>)
      .filter(([key]) => !["authorization", "token", "accessToken", "refreshToken", "password"].includes(key))
      .slice(0, 20)
      .map(([key, entry]) => [key, sanitizeForLog(entry, depth + 1)]);
    return Object.fromEntries(entries);
  }

  return String(value);
}

export function extractPromptFromPayload(payload: unknown): string | null {
  if (!payload || typeof payload !== "object") {
    return null;
  }

  const candidateKeys = ["question", "prompt", "query", "message", "content"];
  for (const key of candidateKeys) {
    const value = (payload as Record<string, unknown>)[key];
    if (typeof value === "string" && value.trim().length > 0) {
      return truncate(value.trim(), 2000);
    }
  }

  return null;
}

export function summarizeRequestForLog(input: {
  params?: unknown;
  query?: unknown;
  body?: unknown;
}): Record<string, unknown> {
  return {
    params: sanitizeForLog(input.params ?? {}),
    query: sanitizeForLog(input.query ?? {}),
    body: sanitizeForLog(input.body ?? {}),
  };
}

export async function recordAgentQueryLog(input: {
  actor: QueryLogActor;
  logType?: QueryLogType;
  route: string;
  requestPath?: string | null;
  method?: string | null;
  entityType?: string | null;
  entityId?: string | null;
  prompt?: string | null;
  requestPayload?: Record<string, unknown>;
  responseSummary?: Record<string, unknown>;
  status: QueryLogStatus;
  statusCode?: number | null;
  durationMs?: number | null;
  userAgent?: string | null;
  errorText?: string | null;
}): Promise<void> {
  await db.insert(agentQueryLogs).values({
    id: createId("query_log"),
    logType: input.logType ?? "query",
    actorType: input.actor.type,
    actorId: input.actor.id,
    actorEmail: input.actor.email ?? null,
    actorRole: input.actor.appRole ?? null,
    workspaceId: input.actor.workspaceId ?? null,
    authSource: input.actor.authSource ?? null,
    method: input.method ?? null,
    route: input.route,
    requestPath: input.requestPath ?? null,
    entityType: input.entityType ?? null,
    entityId: input.entityId ?? null,
    prompt: input.prompt ?? null,
    requestPayload: input.requestPayload ?? {},
    responseSummary: input.responseSummary ?? {},
    status: input.status,
    statusCode: input.statusCode ?? null,
    durationMs: input.durationMs ?? null,
    userAgent: input.userAgent ?? null,
    errorText: input.errorText ?? null,
  });
}

export async function listAgentQueryLogs(input: {
  limit: number;
  logType?: QueryLogType;
  method?: string;
  status?: QueryLogStatus;
  sinceHours?: number;
  route?: string;
  entityType?: string;
  entityId?: string;
}) {
  const filters = [];
  if (input.logType) {
    filters.push(eq(agentQueryLogs.logType, input.logType));
  }
  if (input.method) {
    filters.push(eq(agentQueryLogs.method, input.method));
  }
  if (input.status) {
    filters.push(eq(agentQueryLogs.status, input.status));
  }
  if (input.route) {
    filters.push(eq(agentQueryLogs.route, input.route));
  }
  if (input.entityType) {
    filters.push(eq(agentQueryLogs.entityType, input.entityType));
  }
  if (input.entityId) {
    filters.push(eq(agentQueryLogs.entityId, input.entityId));
  }
  if (input.sinceHours && input.sinceHours > 0) {
    filters.push(gte(agentQueryLogs.createdAt, new Date(Date.now() - input.sinceHours * 60 * 60 * 1000)));
  }

  return db.query.agentQueryLogs.findMany({
    where: filters.length > 0 ? and(...filters) : undefined,
    orderBy: [desc(agentQueryLogs.createdAt)],
    limit: input.limit,
  });
}

export async function summarizeAgentQueryLogs(input: {
  sinceHours: number;
  limit: number;
}) {
  const logs = await listAgentQueryLogs({
    limit: input.limit,
    sinceHours: input.sinceHours,
  });

  const routeCounts = new Map<string, number>();
  const routePerformance = new Map<string, { count: number; totalMs: number; maxMs: number }>();
  const questionCounts = new Map<string, number>();
  let totalFailures = 0;
  let totalDurationMs = 0;
  let durationSamples = 0;

  for (const log of logs) {
    routeCounts.set(log.route, (routeCounts.get(log.route) ?? 0) + 1);
    if (log.status === "failed") {
      totalFailures += 1;
    }

    if (typeof log.durationMs === "number") {
      const current = routePerformance.get(log.route) ?? { count: 0, totalMs: 0, maxMs: 0 };
      current.count += 1;
      current.totalMs += log.durationMs;
      current.maxMs = Math.max(current.maxMs, log.durationMs);
      routePerformance.set(log.route, current);
      totalDurationMs += log.durationMs;
      durationSamples += 1;
    }

    if (log.prompt) {
      const normalized = log.prompt.trim();
      questionCounts.set(normalized, (questionCounts.get(normalized) ?? 0) + 1);
    }
  }

  return {
    sinceHours: input.sinceHours,
    logCount: logs.length,
    failureCount: totalFailures,
    averageDurationMs: durationSamples > 0 ? Math.round(totalDurationMs / durationSamples) : null,
    topRoutes: Array.from(routeCounts.entries())
      .sort((left, right) => right[1] - left[1])
      .slice(0, 12)
      .map(([route, count]) => ({
        route,
        count,
        averageDurationMs: routePerformance.has(route)
          ? Math.round(routePerformance.get(route)!.totalMs / routePerformance.get(route)!.count)
          : null,
        maxDurationMs: routePerformance.get(route)?.maxMs ?? null,
      })),
    topQuestions: Array.from(questionCounts.entries())
      .sort((left, right) => right[1] - left[1])
      .slice(0, 12)
      .map(([prompt, count]) => ({
        prompt,
        count,
      })),
    recentSlowRequests: logs
      .filter((log) => typeof log.durationMs === "number")
      .sort((left, right) => (right.durationMs ?? 0) - (left.durationMs ?? 0))
      .slice(0, 12)
      .map((log) => ({
        route: log.route,
        method: log.method,
        actorEmail: log.actorEmail,
        durationMs: log.durationMs,
        statusCode: log.statusCode,
        createdAt: log.createdAt,
        prompt: log.prompt,
      })),
  };
}
