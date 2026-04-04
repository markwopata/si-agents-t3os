import type {
  ExecutivePortfolioQueryResponse,
  InitiativeSummary,
} from "@si/domain";
import {
  getLatestObservationSummariesForInitiatives,
  listInitiatives,
} from "./initiative-service.js";

type QueryIntent =
  | "best_progress"
  | "needs_attention"
  | "stale"
  | "priority_stack"
  | "portfolio_summary";

function tokenize(question: string): string[] {
  return Array.from(
    new Set(
      question
        .toLowerCase()
        .split(/[^a-z0-9]+/)
        .map((token) => token.trim())
        .filter((token) => token.length >= 2),
    ),
  );
}

function interpretIntent(question: string): QueryIntent {
  const lower = question.toLowerCase();
  const terms = tokenize(question);

  if (
    (terms.includes("best") || terms.includes("top")) &&
    (terms.includes("progress") || terms.includes("progressing") || lower.includes("making best progress"))
  ) {
    return "best_progress";
  }

  if (
    terms.some((term) => ["stalled", "stuck", "risk", "risky", "attention", "off", "track"].includes(term)) ||
    lower.includes("needs attention")
  ) {
    return "needs_attention";
  }

  if (terms.some((term) => ["stale", "old", "outdated", "freshness"].includes(term))) {
    return "stale";
  }

  if (
    terms.some((term) => ["priority", "priorities", "rank", "ranking", "stack"].includes(term))
  ) {
    return "priority_stack";
  }

  return "portfolio_summary";
}

function wantsFullPortfolio(question: string): boolean {
  const lower = question.toLowerCase();
  return (
    lower.includes("all initiatives") ||
    lower.includes("entire portfolio") ||
    lower.includes("full portfolio") ||
    lower.includes("every initiative") ||
    lower.includes("list initiatives") ||
    lower.includes("list all si") ||
    lower.includes("all sis")
  );
}

function daysSince(iso: string | null): number | null {
  if (!iso) {
    return null;
  }
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) {
    return null;
  }
  return Math.floor((Date.now() - date.getTime()) / (1000 * 60 * 60 * 24));
}

function ownershipStatus(initiative: InitiativeSummary): "complete" | "partial" | "missing" {
  if (initiative.hasExecOwner && initiative.hasInitiativeOwner) {
    return "complete";
  }
  if (initiative.hasExecOwner || initiative.hasGroupOwner || initiative.hasInitiativeOwner) {
    return "partial";
  }
  return "missing";
}

function statusScore(status: InitiativeSummary["latestOpinionStatus"]): number {
  switch (status) {
    case "on_track":
      return 4;
    case "needs_attention":
      return 1;
    case "at_risk":
      return 0;
    case "stalled":
      return -1;
    case "off_track":
      return -2;
    default:
      return 0;
  }
}

function progressScore(initiative: InitiativeSummary): number {
  const ownershipBonus =
    ownershipStatus(initiative) === "complete"
      ? 0.4
      : ownershipStatus(initiative) === "partial"
        ? 0.15
        : -0.25;
  const freshnessPenalty = (() => {
    const age = daysSince(initiative.latestObservationAt ?? initiative.updatedAt);
    if (age === null) {
      return -0.2;
    }
    if (age <= 7) {
      return 0.35;
    }
    if (age <= 14) {
      return 0.15;
    }
    if (age <= 30) {
      return -0.05;
    }
    return -0.35;
  })();

  return (
    statusScore(initiative.latestOpinionStatus) +
    (initiative.latestOpinionConfidence ?? 0.45) +
    ownershipBonus +
    freshnessPenalty
  );
}

function hasStoredOpinion(initiative: InitiativeSummary): boolean {
  return Boolean(initiative.latestOpinionStatus || initiative.latestObservationAt);
}

function compareBestProgress(left: InitiativeSummary, right: InitiativeSummary): number {
  const delta = progressScore(right) - progressScore(left);
  if (delta !== 0) {
    return delta;
  }
  return (left.priorityRank ?? Number.MAX_SAFE_INTEGER) - (right.priorityRank ?? Number.MAX_SAFE_INTEGER);
}

function compareNeedsAttention(left: InitiativeSummary, right: InitiativeSummary): number {
  const leftSeverity = statusScore(left.latestOpinionStatus);
  const rightSeverity = statusScore(right.latestOpinionStatus);
  if (leftSeverity !== rightSeverity) {
    return leftSeverity - rightSeverity;
  }
  return (left.priorityRank ?? Number.MAX_SAFE_INTEGER) - (right.priorityRank ?? Number.MAX_SAFE_INTEGER);
}

function compareStaleness(left: InitiativeSummary, right: InitiativeSummary): number {
  return (daysSince(right.latestObservationAt ?? right.updatedAt) ?? -1) -
    (daysSince(left.latestObservationAt ?? left.updatedAt) ?? -1);
}

function buildQuarterImpactRead(
  initiative: InitiativeSummary,
  progressAssessment: string | null,
): string | null {
  const impact = initiative.upcomingQuarterEarningsImpact;
  if (!impact) {
    return null;
  }

  if (!impact.applicable) {
    return `Q2 earnings impact: not enough evidence yet for ${impact.quarterLabel}.`;
  }

  const summary =
    impact.estimateType === "range"
      ? `Q2 earnings impact: ${impact.direction} estimated range of $${impact.lowEstimate?.toLocaleString() ?? "0"} to $${impact.highEstimate?.toLocaleString() ?? "0"} for ${impact.quarterLabel}.`
      : `Q2 earnings impact: ${impact.direction} directional view for ${impact.quarterLabel}.`;

  if (
    progressAssessment &&
    /q2|earnings impact|quarter ending|june 30, 2026|2026-06-30/i.test(progressAssessment)
  ) {
    return summary;
  }

  return `${summary} Confidence ${Math.round(impact.confidence * 100)}%.`;
}

function buildRead(input: {
  initiative: InitiativeSummary;
  progressAssessment: string | null;
}): string {
  const { initiative, progressAssessment } = input;
  const age = daysSince(initiative.latestObservationAt ?? initiative.updatedAt);
  const ownership = ownershipStatus(initiative);

  const readParts = [
    initiative.latestOpinionStatus
      ? `Latest opinion is ${initiative.latestOpinionStatus.replace(/_/g, " ")} at ${Math.round(
          (initiative.latestOpinionConfidence ?? 0) * 100,
        )}% confidence.`
      : "No stored opinion is available yet.",
    ownership === "complete"
      ? "Ownership coverage is complete."
      : ownership === "partial"
        ? "Ownership coverage is partial."
        : "Ownership coverage is missing key roles.",
    age === null ? "Review freshness is unknown." : `Last reviewed ${age}d ago.`,
  ];

  if (progressAssessment) {
    readParts.push(progressAssessment.replace(/\s+/g, " ").trim());
  }

  const quarterImpactRead = buildQuarterImpactRead(initiative, progressAssessment);
  if (quarterImpactRead) {
    readParts.push(quarterImpactRead);
  }

  return readParts.join(" ");
}

function buildSummary(intent: QueryIntent, count: number): string {
  switch (intent) {
    case "best_progress":
      return `These ${count} initiatives show the strongest current mix of favorable status, confidence, ownership coverage, and review freshness.`;
    case "needs_attention":
      return `These ${count} initiatives appear to need the most executive attention based on their latest stored status and portfolio position.`;
    case "stale":
      return `These ${count} initiatives have the stalest review signal and likely need a fresh look before relying on their current readout.`;
    case "priority_stack":
      return `These ${count} initiatives are currently leading the stored portfolio priority stack.`;
    default:
      return `Here is a concise portfolio slice based on the current stored initiative state.`;
  }
}

export async function queryExecutivePortfolio(input: {
  question: string;
  limit: number;
}): Promise<ExecutivePortfolioQueryResponse> {
  const intent = interpretIntent(input.question);
  const allInitiatives = (await listInitiatives()).filter((initiative) => initiative.isActive);
  const effectiveLimit = wantsFullPortfolio(input.question)
    ? Math.max(allInitiatives.length, input.limit)
    : input.limit;

  let selected = allInitiatives;
  switch (intent) {
    case "best_progress":
      selected = [...allInitiatives]
        .sort((left, right) => {
          const leftHasOpinion = hasStoredOpinion(left) ? 1 : 0;
          const rightHasOpinion = hasStoredOpinion(right) ? 1 : 0;
          if (leftHasOpinion !== rightHasOpinion) {
            return rightHasOpinion - leftHasOpinion;
          }
          return compareBestProgress(left, right);
        })
        .slice(0, effectiveLimit);
      break;
    case "needs_attention":
      selected = [...allInitiatives]
        .filter((initiative) =>
          ["needs_attention", "at_risk", "stalled", "off_track"].includes(
            initiative.latestOpinionStatus ?? "",
          ),
        )
        .sort(compareNeedsAttention)
        .slice(0, effectiveLimit);
      break;
    case "stale":
      selected = [...allInitiatives].sort(compareStaleness).slice(0, effectiveLimit);
      break;
    case "priority_stack":
      selected = [...allInitiatives]
        .filter((initiative) => initiative.priorityRank !== null)
        .sort(
          (left, right) =>
            (left.priorityRank ?? Number.MAX_SAFE_INTEGER) -
            (right.priorityRank ?? Number.MAX_SAFE_INTEGER),
        )
        .slice(0, effectiveLimit);
      break;
    default:
      selected = [...allInitiatives]
        .sort(compareBestProgress)
        .slice(0, effectiveLimit);
      break;
  }

  const latestObservationByInitiativeId = await getLatestObservationSummariesForInitiatives(
    selected.map((initiative) => initiative.id),
  );

  const items = selected.map((initiative) => {
    const latestObservation = latestObservationByInitiativeId.get(initiative.id) ?? null;
    return {
      initiativeId: initiative.id,
      code: initiative.code,
      title: initiative.title,
      status: initiative.latestOpinionStatus,
      confidence: initiative.latestOpinionConfidence,
      priorityRank: initiative.priorityRank,
      ownershipStatus: ownershipStatus(initiative),
      lastReviewedAt: initiative.latestObservationAt,
      upcomingQuarterEarningsImpact: initiative.upcomingQuarterEarningsImpact,
      read: buildRead({
        initiative,
        progressAssessment: latestObservation?.progressAssessment ?? null,
      }),
    };
  });

  return {
    question: input.question,
    interpretedIntent: intent,
    generatedAt: new Date().toISOString(),
    summary: buildSummary(intent, items.length),
    returnedCount: items.length,
    totalAvailable: allInitiatives.length,
    items,
  };
}
