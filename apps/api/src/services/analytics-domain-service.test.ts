import { describe, expect, it } from "vitest";
import {
  cleanSlackText,
  extractPromptCandidate,
  scoreDomainMatch,
} from "./analytics-domain-service.js";

const branchEarningsDomain = {
  key: "branch_earnings" as const,
  keywords: ["branch earnings", "margin", "invoice", "gl", "revenue pacing"],
};

describe("cleanSlackText", () => {
  it("strips Slack markup and compacts whitespace", () => {
    expect(
      cleanSlackText(
        "Hey <@U123> can you review <https://example.com|this sheet> and explain why branch earnings moved?\n```sql\nselect 1\n```",
      ),
    ).toBe("Hey can you review this sheet and explain why branch earnings moved?");
  });
});

describe("scoreDomainMatch", () => {
  it("rewards messages that use domain-specific language", () => {
    const match = scoreDomainMatch(
      "Can you explain why branch earnings margin moved after this invoice hit the GL?",
      branchEarningsDomain,
    );

    expect(match.score).toBeGreaterThan(0);
    expect(match.matchedTerms).toContain("branch earnings");
    expect(match.matchedTerms).toContain("margin");
  });

  it("ignores messages without the right domain vocabulary", () => {
    const match = scoreDomainMatch("Please approve this lunch receipt.", branchEarningsDomain);
    expect(match.score).toBe(0);
    expect(match.matchedTerms).toHaveLength(0);
  });
});

describe("extractPromptCandidate", () => {
  it("turns analytics-style Slack questions into prompt candidates", () => {
    const candidate = extractPromptCandidate({
      domain: branchEarningsDomain,
      observation: {
        id: "msg_1",
        initiativeId: "initiative_1",
        channelId: "C123",
        channelName: "branch-earnings",
        permalink: "https://example.com/message",
        text: "Morning! Can you explain why branch earnings moved after the invoice was posted to the GL?",
        messageAt: new Date("2026-04-05T14:00:00.000Z"),
        sourceType: "slack_message",
      },
    });

    expect(candidate?.prompt).toBe(
      "Can you explain why branch earnings moved after the invoice was posted to the GL?",
    );
    expect(candidate?.domainKey).toBe("branch_earnings");
    expect(candidate?.confidence).toBeGreaterThan(0.62);
  });

  it("filters short or non-analytical chatter", () => {
    const candidate = extractPromptCandidate({
      domain: branchEarningsDomain,
      observation: {
        id: "msg_2",
        initiativeId: "initiative_1",
        channelId: "C123",
        channelName: "branch-earnings",
        permalink: null,
        text: "thanks",
        messageAt: new Date("2026-04-05T14:00:00.000Z"),
        sourceType: "slack_message",
      },
    });

    expect(candidate).toBeNull();
  });
});
