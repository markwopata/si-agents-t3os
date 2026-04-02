import type { FastifyPluginAsync } from "fastify";

export const rootRoutes: FastifyPluginAsync = async (app) => {
  app.get("/", async () => ({
    service: "si-management-api",
    docs: {
      health: "/health",
      initiatives: "/initiatives",
      initiativeAsk: "/initiatives/:initiativeId/ask",
      initiativeRawEvidence: "/initiatives/:initiativeId/raw-evidence",
      initiativeAnnotations: "/initiatives/:initiativeId/annotations",
      platformContacts: "/platform/contacts",
      platformWorkspaceMembers: "/platform/workspace-members",
      importWorkbook: "/imports/si-workbook",
      portfolioRefresh: "/portfolio/refresh",
      slackInstall: "/integrations/slack/install",
      googleInstall: "/integrations/google/install",
    },
  }));
};
