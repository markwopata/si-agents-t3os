import type { InitiativeSummary, PrioritySource, StatusRecommendation } from "@si/domain";
import { asc, desc, eq, sql } from "drizzle-orm";
import { db, pool } from "../db/client.js";
import {
  agentObservations,
  googleFileSnapshots,
  googleSyncRuns,
  initiatives,
  slackMessageEvents,
  slackSyncRuns,
  trackerParseRuns,
} from "../db/schema.js";

type InitiativeRow = typeof initiatives.$inferSelect;

type RankingComputation = {
  initiativeId: string;
  score: number;
  reason: string;
};

function asNumber(value: unknown): number {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === "string" && value.trim()) {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : 0;
  }
  return 0;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}

function toDate(value: unknown): Date | null {
  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }
  if (typeof value === "string" && value.trim()) {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }
  return null;
}

function daysSince(value: Date | null, now: Date): number | null {
  if (!value) {
    return null;
  }
  return Math.max(0, Math.round((now.getTime() - value.getTime()) / (1000 * 60 * 60 * 24)));
}

function statusWeight(status: StatusRecommendation | null): number {
  switch (status) {
    case "on_track":
      return 30;
    case "needs_attention":
      return 18;
    case "stalled":
      return 8;
    case "at_risk":
      return 8;
    case "off_track":
      return 3;
    default:
      return 8;
  }
}

function buildReason(parts: string[]): string {
  return parts.filter(Boolean).join(" • ");
}

function firstByInitiative<T extends { initiativeId: string }>(rows: T[]): Map<string, T> {
  const byId = new Map<string, T>();
  for (const row of rows) {
    if (!byId.has(row.initiativeId)) {
      byId.set(row.initiativeId, row);
    }
  }
  return byId;
}

async function getRecentSlackActivity(): Promise<Map<string, { messageCount: number; lastMessageAt: Date | null }>> {
  const result = await pool.query<{
    initiative_id: string;
    message_count: string;
    last_message_at: string | null;
  }>(`
    select initiative_id, count(*)::text as message_count, max(message_at)::text as last_message_at
    from slack_message_events
    where message_at >= now() - interval '30 days'
    group by initiative_id
  `);

  return new Map(
    result.rows.map((row) => [
      row.initiative_id,
      {
        messageCount: Number(row.message_count),
        lastMessageAt: row.last_message_at ? new Date(row.last_message_at) : null,
      },
    ]),
  );
}

async function getRecentGoogleActivity(): Promise<Map<string, { fileCount: number; lastModifiedAt: Date | null }>> {
  const result = await pool.query<{
    initiative_id: string;
    file_count: string;
    last_modified_at: string | null;
  }>(`
    select initiative_id, count(*)::text as file_count, max(modified_time)::text as last_modified_at
    from google_file_snapshots
    where modified_time >= now() - interval '30 days'
    group by initiative_id
  `);

  return new Map(
    result.rows.map((row) => [
      row.initiative_id,
      {
        fileCount: Number(row.file_count),
        lastModifiedAt: row.last_modified_at ? new Date(row.last_modified_at) : null,
      },
    ]),
  );
}

async function computeRankings(): Promise<RankingComputation[]> {
  const now = new Date();
  const [initiativeRows, observationRows, trackerRows, slackRows, googleRows, recentSlack, recentGoogle] =
    await Promise.all([
      db.select().from(initiatives).where(eq(initiatives.isActive, true)),
      db.select().from(agentObservations).orderBy(desc(agentObservations.createdAt)),
      db.select().from(trackerParseRuns).orderBy(desc(trackerParseRuns.createdAt)),
      db.select().from(slackSyncRuns).orderBy(desc(slackSyncRuns.createdAt)),
      db.select().from(googleSyncRuns).orderBy(desc(googleSyncRuns.createdAt)),
      getRecentSlackActivity(),
      getRecentGoogleActivity(),
    ]);

  const latestObservationById = firstByInitiative(observationRows);
  const latestTrackerById = firstByInitiative(trackerRows);
  const latestSlackById = firstByInitiative(slackRows);
  const latestGoogleById = firstByInitiative(googleRows);

  const computations = initiativeRows.map((initiative) => {
    const latestObservation = latestObservationById.get(initiative.id);
    const latestTracker = latestTrackerById.get(initiative.id);
    const latestSlack = latestSlackById.get(initiative.id);
    const latestGoogle = latestGoogleById.get(initiative.id);
    const slackActivity = recentSlack.get(initiative.id) ?? { messageCount: 0, lastMessageAt: null };
    const googleActivity = recentGoogle.get(initiative.id) ?? { fileCount: 0, lastModifiedAt: null };

    const trackerSummary = (latestTracker?.summary ?? {}) as Record<string, unknown>;
    const trackerModifiedAt =
      toDate(trackerSummary.trackerModifiedTime) ?? latestTracker?.createdAt ?? null;
    const trackerAgeDays = daysSince(trackerModifiedAt, now);
    const trackerFreshnessScore =
      trackerAgeDays === null
        ? 0
        : trackerAgeDays <= 7
          ? 18
          : trackerAgeDays <= 21
            ? 12
            : trackerAgeDays <= 45
              ? 7
              : trackerAgeDays <= 90
                ? 3
                : 0;

    const totalItems = asNumber(trackerSummary.totalItems);
    const topPriorityCount = asNumber(trackerSummary.topPriorityCount);
    const blockedItemCount = asNumber(trackerSummary.blockedItemCount);
    const summaryFieldCount = asNumber(trackerSummary.summaryFieldCount);

    const processScore =
      (latestTracker ? 8 : 0) +
      (latestSlack ? 4 : 0) +
      (latestGoogle ? 4 : 0) +
      Math.min(summaryFieldCount * 1.2, 8) +
      Math.min(totalItems, 10) +
      Math.min(topPriorityCount * 1.1, 8);

    const activityScore =
      Math.min(slackActivity.messageCount, 45) * 0.22 +
      Math.min(googleActivity.fileCount, 30) * 0.28;

    const confidenceScore = (latestObservation?.confidenceScore ?? 0) * 14;
    const statusScore = statusWeight(
      (latestObservation?.statusRecommendation as StatusRecommendation | undefined) ?? null,
    );
    const blockerPenalty = Math.min(blockedItemCount * 2.4, 16);

    const noRecentSignals =
      !slackActivity.lastMessageAt &&
      !googleActivity.lastModifiedAt &&
      (trackerAgeDays === null || trackerAgeDays > 60);
    const stalePenalty = noRecentSignals ? 10 : 0;

    const score = clamp(
      statusScore + confidenceScore + trackerFreshnessScore + processScore + activityScore - blockerPenalty - stalePenalty,
      0,
      100,
    );

    const reasonParts = [
      latestObservation
        ? `${latestObservation.statusRecommendation.replace("_", " ")} at ${Math.round(
            latestObservation.confidenceScore * 100,
          )}% confidence`
        : "no agent opinion yet",
      trackerAgeDays !== null
        ? `tracker touched ${trackerAgeDays}d ago with ${totalItems} rows`
        : "tracker not parsed yet",
      slackActivity.messageCount > 0
        ? `${slackActivity.messageCount} Slack messages in 30d`
        : "no recent Slack traffic",
      googleActivity.fileCount > 0
        ? `${googleActivity.fileCount} Drive file updates in 30d`
        : "no recent Drive edits",
      blockedItemCount > 0 ? `${blockedItemCount} blocker rows flagged` : "no blocker rows flagged",
    ];

    return {
      initiativeId: initiative.id,
      score: Number(score.toFixed(1)),
      reason: buildReason(reasonParts),
    };
  });

  computations.sort((left, right) => right.score - left.score || left.initiativeId.localeCompare(right.initiativeId));
  return computations;
}

export async function refreshPrioritySignals(): Promise<RankingComputation[]> {
  const computations = await computeRankings();
  const rows = await db.select().from(initiatives);
  const rowById = new Map(rows.map((row) => [row.id, row]));
  const hasExistingRanks = rows.some((row) => row.priorityRank !== null);
  const now = new Date();

  for (const [index, computation] of computations.entries()) {
    const row = rowById.get(computation.initiativeId);
    if (!row) {
      continue;
    }

    await db
      .update(initiatives)
      .set({
        priorityScore: computation.score,
        priorityReason: computation.reason,
        rankingUpdatedAt: now,
        ...(hasExistingRanks
          ? {}
          : {
              priorityRank: index + 1,
              prioritySource: "system",
            }),
      })
      .where(eq(initiatives.id, computation.initiativeId));
  }

  return computations;
}

export async function recomputePriorityRanking(): Promise<InitiativeSummary[]> {
  const computations = await computeRankings();
  const now = new Date();

  for (const [index, computation] of computations.entries()) {
    await db
      .update(initiatives)
      .set({
        priorityRank: index + 1,
        priorityScore: computation.score,
        priorityReason: computation.reason,
        prioritySource: "system",
        rankingUpdatedAt: now,
      })
      .where(eq(initiatives.id, computation.initiativeId));
  }

  const { listInitiatives } = await import("./initiative-service.js");
  return listInitiatives();
}

export async function saveManualPriorityRanking(orderedIds: string[]): Promise<InitiativeSummary[]> {
  const existing = await db
    .select()
    .from(initiatives)
    .where(eq(initiatives.isActive, true))
    .orderBy(sql`${initiatives.priorityRank} is null`, asc(initiatives.priorityRank), initiatives.code);
  const seen = new Set<string>();
  const finalOrder = [...orderedIds.filter((id) => !seen.has(id) && seen.add(id))];

  for (const row of existing) {
    if (!seen.has(row.id)) {
      finalOrder.push(row.id);
      seen.add(row.id);
    }
  }

  const now = new Date();
  for (const [index, initiativeId] of finalOrder.entries()) {
    await db
      .update(initiatives)
      .set({
        priorityRank: index + 1,
        prioritySource: "manual" satisfies PrioritySource,
        rankingUpdatedAt: now,
      })
      .where(eq(initiatives.id, initiativeId));
  }

  const { listInitiatives } = await import("./initiative-service.js");
  return listInitiatives();
}
