import { describe, expect, it } from "vitest";
import { parseGoogleFileLink } from "./reader.js";

describe("parseGoogleFileLink", () => {
  it("extracts folder IDs from Google Drive folder URLs", () => {
    expect(
      parseGoogleFileLink("https://drive.google.com/drive/folders/1YiO0juIp7bD7H7vWT24cESSdMRJ0rpsU?usp=drive_link"),
    ).toEqual({
      fileId: "1YiO0juIp7bD7H7vWT24cESSdMRJ0rpsU",
      kind: "folder",
    });
  });

  it("extracts file IDs from docs-style URLs", () => {
    expect(
      parseGoogleFileLink("https://docs.google.com/spreadsheets/d/1abcDEFghiJKLmnOPQrstUVWxyz1234567890/edit#gid=0"),
    ).toEqual({
      fileId: "1abcDEFghiJKLmnOPQrstUVWxyz1234567890",
      kind: "file",
    });
  });
});
