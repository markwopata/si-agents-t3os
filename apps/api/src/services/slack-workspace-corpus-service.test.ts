import { describe, expect, it } from "vitest";
import { hasSyncableSlackContent } from "./slack-workspace-corpus-service.js";

describe("hasSyncableSlackContent", () => {
  it("keeps text-only messages", () => {
    expect(
      hasSyncableSlackContent({
        text: "Need help with this dashboard.",
      }),
    ).toBe(true);
  });

  it("keeps file-only messages", () => {
    expect(
      hasSyncableSlackContent({
        text: "   ",
        files: [{ id: "F123", name: "dashboard.png" }],
      }),
    ).toBe(true);
  });

  it("drops empty messages without attachments", () => {
    expect(
      hasSyncableSlackContent({
        text: "   ",
      }),
    ).toBe(false);
  });
});
