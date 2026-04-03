import type { InitiativeDetail } from "@si/domain";
import OpenAI from "openai";
import { z } from "zod";
import { env } from "../config/env.js";
import type { AnalyticsCorpusSnippet } from "./analytics-corpus-service.js";

const kpiCandidateSchema = z.object({
  metricKey: z.string().min(1),
  label: z.string().min(1),
  whyItMatters: z.string().min(1),
  likelySourceObjects: z.array(z.string().min(1)).max(5),
  warehouseSearchTerms: z.array(z.string().min(1)).max(8),
  supportingSnippetRefs: z.array(z.string().min(1)).max(6),
  confidence: z.number().min(0.05).max(0.99),
});

const kpiResearchResponseSchema = z.object({
  candidates: z.array(kpiCandidateSchema).max(6),
});

export type ProposedKpiCandidate = z.infer<typeof kpiCandidateSchema>;

let openAiClient: OpenAI | null = null;
const OPENAI_KPI_TIMEOUT_MS = Math.max(env.OPENAI_KPI_TIMEOUT_MS, 300_000);

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

function buildPromptContext(input: {
  initiative: InitiativeDetail;
  trackerContext: string[];
  trackerCurrentFindings: Array<{ label: string; metricValue: string | null; narrative: string | null }>;
  heuristicProposals: Array<{ label: string; narrative: string | null }>;
  snippets: AnalyticsCorpusSnippet[];
}): string {
  return JSON.stringify(
    {
      objective:
        "Propose the strongest KPI candidates for this strategic initiative using initiative context and analytics-code snippets.",
      initiative: {
        code: input.initiative.code,
        title: input.initiative.title,
        objective: input.initiative.objective,
        group: input.initiative.group,
        stage: input.initiative.stage,
        targetCadence: input.initiative.targetCadence,
      },
      trackerContext: input.trackerContext.slice(0, 8),
      trackerCurrentFindings: input.trackerCurrentFindings.slice(0, 8),
      heuristicProposals: input.heuristicProposals.slice(0, 6),
      analyticsSnippets: input.snippets.slice(0, 10).map((snippet) => ({
        snippetRef: `${snippet.relativePath}:${snippet.lineStart}-${snippet.lineEnd}`,
        sourceType: snippet.sourceType,
        matchedTerms: snippet.matchedTerms,
        excerpt: truncate(snippet.excerpt, 1400),
      })),
    },
    null,
    2,
  );
}

const SYSTEM_PROMPT = `You are the KPI research analyst for EquipmentShare strategic initiatives.

Use the initiative context and analytics-code snippets to infer the best KPI candidates.
Your job is not to repeat every metric-shaped line. Your job is to produce the 3-6 KPI candidates that would best help senior leadership judge whether the initiative is creating real progress.

Important rules:
- Prefer business-facing KPIs over technical noise.
- Use analytics-code snippets to infer existing models, measures, or semantic objects when possible.
- Only include likelySourceObjects that are plausibly grounded in the snippets.
- warehouseSearchTerms should be concise SQL validation terms, not sentences.
- supportingSnippetRefs must reference only the provided snippet refs.
- Avoid generic filler KPIs when the snippets suggest a stronger initiative-specific KPI.

Return only valid JSON matching the schema.`;

export function openAiKpiResearchEnabled(): boolean {
  return Boolean(env.OPENAI_API_KEY?.trim());
}

export async function proposeKpisWithOpenAi(input: {
  initiative: InitiativeDetail;
  trackerContext: string[];
  trackerCurrentFindings: Array<{ label: string; metricValue: string | null; narrative: string | null }>;
  heuristicProposals: Array<{ label: string; narrative: string | null }>;
  snippets: AnalyticsCorpusSnippet[];
}): Promise<{ candidates: ProposedKpiCandidate[]; model: string }> {
  const client = getOpenAiClient();
  if (!client) {
    throw new Error("OpenAI KPI research is not configured");
  }

  const response = await withTimeout(
    client.responses.create({
      model: env.OPENAI_KPI_MODEL,
      reasoning: {
        effort: env.OPENAI_KPI_REASONING_EFFORT,
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
          name: "kpi_research",
          strict: true,
          schema: {
            type: "object",
            additionalProperties: false,
            properties: {
              candidates: {
                type: "array",
                maxItems: 6,
                items: {
                  type: "object",
                  additionalProperties: false,
                  properties: {
                    metricKey: { type: "string" },
                    label: { type: "string" },
                    whyItMatters: { type: "string" },
                    likelySourceObjects: {
                      type: "array",
                      maxItems: 5,
                      items: { type: "string" },
                    },
                    warehouseSearchTerms: {
                      type: "array",
                      maxItems: 8,
                      items: { type: "string" },
                    },
                    supportingSnippetRefs: {
                      type: "array",
                      maxItems: 6,
                      items: { type: "string" },
                    },
                    confidence: { type: "number" },
                  },
                  required: [
                    "metricKey",
                    "label",
                    "whyItMatters",
                    "likelySourceObjects",
                    "warehouseSearchTerms",
                    "supportingSnippetRefs",
                    "confidence",
                  ],
                },
              },
            },
            required: ["candidates"],
          },
        },
      },
    }),
    OPENAI_KPI_TIMEOUT_MS,
    `OpenAI KPI research for ${input.initiative.code}`,
  );

  const rawText = response.output_text?.trim();
  if (!rawText) {
    throw new Error("OpenAI KPI research returned empty output");
  }

  const parsed = kpiResearchResponseSchema.parse(JSON.parse(rawText));
  return {
    model: response.model,
    candidates: parsed.candidates.map((candidate) => ({
      ...candidate,
      confidence: Number(candidate.confidence.toFixed(2)),
    })),
  };
}
