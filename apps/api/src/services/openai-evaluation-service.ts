import type {
  EvaluationResult,
  GoogleEvidenceInput,
  KpiEvidenceInput,
  SlackEvidenceInput,
  TrackerEvidenceInput,
} from "@si/agent-core";
import type { InitiativeDetail } from "@si/domain";
import OpenAI from "openai";
import { z } from "zod";
import { env } from "../config/env.js";

const llmEvaluationSchema = z.object({
  statusRecommendation: z.enum(["on_track", "needs_attention", "stalled", "off_track"]),
  progressAssessment: z.string().min(1),
  confidenceScore: z.number().min(0.05).max(0.99),
  topBlockers: z.array(z.string().min(1)).max(5),
  suggestedNextActions: z.array(z.string().min(1)).max(5),
  evidenceSummary: z.string().min(1),
  upcomingQuarterEarningsImpact: z.object({
    quarterLabel: z.string().min(1),
    periodEnd: z.string().min(1),
    applicable: z.boolean(),
    estimateType: z.enum(["range", "directional", "insufficient_evidence"]),
    lowEstimate: z.number().nullable(),
    highEstimate: z.number().nullable(),
    direction: z.enum(["positive", "negative", "neutral", "mixed", "unknown"]),
    confidence: z.number().min(0.05).max(0.99),
    rationale: z.string().min(1),
  }),
});

let openAiClient: OpenAI | null = null;

function getOpenAiClient(): OpenAI | null {
  if (!env.OPENAI_API_KEY?.trim()) {
    return null;
  }

  if (!openAiClient) {
    openAiClient = new OpenAI({ apiKey: env.OPENAI_API_KEY });
  }

  return openAiClient;
}

function truncate(value: string | null | undefined, maxLength: number): string {
  if (!value) {
    return "";
  }

  return value.length > maxLength ? `${value.slice(0, maxLength - 1)}…` : value;
}

function withTimeout<T>(promise: Promise<T>, timeoutMs: number, label: string): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const timeout = setTimeout(() => {
      reject(new Error(`${label} timed out after ${timeoutMs}ms`));
    }, timeoutMs);

    promise
      .then((value) => {
        clearTimeout(timeout);
        resolve(value);
      })
      .catch((error) => {
        clearTimeout(timeout);
        reject(error);
      });
  });
}

function summarizeSlackEvidence(slackEvidence: SlackEvidenceInput) {
  const recentMessages = [...slackEvidence.messages]
    .sort((left, right) => Number(right.ts.split(".")[0] ?? 0) - Number(left.ts.split(".")[0] ?? 0))
    .slice(0, 8)
    .map((message) => ({
      sourceId: `${message.channelId}:${message.ts}`,
      channel: message.channelName ?? message.label,
      ts: message.ts,
      text: truncate(message.text, 350),
      replyCount: message.replyCount,
      replies: message.replies.slice(0, 2).map((reply) => truncate(reply.text, 220)),
    }));

  return {
    connected: slackEvidence.connected,
    unreadableChannels: slackEvidence.unreadableChannels,
    totalMessages: slackEvidence.messages.length,
    recentMessages,
  };
}

function summarizeGoogleEvidence(googleEvidence: GoogleEvidenceInput) {
  const files = googleEvidence.files.slice(0, 8).map((file) => ({
    sourceId: file.fileId ?? file.linkId,
    label: file.name ?? file.label,
    readable: file.readable,
    modifiedTime: file.modifiedTime,
    lastModifyingUser: file.lastModifyingUser,
    revisionCount: file.revisions.length,
    childCount: file.children.length,
    sampleChildren: file.children.slice(0, 3).map((child) => ({
      sourceId: child.id,
      label: child.name,
      modifiedTime: child.modifiedTime,
      lastModifyingUser: child.lastModifyingUser,
      revisionCount: child.revisions.length,
    })),
  }));

  return {
    connected: googleEvidence.connected,
    totalFiles: googleEvidence.files.length,
    readableFiles: googleEvidence.files.filter((file) => file.readable).length,
    files,
  };
}

function summarizeTrackerEvidence(trackerEvidence: TrackerEvidenceInput) {
  return {
    connected: trackerEvidence.connected,
    trackerFileId: trackerEvidence.trackerFileId,
    trackerName: trackerEvidence.trackerName,
    parsedAt: trackerEvidence.parsedAt,
    summaryFields: trackerEvidence.summaryFields.slice(0, 12),
    items: trackerEvidence.items.slice(0, 10).map((item) => ({
      rowNumber: item.rowNumber,
      itemType: item.itemType,
      description: truncate(item.description, 220),
      status: item.status,
      notes: truncate(item.notes, 220),
      currentValueEstimate: item.currentValueEstimate,
      impactValue: item.impactValue,
      phase: item.phase,
    })),
  };
}

function summarizeKpiEvidence(kpiEvidence: KpiEvidenceInput) {
  return {
    latestResearchRunId: kpiEvidence.latestResearchRunId,
    researchedAt: kpiEvidence.researchedAt,
    summary: kpiEvidence.summary,
    findings: kpiEvidence.findings.slice(0, 12).map((finding) => ({
      sourceId: finding.id,
      findingClass: finding.findingClass,
      sourceType: finding.sourceType,
      label: finding.label,
      metricKey: finding.metricKey,
      metricValue: finding.metricValue,
      unit: finding.unit,
      narrative: truncate(finding.narrative, 260),
      sourceRef: truncate(finding.sourceRef, 180),
    })),
  };
}

function buildPromptContext(input: {
  initiative: InitiativeDetail;
  globalKnowledge: string;
  slackEvidence: SlackEvidenceInput;
  googleEvidence: GoogleEvidenceInput;
  trackerEvidence: TrackerEvidenceInput;
  kpiEvidence: KpiEvidenceInput;
  heuristicResult: EvaluationResult;
}): string {
  const { initiative, globalKnowledge, slackEvidence, googleEvidence, trackerEvidence, kpiEvidence, heuristicResult } = input;

  return JSON.stringify(
    {
      objective: "Assess whether the strategic initiative is making real progress for senior leadership.",
      upcomingQuarterTarget: {
        quarterLabel: "Q2 FY26",
        periodEnd: "2026-06-30",
        objective:
          "Estimate the initiative's likely earnings impact for the upcoming quarter ending 2026-06-30. Use KPI evidence first. If hard data is incomplete, produce a directional or range estimate with explicit confidence.",
      },
      hardRules: [
        "Do not trust workbook color/status fields by themselves.",
        "Real progress means recent operator work, decision-making, execution, and measurable movement toward the initiative goal.",
        "Administrative churn without outcome movement is not enough for on_track.",
        "Use the KPI evidence when it exists; weak or stale KPI evidence should lower confidence.",
        "Reserve on_track for initiatives with credible recent operating evidence and real progress.",
        "For upcoming-quarter impact, numeric ranges require credible KPI or tracker support.",
        "If the initiative is not credibly tied to Q2 FY26 earnings, mark it as not applicable or insufficient evidence.",
      ],
      initiative: {
        id: initiative.id,
        code: initiative.code,
        title: initiative.title,
        objective: initiative.objective,
        group: initiative.group,
        stage: initiative.stage,
        targetCadence: initiative.targetCadence,
        updateType: initiative.updateType,
        people: initiative.people.map((person) => ({
          role: person.role,
          displayName: person.displayName,
          email: person.email,
        })),
        links: initiative.links.map((link) => ({
          linkType: link.linkType,
          label: link.label,
          url: link.url,
        })),
      },
      globalKnowledge: truncate(globalKnowledge, 14000),
      heuristicBaseline: {
        statusRecommendation: heuristicResult.statusRecommendation,
        confidenceScore: heuristicResult.confidenceScore,
        topBlockers: heuristicResult.topBlockers,
        suggestedNextActions: heuristicResult.suggestedNextActions,
        evidenceSummary: truncate(heuristicResult.evidenceSummary, 5000),
      },
      evidence: {
        slack: summarizeSlackEvidence(slackEvidence),
        googleDrive: summarizeGoogleEvidence(googleEvidence),
        tracker: summarizeTrackerEvidence(trackerEvidence),
        kpis: summarizeKpiEvidence(kpiEvidence),
      },
    },
    null,
    2,
  );
}

const SYSTEM_PROMPT = `You are the SI-Agent evaluation engine for EquipmentShare strategic initiatives.

Your job is to assess the CURRENT status of an initiative for senior leadership.
You are not grading whether the initiative sounds important. You are judging whether the evidence shows real, legitimate progress toward the goal.

Use the evidence conservatively:
- Prefer recent operator activity, artifact freshness, blocker resolution, execution evidence, and KPI movement.
- Distinguish true progress from admin updates, stale trackers, or performative chatter.
- If evidence is mixed, use needs_attention.
- If evidence is stale or momentum appears lost, use stalled or off_track.
- Only use on_track when the initiative shows credible recent work and forward motion.
- Also estimate the initiative's likely Q2 FY26 earnings impact for the quarter ending 2026-06-30.
- Use KPI and tracker evidence first for that estimate.
- When hard data is incomplete, return a directional or confidence-banded estimate instead of fake precision.
- Let progressAssessment briefly mention the upcoming-quarter earnings view when it is applicable.

Return only valid JSON matching the schema.`;

export function openAiEvaluationEnabled(): boolean {
  return Boolean(env.OPENAI_API_KEY?.trim());
}

export async function evaluateInitiativeWithOpenAi(input: {
  initiative: InitiativeDetail;
  globalKnowledge: string;
  slackEvidence: SlackEvidenceInput;
  googleEvidence: GoogleEvidenceInput;
  trackerEvidence: TrackerEvidenceInput;
  kpiEvidence: KpiEvidenceInput;
  heuristicResult: EvaluationResult;
}): Promise<{ result: EvaluationResult; model: string }> {
  const client = getOpenAiClient();
  if (!client) {
    throw new Error("OpenAI evaluation is not configured");
  }

  const response = await withTimeout(
    client.responses.create({
      model: env.OPENAI_EVALUATION_MODEL,
      reasoning: {
        effort: env.OPENAI_EVALUATION_REASONING_EFFORT,
      },
      input: [
        {
          role: "system",
          content: [{ type: "input_text", text: SYSTEM_PROMPT }],
        },
        {
          role: "user",
          content: [
            {
              type: "input_text",
              text: buildPromptContext(input),
            },
          ],
        },
      ],
      text: {
        format: {
          type: "json_schema",
          name: "initiative_evaluation",
          strict: true,
          schema: {
            type: "object",
            additionalProperties: false,
            properties: {
              statusRecommendation: {
                type: "string",
                enum: ["on_track", "needs_attention", "stalled", "off_track"],
              },
              progressAssessment: { type: "string" },
              confidenceScore: { type: "number" },
              topBlockers: {
                type: "array",
                items: { type: "string" },
                maxItems: 5,
              },
              suggestedNextActions: {
                type: "array",
                items: { type: "string" },
                maxItems: 5,
              },
              evidenceSummary: { type: "string" },
              upcomingQuarterEarningsImpact: {
                type: "object",
                additionalProperties: false,
                properties: {
                  quarterLabel: { type: "string" },
                  periodEnd: { type: "string" },
                  applicable: { type: "boolean" },
                  estimateType: {
                    type: "string",
                    enum: ["range", "directional", "insufficient_evidence"],
                  },
                  lowEstimate: { type: ["number", "null"] },
                  highEstimate: { type: ["number", "null"] },
                  direction: {
                    type: "string",
                    enum: ["positive", "negative", "neutral", "mixed", "unknown"],
                  },
                  confidence: { type: "number" },
                  rationale: { type: "string" },
                },
                required: [
                  "quarterLabel",
                  "periodEnd",
                  "applicable",
                  "estimateType",
                  "lowEstimate",
                  "highEstimate",
                  "direction",
                  "confidence",
                  "rationale",
                ],
              },
            },
            required: [
              "statusRecommendation",
              "progressAssessment",
              "confidenceScore",
              "topBlockers",
              "suggestedNextActions",
              "evidenceSummary",
              "upcomingQuarterEarningsImpact",
            ],
          },
        },
      },
    }),
    env.OPENAI_EVALUATION_TIMEOUT_MS,
    `OpenAI evaluation for ${input.initiative.code}`,
  );

  const rawText = response.output_text?.trim();
  if (!rawText) {
    throw new Error("OpenAI evaluation returned empty output");
  }

  const parsed = llmEvaluationSchema.parse(JSON.parse(rawText));

  return {
    model: response.model,
    result: {
      ...input.heuristicResult,
      statusRecommendation: parsed.statusRecommendation,
      progressAssessment: parsed.progressAssessment,
      confidenceScore: Number(parsed.confidenceScore.toFixed(2)),
      topBlockers: parsed.topBlockers,
      suggestedNextActions: parsed.suggestedNextActions,
      evidenceSummary: parsed.evidenceSummary,
      upcomingQuarterEarningsImpact: {
        ...parsed.upcomingQuarterEarningsImpact,
        confidence: Number(parsed.upcomingQuarterEarningsImpact.confidence.toFixed(2)),
        lowEstimate:
          parsed.upcomingQuarterEarningsImpact.lowEstimate === null
            ? null
            : Number(parsed.upcomingQuarterEarningsImpact.lowEstimate.toFixed(2)),
        highEstimate:
          parsed.upcomingQuarterEarningsImpact.highEstimate === null
            ? null
            : Number(parsed.upcomingQuarterEarningsImpact.highEstimate.toFixed(2)),
      },
    },
  };
}
