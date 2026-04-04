import cors from "@fastify/cors";
import multipart from "@fastify/multipart";
import sensible from "@fastify/sensible";
import Fastify from "fastify";
import { env } from "./config/env.js";
import {
  extractPromptFromPayload,
  recordAgentQueryLog,
  summarizeRequestForLog,
} from "./lib/query-log.js";
import { authPlugin } from "./plugins/auth.js";
import { apiTokenRoutes } from "./routes/api-tokens.js";
import { agentRoutes } from "./routes/agent.js";
import { healthRoutes } from "./routes/health.js";
import { googleRoutes } from "./routes/google.js";
import { importRoutes } from "./routes/imports.js";
import { initiativeRoutes } from "./routes/initiatives.js";
import { knowledgeRoutes } from "./routes/knowledge.js";
import { pilotRoutes } from "./routes/pilot.js";
import { platformRoutes } from "./routes/platform.js";
import { portfolioRoutes } from "./routes/portfolio.js";
import { executiveRoutes } from "./routes/executive.js";
import { rootRoutes } from "./routes/root.js";
import { sessionRoutes } from "./routes/session.js";
import { serviceTokenRoutes } from "./routes/service-tokens.js";
import { slackRoutes } from "./routes/slack.js";

export async function buildApp() {
  const app = Fastify({ logger: true });
  await app.register(sensible);
  const defaultAllowedOrigins = new Set<string>([
    "http://localhost:3000",
    "https://si-agents-api.onrender.com",
    "https://staging-erp.estrack.com",
  ]);

  try {
    defaultAllowedOrigins.add(new URL(env.WEB_APP_URL).origin);
  } catch {
    // Ignore invalid WEB_APP_URL values and rely on explicit defaults.
  }

  const allowedOrigins = new Set(
    env.CORS_ALLOWED_ORIGINS.split(",")
    .map((origin) => origin.trim())
    .filter(Boolean),
  );

  defaultAllowedOrigins.forEach((origin) => allowedOrigins.add(origin));

  const defaultAllowedOriginPatterns = [
    "https://*.t3os.ai",
    "https://*.estrack.com",
    "https://*.equipmentshare.com",
  ];

  const allowedOriginPatterns = [...defaultAllowedOriginPatterns, ...env.CORS_ALLOWED_ORIGIN_PATTERNS.split(",")]
    .map((pattern) => pattern.trim())
    .filter(Boolean)
    .map((pattern) =>
      new RegExp(
        `^${pattern
          .replace(/[|\\{}()[\]^$+?.]/g, "\\$&")
          .replace(/\*/g, ".*")}$`,
        "i",
      ),
    );
  await app.register(cors, {
    origin: (origin: string | undefined, callback) => {
      if (!origin) {
        callback(null, true);
        return;
      }

      if (allowedOrigins.has(origin)) {
        callback(null, true);
        return;
      }

       if (allowedOriginPatterns.some((pattern) => pattern.test(origin))) {
        callback(null, true);
        return;
      }

      callback(new Error(`Origin ${origin} is not allowed by CORS`), false);
    },
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  });
  await app.register(multipart);
  await app.register(authPlugin);

  app.addHook("onRequest", async (request) => {
    (request as typeof request & { requestStartedAtMs?: number }).requestStartedAtMs = Date.now();
  });

  app.addHook("onResponse", async (request, reply) => {
    try {
      if (request.method === "OPTIONS") {
        return;
      }

      const route = request.routeOptions?.url ?? request.raw.url?.split("?")[0] ?? request.url;
      if (route === "/" || route === "/health") {
        return;
      }

      const startedAt =
        (request as typeof request & { requestStartedAtMs?: number }).requestStartedAtMs ?? Date.now();
      const durationMs = Math.max(Date.now() - startedAt, 0);
      const prompt = extractPromptFromPayload(request.body) ?? extractPromptFromPayload(request.query);
      const responseSummary: Record<string, unknown> = {
        route: request.routeOptions?.url ?? null,
        statusCode: reply.statusCode,
        durationMs,
      };

      await recordAgentQueryLog({
        actor: request.actor,
        logType: "request",
        route,
        requestPath: request.raw.url?.split("?")[0] ?? request.url,
        method: request.method,
        entityType:
          typeof (request.params as Record<string, unknown> | undefined)?.initiativeId === "string"
            ? "initiative"
            : undefined,
        entityId:
          typeof (request.params as Record<string, unknown> | undefined)?.initiativeId === "string"
            ? String((request.params as Record<string, unknown>).initiativeId)
            : undefined,
        prompt,
        requestPayload: summarizeRequestForLog({
          params: request.params,
          query: request.query,
          body: request.body,
        }),
        responseSummary,
        status: reply.statusCode >= 400 ? "failed" : "succeeded",
        statusCode: reply.statusCode,
        durationMs,
        userAgent: request.headers["user-agent"] ?? null,
        errorText: reply.statusCode >= 500 ? reply.raw.statusMessage ?? null : null,
      });
    } catch (error) {
      request.log.warn({ error }, "Unable to record API request telemetry");
    }
  });

  await app.register(rootRoutes);
  await app.register(sessionRoutes);
  await app.register(healthRoutes);
  await app.register(apiTokenRoutes);
  await app.register(initiativeRoutes);
  await app.register(executiveRoutes);
  await app.register(knowledgeRoutes);
  await app.register(importRoutes);
  await app.register(serviceTokenRoutes);
  await app.register(agentRoutes);
  await app.register(pilotRoutes);
  await app.register(platformRoutes);
  await app.register(portfolioRoutes);
  await app.register(slackRoutes);
  await app.register(googleRoutes);

  return app;
}
