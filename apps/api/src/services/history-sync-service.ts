import type { InitiativeDetail } from "@si/domain";
import { and, desc, eq, inArray, sql } from "drizzle-orm";
import { env } from "../config/env.js";
import { db } from "../db/client.js";
import {
  googleFileSnapshots,
  googleInstallations,
  googleRevisionEvents,
  googleSyncRuns,
  integrationSyncIssues,
  initiativeLinks,
  initiatives,
  slackFileEvents,
  slackInstallations,
  slackMessageEvents,
  slackReplyEvents,
  slackSyncRuns,
} from "../db/schema.js";
import { decryptSecret } from "../lib/crypto.js";
import { createId } from "../lib/id.js";
import { getGoogleAccessToken } from "../integrations/google/service.js";
import { parseGoogleFileLink } from "../integrations/google/reader.js";
import { parseSlackChannelLink } from "../integrations/slack/reader.js";
import { getInitiativeById } from "./initiative-service.js";

interface SlackApiResponse {
  ok: boolean;
  error?: string;
  response_metadata?: {
    next_cursor?: string;
  };
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
    files?: SlackFilePayload[];
  }>;
}

interface SlackConversationInfoPayload extends SlackApiResponse {
  channel?: {
    id: string;
    name?: string;
  };
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

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
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

interface GoogleDriveFile {
  id?: string;
  name?: string;
  mimeType?: string;
  modifiedTime?: string;
  webViewLink?: string;
  lastModifyingUser?: {
    displayName?: string;
    emailAddress?: string;
  };
}

interface GoogleDriveRevision {
  id?: string;
  modifiedTime?: string;
  lastModifyingUser?: {
    displayName?: string;
    emailAddress?: string;
  };
}

interface GoogleFileTarget {
  fileId: string;
  kind: "folder" | "file";
  url: string;
  label: string;
}

interface TrackerCandidate {
  trackerFileId: string;
  trackerName: string;
  webViewLink: string | null;
}

function sanitizeSlackText(text: string | undefined): string {
  return (text ?? "").replace(/\u0000/g, "").replace(/\s+/g, " ").trim();
}

function slackTsToDate(ts: string): Date | null {
  const numeric = Number(ts);
  if (!Number.isFinite(numeric)) {
    return null;
  }
  return new Date(numeric * 1000);
}

function buildSlackPermalink(channelUrl: string, channelId: string, ts: string): string {
  const normalizedTs = ts.replace(".", "");
  const base = channelUrl.split("/archives/")[0];
  return `${base}/archives/${channelId}/p${normalizedTs}`;
}

function formatGoogleUser(
  user: { displayName?: string; emailAddress?: string } | undefined,
): string | null {
  if (!user) {
    return null;
  }
  return (user.displayName ?? user.emailAddress ?? null)?.replace(/\u0000/g, "") ?? null;
}

function isTrackerName(name: string | undefined): boolean {
  const value = (name ?? "").toLowerCase();
  return value.includes("initiative approach tracker") || value.includes("approach tracker");
}

function scoreTrackerCandidate(file: {
  name?: string;
  webViewLink?: string | null;
}): number {
  const name = (file.name ?? "").toLowerCase();
  let score = 0;

  if (name.includes("initiative approach tracker")) {
    score += 100;
  } else if (name.includes("approach tracker")) {
    score += 85;
  } else if (name.includes("tracker")) {
    score += 50;
  }

  if (/^\d+\s+initiative approach tracker/i.test(file.name ?? "")) {
    score += 20;
  }

  if (name.includes("deal tracker")) {
    score -= 40;
  }
  if (name.includes("swot")) {
    score -= 25;
  }

  return score;
}

function chooseTrackerCandidate(
  files: Array<{ id?: string; name?: string; mimeType?: string; webViewLink?: string | null }>,
): TrackerCandidate | null {
  const spreadsheets = files
    .filter((file) => file.id && file.mimeType === "application/vnd.google-apps.spreadsheet")
    .sort((left, right) => scoreTrackerCandidate(right) - scoreTrackerCandidate(left));
  const exact = spreadsheets.find((file) => isTrackerName(file.name));
  const fallback = exact ?? spreadsheets.find((file) => (file.name ?? "").toLowerCase().includes("tracker"));
  if (!fallback?.id || !fallback.name) {
    return null;
  }

  return {
    trackerFileId: fallback.id,
    trackerName: fallback.name.replace(/\u0000/g, ""),
    webViewLink: fallback.webViewLink ?? null,
  };
}

function classifyIntegrationError(error: unknown): { errorCode: string; message: string } {
  const message = error instanceof Error ? error.message : String(error);
  const normalized = message.toLowerCase();

  if (normalized.includes("channel_not_found")) {
    return { errorCode: "channel_not_found", message };
  }
  if (normalized.includes("missing_scope")) {
    return { errorCode: "missing_scope", message };
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
  if (normalized.includes("insufficient") && normalized.includes("permissions")) {
    return { errorCode: "insufficient_permissions", message };
  }
  if (normalized.includes("unable to find the tracker item header row")) {
    return { errorCode: "tracker_shape_unrecognized", message };
  }

  return { errorCode: "sync_error", message };
}

async function recordSyncIssue(input: {
  initiativeId: string;
  sourceType: "slack" | "google" | "tracker";
  runId: string | null;
  sourceId: string | null;
  error: unknown;
  metadata?: Record<string, unknown>;
}): Promise<void> {
  const classified = classifyIntegrationError(input.error);
  await db.insert(integrationSyncIssues).values({
    id: createId("sync_issue"),
    initiativeId: input.initiativeId,
    sourceType: input.sourceType,
    runId: input.runId,
    sourceId: input.sourceId,
    errorCode: classified.errorCode,
    message: classified.message,
    metadata: input.metadata ?? {},
  });
}

function normalizeSlackAttachments(files: SlackFilePayload[] | undefined) {
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
      textExcerpt: null as string | null,
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
): Promise<T> {
  for (let attempt = 0; attempt < 6; attempt += 1) {
    const url = new URL(`https://slack.com/api/${method}`);
    for (const [key, value] of Object.entries(params)) {
      url.searchParams.set(key, value);
    }

    const response = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (response.status === 429) {
      const retryAfterSeconds = Number(response.headers.get("retry-after") ?? "5");
      await sleep((Number.isFinite(retryAfterSeconds) ? retryAfterSeconds : 5) * 1000);
      continue;
    }

    if (!response.ok) {
      throw new Error(`Slack API ${method} failed with HTTP ${response.status}`);
    }

    return (await response.json()) as T;
  }

  throw new Error(`Slack API ${method} exhausted retry attempts after repeated rate limits`);
}

async function fetchChannelName(token: string, channelId: string): Promise<string | null> {
  const payload = await slackApi<SlackConversationInfoPayload>(token, "conversations.info", {
    channel: channelId,
  });
  return payload.ok ? payload.channel?.name ?? null : null;
}

async function fetchFullChannelHistory(
  token: string,
  channelId: string,
): Promise<SlackHistoryPayload["messages"]> {
  const allMessages: NonNullable<SlackHistoryPayload["messages"]> = [];
  let cursor = "";

  while (true) {
    const payload = await slackApi<SlackHistoryPayload>(token, "conversations.history", {
      channel: channelId,
      limit: "200",
      ...(cursor ? { cursor } : {}),
    });

    if (!payload.ok) {
      throw new Error(payload.error ?? "Unable to read Slack channel history");
    }

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
): Promise<SlackRepliesPayload["messages"]> {
  const replies: NonNullable<SlackRepliesPayload["messages"]> = [];
  let cursor = "";

  while (true) {
    const payload = await slackApi<SlackRepliesPayload>(token, "conversations.replies", {
      channel: channelId,
      ts: threadTs,
      limit: "200",
      ...(cursor ? { cursor } : {}),
    });

    if (!payload.ok) {
      throw new Error(payload.error ?? "Unable to read Slack thread replies");
    }

    replies.push(...(payload.messages ?? []));
    cursor = payload.response_metadata?.next_cursor ?? "";
    if (!cursor) {
      break;
    }
  }

  return replies;
}

async function googleApi<T>(token: string, url: URL): Promise<T> {
  for (let attempt = 0; attempt < 8; attempt += 1) {
    const response = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (response.status === 429) {
      const retryAfterSeconds = Number(response.headers.get("retry-after") ?? String(5 * (attempt + 1)));
      await sleep((Number.isFinite(retryAfterSeconds) ? retryAfterSeconds : 5 * (attempt + 1)) * 1000);
      continue;
    }

    if (!response.ok) {
      throw new Error(`Google API failed with HTTP ${response.status}`);
    }

    return (await response.json()) as T;
  }

  throw new Error("Google API exhausted retry attempts after repeated rate limits");
}

async function getGoogleFile(token: string, fileId: string): Promise<GoogleDriveFile> {
  const url = new URL(`https://www.googleapis.com/drive/v3/files/${fileId}`);
  url.searchParams.set(
    "fields",
    "id,name,mimeType,modifiedTime,webViewLink,lastModifyingUser(displayName,emailAddress)",
  );
  url.searchParams.set("supportsAllDrives", "true");
  return googleApi<GoogleDriveFile>(token, url);
}

async function listAllFolderFiles(token: string, folderId: string): Promise<GoogleDriveFile[]> {
  const files: GoogleDriveFile[] = [];
  let pageToken = "";

  while (true) {
    const url = new URL("https://www.googleapis.com/drive/v3/files");
    url.searchParams.set("q", `'${folderId}' in parents and trashed = false`);
    url.searchParams.set(
      "fields",
      "nextPageToken,files(id,name,mimeType,modifiedTime,webViewLink,lastModifyingUser(displayName,emailAddress))",
    );
    url.searchParams.set("pageSize", "200");
    url.searchParams.set("orderBy", "modifiedTime desc");
    url.searchParams.set("supportsAllDrives", "true");
    url.searchParams.set("includeItemsFromAllDrives", "true");
    if (pageToken) {
      url.searchParams.set("pageToken", pageToken);
    }

    const payload = await googleApi<{ files?: GoogleDriveFile[]; nextPageToken?: string }>(token, url);
    files.push(...(payload.files ?? []));
    pageToken = payload.nextPageToken ?? "";
    if (!pageToken) {
      break;
    }
  }

  return files;
}

async function listAllRevisions(token: string, fileId: string): Promise<GoogleDriveRevision[]> {
  const revisions: GoogleDriveRevision[] = [];
  let pageToken = "";

  while (true) {
    const url = new URL(`https://www.googleapis.com/drive/v3/files/${fileId}/revisions`);
    url.searchParams.set(
      "fields",
      "nextPageToken,revisions(id,modifiedTime,lastModifyingUser(displayName,emailAddress))",
    );
    url.searchParams.set("pageSize", "200");
    url.searchParams.set("supportsAllDrives", "true");
    if (pageToken) {
      url.searchParams.set("pageToken", pageToken);
    }

    const payload = await googleApi<{ revisions?: GoogleDriveRevision[]; nextPageToken?: string }>(
      token,
      url,
    );
    revisions.push(...(payload.revisions ?? []));
    pageToken = payload.nextPageToken ?? "";
    if (!pageToken) {
      break;
    }
  }

  return revisions;
}

async function resolveGoogleTargets(initiative: InitiativeDetail): Promise<GoogleFileTarget[]> {
  return initiative.links
    .filter((link) => /google\.(com|usercontent)/i.test(link.url))
    .map((link) => {
      const parsed = parseGoogleFileLink(link.url);
      if (!parsed) {
        return null;
      }

      return {
        fileId: parsed.fileId,
        kind: parsed.kind,
        url: link.url,
        label: link.label,
      };
    })
    .filter((value): value is GoogleFileTarget => Boolean(value));
}

function chunk<T>(items: T[], size: number): T[][] {
  const chunks: T[][] = [];
  for (let index = 0; index < items.length; index += size) {
    chunks.push(items.slice(index, index + size));
  }
  return chunks;
}

async function crawlGoogleTree(input: {
  token: string;
  target: GoogleFileTarget;
  initiativeId: string;
  runId: string;
  snapshots: Array<{
    fileId: string;
    parentFileId: string | null;
    depth: number;
    crawlPath: string;
    name: string;
    mimeType: string | null;
    modifiedTime: Date | null;
    lastModifyingUser: string | null;
    webViewLink: string | null;
    rawJson: Record<string, unknown>;
  }>;
  revisionRows: Array<{
    fileId: string;
    revisionId: string;
    modifiedTime: Date | null;
    lastModifyingUser: string | null;
    rawJson: Record<string, unknown>;
  }>;
}): Promise<void> {
  const { token, target, initiativeId, runId, snapshots, revisionRows } = input;
  const visited = new Set<string>();
  const queue: Array<{
    fileId: string;
    parentFileId: string | null;
    depth: number;
    crawlPath: string;
    sourceUrl?: string;
    sourceLabel?: string;
  }> = [
    {
      fileId: target.fileId,
      parentFileId: null,
      depth: 0,
      crawlPath: target.label || target.fileId,
      sourceUrl: target.url,
      sourceLabel: target.label,
    },
  ];

  while (queue.length > 0) {
    const current = queue.shift();
    if (!current || visited.has(current.fileId)) {
      continue;
    }
    visited.add(current.fileId);

    let file: GoogleDriveFile;
    try {
      file = await getGoogleFile(token, current.fileId);
    } catch (error) {
      await recordSyncIssue({
        initiativeId,
        sourceType: "google",
        runId,
        sourceId: current.fileId,
        error,
        metadata: {
          crawlPath: current.crawlPath,
          targetUrl: current.sourceUrl ?? null,
        },
      });
      continue;
    }

    if (!file.id || !file.name) {
      continue;
    }

    snapshots.push({
      fileId: file.id,
      parentFileId: current.parentFileId,
      depth: current.depth,
      crawlPath: current.crawlPath.replace(/\u0000/g, ""),
      name: file.name.replace(/\u0000/g, ""),
      mimeType: file.mimeType?.replace(/\u0000/g, "") ?? null,
      modifiedTime: file.modifiedTime ? new Date(file.modifiedTime) : null,
      lastModifyingUser: formatGoogleUser(file.lastModifyingUser),
      webViewLink: file.webViewLink ?? current.sourceUrl ?? null,
      rawJson: sanitizeJsonValue({
        ...file,
        crawlPath: current.crawlPath,
        depth: current.depth,
        sourceUrl: current.sourceUrl ?? null,
        sourceLabel: current.sourceLabel ?? null,
      }) as Record<string, unknown>,
    });

    const revisions = await listAllRevisions(token, file.id).catch(async (error) => {
      await recordSyncIssue({
        initiativeId,
        sourceType: "google",
        runId,
        sourceId: file.id!,
        error,
        metadata: {
          crawlPath: current.crawlPath,
          phase: "revisions",
        },
      });
      return [];
    });
    revisionRows.push(
      ...revisions
        .filter((revision): revision is GoogleDriveRevision & { id: string } => Boolean(revision.id))
        .map((revision) => ({
          fileId: file.id!,
          revisionId: revision.id!,
          modifiedTime: revision.modifiedTime ? new Date(revision.modifiedTime) : null,
          lastModifyingUser: formatGoogleUser(revision.lastModifyingUser),
          rawJson: sanitizeJsonValue(revision) as Record<string, unknown>,
        })),
    );

    if (file.mimeType !== "application/vnd.google-apps.folder") {
      continue;
    }

    const children = await listAllFolderFiles(token, file.id).catch(async (error) => {
      await recordSyncIssue({
        initiativeId,
        sourceType: "google",
        runId,
        sourceId: file.id!,
        error,
        metadata: {
          crawlPath: current.crawlPath,
          phase: "folder_list",
        },
      });
      return [];
    });

    for (const child of children) {
      if (!child.id || !child.name) {
        continue;
      }
      queue.push({
        fileId: child.id,
        parentFileId: file.id,
        depth: current.depth + 1,
        crawlPath: `${current.crawlPath} / ${child.name}`,
      });
    }
  }
}

export async function syncSlackHistoryForInitiative(initiative: InitiativeDetail): Promise<{
  runIds: string[];
  messagesSynced: number;
  repliesSynced: number;
  attachmentsSynced: number;
  issueCount: number;
}> {
  const token = await getSlackUserToken();
  if (!token) {
    throw new Error("Slack is not connected.");
  }

  const channelTargets = initiative.links
    .filter((link) => link.linkType === "channel" && link.url)
    .map((link) => {
      const parsed = parseSlackChannelLink(link.url);
      if (!parsed) {
        return null;
      }

      return {
        channelId: parsed.channelId,
        label: link.label || parsed.label,
        url: link.url,
      };
    })
    .filter((value): value is { channelId: string; label: string; url: string } => Boolean(value));

  const runIds: string[] = [];
  let messagesSynced = 0;
  let repliesSynced = 0;
  let attachmentsSynced = 0;
  let issueCount = 0;
  const reuseThreshold = new Date(Date.now() - env.EVIDENCE_SYNC_REUSE_HOURS * 60 * 60 * 1000);

  for (const channel of channelTargets) {
    const latestCompletedRun = await db.query.slackSyncRuns.findFirst({
      where: and(
        eq(slackSyncRuns.initiativeId, initiative.id),
        eq(slackSyncRuns.channelId, channel.channelId),
        eq(slackSyncRuns.status, "completed"),
      ),
      orderBy: [desc(slackSyncRuns.createdAt)],
    });

    if (latestCompletedRun && latestCompletedRun.createdAt >= reuseThreshold) {
      const summary = (latestCompletedRun.summary ?? {}) as Record<string, unknown>;
      runIds.push(latestCompletedRun.id);
      messagesSynced += typeof summary.messagesSynced === "number" ? summary.messagesSynced : 0;
      repliesSynced += typeof summary.repliesSynced === "number" ? summary.repliesSynced : 0;
      attachmentsSynced += typeof summary.attachmentsSynced === "number" ? summary.attachmentsSynced : 0;
      continue;
    }

    await db
      .update(slackSyncRuns)
      .set({
        status: "failed",
        summary: {
          errorCode: "superseded_rerun",
          message: "Marked failed because a newer sync attempt superseded this in-flight run.",
        },
        finishedAt: new Date(),
      })
      .where(
        and(
          eq(slackSyncRuns.initiativeId, initiative.id),
          eq(slackSyncRuns.channelId, channel.channelId),
          eq(slackSyncRuns.status, "running"),
        ),
      );

    const runId = createId("slack_sync");
    runIds.push(runId);
    await db.insert(slackSyncRuns).values({
      id: runId,
      initiativeId: initiative.id,
      channelId: channel.channelId,
      channelName: channel.label,
      status: "running",
      syncMode: "full_backfill",
      summary: {},
    });

    try {
      const channelName = await fetchChannelName(token, channel.channelId);
      const history = (await fetchFullChannelHistory(token, channel.channelId) ?? []).filter(
        (message) => !message.subtype && sanitizeSlackText(message.text),
      );

      const replyRows: Array<{
        channelId: string;
        parentTs: string;
        ts: string;
        messageAt: Date | null;
        userId: string | null;
        text: string;
        attachments: ReturnType<typeof normalizeSlackAttachments>;
        rawJson: Record<string, unknown>;
      }> = [];
      const attachmentRows: Array<{
        channelId: string;
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
      }> = [];

      const messageRows = history.map((message) => ({
        channelId: channel.channelId,
        channelName,
        ts: message.ts,
        messageAt: slackTsToDate(message.ts),
        userId: message.user ?? null,
        text: sanitizeSlackText(message.text),
        permalink: buildSlackPermalink(channel.url, channel.channelId, message.ts),
        replyCount: message.reply_count ?? 0,
        attachments: normalizeSlackAttachments(message.files),
        rawJson: message as Record<string, unknown>,
        threadTs: message.thread_ts ?? message.ts,
      }));

      for (const message of messageRows) {
        attachmentRows.push(
          ...message.attachments.map((attachment) => ({
            channelId: message.channelId,
            messageTs: message.ts,
            parentTs: null,
            ...attachment,
          })),
        );
      }

      for (const message of messageRows) {
        if (message.replyCount <= 0) {
          continue;
        }

        const replies = (await fetchFullThreadReplies(token, channel.channelId, message.threadTs)) ?? [];
        for (const reply of replies.slice(1)) {
          if (reply.subtype || !sanitizeSlackText(reply.text)) {
            continue;
          }
          replyRows.push({
            channelId: channel.channelId,
            parentTs: message.threadTs,
            ts: reply.ts,
            messageAt: slackTsToDate(reply.ts),
            userId: reply.user ?? null,
            text: sanitizeSlackText(reply.text),
            attachments: normalizeSlackAttachments(reply.files),
            rawJson: reply as Record<string, unknown>,
          });
        }
      }

      for (const reply of replyRows) {
        attachmentRows.push(
          ...reply.attachments.map((attachment) => ({
            channelId: reply.channelId,
            messageTs: reply.ts,
            parentTs: reply.parentTs,
            ...attachment,
          })),
        );
      }

      for (const values of chunk(messageRows, 150)) {
        await db
          .insert(slackMessageEvents)
          .values(
            values.map((message) => ({
              id: createId("slack_message"),
              initiativeId: initiative.id,
              syncRunId: runId,
              channelId: message.channelId,
              channelName: message.channelName,
              ts: message.ts,
              messageAt: message.messageAt,
              userId: message.userId,
              text: message.text,
              permalink: message.permalink,
              replyCount: message.replyCount,
              rawJson: sanitizeJsonValue(message.rawJson) as Record<string, unknown>,
            })),
          )
          .onConflictDoUpdate({
            target: [slackMessageEvents.channelId, slackMessageEvents.ts],
            set: {
              initiativeId: initiative.id,
              syncRunId: runId,
              channelName: sql`excluded.channel_name`,
              messageAt: sql`excluded.message_at`,
              userId: sql`excluded.user_id`,
              text: sql`excluded.text`,
              permalink: sql`excluded.permalink`,
              replyCount: sql`excluded.reply_count`,
              rawJson: sql`excluded.raw_json`,
            },
          });
      }

      for (const values of chunk(replyRows, 150)) {
        await db
          .insert(slackReplyEvents)
          .values(
            values.map((reply) => ({
              id: createId("slack_reply"),
              initiativeId: initiative.id,
              syncRunId: runId,
              channelId: reply.channelId,
              parentTs: reply.parentTs,
              ts: reply.ts,
              messageAt: reply.messageAt,
              userId: reply.userId,
              text: reply.text,
              rawJson: sanitizeJsonValue(reply.rawJson) as Record<string, unknown>,
            })),
          )
          .onConflictDoUpdate({
            target: [slackReplyEvents.channelId, slackReplyEvents.ts],
            set: {
              initiativeId: initiative.id,
              syncRunId: runId,
              parentTs: sql`excluded.parent_ts`,
              messageAt: sql`excluded.message_at`,
              userId: sql`excluded.user_id`,
              text: sql`excluded.text`,
              rawJson: sql`excluded.raw_json`,
            },
          });
      }

      for (const values of chunk(attachmentRows, 150)) {
        await db
          .insert(slackFileEvents)
          .values(
            values.map((attachment) => ({
              id: createId("slack_file"),
              initiativeId: initiative.id,
              syncRunId: runId,
              channelId: attachment.channelId,
              messageTs: attachment.messageTs,
              parentTs: attachment.parentTs,
              slackFileId: attachment.slackFileId,
              title: attachment.title?.replace(/\u0000/g, "") ?? null,
              name: attachment.name?.replace(/\u0000/g, "") ?? null,
              mimeType: attachment.mimeType?.replace(/\u0000/g, "") ?? null,
              fileType: attachment.fileType?.replace(/\u0000/g, "") ?? null,
              prettyType: attachment.prettyType?.replace(/\u0000/g, "") ?? null,
              sizeBytes: attachment.sizeBytes,
              permalink: attachment.permalink,
              privateUrl: attachment.privateUrl,
              privateDownloadUrl: attachment.privateDownloadUrl,
              textExcerpt: attachment.textExcerpt,
              rawJson: sanitizeJsonValue(attachment.rawJson) as Record<string, unknown>,
            })),
          )
          .onConflictDoUpdate({
            target: [slackFileEvents.channelId, slackFileEvents.messageTs, slackFileEvents.slackFileId],
            set: {
              initiativeId: initiative.id,
              syncRunId: runId,
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

      messagesSynced += messageRows.length;
      repliesSynced += replyRows.length;
      attachmentsSynced += attachmentRows.length;

      await db
        .update(slackSyncRuns)
        .set({
          status: "completed",
          channelName: channelName ?? channel.label,
          summary: {
            messagesSynced: messageRows.length,
            repliesSynced: replyRows.length,
            attachmentsSynced: attachmentRows.length,
            oldestTs: messageRows.at(-1)?.ts ?? null,
            newestTs: messageRows[0]?.ts ?? null,
          },
          finishedAt: new Date(),
        })
        .where(eq(slackSyncRuns.id, runId));
    } catch (error) {
      issueCount += 1;
      await recordSyncIssue({
        initiativeId: initiative.id,
        sourceType: "slack",
        runId,
        sourceId: channel.channelId,
        error,
        metadata: {
          channelLabel: channel.label,
          channelUrl: channel.url,
        },
      });
      await db
        .update(slackSyncRuns)
        .set({
          status: "failed",
          summary: {
            ...classifyIntegrationError(error),
            channelLabel: channel.label,
            channelUrl: channel.url,
          },
          finishedAt: new Date(),
        })
        .where(eq(slackSyncRuns.id, runId));
    }
  }

  return {
    runIds,
    messagesSynced,
    repliesSynced,
    attachmentsSynced,
    issueCount,
  };
}

export async function syncGoogleHistoryForInitiative(initiative: InitiativeDetail): Promise<{
  runId: string;
  trackerCandidate: TrackerCandidate | null;
  snapshotCount: number;
  revisionCount: number;
  issueCount: number;
}> {
  const token = await getGoogleAccessToken();
  if (!token) {
    throw new Error("Google is not connected.");
  }

  const reuseThreshold = new Date(Date.now() - env.EVIDENCE_SYNC_REUSE_HOURS * 60 * 60 * 1000);
  const latestCompletedRun = await db.query.googleSyncRuns.findFirst({
    where: and(eq(googleSyncRuns.initiativeId, initiative.id), eq(googleSyncRuns.status, "completed")),
    orderBy: [desc(googleSyncRuns.createdAt)],
  });

  if (latestCompletedRun && latestCompletedRun.createdAt >= reuseThreshold) {
    const summary = (latestCompletedRun.summary ?? {}) as Record<string, unknown>;
    return {
      runId: latestCompletedRun.id,
      trackerCandidate: (summary.trackerCandidate as TrackerCandidate | null | undefined) ?? null,
      snapshotCount: typeof summary.snapshotCount === "number" ? summary.snapshotCount : 0,
      revisionCount: typeof summary.revisionCount === "number" ? summary.revisionCount : 0,
      issueCount: typeof summary.issueCount === "number" ? summary.issueCount : 0,
    };
  }

  const targets = await resolveGoogleTargets(initiative);
  const runId = createId("google_sync");

  await db
    .update(googleSyncRuns)
    .set({
      status: "failed",
      summary: {
        errorCode: "superseded_rerun",
        message: "Marked failed because a newer sync attempt superseded this in-flight run.",
      },
      finishedAt: new Date(),
    })
    .where(and(eq(googleSyncRuns.initiativeId, initiative.id), eq(googleSyncRuns.status, "running")));

  await db.insert(googleSyncRuns).values({
    id: runId,
    initiativeId: initiative.id,
    rootFileId: targets[0]?.fileId ?? null,
    status: "running",
    summary: {},
  });

  try {
    const snapshots: Array<{
      fileId: string;
      parentFileId: string | null;
      depth: number;
      crawlPath: string;
      name: string;
      mimeType: string | null;
      modifiedTime: Date | null;
      lastModifyingUser: string | null;
      webViewLink: string | null;
      rawJson: Record<string, unknown>;
    }> = [];
    const revisionRows: Array<{
      fileId: string;
      revisionId: string;
      modifiedTime: Date | null;
      lastModifyingUser: string | null;
      rawJson: Record<string, unknown>;
    }> = [];

    for (const target of targets) {
      await crawlGoogleTree({
        token,
        target,
        initiativeId: initiative.id,
        runId,
        snapshots,
        revisionRows,
      });
    }

    for (const values of chunk(snapshots, 150)) {
      await db.insert(googleFileSnapshots).values(
        values.map((snapshot) => ({
          id: createId("google_snapshot"),
          initiativeId: initiative.id,
          syncRunId: runId,
          fileId: snapshot.fileId,
          parentFileId: snapshot.parentFileId,
          depth: snapshot.depth,
          crawlPath: snapshot.crawlPath,
          name: snapshot.name,
          mimeType: snapshot.mimeType,
          modifiedTime: snapshot.modifiedTime,
          lastModifyingUser: snapshot.lastModifyingUser,
          webViewLink: snapshot.webViewLink,
          rawJson: snapshot.rawJson,
        })),
      );
    }

    for (const values of chunk(revisionRows, 150)) {
      await db
        .insert(googleRevisionEvents)
        .values(
          values.map((revision) => ({
            id: createId("google_revision"),
            initiativeId: initiative.id,
            syncRunId: runId,
            fileId: revision.fileId,
            revisionId: revision.revisionId,
            modifiedTime: revision.modifiedTime,
            lastModifyingUser: revision.lastModifyingUser,
            rawJson: revision.rawJson,
          })),
        )
        .onConflictDoNothing();
    }

    const issueCountResult = await db
      .select({ count: sql<number>`count(*)::int` })
      .from(integrationSyncIssues)
      .where(and(eq(integrationSyncIssues.initiativeId, initiative.id), eq(integrationSyncIssues.runId, runId)));
    const issueCount = issueCountResult[0]?.count ?? 0;
    const trackerCandidate = chooseTrackerCandidate(
      snapshots.map((snapshot) => ({
        id: snapshot.fileId,
        name: snapshot.name,
        mimeType: snapshot.mimeType ?? undefined,
        webViewLink: snapshot.webViewLink,
      })),
    );

    await db
      .update(googleSyncRuns)
      .set({
        status: "completed",
        summary: {
          snapshotCount: snapshots.length,
          revisionCount: revisionRows.length,
          issueCount,
          trackerCandidate,
        },
        finishedAt: new Date(),
      })
      .where(eq(googleSyncRuns.id, runId));

    return {
      runId,
      trackerCandidate,
      snapshotCount: snapshots.length,
      revisionCount: revisionRows.length,
      issueCount,
    };
  } catch (error) {
    await recordSyncIssue({
      initiativeId: initiative.id,
      sourceType: "google",
      runId,
      sourceId: targets[0]?.fileId ?? null,
      error,
      metadata: {
        phase: "run",
      },
    });
    await db
      .update(googleSyncRuns)
      .set({
        status: "failed",
        summary: {
          ...classifyIntegrationError(error),
        },
        finishedAt: new Date(),
      })
      .where(eq(googleSyncRuns.id, runId));
    throw error;
  }
}

export async function getStoredSlackEvidenceForInitiative(
  initiative: InitiativeDetail,
): Promise<{
  connected: boolean;
  unreadableChannels: string[];
  issues: Array<{
    id: string;
    sourceType: string;
    runId: string | null;
    sourceId: string | null;
    severity: string;
    errorCode: string;
    message: string;
    metadata: Record<string, unknown>;
    createdAt: string;
  }>;
  messages: Array<{
    channelId: string;
    channelName: string | null;
    label: string;
    url: string;
    ts: string;
    userId: string | null;
    text: string;
    permalink: string | null;
    attachments: Array<{
      id: string;
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
    }>;
    replyCount: number;
    replies: Array<{
      ts: string;
      userId: string | null;
      text: string;
      attachments: Array<{
        id: string;
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
      }>;
    }>;
  }>;
}> {
  const installation = await db.query.slackInstallations.findFirst({
    orderBy: [desc(slackInstallations.updatedAt)],
  });
  const messages = await db.query.slackMessageEvents.findMany({
    where: eq(slackMessageEvents.initiativeId, initiative.id),
    orderBy: [desc(slackMessageEvents.messageAt), desc(slackMessageEvents.createdAt)],
  });
  const issues = await db.query.integrationSyncIssues.findMany({
    where: and(eq(integrationSyncIssues.initiativeId, initiative.id), eq(integrationSyncIssues.sourceType, "slack")),
    orderBy: [desc(integrationSyncIssues.createdAt)],
    limit: 20,
  });

  if (!installation) {
    return {
      connected: false,
      unreadableChannels: issues.map((issue) => String(issue.metadata.channelLabel ?? issue.sourceId ?? "unknown")),
      issues: issues.map((issue) => ({
        id: issue.id,
        sourceType: issue.sourceType,
        runId: issue.runId,
        sourceId: issue.sourceId,
        severity: issue.severity,
        errorCode: issue.errorCode,
        message: issue.message,
        metadata: issue.metadata,
        createdAt: issue.createdAt.toISOString(),
      })),
      messages: [],
    };
  }

  const topMessages = messages.slice(0, 18);
  const messageAndReplyTs = new Set(topMessages.map((message) => message.ts));
  const replies =
    topMessages.length > 0
      ? await db.query.slackReplyEvents.findMany({
          where: and(
            eq(slackReplyEvents.initiativeId, initiative.id),
            inArray(
              slackReplyEvents.parentTs,
              topMessages.map((message) => message.ts),
            ),
          ),
          orderBy: [desc(slackReplyEvents.messageAt), desc(slackReplyEvents.createdAt)],
        })
      : [];

  for (const reply of replies) {
    messageAndReplyTs.add(reply.ts);
  }

  const attachments = messageAndReplyTs.size
    ? await db.query.slackFileEvents.findMany({
        where: and(
          eq(slackFileEvents.initiativeId, initiative.id),
          inArray(slackFileEvents.messageTs, Array.from(messageAndReplyTs)),
        ),
      })
    : [];

  const attachmentsByMessageTs = new Map<
    string,
    Array<{
      id: string;
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
    }>
  >();
  for (const attachment of attachments) {
    const current = attachmentsByMessageTs.get(attachment.messageTs) ?? [];
    current.push({
      id: attachment.slackFileId,
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
    });
    attachmentsByMessageTs.set(attachment.messageTs, current);
  }

  const repliesByParent = new Map<
    string,
    Array<{ ts: string; userId: string | null; text: string; attachments: Array<{
      id: string;
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
    }> }>
  >();
  for (const reply of replies) {
    const current = repliesByParent.get(reply.parentTs) ?? [];
    current.push({
      ts: reply.ts,
      userId: reply.userId,
      text: reply.text,
      attachments: attachmentsByMessageTs.get(reply.ts) ?? [],
    });
    repliesByParent.set(reply.parentTs, current);
  }

  const urlByChannel = new Map(
    initiative.links
      .filter((link) => link.linkType === "channel" && link.url)
      .map((link) => {
        const parsed = parseSlackChannelLink(link.url);
        return parsed ? [parsed.channelId, { label: link.label || parsed.label, url: link.url }] : null;
      })
      .filter((value): value is [string, { label: string; url: string }] => Boolean(value)),
  );

  return {
    connected: true,
    unreadableChannels: issues
      .map((issue) => String(issue.metadata.channelLabel ?? issue.sourceId ?? "unknown"))
      .filter(Boolean),
    issues: issues.map((issue) => ({
      id: issue.id,
      sourceType: issue.sourceType,
      runId: issue.runId,
      sourceId: issue.sourceId,
      severity: issue.severity,
      errorCode: issue.errorCode,
      message: issue.message,
      metadata: issue.metadata,
      createdAt: issue.createdAt.toISOString(),
    })),
    messages: topMessages.map((message) => ({
      channelId: message.channelId,
      channelName: message.channelName,
      label: urlByChannel.get(message.channelId)?.label ?? message.channelName ?? message.channelId,
      url: urlByChannel.get(message.channelId)?.url ?? message.permalink ?? "",
      ts: message.ts,
      userId: message.userId,
      text: message.text,
      permalink: message.permalink,
      attachments: attachmentsByMessageTs.get(message.ts) ?? [],
      replyCount: message.replyCount,
      replies: repliesByParent.get(message.ts) ?? [],
    })),
  };
}

export async function getStoredGoogleEvidenceForInitiative(initiativeId: string): Promise<{
  connected: boolean;
  issues: Array<{
    id: string;
    sourceType: string;
    runId: string | null;
    sourceId: string | null;
    severity: string;
    errorCode: string;
    message: string;
    metadata: Record<string, unknown>;
    createdAt: string;
  }>;
  files: Array<{
    linkId: string;
    label: string;
    url: string;
    fileId: string | null;
    name: string | null;
    mimeType: string | null;
    readable: boolean;
    error: string | null;
    modifiedTime: string | null;
    lastModifyingUser: string | null;
    webViewLink: string | null;
    depth: number;
    crawlPath: string;
    revisions: Array<{ id: string; modifiedTime: string | null; lastModifyingUser: string | null }>;
    children: Array<{
      id: string;
      parentFileId: string | null;
      depth: number;
      crawlPath: string;
      name: string;
      mimeType: string | null;
      modifiedTime: string | null;
      lastModifyingUser: string | null;
      webViewLink: string | null;
      revisions: Array<{ id: string; modifiedTime: string | null; lastModifyingUser: string | null }>;
    }>;
  }>;
}> {
  const installation = await db.query.googleInstallations.findFirst({
    orderBy: [desc(googleInstallations.updatedAt)],
  });
  const recentRuns = await db.query.googleSyncRuns.findMany({
    where: eq(googleSyncRuns.initiativeId, initiativeId),
    orderBy: [desc(googleSyncRuns.createdAt)],
    limit: 8,
  });
  const latestRun = recentRuns.find((run) => run.status === "completed") ?? recentRuns[0] ?? null;
  const newestRunId = recentRuns[0]?.id ?? latestRun?.id ?? null;
  const issueWhere = newestRunId
    ? and(
        eq(integrationSyncIssues.initiativeId, initiativeId),
        eq(integrationSyncIssues.sourceType, "google"),
        eq(integrationSyncIssues.runId, newestRunId),
      )
    : and(
        eq(integrationSyncIssues.initiativeId, initiativeId),
        eq(integrationSyncIssues.sourceType, "google"),
      );
  const issues = await db.query.integrationSyncIssues.findMany({
    where: issueWhere,
    orderBy: [desc(integrationSyncIssues.createdAt)],
    limit: 20,
  });

  if (!installation) {
    return {
      connected: false,
      issues: issues.map((issue) => ({
        id: issue.id,
        sourceType: issue.sourceType,
        runId: issue.runId,
        sourceId: issue.sourceId,
        severity: issue.severity,
        errorCode: issue.errorCode,
        message: issue.message,
        metadata: issue.metadata,
        createdAt: issue.createdAt.toISOString(),
      })),
      files: [],
    };
  }

  if (!latestRun) {
    return {
      connected: true,
      issues: issues.map((issue) => ({
        id: issue.id,
        sourceType: issue.sourceType,
        runId: issue.runId,
        sourceId: issue.sourceId,
        severity: issue.severity,
        errorCode: issue.errorCode,
        message: issue.message,
        metadata: issue.metadata,
        createdAt: issue.createdAt.toISOString(),
      })),
      files: [],
    };
  }

  const snapshots = await db.query.googleFileSnapshots.findMany({
    where: eq(googleFileSnapshots.syncRunId, latestRun.id),
    orderBy: [desc(googleFileSnapshots.modifiedTime), desc(googleFileSnapshots.createdAt)],
  });

  const revisions =
    snapshots.length > 0
      ? await db.query.googleRevisionEvents.findMany({
          where: and(
            eq(googleRevisionEvents.initiativeId, initiativeId),
            inArray(
              googleRevisionEvents.fileId,
              snapshots.map((snapshot) => snapshot.fileId),
            ),
          ),
        })
      : [];

  const revisionsByFile = new Map<string, Array<{ id: string; modifiedTime: string | null; lastModifyingUser: string | null }>>();
  for (const revision of revisions) {
    const current = revisionsByFile.get(revision.fileId) ?? [];
    current.push({
      id: revision.revisionId,
      modifiedTime: revision.modifiedTime?.toISOString() ?? null,
      lastModifyingUser: revision.lastModifyingUser,
    });
    revisionsByFile.set(revision.fileId, current);
  }

  const rootSnapshots = snapshots.filter((snapshot) => !snapshot.parentFileId);
  const childSnapshots = snapshots.filter((snapshot) => snapshot.parentFileId);
  const childrenByParent = new Map<string, typeof childSnapshots>();
  for (const child of childSnapshots) {
    const current = childrenByParent.get(child.parentFileId!) ?? [];
    current.push(child);
    childrenByParent.set(child.parentFileId!, current);
  }

  function collectDescendants(parentFileId: string): typeof childSnapshots {
    const direct = childrenByParent.get(parentFileId) ?? [];
    return direct.flatMap((child) => [child, ...collectDescendants(child.fileId)]);
  }

  return {
    connected: true,
    issues: issues.map((issue) => ({
      id: issue.id,
      sourceType: issue.sourceType,
      runId: issue.runId,
      sourceId: issue.sourceId,
      severity: issue.severity,
      errorCode: issue.errorCode,
      message: issue.message,
      metadata: issue.metadata,
      createdAt: issue.createdAt.toISOString(),
    })),
    files: rootSnapshots.map((snapshot) => ({
      linkId: snapshot.fileId,
      label: snapshot.name,
      url: snapshot.webViewLink ?? "",
      fileId: snapshot.fileId,
      name: snapshot.name,
      mimeType: snapshot.mimeType,
      readable: true,
      error: null,
      modifiedTime: snapshot.modifiedTime?.toISOString() ?? null,
      lastModifyingUser: snapshot.lastModifyingUser,
      webViewLink: snapshot.webViewLink,
      depth: snapshot.depth,
      crawlPath: snapshot.crawlPath,
      revisions: revisionsByFile.get(snapshot.fileId) ?? [],
      children: collectDescendants(snapshot.fileId).map((child) => ({
        id: child.fileId,
        parentFileId: child.parentFileId,
        depth: child.depth,
        crawlPath: child.crawlPath,
        name: child.name,
        mimeType: child.mimeType,
        modifiedTime: child.modifiedTime?.toISOString() ?? null,
        lastModifyingUser: child.lastModifyingUser,
        webViewLink: child.webViewLink,
        revisions: revisionsByFile.get(child.fileId) ?? [],
      })),
    })),
  };
}

export async function detectTrackerCandidateForInitiative(
  initiative: InitiativeDetail,
): Promise<TrackerCandidate | null> {
  const token = await getGoogleAccessToken();
  if (!token) {
    return null;
  }

  const targets = await resolveGoogleTargets(initiative);
  const files: Array<{ id?: string; name?: string; mimeType?: string; webViewLink?: string | null }> = [];
  for (const target of targets) {
    const root = await getGoogleFile(token, target.fileId).catch(() => null);
    if (root) {
      files.push(root);
    }

    if (target.kind === "folder") {
      const children = await listAllFolderFiles(token, target.fileId).catch(() => []);
      files.push(...children);
    }
  }

  return chooseTrackerCandidate(files);
}

export async function listPilotCandidates(limit = 10): Promise<
  Array<{ initiativeId: string; code: string; title: string; group: string; trackerDetected: boolean; trackerName: string | null }>
> {
  const rows = await db.select().from(initiatives).where(eq(initiatives.isActive, true)).orderBy(initiatives.code);
  const eligible: InitiativeDetail[] = [];

  for (const row of rows) {
    if (["001", "030"].includes(row.code)) {
      continue;
    }

    const links = await db.query.initiativeLinks.findMany({
      where: eq(initiativeLinks.initiativeId, row.id),
    });
    const hasChannel = links.some((link) => link.linkType === "channel" && link.url);
    const hasFolder = links.some((link) => link.linkType === "folder" && link.url);
    if (!hasChannel || !hasFolder) {
      continue;
    }

    const detail = await getInitiativeById(row.id);
    if (!detail) {
      continue;
    }
    eligible.push(detail);
  }

  const discovered: Array<{
    initiativeId: string;
    code: string;
    title: string;
    group: string;
    trackerDetected: boolean;
    trackerName: string | null;
  }> = [];

  for (const initiative of eligible) {
    const tracker = await detectTrackerCandidateForInitiative(initiative);
    if (!tracker) {
      continue;
    }
    discovered.push({
      initiativeId: initiative.id,
      code: initiative.code,
      title: initiative.title,
      group: initiative.group,
      trackerDetected: true,
      trackerName: tracker.trackerName,
    });
    if (discovered.length >= limit * 2) {
      break;
    }
  }

  const chosen: typeof discovered = [];
  const seenGroups = new Set<string>();
  for (const candidate of discovered) {
    if (candidate.group && !seenGroups.has(candidate.group) && chosen.length < limit) {
      chosen.push(candidate);
      seenGroups.add(candidate.group);
    }
  }

  for (const candidate of discovered) {
    if (chosen.length >= limit) {
      break;
    }
    if (!chosen.some((existing) => existing.initiativeId === candidate.initiativeId)) {
      chosen.push(candidate);
    }
  }

  return chosen.slice(0, limit);
}
