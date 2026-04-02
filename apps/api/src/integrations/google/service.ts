import { createHmac, createSign, randomBytes } from "node:crypto";
import { readFileSync } from "node:fs";
import { desc, eq } from "drizzle-orm";
import { env } from "../../config/env.js";
import { db } from "../../db/client.js";
import { googleInstallations } from "../../db/schema.js";
import { decryptSecret, encryptSecret } from "../../lib/crypto.js";
import { createId } from "../../lib/id.js";

interface GoogleTokenResponse {
  access_token?: string;
  expires_in?: number;
  refresh_token?: string;
  scope?: string;
  token_type?: string;
  id_token?: string;
  error?: string;
  error_description?: string;
}

interface GoogleUserInfoResponse {
  id?: string;
  email?: string;
}

interface GoogleServiceAccountCredentials {
  type?: string;
  project_id?: string;
  private_key?: string;
  client_email?: string;
  token_uri?: string;
}

type GoogleAuthMode = "oauth" | "service_account" | "unconfigured";

let serviceAccountCredentialsCache: GoogleServiceAccountCredentials | null | undefined;

function base64UrlEncode(input: string): string {
  return Buffer.from(input)
    .toString("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

function getGoogleScopes(): string[] {
  return env.GOOGLE_SCOPES.split(",").filter(Boolean);
}

function loadServiceAccountCredentials(): GoogleServiceAccountCredentials | null {
  if (serviceAccountCredentialsCache !== undefined) {
    return serviceAccountCredentialsCache;
  }

  const raw =
    env.GOOGLE_SERVICE_ACCOUNT_JSON ||
    (env.GOOGLE_SERVICE_ACCOUNT_KEY_PATH ? readFileSync(env.GOOGLE_SERVICE_ACCOUNT_KEY_PATH, "utf8") : null);

  if (!raw) {
    serviceAccountCredentialsCache = null;
    return serviceAccountCredentialsCache;
  }

  try {
    const parsed = JSON.parse(raw) as GoogleServiceAccountCredentials;
    serviceAccountCredentialsCache = parsed;
    return serviceAccountCredentialsCache;
  } catch (error) {
    throw new Error(
      `Unable to parse Google service account credentials: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
}

function isServiceAccountConfigured(): boolean {
  const credentials = loadServiceAccountCredentials();
  return Boolean(
    credentials?.type === "service_account" &&
      credentials.client_email &&
      credentials.private_key &&
      credentials.token_uri,
  );
}

function shouldUseServiceAccount(): boolean {
  if (env.GOOGLE_AUTH_MODE === "oauth") {
    return false;
  }

  if (env.GOOGLE_AUTH_MODE === "service_account") {
    return true;
  }

  return isServiceAccountConfigured();
}

async function getServiceAccountAccessToken(): Promise<string> {
  const credentials = loadServiceAccountCredentials();
  if (
    credentials?.type !== "service_account" ||
    !credentials.client_email ||
    !credentials.private_key ||
    !credentials.token_uri
  ) {
    throw new Error("Google service account credentials are not configured");
  }

  const now = Math.floor(Date.now() / 1000);
  const header = {
    alg: "RS256",
    typ: "JWT",
  };
  const payload = {
    iss: credentials.client_email,
    scope: getGoogleScopes().join(" "),
    aud: credentials.token_uri,
    exp: now + 3600,
    iat: now,
    ...(env.GOOGLE_SERVICE_ACCOUNT_SUBJECT ? { sub: env.GOOGLE_SERVICE_ACCOUNT_SUBJECT } : {}),
  };

  const unsignedToken = `${base64UrlEncode(JSON.stringify(header))}.${base64UrlEncode(JSON.stringify(payload))}`;
  const signer = createSign("RSA-SHA256");
  signer.update(unsignedToken);
  signer.end();

  const signature = signer
    .sign(credentials.private_key, "base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  const response = await fetch(credentials.token_uri, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsignedToken}.${signature}`,
    }),
  });

  const payloadText = await response.text();
  if (!response.ok) {
    throw new Error(`Google service account token exchange failed with HTTP ${response.status}: ${payloadText}`);
  }

  const payloadJson = JSON.parse(payloadText) as GoogleTokenResponse;
  if (!payloadJson.access_token) {
    throw new Error(payloadJson.error_description ?? payloadJson.error ?? "Google service account token exchange failed");
  }

  return payloadJson.access_token;
}

function signState(payload: string): string {
  return createHmac("sha256", env.TOKEN_ENCRYPTION_SECRET).update(payload).digest("hex");
}

export function verifyGoogleState(state: string): boolean {
  const [nonce, signature] = state.split(".");
  return Boolean(nonce && signature && signState(nonce) === signature);
}

function getGoogleSetupState(): {
  configured: boolean;
  authMode: GoogleAuthMode;
  clientIdConfigured: boolean;
  clientSecretConfigured: boolean;
  serviceAccountConfigured: boolean;
  redirectUri: string;
  installUrl: string | null;
  requiredScopes: string[];
  missingRequirements: string[];
} {
  const clientIdConfigured = Boolean(env.GOOGLE_CLIENT_ID);
  const clientSecretConfigured = Boolean(env.GOOGLE_CLIENT_SECRET);
  const serviceAccountConfigured = isServiceAccountConfigured();
  const authMode =
    shouldUseServiceAccount() ? "service_account" : clientIdConfigured && clientSecretConfigured ? "oauth" : "unconfigured";
  const requiredScopes = getGoogleScopes();
  const missingRequirements: string[] = [];

  if (env.GOOGLE_AUTH_MODE !== "service_account" && !clientIdConfigured) {
    missingRequirements.push("Add GOOGLE_CLIENT_ID to .env.");
  }

  if (env.GOOGLE_AUTH_MODE !== "service_account" && !clientSecretConfigured) {
    missingRequirements.push("Add GOOGLE_CLIENT_SECRET to .env.");
  }

  if (env.GOOGLE_AUTH_MODE !== "oauth" && !serviceAccountConfigured) {
    missingRequirements.push(
      "Add GOOGLE_SERVICE_ACCOUNT_JSON or GOOGLE_SERVICE_ACCOUNT_KEY_PATH to use the Google service account path.",
    );
  }

  return {
    configured:
      authMode === "service_account"
        ? serviceAccountConfigured
        : clientIdConfigured && clientSecretConfigured,
    authMode,
    clientIdConfigured,
    clientSecretConfigured,
    serviceAccountConfigured,
    redirectUri: env.GOOGLE_REDIRECT_URI,
    installUrl: clientIdConfigured ? createGoogleInstallUrl() : null,
    requiredScopes,
    missingRequirements,
  };
}

export function createGoogleInstallUrl(): string {
  if (!env.GOOGLE_CLIENT_ID) {
    throw new Error("Google client ID is not configured");
  }

  const nonce = randomBytes(12).toString("hex");
  const signedState = `${nonce}.${signState(nonce)}`;
  const params = new URLSearchParams({
    client_id: env.GOOGLE_CLIENT_ID,
    redirect_uri: env.GOOGLE_REDIRECT_URI,
    response_type: "code",
    access_type: "offline",
    prompt: "consent",
    include_granted_scopes: "true",
    state: signedState,
    scope: env.GOOGLE_SCOPES.split(",").join(" "),
  });

  return `https://accounts.google.com/o/oauth2/v2/auth?${params.toString()}`;
}

async function exchangeGoogleCode(code: string): Promise<GoogleTokenResponse> {
  if (!env.GOOGLE_CLIENT_ID || !env.GOOGLE_CLIENT_SECRET) {
    throw new Error("Google OAuth is not configured");
  }

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      code,
      client_id: env.GOOGLE_CLIENT_ID,
      client_secret: env.GOOGLE_CLIENT_SECRET,
      redirect_uri: env.GOOGLE_REDIRECT_URI,
      grant_type: "authorization_code",
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`Google token exchange failed with HTTP ${response.status}: ${errorBody}`);
  }

  return (await response.json()) as GoogleTokenResponse;
}

async function fetchGoogleUserInfo(accessToken: string): Promise<GoogleUserInfoResponse> {
  const response = await fetch("https://www.googleapis.com/oauth2/v2/userinfo", {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });

  if (!response.ok) {
    throw new Error(`Google userinfo failed with HTTP ${response.status}`);
  }

  return (await response.json()) as GoogleUserInfoResponse;
}

export async function upsertGoogleInstallationFromCode(code: string): Promise<{
  email: string;
  googleUserId: string | null;
}> {
  const tokenPayload = await exchangeGoogleCode(code);
  if (!tokenPayload.access_token) {
    throw new Error(tokenPayload.error_description ?? tokenPayload.error ?? "Google OAuth exchange failed");
  }

  const userInfo = await fetchGoogleUserInfo(tokenPayload.access_token);
  if (!userInfo.email) {
    throw new Error("Google account email was not returned");
  }

  const existing = await db.query.googleInstallations.findFirst({
    where: eq(googleInstallations.email, userInfo.email),
  });

  const refreshTokenEncrypted =
    tokenPayload.refresh_token
      ? encryptSecret(tokenPayload.refresh_token)
      : existing?.refreshTokenEncrypted;

  if (!refreshTokenEncrypted) {
    throw new Error("Google refresh token was not returned. Re-run OAuth consent to grant offline access.");
  }

  const accessTokenEncrypted = encryptSecret(tokenPayload.access_token);
  const scopeList = tokenPayload.scope
    ? tokenPayload.scope.split(" ").filter(Boolean)
    : env.GOOGLE_SCOPES.split(",").filter(Boolean);
  const tokenExpiresAt = tokenPayload.expires_in
    ? new Date(Date.now() + tokenPayload.expires_in * 1000)
    : null;

  if (existing) {
    await db
      .update(googleInstallations)
      .set({
        googleUserId: userInfo.id ?? existing.googleUserId,
        email: userInfo.email,
        accessTokenEncrypted,
        refreshTokenEncrypted,
        scopeList,
        tokenExpiresAt,
        updatedAt: new Date(),
      })
      .where(eq(googleInstallations.id, existing.id));
  } else {
    await db.insert(googleInstallations).values({
      id: createId("google_install"),
      googleUserId: userInfo.id ?? null,
      email: userInfo.email,
      accessTokenEncrypted,
      refreshTokenEncrypted,
      scopeList,
      tokenExpiresAt,
    });
  }

  return {
    email: userInfo.email,
    googleUserId: userInfo.id ?? null,
  };
}

async function refreshGoogleAccessToken(refreshToken: string): Promise<GoogleTokenResponse> {
  if (!env.GOOGLE_CLIENT_ID || !env.GOOGLE_CLIENT_SECRET) {
    throw new Error("Google OAuth is not configured");
  }

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      client_id: env.GOOGLE_CLIENT_ID,
      client_secret: env.GOOGLE_CLIENT_SECRET,
      refresh_token: refreshToken,
      grant_type: "refresh_token",
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`Google token refresh failed with HTTP ${response.status}: ${errorBody}`);
  }

  return (await response.json()) as GoogleTokenResponse;
}

export async function getGoogleAccessToken(): Promise<string | null> {
  if (shouldUseServiceAccount()) {
    return getServiceAccountAccessToken();
  }

  const installation = await db.query.googleInstallations.findFirst({
    orderBy: [desc(googleInstallations.updatedAt)],
  });

  if (!installation) {
    return null;
  }

  const expiresAt = installation.tokenExpiresAt?.getTime() ?? 0;
  if (expiresAt > Date.now() + 60_000) {
    return decryptSecret(installation.accessTokenEncrypted);
  }

  const refreshToken = decryptSecret(installation.refreshTokenEncrypted);
  const refreshed = await refreshGoogleAccessToken(refreshToken);
  if (!refreshed.access_token) {
    throw new Error(refreshed.error_description ?? refreshed.error ?? "Google access token refresh failed");
  }

  await db
    .update(googleInstallations)
    .set({
      accessTokenEncrypted: encryptSecret(refreshed.access_token),
      tokenExpiresAt: refreshed.expires_in
        ? new Date(Date.now() + refreshed.expires_in * 1000)
        : installation.tokenExpiresAt,
      updatedAt: new Date(),
    })
    .where(eq(googleInstallations.id, installation.id));

  return refreshed.access_token;
}

export async function getGoogleInstallStatus(): Promise<{
  connected: boolean;
  configured: boolean;
  authMode: GoogleAuthMode;
  clientIdConfigured: boolean;
  clientSecretConfigured: boolean;
  serviceAccountConfigured: boolean;
  redirectUri: string;
  installUrl: string | null;
  requiredScopes: string[];
  missingRequirements: string[];
  email: string | null;
  connectedAt: string | null;
}> {
  const setup = getGoogleSetupState();
  if (setup.authMode === "service_account") {
    const credentials = loadServiceAccountCredentials();
    return {
      connected: setup.configured,
      ...setup,
      email: credentials?.client_email ?? null,
      connectedAt: null,
    };
  }

  const installation = await db.query.googleInstallations.findFirst({
    orderBy: [desc(googleInstallations.updatedAt)],
  });

  if (!installation) {
    return {
      connected: false,
      ...setup,
      email: null,
      connectedAt: null,
    };
  }

  return {
    connected: true,
    ...setup,
    email: installation.email,
    connectedAt: installation.updatedAt.toISOString(),
  };
}
