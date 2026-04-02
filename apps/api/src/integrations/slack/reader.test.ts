import { describe, expect, it } from "vitest";
import { parseSlackChannelLink } from "./reader.js";

describe("parseSlackChannelLink", () => {
  it("extracts a Slack channel ID from an archives URL", () => {
    expect(
      parseSlackChannelLink("https://equipmentshare.enterprise.slack.com/archives/C0717BZ6CCC"),
    ).toEqual({
      channelId: "C0717BZ6CCC",
      label: "C0717BZ6CCC",
      url: "https://equipmentshare.enterprise.slack.com/archives/C0717BZ6CCC",
    });
  });

  it("returns null for non-Slack URLs", () => {
    expect(parseSlackChannelLink("https://drive.google.com/drive/folders/test")).toBeNull();
  });
});
