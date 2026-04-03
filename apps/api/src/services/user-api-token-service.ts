import { createHash, randomBytes } from "node:crypto";
import { and, eq } from "drizzle-orm";
import { apiTokenCreateSchema, type ApiTokenCreateInput } from "@si/domain";
import { db } from "../db/client.js";
import { userApiTokens } from "../db/schema.js";
import { createId } from "../lib/id.js";

function hashToken(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}

export async function listUserApiTokens(input: {
  ownerUserId: string;
  includeAllForAdmin?: boolean;
}) {
  const rows = await db.query.userApiTokens.findMany({
    where: input.includeAllForAdmin
      ? undefined
      : eq(userApiTokens.ownerUserId, input.ownerUserId),
    orderBy: (table, { desc, asc }) => [asc(table.ownerDisplayName), asc(table.label), desc(table.createdAt)],
  });

  return rows.map((row) => ({
    id: row.id,
    label: row.label,
    scopes: row.scopes,
    tokenPreview: row.tokenPreview,
    createdAt: row.createdAt.toISOString(),
    lastUsedAt: row.lastUsedAt?.toISOString() ?? null,
    ownerUserId: row.ownerUserId,
    ownerEmail: row.ownerEmail ?? null,
    ownerDisplayName: row.ownerDisplayName ?? null,
    ownerWorkspaceId: row.ownerWorkspaceId ?? null,
  }));
}

export async function createUserApiToken(input: {
  ownerUserId: string;
  ownerEmail: string | null;
  ownerDisplayName: string | null;
  ownerWorkspaceId: string | null;
  allowedScopes: string[];
  token: ApiTokenCreateInput;
}): Promise<{ id: string; token: string }> {
  const parsed = apiTokenCreateSchema.parse(input.token);
  const disallowedScopes = parsed.scopes.filter((scope) => !input.allowedScopes.includes(scope));
  if (disallowedScopes.length > 0) {
    throw new Error(`Requested scopes exceed caller permissions: ${disallowedScopes.join(", ")}`);
  }

  const plainToken = `siu_${randomBytes(24).toString("hex")}`;
  const tokenId = createId("user_token");

  await db.insert(userApiTokens).values({
    id: tokenId,
    ownerUserId: input.ownerUserId,
    ownerEmail: input.ownerEmail,
    ownerDisplayName: input.ownerDisplayName,
    ownerWorkspaceId: input.ownerWorkspaceId,
    label: parsed.label,
    tokenHash: hashToken(plainToken),
    tokenPreview: `${plainToken.slice(0, 12)}...`,
    scopes: parsed.scopes,
  });

  return {
    id: tokenId,
    token: plainToken,
  };
}

export async function deleteUserApiToken(input: {
  tokenId: string;
  ownerUserId: string;
  includeAllForAdmin?: boolean;
}): Promise<void> {
  if (input.includeAllForAdmin) {
    await db.delete(userApiTokens).where(eq(userApiTokens.id, input.tokenId));
    return;
  }

  await db
    .delete(userApiTokens)
    .where(
      and(
        eq(userApiTokens.id, input.tokenId),
        eq(userApiTokens.ownerUserId, input.ownerUserId),
      ),
    );
}
