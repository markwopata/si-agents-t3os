import type { FastifyPluginAsync } from "fastify";
import { env } from "../config/env.js";
import { requireScope } from "../plugins/auth.js";
import { requireAdmin } from "../services/authorization-service.js";
import {
  createSlackInstallUrl,
  exchangeSlackCode,
  getSlackInstallStatus,
  verifySlackState,
} from "../integrations/slack/service.js";
import {
  getSlackWorkspaceCorpusStatus,
  syncSlackWorkspaceCorpus,
} from "../services/slack-workspace-corpus-service.js";

export const slackRoutes: FastifyPluginAsync = async (app) => {
  app.get("/integrations/slack/status", async () => getSlackInstallStatus());

  app.get("/integrations/slack/workspace-sync/status", async (request) => {
    requireScope(request, "read:knowledge");
    return getSlackWorkspaceCorpusStatus();
  });

  app.post("/integrations/slack/workspace-sync", async (request) => {
    requireScope(request, "run:agents");
    requireAdmin(request);
    const body = (request.body ?? {}) as {
      force?: boolean;
      conversationTypes?: Array<"public_channel" | "private_channel" | "mpim" | "im">;
      channelLimit?: number | null;
      channelNamePrefixes?: string[];
      channelIds?: string[];
      oldestDate?: string | null;
      includeArchived?: boolean;
    };
    return syncSlackWorkspaceCorpus({
      force: body.force ?? false,
      conversationTypes: body.conversationTypes,
      channelLimit: typeof body.channelLimit === "number" ? body.channelLimit : null,
      channelNamePrefixes: body.channelNamePrefixes,
      channelIds: body.channelIds,
      oldestDate: body.oldestDate ?? null,
      includeArchived: body.includeArchived ?? false,
    });
  });

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
