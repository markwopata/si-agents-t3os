import { auditEvents } from "../db/schema.js";
import { db } from "../db/client.js";
import { createId } from "./id.js";

export interface AuditActor {
  type: "human" | "service_token";
  id: string;
}

export async function recordAuditEvent(input: {
  actor: AuditActor;
  action: string;
  entityType: string;
  entityId: string;
  payload: Record<string, unknown>;
}): Promise<void> {
  await db.insert(auditEvents).values({
    id: createId("audit"),
    actorType: input.actor.type,
    actorId: input.actor.id,
    action: input.action,
    entityType: input.entityType,
    entityId: input.entityId,
    payload: input.payload,
  });
}

