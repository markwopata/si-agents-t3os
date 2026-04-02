import { createHmac, randomBytes } from "node:crypto";
import { eq } from "drizzle-orm";
import { env } from "../../config/env.js";
import { db } from "../../db/client.js";
import { slackInstallations } from "../../db/schema.js";
import { encryptSecret } from "../../lib/crypto.js";
import { createId } from "../../lib/id.js";

function signState(payload: string): string {
  return createHmac("sha256", env.TOKEN_ENCRYPTION_SECRET).update(payload).digest("hex");
}

export function createSlackInstallUrl(): string {
  if (!env.SLACK_CLIENT_ID) {
    throw new Error("Slack client ID is not configured");
  }

  const nonce = randomBytes(12).toString("hex");
  const signedState = `${nonce}.${signState(nonce)}`;
  const params = new URLSearchParams({
    client_id: env.SLACK_CLIENT_ID,
    user_scope: env.SLACK_USER_SCOPES,
    redirect_uri: env.SLACK_REDIRECT_URI,
    state: signedState,
  });

  return `https://slack.com/oauth/v2/authorize?${params.toString()}`;
}

function getSlackSetupState(): {
  configured: boolean;
  clientIdConfigured: boolean;
  clientSecretConfigured: boolean;
  redirectUri: string;
  redirectUriSecure: boolean;
  installUrl: string | null;
  requiredUserScopes: string[];
  missingRequirements: string[];
} {
  const clientIdConfigured = Boolean(env.SLACK_CLIENT_ID);
  const clientSecretConfigured = Boolean(env.SLACK_CLIENT_SECRET);
  const redirectUri = env.SLACK_REDIRECT_URI;
  const redirectUriSecure = redirectUri.startsWith("https://");
  const requiredUserScopes = env.SLACK_USER_SCOPES.split(",").filter(Boolean);
  const missingRequirements: string[] = [];

  if (!clientIdConfigured) {
    missingRequirements.push("Add SLACK_CLIENT_ID to .env.");
  }

  if (!clientSecretConfigured) {
    missingRequirements.push("Add SLACK_CLIENT_SECRET to .env.");
  }

  if (!redirectUriSecure) {
    missingRequirements.push("Use an HTTPS SLACK_REDIRECT_URI for Slack OAuth.");
  }

  return {
    configured: clientIdConfigured && clientSecretConfigured && redirectUriSecure,
    clientIdConfigured,
    clientSecretConfigured,
    redirectUri,
    redirectUriSecure,
    installUrl: clientIdConfigured ? createSlackInstallUrl() : null,
    requiredUserScopes,
    missingRequirements,
  };
}

export function verifySlackState(state: string): boolean {
  const [nonce, signature] = state.split(".");
  return Boolean(nonce && signature && signState(nonce) === signature);
}

export async function exchangeSlackCode(code: string): Promise<{
  teamId: string;
  teamName: string;
  slackUserId: string;
}> {
  if (!env.SLACK_CLIENT_ID || !env.SLACK_CLIENT_SECRET) {
    throw new Error("Slack OAuth is not configured");
  }

  const response = await fetch("https://slack.com/api/oauth.v2.access", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      client_id: env.SLACK_CLIENT_ID,
      client_secret: env.SLACK_CLIENT_SECRET,
      code,
      redirect_uri: env.SLACK_REDIRECT_URI,
    }),
  });

  const payload = (await response.json()) as {
    ok: boolean;
    error?: string;
    team?: { id: string; name: string };
    authed_user?: { id: string; access_token: string; scope: string };
  };

  if (!payload.ok || !payload.team || !payload.authed_user?.access_token) {
    throw new Error(payload.error ?? "Slack OAuth exchange failed");
  }

  const encryptedToken = encryptSecret(payload.authed_user.access_token);
  const scopes = payload.authed_user.scope ? payload.authed_user.scope.split(",") : [];

  const existing = await db.query.slackInstallations.findFirst({
    where: eq(slackInstallations.slackUserId, payload.authed_user.id),
  });

  if (existing) {
    await db
      .update(slackInstallations)
      .set({
        teamId: payload.team.id,
        teamName: payload.team.name,
        accessTokenEncrypted: encryptedToken,
        scopeList: scopes,
        updatedAt: new Date(),
      })
      .where(eq(slackInstallations.id, existing.id));
  } else {
    await db.insert(slackInstallations).values({
      id: createId("slack_install"),
      teamId: payload.team.id,
      teamName: payload.team.name,
      slackUserId: payload.authed_user.id,
      accessTokenEncrypted: encryptedToken,
      scopeList: scopes,
    });
  }

  return {
    teamId: payload.team.id,
    teamName: payload.team.name,
    slackUserId: payload.authed_user.id,
  };
}

export async function getSlackInstallStatus(): Promise<{
  connected: boolean;
  configured: boolean;
  clientIdConfigured: boolean;
  clientSecretConfigured: boolean;
  redirectUri: string;
  redirectUriSecure: boolean;
  installUrl: string | null;
  requiredUserScopes: string[];
  missingRequirements: string[];
  teamName: string | null;
  slackUserId: string | null;
  connectedAt: string | null;
}> {
  const setup = getSlackSetupState();
  const install = await db.query.slackInstallations.findFirst();
  if (!install) {
    return {
      connected: false,
      ...setup,
      teamName: null,
      slackUserId: null,
      connectedAt: null,
    };
  }

  return {
    connected: true,
    ...setup,
    teamName: install.teamName,
    slackUserId: install.slackUserId,
    connectedAt: install.updatedAt.toISOString(),
  };
}
