import { env } from "../config/env.js";
import { closePool, runMigrations } from "../db/migrate.js";
import { syncSlackWorkspaceCorpus } from "../services/slack-workspace-corpus-service.js";

const conversationTypes = env.SLACK_WORKSPACE_CONVERSATION_TYPES.split(",")
  .map((value) => value.trim())
  .filter(Boolean) as Array<"public_channel" | "private_channel" | "mpim" | "im">;
const channelNamePrefixes = env.SLACK_WORKSPACE_CHANNEL_PREFIXES.split(",")
  .map((value) => value.trim())
  .filter(Boolean);
const channelIds = env.SLACK_WORKSPACE_CHANNEL_IDS.split(",")
  .map((value) => value.trim())
  .filter(Boolean);

try {
  await runMigrations();
  const result = await syncSlackWorkspaceCorpus({
    force: process.argv.includes("--force"),
    conversationTypes,
    channelLimit: env.SLACK_WORKSPACE_CHANNEL_LIMIT > 0 ? env.SLACK_WORKSPACE_CHANNEL_LIMIT : null,
    channelNamePrefixes,
    channelIds,
    oldestDate: env.SLACK_WORKSPACE_OLDEST_DATE || null,
    includeArchived: env.SLACK_WORKSPACE_INCLUDE_ARCHIVED,
  });
  console.log(JSON.stringify(result, null, 2));
} finally {
  await closePool();
}
