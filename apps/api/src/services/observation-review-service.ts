import type { ObservationReview, ObservationReviewUpsertInput } from "@si/domain";
import { eq } from "drizzle-orm";
import { db } from "../db/client.js";
import { agentObservationReviews, agentObservations } from "../db/schema.js";
import { createId } from "../lib/id.js";

function toIso(value: Date): string {
  return value.toISOString();
}

export async function getObservationReview(observationId: string): Promise<ObservationReview | null> {
  const row = await db.query.agentObservationReviews.findFirst({
    where: eq(agentObservationReviews.observationId, observationId),
  });

  if (!row) {
    return null;
  }

  return {
    id: row.id,
    observationId: row.observationId,
    verdict: row.verdict as ObservationReview["verdict"],
    note: row.note,
    reviewerType: row.reviewerType,
    reviewerId: row.reviewerId,
    updatedAt: toIso(row.updatedAt),
  };
}

export async function upsertObservationReview(input: {
  observationId: string;
  review: ObservationReviewUpsertInput;
  reviewerType: "human" | "service_token";
  reviewerId: string;
}): Promise<ObservationReview> {
  const observation = await db.query.agentObservations.findFirst({
    where: eq(agentObservations.id, input.observationId),
  });

  if (!observation) {
    throw new Error("Observation not found");
  }

  const existing = await db.query.agentObservationReviews.findFirst({
    where: eq(agentObservationReviews.observationId, input.observationId),
  });

  if (existing) {
    await db
      .update(agentObservationReviews)
      .set({
        verdict: input.review.verdict,
        note: input.review.note,
        reviewerType: input.reviewerType,
        reviewerId: input.reviewerId,
        updatedAt: new Date(),
      })
      .where(eq(agentObservationReviews.id, existing.id));

    return {
      id: existing.id,
      observationId: input.observationId,
      verdict: input.review.verdict,
      note: input.review.note,
      reviewerType: input.reviewerType,
      reviewerId: input.reviewerId,
      updatedAt: new Date().toISOString(),
    };
  }

  const id = createId("review");
  await db.insert(agentObservationReviews).values({
    id,
    observationId: input.observationId,
    initiativeId: observation.initiativeId,
    verdict: input.review.verdict,
    note: input.review.note,
    reviewerType: input.reviewerType,
    reviewerId: input.reviewerId,
  });

  return {
    id,
    observationId: input.observationId,
    verdict: input.review.verdict,
    note: input.review.note,
    reviewerType: input.reviewerType,
    reviewerId: input.reviewerId,
    updatedAt: new Date().toISOString(),
  };
}
