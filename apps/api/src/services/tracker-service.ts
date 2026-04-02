import type { InitiativeTracker } from "@si/domain";
import { desc, eq } from "drizzle-orm";
import { db } from "../db/client.js";
import {
  googleFileSnapshots,
  googleInstallations,
  trackerParseRuns,
  trackerRowItems,
  trackerSummaryFields,
} from "../db/schema.js";
import { createId } from "../lib/id.js";
import { getGoogleAccessToken } from "../integrations/google/service.js";

interface SheetsMetadataResponse {
  properties?: {
    title?: string;
  };
  sheets?: Array<{
    properties?: {
      title?: string;
    };
  }>;
}

type TrackerParseResult = {
  trackerName: string;
  trackerFileId: string;
  sheetName: string;
  summaryFields: Array<{ fieldKey: string; label: string; value: string }>;
  items: Array<{
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
    rawJson: Record<string, unknown>;
  }>;
  summary: Record<string, unknown>;
  rawSheetJson: string[][];
};

function slugify(value: string): string {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

function normalizeCell(value: string | undefined): string {
  return (value ?? "").replace(/\u0000/g, "").replace(/\s+/g, " ").trim();
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

function normalizeHeader(value: string): string {
  return value
    .toLowerCase()
    .replace(/\s+/g, " ")
    .replace(/[^\w\s/]/g, "")
    .trim();
}

function isTrackerName(name: string | null | undefined): boolean {
  const normalized = (name ?? "").toLowerCase();
  return normalized.includes("initiative approach tracker") || normalized.includes("tracker");
}

function scoreTrackerFileCandidate(input: { name: string | null | undefined; crawlPath?: string | null }): number {
  const name = (input.name ?? "").toLowerCase();
  const crawlPath = (input.crawlPath ?? "").toLowerCase();
  let score = 0;

  if (name.includes("initiative approach tracker")) {
    score += 100;
  } else if (name.includes("approach tracker")) {
    score += 85;
  } else if (name.includes("tracker")) {
    score += 50;
  }

  if (/^\d+\s+initiative approach tracker/i.test(input.name ?? "")) {
    score += 20;
  }

  if (name.includes("deal tracker")) {
    score -= 40;
  }
  if (name.includes("swot")) {
    score -= 25;
  }

  if (crawlPath.includes("initiative approach tracker")) {
    score += 15;
  }

  return score;
}

function buildSummaryFields(values: string[][], headerRowIndex: number) {
  const fields: Array<{ fieldKey: string; label: string; value: string }> = [];

  for (let rowIndex = 0; rowIndex < headerRowIndex; rowIndex += 1) {
    const row = values[rowIndex] ?? [];
    for (let columnIndex = 0; columnIndex < row.length; columnIndex += 1) {
      const label = normalizeCell(row[columnIndex]);
      if (!label) {
        continue;
      }

      const looksLikeLabel =
        label.endsWith(":") ||
        /baseline|target|booked|earned to date|confidence|initiative leads|initiative #-name|initiative|team/i.test(
          label,
        );
      if (!looksLikeLabel) {
        continue;
      }

      let value = "";
      for (let offset = 1; offset <= 3; offset += 1) {
        const candidate = normalizeCell(row[columnIndex + offset]);
        const candidateLooksLikeLabel =
          candidate.endsWith(":") ||
          /baseline|target|booked|earned to date|confidence|initiative leads|initiative #-name|initiative|team/i.test(
            candidate,
          );
        if (candidate && !candidate.startsWith("(enter") && !candidateLooksLikeLabel) {
          value = candidate;
          break;
        }
      }

      fields.push({
        fieldKey: slugify(label.replace(/:$/, "")),
        label: label.replace(/:$/, ""),
        value,
      });
    }
  }

  return fields.filter(
    (field, index, all) =>
      field.label &&
      !(field.value === "" && !/initiative leads|initiative #-name/i.test(field.label)) &&
      all.findIndex((candidate) => candidate.fieldKey === field.fieldKey) === index,
  );
}

function findHeaderRowIndex(values: string[][]): number {
  return values.findIndex((row) => {
    const normalized = row.map((cell) => normalizeHeader(cell));
    const hasDescription = normalized.some(
      (cell) =>
        cell === "description" ||
        cell.includes("description") ||
        cell === "action / issue description" ||
        cell.includes("action / issue description"),
    );
    const hasType = normalized.some((cell) => cell === "type" || cell.includes("type"));
    const trackerSignals = [
      "last edited",
      "status",
      "status if applicable",
      "phase",
      "prioritization",
      "prioritization enter only 110",
      "top 10 prioritization",
      "impact value",
      "submitted by",
      "notes",
      "update / notes",
    ];
    const signalCount = trackerSignals.filter((signal) =>
      normalized.some((cell) => cell === signal || cell.includes(signal)),
    ).length;
    return hasDescription && hasType && signalCount >= 2;
  });
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function googleFetchJson<T>(url: string, token: string): Promise<T> {
  for (let attempt = 0; attempt < 8; attempt += 1) {
    const response = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (response.status === 429) {
      const retryAfterSeconds = Number(response.headers.get("retry-after") ?? String(5 * (attempt + 1)));
      await sleep((Number.isFinite(retryAfterSeconds) ? retryAfterSeconds : 5 * (attempt + 1)) * 1000);
      continue;
    }

    if (!response.ok) {
      throw new Error(`Google API failed with HTTP ${response.status}`);
    }

    return (await response.json()) as T;
  }

  throw new Error("Google API exhausted retry attempts after repeated rate limits");
}

function getHeaderIndex(headerMap: Map<string, number>, keys: string[]): number {
  for (const key of keys) {
    const index = headerMap.get(key);
    if (typeof index === "number") {
      return index;
    }
  }
  return -1;
}

export function parseTrackerValues(input: {
  trackerName: string;
  trackerFileId: string;
  sheetName: string;
  values: string[][];
  trackerModifiedTime: string | null;
}): TrackerParseResult {
  const headerRowIndex = findHeaderRowIndex(input.values);
  if (headerRowIndex < 0) {
    throw new Error("Unable to find the tracker item header row.");
  }

  const headerRow = input.values[headerRowIndex] ?? [];
  const headerMap = new Map<string, number>();
  headerRow.forEach((header, index) => {
    headerMap.set(normalizeHeader(header), index);
  });

  const descriptionIndex = getHeaderIndex(headerMap, [
    "description",
    "action / issue description",
    "action issue description",
  ]);
  const itemTypeIndex = getHeaderIndex(headerMap, ["type"]);
  const prioritizationIndex = getHeaderIndex(headerMap, [
    "prioritization enter only 110",
    "prioritization",
    "top 10 prioritization",
  ]);
  const phaseIndex = getHeaderIndex(headerMap, ["phase"]);
  const impactPotentialIndex = getHeaderIndex(headerMap, ["q4 impact potential", "impact potential"]);
  const impactValueIndex = getHeaderIndex(headerMap, [
    "q4 impact value est if applicable",
    "q4 impact value",
    "total impact value",
  ]);
  const currentValueEstimateIndex = getHeaderIndex(headerMap, [
    "current value estimate if changed",
    "captured impact value",
  ]);
  const statusIndex = getHeaderIndex(headerMap, ["status if applicable", "status"]);
  const notesIndex = getHeaderIndex(headerMap, [
    "notes if applicable",
    "notes",
    "update / notes",
    "update notes",
  ]);
  const lastEditedIndex = getHeaderIndex(headerMap, ["last edited"]);
  const submittedByIndex = getHeaderIndex(headerMap, ["submitted by"]);
  const confidenceIndex = getHeaderIndex(headerMap, ["confidence in value estimate"]);

  const summaryFields = buildSummaryFields(input.values, headerRowIndex);
  const items: TrackerParseResult["items"] = [];

  for (let rowIndex = headerRowIndex + 1; rowIndex < input.values.length; rowIndex += 1) {
    const row = input.values[rowIndex] ?? [];
    const normalizedRow = row.map((cell) => normalizeCell(cell));
    if (normalizedRow.every((cell) => !cell)) {
      continue;
    }

    if (normalizedRow.some((cell) => /^total value$/i.test(cell))) {
      break;
    }

    const description = normalizedRow[descriptionIndex] ?? "";
    const itemType = normalizedRow[itemTypeIndex] ?? "";
    if (!description && !itemType) {
      continue;
    }

    const hasSupportingDetail = [
      normalizedRow[prioritizationIndex],
      normalizedRow[phaseIndex],
      normalizedRow[impactPotentialIndex],
      normalizedRow[impactValueIndex],
      normalizedRow[currentValueEstimateIndex],
      normalizedRow[statusIndex],
      normalizedRow[notesIndex],
      normalizedRow[lastEditedIndex],
      normalizedRow[submittedByIndex],
    ].some(Boolean);
    if (!description && itemType && !hasSupportingDetail) {
      continue;
    }

    if (/enter description here|description/i.test(description) && /^type$/i.test(itemType || "")) {
      continue;
    }

    if (/enter description here/i.test(description)) {
      continue;
    }

    items.push({
      rowNumber: rowIndex + 1,
      itemType: itemType || null,
      description,
      prioritization: normalizedRow[prioritizationIndex] || null,
      phase: normalizedRow[phaseIndex] || null,
      impactPotential: normalizedRow[impactPotentialIndex] || null,
      impactValue: normalizedRow[impactValueIndex] || null,
      confidence: normalizedRow[confidenceIndex] || null,
      currentValueEstimate: normalizedRow[currentValueEstimateIndex] || null,
      status: normalizedRow[statusIndex] || null,
      notes: normalizedRow[notesIndex] || null,
      lastEdited: normalizedRow[lastEditedIndex] || null,
      submittedBy: normalizedRow[submittedByIndex] || null,
      rawJson: sanitizeJsonValue(Object.fromEntries(
        headerRow.map((header, index) => [header || `column_${index + 1}`, normalizedRow[index] ?? ""]),
      )) as Record<string, unknown>,
    });
  }

  const blockedItems = items.filter((item) =>
    /(block|risk|delay|hold|stuck)/i.test(
      `${item.itemType ?? ""} ${item.status ?? ""} ${item.notes ?? ""}`,
    ),
  );
  const topPriorityItems = items.filter((item) => {
    const parsed = Number(item.prioritization ?? "");
    return Number.isFinite(parsed) && parsed > 0 && parsed <= 10;
  });

  return {
    trackerName: input.trackerName,
    trackerFileId: input.trackerFileId,
    sheetName: input.sheetName,
    summaryFields,
    items,
    summary: {
      trackerModifiedTime: input.trackerModifiedTime,
      totalItems: items.length,
      topPriorityCount: topPriorityItems.length,
      blockedItemCount: blockedItems.length,
      blockedExamples: blockedItems.slice(0, 5).map((item) => item.description),
      summaryFieldCount: summaryFields.length,
    },
    rawSheetJson: sanitizeJsonValue(input.values) as string[][],
  };
}

async function fetchTrackerSheet(trackerFileId: string): Promise<{
  trackerName: string;
  sheetName: string;
  values: string[][];
}> {
  const token = await getGoogleAccessToken();
  if (!token) {
    throw new Error("Google is not connected.");
  }

  const meta = await googleFetchJson<SheetsMetadataResponse>(
    `https://sheets.googleapis.com/v4/spreadsheets/${trackerFileId}?includeGridData=false`,
    token,
  );
  const trackerName = meta.properties?.title ?? trackerFileId;
  const sheetTitles = (meta.sheets ?? [])
    .map((sheet) => sheet.properties?.title)
    .filter((title): title is string => Boolean(title));

  const scoredSheets: Array<{ title: string; score: number; values: string[][] }> = [];
  for (const sheetName of sheetTitles.slice(0, 8)) {
    const range = `'${sheetName.replace(/'/g, "''")}'!A1:Q500`;
    let valuesPayload: { values?: string[][] };
    try {
      valuesPayload = await googleFetchJson<{ values?: string[][] }>(
        `https://sheets.googleapis.com/v4/spreadsheets/${trackerFileId}/values/${encodeURIComponent(range)}`,
        token,
      );
    } catch {
      continue;
    }

    const values = valuesPayload.values ?? [];
    const headerRowIndex = findHeaderRowIndex(values);
    let score = headerRowIndex >= 0 ? 500 - headerRowIndex : 0;
    const normalizedTitle = sheetName.toLowerCase();
    if (normalizedTitle.includes("tracker")) {
      score += 40;
    }
    if (normalizedTitle.includes("prioritized")) {
      score += 30;
    }
    if (normalizedTitle.includes("approach")) {
      score += 20;
    }
    scoredSheets.push({ title: sheetName, score, values });
  }

  const bestSheet =
    scoredSheets.sort((left, right) => right.score - left.score)[0] ??
    ({
      title: sheetTitles[0] ?? "Sheet1",
      score: 0,
      values: [],
    } as const);

  return {
    trackerName,
    sheetName: bestSheet.title,
    values: bestSheet.values,
  };
}

async function resolveLatestTrackerSnapshot(initiativeId: string): Promise<{
  trackerFileId: string;
  trackerName: string;
  trackerModifiedTime: string | null;
} | null> {
  const snapshots = await db.query.googleFileSnapshots.findMany({
    where: eq(googleFileSnapshots.initiativeId, initiativeId),
    orderBy: [desc(googleFileSnapshots.modifiedTime), desc(googleFileSnapshots.createdAt)],
  });

  const tracker = Array.from(
    new Map(
      snapshots
        .filter(
          (snapshot) =>
            snapshot.mimeType === "application/vnd.google-apps.spreadsheet" && isTrackerName(snapshot.name),
        )
        .map((snapshot) => [snapshot.fileId, snapshot]),
    ).values(),
  ).sort((left, right) => {
    const scoreDiff =
      scoreTrackerFileCandidate({ name: right.name, crawlPath: right.crawlPath }) -
      scoreTrackerFileCandidate({ name: left.name, crawlPath: left.crawlPath });
    if (scoreDiff !== 0) {
      return scoreDiff;
    }
    const modifiedDiff = (right.modifiedTime?.getTime() ?? 0) - (left.modifiedTime?.getTime() ?? 0);
    if (modifiedDiff !== 0) {
      return modifiedDiff;
    }
    return right.createdAt.getTime() - left.createdAt.getTime();
  })[0];

  if (!tracker) {
    return null;
  }

  return {
    trackerFileId: tracker.fileId,
    trackerName: tracker.name,
    trackerModifiedTime: tracker.modifiedTime?.toISOString() ?? null,
  };
}

export async function parseTrackerForInitiative(
  initiativeId: string,
  googleSyncRunId?: string,
): Promise<InitiativeTracker | null> {
  const latestTracker = await resolveLatestTrackerSnapshot(initiativeId);
  if (!latestTracker) {
    return null;
  }

  const fetched = await fetchTrackerSheet(latestTracker.trackerFileId);
  const parsed = parseTrackerValues({
    trackerName: fetched.trackerName,
    trackerFileId: latestTracker.trackerFileId,
    sheetName: fetched.sheetName,
    values: fetched.values,
    trackerModifiedTime: latestTracker.trackerModifiedTime,
  });

  const parseRunId = createId("tracker_parse");
  await db.insert(trackerParseRuns).values({
    id: parseRunId,
    initiativeId,
    googleSyncRunId: googleSyncRunId ?? null,
    trackerFileId: parsed.trackerFileId,
    trackerName: parsed.trackerName,
    sheetName: parsed.sheetName,
    status: "completed",
    summary: parsed.summary,
    rawSheetJson: parsed.rawSheetJson,
  });

  if (parsed.summaryFields.length > 0) {
    await db.insert(trackerSummaryFields).values(
      parsed.summaryFields.map((field) => ({
        id: createId("tracker_summary"),
        parseRunId,
        initiativeId,
        fieldKey: field.fieldKey,
        label: field.label,
        value: field.value,
      })),
    );
  }

  if (parsed.items.length > 0) {
    for (const items of [parsed.items]) {
      await db.insert(trackerRowItems).values(
        items.map((item) => ({
          id: createId("tracker_item"),
          parseRunId,
          initiativeId,
          rowNumber: item.rowNumber,
          itemType: item.itemType,
          description: item.description,
          prioritization: item.prioritization,
          phase: item.phase,
          impactPotential: item.impactPotential,
          impactValue: item.impactValue,
          confidence: item.confidence,
          currentValueEstimate: item.currentValueEstimate,
          status: item.status,
          notes: item.notes,
          lastEdited: item.lastEdited,
          submittedBy: item.submittedBy,
          rawJson: item.rawJson,
        })),
      );
    }
  }

  return getLatestTrackerForInitiative(initiativeId);
}

export async function getLatestTrackerForInitiative(initiativeId: string): Promise<InitiativeTracker> {
  const googleInstallation = await db.query.googleInstallations.findFirst({
    orderBy: [desc(googleInstallations.updatedAt)],
  });
  const latestRun = await db.query.trackerParseRuns.findFirst({
    where: eq(trackerParseRuns.initiativeId, initiativeId),
    orderBy: [desc(trackerParseRuns.createdAt)],
  });

  if (!latestRun) {
    return {
      connected: Boolean(googleInstallation),
      initiativeId,
      latestParseRunId: null,
      trackerFileId: null,
      trackerName: null,
      sheetName: null,
      summaryFields: [],
      items: [],
      parsedAt: null,
      summary: {},
    };
  }

  const [summaryFields, items] = await Promise.all([
    db.query.trackerSummaryFields.findMany({
      where: eq(trackerSummaryFields.parseRunId, latestRun.id),
      orderBy: [desc(trackerSummaryFields.createdAt)],
    }),
    db.query.trackerRowItems.findMany({
      where: eq(trackerRowItems.parseRunId, latestRun.id),
      orderBy: (table) => table.rowNumber,
    }),
  ]);

  return {
    connected: Boolean(googleInstallation),
    initiativeId,
    latestParseRunId: latestRun.id,
    trackerFileId: latestRun.trackerFileId,
    trackerName: latestRun.trackerName,
    sheetName: latestRun.sheetName,
    summaryFields: summaryFields.map((field) => ({
      id: field.id,
      fieldKey: field.fieldKey,
      label: field.label,
      value: field.value,
    })),
    items: items.map((item) => ({
      id: item.id,
      rowNumber: item.rowNumber,
      itemType: item.itemType,
      description: item.description,
      prioritization: item.prioritization,
      phase: item.phase,
      impactPotential: item.impactPotential,
      impactValue: item.impactValue,
      confidence: item.confidence,
      currentValueEstimate: item.currentValueEstimate,
      status: item.status,
      notes: item.notes,
      lastEdited: item.lastEdited,
      submittedBy: item.submittedBy,
    })),
    parsedAt: latestRun.createdAt.toISOString(),
    summary: latestRun.summary ?? {},
  };
}
