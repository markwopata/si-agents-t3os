import { Buffer } from "node:buffer";
import { promisify } from "node:util";
import { execFile as execFileCallback } from "node:child_process";
import { mkdtemp, rm, writeFile } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { XMLParser } from "fast-xml-parser";
import JSZip from "jszip";
import { and, desc, eq, inArray, sql } from "drizzle-orm";
import { db } from "../db/client.js";
import {
  documentContentExtracts,
  googleFileSnapshots,
  slackFileEvents,
} from "../db/schema.js";
import { createId } from "../lib/id.js";
import { getGoogleAccessToken } from "../integrations/google/service.js";
import { decryptSecret } from "../lib/crypto.js";
import { slackInstallations } from "../db/schema.js";

const execFile = promisify(execFileCallback);
const EXTRACTION_TIMEOUT_MS = 20_000;
const FETCH_TIMEOUT_MS = 15_000;
const xmlParser = new XMLParser({
  ignoreAttributes: false,
  attributeNamePrefix: "@_",
  trimValues: true,
});

type ExtractStatus = "completed" | "empty" | "unsupported" | "failed";

interface ExtractResult {
  extractor: string;
  extractionStatus: ExtractStatus;
  extractedText: string;
  summary: string;
  metadata?: Record<string, unknown>;
}

interface ExtractSource {
  initiativeId: string;
  syncRunId: string | null;
  sourceType: "slack_file" | "google_file";
  sourceKey: string;
  sourceId: string;
  parentSourceId: string | null;
  title: string;
  mimeType: string | null;
  sourceUpdatedAt: Date | null;
  metadata: Record<string, unknown>;
  fetchContent: () => Promise<ExtractResult>;
}

const SUPPORTED_EXTENSIONS = new Set([
  ".txt",
  ".md",
  ".csv",
  ".json",
  ".yaml",
  ".yml",
  ".xml",
  ".html",
  ".sql",
  ".log",
  ".pdf",
  ".docx",
  ".xlsx",
  ".pptx",
]);

const SUPPORTED_MIME_PREFIXES = ["text/"];
const SUPPORTED_MIME_TYPES = new Set([
  "application/pdf",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  "application/vnd.openxmlformats-officedocument.presentationml.presentation",
  "application/vnd.google-apps.document",
  "application/vnd.google-apps.spreadsheet",
  "application/vnd.google-apps.presentation",
]);

function asArray<T>(value: T | T[] | undefined): T[] {
  if (Array.isArray(value)) {
    return value;
  }
  return value === undefined ? [] : [value];
}

function compactWhitespace(text: string): string {
  return text.replace(/\u0000/g, "").replace(/\s+/g, " ").trim();
}

function decodeXmlEntities(text: string): string {
  return text
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'");
}

function summarize(text: string, limit = 280): string {
  const compact = compactWhitespace(text);
  if (compact.length <= limit) {
    return compact;
  }
  return `${compact.slice(0, limit - 1)}…`;
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function sanitizeJsonValue(value: unknown): unknown {
  if (typeof value === "string") {
    return value.replace(/\u0000/g, "");
  }
  if (Array.isArray(value)) {
    return value.map((entry) => sanitizeJsonValue(entry));
  }
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>).map(([key, entry]) => [key, sanitizeJsonValue(entry)]),
    );
  }
  return value;
}

async function withTimeout<T>(promise: Promise<T>, timeoutMs: number, label: string): Promise<T> {
  return Promise.race([
    promise,
    new Promise<T>((_, reject) => {
      setTimeout(() => reject(new Error(`${label} timed out after ${timeoutMs}ms`)), timeoutMs);
    }),
  ]);
}

function extensionOf(name: string): string {
  return path.extname(name).toLowerCase();
}

function isSupportedExtractionTarget(mimeType: string | null, title: string): boolean {
  const normalizedMimeType = mimeType?.toLowerCase() ?? "";
  if (SUPPORTED_MIME_PREFIXES.some((prefix) => normalizedMimeType.startsWith(prefix))) {
    return true;
  }
  if (SUPPORTED_MIME_TYPES.has(normalizedMimeType)) {
    return true;
  }
  return SUPPORTED_EXTENSIONS.has(extensionOf(title));
}

function unsupportedResult(mimeType: string | null, title: string): ExtractResult {
  return {
    extractor: "unsupported",
    extractionStatus: "unsupported",
    extractedText: "",
    summary: `Unsupported document type: ${mimeType || extensionOf(title) || "unknown"}`,
  };
}

async function extractPdfText(buffer: Buffer): Promise<string> {
  const tempDir = await mkdtemp(path.join(os.tmpdir(), "si-agent-pdf-"));
  const inputPath = path.join(tempDir, "document.pdf");
  try {
    await writeFile(inputPath, buffer);
    const { stdout } = await execFile(
      "/opt/homebrew/bin/pdftotext",
      [inputPath, "-"],
      { timeout: EXTRACTION_TIMEOUT_MS },
    );
    return compactWhitespace(stdout);
  } finally {
    await rm(tempDir, { recursive: true, force: true });
  }
}

function extractTextLike(buffer: Buffer): string {
  return compactWhitespace(buffer.toString("utf8"));
}

async function extractDocxText(buffer: Buffer): Promise<string> {
  const zip = await JSZip.loadAsync(buffer);
  const xmlParts = await Promise.all(
    Object.keys(zip.files)
      .filter((name) => /^word\/(document|header\d+|footer\d+)\.xml$/.test(name))
      .sort()
      .map(async (name) => decodeXmlEntities(await zip.files[name]!.async("text"))),
  );
  return compactWhitespace(
    xmlParts
      .join("\n")
      .replace(/<[^>]+>/g, " ")
      .replace(/\s+/g, " "),
  );
}

async function extractPptxText(buffer: Buffer): Promise<string> {
  const zip = await JSZip.loadAsync(buffer);
  const slideParts = await Promise.all(
    Object.keys(zip.files)
      .filter((name) => /^ppt\/slides\/slide\d+\.xml$/.test(name))
      .sort()
      .map(async (name) => decodeXmlEntities(await zip.files[name]!.async("text"))),
  );
  const texts = slideParts.flatMap((xml) =>
    Array.from(xml.matchAll(/<a:t>(.*?)<\/a:t>/g)).map((match) => decodeXmlEntities(match[1] ?? "")),
  );
  return compactWhitespace(texts.join("\n"));
}

async function extractXlsxText(buffer: Buffer): Promise<string> {
  const zip = await JSZip.loadAsync(buffer);
  const sharedStringsXml = zip.file("xl/sharedStrings.xml");
  const sharedStrings = sharedStringsXml
    ? asArray((xmlParser.parse(await sharedStringsXml.async("text"))?.sst?.si) ?? []).map((si: any) => {
        const direct = si?.t;
        if (typeof direct === "string") {
          return direct;
        }
        const rich = asArray(si?.r).map((part: any) => part?.t ?? "").join("");
        return rich;
      })
    : [];

  const worksheetTexts: string[] = [];
  for (const name of Object.keys(zip.files).filter((file) => /^xl\/worksheets\/sheet\d+\.xml$/.test(file)).sort()) {
    const parsed = xmlParser.parse(await zip.files[name]!.async("text"));
    const rows = asArray(parsed?.worksheet?.sheetData?.row);
    for (const row of rows) {
      const cells = asArray(row?.c);
      const values = cells
        .map((cell: any) => {
          if (cell?.["@_t"] === "s") {
            const index = Number(cell?.v ?? -1);
            return Number.isFinite(index) && index >= 0 ? sharedStrings[index] ?? "" : "";
          }
          if (typeof cell?.is?.t === "string") {
            return cell.is.t;
          }
          if (typeof cell?.v === "string" || typeof cell?.v === "number") {
            return String(cell.v);
          }
          return "";
        })
        .filter(Boolean);
      if (values.length > 0) {
        worksheetTexts.push(values.join(" | "));
      }
    }
  }

  return compactWhitespace(worksheetTexts.join("\n"));
}

async function extractFromBuffer(input: {
  buffer: Buffer;
  mimeType: string | null;
  title: string;
}): Promise<ExtractResult> {
  const mimeType = input.mimeType?.toLowerCase() ?? "";
  const extension = extensionOf(input.title);

  if (
    mimeType.startsWith("text/") ||
    ["", ".txt", ".md", ".csv", ".json", ".yaml", ".yml", ".xml", ".html", ".sql", ".log"].includes(extension)
  ) {
    const extractedText = extractTextLike(input.buffer);
    return {
      extractor: "plain_text",
      extractionStatus: extractedText ? "completed" : "empty",
      extractedText,
      summary: summarize(extractedText),
    };
  }

  if (mimeType === "application/pdf" || extension === ".pdf") {
    const extractedText = await extractPdfText(input.buffer);
    return {
      extractor: "pdftotext",
      extractionStatus: extractedText ? "completed" : "empty",
      extractedText,
      summary: summarize(extractedText),
    };
  }

  if (
    mimeType === "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ||
    extension === ".docx"
  ) {
    const extractedText = await extractDocxText(input.buffer);
    return {
      extractor: "docx_xml",
      extractionStatus: extractedText ? "completed" : "empty",
      extractedText,
      summary: summarize(extractedText),
    };
  }

  if (
    mimeType === "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" ||
    extension === ".xlsx"
  ) {
    const extractedText = await extractXlsxText(input.buffer);
    return {
      extractor: "xlsx_xml",
      extractionStatus: extractedText ? "completed" : "empty",
      extractedText,
      summary: summarize(extractedText),
    };
  }

  if (
    mimeType === "application/vnd.openxmlformats-officedocument.presentationml.presentation" ||
    extension === ".pptx"
  ) {
    const extractedText = await extractPptxText(input.buffer);
    return {
      extractor: "pptx_xml",
      extractionStatus: extractedText ? "completed" : "empty",
      extractedText,
      summary: summarize(extractedText),
    };
  }

  return unsupportedResult(input.mimeType, input.title);
}

async function fetchGoogleBuffer(url: string, accessToken: string): Promise<Buffer> {
  for (let attempt = 0; attempt < 8; attempt += 1) {
    const response = await fetch(url, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
      signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
    });
    if (response.status === 429) {
      const retryAfterSeconds = Number(response.headers.get("retry-after") ?? String(5 * (attempt + 1)));
      await sleep((Number.isFinite(retryAfterSeconds) ? retryAfterSeconds : 5 * (attempt + 1)) * 1000);
      continue;
    }
    if (!response.ok) {
      throw new Error(`Google content fetch failed with HTTP ${response.status}`);
    }
    const arrayBuffer = await response.arrayBuffer();
    return Buffer.from(arrayBuffer);
  }
  throw new Error("Google content fetch exhausted retry attempts after repeated rate limits");
}

async function fetchGoogleJson<T>(url: URL, accessToken: string): Promise<T> {
  for (let attempt = 0; attempt < 8; attempt += 1) {
    const response = await fetch(url, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });
    if (response.status === 429) {
      const retryAfterSeconds = Number(response.headers.get("retry-after") ?? String(5 * (attempt + 1)));
      await sleep((Number.isFinite(retryAfterSeconds) ? retryAfterSeconds : 5 * (attempt + 1)) * 1000);
      continue;
    }
    if (!response.ok) {
      throw new Error(`Google API fetch failed with HTTP ${response.status}`);
    }
    return (await response.json()) as T;
  }
  throw new Error("Google API fetch exhausted retry attempts after repeated rate limits");
}

async function extractGoogleNativeSpreadsheet(fileId: string, accessToken: string): Promise<ExtractResult> {
  const metadataUrl = new URL(`https://sheets.googleapis.com/v4/spreadsheets/${fileId}`);
  metadataUrl.searchParams.set("fields", "sheets.properties.title");
  const metadata = await fetchGoogleJson<{
    sheets?: Array<{ properties?: { title?: string } }>;
  }>(metadataUrl, accessToken);

  const titles = asArray(metadata.sheets)
    .map((sheet) => sheet.properties?.title)
    .filter((value): value is string => Boolean(value))
    .slice(0, 12);
  const lines: string[] = [];

  for (const title of titles) {
    const valuesUrl = new URL(
      `https://sheets.googleapis.com/v4/spreadsheets/${fileId}/values/${encodeURIComponent(`'${title}'!A1:Z200`)}`,
    );
    let payload: { values?: string[][] };
    try {
      payload = await fetchGoogleJson<{ values?: string[][] }>(valuesUrl, accessToken);
    } catch {
      continue;
    }
    lines.push(`# ${title}`);
    for (const row of payload.values ?? []) {
      const compactRow = row.map((cell) => compactWhitespace(String(cell))).filter(Boolean);
      if (compactRow.length > 0) {
        lines.push(compactRow.join(" | "));
      }
    }
  }

  const extractedText = compactWhitespace(lines.join("\n"));
  return {
    extractor: "google_sheets_api",
    extractionStatus: extractedText ? "completed" : "empty",
    extractedText,
    summary: summarize(extractedText),
    metadata: {
      sheetCount: titles.length,
    },
  };
}

async function extractGoogleFileContent(input: {
  fileId: string;
  mimeType: string | null;
  title: string;
  accessToken: string;
}): Promise<ExtractResult> {
  const mimeType = input.mimeType ?? "";

  if (mimeType === "application/vnd.google-apps.folder") {
    return {
      extractor: "folder",
      extractionStatus: "unsupported",
      extractedText: "",
      summary: "Folders are crawled structurally but not extracted as a document.",
    };
  }

  if (mimeType === "application/vnd.google-apps.document") {
    const buffer = await fetchGoogleBuffer(
      `https://www.googleapis.com/drive/v3/files/${input.fileId}/export?mimeType=text/plain`,
      input.accessToken,
    );
    const extractedText = extractTextLike(buffer);
    return {
      extractor: "google_docs_export",
      extractionStatus: extractedText ? "completed" : "empty",
      extractedText,
      summary: summarize(extractedText),
    };
  }

  if (mimeType === "application/vnd.google-apps.spreadsheet") {
    return extractGoogleNativeSpreadsheet(input.fileId, input.accessToken);
  }

  if (mimeType === "application/vnd.google-apps.presentation") {
    const buffer = await fetchGoogleBuffer(
      `https://www.googleapis.com/drive/v3/files/${input.fileId}/export?mimeType=application/pdf`,
      input.accessToken,
    );
    const extractedText = await extractPdfText(buffer);
    return {
      extractor: "google_slides_pdf",
      extractionStatus: extractedText ? "completed" : "empty",
      extractedText,
      summary: summarize(extractedText),
    };
  }

  const buffer = await fetchGoogleBuffer(
    `https://www.googleapis.com/drive/v3/files/${input.fileId}?alt=media&supportsAllDrives=true`,
    input.accessToken,
  );
  return extractFromBuffer({
    buffer,
    mimeType: input.mimeType,
    title: input.title,
  });
}

async function getSlackAccessToken(): Promise<string | null> {
  const installation = await db.query.slackInstallations.findFirst({
    orderBy: [desc(slackInstallations.updatedAt)],
  });
  return installation ? decryptSecret(installation.accessTokenEncrypted) : null;
}

async function upsertExtract(source: ExtractSource): Promise<{
  extractionStatus: ExtractStatus;
  extractor: string;
}> {
  const existing = await db.query.documentContentExtracts.findFirst({
    where: and(
      eq(documentContentExtracts.sourceType, source.sourceType),
      eq(documentContentExtracts.sourceKey, source.sourceKey),
    ),
  });

  if (
    existing &&
    ((existing.sourceUpdatedAt === null && source.sourceUpdatedAt === null) ||
      (existing.sourceUpdatedAt && source.sourceUpdatedAt && existing.sourceUpdatedAt.getTime() === source.sourceUpdatedAt.getTime())) &&
    existing.extractionStatus !== "failed"
  ) {
    return {
      extractionStatus: existing.extractionStatus as ExtractStatus,
      extractor: existing.extractor,
    };
  }

  let result: ExtractResult;
  try {
    result = await withTimeout(source.fetchContent(), EXTRACTION_TIMEOUT_MS, `Extraction for ${source.title}`);
  } catch (error) {
    result = {
      extractor: "error",
      extractionStatus: "failed",
      extractedText: "",
      summary: error instanceof Error ? error.message : "Extraction failed",
      metadata: {
        error: error instanceof Error ? error.message : String(error),
      },
    };
  }

  const values = {
    initiativeId: source.initiativeId,
    syncRunId: source.syncRunId,
    sourceType: source.sourceType,
    sourceKey: source.sourceKey,
    sourceId: source.sourceId,
    parentSourceId: source.parentSourceId,
    title: source.title.replace(/\u0000/g, ""),
    mimeType: source.mimeType?.replace(/\u0000/g, "") ?? null,
    extractor: result.extractor,
    extractionStatus: result.extractionStatus,
    extractedText: result.extractedText.replace(/\u0000/g, ""),
    summary: result.summary.replace(/\u0000/g, ""),
    sourceUpdatedAt: source.sourceUpdatedAt,
    metadata: sanitizeJsonValue({
      ...source.metadata,
      ...(result.metadata ?? {}),
    }) as Record<string, unknown>,
    updatedAt: new Date(),
  };

  await db
    .insert(documentContentExtracts)
    .values({
      id: existing?.id ?? createId("doc_extract"),
      createdAt: existing?.createdAt ?? new Date(),
      ...values,
    })
    .onConflictDoUpdate({
      target: [documentContentExtracts.sourceType, documentContentExtracts.sourceKey],
      set: values,
    });

  return {
    extractionStatus: result.extractionStatus,
    extractor: result.extractor,
  };
}

export async function extractDocumentsForInitiative(input: {
  initiativeId: string;
  slackRunIds?: string[];
  googleRunId?: string | null;
}): Promise<{
  processedCount: number;
  completedCount: number;
  unsupportedCount: number;
  failedCount: number;
}> {
  const slackWhere =
    input.slackRunIds && input.slackRunIds.length > 0
      ? and(
          eq(slackFileEvents.initiativeId, input.initiativeId),
          inArray(slackFileEvents.syncRunId, input.slackRunIds),
        )
      : eq(slackFileEvents.initiativeId, input.initiativeId);
  const googleWhere = input.googleRunId
    ? and(
        eq(googleFileSnapshots.initiativeId, input.initiativeId),
        eq(googleFileSnapshots.syncRunId, input.googleRunId),
      )
    : eq(googleFileSnapshots.initiativeId, input.initiativeId);

  const [slackFiles, googleFiles, googleAccessToken, slackAccessToken] = await Promise.all([
    db.query.slackFileEvents.findMany({
      where: slackWhere,
      orderBy: [desc(slackFileEvents.createdAt)],
      limit: 400,
    }),
    db.query.googleFileSnapshots.findMany({
      where: googleWhere,
      orderBy: [desc(googleFileSnapshots.modifiedTime), desc(googleFileSnapshots.createdAt)],
      limit: 800,
    }),
    getGoogleAccessToken(),
    getSlackAccessToken(),
  ]);

  const sources: ExtractSource[] = [];

  if (slackAccessToken) {
    for (const file of slackFiles) {
      const downloadUrl = file.privateDownloadUrl ?? file.privateUrl;
      if (!downloadUrl) {
        continue;
      }
      sources.push({
        initiativeId: input.initiativeId,
        syncRunId: file.syncRunId,
        sourceType: "slack_file",
        sourceKey: `${file.channelId}:${file.messageTs}:${file.slackFileId}`,
        sourceId: file.slackFileId,
        parentSourceId: file.parentTs ?? null,
        title: file.name ?? file.title ?? file.slackFileId,
        mimeType: file.mimeType,
        sourceUpdatedAt: null,
        metadata: {
          channelId: file.channelId,
          messageTs: file.messageTs,
          permalink: file.permalink,
        },
        fetchContent: async () => {
          if (!isSupportedExtractionTarget(file.mimeType, file.name ?? file.title ?? file.slackFileId)) {
            return unsupportedResult(file.mimeType, file.name ?? file.title ?? file.slackFileId);
          }
          const response = await fetch(downloadUrl, {
            headers: {
              Authorization: `Bearer ${slackAccessToken}`,
            },
            signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
          });
          if (!response.ok) {
            throw new Error(`Slack attachment fetch failed with HTTP ${response.status}`);
          }
          const buffer = Buffer.from(await response.arrayBuffer());
          return extractFromBuffer({
            buffer,
            mimeType: file.mimeType,
            title: file.name ?? file.title ?? file.slackFileId,
          });
        },
      });
    }
  }

  if (googleAccessToken) {
    for (const file of googleFiles) {
      if (file.mimeType === "application/vnd.google-apps.folder") {
        continue;
      }
      sources.push({
        initiativeId: input.initiativeId,
        syncRunId: file.syncRunId,
        sourceType: "google_file",
        sourceKey: file.fileId,
        sourceId: file.fileId,
        parentSourceId: file.parentFileId,
        title: file.name,
        mimeType: file.mimeType,
        sourceUpdatedAt: file.modifiedTime,
        metadata: {
          webViewLink: file.webViewLink,
          depth: file.depth,
          crawlPath: file.crawlPath,
        },
        fetchContent: () => {
          if (!isSupportedExtractionTarget(file.mimeType, file.name)) {
            return Promise.resolve(unsupportedResult(file.mimeType, file.name));
          }
          return extractGoogleFileContent({
            fileId: file.fileId,
            mimeType: file.mimeType,
            title: file.name,
            accessToken: googleAccessToken,
          });
        },
      });
    }
  }

  const dedupedSources = Array.from(
    new Map(sources.map((source) => [`${source.sourceType}:${source.sourceKey}`, source])).values(),
  );

  let completedCount = 0;
  let unsupportedCount = 0;
  let failedCount = 0;

  const concurrency = 6;
  let cursor = 0;
  const workers = Array.from({ length: Math.min(concurrency, dedupedSources.length) }, async () => {
    while (cursor < dedupedSources.length) {
      const currentIndex = cursor;
      cursor += 1;
      const result = await upsertExtract(dedupedSources[currentIndex]!);
      if (result.extractionStatus === "completed") {
        completedCount += 1;
      } else if (result.extractionStatus === "unsupported") {
        unsupportedCount += 1;
      } else if (result.extractionStatus === "failed") {
        failedCount += 1;
      }
    }
  });

  await Promise.all(workers);

  return {
    processedCount: dedupedSources.length,
    completedCount,
    unsupportedCount,
    failedCount,
  };
}

export async function getDocumentExtractsForInitiative(initiativeId: string, limit = 40) {
  const rows = await db.query.documentContentExtracts.findMany({
    where: eq(documentContentExtracts.initiativeId, initiativeId),
    orderBy: [desc(documentContentExtracts.updatedAt)],
    limit,
  });

  return rows.map((row) => ({
    id: row.id,
    sourceType: row.sourceType,
    sourceKey: row.sourceKey,
    sourceId: row.sourceId,
    parentSourceId: row.parentSourceId,
    title: row.title,
    mimeType: row.mimeType,
    extractor: row.extractor,
    extractionStatus: row.extractionStatus,
    summary: row.summary,
    extractedText: row.extractedText,
    sourceUpdatedAt: row.sourceUpdatedAt?.toISOString() ?? null,
    metadata: row.metadata,
    updatedAt: row.updatedAt.toISOString(),
  }));
}

export async function summarizeDocumentExtractsForInitiative(
  initiativeId: string,
  limit = 12,
): Promise<string> {
  const rows = await getDocumentExtractsForInitiative(initiativeId, limit);
  return rows
    .filter((row) => row.extractionStatus === "completed" && row.extractedText.trim())
    .map((row) => `## ${row.title}\n${row.summary}`)
    .join("\n\n");
}
