import type { FastifyPluginAsync } from "fastify";
import { env } from "../config/env.js";
import {
  createSlackInstallUrl,
  exchangeSlackCode,
  getSlackInstallStatus,
  verifySlackState,
} from "../integrations/slack/service.js";

export const slackRoutes: FastifyPluginAsync = async (app) => {
  app.get("/integrations/slack/status", async () => getSlackInstallStatus());

  app.get("/integrations/slack/install", async (_request, reply) => {
    const installUrl = createSlackInstallUrl();
    return reply.redirect(installUrl);
  });

  app.get("/integrations/slack/callback", async (request, reply) => {
    const { code, state } = request.query as { code?: string; state?: string };
    if (!code || !state || !verifySlackState(state)) {
      return reply.code(400).send("Invalid Slack callback state");
    }

    const install = await exchangeSlackCode(code);
    return reply.type("text/html").send(`
      <html>
        <body style="font-family: sans-serif; padding: 24px;">
          <h1>Slack connected</h1>
          <p>Workspace: ${install.teamName}</p>
          <p>User: ${install.slackUserId}</p>
          <p><a href="${env.WEB_APP_URL}">Return to the SI app</a></p>
        </body>
      </html>
    `);
  });
};

