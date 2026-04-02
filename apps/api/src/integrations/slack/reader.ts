import type { InitiativeDetail, InitiativeSlackEvidence } from "@si/domain";
import { desc } from "drizzle-orm";
import { db } from "../../db/client.js";
import { slackInstallations } from "../../db/schema.js";
import { decryptSecret } from "../../lib/crypto.js";

interface SlackApiResponse {
  ok: boolean;
  error?: string;
}

interface SlackConversationInfoResponse extends SlackApiResponse {
  channel?: {
    id: string;
    name: string;
  };
}

interface SlackHistoryResponse extends SlackApiResponse {
  messages?: Array<{
    type?: string;
    subtype?: string;
    ts: string;
    user?: string;
    text?: string;
    reply_count?: number;
    thread_ts?: string;
    files?: Array<{
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
    }>;
  }>;
}

interface SlackRepliesResponse extends SlackApiResponse {
  messages?: Array<{
    ts: string;
    user?: string;
    text?: string;
    subtype?: string;
    files?: Array<{
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
    }>;
  }>;
}

interface ChannelTarget {
  channelId: string;
  label: string;
  url: string;
}

function parseSlackChannelLink(url: string): ChannelTarget | null {
  try {
    const parsed = new URL(url);
    const parts = parsed.pathname.split("/").filter(Boolean);
    const archiveIndex = parts.indexOf("archives");
    const channelId = archiveIndex >= 0 ? parts[archiveIndex + 1] : null;
    if (!channelId) {
      return null;
    }

    return {
      channelId,
      label: channelId,
      url,
    };
  } catch {
    return null;
  }
}

function buildSlackPermalink(channelUrl: string, channelId: string, ts: string): string {
  const normalizedTs = ts.replace(".", "");
  const base = channelUrl.split("/archives/")[0];
  return `${base}/archives/${channelId}/p${normalizedTs}`;
}

function sanitizeMessageText(text: string | undefined): string {
  return (text ?? "").replace(/\s+/g, " ").trim();
}

function normalizeAttachments(
  files:
    | Array<{
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
      }>
    | undefined,
) {
  return (files ?? [])
    .filter((file): file is NonNullable<typeof files>[number] & { id: string } => Boolean(file.id))
    .map((file) => ({
      id: file.id!,
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
  const url = new URL(`https://slack.com/api/${method}`);
  for (const [key, value] of Object.entries(params)) {
    url.searchParams.set(key, value);
  }

  const response = await fetch(url, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw new Error(`Slack API ${method} failed with HTTP ${response.status}`);
  }

  return (await response.json()) as T;
}

async function fetchChannelName(token: string, channelId: string): Promise<string | null> {
  const payload = await slackApi<SlackConversationInfoResponse>(token, "conversations.info", {
    channel: channelId,
  });

  if (!payload.ok) {
    return null;
  }

  return payload.channel?.name ?? null;
}

async function fetchReplies(
  token: string,
  channelId: string,
  threadTs: string,
): Promise<Array<{ ts: string; userId: string | null; text: string; attachments: ReturnType<typeof normalizeAttachments> }>> {
  const payload = await slackApi<SlackRepliesResponse>(token, "conversations.replies", {
    channel: channelId,
    ts: threadTs,
    limit: "4",
  });

  if (!payload.ok || !payload.messages) {
    return [];
  }

  return payload.messages
    .slice(1, 4)
    .filter((message) => !message.subtype)
    .map((message) => ({
      ts: message.ts,
      userId: message.user ?? null,
      text: sanitizeMessageText(message.text).slice(0, 220),
      attachments: normalizeAttachments(message.files),
    }))
    .filter((message) => message.text);
}

export async function fetchSlackEvidenceForInitiative(
  initiative: InitiativeDetail,
): Promise<InitiativeSlackEvidence> {
  const token = await getSlackUserToken();
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
    .filter((value): value is ChannelTarget => Boolean(value));

  if (!token) {
    return {
      connected: false,
      initiativeId: initiative.id,
      issues: [],
      channels: channelTargets.map((channel) => ({
        channelId: channel.channelId,
        channelName: null,
        label: channel.label,
        url: channel.url,
        readable: false,
        error: "Slack is not connected.",
        messages: [],
      })),
      fetchedAt: new Date().toISOString(),
    };
  }

  const channels = await Promise.all(
    channelTargets.map(async (channel) => {
      try {
        const [channelName, history] = await Promise.all([
          fetchChannelName(token, channel.channelId),
          slackApi<SlackHistoryResponse>(token, "conversations.history", {
            channel: channel.channelId,
            limit: "8",
          }),
        ]);

        if (!history.ok || !history.messages) {
          return {
            channelId: channel.channelId,
            channelName,
            label: channel.label,
            url: channel.url,
            readable: false,
            error: history.error ?? "Unable to read channel history.",
            messages: [],
          };
        }

        const messages = await Promise.all(
          history.messages
            .filter((message) => !message.subtype && sanitizeMessageText(message.text))
            .slice(0, 6)
            .map(async (message) => ({
              ts: message.ts,
              userId: message.user ?? null,
              text: sanitizeMessageText(message.text).slice(0, 400),
              permalink: buildSlackPermalink(channel.url, channel.channelId, message.ts),
              attachments: normalizeAttachments(message.files),
              replyCount: message.reply_count ?? 0,
              replies:
                (message.reply_count ?? 0) > 0
                  ? await fetchReplies(token, channel.channelId, message.thread_ts ?? message.ts)
                  : [],
            })),
        );

        return {
          channelId: channel.channelId,
          channelName,
          label: channel.label,
          url: channel.url,
          readable: true,
          error: null,
          messages,
        };
      } catch (error) {
        return {
          channelId: channel.channelId,
          channelName: null,
          label: channel.label,
          url: channel.url,
          readable: false,
          error: error instanceof Error ? error.message : "Unable to read channel history.",
          messages: [],
        };
      }
    }),
  );

  return {
    connected: true,
    initiativeId: initiative.id,
    channels,
    issues: [],
    fetchedAt: new Date().toISOString(),
  };
}

export { parseSlackChannelLink };
