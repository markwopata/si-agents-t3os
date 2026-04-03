import type { FastifyPluginAsync } from "fastify";

export const rootRoutes: FastifyPluginAsync = async (app) => {
  app.get("/", async () => ({
    service: "si-management-api",
    docs: {
      health: "/health",
      initiatives: "/initiatives",
      executivePortfolioQuery: "/executive/portfolio/query",
      executiveInitiativeContext: "/executive/initiatives/:initiativeId/context",
      executiveInitiativeRawPackage: "/executive/initiatives/:initiativeId/raw-package",
      executiveGlobalKnowledge: "/executive/knowledge/global",
      executiveInitiativeKnowledge: "/executive/initiatives/:initiativeId/knowledge",
      initiativeAgentQuery: "/initiatives/:initiativeId/agent-query",
      initiativeAsk: "/initiatives/:initiativeId/ask",
      initiativeRawEvidence: "/initiatives/:initiativeId/raw-evidence",
      agentSyncAll: "/agent/sync-all",
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
