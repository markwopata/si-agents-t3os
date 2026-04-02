import { describe, expect, it } from "vitest";
import { evaluateInitiative } from "@si/agent-core";
import type { InitiativeDetail } from "@si/domain";

function makeInitiative(overrides: Partial<InitiativeDetail> = {}): InitiativeDetail {
  const base: InitiativeDetail = {
    id: "initiative_1",
    code: "001",
    title: "Test Initiative",
    objective: "Improve process hygiene",
    group: "Ops",
    targetCadence: "Monthly",
    updateType: "Meeting",
    stage: "Execution",
    lClass: "L2",
    progress: "Current update exists",
    leadPerformance: "Solid",
    administrationHealth: "Healthy",
    impactType: "Operational",
    inCapPlan: true,
    isActive: true,
    priorityRank: null,
    priorityScore: null,
    priorityReason: null,
    prioritySource: null,
    rankingUpdatedAt: null,
    latestOpinionStatus: null,
    latestOpinionConfidence: null,
    updatedAt: new Date().toISOString(),
    sourceRowNumber: 3,
    people: [
      {
        id: "p1",
        role: "sales_lead",
        displayName: "Sales Owner",
        email: null,
        sortOrder: 1,
        sourceType: "local",
      },
      {
        id: "p2",
        role: "ops_lead",
        displayName: "Ops Owner",
        email: null,
        sortOrder: 2,
        sourceType: "local",
      },
      {
        id: "p3",
        role: "analytics_lead",
        displayName: "Analytics Owner",
        email: null,
        sortOrder: 3,
        sourceType: "local",
      },
    ],
    links: [
      { id: "l1", linkType: "channel", label: "Slack", url: "https://slack.test", sortOrder: 1 },
      { id: "l2", linkType: "folder", label: "Drive", url: "https://drive.test", sortOrder: 2 },
    ],
    snapshots: [],
    knowledgeDocument: {
      id: "k1",
      title: "Notes",
      slug: "notes",
      content: "Updated and current",
      version: 1,
      updatedAt: new Date().toISOString(),
    },
    annotations: [],
    runConfig: null,
    observations: [],
  };

  return {
    ...base,
    ...overrides,
    annotations: overrides.annotations ?? base.annotations,
  };
}

describe("evaluateInitiative", () => {
  it("marks healthy initiatives as on track", () => {
    const recentSlackTs = `${Math.floor(Date.now() / 1000)}.000100`;

    const result = evaluateInitiative({
      initiative: makeInitiative(),
      globalKnowledge: "Global guidance",
      slackEvidence: {
        connected: true,
        unreadableChannels: [],
        messages: [
          {
            channelId: "C123",
            channelName: "001-test",
            label: "001-test",
            url: "https://equipmentshare.enterprise.slack.com/archives/C123",
            ts: recentSlackTs,
            userId: "U123",
            text: "We resolved the main blocker and updated the KPI tracker.",
            permalink: "https://equipmentshare.enterprise.slack.com/archives/C123/p1710000000000100",
            replyCount: 0,
            replies: [],
          },
        ],
      },
      googleEvidence: {
        connected: true,
        files: [
          {
            linkId: "g1",
            label: "Drive",
            url: "https://drive.test/folder",
            fileId: "folder_1",
            name: "SI Folder",
            mimeType: "application/vnd.google-apps.folder",
            readable: true,
            error: null,
            modifiedTime: new Date().toISOString(),
            lastModifyingUser: "Kim Misher",
            webViewLink: "https://drive.test/folder",
            revisions: [],
            children: [
              {
                id: "sheet_1",
                name: "Approach Tracker",
                mimeType: "application/vnd.google-apps.spreadsheet",
                modifiedTime: new Date().toISOString(),
                lastModifyingUser: "Kim Misher",
                webViewLink: "https://docs.google.com/spreadsheets/d/sheet_1/edit",
                revisions: [
                  {
                    id: "rev_1",
                    modifiedTime: new Date().toISOString(),
                    lastModifyingUser: "Kim Misher",
                  },
                ],
              },
            ],
          },
        ],
      },
      trackerEvidence: {
        connected: true,
        trackerFileId: "tracker_1",
        trackerName: "Tracker",
        parsedAt: new Date().toISOString(),
        summary: {
          trackerModifiedTime: new Date().toISOString(),
        },
        summaryFields: [
          {
            fieldKey: "q4_earnings_target",
            label: "Q4 Earnings Target",
            value: "$5,000,000",
          },
        ],
        items: [
          {
            rowNumber: 10,
            itemType: "Opportunity",
            description: "Increase prices charged for pick-up and delivery",
            prioritization: "1",
            phase: "Execution",
            impactPotential: "High",
            impactValue: "$5,000,000",
            confidence: "Up",
            currentValueEstimate: "$5,000,000",
            status: "Complete",
            notes: "Increased base rate required to hit commission",
            lastEdited: "09/13",
            submittedBy: "KM",
          },
        ],
      },
    });

    expect(result.statusRecommendation).toBe("on_track");
    expect(result.confidenceScore).toBeGreaterThan(0.7);
    expect(result.evidenceReferences.some((reference) => reference.sourceType === "google_drive")).toBe(true);
  });

  it("marks low-signal initiatives as off track", () => {
    const result = evaluateInitiative({
      initiative: makeInitiative({
        stage: "Backlogged",
        targetCadence: "No Cadence",
        progress: "",
        leadPerformance: "",
        administrationHealth: "",
        people: [
          {
            id: "p1",
            role: "sales_lead",
            displayName: "Only Owner",
            email: null,
            sortOrder: 1,
            sourceType: "local",
          },
        ],
        links: [],
        knowledgeDocument: null,
      }),
      globalKnowledge: "Global guidance",
      slackEvidence: {
        connected: true,
        unreadableChannels: [],
        messages: [],
      },
      googleEvidence: {
        connected: false,
        files: [],
      },
      trackerEvidence: {
        connected: false,
        trackerFileId: null,
        trackerName: null,
        parsedAt: null,
        summary: {},
        summaryFields: [],
        items: [],
      },
    });

    expect(result.statusRecommendation).toBe("off_track");
    expect(result.topBlockers.length).toBeGreaterThan(2);
  });

  it("flags stale drive artifacts as needing attention or worse", () => {
    const staleDate = new Date(Date.now() - 1000 * 60 * 60 * 24 * 75).toISOString();
    const result = evaluateInitiative({
      initiative: makeInitiative(),
      globalKnowledge: "Global guidance",
      slackEvidence: {
        connected: true,
        unreadableChannels: [],
        messages: [],
      },
      googleEvidence: {
        connected: true,
        files: [
          {
            linkId: "g1",
            label: "Drive",
            url: "https://drive.test/folder",
            fileId: "folder_1",
            name: "SI Folder",
            mimeType: "application/vnd.google-apps.folder",
            readable: true,
            error: null,
            modifiedTime: staleDate,
            lastModifyingUser: "Former Owner",
            webViewLink: "https://drive.test/folder",
            revisions: [],
            children: [
              {
                id: "sheet_1",
                name: "Approach Tracker",
                mimeType: "application/vnd.google-apps.spreadsheet",
                modifiedTime: staleDate,
                lastModifyingUser: "Former Owner",
                webViewLink: "https://docs.google.com/spreadsheets/d/sheet_1/edit",
                revisions: [],
              },
            ],
          },
        ],
      },
      trackerEvidence: {
        connected: true,
        trackerFileId: "tracker_1",
        trackerName: "Tracker",
        parsedAt: staleDate,
        summary: {
          trackerModifiedTime: staleDate,
        },
        summaryFields: [],
        items: [
          {
            rowNumber: 10,
            itemType: "Opportunity",
            description: "Legacy item with no movement",
            prioritization: "1",
            phase: "Execution",
            impactPotential: "High",
            impactValue: "$5,000,000",
            confidence: "Down",
            currentValueEstimate: "$3,000,000",
            status: "Blocked",
            notes: "Waiting on decision",
            lastEdited: "01/01",
            submittedBy: "AB",
          },
        ],
      },
    });

    expect(["needs_attention", "stalled", "off_track"]).toContain(result.statusRecommendation);
    expect(
      result.topBlockers.some(
        (blocker) =>
          blocker.includes("blocked") ||
          blocker.includes("stale") ||
          blocker.includes("dormant"),
      ),
    ).toBe(true);
  });

  it("does not call dormant initiatives on track just because the workbook said they were healthy", () => {
    const staleSlackTs = `${Math.floor((Date.now() - 449 * 24 * 60 * 60 * 1000) / 1000)}.000100`;
    const staleDate = new Date(Date.now() - 220 * 24 * 60 * 60 * 1000).toISOString();

    const result = evaluateInitiative({
      initiative: makeInitiative({
        progress: "Workbook says green",
        leadPerformance: "Workbook says good",
        administrationHealth: "Workbook says healthy",
      }),
      globalKnowledge: "Global guidance",
      slackEvidence: {
        connected: true,
        unreadableChannels: [],
        messages: [
          {
            channelId: "C123",
            channelName: "001-test",
            label: "001-test",
            url: "https://equipmentshare.enterprise.slack.com/archives/C123",
            ts: staleSlackTs,
            userId: "U123",
            text: "Old kickoff message",
            permalink: "https://equipmentshare.enterprise.slack.com/archives/C123/p1710000000000100",
            replyCount: 0,
            replies: [],
          },
        ],
      },
      googleEvidence: {
        connected: true,
        files: [
          {
            linkId: "g1",
            label: "Drive",
            url: "https://drive.test/folder",
            fileId: "folder_1",
            name: "SI Folder",
            mimeType: "application/vnd.google-apps.folder",
            readable: true,
            error: null,
            modifiedTime: staleDate,
            lastModifyingUser: "Former Owner",
            webViewLink: "https://drive.test/folder",
            revisions: [],
            children: [],
          },
        ],
      },
      trackerEvidence: {
        connected: true,
        trackerFileId: "tracker_1",
        trackerName: "Tracker",
        parsedAt: staleDate,
        summary: {
          trackerModifiedTime: staleDate,
        },
        summaryFields: [],
        items: [],
      },
    });

    expect(result.statusRecommendation).not.toBe("on_track");
    expect(["stalled", "off_track"]).toContain(result.statusRecommendation);
    expect(
      result.topBlockers.some((blocker) => blocker.includes("Slack") || blocker.includes("days")),
    ).toBe(true);
  });
});
