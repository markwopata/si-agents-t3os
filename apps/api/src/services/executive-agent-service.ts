import { getInitiativeById } from "./initiative-service.js";
import { listInitiativeOpinions } from "./agent-service.js";
import { getLatestKpiResearchForInitiative } from "./kpi-research-service.js";
import { getInitiativeRawEvidence } from "./raw-evidence-service.js";
import { getLatestTrackerForInitiative } from "./tracker-service.js";

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

export async function getExecutiveInitiativeContext(input: {
  initiativeId: string;
  includeRawEvidence?: boolean;
  rawEvidenceLimit?: number;
  opinionLimit?: number;
}): Promise<Record<string, unknown>> {
  const initiative = await getInitiativeById(input.initiativeId);
  if (!initiative) {
    throw new Error("Initiative not found");
  }

  const [opinions, latestKpiResearch, latestTracker, rawEvidence] = await Promise.all([
    listInitiativeOpinions(initiative.id),
    getLatestKpiResearchForInitiative(initiative.id),
    getLatestTrackerForInitiative(initiative.id),
    input.includeRawEvidence
      ? getInitiativeRawEvidence(initiative.id, input.rawEvidenceLimit ?? 120)
      : Promise.resolve(null),
  ]);

  const opinionHistory =
    input.opinionLimit && input.opinionLimit > 0
      ? opinions.slice(0, input.opinionLimit)
      : opinions;
  const latestOpinion = opinionHistory[0] ?? null;
  const fetchedAt = new Date().toISOString();
  const latestQuarterImpact =
    latestOpinion && typeof latestOpinion === "object" && "upcomingQuarterEarningsImpact" in latestOpinion
      ? (latestOpinion.upcomingQuarterEarningsImpact ?? initiative.upcomingQuarterEarningsImpact ?? null)
      : (initiative.upcomingQuarterEarningsImpact ?? null);

  const summary = {
    id: initiative.id,
    code: initiative.code,
    title: initiative.title,
    objective: initiative.objective,
    group: initiative.group,
    stage: initiative.stage,
    targetCadence: initiative.targetCadence,
    updateType: initiative.updateType,
    impactType: initiative.impactType,
    isActive: initiative.isActive,
    priorityRank: initiative.priorityRank,
    priorityScore: initiative.priorityScore,
    latestOpinionStatus: initiative.latestOpinionStatus,
    latestOpinionConfidence: initiative.latestOpinionConfidence,
    latestObservationAt: initiative.latestObservationAt,
    updatedAt: initiative.updatedAt,
  };
  const metadata = {
    people: initiative.people,
    links: initiative.links,
    snapshots: initiative.snapshots,
    annotations: initiative.annotations,
    runConfig: initiative.runConfig,
    knowledgeDocument: initiative.knowledgeDocument,
    sourceRowNumber: initiative.sourceRowNumber,
  };
  const insights = {
    latestOpinion,
    opinions: opinionHistory,
    latestKpiResearch,
    latestTracker,
  };

  return {
    initiativeId: initiative.id,
    fetchedAt,
    summary,
    metadata,
    insights,
    rawData: rawEvidence,
    storedSummary: wrapArtifact({
      label: "stored_summary",
      freshness: "stored",
      generatedAt: initiative.updatedAt,
      fetchedAt,
      data: summary,
    }),
    storedMetadata: wrapArtifact({
      label: "stored_metadata",
      freshness: "stored",
      generatedAt: initiative.updatedAt,
      fetchedAt,
      data: metadata,
    }),
    insightArtifacts: {
      latestOpinion: wrapArtifact({
        label: "stored_latest_opinion",
        freshness: "stored",
        generatedAt:
          typeof latestOpinion?.createdAt === "string" ? latestOpinion.createdAt : null,
        fetchedAt,
        data: latestOpinion,
      }),
      opinionHistory: wrapArtifact({
        label: "stored_opinion_history",
        freshness: "stored",
        generatedAt:
          typeof latestOpinion?.createdAt === "string" ? latestOpinion.createdAt : null,
        fetchedAt,
        data: opinionHistory,
      }),
      latestKpiResearch: wrapArtifact({
        label: "stored_kpi_research",
        freshness: "stored",
        generatedAt:
          latestKpiResearch && typeof latestKpiResearch.researchedAt === "string"
            ? latestKpiResearch.researchedAt
            : null,
        fetchedAt,
        data: latestKpiResearch,
      }),
      upcomingQuarterEarningsImpact: wrapArtifact({
        label: "stored_upcoming_quarter_earnings_impact",
        freshness: "stored",
        generatedAt:
          typeof latestOpinion?.createdAt === "string" ? latestOpinion.createdAt : initiative.updatedAt,
        fetchedAt,
        data: latestQuarterImpact,
      }),
      latestTracker: wrapArtifact({
        label: "stored_tracker_summary",
        freshness: "stored",
        generatedAt:
          latestTracker && typeof latestTracker.parsedAt === "string"
            ? latestTracker.parsedAt
            : null,
        fetchedAt,
        data: latestTracker,
      }),
    },
    storedRawData: rawEvidence
      ? wrapArtifact({
          label: "stored_raw_evidence",
          freshness: "stored",
          fetchedAt,
        data: rawEvidence,
      })
      : null,
    storedKpiResearch: wrapArtifact({
      label: "stored_kpi_research",
      freshness: "stored",
      generatedAt:
        latestKpiResearch && typeof latestKpiResearch.researchedAt === "string"
          ? latestKpiResearch.researchedAt
          : null,
      fetchedAt,
      data: latestKpiResearch,
    }),
    storedRawEvidence: rawEvidence
      ? wrapArtifact({
          label: "stored_raw_evidence",
          freshness: "stored",
          fetchedAt,
          data: rawEvidence,
        })
      : null,
  };
}
