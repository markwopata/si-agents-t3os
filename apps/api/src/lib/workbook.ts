import { XMLParser } from "fast-xml-parser";
import JSZip from "jszip";

type CellValue = string | number | boolean | null;

interface ParsedSheetRow {
  rowNumber: number;
  cells: Record<string, { value: CellValue; hyperlink?: string }>;
}

export interface ParsedWorkbook {
  sheets: Array<{
    name: string;
    rows: ParsedSheetRow[];
  }>;
}

const parser = new XMLParser({
  ignoreAttributes: false,
  attributeNamePrefix: "",
  removeNSPrefix: true,
});

function asArray<T>(value: T | T[] | undefined): T[] {
  if (value === undefined) {
    return [];
  }
  return Array.isArray(value) ? value : [value];
}

function getCellColumn(ref: string): string {
  return ref.replace(/\d+/g, "");
}

function decodeSharedValue(raw: unknown, sharedStrings: string[]): CellValue {
  if (typeof raw === "number" || typeof raw === "boolean") {
    return raw;
  }
  if (typeof raw !== "string") {
    return null;
  }
  return raw;
}

export async function parseWorkbook(buffer: Buffer): Promise<ParsedWorkbook> {
  const zip = await JSZip.loadAsync(buffer);
  const workbookXml = parser.parse(await zip.file("xl/workbook.xml")!.async("text"));
  const workbookRelsXml = parser.parse(await zip.file("xl/_rels/workbook.xml.rels")!.async("text"));
  const sheets = asArray(workbookXml.workbook.sheets.sheet);
  const relationships = asArray(workbookRelsXml.Relationships.Relationship);
  const relMap = new Map<string, string>();

  for (const rel of relationships) {
    relMap.set(rel.Id, rel.Target);
  }

  const sharedStrings: string[] = [];
  const sharedStringsFile = zip.file("xl/sharedStrings.xml");
  if (sharedStringsFile) {
    const sharedXml = parser.parse(await sharedStringsFile.async("text"));
    for (const item of asArray(sharedXml.sst.si)) {
      const texts = asArray(item.t ?? item.r).map((entry) => {
        if (typeof entry === "string") {
          return entry;
        }
        if (typeof entry?.t === "string") {
          return entry.t;
        }
        return "";
      });
      sharedStrings.push(texts.join(""));
    }
  }

  const workbookSheets: ParsedWorkbook["sheets"] = [];

  for (const sheet of sheets) {
    const relTarget = relMap.get(sheet.id);
    if (!relTarget) {
      continue;
    }

    const sheetPath = `xl/${relTarget}`;
    const sheetXml = parser.parse(await zip.file(sheetPath)!.async("text"));
    const sheetData = asArray(sheetXml.worksheet.sheetData?.row);
    const rowEntries: ParsedSheetRow[] = [];

    const links = new Map<string, string>();
    const hyperlinkEntries = asArray(sheetXml.worksheet.hyperlinks?.hyperlink);
    if (hyperlinkEntries.length > 0) {
      const relPath = sheetPath.replace("worksheets/", "worksheets/_rels/") + ".rels";
      const relFile = zip.file(relPath);
      if (relFile) {
        const relXml = parser.parse(await relFile.async("text"));
        const sheetRelMap = new Map<string, string>();
        for (const rel of asArray(relXml.Relationships.Relationship)) {
          sheetRelMap.set(rel.Id, rel.Target);
        }

        for (const link of hyperlinkEntries) {
          if (typeof link.ref === "string" && typeof link.id === "string") {
            links.set(link.ref, sheetRelMap.get(link.id) ?? "");
          }
        }
      }
    }

    for (const row of sheetData) {
      const rowNumber = Number(row.r);
      const cells = asArray(row.c);
      const mappedCells: ParsedSheetRow["cells"] = {};

      for (const cell of cells) {
        const ref = cell.r as string;
        const type = cell.t as string | undefined;
        const rawValue = cell.v ?? cell.is?.t ?? null;
        let value: CellValue = null;

        if (type === "s" && (typeof rawValue === "string" || typeof rawValue === "number")) {
          value = sharedStrings[Number(rawValue)] ?? "";
        } else {
          value = decodeSharedValue(rawValue, sharedStrings);
        }

        mappedCells[getCellColumn(ref)] = {
          value,
          hyperlink: links.get(ref),
        };
      }

      rowEntries.push({
        rowNumber,
        cells: mappedCells,
      });
    }

    workbookSheets.push({
      name: sheet.name as string,
      rows: rowEntries,
    });
  }

  return { sheets: workbookSheets };
}
