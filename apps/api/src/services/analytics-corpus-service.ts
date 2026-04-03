import { execFile as execFileCallback } from "node:child_process";
import { existsSync } from "node:fs";
import { readdir, readFile } from "node:fs/promises";
import path from "node:path";
import { promisify } from "node:util";
import type { InitiativeDetail } from "@si/domain";
import { env } from "../config/env.js";
import { resolveFromProjectRoot } from "../lib/paths.js";

const execFile = promisify(execFileCallback);

const ALLOWED_EXTENSIONS = new Set([".sql", ".lkml", ".md", ".yml", ".yaml"]);
const EXCLUDED_FILE_NAMES = new Set([
  ".env",
  ".env.example",
  "dbt_project.yml",
  "docker-compose.yml",
  "package-lock.json",
  "package.json",
  "poetry.lock",
  "pnpm-lock.yaml",
  "yarn.lock",
  "AGENT_BOOTSTRAP.md",
  "ANALYST_AGENT_SETUP.md",
]);
const EXCLUDED_PATH_SEGMENTS = [
  ".git",
  ".github",
  ".cursor",
  ".vscode",
  "node_modules",
  "dist",
  "build",
  "coverage",
  "bootstrap",
  "setup",
  "ci",
  "scripts",
  "tests",
  "__tests__",
];
const GENERIC_LINE_PATTERNS = [
  /^@property$/i,
  /^from\s+\S+/i,
  /^import\s+\S+/i,
  /^view:\s*[a-z_]+$/i,
  /^include:\s*/i,
  /^version:\s*\d+/i,
];
const METRIC_HINT_PATTERN =
  /\b(revenue|earnings|margin|fee|fees|target|baseline|forecast|booked|earned|collect|collected|throughput|utilization|count|rate|volume|profit|sales|buyback|buybacks|capex|capital|inventory|training|work order|priority|forecast)\b/i;
const SEMANTIC_HINT_PATTERN =
  /\b(measure|metric|kpi|target|goal|actual|forecast|variance|booking|bookings|revenue|margin|cost|fee|fees|training|utilization|throughput|work order|priority)\b/i;

export type AnalyticsCorpusSnippet = {
  filePath: string;
  relativePath: string;
  sourceType: string;
  score: number;
  matchedTerms: string[];
  lineStart: number;
  lineEnd: number;
  excerpt: string;
  bestLine: string;
};

function unique<T>(values: T[]): T[] {
  return Array.from(new Set(values));
}

export function resolveAnalyticsCorpusPath(): string {
  const curated = env.ANALYTICS_CURATED_CORPUS_PATH.trim();
  if (curated.length > 0) {
    return curated;
  }

  const localCuratedPath = resolveFromProjectRoot(".analytics-curated");
  if (existsSync(localCuratedPath)) {
    return localCuratedPath;
  }

  return env.ANALYTICS_CORPUS_PATH;
}

export function shouldIncludeAnalyticsFile(absolutePath: string, rootPath: string): boolean {
  const relativePath = path.relative(rootPath, absolutePath);
  if (relativePath.startsWith("..")) {
    return false;
  }

  const baseName = path.basename(absolutePath);
  if (EXCLUDED_FILE_NAMES.has(baseName)) {
    return false;
  }

  const extension = path.extname(absolutePath).toLowerCase();
  if (!ALLOWED_EXTENSIONS.has(extension)) {
    return false;
  }

  const loweredRelativePath = relativePath.replace(/\\/g, "/").toLowerCase();
  if (loweredRelativePath.includes("/secrets/") || loweredRelativePath.includes("/credentials/")) {
    return false;
  }

  return !EXCLUDED_PATH_SEGMENTS.some((segment) => loweredRelativePath.split("/").includes(segment.toLowerCase()));
}

export function classifyAnalyticsSourceType(filePath: string): string {
  const normalized = filePath.replace(/\\/g, "/").toLowerCase();
  const extension = path.extname(normalized);
  if (extension === ".yml" || extension === ".yaml") {
    return "semantic_metadata";
  }
  if (extension === ".lkml" || normalized.includes("/looker/")) {
    return "looker_model";
  }
  if (extension === ".sql" || normalized.includes("/dbt/") || normalized.includes("ba-finance-dbt")) {
    return "dbt_model";
  }
  if (extension === ".md") {
    return "analytics_doc";
  }
  return "analytics_code";
}

function sourceWeight(sourceType: string): number {
  switch (sourceType) {
    case "dbt_model":
      return 7;
    case "looker_model":
      return 6;
    case "semantic_metadata":
      return 5;
    case "analytics_doc":
      return 4;
    default:
      return 2;
  }
}

function countMatchedTerms(haystack: string, terms: string[]): string[] {
  const lowered = haystack.toLowerCase();
  return terms.filter((term) => lowered.includes(term.toLowerCase()));
}

function isUsefulAnalyticsLine(lineText: string): boolean {
  const trimmed = lineText.trim();
  if (trimmed.length < 16) {
    return false;
  }

  return !GENERIC_LINE_PATTERNS.some((pattern) => pattern.test(trimmed));
}

function computeLineScore(filePath: string, lineText: string, terms: string[]): number {
  const sourceType = classifyAnalyticsSourceType(filePath);
  const matchedTerms = countMatchedTerms(`${filePath} ${lineText}`, terms);
  const semanticHintScore = SEMANTIC_HINT_PATTERN.test(lineText) ? 4 : 0;
  const metricHintScore = METRIC_HINT_PATTERN.test(lineText) ? 3 : 0;
  const fileHintScore = METRIC_HINT_PATTERN.test(filePath) ? 2 : 0;
  return sourceWeight(sourceType) + matchedTerms.length * 3 + semanticHintScore + metricHintScore + fileHintScore;
}

function buildExcerpt(lines: string[], bestIndex: number): { lineStart: number; lineEnd: number; excerpt: string } {
  const lineStart = Math.max(0, bestIndex - 2);
  const lineEnd = Math.min(lines.length - 1, bestIndex + 2);
  const excerpt = lines
    .slice(lineStart, lineEnd + 1)
    .map((line, index) => `${lineStart + index + 1}: ${line}`)
    .join("\n")
    .trim();
  return {
    lineStart: lineStart + 1,
    lineEnd: lineEnd + 1,
    excerpt,
  };
}

async function walkAnalyticsFiles(rootPath: string, currentPath: string, results: string[]): Promise<void> {
  const entries = await readdir(currentPath, { withFileTypes: true });

  for (const entry of entries) {
    const absolutePath = path.join(currentPath, entry.name);

    if (entry.isDirectory()) {
      const loweredRelativePath = path.relative(rootPath, absolutePath).replace(/\\/g, "/").toLowerCase();
      if (EXCLUDED_PATH_SEGMENTS.some((segment) => loweredRelativePath.split("/").includes(segment.toLowerCase()))) {
        continue;
      }
      await walkAnalyticsFiles(rootPath, absolutePath, results);
      continue;
    }

    if (entry.isFile() && shouldIncludeAnalyticsFile(absolutePath, rootPath)) {
      results.push(absolutePath);
    }
  }
}

async function findCandidateFilesWithoutRipgrep(rootPath: string, terms: string[], maxFiles: number): Promise<string[]> {
  const candidateFiles: string[] = [];
  await walkAnalyticsFiles(rootPath, rootPath, candidateFiles);

  const scoredMatches: Array<{ filePath: string; score: number }> = [];
  for (const filePath of candidateFiles) {
    let contents: string;
    try {
      contents = await readFile(filePath, "utf8");
    } catch {
      continue;
    }

    const loweredContents = contents.toLowerCase();
    const loweredFilePath = filePath.toLowerCase();
    const matchedTerms = terms.filter(
      (term) => loweredFilePath.includes(term) || loweredContents.includes(term),
    );

    if (matchedTerms.length === 0) {
      continue;
    }

    const sourceType = classifyAnalyticsSourceType(filePath);
    const score =
      matchedTerms.length * 4 +
      sourceWeight(sourceType) +
      (SEMANTIC_HINT_PATTERN.test(contents) ? 4 : 0) +
      (METRIC_HINT_PATTERN.test(contents) ? 3 : 0);

    scoredMatches.push({ filePath, score });
  }

  return scoredMatches
    .sort((left, right) => right.score - left.score)
    .slice(0, maxFiles)
    .map((entry) => entry.filePath);
}

function selectBestSnippet(filePath: string, fileContents: string, terms: string[], rootPath: string): AnalyticsCorpusSnippet | null {
  const lines = fileContents.split("\n");
  let bestIndex = -1;
  let bestScore = -1;

  for (let index = 0; index < lines.length; index += 1) {
    const lineText = lines[index]?.trim() ?? "";
    if (!lineText || !isUsefulAnalyticsLine(lineText)) {
      continue;
    }
    const haystack = `${filePath} ${lineText}`.toLowerCase();
    if (!terms.some((term) => haystack.includes(term.toLowerCase()))) {
      continue;
    }
    const score = computeLineScore(filePath, lineText, terms);
    if (score > bestScore) {
      bestScore = score;
      bestIndex = index;
    }
  }

  if (bestIndex === -1 || bestScore < 7) {
    return null;
  }

  const excerpt = buildExcerpt(lines, bestIndex);
  const bestLine = lines[bestIndex]?.trim() ?? "";
  const matchedTerms = countMatchedTerms(`${filePath} ${bestLine}`, terms);
  return {
    filePath,
    relativePath: path.relative(rootPath, filePath),
    sourceType: classifyAnalyticsSourceType(filePath),
    score: bestScore,
    matchedTerms: unique(matchedTerms),
    lineStart: excerpt.lineStart,
    lineEnd: excerpt.lineEnd,
    excerpt: excerpt.excerpt,
    bestLine,
  };
}

export async function retrieveAnalyticsCorpusSnippets(input: {
  initiative: InitiativeDetail;
  trackerContext: string[];
  searchTerms: string[];
  maxFiles?: number;
  maxSnippets?: number;
}): Promise<AnalyticsCorpusSnippet[]> {
  const rootPath = resolveAnalyticsCorpusPath();
  const terms = unique(
    input.searchTerms
      .concat(
        input.initiative.code,
        input.initiative.title.split(/\s+/),
        input.initiative.objective.split(/\s+/),
        input.trackerContext.flatMap((entry) => entry.split(/\s+/)),
      )
      .map((term) => term.trim().toLowerCase())
      .filter((term) => term.length >= 4),
  ).slice(0, 14);

  if (terms.length === 0) {
    return [];
  }

  const escapedTerms = terms.map((term) => term.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
  const pattern = escapedTerms.join("|");
  const args = ["-l", "-i", "--glob", "*.{sql,lkml,md,yml,yaml}", pattern, rootPath];
  const maxFiles = input.maxFiles ?? 60;

  try {
    const { stdout } = await execFile("rg", args, {
      maxBuffer: 1024 * 1024 * 8,
      timeout: env.ANALYTICS_SEARCH_TIMEOUT_MS,
    });
    const candidateFiles = stdout
      .split("\n")
      .filter(Boolean)
      .filter((filePath) => shouldIncludeAnalyticsFile(filePath, rootPath))
      .slice(0, maxFiles);

    const snippets: AnalyticsCorpusSnippet[] = [];
    for (const filePath of candidateFiles) {
      let contents: string;
      try {
        contents = await readFile(filePath, "utf8");
      } catch {
        continue;
      }
      const snippet = selectBestSnippet(filePath, contents, terms, rootPath);
      if (snippet) {
        snippets.push(snippet);
      }
    }

    return snippets.sort((left, right) => right.score - left.score).slice(0, input.maxSnippets ?? 10);
  } catch (error) {
    const execError = error as { code?: number | string; killed?: boolean; signal?: string };
    if (execError.code === 1) {
      return [];
    }
    if (execError.code === "ETIMEDOUT" || execError.killed === true || execError.signal === "SIGTERM") {
      return [];
    }
    if (execError.code === "ENOENT") {
      const candidateFiles = await findCandidateFilesWithoutRipgrep(rootPath, terms, maxFiles);
      const snippets: AnalyticsCorpusSnippet[] = [];
      for (const filePath of candidateFiles) {
        let contents: string;
        try {
          contents = await readFile(filePath, "utf8");
        } catch {
          continue;
        }
        const snippet = selectBestSnippet(filePath, contents, terms, rootPath);
        if (snippet) {
          snippets.push(snippet);
        }
      }

      return snippets.sort((left, right) => right.score - left.score).slice(0, input.maxSnippets ?? 10);
    }
    throw error;
  }
}
