import type { InitiativeAskResponse } from "@si/domain";
import { desc, eq } from "drizzle-orm";
import { db } from "../db/client.js";
import { agentObservations, kpiFindings } from "../db/schema.js";
import { summarizeDocumentExtractsForInitiative } from "./document-extraction-service.js";
import { getInitiativeById } from "./initiative-service.js";
import { getLatestTrackerForInitiative } from "./tracker-service.js";
import { getInitiativeRawEvidence } from "./raw-evidence-service.js";

type EvidenceItem = InitiativeAskResponse["evidence"][number];

function tokenize(question: string): string[] {
  return Array.from(
    new Set(
      question
        .toLowerCase()
        .split(/[^a-z0-9]+/)
        .map((token) => token.trim())
        .filter((token) => token.length >= 3),
    ),
  );
}

function truncate(text: string, limit = 220): string {
  const compact = text.replace(/\s+/g, " ").trim();
  return compact.length <= limit ? compact : `${compact.slice(0, limit - 1)}…`;
}

export async function askInitiativeQuestion(input: {
  initiativeId: string;
  question: string;
  includeRawEvidence?: boolean;
}): Promise<InitiativeAskResponse> {
  const initiative = await getInitiativeById(input.initiativeId);
  if (!initiative) {
    throw new Error("Initiative not found");
  }

  const [tracker, latestObservation, findings, rawEvidence, documentSummary] = await Promise.all([
    getLatestTrackerForInitiative(input.initiativeId),
    db.query.agentObservations.findFirst({
      where: eq(agentObservations.initiativeId, input.initiativeId),
      orderBy: [desc(agentObservations.createdAt)],
    }),
    db.query.kpiFindings.findMany({
      where: eq(kpiFindings.initiativeId, input.initiativeId),
      orderBy: [desc(kpiFindings.createdAt)],
      limit: 18,
    }),
    getInitiativeRawEvidence(input.initiativeId, input.includeRawEvidence ? 60 : 15),
    summarizeDocumentExtractsForInitiative(input.initiativeId, 6),
  ]);

  const terms = tokenize(input.question);
  const evidence: EvidenceItem[] = [];
  const answerParts: string[] = [];
  const followUps: string[] = [];
  let confidence = 0.6;

  if (latestObservation) {
    answerParts.push(
      `Latest stored opinion is ${latestObservation.statusRecommendation.replace(/_/g, " ")} with ${Math.round(
        latestObservation.confidenceScore * 100,
      )}% confidence.`,
    );
    evidence.push({
      sourceType: "latest_observation",
      title: "Latest agent opinion",
      excerpt: truncate(latestObservation.progressAssessment),
      metadata: {
        observationId: latestObservation.id,
        createdAt: latestObservation.createdAt.toISOString(),
      },
    });
    confidence += 0.12;
  } else {
    answerParts.push("There is no stored agent opinion yet for this SI.");
    followUps.push("Run a fresh evaluation before relying on this answer.");
    confidence -= 0.15;
  }

  if (initiative.people.length > 0 && terms.some((term) => ["owner", "owners", "ownership", "lead", "leads"].includes(term))) {
    const owners = initiative.people
      .map((person) => `${person.role.replace(/_/g, " ")}: ${person.displayName}`)
      .slice(0, 6);
    answerParts.push(`Current mapped ownership is ${owners.join("; ")}.`);
    confidence += 0.08;
  }

  if (terms.some((term) => ["blocker", "blockers", "risk", "risks", "stuck"].includes(term))) {
    const trackerBlockers = tracker.items
      .filter((item) => /(block|risk|delay|hold|stuck)/i.test(`${item.status ?? ""} ${item.notes ?? ""}`))
      .slice(0, 3)
      .map((item) => truncate(`${item.description} (${item.status ?? "no status"})`));
    const observationBlockers = latestObservation?.topBlockers.slice(0, 3) ?? [];
    const blockers = [...observationBlockers, ...trackerBlockers].slice(0, 5);
    answerParts.push(
      blockers.length > 0
        ? `The strongest blocker signals are: ${blockers.join("; ")}.`
        : "I do not see explicit blockers in the latest opinion or parsed tracker rows.",
    );
    confidence += blockers.length > 0 ? 0.08 : -0.04;
  }

  if (terms.some((term) => ["kpi", "kpis", "metric", "metrics", "measure"].includes(term))) {
    const currentFindings = findings
      .filter((finding) => finding.findingClass !== "proposal")
      .slice(0, 4)
      .map((finding) => `${finding.label}${finding.metricValue ? ` = ${finding.metricValue}` : ""}`);
    const proposalFindings = findings
      .filter((finding) => finding.findingClass === "proposal")
      .slice(0, 3)
      .map((finding) => finding.label);
    if (currentFindings.length > 0) {
      answerParts.push(`Current KPI view: ${currentFindings.join("; ")}.`);
      confidence += 0.1;
    } else {
      answerParts.push("No validated KPI findings are stored yet for this initiative.");
      confidence -= 0.05;
    }
    if (proposalFindings.length > 0) {
      answerParts.push(`Suggested KPI additions: ${proposalFindings.join("; ")}.`);
    }
    if (initiative.runConfig?.customKpiRulesMarkdown.trim()) {
      answerParts.push(
        `Custom KPI guidance is configured for this SI and should be considered alongside the stored findings.`,
      );
      confidence += 0.05;
    }
  }

  if (
    terms.some((term) => ["process", "working", "activity", "slack", "drive", "updating", "cadence"].includes(term))
  ) {
    answerParts.push(
      `Stored raw evidence currently includes ${rawEvidence.slackMessages.length} Slack messages, ${rawEvidence.googleFiles.length} Google file snapshots, and ${rawEvidence.documentExtracts.length} extracted documents in the most recent query window.`,
    );
    if (tracker.parsedAt) {
      answerParts.push(`The latest parsed tracker snapshot was captured at ${new Date(tracker.parsedAt).toLocaleString()}.`);
    } else {
      answerParts.push("No parsed tracker snapshot is stored yet.");
      confidence -= 0.05;
    }
  }

  if (terms.some((term) => ["document", "documents", "file", "files", "attachment", "attachments", "drive"].includes(term))) {
    if (rawEvidence.documentExtracts.length > 0) {
      const visibleDocs = rawEvidence.documentExtracts
        .filter((extract) => extract.extractionStatus === "completed")
        .slice(0, 3)
        .map((extract) => `${extract.title}: ${truncate(extract.summary, 120)}`);
      if (visibleDocs.length > 0) {
        answerParts.push(`Recent extracted document signals: ${visibleDocs.join("; ")}.`);
        confidence += 0.07;
      }
    } else {
      answerParts.push("No extracted document content is stored yet for this initiative.");
      confidence -= 0.04;
    }
  }

  const matchingAnnotations = initiative.annotations.filter((annotation) =>
    terms.length === 0
      ? true
      : terms.some((term) =>
          `${annotation.title} ${annotation.content}`.toLowerCase().includes(term),
        ),
  );
  for (const annotation of matchingAnnotations.slice(0, 3)) {
    evidence.push({
      sourceType: annotation.annotationType,
      title: annotation.title,
      excerpt: truncate(annotation.content),
      metadata: {
        annotationId: annotation.id,
        updatedAt: annotation.updatedAt,
      },
    });
  }

  if (initiative.runConfig) {
    evidence.push({
      sourceType: "run_config",
      title: "SI run config",
      excerpt: truncate(
        [
          initiative.runConfig.customInstructionsMarkdown,
          initiative.runConfig.goodLooksLikeMarkdown,
          initiative.runConfig.customKpiRulesMarkdown,
        ]
          .filter((value) => value.trim())
          .join(" "),
      ),
      metadata: {
        cadenceMode: initiative.runConfig.cadenceMode,
        updatedAt: initiative.runConfig.updatedAt,
      },
    });
  }

  for (const finding of findings.slice(0, 4)) {
    evidence.push({
      sourceType: finding.sourceType,
      title: finding.label,
      excerpt: truncate(finding.narrative ?? finding.metricValue ?? finding.label),
      metadata: {
        sourceRef: finding.sourceRef,
        findingClass: finding.findingClass,
      },
    });
  }

  for (const item of tracker.items.slice(0, 3)) {
    evidence.push({
      sourceType: "initiative_tracker",
      title: `Tracker row ${item.rowNumber}`,
      excerpt: truncate(`${item.description} ${item.notes ?? ""}`),
      metadata: {
        status: item.status,
        submittedBy: item.submittedBy,
      },
    });
  }

  for (const extract of rawEvidence.documentExtracts
    .filter((row) => row.extractionStatus === "completed" && row.summary.trim())
    .slice(0, 3)) {
    evidence.push({
      sourceType: extract.sourceType,
      title: extract.title,
      excerpt: truncate(extract.summary),
      metadata: {
        extractor: extract.extractor,
        sourceUpdatedAt: extract.sourceUpdatedAt,
      },
    });
  }

  if (input.includeRawEvidence) {
    for (const message of rawEvidence.slackMessages.slice(0, 4)) {
      evidence.push({
        sourceType: "slack",
        title: message.channelName ?? message.channelId,
        excerpt: truncate(message.text),
        url: message.permalink ?? undefined,
        metadata: {
          ts: message.ts,
          replyCount: message.replyCount,
        },
      });
    }
  }

  if (answerParts.length === 0) {
    answerParts.push(
      "I could not match the question to a focused SI slice, so I’m returning the latest opinion and stored evidence summary instead.",
    );
    followUps.push("Ask about blockers, KPI coverage, ownership, progress, or recent activity for a sharper answer.");
    confidence -= 0.08;
  }

  if (documentSummary.trim() && !terms.some((term) => ["document", "documents", "file", "files", "attachment", "attachments"].includes(term))) {
    followUps.push("Ask about attached files or Drive documents if you want a document-content summary layered onto the tracker and Slack view.");
  }

  if (initiative.annotations.length === 0) {
    followUps.push("Post SI-specific operating instructions or detail notes if you want future evaluations to reflect extra context.");
  }

  return {
    initiativeId: input.initiativeId,
    question: input.question,
    answer: answerParts.join(" "),
    confidence: Math.max(0.2, Math.min(0.95, Number(confidence.toFixed(2)))),
    evidence: evidence.slice(0, 10),
    followUps: Array.from(new Set(followUps)),
    generatedAt: new Date().toISOString(),
  };
}
