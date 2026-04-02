import { createHash, randomBytes } from "node:crypto";
import { serviceTokenCreateSchema, type ServiceTokenCreateInput } from "@si/domain";
import { eq } from "drizzle-orm";
import { db } from "../db/client.js";
import { serviceTokens } from "../db/schema.js";
import { createId } from "../lib/id.js";

function hashToken(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}

export async function listServiceTokens(): Promise<
  Array<{ id: string; label: string; scopes: string[]; tokenPreview: string; createdAt: string }>
> {
  const rows = await db.query.serviceTokens.findMany();
  return rows.map((row) => ({
    id: row.id,
    label: row.label,
    scopes: row.scopes,
    tokenPreview: row.tokenPreview,
    createdAt: row.createdAt.toISOString(),
  }));
}

export async function createServiceToken(
  input: ServiceTokenCreateInput,
): Promise<{ id: string; token: string }> {
  const parsed = serviceTokenCreateSchema.parse(input);
  const plainToken = `si_${randomBytes(24).toString("hex")}`;
  const tokenId = createId("token");

  await db.insert(serviceTokens).values({
    id: tokenId,
    label: parsed.label,
    tokenHash: hashToken(plainToken),
    tokenPreview: `${plainToken.slice(0, 10)}...`,
    scopes: parsed.scopes,
  });

  return {
    id: tokenId,
    token: plainToken,
  };
}

export async function deleteServiceToken(tokenId: string): Promise<void> {
  await db.delete(serviceTokens).where(eq(serviceTokens.id, tokenId));
}
