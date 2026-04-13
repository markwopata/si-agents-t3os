import type {
  AnalyticsDomain,
  AnalyticsDomainCatalog,
  AnalyticsDomainKey,
  AnalyticsPromptCandidate,
  AnalyticsSensitivityTier,
} from "@si/domain";
import { count, desc, sql } from "drizzle-orm";
import { db } from "../db/client.js";
import {
  slackMessageEvents,
  slackReplyEvents,
  slackWorkspaceMessageEvents,
} from "../db/schema.js";

const ANALYTICS_DOMAIN_WINDOW_LIMIT = 5000;
const DEFAULT_PROMPT_LIMIT = 5;
const QUESTION_SIGNAL_PATTERN =
  /\?|(^|\s)(what|why|how|which|where|when|who|can|could|does|do|did|should|is|are|would)\b/i;
const ANALYTICS_INTENT_PATTERN =
  /\b(analy[sz]e|compare|explain|forecast|pull|replicate|show|tie\s*out|validate|breakdown|trend|impact|logic|query|dashboard|report)\b/i;
const GREETING_PREFIX_PATTERN =
  /^(hi|hello|hey|morning|good morning|afternoon|good afternoon|evening|good evening|thanks|thank you)[!,.\s:;-]+/i;
const SLACK_MARKUP_PATTERN = /<([^>|]+)\|([^>]+)>|<([^>]+)>/g;
const INLINE_CODE_PATTERN = /`[^`]+`/g;
const BLOCK_CODE_PATTERN = /```[\s\S]*?```/g;

type DomainSeed = {
  key: AnalyticsDomainKey;
  label: string;
  description: string;
  sensitivityTier: AnalyticsSensitivityTier;
  canonicalTerms: string[];
  sourceFamilies: string[];
  organizingQuestions: string[];
  seedPromptExamples: string[];
  keywords: string[];
};

type SlackObservation = {
  id: string;
  initiativeId: string;
  channelId: string;
  channelName: string | null;
  permalink: string | null;
  text: string;
  messageAt: Date | null;
  sourceType: "slack_message" | "slack_reply";
};

type DomainMatch = {
  score: number;
  matchedTerms: string[];
};

const DOMAIN_SEEDS: DomainSeed[] = [
  {
    key: "branch_earnings",
    label: "Branch Earnings and P&L",
    description:
      "Questions about branch earnings, branch-level P&L, market performance, operational drivers, and local scorecards.",
    sensitivityTier: "finance_restricted",
    canonicalTerms: [
      "branch earnings",
      "branch p&l",
      "net income",
      "ebitda",
      "margin drivers",
      "opex",
      "scorecard",
      "revenue pacing",
    ],
    sourceFamilies: [
      "ba-finance-dbt marts/branch_earnings",
      "Market Dashboard",
      "Trending Branch Earnings",
      "Branch Earnings Dashboard",
      "branch scorecards",
      "regional finance dashboards",
      "branch earnings review workflows",
    ],
    organizingQuestions: [
      "Why did branch earnings move this month?",
      "Which branch-level categories are driving the gap?",
      "Which branch, region, or market is outperforming or underperforming?",
    ],
    seedPromptExamples: [
      "Why did February branch earnings move versus January, and which line items explain the change?",
      "Show the biggest drivers of branch net income variance for the Southeast region this quarter.",
      "Compare branch scorecard performance for the top 20 branches versus plan.",
      "Show the markets driving the biggest branch earnings variance this week.",
    ],
    keywords: [
      "branch earnings",
      "branch p&l",
      "market dashboard",
      "trending branch earnings",
      "net income",
      "ebitda",
      "margin",
      "opex",
      "scorecard",
      "revenue pacing",
      "earnings",
      "p&l",
      "profit",
    ],
  },
  {
    key: "general_ledger_accounting",
    label: "General Ledger and Accounting",
    description:
      "Accounting truth, journal-level behavior, close, reconciliations, AP and collections workflows, chart of accounts, and posting logic.",
    sensitivityTier: "finance_restricted",
    canonicalTerms: [
      "GL",
      "general ledger",
      "journal entry",
      "trial balance",
      "close",
      "reconciliation",
      "Intacct",
    ],
    sourceFamilies: [
      "intacct models",
      "accounting marts",
      "AP - Bills",
      "Collectors Manager Dashboard",
      "Individual Credit Cards",
      "trial balance workflows",
      "close and reconciliation reporting",
    ],
    organizingQuestions: [
      "How did this entry hit the GL?",
      "Why does the trial balance not tie out?",
      "Which accounting workflow is the source of truth for this posting question?",
    ],
    seedPromptExamples: [
      "Explain how this transaction flowed through the GL and which journal entries were created.",
      "Why does the trial balance not tie out for this branch and period?",
      "Show the journal-entry populations behind this reconciliation break.",
      "Which AP bills or collector populations are driving finance operations volume this month?",
    ],
    keywords: [
      "gl",
      "general ledger",
      "journal entry",
      "trial balance",
      "close",
      "reconciliation",
      "intacct",
      "posting",
      "accounting",
      "tie out",
      "accrual",
      "ap bills",
      "collectors",
      "credit cards",
    ],
  },
  {
    key: "fixed_assets_depreciation",
    label: "Fixed Assets and Depreciation",
    description:
      "Fixed-asset register, capex, depreciation, transfers, disposals, and book-value questions.",
    sensitivityTier: "finance_restricted",
    canonicalTerms: [
      "fixed asset",
      "asset register",
      "depreciation",
      "capex",
      "NBV",
      "book value",
      "asset transfer",
    ],
    sourceFamilies: [
      "fixed asset subledger",
      "depreciation schedules",
      "capex reporting",
      "asset accounting models",
    ],
    organizingQuestions: [
      "How is depreciation calculated for this asset population?",
      "What changed in the fixed-asset register this month?",
      "How do transfers, disposals, and book value roll through accounting?",
    ],
    seedPromptExamples: [
      "Show depreciation expense by asset class and branch for the last 12 months.",
      "Which fixed-asset transfers changed NBV for this region this quarter?",
      "Explain how this disposal moved through the fixed-asset ledger and GL.",
    ],
    keywords: [
      "fixed asset",
      "asset register",
      "depreciation",
      "capex",
      "nbv",
      "book value",
      "asset transfer",
      "disposal",
      "placed in service",
      "useful life",
    ],
  },
  {
    key: "customer_revenue_performance",
    label: "Customers, Sales, and Revenue",
    description:
      "Customer performance, sales productivity, revenue mix, key-account trends, rental revenue, quote activity, and customer-level profitability questions.",
    sensitivityTier: "customer_sensitive",
    canonicalTerms: [
      "customer revenue",
      "rental revenue",
      "key account",
      "customer profitability",
      "revenue mix",
      "cohort",
    ],
    sourceFamilies: [
      "Customer Dashboard",
      "Company Look Up",
      "Salesperson",
      "Equipment Sales Quote Request",
      "revenue marts",
      "customer analytics dashboards",
      "rental revenue reporting",
      "account-level performance workflows",
    ],
    organizingQuestions: [
      "Which customers or segments are driving revenue growth?",
      "What changed in revenue mix by customer, branch, or product line?",
      "Which accounts are most profitable or at risk?",
      "Which sales reps, quotes, or account relationships are driving commercial performance?",
    ],
    seedPromptExamples: [
      "Show rental revenue by top 50 customers and highlight the biggest movers versus last quarter.",
      "Which key accounts are losing share in this market and what products are driving the decline?",
      "Compare customer profitability across branches for national accounts versus local accounts.",
      "Rank salespeople by customer revenue growth and quote conversion in their home markets.",
    ],
    keywords: [
      "customer revenue",
      "rental revenue",
      "revenue",
      "customer profitability",
      "customer",
      "customer dashboard",
      "key account",
      "account",
      "cohort",
      "revenue mix",
      "bookings",
      "salesperson",
      "quote request",
      "company look up",
    ],
  },
  {
    key: "pricing_rate_achievement",
    label: "Pricing and Rate Achievement",
    description:
      "Pricing logic, rate achievement, benchmark and floor rates, expiration logic, and commission impacts.",
    sensitivityTier: "operational_sensitive",
    canonicalTerms: [
      "rate achievement",
      "benchmark rate",
      "floor rate",
      "points",
      "rate start date",
      "commission impact",
    ],
    sourceFamilies: [
      "analytics.public.rateachievement_points",
      "Benchmark and Online Rates by Class and Market",
      "pricing dashboards",
      "rate admin workflows",
      "pricing LookML",
    ],
    organizingQuestions: [
      "How is rate achievement calculated?",
      "When does a rate change take effect?",
      "How did a pricing change impact commission or margin?",
    ],
    seedPromptExamples: [
      "Explain how rate achievement points are calculated for this invoice and what changed after the rate update.",
      "Compare benchmark, floor, and invoiced rates for 10K telehandlers in Florida.",
      "What commission impact came from the August rate achievement increase in Southeast Florida?",
    ],
    keywords: [
      "rate achievement",
      "benchmark rate",
      "floor rate",
      "points",
      "pricing",
      "benchmark and online rates",
      "rate agreement",
      "rate start date",
      "rates",
      "commission payout",
    ],
  },
  {
    key: "fleet_assets_utilization",
    label: "Fleet, Inventory, Assets, OEC, and Utilization",
    description:
      "Fleet composition, inventory position, asset detail, availability, OEC, utilization, market-level asset views, and rental fleet mix.",
    sensitivityTier: "operational_sensitive",
    canonicalTerms: [
      "inventory information",
      "asset details",
      "asset availability",
      "OEC",
      "utilization",
      "on-rent",
      "unavailable OEC",
      "fleet breakdown",
      "asset historical",
    ],
    sourceFamilies: [
      "Inventory Information",
      "Asset Details",
      "Asset Availability Finder",
      "analytics.assets",
      "market-level asset metrics",
      "fleet dashboards",
      "asset financing snapshots",
    ],
    organizingQuestions: [
      "What is the OEC or utilization by market, class, or date?",
      "Where can I look up asset detail or inventory by market and class?",
      "How much unavailable OEC is sitting in the fleet?",
      "Which dashboard or model is the right starting point for fleet analysis?",
    ],
    seedPromptExamples: [
      "Show rental fleet OEC by region at the end of last quarter and break out unavailable OEC.",
      "Which markets are underperforming on utilization for 6K and 10K telehandlers?",
      "Where should I start if I need equipment utilization data for asset historical analysis?",
      "Find available assets by class and market and drill into the asset detail records behind them.",
    ],
    keywords: [
      "inventory information",
      "asset details",
      "asset availability",
      "oec",
      "utilization",
      "on-rent",
      "unavailable oec",
      "fleet",
      "asset historical",
      "equipment utilization",
      "afs",
      "rental fleet",
    ],
  },
  {
    key: "maintenance_work_orders",
    label: "Maintenance and Work Orders",
    description:
      "Work orders, downtime, shop labor, service dashboard behavior, warranty activity, parts usage, PM compliance, and repair-cycle performance.",
    sensitivityTier: "operational_sensitive",
    canonicalTerms: [
      "work order",
      "downtime",
      "shop labor",
      "parts usage",
      "PM compliance",
      "repair cycle time",
      "hard-down",
    ],
    sourceFamilies: [
      "Service Dashboard",
      "Warranty Overview",
      "Parts Transactions",
      "work-order sources",
      "service and maintenance dashboards",
      "shop labor reporting",
      "downtime workflows",
    ],
    organizingQuestions: [
      "Which work orders are driving downtime or cost?",
      "How fast are repairs moving through the shop?",
      "What parts, labor, or failure patterns are hurting fleet availability?",
      "Which service and warranty workflows are getting used most heavily by the field?",
    ],
    seedPromptExamples: [
      "Show work-order volume, downtime days, and repair cycle time by branch for the last 90 days.",
      "Which asset classes are driving the highest maintenance cost per unit this quarter?",
      "Compare PM compliance and hard-down incidents by region.",
      "Show parts transactions and warranty volume by market and branch for the last 30 days.",
    ],
    keywords: [
      "work order",
      "maintenance",
      "service dashboard",
      "warranty",
      "parts transactions",
      "downtime",
      "shop labor",
      "parts usage",
      "pm compliance",
      "repair cycle time",
      "hard-down",
      "service order",
      "wo",
    ],
  },
  {
    key: "fleet_optimization_tco",
    label: "Fleet Optimization and TCO",
    description:
      "Total cost to own, work-order and depreciation logic, and optimization work that compares fleet classes or ownership choices.",
    sensitivityTier: "operational_sensitive",
    canonicalTerms: [
      "TCO",
      "total cost to own",
      "depreciation",
      "hard-down lost revenue",
      "work order cost",
      "Rouse value",
    ],
    sourceFamilies: [
      "fleet_optimization.gold.fact_total_cost_to_own",
      "fleet analytics domain docs",
      "optimization models",
      "work-order cost sources",
    ],
    organizingQuestions: [
      "How does the TCO formula work for this class?",
      "What data sources improve TCO accuracy?",
      "Which fleet choices create the best ownership economics?",
    ],
    seedPromptExamples: [
      "Walk me through the official TCO formula for TL12 versus JD333 and list the key cost drivers.",
      "Compare actual TCO versus inferred TCO for 10K telehandlers.",
      "Which repos or docs explain how the fleet optimization model is built?",
    ],
    keywords: [
      "tco",
      "total cost to own",
      "depreciation",
      "hard-down",
      "work order cost",
      "work_order",
      "rouse",
      "markdown",
      "optimization",
    ],
  },
  {
    key: "materials",
    label: "Materials and Distribution",
    description:
      "Materials revenue, BiSTrack coverage, Sage bridges, and location-level data limitations in materials workflows.",
    sensitivityTier: "operational_sensitive",
    canonicalTerms: [
      "materials revenue",
      "BiSTrack",
      "Sage",
      "Forge & Build",
      "location coverage",
      "parts and service revenue",
    ],
    sourceFamilies: [
      "analytics.bt_dbo",
      "materials marts",
      "Sage-linked finance logic",
      "materials dashboards",
    ],
    organizingQuestions: [
      "What material revenue do we trust by location and month?",
      "Which stores are not on BiSTrack?",
      "Where does the Sage bridge create limitations or reconciliation work?",
    ],
    seedPromptExamples: [
      "Show monthly materials revenue by location and flag stores that are not on BiSTrack.",
      "Explain whether this materials location is covered by BiSTrack and what data is missing if it is not.",
      "Tie Sage revenue entries back to materials reporting for this location.",
    ],
    keywords: [
      "materials revenue",
      "materials",
      "bistrack",
      "sage",
      "forge & build",
      "parts and service",
      "location id",
    ],
  },
  {
    key: "people_payroll",
    label: "People, Compensation, and Payroll",
    description:
      "Payroll detail, compensation history, hours worked, and sensitive people-system analysis.",
    sensitivityTier: "confidential_people",
    canonicalTerms: [
      "Workday",
      "payroll",
      "hours worked",
      "base compensation",
      "bonus",
      "fringe",
      "pay component",
    ],
    sourceFamilies: [
      "people_analytics.workday_raas",
      "payroll detail",
      "base compensation history",
      "People Systems workflows",
    ],
    organizingQuestions: [
      "How do payroll detail and compensation history line up?",
      "What hours or pay components explain a variance?",
      "Which questions require elevated sensitivity controls?",
    ],
    seedPromptExamples: [
      "Compare payroll hours and pay components for this team across the last two quarters.",
      "What changed in Workday payroll detail that explains the fringe variance?",
      "Which payroll questions should be blocked or routed to a restricted workflow?",
    ],
    keywords: [
      "workday",
      "payroll",
      "hours worked",
      "hours",
      "base compensation",
      "bonus",
      "fringe",
      "pay component",
      "salary",
      "employee",
    ],
  },
  {
    key: "learning_training",
    label: "Learning and Training",
    description:
      "Training completion, enrollment history, and operational or external training coverage using Docebo data.",
    sensitivityTier: "broad_internal",
    canonicalTerms: [
      "Docebo",
      "training completion",
      "enrollment history",
      "certification",
      "external training",
    ],
    sourceFamilies: [
      "analytics.docebo",
      "people_analytics.docebo",
      "training reports",
      "external training workflows",
    ],
    organizingQuestions: [
      "Can we replicate a training completion report from Snowflake?",
      "How has external training progressed over time?",
      "What Docebo entities or tables are the right starting point?",
    ],
    seedPromptExamples: [
      "Replicate the training completion report for the Meta mega project and show trend over time.",
      "Which Docebo tables should I start with for enrollment history and users?",
      "How much external training activity is captured in the current Docebo pipeline?",
    ],
    keywords: [
      "docebo",
      "training",
      "enrollment history",
      "certification",
      "completion",
      "users",
      "external training",
    ],
  },
  {
    key: "planning_management_reporting",
    label: "Planning and Management Reporting",
    description:
      "Anaplan, cash-flow forecasting, planning workflows, target setting, and management-reporting outputs.",
    sensitivityTier: "finance_restricted",
    canonicalTerms: [
      "Anaplan",
      "cash flow forecast",
      "management reporting",
      "target drift",
      "scenario analysis",
      "planning",
    ],
    sourceFamilies: [
      "marts/anaplan",
      "cash-flow forecast reports",
      "planning spreadsheets",
      "management reporting artifacts",
    ],
    organizingQuestions: [
      "Which planning metric belongs in Anaplan versus the warehouse?",
      "How do we explain variance in the current planning output?",
      "What should be ETL'd into Snowflake for reporting?",
    ],
    seedPromptExamples: [
      "Summarize the weekly cash flow forecast and highlight the biggest drivers versus prior week.",
      "Which SI KPI data should live in Anaplan versus the warehouse?",
      "Compare the current planning output to the monthly FP&A reporting package.",
    ],
    keywords: [
      "anaplan",
      "cash flow forecast",
      "cash flow",
      "planning",
      "scenario analysis",
      "fp&a",
      "forecast",
      "management reporting",
      "weekly cash flow",
    ],
  },
  {
    key: "ownership_program",
    label: "OWN Program",
    description:
      "OWN Program volume, enrollments, payouts, revenue share, and program performance analysis.",
    sensitivityTier: "finance_restricted",
    canonicalTerms: [
      "OWN Program",
      "OWN enrollment",
      "revenue share",
      "payouts",
      "program volume",
      "related party",
    ],
    sourceFamilies: [
      "OWN payout tables",
      "OWN enrollment sources",
      "program performance reporting",
      "asset ownership sources",
    ],
    organizingQuestions: [
      "How much OWN Program activity are we doing?",
      "How should payouts or related-party percentages be interpreted?",
      "Which markets, branches, or asset classes are driving program performance?",
    ],
    seedPromptExamples: [
      "How much OWN Program volume are we on pace to do this year?",
      "Show the relationship between OWN Program payouts and OEC enrolled in the program.",
      "Which branches are generating the most OWN Program activity and revenue share this quarter?",
    ],
    keywords: [
      "own program",
      "own enrollment",
      "revenue share",
      "payout",
      "related party",
      "program volume",
      "own payout",
    ],
  },
  {
    key: "asset_disposition_valuation",
    label: "Asset Disposition and Valuation",
    description:
      "Asset sales, buybacks, wholesale values, resale performance, residual assumptions, and disposition economics.",
    sensitivityTier: "finance_restricted",
    canonicalTerms: [
      "asset disposition",
      "asset sale",
      "wholesale value",
      "Rouse value",
      "residual",
      "buyback",
      "valuation",
    ],
    sourceFamilies: [
      "asset sale reporting",
      "Rouse estimate models",
      "buyback workflows",
      "valuation and resale artifacts",
    ],
    organizingQuestions: [
      "What value should we assign to this asset population?",
      "How are resale proceeds comparing to expectation?",
      "Which channels, classes, or regions are driving disposition performance?",
    ],
    seedPromptExamples: [
      "Compare actual resale proceeds to wholesale value for assets sold in the last two quarters.",
      "Which asset classes have the biggest gap between residual assumptions and realized sale value?",
      "Show buyback and disposition activity by OEM, class, and branch.",
    ],
    keywords: [
      "asset disposition",
      "asset sale",
      "wholesale value",
      "rouse value",
      "residual",
      "buyback",
      "valuation",
      "disposition",
      "resale",
      "wholesale",
    ],
  },
];

function compactWhitespace(value: string): string {
  return value.replace(/\s+/g, " ").trim();
}

export function cleanSlackText(text: string): string {
  return compactWhitespace(
    text
      .replace(BLOCK_CODE_PATTERN, " ")
      .replace(INLINE_CODE_PATTERN, " ")
      .replace(SLACK_MARKUP_PATTERN, (_match, rawUrl: string | undefined, label: string | undefined, plain: string | undefined) => {
        if (typeof label === "string" && label.trim()) {
          return ` ${label} `;
        }
        if (typeof plain === "string" && plain.trim()) {
          if (plain.startsWith("@") || plain.startsWith("#")) {
            return " ";
          }
          return ` ${plain} `;
        }
        if (typeof rawUrl === "string" && rawUrl.trim()) {
          return " ";
        }
        return " ";
      })
      .replace(/[\r\n\t]+/g, " "),
  );
}

function canonicalizePrompt(text: string): string {
  const cleaned = cleanSlackText(text).replace(GREETING_PREFIX_PATTERN, "");
  if (!cleaned) {
    return "";
  }
  const normalized = cleaned.charAt(0).toUpperCase() + cleaned.slice(1);
  if (/[?!.]$/.test(normalized)) {
    return normalized;
  }
  return `${normalized}?`;
}

function topTerms(terms: Map<string, number>, limit = 8): string[] {
  return Array.from(terms.entries())
    .sort((left, right) => right[1] - left[1] || left[0].localeCompare(right[0]))
    .slice(0, limit)
    .map(([term]) => term);
}

export function scoreDomainMatch(text: string, domain: Pick<DomainSeed, "keywords">): DomainMatch {
  const lowered = cleanSlackText(text).toLowerCase();
  const matchedTerms = domain.keywords.filter((term) => lowered.includes(term.toLowerCase()));
  if (matchedTerms.length === 0) {
    return {
      score: 0,
      matchedTerms: [],
    };
  }

  const phraseBoost = matchedTerms.some((term) => term.includes(" ")) ? 0.2 : 0;
  return {
    score: Math.min(0.95, 0.2 + matchedTerms.length * 0.14 + phraseBoost),
    matchedTerms: Array.from(new Set(matchedTerms)),
  };
}

export function extractPromptCandidate(input: {
  domain: Pick<DomainSeed, "key" | "keywords">;
  observation: SlackObservation;
}): AnalyticsPromptCandidate | null {
  const cleaned = cleanSlackText(input.observation.text);
  if (cleaned.length < 24 || cleaned.length > 420) {
    return null;
  }

  const domainMatch = scoreDomainMatch(cleaned, input.domain);
  if (domainMatch.score <= 0) {
    return null;
  }

  const questionSignal = QUESTION_SIGNAL_PATTERN.test(cleaned) ? 0.28 : 0;
  const analyticsSignal = ANALYTICS_INTENT_PATTERN.test(cleaned) ? 0.18 : 0;
  const confidence = Math.min(0.97, 0.2 + domainMatch.score + questionSignal + analyticsSignal);
  if (confidence < 0.62) {
    return null;
  }

  const prompt = canonicalizePrompt(cleaned);
  if (!prompt) {
    return null;
  }

  return {
    domainKey: input.domain.key,
    prompt,
    observedText: cleaned,
    sourceType: input.observation.sourceType,
    sourceId: input.observation.id,
    initiativeId: input.observation.initiativeId,
    channelId: input.observation.channelId,
    channelName: input.observation.channelName,
    permalink: input.observation.permalink,
    confidence: Number(confidence.toFixed(2)),
    rationale: "Observed Slack message matched domain language and looked like an analytics-style question or request.",
    matchedTerms: domainMatch.matchedTerms,
    messageAt: input.observation.messageAt?.toISOString() ?? null,
  };
}

function dedupePromptCandidates(candidates: AnalyticsPromptCandidate[], limit: number): AnalyticsPromptCandidate[] {
  const bestByPrompt = new Map<string, AnalyticsPromptCandidate>();
  for (const candidate of candidates) {
    const key = candidate.prompt.toLowerCase();
    const existing = bestByPrompt.get(key);
    if (!existing || candidate.confidence > existing.confidence) {
      bestByPrompt.set(key, candidate);
    }
  }

  return Array.from(bestByPrompt.values())
    .sort((left, right) => right.confidence - left.confidence || left.prompt.localeCompare(right.prompt))
    .slice(0, limit);
}

async function loadSlackObservations(): Promise<{
  storedSlackMessages: number;
  storedSlackReplies: number;
  messages: SlackObservation[];
  replies: SlackObservation[];
}> {
  const [
    workspaceMessageCountResult,
    workspaceRows,
    messageCountResult,
    replyCountResult,
    messageRows,
    replyRows,
  ] = await Promise.all([
    db.select({ value: count() }).from(slackWorkspaceMessageEvents),
    db
      .select({
        id: slackWorkspaceMessageEvents.id,
        initiativeId: sql<string | null>`null`,
        channelId: slackWorkspaceMessageEvents.channelId,
        channelName: sql<string | null>`null`,
        permalink: slackWorkspaceMessageEvents.permalink,
        text: slackWorkspaceMessageEvents.text,
        messageAt: slackWorkspaceMessageEvents.messageAt,
        isThreadReply: slackWorkspaceMessageEvents.isThreadReply,
      })
      .from(slackWorkspaceMessageEvents)
      .orderBy(desc(slackWorkspaceMessageEvents.messageAt), desc(slackWorkspaceMessageEvents.createdAt))
      .limit(ANALYTICS_DOMAIN_WINDOW_LIMIT),
    db.select({ value: count() }).from(slackMessageEvents),
    db.select({ value: count() }).from(slackReplyEvents),
    db
      .select({
        id: slackMessageEvents.id,
        initiativeId: slackMessageEvents.initiativeId,
        channelId: slackMessageEvents.channelId,
        channelName: slackMessageEvents.channelName,
        permalink: slackMessageEvents.permalink,
        text: slackMessageEvents.text,
        messageAt: slackMessageEvents.messageAt,
      })
      .from(slackMessageEvents)
      .orderBy(desc(slackMessageEvents.messageAt), desc(slackMessageEvents.createdAt))
      .limit(ANALYTICS_DOMAIN_WINDOW_LIMIT),
    db
      .select({
        id: slackReplyEvents.id,
        initiativeId: slackReplyEvents.initiativeId,
        channelId: slackReplyEvents.channelId,
        channelName: slackReplyEvents.channelId,
        permalink: slackReplyEvents.parentTs,
        text: slackReplyEvents.text,
        messageAt: slackReplyEvents.messageAt,
      })
      .from(slackReplyEvents)
      .orderBy(desc(slackReplyEvents.messageAt), desc(slackReplyEvents.createdAt))
      .limit(ANALYTICS_DOMAIN_WINDOW_LIMIT),
  ]);

  const workspaceMessageCount = Number(workspaceMessageCountResult[0]?.value ?? 0);
  if (workspaceMessageCount > 0) {
    return {
      storedSlackMessages: workspaceMessageCount,
      storedSlackReplies: 0,
      messages: workspaceRows
        .filter((row) => !row.isThreadReply)
        .map((row) => ({
          id: row.id,
          initiativeId: row.initiativeId ?? "",
          channelId: row.channelId,
          channelName: row.channelName,
          permalink: row.permalink,
          text: row.text,
          messageAt: row.messageAt,
          sourceType: "slack_message" as const,
        })),
      replies: workspaceRows
        .filter((row) => row.isThreadReply)
        .map((row) => ({
          id: row.id,
          initiativeId: row.initiativeId ?? "",
          channelId: row.channelId,
          channelName: row.channelName,
          permalink: row.permalink,
          text: row.text,
          messageAt: row.messageAt,
          sourceType: "slack_reply" as const,
        })),
    };
  }

  return {
    storedSlackMessages: Number(messageCountResult[0]?.value ?? 0),
    storedSlackReplies: Number(replyCountResult[0]?.value ?? 0),
    messages: messageRows.map((row) => ({
      ...row,
      sourceType: "slack_message" as const,
    })),
    replies: replyRows.map((row) => ({
      ...row,
      channelName: null,
      permalink: null,
      sourceType: "slack_reply" as const,
    })),
  };
}

export async function buildAnalyticsDomainCatalog(): Promise<AnalyticsDomainCatalog> {
  const observations = await loadSlackObservations();
  const analyzed = [...observations.messages, ...observations.replies];

  const domains: AnalyticsDomain[] = DOMAIN_SEEDS.map((seed) => {
    let matchedMessageCount = 0;
    let matchedReplyCount = 0;
    let lastMatchedAt: string | null = null;
    const termCounts = new Map<string, number>();
    const promptCandidates: AnalyticsPromptCandidate[] = [];

    for (const observation of analyzed) {
      const match = scoreDomainMatch(observation.text, seed);
      if (match.score <= 0) {
        continue;
      }

      if (observation.sourceType === "slack_message") {
        matchedMessageCount += 1;
      } else {
        matchedReplyCount += 1;
      }

      for (const term of match.matchedTerms) {
        termCounts.set(term, (termCounts.get(term) ?? 0) + 1);
      }

      const observedAt = observation.messageAt?.toISOString() ?? null;
      if (observedAt && (!lastMatchedAt || observedAt > lastMatchedAt)) {
        lastMatchedAt = observedAt;
      }

      const promptCandidate = extractPromptCandidate({
        domain: seed,
        observation,
      });
      if (promptCandidate) {
        promptCandidates.push(promptCandidate);
      }
    }

    return {
      key: seed.key,
      label: seed.label,
      description: seed.description,
      sensitivityTier: seed.sensitivityTier,
      canonicalTerms: seed.canonicalTerms,
      sourceFamilies: seed.sourceFamilies,
      organizingQuestions: seed.organizingQuestions,
      seedPromptExamples: seed.seedPromptExamples,
      slackSignals: {
        matchedMessageCount,
        matchedReplyCount,
        matchedTerms: topTerms(termCounts),
        lastMatchedAt,
      },
      promptCandidates: dedupePromptCandidates(promptCandidates, DEFAULT_PROMPT_LIMIT),
    };
  });

  return {
    generatedAt: new Date().toISOString(),
    sourceSummary: {
      storedSlackMessages: observations.storedSlackMessages,
      storedSlackReplies: observations.storedSlackReplies,
      analyzedSlackMessages: observations.messages.length,
      analyzedSlackReplies: observations.replies.length,
      methodology:
        "Seed domains come from the EquipmentShare intelligence handoff. Slack-backed counts and prompt candidates are derived from keyword matching over the most recent stored Slack messages and replies to keep the pilot responsive.",
    },
    domains,
  };
}
