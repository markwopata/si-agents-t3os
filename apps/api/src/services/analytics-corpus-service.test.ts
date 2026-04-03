import { describe, expect, it } from "vitest";
import {
  classifyAnalyticsSourceType,
  shouldIncludeAnalyticsFile,
} from "./analytics-corpus-service.js";

describe("shouldIncludeAnalyticsFile", () => {
  const root = "/tmp/analytics";

  it("keeps KPI-relevant analytics assets and excludes sensitive or noisy files", () => {
    expect(shouldIncludeAnalyticsFile("/tmp/analytics/ba-finance-dbt/models/finance/revenue.sql", root)).toBe(true);
    expect(shouldIncludeAnalyticsFile("/tmp/analytics/looker/views/training.lkml", root)).toBe(true);
    expect(shouldIncludeAnalyticsFile("/tmp/analytics/README.md", root)).toBe(true);

    expect(shouldIncludeAnalyticsFile("/tmp/analytics/.env", root)).toBe(false);
    expect(shouldIncludeAnalyticsFile("/tmp/analytics/AGENT_BOOTSTRAP.md", root)).toBe(false);
    expect(shouldIncludeAnalyticsFile("/tmp/analytics/dbt_project.yml", root)).toBe(false);
    expect(shouldIncludeAnalyticsFile("/tmp/analytics/.github/workflows/build.yml", root)).toBe(false);
    expect(shouldIncludeAnalyticsFile("/tmp/analytics/scripts/seed.py", root)).toBe(false);
  });
});

describe("classifyAnalyticsSourceType", () => {
  it("classifies curated analytics files for provenance", () => {
    expect(classifyAnalyticsSourceType("/tmp/analytics/ba-finance-dbt/models/finance/revenue.sql")).toBe(
      "dbt_model",
    );
    expect(classifyAnalyticsSourceType("/tmp/analytics/looker/views/training.lkml")).toBe("looker_model");
    expect(classifyAnalyticsSourceType("/tmp/analytics/ba-finance-dbt/models/schema.yml")).toBe(
      "semantic_metadata",
    );
    expect(classifyAnalyticsSourceType("/tmp/analytics/docs/property-fees.md")).toBe("analytics_doc");
  });
});
