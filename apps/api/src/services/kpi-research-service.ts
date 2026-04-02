import type { InitiativeDetail, InitiativeKpiResearch, KpiFinding } from "@si/domain";
import { execFile as execFileCallback } from "node:child_process";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { promisify } from "node:util";
import { and, desc, eq } from "drizzle-orm";
import { env } from "../config/env.js";
import { db } from "../db/client.js";
import { kpiFindings, kpiResearchRuns } from "../db/schema.js";
import { createId } from "../lib/id.js";
import { executeSqlThroughFrosty } from "./frosty-client.js";
import { getLatestTrackerForInitiative } from "./tracker-service.js";

const execFile = promisify(execFileCallback);
const ANALYTICS_SEARCH_TIMEOUT_MS = env.ANALYTICS_SEARCH_TIMEOUT_MS;
const KPI_RESEARCH_TIMEOUT_MS = env.KPI_RESEARCH_TIMEOUT_MS;

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

const METRIC_HINT_PATTERN =
  /\b(revenue|earnings|margin|fee|fees|target|baseline|forecast|booked|earned|collect|collected|throughput|utilization|count|rate|volume|profit|sales|buyback|buybacks|capex|capital|inventory)\b/i;

const GENERIC_LINE_PATTERNS = [
  /^@property$/i,
  /^from\s+\S+/i,
  /^import\s+\S+/i,
  /^dimension:\s*[a-z_]+$/i,
  /^measure:\s*[a-z_]+$/i,
  /^view:\s*[a-z_]+$/i,
];

function slugify(value: string): string {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

function buildSearchTerms(initiative: InitiativeDetail, trackerText: string[]): string[] {
  const base = [initiative.code, initiative.title, initiative.objective, initiative.group, ...trackerText]
    .join(" ")
    .toLowerCase()
    .split(/[^a-z0-9]+/)
    .map((token) => token.trim())
    .filter((token) => token.length >= 4 && !STOPWORDS.has(token));

  return Array.from(new Set(base)).slice(0, 8);
}

function classifySourceType(filePath: string): string {
  if (filePath.includes("/ba-finance-dbt/")) {
    return "dbt_model";
  }
  if (filePath.includes("/looker/")) {
    return "looker_model";
  }
  return "analytics_code";
}

function sourceWeight(sourceType: string): number {
  if (sourceType === "dbt_model") {
    return 5;
  }
  if (sourceType === "looker_model") {
    return 4;
  }
  return 2;
}

function countMatchedTerms(lineText: string, filePath: string, terms: string[]): number {
  const haystack = `${lineText} ${path.basename(filePath)}`.toLowerCase();
  return terms.filter((term) => haystack.includes(term.toLowerCase())).length;
}

function isUsefulAnalyticsLine(lineText: string): boolean {
  const text = lineText.trim();
  if (text.length < 18) {
    return false;
  }
  return !GENERIC_LINE_PATTERNS.some((pattern) => pattern.test(text));
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

function deriveProposedFindings(
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
        findingPriority: "proposal",
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
        findingPriority: "proposal",
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
        findingPriority: "proposal",
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
        findingPriority: "proposal",
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
    where: and(
      eq(kpiResearchRuns.initiativeId, initiativeId),
      eq(kpiResearchRuns.status, "completed"),
    ),
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

async function searchAnalyticsCorpus(terms: string[]): Promise<
  Array<{
    filePath: string;
    lineNumber: string;
    lineText: string;
    sourceType: string;
    score: number;
  }>
> {
  if (terms.length === 0) {
    return [];
  }

  const escapedTerms = terms.map((term) => term.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
  const pattern = escapedTerms.join("|");
  const corpusPath = env.ANALYTICS_CORPUS_PATH;
  const searchRoots = [
    path.join(corpusPath, "ba_gitlab_repos", "ba-finance-dbt"),
    path.join(corpusPath, "dbt_cloud", "business-intelligence"),
    path.join(corpusPath, "looker"),
  ];
  const args = [
    "-l",
    "-i",
    "--glob",
    "*.{sql,lkml,md,yml,yaml,py}",
    pattern,
    ...searchRoots,
  ];

  try {
    const { stdout } = await execFile("rg", args, {
      maxBuffer: 1024 * 1024 * 8,
      timeout: ANALYTICS_SEARCH_TIMEOUT_MS,
    });
    const candidateFiles = stdout
      .split("\n")
      .filter(Boolean)
      .slice(0, 40);
    const hits: Array<{
      filePath: string;
      lineNumber: string;
      lineText: string;
      sourceType: string;
      score: number;
    }> = [];

    for (const filePath of candidateFiles) {
      let content: string;
      try {
        content = await readFile(filePath, "utf8");
      } catch {
        continue;
      }
      const lines = content.split("\n");
      for (let index = 0; index < lines.length; index += 1) {
        const lineText = lines[index]?.trim() ?? "";
        if (!lineText) {
          continue;
        }
        const haystack = `${filePath} ${lineText}`.toLowerCase();
        if (!terms.some((term) => haystack.includes(term.toLowerCase()))) {
          continue;
        }
        const sourceType = classifySourceType(filePath);
        const termMatches = countMatchedTerms(lineText, filePath, terms);
        const metricHintScore = METRIC_HINT_PATTERN.test(lineText) ? 3 : 0;
        const pathHintScore = METRIC_HINT_PATTERN.test(filePath) ? 2 : 0;
        const hit = {
          filePath,
          lineNumber: String(index + 1),
          lineText,
          sourceType,
          score: sourceWeight(sourceType) + termMatches * 2 + metricHintScore + pathHintScore,
        };
        if (!isUsefulAnalyticsLine(hit.lineText)) {
          continue;
        }
        if (hit.score < 6 && !METRIC_HINT_PATTERN.test(hit.lineText)) {
          continue;
        }
        hits.push(hit);
      }
    }

    return hits.sort((left, right) => right.score - left.score).slice(0, 10);
  } catch (error) {
    const execError = error as { stdout?: string; code?: number | string; killed?: boolean; signal?: string };
    if (execError.code === 1) {
      return [];
    }
    if (
      execError.code === "ETIMEDOUT" ||
      execError.killed === true ||
      execError.signal === "SIGTERM"
    ) {
      return [];
    }
    throw error;
  }
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

async function runSnowflakeDiscovery(terms: string[]): Promise<string | null> {
  if (terms.length === 0) {
    return null;
  }

  const sanitizedTerms = terms.slice(0, 5).map((term) => term.replace(/'/g, "''"));
  const valuesClause = sanitizedTerms.map((term) => `('${term}')`).join(", ");
  const sql = `
with terms(term) as (
  select column1 from values ${valuesClause}
)
select table_schema, table_name, column_name
from analytics.information_schema.columns c
join terms t
  on lower(c.table_name) like '%' || lower(t.term) || '%'
  or lower(c.column_name) like '%' || lower(t.term) || '%'
where table_schema <> 'INFORMATION_SCHEMA'
limit 25
`;

  try {
    const result = await executeSqlThroughFrosty(sql, env.FROSTY_BASE_URL);
    if (result.success === false) {
      return result.error?.trim() || null;
    }

    if (!Array.isArray(result.data) || result.data.length === 0) {
      return null;
    }

    return JSON.stringify(
      {
        statementType: result.statement_type ?? null,
        columns: result.columns ?? [],
        rowCount: result.row_count ?? result.data.length,
        data: result.data,
      },
      null,
      2,
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return message.trim() || null;
  }
}

export async function runKpiResearchForInitiative(
  initiative: InitiativeDetail,
  agentRunId?: string,
): Promise<{ researchRunId: string; findings: KpiFinding[] }> {
  const tracker = await getLatestTrackerForInitiative(initiative.id);
  const trackerContext = tracker.items.slice(0, 6).map((item) => `${item.itemType ?? ""} ${item.description}`);
  const terms = buildSearchTerms(initiative, trackerContext);

  const researchRunId = createId("kpi_research");
  await db.insert(kpiResearchRuns).values({
    id: researchRunId,
    initiativeId: initiative.id,
    agentRunId: agentRunId ?? null,
    status: "running",
    summary: {
      terms,
    },
  });

  try {
    const [searchHits, snowflakeOutput] = await withTimeout(
      Promise.all([
        searchAnalyticsCorpus(terms),
        runSnowflakeDiscovery(terms),
      ]),
      KPI_RESEARCH_TIMEOUT_MS,
      `KPI research for ${initiative.code}`,
    );

    const findings: KpiFinding[] = [
      ...deriveTrackerFindings(tracker),
      ...searchHits.map((hit) => ({
        id: createId("kpi"),
        findingClass: "analytics_reference",
        sourceType: hit.sourceType,
        metricKey: slugify(hit.lineText.slice(0, 60) || path.basename(hit.filePath)),
        label: hit.lineText.slice(0, 120) || path.basename(hit.filePath),
        metricValue: null,
        unit: null,
        narrative: "Ranked analytics-code reference discovered during KPI research.",
        sourceRef: `${hit.filePath}:${hit.lineNumber}`,
        provenance: {
          filePath: hit.filePath,
          lineNumber: hit.lineNumber,
          lineText: hit.lineText,
          score: hit.score,
          findingPriority: hit.score >= 10 ? "high_signal_reference" : "reference",
        },
      })),
      ...(snowflakeOutput
        ? [
            {
              id: createId("kpi"),
              findingClass: "analytics_reference",
              sourceType: "snowflake_search",
              metricKey: "snowflake_object_matches",
              label: "Snowflake object discovery",
              metricValue: null,
              unit: null,
              narrative: "Potential analytics objects discovered in Snowflake metadata for this SI.",
              sourceRef: "analytics.information_schema.columns",
              provenance: {
                queryTerms: terms,
                output: snowflakeOutput,
                findingPriority: "warehouse_reference",
              },
            },
          ]
        : []),
      ...deriveProposedFindings(initiative, tracker),
    ];

    if (findings.length > 0) {
      await db.insert(kpiFindings).values(
        findings.map((finding) => ({
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
          searchHitCount: searchHits.length,
          trackerFindingCount: findings.filter((finding) => finding.sourceType === "tracker").length,
          proposedFindingCount: findings.filter((finding) => finding.findingClass === "proposal").length,
          snowflakeOutput,
        },
        finishedAt: new Date(),
      })
      .where(eq(kpiResearchRuns.id, researchRunId));

    return { researchRunId, findings };
  } catch (error) {
    const fallbackFindings = [
      ...deriveTrackerFindings(tracker),
      ...deriveProposedFindings(initiative, tracker),
      ...await getLatestCompletedFindingsForInitiative(initiative.id, researchRunId),
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
          fallback: true,
          reusedFindingCount: fallbackFindings.length,
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
