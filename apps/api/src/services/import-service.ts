import fs from "node:fs/promises";
import path from "node:path";
import {
  type ImportSummary,
  type InitiativeLinkInput,
  type InitiativePersonInput,
  type PeriodSnapshotInput,
} from "@si/domain";
import { and, eq } from "drizzle-orm";
import { db } from "../db/client.js";
import {
  initiatives,
  sourceImportBatches,
  sourceImportRows,
} from "../db/schema.js";
import { env } from "../config/env.js";
import { createId } from "../lib/id.js";
import { resolveFromProjectRoot } from "../lib/paths.js";
import { parseWorkbook } from "../lib/workbook.js";
import {
  replaceInitiativeLinks,
  replaceInitiativePeople,
  replaceInitiativeSnapshots,
  upsertKnowledgeDocument,
} from "./initiative-service.js";

const PERSON_COLUMNS: Array<{ column: string; role: InitiativePersonInput["role"] }> = [
  { column: "T", role: "exec_owner" },
  { column: "U", role: "group_owner" },
  { column: "V", role: "initiative_owner" },
  { column: "W", role: "si_analytics_owner" },
  { column: "X", role: "sales_lead" },
  { column: "Y", role: "ops_lead" },
  { column: "Z", role: "analytics_lead" },
  { column: "AA", role: "pm" },
  { column: "AB", role: "other_invitee" },
];

const LINK_COLUMNS: Array<{ column: string; linkType: InitiativeLinkInput["linkType"] }> = [
  { column: "N", linkType: "folder" },
  { column: "O", linkType: "channel" },
  { column: "P", linkType: "playbook" },
  { column: "Q", linkType: "dashboard" },
  { column: "R", linkType: "other" },
];

function cellText(
  row: Record<string, { value: string | number | boolean | null; hyperlink?: string }>,
  column: string,
): string {
  const value = row[column]?.value;
  if (value === undefined || value === null) {
    return "";
  }
  return typeof value === "string" ? value.trim() : String(value);
}

function slugify(value: string): string {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

export function splitMultiPersonCell(value: string): string[] {
  const normalized = value
    .replace(/\n/g, ",")
    .replace(/\s{2,}/g, ",")
    .replace(/\//g, ",")
    .replace(/;/g, ",");

  const basicParts = normalized
    .split(",")
    .map((part) => part.trim())
    .filter(Boolean);

  if (basicParts.length > 1) {
    return basicParts;
  }

  const words = value.trim().split(/\s+/);
  if (words.length >= 4 && words.length % 2 === 0) {
    const pairs: string[] = [];
    for (let index = 0; index < words.length; index += 2) {
      pairs.push(`${words[index]} ${words[index + 1]}`.trim());
    }
    return pairs;
  }

  return value.trim() ? [value.trim()] : [];
}

export function normalizePeople(
  row: Record<string, { value: string | number | boolean | null; hyperlink?: string }>,
): InitiativePersonInput[] {
  const people: InitiativePersonInput[] = [];

  for (const [sortOrder, mapping] of PERSON_COLUMNS.entries()) {
    const value = cellText(row, mapping.column);
    if (!value) {
      continue;
    }

    const emailLink = row[mapping.column]?.hyperlink;
    const email =
      typeof emailLink === "string" && emailLink.startsWith("mailto:")
        ? emailLink.replace("mailto:", "")
        : null;

    const names = splitMultiPersonCell(value);
    names.forEach((name, nameIndex) => {
      people.push({
        role: mapping.role,
        displayName: name,
        email: names.length === 1 ? email : null,
        sortOrder: sortOrder * 10 + nameIndex,
        sourceType: "local",
      });
    });
  }

  return people;
}

export function normalizeLinks(
  row: Record<string, { value: string | number | boolean | null; hyperlink?: string }>,
): InitiativeLinkInput[] {
  return LINK_COLUMNS.map((mapping, index) => {
    const label = cellText(row, mapping.column);
    const url = row[mapping.column]?.hyperlink ?? "";
    return {
      linkType: mapping.linkType,
      label,
      url,
      sortOrder: index,
    };
  }).filter((link) => link.label || link.url);
}

export function normalizeSnapshots(
  row: Record<string, { value: string | number | boolean | null; hyperlink?: string }>,
): PeriodSnapshotInput[] {
  const financialPeriod = "Q2-2026-financial";
  const kpiPeriod = "Q2-2025-ops-kpi";
  const snapshots: PeriodSnapshotInput[] = [];

  if (
    cellText(row, "AK") ||
    cellText(row, "AL") ||
    cellText(row, "AM") ||
    cellText(row, "AN") ||
    cellText(row, "AO")
  ) {
    snapshots.push({
      periodKey: financialPeriod,
      category: "financial",
      status: cellText(row, "AK"),
      baselineValue: [cellText(row, "AL"), cellText(row, "AN")].filter(Boolean).join(" | "),
      bookedValue: [cellText(row, "AM"), cellText(row, "AO")].filter(Boolean).join(" | "),
    });
  }

  if (cellText(row, "AQ") || cellText(row, "AR") || cellText(row, "AS")) {
    snapshots.push({
      periodKey: kpiPeriod,
      category: "kpi",
      status: cellText(row, "AQ"),
      baselineValue: cellText(row, "AR"),
      bookedValue: cellText(row, "AS"),
    });
  }

  return snapshots;
}

async function seedGlobalKnowledge(): Promise<void> {
  const knowledgePath = path.isAbsolute(env.GLOBAL_KNOWLEDGE_PATH)
    ? env.GLOBAL_KNOWLEDGE_PATH
    : resolveFromProjectRoot(env.GLOBAL_KNOWLEDGE_PATH);
  const content = await fs.readFile(knowledgePath, "utf8");
  await upsertKnowledgeDocument({
    documentType: "global",
    slug: "global-si-operating-model",
    title: "Strategic Initiatives Operating Model",
    content,
  });
}

export async function importWorkbookFromBuffer(
  buffer: Buffer,
  sourcePath: string,
): Promise<ImportSummary> {
  await seedGlobalKnowledge();
  const workbook = await parseWorkbook(buffer);
  const siList = workbook.sheets.find((sheet) => sheet.name === "SI List");
  if (!siList) {
    throw new Error("Workbook does not contain an 'SI List' sheet");
  }

  const batchId = createId("import");
  let importedCount = 0;
  let skippedCount = 0;
  const warnings: string[] = [];

  await db.insert(sourceImportBatches).values({
    id: batchId,
    sourceName: "Strategic Initiatives Workbook",
    sourcePath,
    status: "running",
    summary: {},
  });

  const headerRow = siList.rows.find((row) => row.rowNumber === 2);
  if (!headerRow) {
    throw new Error("Workbook is missing the SI header row");
  }

  for (const row of siList.rows) {
    if (row.rowNumber < 3) {
      continue;
    }

    const nameCell = cellText(row.cells, "A");
    if (!nameCell) {
      continue;
    }

    if (!/^\d{3}\s+/.test(nameCell)) {
      skippedCount += 1;
      continue;
    }

    const [codePart, ...titleParts] = nameCell.split(" ");
    const code = codePart ?? "";
    const title = titleParts.join(" ").trim();
    if (!title) {
      skippedCount += 1;
      continue;
    }
    const mapped = {
      code,
      title,
      objective: cellText(row.cells, "B"),
      group: cellText(row.cells, "D"),
      targetCadence: cellText(row.cells, "E"),
      updateType: cellText(row.cells, "F"),
      stage: cellText(row.cells, "G"),
      lClass: cellText(row.cells, "H"),
      progress: cellText(row.cells, "J"),
      leadPerformance: cellText(row.cells, "K"),
      administrationHealth: cellText(row.cells, "L"),
      impactType: cellText(row.cells, "AD"),
      inCapPlan:
        cellText(row.cells, "AE").toLowerCase() === "yes"
          ? true
          : cellText(row.cells, "AE").toLowerCase() === "no"
            ? false
            : null,
      sourceRowNumber: row.rowNumber,
    };

    const people = normalizePeople(row.cells);
    const links = normalizeLinks(row.cells);
    const snapshots = normalizeSnapshots(row.cells);

    await db.insert(sourceImportRows).values({
      id: createId("import_row"),
      batchId,
      sheetName: siList.name,
      rowNumber: row.rowNumber,
      rowKey: code,
      rawJson: {
        row: row.cells,
      },
      mappedJson: {
        initiative: mapped,
        people,
        links,
        snapshots,
      },
    });

    const existing = await db.query.initiatives.findFirst({
      where: eq(initiatives.code, code),
    });

    const initiativeId = existing?.id ?? createId("initiative");

    if (existing) {
      await db
        .update(initiatives)
        .set({
          ...mapped,
          isActive: true,
          updatedAt: new Date(),
        })
        .where(eq(initiatives.id, existing.id));
    } else {
      await db.insert(initiatives).values({
        id: initiativeId,
        ...mapped,
        isActive: true,
      });
    }

    await replaceInitiativePeople(initiativeId, people);
    await replaceInitiativeLinks(initiativeId, links);
    await replaceInitiativeSnapshots(initiativeId, snapshots);
    await upsertKnowledgeDocument({
      initiativeId,
      documentType: "initiative",
      slug: `initiative-${slugify(code)}-${slugify(title)}`,
      title: `${code} ${title} Notes`,
      content: [
        `# ${code} ${title}`,
        "",
        "## Objective",
        mapped.objective || "Add the current SI objective here.",
        "",
        "## Initial Operating Notes",
        "- Capture the lead's current top blockers.",
        "- Capture recent wins and decisions.",
        "- Capture KPI definitions and update expectations.",
      ].join("\n"),
    });

    importedCount += 1;
  }

  if (importedCount === 0) {
    warnings.push("No initiatives were imported from the workbook.");
  }

  await db
    .update(sourceImportBatches)
    .set({
      status: "completed",
      summary: {
        importedCount,
        skippedCount,
        warnings,
      },
    })
    .where(and(eq(sourceImportBatches.id, batchId)));

  return {
    batchId,
    importedCount,
    skippedCount,
    warnings,
  };
}

export async function importWorkbookFromFile(sourcePath: string): Promise<ImportSummary> {
  const buffer = await fs.readFile(sourcePath);
  return importWorkbookFromBuffer(buffer, sourcePath);
}
