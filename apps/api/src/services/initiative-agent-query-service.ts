import { and, desc, eq } from "drizzle-orm";
import { db } from "../db/client.js";
import {
  googleSyncRuns,
  kpiResearchRuns,
  slackSyncRuns,
  trackerParseRuns,
} from "../db/schema.js";
import {
  syncGoogleHistoryForInitiative,
  syncSlackHistoryForInitiative,
} from "./history-sync-service.js";
import { extractDocumentsForInitiative } from "./document-extraction-service.js";
import { runEvaluationForInitiative, listInitiativeOpinions } from "./agent-service.js";
import { getInitiativeById, listInitiativeAnnotations } from "./initiative-service.js";
import { getLatestKpiResearchForInitiative } from "./kpi-research-service.js";
import { getInitiativeRawEvidence } from "./raw-evidence-service.js";
import { getInitiativeRunConfig } from "./run-config-service.js";
import { getLatestTrackerForInitiative, parseTrackerForInitiative } from "./tracker-service.js";

type RefreshPolicy = "if_stale" | "always" | "never";
type AgentQueryMode = "raw" | "insights" | "assess" | "full";

interface SourceFreshness {
  configured: boolean;
  lastUpdatedAt: string | null;
  isStale: boolean;
  syncedDuringRequest: boolean;
  reason: "fresh" | "stale" | "missing" | "not_configured" | "forced";
}

function wrapArtifact(input: {
  label: string;
  freshness: "stored" | "fresh";
  generatedAt?: string | null;
  fetchedAt?: string | null;
  data: unknown;
}): Record<string, unknown> {
  return {
    label: input.label,
    freshness: input.freshness,
    generatedAt: input.generatedAt ?? null,
    fetchedAt: input.fetchedAt ?? null,
    data: input.data,
  };
}

function buildFreshnessState(input: {
  configured: boolean;
  lastUpdatedAt: Date | null;
  refreshPolicy: RefreshPolicy;
  staleAfterMinutes: number;
}): SourceFreshness {
  if (!input.configured) {
    return {
      configured: false,
      lastUpdatedAt: input.lastUpdatedAt?.toISOString() ?? null,
      isStale: false,
      syncedDuringRequest: false,
      reason: "not_configured",
    };
  }

  if (!input.lastUpdatedAt) {
    return {
      configured: true,
      lastUpdatedAt: null,
      isStale: true,
      syncedDuringRequest: false,
      reason: "missing",
    };
  }

  if (input.refreshPolicy === "always") {
    return {
      configured: true,
      lastUpdatedAt: input.lastUpdatedAt.toISOString(),
      isStale: true,
      syncedDuringRequest: false,
      reason: "forced",
    };
  }

  const staleThresholdMs = input.staleAfterMinutes * 60 * 1000;
  const isStale = Date.now() - input.lastUpdatedAt.getTime() > staleThresholdMs;

  return {
    configured: true,
    lastUpdatedAt: input.lastUpdatedAt.toISOString(),
    isStale,
    syncedDuringRequest: false,
    reason: isStale ? "stale" : "fresh",
  };
}

async function getLatestCompletedSlackSyncAt(initiativeId: string): Promise<Date | null> {
  const latest = await db.query.slackSyncRuns.findFirst({
    where: and(eq(slackSyncRuns.initiativeId, initiativeId), eq(slackSyncRuns.status, "completed")),
    orderBy: [desc(slackSyncRuns.finishedAt), desc(slackSyncRuns.createdAt)],
  });
  return latest?.finishedAt ?? latest?.createdAt ?? null;
}

async function getLatestCompletedGoogleSyncAt(initiativeId: string): Promise<Date | null> {
  const latest = await db.query.googleSyncRuns.findFirst({
    where: and(eq(googleSyncRuns.initiativeId, initiativeId), eq(googleSyncRuns.status, "completed")),
    orderBy: [desc(googleSyncRuns.finishedAt), desc(googleSyncRuns.createdAt)],
  });
  return latest?.finishedAt ?? latest?.createdAt ?? null;
}

async function getLatestTrackerParseAt(initiativeId: string): Promise<Date | null> {
  const latest = await db.query.trackerParseRuns.findFirst({
    where: eq(trackerParseRuns.initiativeId, initiativeId),
    orderBy: [desc(trackerParseRuns.createdAt)],
  });
  return latest?.createdAt ?? null;
}

async function getLatestKpiResearchAt(initiativeId: string): Promise<Date | null> {
  const latest = await db.query.kpiResearchRuns.findFirst({
    where: eq(kpiResearchRuns.initiativeId, initiativeId),
    orderBy: [desc(kpiResearchRuns.createdAt)],
  });
  return latest?.finishedAt ?? latest?.createdAt ?? null;
}

export async function runInitiativeAgentQuery(input: {
  initiativeId: string;
  requestedByType: "human" | "service_token";
  requestedById: string;
  mode: AgentQueryMode;
  refreshPolicy: RefreshPolicy;
  staleAfterMinutes: number;
  refreshKpis: boolean;
}): Promise<Record<string, unknown>> {
  const requestStartedAt = new Date().toISOString();
  const initiative = await getInitiativeById(input.initiativeId);
  if (!initiative) {
    throw new Error("Initiative not found");
  }

  const hasSlackLinks = initiative.links.some((link) => link.linkType === "channel" && link.url);
  const hasGoogleLinks = initiative.links.some((link) => link.linkType === "folder" && link.url);

  const [lastSlackSyncAt, lastGoogleSyncAt, lastTrackerParseAt, lastKpiResearchAt] = await Promise.all([
    getLatestCompletedSlackSyncAt(initiative.id),
    getLatestCompletedGoogleSyncAt(initiative.id),
    getLatestTrackerParseAt(initiative.id),
    getLatestKpiResearchAt(initiative.id),
  ]);

  const freshness = {
    slack: buildFreshnessState({
      configured: hasSlackLinks,
      lastUpdatedAt: lastSlackSyncAt,
      refreshPolicy: input.refreshPolicy,
      staleAfterMinutes: input.staleAfterMinutes,
    }),
    google: buildFreshnessState({
      configured: hasGoogleLinks,
      lastUpdatedAt: lastGoogleSyncAt,
      refreshPolicy: input.refreshPolicy,
      staleAfterMinutes: input.staleAfterMinutes,
    }),
    tracker: buildFreshnessState({
      configured: hasGoogleLinks,
      lastUpdatedAt: lastTrackerParseAt,
      refreshPolicy: input.refreshPolicy,
      staleAfterMinutes: input.staleAfterMinutes,
    }),
    kpis: buildFreshnessState({
      configured: true,
      lastUpdatedAt: lastKpiResearchAt,
      refreshPolicy: input.refreshPolicy,
      staleAfterMinutes: input.staleAfterMinutes,
    }),
  };

  const shouldSyncEvidence =
    input.refreshPolicy === "always" ||
    (input.refreshPolicy === "if_stale" &&
      (freshness.slack.isStale || freshness.google.isStale || freshness.tracker.isStale));

  if (shouldSyncEvidence) {
    const [slackSync, googleSync] = await Promise.all([
      hasSlackLinks
        ? syncSlackHistoryForInitiative(initiative, {
            reuseWithinMinutes: input.staleAfterMinutes,
            force: input.refreshPolicy === "always",
          })
        : Promise.resolve(null),
      hasGoogleLinks
        ? syncGoogleHistoryForInitiative(initiative, {
            reuseWithinMinutes: input.staleAfterMinutes,
            force: input.refreshPolicy === "always",
          })
        : Promise.resolve(null),
    ]);

    if (slackSync?.performedSync || googleSync?.performedSync) {
      await extractDocumentsForInitiative({
        initiativeId: initiative.id,
        slackRunIds: slackSync?.newRunIds ?? [],
        googleRunId: googleSync?.performedSync ? googleSync.runId : null,
      });
    }

    if (hasGoogleLinks && (googleSync?.performedSync || freshness.tracker.isStale || input.refreshPolicy === "always")) {
      await parseTrackerForInitiative(initiative.id, googleSync?.performedSync ? googleSync.runId : undefined);
      freshness.tracker.syncedDuringRequest = true;
      freshness.tracker.lastUpdatedAt = new Date().toISOString();
      freshness.tracker.isStale = false;
      freshness.tracker.reason = "fresh";
    }

    if (slackSync?.performedSync) {
      freshness.slack.syncedDuringRequest = true;
      freshness.slack.lastUpdatedAt = new Date().toISOString();
      freshness.slack.isStale = false;
      freshness.slack.reason = "fresh";
    }
    if (googleSync?.performedSync) {
      freshness.google.syncedDuringRequest = true;
      freshness.google.lastUpdatedAt = new Date().toISOString();
      freshness.google.isStale = false;
      freshness.google.reason = "fresh";
    }
  }

  let assessment: Record<string, unknown> | null = null;
  if (input.mode === "assess" || input.mode === "full") {
    const evaluation = await runEvaluationForInitiative({
      initiativeId: initiative.id,
      requestedByType: input.requestedByType,
      requestedById: input.requestedById,
      refreshKpisBeforeEvaluation: input.refreshKpis,
      hydrateLiveEvidence: false,
    });
    const opinions = await listInitiativeOpinions(initiative.id);
    assessment = opinions.find((opinion) => opinion.id === evaluation.observationId) ?? {
      runId: evaluation.runId,
      observationId: evaluation.observationId,
    };
    if (input.refreshKpis) {
      freshness.kpis.syncedDuringRequest = true;
      freshness.kpis.lastUpdatedAt = new Date().toISOString();
      freshness.kpis.isStale = false;
      freshness.kpis.reason = "fresh";
    }
  }

  const includeRawData = input.mode === "raw" || input.mode === "full";
  const includeInsights = input.mode === "insights" || input.mode === "full";

  const [rawData, latestKpis, latestTracker, annotations, runConfig, opinions] = await Promise.all([
    includeRawData ? getInitiativeRawEvidence(initiative.id) : Promise.resolve(null),
    includeInsights ? getLatestKpiResearchForInitiative(initiative.id) : Promise.resolve(null),
    includeInsights ? getLatestTrackerForInitiative(initiative.id) : Promise.resolve(null),
    includeInsights ? listInitiativeAnnotations(initiative.id) : Promise.resolve([]),
    includeInsights ? getInitiativeRunConfig(initiative.id) : Promise.resolve(null),
    includeInsights ? listInitiativeOpinions(initiative.id) : Promise.resolve([]),
  ]);

  const latestObservation = includeInsights ? (opinions[0] ?? null) : null;
  const latestObservationIsFresh =
    Boolean(assessment) &&
    assessment !== null &&
    latestObservation !== null &&
    typeof assessment.id === "string" &&
    typeof latestObservation.id === "string" &&
    assessment.id === latestObservation.id;
  const latestKpiResearchIsFresh = freshness.kpis.syncedDuringRequest;
  const latestTrackerIsFresh = freshness.tracker.syncedDuringRequest;
  const latestQuarterImpact =
    assessment && typeof assessment === "object" && "upcomingQuarterEarningsImpact" in assessment
      ? (assessment.upcomingQuarterEarningsImpact ?? initiative.upcomingQuarterEarningsImpact ?? null)
      : latestObservation && typeof latestObservation === "object" && "upcomingQuarterEarningsImpact" in latestObservation
        ? (latestObservation.upcomingQuarterEarningsImpact ?? initiative.upcomingQuarterEarningsImpact ?? null)
        : (initiative.upcomingQuarterEarningsImpact ?? null);
  const rawDataFreshness =
    freshness.slack.syncedDuringRequest ||
    freshness.google.syncedDuringRequest ||
    freshness.tracker.syncedDuringRequest
      ? "fresh"
      : "stored";
  const storedInsights = includeInsights
    ? {
        latestObservation,
        latestKpiResearch: latestKpis,
        latestTracker,
        annotations,
        runConfig,
      }
    : null;

  return {
    initiative,
    freshness,
    rawData,
    insights: storedInsights,
    assessment,
    rawDataArtifact: includeRawData
      ? wrapArtifact({
          label:
            rawDataFreshness === "fresh" ? "fresh_raw_evidence" : "stored_raw_evidence",
          freshness: rawDataFreshness,
          fetchedAt: requestStartedAt,
          data: rawData,
        })
      : null,
    insightArtifacts: includeInsights
      ? {
          latestObservation: wrapArtifact({
            label: latestObservationIsFresh
              ? "fresh_latest_observation"
              : "stored_latest_observation",
            freshness: latestObservationIsFresh ? "fresh" : "stored",
            generatedAt:
              latestObservation && typeof latestObservation.createdAt === "string"
                ? latestObservation.createdAt
                : null,
            fetchedAt: requestStartedAt,
            data: latestObservation,
          }),
          latestKpiResearch: wrapArtifact({
            label: latestKpiResearchIsFresh
              ? "fresh_kpi_analysis"
              : "stored_kpi_research",
            freshness: latestKpiResearchIsFresh ? "fresh" : "stored",
            generatedAt:
              latestKpis && typeof latestKpis.researchedAt === "string"
                ? latestKpis.researchedAt
                : null,
            fetchedAt: requestStartedAt,
            data: latestKpis,
          }),
          upcomingQuarterEarningsImpact: wrapArtifact({
            label:
              latestObservationIsFresh || latestKpiResearchIsFresh
                ? "fresh_upcoming_quarter_earnings_impact"
                : "stored_upcoming_quarter_earnings_impact",
            freshness:
              latestObservationIsFresh || latestKpiResearchIsFresh ? "fresh" : "stored",
            generatedAt:
              typeof latestObservation?.createdAt === "string"
                ? latestObservation.createdAt
                : requestStartedAt,
            fetchedAt: requestStartedAt,
            data: latestQuarterImpact,
          }),
          latestTracker: wrapArtifact({
            label: latestTrackerIsFresh ? "fresh_tracker_summary" : "stored_tracker_summary",
            freshness: latestTrackerIsFresh ? "fresh" : "stored",
            generatedAt:
              latestTracker && typeof latestTracker.parsedAt === "string"
                ? latestTracker.parsedAt
                : null,
            fetchedAt: requestStartedAt,
            data: latestTracker,
          }),
          annotations: wrapArtifact({
            label: "stored_annotations",
            freshness: "stored",
            fetchedAt: requestStartedAt,
            data: annotations,
          }),
          runConfig: wrapArtifact({
            label: "stored_run_config",
            freshness: "stored",
            fetchedAt: requestStartedAt,
            data: runConfig,
          }),
        }
      : null,
    freshAssessment: assessment
      ? wrapArtifact({
          label: "fresh_assessment",
          freshness: "fresh",
          generatedAt:
            typeof assessment.createdAt === "string" ? assessment.createdAt : requestStartedAt,
          fetchedAt: requestStartedAt,
          data: assessment,
        })
      : null,
    storedKpiResearch:
      includeInsights && !latestKpiResearchIsFresh
        ? wrapArtifact({
            label: "stored_kpi_research",
            freshness: "stored",
            generatedAt:
              latestKpis && typeof latestKpis.researchedAt === "string"
                ? latestKpis.researchedAt
                : null,
            fetchedAt: requestStartedAt,
            data: latestKpis,
          })
        : null,
    freshKpiAnalysis:
      includeInsights && latestKpiResearchIsFresh
        ? wrapArtifact({
            label: "fresh_kpi_analysis",
            freshness: "fresh",
            generatedAt:
              latestKpis && typeof latestKpis.researchedAt === "string"
                ? latestKpis.researchedAt
                : requestStartedAt,
            fetchedAt: requestStartedAt,
            data: latestKpis,
          })
        : null,
    storedRawEvidence:
      includeRawData && rawDataFreshness === "stored"
        ? wrapArtifact({
            label: "stored_raw_evidence",
            freshness: "stored",
            fetchedAt: requestStartedAt,
            data: rawData,
          })
        : null,
    freshRawEvidence:
      includeRawData && rawDataFreshness === "fresh"
        ? wrapArtifact({
            label: "fresh_raw_evidence",
            freshness: "fresh",
            fetchedAt: requestStartedAt,
            data: rawData,
          })
        : null,
  };
}
