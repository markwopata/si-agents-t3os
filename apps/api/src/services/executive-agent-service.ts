import { getInitiativeById } from "./initiative-service.js";
import { listInitiativeOpinions } from "./agent-service.js";
import { getLatestKpiResearchForInitiative } from "./kpi-research-service.js";
import { getInitiativeRawEvidence } from "./raw-evidence-service.js";
import { getLatestTrackerForInitiative } from "./tracker-service.js";

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

  return {
    initiativeId: initiative.id,
    fetchedAt: new Date().toISOString(),
    summary: {
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
    },
    metadata: {
      people: initiative.people,
      links: initiative.links,
      snapshots: initiative.snapshots,
      annotations: initiative.annotations,
      runConfig: initiative.runConfig,
      knowledgeDocument: initiative.knowledgeDocument,
      sourceRowNumber: initiative.sourceRowNumber,
    },
    insights: {
      latestOpinion,
      opinions: opinionHistory,
      latestKpiResearch,
      latestTracker,
    },
    rawData: rawEvidence,
  };
}
