import cors from "@fastify/cors";
import multipart from "@fastify/multipart";
import sensible from "@fastify/sensible";
import Fastify from "fastify";
import { env } from "./config/env.js";
import { authPlugin } from "./plugins/auth.js";
import { agentRoutes } from "./routes/agent.js";
import { healthRoutes } from "./routes/health.js";
import { googleRoutes } from "./routes/google.js";
import { importRoutes } from "./routes/imports.js";
import { initiativeRoutes } from "./routes/initiatives.js";
import { knowledgeRoutes } from "./routes/knowledge.js";
import { pilotRoutes } from "./routes/pilot.js";
import { platformRoutes } from "./routes/platform.js";
import { portfolioRoutes } from "./routes/portfolio.js";
import { rootRoutes } from "./routes/root.js";
import { sessionRoutes } from "./routes/session.js";
import { serviceTokenRoutes } from "./routes/service-tokens.js";
import { slackRoutes } from "./routes/slack.js";

export async function buildApp() {
  const app = Fastify({ logger: true });
  await app.register(sensible);
  const allowedOrigins = env.CORS_ALLOWED_ORIGINS.split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);
  await app.register(cors, {
    origin: (origin: string | undefined, callback) => {
      if (!origin) {
        callback(null, true);
        return;
      }

      if (allowedOrigins.includes(origin)) {
        callback(null, true);
        return;
      }

      callback(new Error(`Origin ${origin} is not allowed by CORS`), false);
    },
  });
  await app.register(multipart);
  await app.register(authPlugin);

  await app.register(rootRoutes);
  await app.register(sessionRoutes);
  await app.register(healthRoutes);
  await app.register(initiativeRoutes);
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
