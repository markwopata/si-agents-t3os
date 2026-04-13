import { desc, eq, sql } from "drizzle-orm";
import { db } from "../db/client.js";
import { env } from "../config/env.js";
import {
  slackInstallations,
  slackWorkspaceChannels,
  slackWorkspaceFileEvents,
  slackWorkspaceMessageEvents,
  slackWorkspaceSyncIssues,
  slackWorkspaceSyncRuns,
} from "../db/schema.js";
import { decryptSecret } from "../lib/crypto.js";
import { createId } from "../lib/id.js";

interface SlackApiResponse {
  ok: boolean;
  error?: string;
  response_metadata?: {
    next_cursor?: string;
  };
}

interface SlackConversationPayload {
  id?: string;
  name?: string;
  user?: string;
  is_archived?: boolean;
  is_private?: boolean;
  is_im?: boolean;
  is_mpim?: boolean;
  is_general?: boolean;
  is_shared?: boolean;
  is_ext_shared?: boolean;
  is_org_shared?: boolean;
  num_members?: number;
  topic?: { value?: string };
  purpose?: { value?: string };
  updated?: number;
}

interface SlackConversationsListPayload extends SlackApiResponse {
  channels?: SlackConversationPayload[];
}

interface SlackHistoryPayload extends SlackApiResponse {
  messages?: Array<{
    type?: string;
    subtype?: string;
    ts: string;
    user?: string;
    text?: string;
    reply_count?: number;
    thread_ts?: string;
    files?: SlackFilePayload[];
  }>;
}

interface SlackRepliesPayload extends SlackApiResponse {
  messages?: Array<{
    ts: string;
    user?: string;
    text?: string;
    subtype?: string;
    thread_ts?: string;
    files?: SlackFilePayload[];
  }>;
}

interface SlackFilePayload {
  id?: string;
  title?: string;
  name?: string;
  mimetype?: string;
  filetype?: string;
  pretty_type?: string;
  size?: number;
  permalink?: string;
  url_private?: string;
  url_private_download?: string;
}

type ConversationType = "public_channel" | "private_channel" | "mpim" | "im";

type WorkspaceConversation = {
  channelId: string;
  name: string | null;
  normalizedName: string | null;
  conversationType: ConversationType;
  title: string | null;
  topic: string | null;
  purpose: string | null;
  userId: string | null;
  memberCount: number | null;
  isArchived: boolean;
  isPrivate: boolean;
  isIm: boolean;
  isMpim: boolean;
  isGeneral: boolean;
  isShared: boolean;
  isExtShared: boolean;
  isOrgShared: boolean;
  lastMessageTs: string | null;
  lastMessageAt: Date | null;
  rawJson: Record<string, unknown>;
};

function isoDateToSlackTs(value: string | null | undefined): string | null {
  if (!value) {
    return null;
  }
  const parsed = Date.parse(value);
  if (!Number.isFinite(parsed)) {
    return null;
  }
  return String(parsed / 1000);
}

type NormalizedSlackAttachment = {
  slackFileId: string;
  title: string | null;
  name: string | null;
  mimeType: string | null;
  fileType: string | null;
  prettyType: string | null;
  sizeBytes: number | null;
  permalink: string | null;
  privateUrl: string | null;
  privateDownloadUrl: string | null;
  textExcerpt: string | null;
  rawJson: Record<string, unknown>;
};

const DEFAULT_CONVERSATION_TYPES: ConversationType[] = [
  "public_channel",
  "private_channel",
  "mpim",
  "im",
];
const SLACK_API_REQUEST_TIMEOUT_MS = 60_000;
const SLACK_METHOD_MIN_INTERVAL_MS: Partial<Record<string, number>> = {
  "conversations.history": 200,
  // Keep a small floor for replies, but rely primarily on Slack's
  // retry-after guidance so large channel backfills can still finish.
  "conversations.replies": 250,
};
const slackMethodChains = new Map<string, Promise<void>>();
const slackMethodCooldownUntil = new Map<string, number>();

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getSlackMethodMinIntervalMs(method: string): number {
  return SLACK_METHOD_MIN_INTERVAL_MS[method] ?? 0;
}

function applySlackMethodCooldown(method: string, delayMs: number): void {
  if (!Number.isFinite(delayMs) || delayMs <= 0) {
    return;
  }
  const nextAllowedAt = Date.now() + delayMs;
  const existing = slackMethodCooldownUntil.get(method) ?? 0;
  if (nextAllowedAt > existing) {
    slackMethodCooldownUntil.set(method, nextAllowedAt);
  }
}

function scheduleSlackMethodCall<T>(method: string, task: () => Promise<T>): Promise<T> {
  const previous = slackMethodChains.get(method) ?? Promise.resolve();
  const scheduled = previous.catch(() => undefined).then(async () => {
    const cooldownUntil = slackMethodCooldownUntil.get(method) ?? 0;
    const waitMs = cooldownUntil - Date.now();
    if (waitMs > 0) {
      await sleep(waitMs);
    }
    try {
      return await task();
    } finally {
      const minIntervalMs = getSlackMethodMinIntervalMs(method);
      if (minIntervalMs > 0) {
        await sleep(minIntervalMs);
      }
    }
  });

  slackMethodChains.set(
    method,
    scheduled.then(
      () => undefined,
      () => undefined,
    ),
  );

  return scheduled;
}

function compactWhitespace(value: string): string {
  return value.replace(/\u0000/g, "").replace(/\s+/g, " ").trim();
}

function sanitizeJsonValue(value: unknown): unknown {
  if (typeof value === "string") {
    return value.replace(/\u0000/g, "");
  }
  if (Array.isArray(value)) {
    return value.map((entry) => sanitizeJsonValue(entry));
  }
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>).map(([key, entry]) => [key, sanitizeJsonValue(entry)]),
    );
  }
  return value;
}

function sanitizeSlackText(text: string | undefined): string {
  return compactWhitespace(text ?? "");
}

export function hasSyncableSlackContent(message: {
  text?: string;
  files?: SlackFilePayload[];
}): boolean {
  return sanitizeSlackText(message.text).length > 0 || normalizeSlackAttachments(message.files).length > 0;
}

function slackTsToDate(ts: string): Date | null {
  const numeric = Number(ts);
  if (!Number.isFinite(numeric)) {
    return null;
  }
  return new Date(numeric * 1000);
}

function subtractSlackTs(ts: string, seconds: number): string {
  const numeric = Number(ts);
  if (!Number.isFinite(numeric)) {
    return ts;
  }
  return String(Math.max(numeric - seconds, 0));
}

function chunk<T>(items: T[], size: number): T[][] {
  const chunks: T[][] = [];
  for (let index = 0; index < items.length; index += size) {
    chunks.push(items.slice(index, index + size));
  }
  return chunks;
}

function classifyIntegrationError(error: unknown): { errorCode: string; message: string } {
  const message = error instanceof Error ? error.message : String(error);
  const normalized = message.toLowerCase();

  if (normalized.includes("rate limit") || normalized.includes("ratelimited")) {
    return { errorCode: "rate_limited", message };
  }
  if (normalized.includes("missing_scope")) {
    return { errorCode: "missing_scope", message };
  }
  if (normalized.includes("not_in_channel")) {
    return { errorCode: "not_in_channel", message };
  }
  if (normalized.includes("invalid_auth") || normalized.includes("not_authed")) {
    return { errorCode: "invalid_auth", message };
  }
  if (normalized.includes("http 403")) {
    return { errorCode: "http_403", message };
  }
  if (normalized.includes("http 404")) {
    return { errorCode: "http_404", message };
  }
  if (normalized.includes("channel_not_found")) {
    return { errorCode: "channel_not_found", message };
  }
  return { errorCode: "sync_error", message };
}

function conversationTypeOf(channel: SlackConversationPayload): ConversationType {
  if (channel.is_im) {
    return "im";
  }
  if (channel.is_mpim) {
    return "mpim";
  }
  if (channel.is_private) {
    return "private_channel";
  }
  return "public_channel";
}

function parseSlackConversationUpdated(updated: number | undefined): {
  ts: string | null;
  date: Date | null;
} {
  if (typeof updated !== "number" || !Number.isFinite(updated)) {
    return { ts: null, date: null };
  }

  const asSeconds = updated > 10_000_000_000 ? updated / 1000 : updated;
  if (asSeconds <= 0 || asSeconds >= 4_102_444_800) {
    return { ts: null, date: null };
  }

  return {
    ts: String(asSeconds),
    date: new Date(asSeconds * 1000),
  };
}

function normalizeConversation(channel: SlackConversationPayload): WorkspaceConversation | null {
  if (!channel.id) {
    return null;
  }

  const conversationType = conversationTypeOf(channel);
  const normalizedName = channel.is_im
    ? channel.user?.toLowerCase() ?? null
    : channel.name?.toLowerCase() ?? null;
  const updated = parseSlackConversationUpdated(channel.updated);

  return {
    channelId: channel.id,
    name: channel.name ?? null,
    normalizedName,
    conversationType,
    title: null,
    topic: compactWhitespace(channel.topic?.value ?? "") || null,
    purpose: compactWhitespace(channel.purpose?.value ?? "") || null,
    userId: channel.user ?? null,
    memberCount: typeof channel.num_members === "number" ? channel.num_members : null,
    isArchived: Boolean(channel.is_archived),
    isPrivate: Boolean(channel.is_private),
    isIm: Boolean(channel.is_im),
    isMpim: Boolean(channel.is_mpim),
    isGeneral: Boolean(channel.is_general),
    isShared: Boolean(channel.is_shared),
    isExtShared: Boolean(channel.is_ext_shared),
    isOrgShared: Boolean(channel.is_org_shared),
    lastMessageTs: updated.ts,
    lastMessageAt: updated.date,
    rawJson: channel as unknown as Record<string, unknown>,
  };
}

function normalizeSlackAttachments(files: SlackFilePayload[] | undefined): NormalizedSlackAttachment[] {
  return (files ?? [])
    .filter((file): file is SlackFilePayload & { id: string } => Boolean(file.id))
    .map((file) => ({
      slackFileId: file.id!,
      title: file.title ?? null,
      name: file.name ?? null,
      mimeType: file.mimetype ?? null,
      fileType: file.filetype ?? null,
      prettyType: file.pretty_type ?? null,
      sizeBytes: typeof file.size === "number" ? file.size : null,
      permalink: file.permalink ?? null,
      privateUrl: file.url_private ?? null,
      privateDownloadUrl: file.url_private_download ?? null,
      textExcerpt: null,
      rawJson: file as unknown as Record<string, unknown>,
    }));
}

async function getSlackUserToken(): Promise<string | null> {
  const installation = await db.query.slackInstallations.findFirst({
    orderBy: [desc(slackInstallations.updatedAt)],
  });
  if (!installation) {
    return null;
  }
  return decryptSecret(installation.accessTokenEncrypted);
}

async function slackApi<T extends SlackApiResponse>(
  token: string,
  method: string,
  params: Record<string, string>,
  options?: {
    maxAttempts?: number;
    retryBufferMs?: number;
    requestTimeoutMs?: number;
  },
): Promise<T> {
  const maxAttempts = options?.maxAttempts ?? (method === "conversations.replies" ? 12 : 6);
  const retryBufferMs = options?.retryBufferMs ?? 0;
  const requestTimeoutMs = options?.requestTimeoutMs ?? SLACK_API_REQUEST_TIMEOUT_MS;

  for (let attempt = 0; attempt < maxAttempts; attempt += 1) {
    const url = new URL(`https://slack.com/api/${method}`);
    for (const [key, value] of Object.entries(params)) {
      url.searchParams.set(key, value);
    }

    const response = await scheduleSlackMethodCall(method, async () => {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), requestTimeoutMs);
      try {
        return await fetch(url, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
          signal: controller.signal,
        });
      } catch (error) {
        if (error instanceof Error && error.name === "AbortError") {
          throw new Error(
            `Slack API ${method} timed out after ${Math.round(requestTimeoutMs / 1000)}s`,
          );
        }
        throw error;
      } finally {
        clearTimeout(timeout);
      }
    });

    if (response.status === 429) {
      const retryAfterSeconds = Number(response.headers.get("retry-after") ?? "5");
      const retryDelayMs = (Number.isFinite(retryAfterSeconds) ? retryAfterSeconds : 5) * 1000 + retryBufferMs;
      applySlackMethodCooldown(method, retryDelayMs);
      await sleep(retryDelayMs);
      continue;
    }

    if (!response.ok) {
      throw new Error(`Slack API ${method} failed with HTTP ${response.status}`);
    }

    const payload = (await response.json()) as T;
    if (!payload.ok) {
      if (payload.error === "ratelimited") {
        const retryDelayMs = 5_000 + retryBufferMs;
        applySlackMethodCooldown(method, retryDelayMs);
        await sleep(retryDelayMs);
        continue;
      }
      throw new Error(payload.error ?? `Slack API ${method} failed`);
    }
    return payload;
  }

  throw new Error(`Slack API ${method} exhausted retry attempts after repeated rate limits`);
}

async function discoverConversationsByType(
  token: string,
  type: ConversationType,
): Promise<WorkspaceConversation[]> {
  const results: WorkspaceConversation[] = [];
  let cursor = "";

  while (true) {
    const payload = await slackApi<SlackConversationsListPayload>(token, "conversations.list", {
      types: type,
      limit: "200",
      exclude_archived: "true",
      ...(cursor ? { cursor } : {}),
    });

    for (const channel of payload.channels ?? []) {
      const normalized = normalizeConversation(channel);
      if (normalized) {
        results.push(normalized);
      }
    }

    cursor = payload.response_metadata?.next_cursor ?? "";
    if (!cursor) {
      break;
    }
  }

  return results;
}

async function fetchFullChannelHistory(
  token: string,
  channelId: string,
  options?: {
    oldestTs?: string | null;
  },
): Promise<SlackHistoryPayload["messages"]> {
  const allMessages: NonNullable<SlackHistoryPayload["messages"]> = [];
  let cursor = "";

  while (true) {
    const payload = await slackApi<SlackHistoryPayload>(token, "conversations.history", {
      channel: channelId,
      limit: "200",
      ...(options?.oldestTs ? { oldest: options.oldestTs } : {}),
      ...(cursor ? { cursor } : {}),
    });

    allMessages.push(...(payload.messages ?? []));
    cursor = payload.response_metadata?.next_cursor ?? "";
    if (!cursor) {
      break;
    }
  }

  return allMessages;
}

async function fetchFullThreadReplies(
  token: string,
  channelId: string,
  threadTs: string,
  options?: {
    oldestTs?: string | null;
  },
): Promise<SlackRepliesPayload["messages"]> {
  const replies: NonNullable<SlackRepliesPayload["messages"]> = [];
  let cursor = "";

  while (true) {
    const payload = await slackApi<SlackRepliesPayload>(token, "conversations.replies", {
      channel: channelId,
      ts: threadTs,
      limit: "200",
      ...(options?.oldestTs ? { oldest: options.oldestTs } : {}),
      ...(cursor ? { cursor } : {}),
    }, {
      maxAttempts: 60,
      retryBufferMs: 250,
    });

    replies.push(...(payload.messages ?? []));
    cursor = payload.response_metadata?.next_cursor ?? "";
    if (!cursor) {
      break;
    }
  }

  return replies;
}

async function recordWorkspaceSyncIssue(input: {
  runId: string;
  channelId?: string | null;
  error: unknown;
  metadata?: Record<string, unknown>;
}): Promise<void> {
  const classified = classifyIntegrationError(input.error);
  await db.insert(slackWorkspaceSyncIssues).values({
    id: createId("slack_workspace_issue"),
    runId: input.runId,
    channelId: input.channelId ?? null,
    errorCode: classified.errorCode,
    message: classified.message,
    metadata: input.metadata ?? {},
  });
}

async function upsertWorkspaceMessages(input: {
  runId: string;
  channelId: string;
  messages: Array<{
    ts: string;
    threadTs: string;
    parentTs: string | null;
    isThreadReply: boolean;
    messageAt: Date | null;
    userId: string | null;
    text: string;
    permalink: string | null;
    replyCount: number;
    rawJson: Record<string, unknown>;
  }>;
}): Promise<void> {
  for (const values of chunk(input.messages, 150)) {
    await db
      .insert(slackWorkspaceMessageEvents)
      .values(
        values.map((message) => ({
          id: createId("slack_workspace_msg"),
          syncRunId: input.runId,
          channelId: input.channelId,
          ts: message.ts,
          threadTs: message.threadTs,
          parentTs: message.parentTs,
          isThreadReply: message.isThreadReply,
          messageAt: message.messageAt,
          userId: message.userId,
          text: message.text,
          permalink: message.permalink,
          replyCount: message.replyCount,
          rawJson: sanitizeJsonValue(message.rawJson) as Record<string, unknown>,
        })),
      )
      .onConflictDoUpdate({
        target: [slackWorkspaceMessageEvents.channelId, slackWorkspaceMessageEvents.ts],
        set: {
          syncRunId: input.runId,
          threadTs: sql`excluded.thread_ts`,
          parentTs: sql`excluded.parent_ts`,
          isThreadReply: sql`excluded.is_thread_reply`,
          messageAt: sql`excluded.message_at`,
          userId: sql`excluded.user_id`,
          text: sql`excluded.text`,
          permalink: sql`excluded.permalink`,
          replyCount: sql`excluded.reply_count`,
          rawJson: sql`excluded.raw_json`,
        },
      });
  }
}

async function upsertWorkspaceFiles(input: {
  runId: string;
  channelId: string;
  files: Array<{
    messageTs: string;
    parentTs: string | null;
    slackFileId: string;
    title: string | null;
    name: string | null;
    mimeType: string | null;
    fileType: string | null;
    prettyType: string | null;
    sizeBytes: number | null;
    permalink: string | null;
    privateUrl: string | null;
    privateDownloadUrl: string | null;
    textExcerpt: string | null;
    rawJson: Record<string, unknown>;
  }>;
}): Promise<void> {
  for (const values of chunk(input.files, 150)) {
    await db
      .insert(slackWorkspaceFileEvents)
      .values(
        values.map((attachment) => ({
          id: createId("slack_workspace_file"),
          syncRunId: input.runId,
          channelId: input.channelId,
          messageTs: attachment.messageTs,
          parentTs: attachment.parentTs,
          slackFileId: attachment.slackFileId,
          title: attachment.title,
          name: attachment.name,
          mimeType: attachment.mimeType,
          fileType: attachment.fileType,
          prettyType: attachment.prettyType,
          sizeBytes: attachment.sizeBytes,
          permalink: attachment.permalink,
          privateUrl: attachment.privateUrl,
          privateDownloadUrl: attachment.privateDownloadUrl,
          textExcerpt: attachment.textExcerpt,
          rawJson: sanitizeJsonValue(attachment.rawJson) as Record<string, unknown>,
        })),
      )
      .onConflictDoUpdate({
        target: [
          slackWorkspaceFileEvents.channelId,
          slackWorkspaceFileEvents.messageTs,
          slackWorkspaceFileEvents.slackFileId,
        ],
        set: {
          syncRunId: input.runId,
          parentTs: sql`excluded.parent_ts`,
          title: sql`excluded.title`,
          name: sql`excluded.name`,
          mimeType: sql`excluded.mime_type`,
          fileType: sql`excluded.file_type`,
          prettyType: sql`excluded.pretty_type`,
          sizeBytes: sql`excluded.size_bytes`,
          permalink: sql`excluded.permalink`,
          privateUrl: sql`excluded.private_url`,
          privateDownloadUrl: sql`excluded.private_download_url`,
          textExcerpt: sql`excluded.text_excerpt`,
          rawJson: sql`excluded.raw_json`,
        },
      });
  }
}

export async function getSlackWorkspaceCorpusStatus(): Promise<Record<string, unknown>> {
  const [latestRun, channelCountResult, messageCountResult, fileCountResult] = await Promise.all([
    db.query.slackWorkspaceSyncRuns.findFirst({
      orderBy: [desc(slackWorkspaceSyncRuns.createdAt)],
    }),
    db.select({ value: sql<number>`count(*)` }).from(slackWorkspaceChannels),
    db.select({ value: sql<number>`count(*)` }).from(slackWorkspaceMessageEvents),
    db.select({ value: sql<number>`count(*)` }).from(slackWorkspaceFileEvents),
  ]);

  return {
    connected: Boolean(await getSlackUserToken()),
    latestRun: latestRun
      ? {
          id: latestRun.id,
          status: latestRun.status,
          syncMode: latestRun.syncMode,
          conversationTypes: latestRun.conversationTypes,
          summary: latestRun.summary,
          createdAt: latestRun.createdAt.toISOString(),
          finishedAt: latestRun.finishedAt?.toISOString() ?? null,
        }
      : null,
    counts: {
      channels: Number(channelCountResult[0]?.value ?? 0),
      messages: Number(messageCountResult[0]?.value ?? 0),
      files: Number(fileCountResult[0]?.value ?? 0),
    },
  };
}

export async function syncSlackWorkspaceCorpus(input?: {
  force?: boolean;
  conversationTypes?: ConversationType[];
  channelLimit?: number | null;
  channelNamePrefixes?: string[];
  channelIds?: string[];
  oldestDate?: string | null;
  includeArchived?: boolean;
}): Promise<Record<string, unknown>> {
  const token = await getSlackUserToken();
  if (!token) {
    throw new Error("Slack is not connected.");
  }

  const conversationTypes =
    input?.conversationTypes && input.conversationTypes.length > 0
      ? Array.from(new Set(input.conversationTypes))
      : DEFAULT_CONVERSATION_TYPES;
  const channelNamePrefixes = (input?.channelNamePrefixes ?? [])
    .map((value) => value.trim().toLowerCase())
    .filter(Boolean);
  const orderedChannelIds = Array.from(
    new Set((input?.channelIds ?? []).map((value) => value.trim()).filter(Boolean)),
  );
  const channelIds = new Set(orderedChannelIds);
  const channelIdOrder = new Map(orderedChannelIds.map((channelId, index) => [channelId, index]));
  const oldestTsFloor = isoDateToSlackTs(input?.oldestDate ?? null);

  await db
    .update(slackWorkspaceSyncRuns)
    .set({
      status: "failed",
      summary: {
        errorCode: "superseded_rerun",
        message: "Marked failed because a newer workspace sync superseded this in-flight run.",
      },
      finishedAt: new Date(),
    })
    .where(eq(slackWorkspaceSyncRuns.status, "running"));

  const runId = createId("slack_workspace_sync");
  await db.insert(slackWorkspaceSyncRuns).values({
    id: runId,
    status: "running",
    syncMode: input?.force ? "full_backfill" : "incremental",
    conversationTypes,
    summary: {},
  });

  try {
    const discovered: WorkspaceConversation[] = [];
    const discoveryFailures: Array<{ type: ConversationType; errorCode: string; message: string }> = [];
    for (const type of conversationTypes) {
      try {
        const rows = await discoverConversationsByType(token, type);
        discovered.push(...rows);
      } catch (error) {
        const classified = classifyIntegrationError(error);
        discoveryFailures.push({
          type,
          errorCode: classified.errorCode,
          message: classified.message,
        });
        await recordWorkspaceSyncIssue({
          runId,
          error,
          metadata: {
            stage: "discover_conversations",
            conversationType: type,
          },
        });
      }
    }

    const dedupedConversations = Array.from(
      new Map(discovered.map((conversation) => [conversation.channelId, conversation])).values(),
    )
      .filter((conversation) => (input?.includeArchived ? true : !conversation.isArchived))
      .filter((conversation) => (channelIds.size === 0 ? true : channelIds.has(conversation.channelId)))
      .filter((conversation) =>
        channelNamePrefixes.length === 0
          ? true
          : Boolean(
              conversation.name &&
                channelNamePrefixes.some((prefix) => conversation.name!.toLowerCase().startsWith(prefix)),
            ),
      )
      .sort((left, right) => {
        const leftExplicitOrder = channelIdOrder.get(left.channelId);
        const rightExplicitOrder = channelIdOrder.get(right.channelId);
        if (leftExplicitOrder !== undefined || rightExplicitOrder !== undefined) {
          if (leftExplicitOrder === undefined) {
            return 1;
          }
          if (rightExplicitOrder === undefined) {
            return -1;
          }
          if (leftExplicitOrder !== rightExplicitOrder) {
            return leftExplicitOrder - rightExplicitOrder;
          }
        }
        const leftScore = left.lastMessageAt?.getTime() ?? 0;
        const rightScore = right.lastMessageAt?.getTime() ?? 0;
        return rightScore - leftScore;
      });

    const selectedConversations =
      typeof input?.channelLimit === "number" && input.channelLimit > 0
        ? dedupedConversations.slice(0, input.channelLimit)
        : dedupedConversations;

    for (const values of chunk(selectedConversations, 150)) {
      await db
        .insert(slackWorkspaceChannels)
        .values(
          values.map((channel) => ({
            channelId: channel.channelId,
            discoveryRunId: runId,
            name: channel.name,
            normalizedName: channel.normalizedName,
            conversationType: channel.conversationType,
            title: channel.title,
            topic: channel.topic,
            purpose: channel.purpose,
            userId: channel.userId,
            memberCount: channel.memberCount,
            isArchived: channel.isArchived,
            isPrivate: channel.isPrivate,
            isIm: channel.isIm,
            isMpim: channel.isMpim,
            isGeneral: channel.isGeneral,
            isShared: channel.isShared,
            isExtShared: channel.isExtShared,
            isOrgShared: channel.isOrgShared,
            lastMessageTs: channel.lastMessageTs,
            lastMessageAt: channel.lastMessageAt,
            lastDiscoveredAt: new Date(),
            rawJson: sanitizeJsonValue(channel.rawJson) as Record<string, unknown>,
            updatedAt: new Date(),
          })),
        )
        .onConflictDoUpdate({
          target: [slackWorkspaceChannels.channelId],
          set: {
            discoveryRunId: runId,
            name: sql`excluded.name`,
            normalizedName: sql`excluded.normalized_name`,
            conversationType: sql`excluded.conversation_type`,
            title: sql`excluded.title`,
            topic: sql`excluded.topic`,
            purpose: sql`excluded.purpose`,
            userId: sql`excluded.user_id`,
            memberCount: sql`excluded.member_count`,
            isArchived: sql`excluded.is_archived`,
            isPrivate: sql`excluded.is_private`,
            isIm: sql`excluded.is_im`,
            isMpim: sql`excluded.is_mpim`,
            isGeneral: sql`excluded.is_general`,
            isShared: sql`excluded.is_shared`,
            isExtShared: sql`excluded.is_ext_shared`,
            isOrgShared: sql`excluded.is_org_shared`,
            lastMessageTs: sql`excluded.last_message_ts`,
            lastMessageAt: sql`excluded.last_message_at`,
            lastDiscoveredAt: sql`excluded.last_discovered_at`,
            rawJson: sql`excluded.raw_json`,
            updatedAt: sql`excluded.updated_at`,
          },
        });
    }

    const processChannel = async (
      channel: WorkspaceConversation,
    ): Promise<{
      messagesSynced: number;
      repliesSynced: number;
      filesSynced: number;
      channelsSynced: number;
      failure: { channelId: string; errorCode: string; message: string } | null;
    }> => {
      try {
      const latestKnownMessage = await db.query.slackWorkspaceMessageEvents.findFirst({
        where: eq(slackWorkspaceMessageEvents.channelId, channel.channelId),
        orderBy: [desc(slackWorkspaceMessageEvents.messageAt), desc(slackWorkspaceMessageEvents.createdAt)],
      });
      const historyOldestTs =
        !input?.force && latestKnownMessage?.ts
          ? subtractSlackTs(latestKnownMessage.ts, 1)
          : oldestTsFloor;

      const history = (
        (await fetchFullChannelHistory(token, channel.channelId, {
          oldestTs: historyOldestTs,
        })) ?? []
      ).filter((message) => !message.subtype && hasSyncableSlackContent(message));

      const messageRows = history.map((message) => ({
        ts: message.ts,
        threadTs: message.thread_ts ?? message.ts,
        parentTs: null as string | null,
        isThreadReply: false,
        messageAt: slackTsToDate(message.ts),
        userId: message.user ?? null,
        text: sanitizeSlackText(message.text),
        permalink: null as string | null,
        replyCount: message.reply_count ?? 0,
        attachments: normalizeSlackAttachments(message.files),
        rawJson: message as Record<string, unknown>,
      }));

      const messageAttachmentRows = messageRows.flatMap((message) =>
        message.attachments.map((attachment) => ({
          messageTs: message.ts,
          parentTs: null as string | null,
          ...attachment,
        })),
      );

      await upsertWorkspaceMessages({
        runId,
        channelId: channel.channelId,
        messages: messageRows,
      });
      await upsertWorkspaceFiles({
        runId,
        channelId: channel.channelId,
        files: messageAttachmentRows,
      });

      const existingRepliesByParent = new Map<string, { count: number; latestTs: string | null }>();
      const replyParents = Array.from(
        new Set(messageRows.filter((message) => message.replyCount > 0).map((message) => message.threadTs)),
      );
      if (replyParents.length > 0) {
        const existingRows = await db.query.slackWorkspaceMessageEvents.findMany({
          where: eq(slackWorkspaceMessageEvents.channelId, channel.channelId),
        });
        for (const row of existingRows) {
          if (!row.parentTs) {
            continue;
          }
          const current = existingRepliesByParent.get(row.parentTs) ?? { count: 0, latestTs: null };
          current.count += 1;
          if (!current.latestTs || Number(row.ts) > Number(current.latestTs)) {
            current.latestTs = row.ts;
          }
          existingRepliesByParent.set(row.parentTs, current);
        }
      }

      const replyRows: Array<{
        ts: string;
        threadTs: string;
        parentTs: string;
        isThreadReply: true;
        messageAt: Date | null;
        userId: string | null;
        text: string;
        permalink: null;
        replyCount: 0;
        attachments: NormalizedSlackAttachment[];
        rawJson: Record<string, unknown>;
      }> = [];

      for (const message of messageRows) {
        if (message.replyCount <= 0) {
          continue;
        }

        const existing = existingRepliesByParent.get(message.threadTs);
        if (!input?.force && existing && existing.count >= message.replyCount) {
          continue;
        }

        let replies: SlackRepliesPayload["messages"] = [];
        try {
          replies =
            (await fetchFullThreadReplies(token, channel.channelId, message.threadTs, {
              oldestTs:
                !input?.force && existing?.latestTs
                  ? subtractSlackTs(existing.latestTs, 1)
                  : oldestTsFloor,
            })) ?? [];
        } catch (error) {
          await recordWorkspaceSyncIssue({
            runId,
            channelId: channel.channelId,
            error,
            metadata: {
              stage: "sync_thread_replies",
              conversationType: channel.conversationType,
              channelName: channel.name,
              threadTs: message.threadTs,
            },
          });
          continue;
        }
        for (const reply of replies.slice(1)) {
          if (reply.subtype || !hasSyncableSlackContent(reply)) {
            continue;
          }
          replyRows.push({
            ts: reply.ts,
            threadTs: reply.thread_ts ?? message.threadTs,
            parentTs: message.threadTs,
            isThreadReply: true,
            messageAt: slackTsToDate(reply.ts),
            userId: reply.user ?? null,
            text: sanitizeSlackText(reply.text),
            permalink: null,
            replyCount: 0,
            attachments: normalizeSlackAttachments(reply.files),
            rawJson: reply as Record<string, unknown>,
          });
        }
      }

      const replyAttachmentRows = replyRows.flatMap((reply) =>
          reply.attachments.map((attachment) => ({
            messageTs: reply.ts,
            parentTs: reply.parentTs,
            ...attachment,
          })),
      );

      await upsertWorkspaceMessages({
        runId,
        channelId: channel.channelId,
        messages: replyRows,
      });
      await upsertWorkspaceFiles({
        runId,
        channelId: channel.channelId,
        files: replyAttachmentRows,
      });

      await db
        .update(slackWorkspaceChannels)
        .set({
          lastSyncedAt: new Date(),
          updatedAt: new Date(),
        })
        .where(eq(slackWorkspaceChannels.channelId, channel.channelId));
      return {
        messagesSynced: messageRows.length,
        repliesSynced: replyRows.length,
        filesSynced: messageAttachmentRows.length + replyAttachmentRows.length,
        channelsSynced: 1,
        failure: null,
      };
      } catch (error) {
        const classified = classifyIntegrationError(error);
        await recordWorkspaceSyncIssue({
          runId,
          channelId: channel.channelId,
          error,
          metadata: {
            stage: "sync_channel_history",
            conversationType: channel.conversationType,
            channelName: channel.name,
          },
        });
        return {
          messagesSynced: 0,
          repliesSynced: 0,
          filesSynced: 0,
          channelsSynced: 0,
          failure: {
            channelId: channel.channelId,
            errorCode: classified.errorCode,
            message: classified.message,
          },
        };
      }
    };

    let nextIndex = 0;
    const workerCount = Math.min(env.SLACK_WORKSPACE_SYNC_CONCURRENCY, Math.max(selectedConversations.length, 1));
    const workerResults = await Promise.all(
      Array.from({ length: workerCount }, async () => {
        const results: Array<Awaited<ReturnType<typeof processChannel>>> = [];
        for (;;) {
          const channel = selectedConversations[nextIndex];
          nextIndex += 1;
          if (!channel) {
            break;
          }
          results.push(await processChannel(channel));
        }
        return results;
      }),
    );

    const flattenedResults = workerResults.flat();
    const messagesSynced = flattenedResults.reduce((sum, result) => sum + result.messagesSynced, 0);
    const repliesSynced = flattenedResults.reduce((sum, result) => sum + result.repliesSynced, 0);
    const filesSynced = flattenedResults.reduce((sum, result) => sum + result.filesSynced, 0);
    const channelsSynced = flattenedResults.reduce((sum, result) => sum + result.channelsSynced, 0);
    const channelFailures = flattenedResults
      .map((result) => result.failure)
      .filter((value): value is { channelId: string; errorCode: string; message: string } => Boolean(value));

    const summary = {
      discoveredConversationCount: dedupedConversations.length,
      selectedConversationCount: selectedConversations.length,
      channelsSynced,
      messagesSynced,
      repliesSynced,
      filesSynced,
      channelNamePrefixes,
      channelIds: Array.from(channelIds),
      oldestDate: input?.oldestDate ?? null,
      discoveryFailures,
      channelFailureCount: channelFailures.length,
      channelFailures: channelFailures.slice(0, 50),
    };

    await db
      .update(slackWorkspaceSyncRuns)
      .set({
        status: "completed",
        summary,
        finishedAt: new Date(),
      })
      .where(eq(slackWorkspaceSyncRuns.id, runId));

    return {
      runId,
      status: "completed",
      ...summary,
    };
  } catch (error) {
    const classified = classifyIntegrationError(error);
    await db
      .update(slackWorkspaceSyncRuns)
      .set({
        status: "failed",
        summary: classified,
        finishedAt: new Date(),
      })
      .where(eq(slackWorkspaceSyncRuns.id, runId));
    throw error;
  }
}
