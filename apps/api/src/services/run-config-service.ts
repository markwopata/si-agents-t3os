import type { InitiativeDetail, InitiativeRunConfigUpsertInput } from "@si/domain";
import { eq } from "drizzle-orm";
import { db } from "../db/client.js";
import { initiativeRunConfigs } from "../db/schema.js";
import { createId } from "../lib/id.js";
import { getInitiativeById } from "./initiative-service.js";

export async function getInitiativeRunConfig(
  initiativeId: string,
): Promise<InitiativeDetail["runConfig"]> {
  const detail = await getInitiativeById(initiativeId);
  return detail?.runConfig ?? null;
}

export async function upsertInitiativeRunConfig(input: {
  initiativeId: string;
  config: InitiativeRunConfigUpsertInput;
  updatedByType: string;
  updatedById: string;
}): Promise<NonNullable<InitiativeDetail["runConfig"]>> {
  const existing = await db.query.initiativeRunConfigs.findFirst({
    where: eq(initiativeRunConfigs.initiativeId, input.initiativeId),
  });

  if (existing) {
    await db
      .update(initiativeRunConfigs)
      .set({
        cadenceMode: input.config.cadenceMode,
        cadenceDetail: input.config.cadenceDetail,
        alertThresholds: input.config.alertThresholds,
        customKpiRulesMarkdown: input.config.customKpiRulesMarkdown,
        customInstructionsMarkdown: input.config.customInstructionsMarkdown,
        goodLooksLikeMarkdown: input.config.goodLooksLikeMarkdown,
        ownerNotesMarkdown: input.config.ownerNotesMarkdown,
        updatedByType: input.updatedByType,
        updatedById: input.updatedById,
        updatedAt: new Date(),
      })
      .where(eq(initiativeRunConfigs.id, existing.id));
    const detail = await getInitiativeById(input.initiativeId);
    if (!detail?.runConfig) {
      throw new Error("Failed to load initiative run config");
    }
    return detail.runConfig;
  }

  await db.insert(initiativeRunConfigs).values({
    id: createId("run_config"),
    initiativeId: input.initiativeId,
    cadenceMode: input.config.cadenceMode,
    cadenceDetail: input.config.cadenceDetail,
    alertThresholds: input.config.alertThresholds,
    customKpiRulesMarkdown: input.config.customKpiRulesMarkdown,
    customInstructionsMarkdown: input.config.customInstructionsMarkdown,
    goodLooksLikeMarkdown: input.config.goodLooksLikeMarkdown,
    ownerNotesMarkdown: input.config.ownerNotesMarkdown,
    updatedByType: input.updatedByType,
    updatedById: input.updatedById,
  });

  const detail = await getInitiativeById(input.initiativeId);
  if (!detail?.runConfig) {
    throw new Error("Failed to load initiative run config");
  }
  return detail.runConfig;
}
