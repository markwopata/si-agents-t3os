import type { FastifyPluginAsync } from "fastify";
import { env } from "../config/env.js";
import {
  createGoogleInstallUrl,
  getGoogleInstallStatus,
  upsertGoogleInstallationFromCode,
  verifyGoogleState,
} from "../integrations/google/service.js";

export const googleRoutes: FastifyPluginAsync = async (app) => {
  app.get("/integrations/google/status", async () => getGoogleInstallStatus());

  app.get("/integrations/google/install", async (_request, reply) => {
    const installUrl = createGoogleInstallUrl();
    return reply.redirect(installUrl);
  });

  app.get("/integrations/google/callback", async (request, reply) => {
    const { code, state } = request.query as { code?: string; state?: string };
    if (!code || !state || !verifyGoogleState(state)) {
      return reply.code(400).send("Invalid Google callback state");
    }

    const installation = await upsertGoogleInstallationFromCode(code);
    return reply.type("text/html").send(`
      <html>
        <body style="font-family: sans-serif; padding: 24px;">
          <h1>Google connected</h1>
          <p>Email: ${installation.email}</p>
          <p>User ID: ${installation.googleUserId ?? "Unavailable"}</p>
          <p><a href="${env.WEB_APP_URL}">Return to the SI app</a></p>
        </body>
      </html>
    `);
  });
};
