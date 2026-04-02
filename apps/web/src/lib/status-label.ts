import type { InitiativeSummary, StatusRecommendation } from "@si/domain";

export function formatStatusLabel(
  status: InitiativeSummary["latestOpinionStatus"] | StatusRecommendation | null,
): string {
  switch (status) {
    case "on_track":
      return "Making progress";
    case "needs_attention":
      return "Mixed signals";
    case "stalled":
      return "Stalled";
    case "off_track":
      return "Off track";
    case "at_risk":
      return "At risk";
    default:
      return "No opinion yet";
  }
}
