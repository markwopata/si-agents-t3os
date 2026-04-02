import { describe, expect, it } from "vitest";
import {
  normalizeLinks,
  normalizePeople,
  normalizeSnapshots,
  splitMultiPersonCell,
} from "./import-service.js";

describe("splitMultiPersonCell", () => {
  it("splits delimited cells into multiple people", () => {
    expect(splitMultiPersonCell("Mark Wopata, Ken Sacco")).toEqual([
      "Mark Wopata",
      "Ken Sacco",
    ]);
  });

  it("falls back to paired words when names are space-separated", () => {
    expect(splitMultiPersonCell("Russell Scott Brandon Howard")).toEqual([
      "Russell Scott",
      "Brandon Howard",
    ]);
  });
});

describe("normalize row helpers", () => {
  const row = {
    O: {
      value: "001-own-program-buyback",
      hyperlink: "https://equipmentshare.enterprise.slack.com/archives/C0717BZ6CCC",
    },
    N: {
      value: "01 OWN Program Buy Backs",
      hyperlink: "https://drive.google.com/drive/folders/test",
    },
    T: {
      value: "Mark Wopata",
    },
    Z: {
      value: "Russell Scott Brandon Howard",
    },
    AK: {
      value: "On Track",
    },
    AL: {
      value: "1000",
    },
    AM: {
      value: "800",
    },
    AQ: {
      value: "Needs Review",
    },
    AR: {
      value: "75",
    },
    AS: {
      value: "67",
    },
  };

  it("extracts people rows from role columns", () => {
    const people = normalizePeople(row);
    expect(people).toHaveLength(3);
    expect(people[0]?.role).toBe("exec_owner");
    expect(people[1]?.displayName).toBe("Russell Scott");
    expect(people[2]?.displayName).toBe("Brandon Howard");
  });

  it("extracts typed links from workbook cells", () => {
    const links = normalizeLinks(row);
    expect(links).toEqual([
      {
        linkType: "folder",
        label: "01 OWN Program Buy Backs",
        url: "https://drive.google.com/drive/folders/test",
        sortOrder: 0,
      },
      {
        linkType: "channel",
        label: "001-own-program-buyback",
        url: "https://equipmentshare.enterprise.slack.com/archives/C0717BZ6CCC",
        sortOrder: 1,
      },
    ]);
  });

  it("creates structured period snapshots", () => {
    const snapshots = normalizeSnapshots(row);
    expect(snapshots).toEqual([
      {
        periodKey: "Q2-2026-financial",
        category: "financial",
        status: "On Track",
        baselineValue: "1000",
        bookedValue: "800",
      },
      {
        periodKey: "Q2-2025-ops-kpi",
        category: "kpi",
        status: "Needs Review",
        baselineValue: "75",
        bookedValue: "67",
      },
    ]);
  });
});

