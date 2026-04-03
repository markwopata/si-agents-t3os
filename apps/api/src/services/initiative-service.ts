import { and, asc, desc, eq, inArray, sql } from "drizzle-orm";
import {
  initiativeCreateSchema,
  initiativeUpdateSchema,
  type InitiativeDetail,
  type InitiativeAnnotationCreateInput,
  type InitiativeLinkInput,
  type InitiativePersonInput,
  type InitiativeSummary,
  type InitiativeUpdateInput,
  type ObservationReviewVerdict,
  knowledgeDocumentUpsertSchema,
  type PeriodSnapshotInput,
} from "@si/domain";
import { db } from "../db/client.js";
import {
  agentEvidenceRefs,
  agentObservations,
  agentObservationReviews,
  initiativeAnnotations,
  initiativeLinks,
  initiativePeople,
  initiativePeriodSnapshots,
  initiativeRunConfigs,
  initiatives,
  knowledgeDocuments,
} from "../db/schema.js";
import { createId } from "../lib/id.js";

function toIso(value: Date): string {
  return value.toISOString();
}

type ObservationReviewRecord = NonNullable<InitiativeDetail["observations"][number]["review"]>;

async function hydrateInitiatives(initiativeIds: string[]): Promise<Map<string, InitiativeDetail>> {
  if (initiativeIds.length === 0) {
    return new Map();
  }

  const [initiativeRows, peopleRows, linkRows, snapshotRows, knowledgeRows, annotationRows, runConfigRows, observationRows] =
    await Promise.all([
      db.select().from(initiatives).where(inArray(initiatives.id, initiativeIds)),
      db.select().from(initiativePeople).where(inArray(initiativePeople.initiativeId, initiativeIds)),
      db.select().from(initiativeLinks).where(inArray(initiativeLinks.initiativeId, initiativeIds)),
      db
        .select()
        .from(initiativePeriodSnapshots)
        .where(inArray(initiativePeriodSnapshots.initiativeId, initiativeIds)),
      db.select().from(knowledgeDocuments).where(inArray(knowledgeDocuments.initiativeId, initiativeIds)),
      db.select().from(initiativeAnnotations).where(inArray(initiativeAnnotations.initiativeId, initiativeIds)),
      db.select().from(initiativeRunConfigs).where(inArray(initiativeRunConfigs.initiativeId, initiativeIds)),
      db
        .select()
        .from(agentObservations)
        .where(inArray(agentObservations.initiativeId, initiativeIds))
        .orderBy(desc(agentObservations.createdAt)),
    ]);

  const observationIds = observationRows.map((row) => row.id);
  const evidenceRows =
    observationIds.length > 0
      ? await db
          .select()
          .from(agentEvidenceRefs)
          .where(inArray(agentEvidenceRefs.observationId, observationIds))
      : [];
  const reviewRows =
    observationIds.length > 0
      ? await db
          .select()
          .from(agentObservationReviews)
          .where(inArray(agentObservationReviews.observationId, observationIds))
      : [];

  const byId = new Map<string, InitiativeDetail>();
  for (const row of initiativeRows) {
    byId.set(row.id, {
      id: row.id,
      code: row.code,
      title: row.title,
      objective: row.objective,
      group: row.group,
      targetCadence: row.targetCadence,
      updateType: row.updateType,
      stage: row.stage,
      lClass: row.lClass,
      progress: row.progress,
      leadPerformance: row.leadPerformance,
      administrationHealth: row.administrationHealth,
      impactType: row.impactType,
      inCapPlan: row.inCapPlan,
      isActive: row.isActive,
      priorityRank: row.priorityRank,
      priorityScore: row.priorityScore,
      priorityReason: row.priorityReason,
      prioritySource: (row.prioritySource as InitiativeDetail["prioritySource"]) ?? null,
      rankingUpdatedAt: row.rankingUpdatedAt ? toIso(row.rankingUpdatedAt) : null,
      latestOpinionStatus: null,
      latestOpinionConfidence: null,
      latestObservationAt: null,
      peopleCount: 0,
      hasExecOwner: false,
      hasGroupOwner: false,
      hasInitiativeOwner: false,
      updatedAt: toIso(row.updatedAt),
      sourceRowNumber: row.sourceRowNumber,
      people: [],
      links: [],
      snapshots: [],
      knowledgeDocument: null,
      annotations: [],
      runConfig: null,
      observations: [],
    });
  }

  for (const row of peopleRows) {
    byId.get(row.initiativeId)?.people.push({
      id: row.id,
      role: row.role as InitiativePersonInput["role"],
      displayName: row.displayName,
      email: row.email,
      t3osContactId: row.t3osContactId,
      t3osWorkspaceMemberId: row.t3osWorkspaceMemberId,
      t3osUserId: row.t3osUserId,
      sourceType: row.sourceType,
      sortOrder: row.sortOrder,
    });
  }

  for (const row of linkRows) {
    byId.get(row.initiativeId)?.links.push({
      id: row.id,
      linkType: row.linkType as InitiativeLinkInput["linkType"],
      label: row.label,
      url: row.url,
      sortOrder: row.sortOrder,
    });
  }

  for (const row of snapshotRows) {
    byId.get(row.initiativeId)?.snapshots.push({
      id: row.id,
      periodKey: row.periodKey,
      category: row.category as PeriodSnapshotInput["category"],
      status: row.status,
      baselineValue: row.baselineValue,
      bookedValue: row.bookedValue,
    });
  }

  for (const row of knowledgeRows) {
    const initiative = byId.get(row.initiativeId ?? "");
    if (initiative) {
      initiative.knowledgeDocument = {
        id: row.id,
        title: row.title,
        slug: row.slug,
        content: row.content,
        version: row.version,
        updatedAt: toIso(row.updatedAt),
      };
    }
  }

  for (const row of annotationRows) {
    byId.get(row.initiativeId)?.annotations.push({
      id: row.id,
      annotationType: row.annotationType as InitiativeDetail["annotations"][number]["annotationType"],
      title: row.title,
      content: row.content,
      metadata: row.metadata,
      createdByType: row.createdByType,
      createdById: row.createdById,
      createdAt: toIso(row.createdAt),
      updatedAt: toIso(row.updatedAt),
    });
  }

  for (const row of runConfigRows) {
    const initiative = byId.get(row.initiativeId);
    if (!initiative) {
      continue;
    }

    initiative.runConfig = {
      id: row.id,
      cadenceMode: row.cadenceMode as InitiativeDetail["runConfig"] extends infer T
        ? T extends { cadenceMode: infer C }
          ? C
          : never
        : never,
      cadenceDetail: row.cadenceDetail,
      alertThresholds: {
        maxTrackerStalenessDays:
          typeof row.alertThresholds?.maxTrackerStalenessDays === "number"
            ? row.alertThresholds.maxTrackerStalenessDays
            : null,
        attentionBlockerCount:
          typeof row.alertThresholds?.attentionBlockerCount === "number"
            ? row.alertThresholds.attentionBlockerCount
            : null,
        minimumSlackMessages30d:
          typeof row.alertThresholds?.minimumSlackMessages30d === "number"
            ? row.alertThresholds.minimumSlackMessages30d
            : null,
        minimumDriveUpdates30d:
          typeof row.alertThresholds?.minimumDriveUpdates30d === "number"
            ? row.alertThresholds.minimumDriveUpdates30d
            : null,
        minimumOnTrackScore:
          typeof row.alertThresholds?.minimumOnTrackScore === "number"
            ? row.alertThresholds.minimumOnTrackScore
            : null,
      },
      customKpiRulesMarkdown: row.customKpiRulesMarkdown,
      customInstructionsMarkdown: row.customInstructionsMarkdown,
      goodLooksLikeMarkdown: row.goodLooksLikeMarkdown,
      ownerNotesMarkdown: row.ownerNotesMarkdown,
      updatedByType: row.updatedByType,
      updatedById: row.updatedById,
      updatedAt: toIso(row.updatedAt),
    };
  }

  const evidenceByObservationId = new Map<
    string,
    Array<{
      id: string;
      sourceType: string;
      sourceId: string;
      title: string;
      url: string | null;
      excerpt: string;
      metadata: Record<string, unknown>;
    }>
  >();
  const reviewByObservationId = new Map<string, ObservationReviewRecord>();

  for (const row of evidenceRows) {
    const current = evidenceByObservationId.get(row.observationId) ?? [];
    current.push({
      id: row.id,
      sourceType: row.sourceType,
      sourceId: row.sourceId,
      title: row.title,
      url: row.url,
      excerpt: row.excerpt,
      metadata: row.metadata,
    });
    evidenceByObservationId.set(row.observationId, current);
  }

  for (const row of reviewRows) {
    reviewByObservationId.set(row.observationId, {
      id: row.id,
      observationId: row.observationId,
      verdict: row.verdict as ObservationReviewVerdict,
      note: row.note,
      reviewerType: row.reviewerType,
      reviewerId: row.reviewerId,
      updatedAt: toIso(row.updatedAt),
    });
  }

  for (const row of observationRows) {
    const initiative = byId.get(row.initiativeId);
    if (!initiative) {
      continue;
    }

    initiative.observations.push({
      id: row.id,
      agentRunId: row.agentRunId,
      statusRecommendation: row.statusRecommendation as InitiativeDetail["observations"][number]["statusRecommendation"],
      progressAssessment: row.progressAssessment,
      confidenceScore: row.confidenceScore,
      topBlockers: row.topBlockers,
      suggestedNextActions: row.suggestedNextActions,
      evidenceSummary: row.evidenceSummary,
      evidenceReferences: evidenceByObservationId.get(row.id) ?? [],
      review: reviewByObservationId.get(row.id) ?? null,
      createdAt: toIso(row.createdAt),
    });

    if (initiative.latestOpinionStatus === null) {
      initiative.latestOpinionStatus = row.statusRecommendation as InitiativeSummary["latestOpinionStatus"];
      initiative.latestOpinionConfidence = row.confidenceScore;
    }
  }

  return byId;
}

export async function listInitiatives(): Promise<InitiativeSummary[]> {
  const rows = await db
    .select()
    .from(initiatives)
    .orderBy(sql`${initiatives.priorityRank} is null`, asc(initiatives.priorityRank), initiatives.code);
  const hydrated = await hydrateInitiatives(rows.map((row) => row.id));
  return rows.map((row) => {
    const detail = hydrated.get(row.id)!;
    return {
      id: detail.id,
      code: detail.code,
      title: detail.title,
      objective: detail.objective,
      group: detail.group,
      targetCadence: detail.targetCadence,
      updateType: detail.updateType,
      stage: detail.stage,
      lClass: detail.lClass,
      progress: detail.progress,
      leadPerformance: detail.leadPerformance,
      administrationHealth: detail.administrationHealth,
      impactType: detail.impactType,
      inCapPlan: detail.inCapPlan,
      isActive: detail.isActive,
      priorityRank: detail.priorityRank,
      priorityScore: detail.priorityScore,
      priorityReason: detail.priorityReason,
      prioritySource: detail.prioritySource,
      rankingUpdatedAt: detail.rankingUpdatedAt,
      latestOpinionStatus: detail.latestOpinionStatus,
      latestOpinionConfidence: detail.latestOpinionConfidence,
      latestObservationAt: detail.observations[0]?.createdAt ?? null,
      peopleCount: detail.people.length,
      hasExecOwner: detail.people.some((person) => person.role === "exec_owner"),
      hasGroupOwner: detail.people.some((person) => person.role === "group_owner"),
      hasInitiativeOwner: detail.people.some((person) => person.role === "initiative_owner"),
      updatedAt: detail.updatedAt,
    };
  });
}

export async function getInitiativeById(initiativeId: string): Promise<InitiativeDetail | null> {
  const hydrated = await hydrateInitiatives([initiativeId]);
  return hydrated.get(initiativeId) ?? null;
}

export async function createInitiative(input: InitiativeUpdateInput): Promise<InitiativeDetail> {
  const parsed = initiativeCreateSchema.parse(input);
  const initiativeId = createId("initiative");

  await db.insert(initiatives).values({
    id: initiativeId,
    code: parsed.code,
    title: parsed.title,
    objective: parsed.objective,
    group: parsed.group,
    targetCadence: parsed.targetCadence,
    updateType: parsed.updateType,
    stage: parsed.stage,
    lClass: parsed.lClass,
    progress: parsed.progress,
    leadPerformance: parsed.leadPerformance,
    administrationHealth: parsed.administrationHealth,
    impactType: parsed.impactType,
    inCapPlan: parsed.inCapPlan,
    isActive: parsed.isActive,
    sourceRowNumber: parsed.sourceRowNumber,
  });

  await upsertKnowledgeDocument({
    initiativeId,
    documentType: "initiative",
    slug: `initiative-${parsed.code.toLowerCase().replace(/\s+/g, "-")}`,
    title: `${parsed.code} ${parsed.title} Notes`,
    content: "",
  });

  return (await getInitiativeById(initiativeId))!;
}

export async function updateInitiative(
  initiativeId: string,
  input: InitiativeUpdateInput,
): Promise<InitiativeDetail | null> {
  const parsed = initiativeUpdateSchema.parse(input);
  await db
    .update(initiatives)
    .set({
      ...parsed,
      updatedAt: new Date(),
    })
    .where(eq(initiatives.id, initiativeId));

  return getInitiativeById(initiativeId);
}

export async function archiveInitiative(initiativeId: string): Promise<void> {
  await db
    .update(initiatives)
    .set({
      isActive: false,
      updatedAt: new Date(),
    })
    .where(eq(initiatives.id, initiativeId));
}

export async function replaceInitiativePeople(
  initiativeId: string,
  people: InitiativePersonInput[],
): Promise<void> {
  await db.delete(initiativePeople).where(eq(initiativePeople.initiativeId, initiativeId));
  if (people.length === 0) {
    return;
  }

  await db.insert(initiativePeople).values(
    people.map((person) => ({
      id: createId("person"),
      initiativeId,
      role: person.role,
      displayName: person.displayName,
      email: person.email ?? null,
      t3osContactId: person.t3osContactId ?? null,
      t3osWorkspaceMemberId: person.t3osWorkspaceMemberId ?? null,
      t3osUserId: person.t3osUserId ?? null,
      sourceType: person.sourceType ?? "local",
      sortOrder: person.sortOrder,
    })),
  );
}

export async function replaceInitiativeLinks(
  initiativeId: string,
  links: InitiativeLinkInput[],
): Promise<void> {
  await db.delete(initiativeLinks).where(eq(initiativeLinks.initiativeId, initiativeId));
  if (links.length === 0) {
    return;
  }

  await db.insert(initiativeLinks).values(
    links.map((link) => ({
      id: createId("link"),
      initiativeId,
      linkType: link.linkType,
      label: link.label,
      url: link.url,
      sortOrder: link.sortOrder,
    })),
  );
}

export async function replaceInitiativeSnapshots(
  initiativeId: string,
  snapshots: PeriodSnapshotInput[],
): Promise<void> {
  await db
    .delete(initiativePeriodSnapshots)
    .where(eq(initiativePeriodSnapshots.initiativeId, initiativeId));
  if (snapshots.length === 0) {
    return;
  }

  await db.insert(initiativePeriodSnapshots).values(
    snapshots.map((snapshot) => ({
      id: createId("snapshot"),
      initiativeId,
      periodKey: snapshot.periodKey,
      category: snapshot.category,
      status: snapshot.status,
      baselineValue: snapshot.baselineValue,
      bookedValue: snapshot.bookedValue,
    })),
  );
}

export async function getGlobalKnowledgeDocument(): Promise<{
  id: string;
  title: string;
  slug: string;
  content: string;
  version: number;
  updatedAt: string;
} | null> {
  const doc = await db.query.knowledgeDocuments.findFirst({
    where: and(eq(knowledgeDocuments.documentType, "global"), eq(knowledgeDocuments.slug, "global-si-operating-model")),
  });

  return doc
    ? {
        id: doc.id,
        title: doc.title,
        slug: doc.slug,
        content: doc.content,
        version: doc.version,
        updatedAt: toIso(doc.updatedAt),
      }
    : null;
}

export async function upsertKnowledgeDocument(input: {
  initiativeId?: string | null;
  documentType: "global" | "initiative";
  slug: string;
  title: string;
  content: string;
}): Promise<void> {
  const parsed = knowledgeDocumentUpsertSchema.parse({
    ...input,
    initiativeId: input.initiativeId ?? null,
  });

  const existing = await db.query.knowledgeDocuments.findFirst({
    where: eq(knowledgeDocuments.slug, parsed.slug),
  });

  if (existing) {
    await db
      .update(knowledgeDocuments)
      .set({
        title: parsed.title,
        content: parsed.content,
        version: existing.version + 1,
        updatedAt: new Date(),
      })
      .where(eq(knowledgeDocuments.id, existing.id));
    return;
  }

  await db.insert(knowledgeDocuments).values({
    id: createId("knowledge"),
    initiativeId: parsed.initiativeId ?? null,
    documentType: parsed.documentType,
    slug: parsed.slug,
    title: parsed.title,
    content: parsed.content,
  });
}

export async function addInitiativeAnnotation(input: {
  initiativeId: string;
  annotation: InitiativeAnnotationCreateInput;
  createdByType: string;
  createdById: string;
}): Promise<InitiativeDetail["annotations"][number]> {
  const id = createId("annotation");
  await db.insert(initiativeAnnotations).values({
    id,
    initiativeId: input.initiativeId,
    annotationType: input.annotation.annotationType,
    title: input.annotation.title,
    content: input.annotation.content,
    metadata: input.annotation.metadata ?? {},
    createdByType: input.createdByType,
    createdById: input.createdById,
  });

  const detail = await getInitiativeById(input.initiativeId);
  const created = detail?.annotations.find((annotation) => annotation.id === id);
  if (!created) {
    throw new Error("Failed to load created annotation");
  }
  return created;
}

export async function listInitiativeAnnotations(
  initiativeId: string,
): Promise<InitiativeDetail["annotations"]> {
  const detail = await getInitiativeById(initiativeId);
  return detail?.annotations ?? [];
}

export async function deleteInitiativeAnnotation(
  initiativeId: string,
  annotationId: string,
): Promise<boolean> {
  const existing = await db.query.initiativeAnnotations.findFirst({
    where: and(eq(initiativeAnnotations.id, annotationId), eq(initiativeAnnotations.initiativeId, initiativeId)),
  });
  if (!existing) {
    return false;
  }

  await db.delete(initiativeAnnotations).where(eq(initiativeAnnotations.id, annotationId));
  return true;
}
