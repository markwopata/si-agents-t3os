import type { InitiativeRawEvidence } from "@si/domain";
import { and, count, desc, eq, inArray } from "drizzle-orm";
import { db } from "../db/client.js";
import {
  agentObservations,
  documentContentExtracts,
  googleFileSnapshots,
  integrationSyncIssues,
  kpiResearchRuns,
  slackFileEvents,
  slackMessageEvents,
  slackReplyEvents,
  trackerParseRuns,
} from "../db/schema.js";

export async function getInitiativeRawEvidence(
  initiativeId: string,
  limit: number | null = 50,
  offset = 0,
): Promise<InitiativeRawEvidence> {
  const safeLimit =
    typeof limit === "number" && Number.isFinite(limit) && limit > 0
      ? Math.max(Math.trunc(limit), 1)
      : null;
  const safeOffset = Number.isFinite(offset) && offset > 0 ? Math.trunc(offset) : 0;

  const [
    messages,
    files,
    latestTrackerRun,
    latestObservation,
    latestResearchRun,
    syncIssues,
    documentExtracts,
    slackMessageCountResult,
    googleFileCountResult,
    syncIssueCountResult,
    documentExtractCountResult,
  ] =
    await Promise.all([
    db.query.slackMessageEvents.findMany({
      where: eq(slackMessageEvents.initiativeId, initiativeId),
      orderBy: [desc(slackMessageEvents.messageAt), desc(slackMessageEvents.createdAt)],
      ...(safeLimit ? { limit: safeLimit } : {}),
      ...(safeOffset ? { offset: safeOffset } : {}),
    }),
    db.query.googleFileSnapshots.findMany({
      where: eq(googleFileSnapshots.initiativeId, initiativeId),
      orderBy: [desc(googleFileSnapshots.modifiedTime), desc(googleFileSnapshots.createdAt)],
      ...(safeLimit ? { limit: safeLimit } : {}),
      ...(safeOffset ? { offset: safeOffset } : {}),
    }),
    db.query.trackerParseRuns.findFirst({
      where: eq(trackerParseRuns.initiativeId, initiativeId),
      orderBy: [desc(trackerParseRuns.createdAt)],
    }),
    db.query.agentObservations.findFirst({
      where: eq(agentObservations.initiativeId, initiativeId),
      orderBy: [desc(agentObservations.createdAt)],
    }),
    db.query.kpiResearchRuns.findFirst({
      where: eq(kpiResearchRuns.initiativeId, initiativeId),
      orderBy: [desc(kpiResearchRuns.createdAt)],
    }),
    db.query.integrationSyncIssues.findMany({
      where: eq(integrationSyncIssues.initiativeId, initiativeId),
      orderBy: [desc(integrationSyncIssues.createdAt)],
      ...(safeLimit ? { limit: safeLimit } : {}),
      ...(safeOffset ? { offset: safeOffset } : {}),
    }),
    db.query.documentContentExtracts.findMany({
      where: eq(documentContentExtracts.initiativeId, initiativeId),
      orderBy: [desc(documentContentExtracts.updatedAt)],
      ...(safeLimit ? { limit: safeLimit } : {}),
      ...(safeOffset ? { offset: safeOffset } : {}),
    }),
    db.select({ value: count() }).from(slackMessageEvents).where(eq(slackMessageEvents.initiativeId, initiativeId)),
    db.select({ value: count() }).from(googleFileSnapshots).where(eq(googleFileSnapshots.initiativeId, initiativeId)),
    db.select({ value: count() }).from(integrationSyncIssues).where(eq(integrationSyncIssues.initiativeId, initiativeId)),
    db.select({ value: count() }).from(documentContentExtracts).where(eq(documentContentExtracts.initiativeId, initiativeId)),
  ]);

  const slackMessageCount = Number(slackMessageCountResult[0]?.value ?? 0);
  const googleFileCount = Number(googleFileCountResult[0]?.value ?? 0);
  const syncIssueCount = Number(syncIssueCountResult[0]?.value ?? 0);
  const documentExtractCount = Number(documentExtractCountResult[0]?.value ?? 0);
  const trackerSheetRowCount = Array.isArray(latestTrackerRun?.rawSheetJson)
    ? latestTrackerRun.rawSheetJson.length
    : 0;
  const nextOffset = safeLimit
    ? safeOffset + safeLimit
    : null;

  const messageTsSet = new Set(messages.map((message) => message.ts));
  const replies = messages.length
    ? await db.query.slackReplyEvents.findMany({
        where: inArray(
          slackReplyEvents.parentTs,
          messages.map((message) => message.ts),
        ),
        orderBy: [desc(slackReplyEvents.messageAt), desc(slackReplyEvents.createdAt)],
      })
    : [];

  for (const reply of replies) {
    messageTsSet.add(reply.ts);
  }

  const attachments = messageTsSet.size
    ? await db.query.slackFileEvents.findMany({
        where: and(
          eq(slackFileEvents.initiativeId, initiativeId),
          inArray(slackFileEvents.messageTs, Array.from(messageTsSet)),
        ),
      })
    : [];

  const repliesByParent = new Map<string, typeof replies>();
  for (const reply of replies) {
    const current = repliesByParent.get(reply.parentTs) ?? [];
    current.push(reply);
    repliesByParent.set(reply.parentTs, current);
  }

  const attachmentsByMessageTs = new Map<string, typeof attachments>();
  for (const attachment of attachments) {
    const current = attachmentsByMessageTs.get(attachment.messageTs) ?? [];
    current.push(attachment);
    attachmentsByMessageTs.set(attachment.messageTs, current);
  }

  return {
    initiativeId,
    slackMessages: messages.map((message) => ({
      id: message.id,
      channelId: message.channelId,
      channelName: message.channelName,
      ts: message.ts,
      text: message.text,
      userId: message.userId,
      permalink: message.permalink,
      attachments: (attachmentsByMessageTs.get(message.ts) ?? []).map((attachment) => ({
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
      })),
      replyCount: message.replyCount,
      messageAt: message.messageAt?.toISOString() ?? null,
      replies: (repliesByParent.get(message.ts) ?? []).map((reply) => ({
        id: reply.id,
        ts: reply.ts,
        text: reply.text,
        userId: reply.userId,
        messageAt: reply.messageAt?.toISOString() ?? null,
        attachments: (attachmentsByMessageTs.get(reply.ts) ?? []).map((attachment) => ({
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
        })),
      })),
    })),
    googleFiles: files.map((file) => ({
      id: file.id,
      fileId: file.fileId,
      parentFileId: file.parentFileId,
      depth: file.depth,
      crawlPath: file.crawlPath,
      name: file.name,
      mimeType: file.mimeType,
      modifiedTime: file.modifiedTime?.toISOString() ?? null,
      lastModifyingUser: file.lastModifyingUser,
      webViewLink: file.webViewLink,
    })),
    syncIssues: syncIssues.map((issue) => ({
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
    documentExtracts: documentExtracts.map((extract) => ({
      id: extract.id,
      sourceType: extract.sourceType,
      sourceKey: extract.sourceKey,
      sourceId: extract.sourceId,
      parentSourceId: extract.parentSourceId,
      title: extract.title,
      mimeType: extract.mimeType,
      extractor: extract.extractor,
      extractionStatus: extract.extractionStatus,
      summary: extract.summary,
      extractedText: extract.extractedText,
      sourceUpdatedAt: extract.sourceUpdatedAt?.toISOString() ?? null,
      metadata: extract.metadata,
      updatedAt: extract.updatedAt.toISOString(),
    })),
    trackerSheetRows: Array.isArray(latestTrackerRun?.rawSheetJson)
      ? (latestTrackerRun?.rawSheetJson as string[][])
      : [],
    latestTrackerParseRunId: latestTrackerRun?.id ?? null,
    latestObservationId: latestObservation?.id ?? null,
    latestResearchRunId: latestResearchRun?.id ?? null,
    pagination: {
      limit: safeLimit,
      offset: safeOffset,
      counts: {
        slackMessages: slackMessageCount,
        googleFiles: googleFileCount,
        syncIssues: syncIssueCount,
        documentExtracts: documentExtractCount,
        trackerSheetRows: trackerSheetRowCount,
      },
      hasMore: {
        slackMessages: safeLimit ? safeOffset + messages.length < slackMessageCount : false,
        googleFiles: safeLimit ? safeOffset + files.length < googleFileCount : false,
        syncIssues: safeLimit ? safeOffset + syncIssues.length < syncIssueCount : false,
        documentExtracts: safeLimit ? safeOffset + documentExtracts.length < documentExtractCount : false,
      },
      nextOffset:
        safeLimit &&
        (safeOffset + messages.length < slackMessageCount ||
          safeOffset + files.length < googleFileCount ||
          safeOffset + syncIssues.length < syncIssueCount ||
          safeOffset + documentExtracts.length < documentExtractCount)
          ? nextOffset
          : null,
    },
  };
}
