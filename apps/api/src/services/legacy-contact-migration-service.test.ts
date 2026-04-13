import { describe, expect, it } from "vitest";
import { pickHrMatch } from "./legacy-contact-migration-service.js";

describe("pickHrMatch", () => {
  it("prefers the most recent active row from the 12 month employee directory", () => {
    const result = pickHrMatch([
      {
        email: "mark.wopata@equipmentshare.com",
        employeeId: "1",
        fullName: "Older Snapshot",
        employeeTitle: "Analytics Lead",
        employeeStatus: "Active",
        directManagerName: "Manager A",
        marketId: 1,
        workPhone: null,
        source: "EE_COMPANY_DIRECTORY_12_MONTH",
        updatedAt: "2026-03-01T00:00:00Z",
      },
      {
        email: "mark.wopata@equipmentshare.com",
        employeeId: "1",
        fullName: "Fresh Snapshot",
        employeeTitle: "Analytics Lead",
        employeeStatus: "Active",
        directManagerName: "Manager A",
        marketId: 1,
        workPhone: null,
        source: "EE_COMPANY_DIRECTORY_12_MONTH",
        updatedAt: "2026-04-01T00:00:00Z",
      },
      {
        email: "mark.wopata@equipmentshare.com",
        employeeId: "1",
        fullName: "Company Directory",
        employeeTitle: "Analytics Lead",
        employeeStatus: "Active",
        directManagerName: "Manager A",
        marketId: 1,
        workPhone: null,
        source: "COMPANY_DIRECTORY",
        updatedAt: "2026-04-02T00:00:00Z",
      },
    ]);

    expect(result.status).toBe("matched_employee");
    expect(result.match?.fullName).toBe("Fresh Snapshot");
    expect(result.match?.source).toBe("EE_COMPANY_DIRECTORY_12_MONTH");
  });

  it("marks multiple active employee ids as ambiguous", () => {
    const result = pickHrMatch([
      {
        email: "shared@equipmentshare.com",
        employeeId: "1",
        fullName: "One",
        employeeTitle: "Role A",
        employeeStatus: "Active",
        directManagerName: null,
        marketId: 1,
        workPhone: null,
        source: "EE_COMPANY_DIRECTORY_12_MONTH",
        updatedAt: "2026-04-01T00:00:00Z",
      },
      {
        email: "shared@equipmentshare.com",
        employeeId: "2",
        fullName: "Two",
        employeeTitle: "Role B",
        employeeStatus: "Active",
        directManagerName: null,
        marketId: 2,
        workPhone: null,
        source: "EE_COMPANY_DIRECTORY_12_MONTH",
        updatedAt: "2026-04-02T00:00:00Z",
      },
    ]);

    expect(result.status).toBe("ambiguous_match");
    expect(result.match).toBeNull();
  });
});
