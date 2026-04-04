import {
  type InitiativeDetail,
  type InitiativeSummary,
  statusRecommendationEnum,
} from "@si/domain";

export interface EvidenceReference {
  sourceType:
    | "initiative_record"
    | "knowledge_document"
    | "slack"
    | "google_drive"
    | "initiative_tracker"
    | "kpi_research"
    | "manual";
  sourceId: string;
  title: string;
  excerpt: string;
  url?: string;
  metadata?: Record<string, unknown>;
}

export interface SlackEvidenceMessage {
  channelId: string;
  channelName: string | null;
  label: string;
  url: string;
  ts: string;
  userId: string | null;
  text: string;
  permalink: string | null;
  replyCount: number;
  replies: Array<{
    ts: string;
    userId: string | null;
    text: string;
  }>;
}

export interface SlackEvidenceInput {
  connected: boolean;
  unreadableChannels: string[];
  messages: SlackEvidenceMessage[];
}

export interface GoogleEvidenceRevision {
  id: string;
  modifiedTime: string | null;
  lastModifyingUser: string | null;
}

export interface GoogleEvidenceChildFile {
  id: string;
  name: string;
  mimeType: string | null;
  modifiedTime: string | null;
  lastModifyingUser: string | null;
  webViewLink: string | null;
  revisions: GoogleEvidenceRevision[];
}

export interface GoogleEvidenceFile {
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
  revisions: GoogleEvidenceRevision[];
  children: GoogleEvidenceChildFile[];
}

export interface GoogleEvidenceInput {
  connected: boolean;
  files: GoogleEvidenceFile[];
}

export interface TrackerSummaryFieldInput {
  fieldKey: string;
  label: string;
  value: string;
}

export interface TrackerRowItemInput {
  rowNumber: number;
  itemType: string | null;
  description: string;
  prioritization: string | null;
  phase: string | null;
  impactPotential: string | null;
  impactValue: string | null;
  confidence: string | null;
  currentValueEstimate: string | null;
  status: string | null;
  notes: string | null;
  lastEdited: string | null;
  submittedBy: string | null;
}

export interface TrackerEvidenceInput {
  connected: boolean;
  trackerFileId: string | null;
  trackerName: string | null;
  parsedAt: string | null;
  summary: Record<string, unknown>;
  summaryFields: TrackerSummaryFieldInput[];
  items: TrackerRowItemInput[];
}

export interface KpiEvidenceFindingInput {
  id: string;
  findingClass: string;
  sourceType: string;
  metricKey: string;
  label: string;
  metricValue: string | null;
  unit: string | null;
  narrative: string;
  sourceRef: string;
  provenance?: Record<string, unknown>;
}

export interface KpiEvidenceInput {
  latestResearchRunId: string | null;
  researchedAt: string | null;
  summary: Record<string, unknown>;
  findings: KpiEvidenceFindingInput[];
}

export interface UpcomingQuarterEarningsImpact {
  quarterLabel: string;
  periodEnd: string;
  applicable: boolean;
  estimateType: "range" | "directional" | "insufficient_evidence";
  lowEstimate: number | null;
  highEstimate: number | null;
  direction: "positive" | "negative" | "neutral" | "mixed" | "unknown";
  confidence: number;
  rationale: string;
}

export interface EvaluationInput {
  initiative: InitiativeDetail;
  globalKnowledge: string;
  slackEvidence: SlackEvidenceInput;
  googleEvidence: GoogleEvidenceInput;
  trackerEvidence: TrackerEvidenceInput;
  kpiEvidence?: KpiEvidenceInput;
  runConfig?: InitiativeDetail["runConfig"];
}

export interface EvaluationResult {
  statusRecommendation: (typeof statusRecommendationEnum)["_type"];
  progressAssessment: string;
  confidenceScore: number;
  topBlockers: string[];
  suggestedNextActions: string[];
  evidenceSummary: string;
  upcomingQuarterEarningsImpact: UpcomingQuarterEarningsImpact;
  evidenceReferences: EvidenceReference[];
}

const UPCOMING_QUARTER_LABEL = "Q2 FY26";
const UPCOMING_QUARTER_PERIOD_END = "2026-06-30";

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}

function daysSince(timestamp: string | null): number | null {
  if (!timestamp) {
    return null;
  }

  const parsed = Date.parse(timestamp);
  if (Number.isNaN(parsed)) {
    return null;
  }

  return (Date.now() - parsed) / (1000 * 60 * 60 * 24);
}

function daysSinceSlackTs(timestamp: string | null): number | null {
  if (!timestamp) {
    return null;
  }

  const seconds = Number(timestamp.split(".")[0]);
  if (!Number.isFinite(seconds)) {
    return null;
  }

  return daysSince(new Date(seconds * 1000).toISOString());
}

function countMatches(values: string[], pattern: RegExp): number {
  let total = 0;
  for (const value of values) {
    const matches = value.match(pattern);
    total += matches?.length ?? 0;
  }
  return total;
}

function parseCurrencyLike(value: string | null | undefined): number | null {
  if (!value) {
    return null;
  }

  const normalized = value.replace(/[$,%\s,]/g, "");
  const match = normalized.match(/-?\d+(\.\d+)?/);
  if (!match) {
    return null;
  }

  const parsed = Number(match[0]);
  return Number.isFinite(parsed) ? parsed : null;
}

function roundUsd(value: number): number {
  return Math.round(value);
}

function deriveUpcomingQuarterEarningsImpact(input: {
  initiative: InitiativeDetail;
  trackerEvidence: TrackerEvidenceInput;
  kpiEvidence: KpiEvidenceInput;
  blockers: string[];
  score: number;
}): UpcomingQuarterEarningsImpact {
  const initiativeText = [
    input.initiative.code,
    input.initiative.title,
    input.initiative.objective,
    input.initiative.group,
    input.initiative.impactType,
    input.initiative.progress,
  ]
    .join(" ")
    .toLowerCase();

  const earningsCuePattern =
    /(earnings|profit|margin|ebitda|ebit|gross profit|revenue|sales|used sales|volume|turns|rental|savings|cost|booked|pricing|yield)/i;
  const positiveCuePattern =
    /(increase|grow|improve|lift|gain|savings|reduce cost|margin|profit|revenue|booked|used sales)/i;
  const negativeCuePattern = /(decline|drop|erosion|loss|risk|blocker|delay|cost increase|headwind)/i;

  const monetaryCandidates = [
    ...input.trackerEvidence.summaryFields.map((field) => parseCurrencyLike(field.value)),
    ...input.trackerEvidence.items.flatMap((item) => [
      parseCurrencyLike(item.currentValueEstimate),
      parseCurrencyLike(item.impactValue),
    ]),
    ...input.kpiEvidence.findings.flatMap((finding) => [
      finding.unit === "usd" ? parseCurrencyLike(finding.metricValue) : null,
      parseCurrencyLike(finding.metricValue && finding.metricValue.includes("$") ? finding.metricValue : null),
    ]),
  ]
    .filter((value): value is number => value !== null)
    .map((value) => Math.abs(value))
    .filter((value) => value > 0);

  const sortedMonetaryCandidates = [...monetaryCandidates].sort((left, right) => right - left);
  const topCandidate = sortedMonetaryCandidates[0] ?? null;
  const floorCandidate =
    sortedMonetaryCandidates.length > 1
      ? sortedMonetaryCandidates[sortedMonetaryCandidates.length - 1]
      : topCandidate !== null
        ? topCandidate * 0.5
        : null;

  const kpiBacked =
    input.kpiEvidence.findings.some((finding) => finding.findingClass === "warehouse_validated") ||
    input.kpiEvidence.findings.some((finding) => finding.unit === "usd");
  const hasApplicableSignals =
    earningsCuePattern.test(initiativeText) ||
    topCandidate !== null ||
    input.kpiEvidence.findings.some((finding) =>
      earningsCuePattern.test(`${finding.label} ${finding.metricKey} ${finding.narrative}`),
    );

  const direction =
    positiveCuePattern.test(initiativeText) && negativeCuePattern.test(input.blockers.join(" "))
      ? "mixed"
      : positiveCuePattern.test(initiativeText)
        ? "positive"
        : negativeCuePattern.test(`${initiativeText} ${input.blockers.join(" ")}`)
          ? "negative"
          : topCandidate !== null
            ? "positive"
            : hasApplicableSignals
              ? "mixed"
              : "unknown";

  if (!hasApplicableSignals) {
    return {
      quarterLabel: UPCOMING_QUARTER_LABEL,
      periodEnd: UPCOMING_QUARTER_PERIOD_END,
      applicable: false,
      estimateType: "insufficient_evidence",
      lowEstimate: null,
      highEstimate: null,
      direction: "unknown",
      confidence: 0.2,
      rationale:
        "Current evidence does not provide enough measurable SI detail, KPI support, or current operating proof to support a credible Q2 FY26 earnings-impact estimate yet, and that should be treated as the initiative running behind on executive readiness.",
    };
  }

  if (topCandidate !== null) {
    const lowEstimate = Math.min(topCandidate, floorCandidate ?? topCandidate * 0.5);
    const highEstimate = Math.max(topCandidate, floorCandidate ?? topCandidate);
    const confidence = clamp(
      (kpiBacked ? 0.68 : 0.52) + Math.min(input.kpiEvidence.findings.length, 6) * 0.03 + (input.score >= 0.52 ? 0.05 : 0),
      0.18,
      0.9,
    );
    return {
      quarterLabel: UPCOMING_QUARTER_LABEL,
      periodEnd: UPCOMING_QUARTER_PERIOD_END,
      applicable: true,
      estimateType: "range",
      lowEstimate: roundUsd(lowEstimate),
      highEstimate: roundUsd(highEstimate),
      direction: direction === "unknown" ? "positive" : direction,
      confidence: Number(confidence.toFixed(2)),
      rationale:
        "Tracker and KPI evidence include dollar-linked signals that support a directional Q2 FY26 earnings estimate, but the range should still be treated as an operating estimate rather than booked financial guidance.",
    };
  }

  return {
    quarterLabel: UPCOMING_QUARTER_LABEL,
    periodEnd: UPCOMING_QUARTER_PERIOD_END,
    applicable: true,
    estimateType: "directional",
    lowEstimate: null,
    highEstimate: null,
    direction,
    confidence: Number(clamp(0.35 + Math.min(input.kpiEvidence.findings.length, 5) * 0.05, 0.2, 0.7).toFixed(2)),
    rationale:
      "The initiative appears likely to influence Q2 FY26 earnings directionally, but the current KPI and tracker evidence is not strong enough to support a numeric range with confidence.",
  };
}

function summarizeHealth(summary: InitiativeSummary | InitiativeDetail): string[] {
  const notes: string[] = [];

  if (!summary.targetCadence || summary.targetCadence === "No Cadence") {
    notes.push("initiative does not have a working cadence");
  }

  return notes;
}

export function evaluateInitiative(input: EvaluationInput): EvaluationResult {
  const { initiative, globalKnowledge, slackEvidence, googleEvidence, trackerEvidence, runConfig } = input;
  const kpiEvidence = input.kpiEvidence ?? {
    latestResearchRunId: null,
    researchedAt: null,
    summary: {},
    findings: [],
  };
  const thresholds = runConfig?.alertThresholds;
  const evidenceReferences: EvidenceReference[] = [];
  const blockers = summarizeHealth(initiative);

  let score = 0.45;

  const triadRoles = new Set(initiative.people.map((person) => person.role));
  const triadComplete =
    triadRoles.has("sales_lead") &&
    triadRoles.has("ops_lead") &&
    triadRoles.has("analytics_lead");

  if (!triadComplete) {
    blockers.push("triad ownership appears incomplete");
    score -= 0.18;
  } else {
    score += 0.12;
  }

  const hasChannel = initiative.links.some((link) => link.linkType === "channel" && link.url);
  const hasFolder = initiative.links.some((link) => link.linkType === "folder" && link.url);
  if (!hasChannel) {
    blockers.push("no Slack channel link is mapped");
    score -= 0.12;
  }
  if (!hasFolder) {
    blockers.push("no Drive folder link is mapped");
    score -= 0.1;
  }

  if (!initiative.knowledgeDocument?.content.trim()) {
    blockers.push("initiative-specific notes are still empty");
    score -= 0.03;
  } else {
    score += 0.03;
  }

  if (runConfig?.customInstructionsMarkdown.trim()) {
    score += 0.03;
  }

  if (runConfig?.goodLooksLikeMarkdown.trim()) {
    score += 0.02;
  }
  if (runConfig?.customKpiRulesMarkdown.trim()) {
    score += 0.02;
  }

  const slackMessageAges = slackEvidence.messages
    .map((message) => daysSinceSlackTs(message.ts))
    .filter((value): value is number => value !== null);
  const latestSlackAge = slackMessageAges.length > 0 ? Math.min(...slackMessageAges) : null;
  const recentSlackMessages = slackMessageAges.filter((ageDays) => ageDays <= 30).length;
  const recentSlackMessages90 = slackMessageAges.filter((ageDays) => ageDays <= 90).length;

  if (slackEvidence.unreadableChannels.length > 0) {
    blockers.push(`Slack channel read failed for ${slackEvidence.unreadableChannels.join(", ")}`);
    score -= 0.15;
  } else if (hasChannel) {
    if (!slackEvidence.connected) {
      blockers.push("Slack is not connected, so working-channel activity could not be verified");
      score -= 0.08;
    } else if (slackEvidence.messages.length === 0) {
      blockers.push("linked Slack channel does not show readable message history");
      score -= 0.15;
    } else {
      if (recentSlackMessages >= 5) {
        score += 0.18;
      } else if (recentSlackMessages >= 1) {
        score += 0.11;
      } else if (recentSlackMessages90 >= 1) {
        score += 0.04;
      }

      if (latestSlackAge !== null && latestSlackAge > 365) {
        blockers.push(`no visible Slack message activity in roughly ${Math.round(latestSlackAge)} days`);
        score -= 0.2;
      } else if (latestSlackAge !== null && latestSlackAge > 120) {
        blockers.push(`Slack activity looks stale, with no visible messages in roughly ${Math.round(latestSlackAge)} days`);
        score -= 0.12;
      } else if (latestSlackAge !== null && latestSlackAge > 45) {
        blockers.push(`Slack activity has cooled off, with no visible messages in roughly ${Math.round(latestSlackAge)} days`);
        score -= 0.05;
      }
    }
  }

  const readableGoogleFiles = googleEvidence.files.filter((file) => file.readable);
  const unreadableGoogleFiles = googleEvidence.files.filter((file) => !file.readable);
  const googleDocuments = readableGoogleFiles.flatMap((file) => [file, ...file.children]);
  const recentGoogleDocument = googleDocuments.find((fileLike) => {
    const ageDays = daysSince(fileLike.modifiedTime);
    return ageDays !== null && ageDays <= 30;
  });
  const staleGoogleDocument = googleDocuments
    .map((fileLike) => ({
      fileLike,
      ageDays: daysSince(fileLike.modifiedTime),
    }))
    .filter((entry): entry is { fileLike: (typeof googleDocuments)[number]; ageDays: number } => entry.ageDays !== null)
    .sort((left, right) => right.ageDays - left.ageDays)[0];
  const googleDocumentAges = googleDocuments
    .map((fileLike) => daysSince(fileLike.modifiedTime))
    .filter((value): value is number => value !== null);
  const latestDriveAge = googleDocumentAges.length > 0 ? Math.min(...googleDocumentAges) : null;
  const recentDriveUpdates = googleDocumentAges.filter((ageDays) => ageDays <= 30).length;
  const recentDriveUpdates90 = googleDocumentAges.filter((ageDays) => ageDays <= 90).length;

  if (hasFolder) {
    if (!googleEvidence.connected) {
      blockers.push("Google Drive is not connected, so artifact activity could not be verified");
      score -= 0.08;
    } else if (readableGoogleFiles.length === 0) {
      blockers.push("linked Drive artifacts could not be read");
      score -= 0.12;
    } else {
      score += 0.05;

      if (recentDriveUpdates >= 4) {
        score += 0.12;
      } else if (recentDriveUpdates >= 1) {
        score += 0.08;
      } else if (recentDriveUpdates90 >= 1) {
        score += 0.03;
      } else {
        blockers.push("linked Drive artifacts do not show a recent update in the last 90 days");
        score -= 0.1;
      }

      if (latestDriveAge !== null && latestDriveAge > 365) {
        blockers.push(`linked Drive artifacts appear dormant for roughly ${Math.round(latestDriveAge)} days`);
        score -= 0.16;
      } else if (latestDriveAge !== null && latestDriveAge > 120) {
        blockers.push(`linked Drive artifacts appear stale for roughly ${Math.round(latestDriveAge)} days`);
        score -= 0.1;
      }

      if (
        readableGoogleFiles.every((file) => file.children.length === 0) &&
        readableGoogleFiles.every((file) => file.revisions.length === 0)
      ) {
        blockers.push("linked Drive folder does not expose current tracker files or revision history");
        score -= 0.05;
      }
    }
  }

  if (unreadableGoogleFiles.length > 0) {
    blockers.push(
      `Google artifact read failed for ${unreadableGoogleFiles.map((file) => file.label || file.url).join(", ")}`,
    );
    score -= 0.08;
  }

  const trackerAgeDays = daysSince(String(trackerEvidence.summary.trackerModifiedTime ?? trackerEvidence.parsedAt ?? ""));
  const trackerBlockedItems = trackerEvidence.items.filter((item) =>
    /(block|risk|delay|hold|stuck)/i.test(`${item.status ?? ""} ${item.notes ?? ""}`),
  );
  const kpiAgeDays = daysSince(kpiEvidence.researchedAt);
  const analyticsFindings = kpiEvidence.findings.filter((finding) =>
    ["analytics_reference", "current_state"].includes(finding.findingClass),
  );
  const proposalFindings = kpiEvidence.findings.filter((finding) => finding.findingClass === "proposal");

  if (trackerEvidence.connected) {
    if (trackerEvidence.items.length > 0 || trackerEvidence.summaryFields.length > 0) {
      score += 0.06;
    }

    if (trackerAgeDays !== null && trackerAgeDays <= 21) {
      score += 0.15;
    } else if (trackerAgeDays !== null && trackerAgeDays <= 45) {
      score += 0.08;
    } else if (trackerAgeDays !== null && trackerAgeDays <= 90) {
      score += 0.01;
    } else if (trackerEvidence.trackerFileId && trackerAgeDays !== null && trackerAgeDays <= 180) {
      blockers.push(`initiative tracker appears stale, with no visible update in roughly ${Math.round(trackerAgeDays)} days`);
      score -= 0.08;
    } else if (trackerEvidence.trackerFileId) {
      blockers.push(`initiative tracker appears dormant, with no visible update in roughly ${Math.round(trackerAgeDays ?? 0)} days`);
      score -= 0.16;
    } else if (trackerEvidence.trackerFileId) {
      blockers.push("initiative tracker appears stale or missing a recent edit");
      score -= 0.08;
    }

    if (trackerEvidence.items.length === 0 && trackerEvidence.trackerFileId) {
      blockers.push("initiative tracker is present but does not contain parsed work items");
      score -= 0.06;
    }
  } else if (hasFolder) {
    blockers.push("no initiative tracker could be parsed from the linked Drive evidence");
    score -= 0.08;
  }

  if (trackerBlockedItems.length > 0) {
    blockers.push(
      ...trackerBlockedItems
        .slice(0, 2)
        .map((item) => `tracker row flagged as blocked: ${item.description.slice(0, 120)}`),
    );
    score -= Math.min(trackerBlockedItems.length * 0.03, 0.12);
  }

  if (kpiEvidence.findings.length > 0) {
    score += 0.04;

    if (analyticsFindings.length > 0) {
      score += 0.03;
    }

    if (proposalFindings.length > 0) {
      score += 0.02;
    }

    if (kpiAgeDays !== null && kpiAgeDays <= 30) {
      score += 0.05;
    } else if (kpiAgeDays !== null && kpiAgeDays <= 90) {
      score += 0.02;
    } else if (kpiAgeDays !== null && kpiAgeDays > 180) {
      blockers.push(`KPI research appears stale, with no refresh in roughly ${Math.round(kpiAgeDays)} days`);
      score -= 0.06;
    }
  } else if (triadRoles.has("analytics_lead")) {
    blockers.push("no KPI research findings are available to validate current progress");
    score -= 0.05;
  }

  const signalCorpus = [
    ...slackEvidence.messages.map((message) => message.text),
    ...slackEvidence.messages.flatMap((message) => message.replies.map((reply) => reply.text)),
    ...trackerEvidence.items.map((item) =>
      [item.description, item.status, item.notes, item.currentValueEstimate, item.impactValue]
        .filter(Boolean)
        .join(" "),
    ),
    ...trackerEvidence.summaryFields.map((field) => `${field.label} ${field.value}`),
    ...kpiEvidence.findings.map((finding) =>
      [finding.label, finding.narrative, finding.metricKey, finding.sourceRef].filter(Boolean).join(" "),
    ),
  ];
  const progressSignals = countMatches(
    signalCorpus,
    /\b(resolved|complete(?:d)?|launched|implemented|signed|booked|collected|delivered|finished|executed|live|closed|shipped|deployed|rolled out)\b/gi,
  );
  const blockerSignals = countMatches(
    signalCorpus,
    /\b(blocked|stuck|delay(?:ed)?|waiting|hold|risk|issue|escalat(?:e|ed|ion)|dependency|pending|roadblock)\b/gi,
  );

  if (progressSignals > 0) {
    score += Math.min(progressSignals * 0.015, 0.12);
  }
  if (blockerSignals > 0) {
    score -= Math.min(blockerSignals * 0.015, 0.14);
  }

  if (thresholds?.maxTrackerStalenessDays !== null && thresholds?.maxTrackerStalenessDays !== undefined && trackerAgeDays !== null) {
    if (trackerAgeDays > thresholds.maxTrackerStalenessDays) {
      blockers.push(
        `tracker exceeded configured staleness threshold of ${thresholds.maxTrackerStalenessDays} days`,
      );
      score -= 0.08;
    }
  }

  if (thresholds?.attentionBlockerCount !== null && thresholds?.attentionBlockerCount !== undefined) {
    if (trackerBlockedItems.length >= thresholds.attentionBlockerCount) {
      blockers.push(
        `tracker blocker count exceeded configured threshold of ${thresholds.attentionBlockerCount}`,
      );
      score -= 0.08;
    }
  }

  if (thresholds?.minimumSlackMessages30d !== null && thresholds?.minimumSlackMessages30d !== undefined) {
    if (recentSlackMessages < thresholds.minimumSlackMessages30d) {
      blockers.push(
        `recent Slack activity is below the configured threshold of ${thresholds.minimumSlackMessages30d} messages in 30 days`,
      );
      score -= 0.06;
    }
  }

  if (thresholds?.minimumDriveUpdates30d !== null && thresholds?.minimumDriveUpdates30d !== undefined) {
    if (recentDriveUpdates < thresholds.minimumDriveUpdates30d) {
      blockers.push(
        `recent Drive updates are below the configured threshold of ${thresholds.minimumDriveUpdates30d} updates in 30 days`,
      );
      score -= 0.06;
    }
  }

  if (thresholds?.minimumOnTrackScore !== null && thresholds?.minimumOnTrackScore !== undefined && score < thresholds.minimumOnTrackScore) {
    blockers.push(
      `composite health score is below the configured on-track threshold of ${Math.round(
        thresholds.minimumOnTrackScore * 100,
      )}%`,
    );
      score -= 0.03;
  }

  const dormantAcrossSystems =
    (latestSlackAge === null || latestSlackAge > 180) &&
    (latestDriveAge === null || latestDriveAge > 120) &&
    (trackerAgeDays === null || trackerAgeDays > 90);
  const deeplyDormant =
    (latestSlackAge === null || latestSlackAge > 365) &&
    (latestDriveAge === null || latestDriveAge > 180) &&
    (trackerAgeDays === null || trackerAgeDays > 180);
  const hasStrongRecentActivity =
    recentSlackMessages > 0 && (recentDriveUpdates > 0 || (trackerAgeDays !== null && trackerAgeDays <= 45));

  const statusRecommendation =
    deeplyDormant
      ? "off_track"
      : dormantAcrossSystems
        ? "stalled"
        : score >= 0.72 && hasStrongRecentActivity
          ? "on_track"
          : score >= 0.52
            ? "needs_attention"
            : score >= 0.34
              ? "stalled"
              : "off_track";

  evidenceReferences.push({
    sourceType: "initiative_record",
    sourceId: initiative.id,
    title: `${initiative.code} ${initiative.title}`,
    excerpt: initiative.objective,
  });

  if (initiative.knowledgeDocument) {
    evidenceReferences.push({
      sourceType: "knowledge_document",
      sourceId: initiative.knowledgeDocument.id,
      title: initiative.knowledgeDocument.title,
      excerpt: initiative.knowledgeDocument.content.slice(0, 240),
    });
  } else {
    evidenceReferences.push({
      sourceType: "manual",
      sourceId: "global-si-operating-model",
      title: "Global SI Operating Model",
      excerpt: globalKnowledge.slice(0, 240),
    });
  }

  if (runConfig) {
    const combinedRunInstructions = [
      runConfig.customInstructionsMarkdown,
      runConfig.goodLooksLikeMarkdown,
      runConfig.customKpiRulesMarkdown,
      runConfig.ownerNotesMarkdown,
    ]
      .filter((value) => value.trim())
      .join("\n\n");

    if (combinedRunInstructions) {
      evidenceReferences.push({
        sourceType: "manual",
        sourceId: runConfig.id,
        title: "SI run config",
        excerpt: combinedRunInstructions.slice(0, 240),
        metadata: {
          cadenceMode: runConfig.cadenceMode,
          updatedAt: runConfig.updatedAt,
        },
      });
    }
  }

  for (const message of slackEvidence.messages.slice(0, 3)) {
    evidenceReferences.push({
      sourceType: "slack",
      sourceId: `${message.channelId}:${message.ts}`,
      title: `Slack ${message.channelName ? `#${message.channelName}` : message.label}`,
      excerpt: message.text,
      url: message.permalink ?? message.url,
      metadata: {
        channelId: message.channelId,
        channelName: message.channelName,
        ts: message.ts,
        replyCount: message.replyCount,
      },
    });
  }

  for (const file of readableGoogleFiles.slice(0, 2)) {
    const childCount = file.children.length;
    const latestChild = [...file.children]
      .filter((child) => child.modifiedTime)
      .sort((left, right) => Date.parse(right.modifiedTime ?? "") - Date.parse(left.modifiedTime ?? ""))[0];

    evidenceReferences.push({
      sourceType: "google_drive",
      sourceId: file.fileId ?? file.linkId,
      title: `Drive ${file.name ?? file.label}`,
      excerpt:
        childCount > 0
          ? `${childCount} tracked files found. Latest visible artifact: ${latestChild?.name ?? "unknown"}`
          : `Last modified ${file.modifiedTime ?? "unknown"} by ${file.lastModifyingUser ?? "unknown user"}.`,
      url: file.webViewLink ?? file.url,
      metadata: {
        modifiedTime: file.modifiedTime,
        lastModifyingUser: file.lastModifyingUser,
        childCount,
        revisionCount: file.revisions.length,
      },
    });
  }

  for (const child of readableGoogleFiles.flatMap((file) => file.children).slice(0, 2)) {
    evidenceReferences.push({
      sourceType: "google_drive",
      sourceId: child.id,
      title: `Artifact ${child.name}`,
      excerpt: `Last modified ${child.modifiedTime ?? "unknown"} by ${child.lastModifyingUser ?? "unknown user"}.`,
      url: child.webViewLink ?? undefined,
      metadata: {
        modifiedTime: child.modifiedTime,
        lastModifyingUser: child.lastModifyingUser,
        revisionCount: child.revisions.length,
      },
    });
  }

  for (const field of trackerEvidence.summaryFields.slice(0, 3)) {
    evidenceReferences.push({
      sourceType: "initiative_tracker",
      sourceId: `${trackerEvidence.trackerFileId ?? "tracker"}:${field.fieldKey}`,
      title: `Tracker ${field.label}`,
      excerpt: field.value || "No current value entered.",
      metadata: {
        trackerName: trackerEvidence.trackerName,
        parsedAt: trackerEvidence.parsedAt,
      },
    });
  }

  for (const item of trackerEvidence.items.slice(0, 2)) {
    evidenceReferences.push({
      sourceType: "initiative_tracker",
      sourceId: `${trackerEvidence.trackerFileId ?? "tracker"}:row:${item.rowNumber}`,
      title: `Tracker Row ${item.rowNumber}`,
      excerpt: `${item.itemType ?? "Item"}: ${item.description} ${item.status ? `(${item.status})` : ""}`.trim(),
      metadata: {
        notes: item.notes,
        phase: item.phase,
        prioritization: item.prioritization,
        lastEdited: item.lastEdited,
        submittedBy: item.submittedBy,
      },
    });
  }

  for (const finding of kpiEvidence.findings.slice(0, 3)) {
    evidenceReferences.push({
      sourceType: "kpi_research",
      sourceId: finding.id,
      title: `KPI ${finding.label}`,
      excerpt: finding.narrative,
      metadata: {
        findingClass: finding.findingClass,
        sourceType: finding.sourceType,
        metricKey: finding.metricKey,
        metricValue: finding.metricValue,
        unit: finding.unit,
        sourceRef: finding.sourceRef,
        researchedAt: kpiEvidence.researchedAt,
      },
    });
  }

  const baseProgressAssessment =
    statusRecommendation === "on_track"
      ? "The initiative shows credible recent operating activity and progress signals across Slack, Drive, and the tracker, so it appears to be actively moving toward its goal."
      : statusRecommendation === "needs_attention"
        ? "The initiative shows some real activity, but the evidence is mixed. Progress may be happening, yet stale operating artifacts or blocker signals keep the current trajectory uncertain."
        : statusRecommendation === "stalled"
          ? "The initiative does not show enough recent operating activity to believe it is actively progressing. It may still matter, but the working evidence suggests momentum has stalled."
          : "The initiative lacks credible recent operating evidence and should be treated as off track until the team re-establishes active work, current artifacts, and measurable progress.";

  const suggestedNextActions = [
    trackerEvidence.trackerFileId
      ? trackerAgeDays !== null && trackerAgeDays <= 30
        ? "Review the latest tracker updates with the initiative lead and verify them against current KPI evidence."
        : "Require the SI triad to refresh the initiative tracker and the top priority rows before the next review."
      : "Require the SI team to create or relink the working tracker so blockers, priorities, and KPI progress are visible.",
    kpiEvidence.findings.length > 0
      ? kpiAgeDays !== null && kpiAgeDays <= 30
        ? "Validate the KPI research findings against the latest operator narrative and update any weak metric mappings."
        : "Refresh KPI research so the initiative has current analytics references and measurable progress evidence."
      : "Build or refresh KPI research so the initiative has concrete analytics references instead of qualitative-only updates.",
    hasChannel
      ? "Review the linked Slack channel for the latest blocker resolution activity and capture decisions back into the SI record."
      : "Add the correct SI Slack channel mapping before the next review cycle.",
    hasFolder
      ? recentDriveUpdates > 0
        ? "Confirm the latest Drive artifacts still match the KPI story and the decisions captured in Slack."
        : staleGoogleDocument
          ? `Have the SI triad refresh the Drive tracker and core artifacts, which appear stale by roughly ${Math.round(staleGoogleDocument.ageDays)} days.`
          : "Confirm the linked Drive folder contains current working artifacts."
      : "Add the SI working folder so the team has a canonical evidence location.",
  ];

  const upcomingQuarterEarningsImpact = deriveUpcomingQuarterEarningsImpact({
    initiative,
    trackerEvidence,
    kpiEvidence,
    blockers,
    score,
  });

  const quarterImpactSentence =
    !upcomingQuarterEarningsImpact.applicable
      ? `For ${upcomingQuarterEarningsImpact.quarterLabel}, there is not enough measurable detail yet to support a credible earnings-impact estimate, and that should be treated as the SI running behind on executive readiness.`
      : upcomingQuarterEarningsImpact.estimateType === "range"
        ? `For ${upcomingQuarterEarningsImpact.quarterLabel}, the initiative is currently estimated to have a ${upcomingQuarterEarningsImpact.direction} earnings impact in the range of $${upcomingQuarterEarningsImpact.lowEstimate?.toLocaleString() ?? "0"} to $${upcomingQuarterEarningsImpact.highEstimate?.toLocaleString() ?? "0"}, at ${Math.round(upcomingQuarterEarningsImpact.confidence * 100)}% confidence.`
        : `For ${upcomingQuarterEarningsImpact.quarterLabel}, the initiative currently points to a ${upcomingQuarterEarningsImpact.direction} directional earnings impact at ${Math.round(upcomingQuarterEarningsImpact.confidence * 100)}% confidence.`;

  const progressAssessment = `${baseProgressAssessment} ${quarterImpactSentence}`.trim();

  return {
    statusRecommendation,
    progressAssessment,
    confidenceScore: clamp(Number(score.toFixed(2)), 0.05, 0.99),
    topBlockers: blockers.slice(0, 5),
    suggestedNextActions,
    evidenceSummary: [
      `Status score: ${score.toFixed(2)}`,
      `Slack activity: ${recentSlackMessages} messages in 30d${latestSlackAge !== null ? `; latest visible activity ${Math.round(latestSlackAge)}d ago` : ""}`,
      `Drive activity: ${recentDriveUpdates} updates in 30d${latestDriveAge !== null ? `; latest visible artifact update ${Math.round(latestDriveAge)}d ago` : ""}`,
      `Tracker activity: ${
        trackerAgeDays !== null
          ? `last visible edit ${Math.round(trackerAgeDays)}d ago with ${trackerEvidence.items.length} parsed rows`
          : "tracker recency unknown"
      }`,
      `KPI research: ${
        kpiEvidence.findings.length > 0
          ? `${kpiEvidence.findings.length} findings${kpiAgeDays !== null ? `; latest refresh ${Math.round(kpiAgeDays)}d ago` : ""}`
          : "no current KPI findings"
      }`,
      `Signals: ${progressSignals} progress, ${blockerSignals} blocker`,
      `Health flags: ${blockers.length > 0 ? blockers.join("; ") : "none"}`,
      `Run config: ${
        runConfig
          ? `${runConfig.cadenceMode}${runConfig.cadenceDetail ? ` (${runConfig.cadenceDetail})` : ""}`
          : "default"
      }`,
      `Upcoming quarter impact: ${
        upcomingQuarterEarningsImpact.applicable
          ? upcomingQuarterEarningsImpact.estimateType === "range"
            ? `${upcomingQuarterEarningsImpact.direction} $${upcomingQuarterEarningsImpact.lowEstimate?.toLocaleString() ?? "0"} to $${upcomingQuarterEarningsImpact.highEstimate?.toLocaleString() ?? "0"} for ${upcomingQuarterEarningsImpact.quarterLabel}`
            : `${upcomingQuarterEarningsImpact.direction} directional view for ${upcomingQuarterEarningsImpact.quarterLabel}`
          : `not enough measurable detail for ${upcomingQuarterEarningsImpact.quarterLabel}; treat the SI as behind until KPI-backed detail improves`
      }`,
      ...evidenceReferences.map((ref) => `${ref.title}: ${ref.excerpt}`),
    ].join("\n"),
    upcomingQuarterEarningsImpact,
    evidenceReferences,
  };
}
