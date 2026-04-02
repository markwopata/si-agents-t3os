import { describe, expect, it } from "vitest";
import { parseTrackerValues } from "./tracker-service.js";

describe("parseTrackerValues", () => {
  it("parses tracker summary fields and row items from a standard tracker layout", () => {
    const result = parseTrackerValues({
      trackerName: "02 Initiative Approach Tracker - Op Lease Buyouts",
      trackerFileId: "sheet_1",
      sheetName: "Sheet1",
      trackerModifiedTime: "2026-04-01T00:00:00.000Z",
      values: [
        [],
        ["", "Initiative #-Name:", "002 Op Lease Buyout & Sale"],
        ["", "Initiative Leads:", "Mark / Kim"],
        [],
        ["", "Q4 Earnings Baseline:", "$1,000,000", "Q4 Booked Earnings-to-Date:", "", "$250,000"],
        ["", "Q4 Earnings Target:", "$2,000,000", "Confidence in Reaching Q4 Target:", "", "Medium"],
        [],
        [
          "",
          "Type",
          "Description",
          "",
          "",
          "",
          "",
          "Prioritization\n(enter only 1-10)",
          "Phase",
          "Q4 Impact Potential",
          "Q4 Impact Value \n(est., if applicable)",
          "Confidence in \nValue Estimate",
          "Current Value Estimate (if changed)",
          "Status\n(if applicable)",
          "Notes\n(if applicable)",
          "Last Edited",
          "Submitted By",
        ],
        [
          "",
          "",
          "(enter description here)",
          "",
          "",
          "",
          "",
          "(only label top 10 priorities)",
          "",
          "",
          "(enter value estimate here)",
          "",
          "(enter value estimate here)",
          "",
          "(enter notes or milestones completed this week)",
          "(enter date)",
          "(enter name)",
        ],
        [
          "",
          "Opportunity",
          "Increase prices charged for pick-up and delivery",
          "",
          "",
          "",
          "",
          "1",
          "Execution",
          "High",
          "$5,000,000",
          "Up",
          "$5,000,000",
          "Complete",
          "Raised the base rate",
          "09/13",
          "KM",
        ],
        [
          "",
          "Risk",
          "Counterparty approval pending",
          "",
          "",
          "",
          "",
          "2",
          "Planning",
          "Medium",
          "$500,000",
          "Down",
          "$300,000",
          "Blocked",
          "Waiting on legal review",
          "09/14",
          "MW",
        ],
        ["", "Total Value", "", "", "", "", "", "", "", "", "$0.00", "", "$0.00"],
      ],
    });

    expect(result.summaryFields.some((field) => field.label === "Q4 Earnings Target")).toBe(true);
    expect(result.summaryFields.find((field) => field.label === "Q4 Earnings Baseline")?.value).toBe("$1,000,000");
    expect(result.summaryFields.find((field) => field.label === "Q4 Booked Earnings-to-Date")?.value).toBe(
      "$250,000",
    );
    expect(result.items).toHaveLength(2);
    expect(result.items[0]?.description).toContain("Increase prices");
    expect(result.summary.totalItems).toBe(2);
    expect(result.summary.blockedItemCount).toBe(1);
  });

  it("parses tracker variants that omit last-edited columns and use annual summary labels", () => {
    const result = parseTrackerValues({
      trackerName: "05 Developer Fee Initiative Approach Tracker",
      trackerFileId: "sheet_2",
      sheetName: "2025",
      trackerModifiedTime: "2026-04-01T00:00:00.000Z",
      values: [
        [],
        ["", "SI INFORMATION"],
        ["", "Initiative:", "005 - Property Fees (Earnest, Assignment, Developer)"],
        [
          "",
          "Team:",
          "Ops: Caleb Cushman, Sales: Kim Misher, Analytics: Jamie Mormando",
        ],
        ["", "Annual Baseline", '$29.2M from GL 5990 "Other Income"'],
        ["", "Annual Target", "N/A"],
        ["", "Earned to Date", "TBD"],
        ["", "Confidence", "Low"],
        [],
        ["", "ACTIONS / ISSUES"],
        [
          "",
          "Prioritization ",
          "Type",
          "Description",
          "",
          "",
          "",
          "",
          "Phase",
          "Status",
          "Impacts >>",
          "Impact Potential",
          "Total Impact Value",
          "Captured Impact Value",
          "Notes",
        ],
        [
          "",
          "3",
          "Opportunity",
          "Track and collect earnest money pre-paid by ES from Premiere",
          "",
          "",
          "",
          "",
          "Start-Up",
          "On Track",
          "",
          "Low",
          "",
          "",
          "Think this is generally tracked by Angie",
        ],
        [
          "",
          "2",
          "Blocker",
          "Improve forecasting of developer fees",
          "",
          "",
          "",
          "",
          "Not yet started",
          "Not yet started",
          "",
          "High",
        ],
      ],
    });

    expect(result.summaryFields.some((field) => field.label === "Annual Baseline")).toBe(true);
    expect(result.summaryFields.some((field) => field.label === "Team")).toBe(true);
    expect(result.items).toHaveLength(2);
    expect(result.items[0]?.prioritization).toBe("3");
    expect(result.items[0]?.impactPotential).toBe("Low");
    expect(result.items[1]?.itemType).toBe("Blocker");
    expect(result.summary.blockedItemCount).toBe(1);
  });

  it("parses action-oriented tracker tabs that use action/issue and update/notes headers", () => {
    const result = parseTrackerValues({
      trackerName: "030 Initiative Approach Tracker - Capital Planning",
      trackerFileId: "sheet_3",
      sheetName: "Tracker",
      trackerModifiedTime: "2026-04-01T00:00:00.000Z",
      values: [
        [],
        ["", "SI INFORMATION"],
        ["", "Initiative:", "030 - Capital Planning"],
        ["", "Team:", "Sales Kim Misher Ops Russell Scott Analytics Addison Calhoun"],
        [],
        ["", "ACTIONS / ISSUES"],
        [
          "",
          "Prioritization ",
          "Type",
          "Action / Issue Description",
          "",
          "",
          "",
          "",
          "Phase",
          "Status",
          "Update / Notes",
          "",
          "",
          "",
          "Last Edited",
          "Submitted By",
        ],
        [
          "",
          "1",
          "Blocker",
          "Align payment schedule assumptions for the cap plan model",
          "",
          "",
          "",
          "",
          "Execution",
          "At Risk",
          "Waiting on finalized ops input",
          "",
          "",
          "",
          "03/15",
          "KM",
        ],
      ],
    });

    expect(result.items).toHaveLength(1);
    expect(result.items[0]?.description).toContain("cap plan model");
    expect(result.items[0]?.notes).toContain("ops input");
    expect(result.items[0]?.prioritization).toBe("1");
    expect(result.summary.blockedItemCount).toBe(1);
  });
});
