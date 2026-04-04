import type { InitiativeDetail, InitiativeKpiResearch, KpiFinding } from "@si/domain";
import { and, desc, eq } from "drizzle-orm";
import { env } from "../config/env.js";
import { db } from "../db/client.js";
import { kpiFindings, kpiResearchRuns } from "../db/schema.js";
import { createId } from "../lib/id.js";
import {
  retrieveAnalyticsCorpusSnippets,
  type AnalyticsCorpusSnippet,
  resolveAnalyticsCorpusPath,
} from "./analytics-corpus-service.js";
import {
  executeSqlThroughFrostyWithWarehouse,
  type FrostySqlResult,
} from "./frosty-client.js";
import {
  openAiKpiResearchEnabled,
  proposeKpisWithOpenAi,
  type ProposedKpiCandidate,
} from "./openai-kpi-research-service.js";
import { getLatestTrackerForInitiative } from "./tracker-service.js";

const KPI_RESEARCH_TIMEOUT_MS = Math.max(env.KPI_RESEARCH_TIMEOUT_MS, 300_000);

const STOPWORDS = new Set([
  "initiative",
  "program",
  "team",
  "teams",
  "quarterly",
  "current",
  "inform",
  "scope",
  "operational",
  "strategic",
  "equipmentshare",
  "approach",
  "tracker",
  "issues",
  "actions",
  "action",
]);

function slugify(value: string): string {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

function unique<T>(values: T[]): T[] {
  return Array.from(new Set(values));
}

function buildSearchTerms(initiative: InitiativeDetail, trackerText: string[]): string[] {
  const base = [initiative.code, initiative.title, initiative.objective, initiative.group, ...trackerText]
    .join(" ")
    .toLowerCase()
    .split(/[^a-z0-9]+/)
    .map((token) => token.trim())
    .filter((token) => token.length >= 4 && !STOPWORDS.has(token));

  return Array.from(new Set(base)).slice(0, 10);
}

function deriveTrackerFindings(tracker: Awaited<ReturnType<typeof getLatestTrackerForInitiative>>): KpiFinding[] {
  const summaryMetrics = tracker.summaryFields
    .filter((field) => /(baseline|booked|earned to date|target|confidence)/i.test(field.label))
    .map((field) => ({
      id: createId("kpi"),
      findingClass: "tracker_current",
      sourceType: "tracker",
      metricKey: field.fieldKey,
      label: field.label,
      metricValue: field.value || null,
      unit: field.value.includes("$") ? "usd" : null,
      narrative: "Current KPI value captured from the initiative tracker.",
      sourceRef: tracker.trackerFileId,
      provenance: {
        trackerName: tracker.trackerName,
        parsedAt: tracker.parsedAt,
        findingPriority: "current_metric",
      },
    }));

  const topPriorityCount = tracker.items.filter((item) => {
    const value = Number(item.prioritization ?? "");
    return Number.isFinite(value) && value > 0 && value <= 10;
  }).length;

  if (topPriorityCount > 0) {
    summaryMetrics.push({
      id: createId("kpi"),
      findingClass: "tracker_current",
      sourceType: "tracker",
      metricKey: "tracker_top_priority_items",
      label: "Top priority tracker items",
      metricValue: String(topPriorityCount),
      unit: "count",
      narrative: "Number of tracker rows carrying a top-10 prioritization.",
      sourceRef: tracker.trackerFileId,
      provenance: {
        trackerName: tracker.trackerName,
        parsedAt: tracker.parsedAt,
        findingPriority: "operating_metric",
      },
    });
  }

  const blockerCount = tracker.items.filter((item) =>
    /(block|risk|delay|hold|stuck)/i.test(`${item.itemType ?? ""} ${item.status ?? ""} ${item.notes ?? ""}`),
  ).length;

  if (blockerCount > 0) {
    summaryMetrics.push({
      id: createId("kpi"),
      findingClass: "tracker_current",
      sourceType: "tracker",
      metricKey: "tracker_blocker_count",
      label: "Tracker blocker count",
      metricValue: String(blockerCount),
      unit: "count",
      narrative: "Current number of tracker rows flagged as blockers or risks.",
      sourceRef: tracker.trackerFileId,
      provenance: {
        trackerName: tracker.trackerName,
        parsedAt: tracker.parsedAt,
        findingPriority: "operating_metric",
      },
    });
  }

  return summaryMetrics;
}

function deriveHeuristicProposalFindings(
  initiative: InitiativeDetail,
  tracker: Awaited<ReturnType<typeof getLatestTrackerForInitiative>>,
): KpiFinding[] {
  const proposals: KpiFinding[] = [
    {
      id: createId("kpi"),
      findingClass: "proposal",
      sourceType: "heuristic_proposal",
      metricKey: "days_since_tracker_update",
      label: "Days since tracker update",
      metricValue: null,
      unit: "days",
      narrative: "Use tracker freshness as a core KPI so stale operating cadence becomes visible immediately.",
      sourceRef: tracker.trackerFileId,
      provenance: {
        reason: "Tracker freshness is central to evaluating SI operating discipline.",
        findingPriority: "supporting_proposal",
      },
    },
    {
      id: createId("kpi"),
      findingClass: "proposal",
      sourceType: "heuristic_proposal",
      metricKey: "priority_item_completion_rate",
      label: "Priority item completion rate",
      metricValue: null,
      unit: "percent",
      narrative:
        "Track the share of top-priority tracker rows that are complete or in an execution-ready phase.",
      sourceRef: tracker.trackerFileId,
      provenance: {
        reason: "The tracker is organized around prioritized work items and phases.",
        findingPriority: "supporting_proposal",
      },
    },
  ];

  const objectiveText = `${initiative.title} ${initiative.objective}`.toLowerCase();
  if (/earnings|profit|margin|booked/i.test(objectiveText)) {
    proposals.push({
      id: createId("kpi"),
      findingClass: "proposal",
      sourceType: "heuristic_proposal",
      metricKey: "booked_vs_target",
      label: "Booked vs target",
      metricValue: null,
      unit: "usd",
      narrative: "Measure the current booked amount against the stated target each run.",
      sourceRef: tracker.trackerFileId,
      provenance: {
        reason: "The tracker summary already references booked earnings and target values.",
        findingPriority: "supporting_proposal",
      },
    });
  }

  if (/buyback|lease|capex|capital/i.test(objectiveText)) {
    proposals.push({
      id: createId("kpi"),
      findingClass: "proposal",
      sourceType: "heuristic_proposal",
      metricKey: "items_completed_this_period",
      label: "Items completed this period",
      metricValue: null,
      unit: "count",
      narrative: "Count completed work items or transactions in the current period to measure operating throughput.",
      sourceRef: tracker.trackerFileId,
      provenance: {
        reason: "This SI appears transaction-oriented and should show throughput, not just narrative progress.",
        findingPriority: "supporting_proposal",
      },
    });
  }

  return proposals;
}

async function getLatestCompletedFindingsForInitiative(
  initiativeId: string,
  excludeRunId: string,
): Promise<KpiFinding[]> {
  const latestCompletedRun = await db.query.kpiResearchRuns.findFirst({
    where: and(eq(kpiResearchRuns.initiativeId, initiativeId), eq(kpiResearchRuns.status, "completed")),
    orderBy: [desc(kpiResearchRuns.createdAt)],
  });

  if (!latestCompletedRun || latestCompletedRun.id === excludeRunId || latestCompletedRun.status !== "completed") {
    return [];
  }

  const priorFindings = await db.query.kpiFindings.findMany({
    where: eq(kpiFindings.researchRunId, latestCompletedRun.id),
    orderBy: [desc(kpiFindings.createdAt)],
  });

  return priorFindings.map((finding) => ({
    id: createId("kpi"),
    findingClass: finding.findingClass,
    sourceType: finding.sourceType,
    metricKey: finding.metricKey,
    label: finding.label,
    metricValue: finding.metricValue,
    unit: finding.unit,
    narrative: finding.narrative,
    sourceRef: finding.sourceRef,
    provenance: {
      ...(finding.provenance ?? {}),
      reusedFromRunId: latestCompletedRun.id,
      reuseReason: "Live KPI research fallback",
    },
  }));
}

function withTimeout<T>(promise: Promise<T>, timeoutMs: number, label: string): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const timeoutHandle = setTimeout(() => {
      reject(new Error(`${label} timed out after ${timeoutMs}ms`));
    }, timeoutMs);

    promise
      .then((value) => {
        clearTimeout(timeoutHandle);
        resolve(value);
      })
      .catch((error) => {
        clearTimeout(timeoutHandle);
        reject(error);
      });
  });
}

function normalizeSqlRows(result: FrostySqlResult): Array<Record<string, unknown>> {
  if (!Array.isArray(result.data)) {
    return [];
  }

  return result.data.map((row) => {
    if (!Array.isArray(row)) {
      return row as Record<string, unknown>;
    }
    return Object.fromEntries((result.columns ?? []).map((column, index) => [column, row[index] ?? null]));
  });
}

function escapeSqlLiteral(value: string): string {
  return value.replace(/'/g, "''");
}

function buildAnalyticsReferenceFindings(snippets: AnalyticsCorpusSnippet[]): KpiFinding[] {
  return snippets.map((snippet) => ({
    id: createId("kpi"),
    findingClass: "analytics_code_reference",
    sourceType: snippet.sourceType,
    metricKey: slugify(snippet.bestLine.slice(0, 64) || snippet.relativePath),
    label: snippet.bestLine.slice(0, 120) || snippet.relativePath,
    metricValue: null,
    unit: null,
    narrative: "High-signal analytics-code snippet retrieved for KPI research.",
    sourceRef: `${snippet.relativePath}:${snippet.lineStart}-${snippet.lineEnd}`,
    provenance: {
      relativePath: snippet.relativePath,
      score: snippet.score,
      matchedTerms: snippet.matchedTerms,
      excerpt: snippet.excerpt,
      lineStart: snippet.lineStart,
      lineEnd: snippet.lineEnd,
      findingPriority: snippet.score >= 12 ? "high_signal_reference" : "reference",
    },
  }));
}

function buildGptProposalFindings(
  candidates: ProposedKpiCandidate[],
  model: string | null,
  trackerFileId: string | null,
): KpiFinding[] {
  return candidates.map((candidate) => ({
    id: createId("kpi"),
    findingClass: "proposal",
    sourceType: "gpt_proposal",
    metricKey: slugify(candidate.metricKey),
    label: candidate.label,
    metricValue: null,
    unit: null,
    narrative: `${candidate.whyItMatters} Q2 FY26 earnings impact connection: ${candidate.upcomingQuarterEarningsConnection}`,
    sourceRef: trackerFileId,
    provenance: {
      model,
      confidence: candidate.confidence,
      upcomingQuarterEarningsConnection: candidate.upcomingQuarterEarningsConnection,
      likelySourceObjects: candidate.likelySourceObjects,
      warehouseSearchTerms: candidate.warehouseSearchTerms,
      supportingSnippetRefs: candidate.supportingSnippetRefs,
      findingPriority: "primary_proposal",
    },
  }));
}

async function validateKpiCandidatesWithWarehouse(
  candidates: ProposedKpiCandidate[],
  fallbackTerms: string[],
): Promise<{ findings: KpiFinding[]; outputs: Array<Record<string, unknown>> }> {
  const findings: KpiFinding[] = [];
  const outputs: Array<Record<string, unknown>> = [];

  for (const candidate of candidates.slice(0, 5)) {
    const exactObjects = unique(
      candidate.likelySourceObjects
        .map((value) => value.trim())
        .filter((value) => value.length > 0)
        .map((value) => value.toLowerCase()),
    ).slice(0, 5);
    const queryTerms = unique(
      candidate.warehouseSearchTerms
        .concat(
          exactObjects.flatMap((value) => value.split(/[^a-z0-9_]+/i)),
          fallbackTerms,
          candidate.label.split(/[^a-z0-9_]+/i),
        )
        .map((value) => value.trim().toLowerCase())
        .filter((value) => value.length >= 4),
    ).slice(0, 8);

    if (queryTerms.length === 0 && exactObjects.length === 0) {
      continue;
    }

    const termValuesClause =
      queryTerms.length > 0
        ? queryTerms.map((term) => `('${escapeSqlLiteral(term)}')`).join(", ")
        : "('metric')";
    const exactObjectClause =
      exactObjects.length > 0
        ? `or lower(c.table_schema || '.' || c.table_name) in (${exactObjects
            .map((value) => `'${escapeSqlLiteral(value)}'`)
            .join(", ")})`
        : "";

    const sql = `
with terms(term) as (
  select column1 from values ${termValuesClause}
)
select table_schema, table_name, column_name
from analytics.information_schema.columns c
where c.table_schema <> 'INFORMATION_SCHEMA'
  and (
    exists (
      select 1
      from terms t
      where lower(c.table_schema) like '%' || lower(t.term) || '%'
        or lower(c.table_name) like '%' || lower(t.term) || '%'
        or lower(c.column_name) like '%' || lower(t.term) || '%'
    )
    ${exactObjectClause}
  )
limit 12
`;

    try {
      const result = await executeSqlThroughFrostyWithWarehouse(
        sql,
        env.FROSTY_SQL_WAREHOUSE,
        env.FROSTY_BASE_URL,
      );
      const rows = normalizeSqlRows(result);
      if (rows.length === 0) {
        continue;
      }

      const matchedObjects = rows.map((row) => ({
        tableSchema: String(row.table_schema ?? ""),
        tableName: String(row.table_name ?? ""),
        columnName: String(row.column_name ?? ""),
      }));

      outputs.push({
        metricKey: candidate.metricKey,
        label: candidate.label,
        warehouse: env.FROSTY_SQL_WAREHOUSE,
        matchedRowCount: matchedObjects.length,
        matchedObjects,
      });

      findings.push({
        id: createId("kpi"),
        findingClass: "warehouse_validated",
        sourceType: "snowflake_validation",
        metricKey: slugify(candidate.metricKey),
        label: candidate.label,
        metricValue: null,
        unit: null,
        narrative: `Snowflake metadata validation found ${matchedObjects.length} likely source columns for this KPI candidate.`,
        sourceRef: "analytics.information_schema.columns",
        provenance: {
          likelySourceObjects: candidate.likelySourceObjects,
          queryTerms,
          warehouse: env.FROSTY_SQL_WAREHOUSE,
          matchedObjects,
          validationMethod: "information_schema_search",
          findingPriority: "warehouse_validated",
        },
      });
    } catch (error) {
      outputs.push({
        metricKey: candidate.metricKey,
        label: candidate.label,
        warehouse: env.FROSTY_SQL_WAREHOUSE,
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }

  return { findings, outputs };
}

export async function runKpiResearchForInitiative(
  initiative: InitiativeDetail,
  agentRunId?: string,
): Promise<{ researchRunId: string; findings: KpiFinding[] }> {
  const startedAtMs = Date.now();
  const tracker = await getLatestTrackerForInitiative(initiative.id);
  const trackerContext = tracker.items
    .slice(0, 8)
    .map((item) => `${item.itemType ?? ""} ${item.description} ${item.notes ?? ""}`.trim())
    .filter(Boolean);
  const terms = buildSearchTerms(initiative, trackerContext);

  const researchRunId = createId("kpi_research");
  await db.insert(kpiResearchRuns).values({
    id: researchRunId,
    initiativeId: initiative.id,
    agentRunId: agentRunId ?? null,
    status: "running",
    summary: {
      terms,
      analyticsCorpusPath: resolveAnalyticsCorpusPath(),
    },
  });

  try {
    const trackerFindings = deriveTrackerFindings(tracker);
    const heuristicProposals = deriveHeuristicProposalFindings(initiative, tracker);

    const result = await withTimeout(
      (async () => {
        const timings: Record<string, number> = {};
        const retrievalStartedAtMs = Date.now();
        const analyticsSnippets = await retrieveAnalyticsCorpusSnippets({
          initiative,
          trackerContext,
          searchTerms: terms,
        });
        timings.analyticsRetrievalMs = Date.now() - retrievalStartedAtMs;

        const analyticsReferenceFindings = buildAnalyticsReferenceFindings(analyticsSnippets);
        let openAiCandidates: ProposedKpiCandidate[] = [];
        let openAiModel: string | null = null;
        let openAiWarning: string | null = null;

        if (analyticsSnippets.length > 0 && openAiKpiResearchEnabled()) {
          try {
            const openAiStartedAtMs = Date.now();
            const openAiResult = await proposeKpisWithOpenAi({
              initiative,
              trackerContext,
              trackerCurrentFindings: trackerFindings.map((finding) => ({
                label: finding.label,
                metricValue: finding.metricValue,
                narrative: finding.narrative,
              })),
              heuristicProposals: heuristicProposals.map((finding) => ({
                label: finding.label,
                narrative: finding.narrative,
              })),
              snippets: analyticsSnippets,
            });
            openAiCandidates = openAiResult.candidates;
            openAiModel = openAiResult.model;
            timings.openAiProposalMs = Date.now() - openAiStartedAtMs;
          } catch (error) {
            openAiWarning = error instanceof Error ? error.message : String(error);
          }
        }

        const gptProposalFindings = buildGptProposalFindings(openAiCandidates, openAiModel, tracker.trackerFileId);
        const validationStartedAtMs = Date.now();
        const validation = await validateKpiCandidatesWithWarehouse(openAiCandidates, terms);
        timings.validationMs = Date.now() - validationStartedAtMs;

        const findings: KpiFinding[] = [
          ...trackerFindings,
          ...analyticsReferenceFindings,
          ...gptProposalFindings,
          ...validation.findings,
          ...heuristicProposals,
        ];

        return {
          findings,
          analyticsSnippets,
          openAiCandidates,
          openAiModel,
          openAiWarning,
          validationOutputs: validation.outputs,
          timings: {
            ...timings,
            totalMs: Date.now() - startedAtMs,
          },
        };
      })(),
      KPI_RESEARCH_TIMEOUT_MS,
      `KPI research for ${initiative.code}`,
    );

    if (result.findings.length > 0) {
      await db.insert(kpiFindings).values(
        result.findings.map((finding) => ({
          id: finding.id,
          researchRunId,
          initiativeId: initiative.id,
          findingClass: finding.findingClass,
          sourceType: finding.sourceType,
          metricKey: finding.metricKey,
          label: finding.label,
          metricValue: finding.metricValue,
          unit: finding.unit,
          narrative: finding.narrative,
          sourceRef: finding.sourceRef,
          provenance: finding.provenance,
        })),
      );
    }

    await db
      .update(kpiResearchRuns)
      .set({
        status: "completed",
        summary: {
          terms,
          upcomingQuarterTarget: {
            quarterLabel: "Q2 FY26",
            periodEnd: "2026-06-30",
          },
          analyticsCorpusPath: resolveAnalyticsCorpusPath(),
          analyticsSnippetCount: result.analyticsSnippets.length,
          analyticsReferenceCount: result.findings.filter((finding) => finding.findingClass === "analytics_code_reference")
            .length,
          trackerFindingCount: result.findings.filter((finding) => finding.sourceType === "tracker").length,
          proposalFindingCount: result.findings.filter((finding) => finding.findingClass === "proposal").length,
          warehouseValidatedCount: result.findings.filter((finding) => finding.findingClass === "warehouse_validated")
            .length,
          openAiCandidateCount: result.openAiCandidates.length,
          openAiModel: result.openAiModel,
          openAiWarning: result.openAiWarning,
          validationOutputs: result.validationOutputs,
          timings: result.timings,
        },
        finishedAt: new Date(),
      })
      .where(eq(kpiResearchRuns.id, researchRunId));

    return { researchRunId, findings: result.findings };
  } catch (error) {
    const fallbackFindings = [
      ...deriveTrackerFindings(tracker),
      ...deriveHeuristicProposalFindings(initiative, tracker),
      ...(await getLatestCompletedFindingsForInitiative(initiative.id, researchRunId)),
    ];

    if (fallbackFindings.length > 0) {
      await db.insert(kpiFindings).values(
        fallbackFindings.map((finding) => ({
          id: finding.id,
          researchRunId,
          initiativeId: initiative.id,
          findingClass: finding.findingClass,
          sourceType: finding.sourceType,
          metricKey: finding.metricKey,
          label: finding.label,
          metricValue: finding.metricValue,
          unit: finding.unit,
          narrative: finding.narrative,
          sourceRef: finding.sourceRef,
          provenance: finding.provenance,
        })),
      );
    }

    await db
      .update(kpiResearchRuns)
      .set({
        status: "completed",
        summary: {
          warning: error instanceof Error ? error.message : "KPI research failed",
          terms,
          analyticsCorpusPath: resolveAnalyticsCorpusPath(),
          fallback: true,
          reusedFindingCount: fallbackFindings.length,
          timings: {
            totalMs: Date.now() - startedAtMs,
          },
        },
        finishedAt: new Date(),
      })
      .where(eq(kpiResearchRuns.id, researchRunId));

    return { researchRunId, findings: fallbackFindings };
  }
}

export async function getLatestKpiResearchForInitiative(initiativeId: string): Promise<InitiativeKpiResearch> {
  const latestRun = await db.query.kpiResearchRuns.findFirst({
    where: eq(kpiResearchRuns.initiativeId, initiativeId),
    orderBy: [desc(kpiResearchRuns.createdAt)],
  });

  if (!latestRun) {
    return {
      initiativeId,
      latestResearchRunId: null,
      findings: [],
      summary: {},
      researchedAt: null,
    };
  }

  const findings = await db.query.kpiFindings.findMany({
    where: eq(kpiFindings.researchRunId, latestRun.id),
    orderBy: [desc(kpiFindings.createdAt)],
  });

  return {
    initiativeId,
    latestResearchRunId: latestRun.id,
    findings: findings.map((finding) => ({
      id: finding.id,
      findingClass: finding.findingClass,
      sourceType: finding.sourceType,
      metricKey: finding.metricKey,
      label: finding.label,
      metricValue: finding.metricValue,
      unit: finding.unit,
      narrative: finding.narrative,
      sourceRef: finding.sourceRef,
      provenance: finding.provenance,
    })),
    summary: latestRun.summary ?? {},
    researchedAt: latestRun.createdAt.toISOString(),
  };
}
