import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { config as loadDotenv } from "dotenv";
import { z } from "zod";

const configDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(configDir, "../../../../");

loadDotenv({ path: resolve(repoRoot, ".env") });
loadDotenv({ path: resolve(repoRoot, ".env.local"), override: true });
loadDotenv();

function firstDefined(...values: Array<string | undefined>): string | undefined {
  return values.find((value) => typeof value === "string" && value.trim().length > 0);
}

function defaultBooleanEnv(value: string | undefined, fallback: boolean): string {
  if (typeof value === "string") {
    return value;
  }
  return fallback ? "true" : "false";
}

const hostedRuntime = process.env.NODE_ENV === "production" || Boolean(process.env.RENDER);
const defaultDevAuthBypass = !hostedRuntime;
const defaultTokenEncryptionSecret = hostedRuntime ? undefined : "local-dev-encryption-secret";

const envSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().default(3001),
  HOST: z.string().default("0.0.0.0"),
  CORS_ALLOWED_ORIGINS: z.string().default("http://localhost:3000"),
  CORS_ALLOWED_ORIGIN_PATTERNS: z.string().default(""),
  DATABASE_URL: z
    .string()
    .default("postgresql://si_management:si_management@localhost:54329/si_management"),
  DEV_AUTH_BYPASS: z
    .string()
    .default(defaultDevAuthBypass ? "true" : "false")
    .transform((value) => value === "true"),
  T3OS_TRUST_HEADER_AUTH: z
    .string()
    .default("false")
    .transform((value) => value === "true"),
  T3OS_USER_ID_HEADER: z.string().default("x-t3os-user-id"),
  T3OS_USER_EMAIL_HEADER: z.string().default("x-t3os-user-email"),
  T3OS_USER_NAME_HEADER: z.string().default("x-t3os-user-name"),
  T3OS_APP_ROLE_HEADER: z.string().default("x-t3os-app-role"),
  T3OS_WORKSPACE_ID_HEADER: z.string().default("x-t3os-workspace-id"),
  T3OS_ADMIN_EMAILS: z
    .string()
    .default("mark.wopata@equipmentshare.com,kim.misher@equipmentshare.com"),
  T3OS_EXECUTIVE_EMAILS: z
    .string()
    .default("lindsey.malhiot@equipmentshare.com,jabbok@equipmentshare.com,will@equipmentshare.com"),
  T3OS_JWT_ISSUER: z.string().min(1),
  T3OS_JWT_AUDIENCE: z.string().min(1),
  T3OS_JWKS_URI: z.string().optional(),
  T3OS_GRAPHQL_URL: z
    .string()
    .default("https://staging-api.equipmentshare.com/es-erp-api/graphql"),
  TOKEN_ENCRYPTION_SECRET: z.string().min(1),
  WORKBOOK_PATH: z
    .string()
    .default("/Users/mark.wopata/Downloads/Strategic Initiatives_Program Summary & Status.xlsx"),
  GLOBAL_KNOWLEDGE_PATH: z
    .string()
    .default("knowledge-seeds/global-si-operating-model.md"),
  WEB_APP_URL: z.string().default("http://localhost:3000"),
  SLACK_CLIENT_ID: z.string().optional(),
  SLACK_CLIENT_SECRET: z.string().optional(),
  SLACK_REDIRECT_URI: z.string().default("http://localhost:3001/integrations/slack/callback"),
  SLACK_SCOPES: z
    .string()
    .default(
      "channels:history,groups:history,im:history,mpim:history,channels:read,groups:read,im:read,mpim:read,users:read",
    ),
  SLACK_USER_SCOPES: z
    .string()
    .default(
      "channels:history,groups:history,im:history,mpim:history,channels:read,groups:read,im:read,mpim:read,users:read",
    ),
  SLACK_WORKSPACE_CONVERSATION_TYPES: z
    .string()
    .default("public_channel,private_channel,mpim,im"),
  SLACK_WORKSPACE_CHANNEL_LIMIT: z.coerce.number().int().min(0).default(0),
  SLACK_WORKSPACE_CHANNEL_PREFIXES: z.string().default(""),
  SLACK_WORKSPACE_CHANNEL_IDS: z.string().default(""),
  SLACK_WORKSPACE_OLDEST_DATE: z.string().default(""),
  SLACK_WORKSPACE_SYNC_CONCURRENCY: z.coerce.number().int().min(1).max(16).default(6),
  SLACK_WORKSPACE_INCLUDE_ARCHIVED: z
    .string()
    .default("false")
    .transform((value) => value === "true"),
  GOOGLE_CLIENT_ID: z.string().optional(),
  GOOGLE_CLIENT_SECRET: z.string().optional(),
  GOOGLE_REDIRECT_URI: z.string().default("http://localhost:3001/integrations/google/callback"),
  GOOGLE_AUTH_MODE: z.enum(["auto", "oauth", "service_account"]).default("auto"),
  GOOGLE_SERVICE_ACCOUNT_KEY_PATH: z.string().optional(),
  GOOGLE_SERVICE_ACCOUNT_JSON: z.string().optional(),
  GOOGLE_SERVICE_ACCOUNT_PROJECT_ID: z.string().optional(),
  GOOGLE_SERVICE_ACCOUNT_CLIENT_EMAIL: z.string().optional(),
  GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY: z.string().optional(),
  GOOGLE_SERVICE_ACCOUNT_TOKEN_URI: z.string().optional(),
  GOOGLE_SERVICE_ACCOUNT_SUBJECT: z.string().optional(),
  GOOGLE_SCOPES: z
    .string()
    .default(
      [
        "openid",
        "email",
        "profile",
        "https://www.googleapis.com/auth/drive.readonly",
        "https://www.googleapis.com/auth/spreadsheets.readonly",
      ].join(","),
    ),
  OPENAI_API_KEY: z.string().optional(),
  OPENAI_EVALUATION_MODEL: z.string().default("gpt-5.4"),
  OPENAI_EVALUATION_REASONING_EFFORT: z.enum(["low", "medium", "high"]).default("high"),
  OPENAI_EVALUATION_TIMEOUT_MS: z.coerce.number().default(45000),
  OPENAI_KPI_MODEL: z.string().default("gpt-5.4"),
  OPENAI_KPI_REASONING_EFFORT: z.enum(["low", "medium", "high"]).default("high"),
  OPENAI_KPI_TIMEOUT_MS: z.coerce.number().default(300000),
  ANALYTICS_CORPUS_PATH: z
    .string()
    .default("/Users/mark.wopata/code/cursor_all_data_org_code"),
  ANALYTICS_CURATED_CORPUS_PATH: z.string().default(""),
  FROSTY_BASE_URL: z.string().default("http://localhost:8888"),
  FROSTY_SQL_WAREHOUSE: z.string().default("AD_HOC_WH"),
  FROSTY_REQUEST_TIMEOUT_MS: z.coerce.number().default(30000),
  ANALYTICS_SEARCH_TIMEOUT_MS: z.coerce.number().default(20000),
  KPI_RESEARCH_TIMEOUT_MS: z.coerce.number().default(360000),
  EVIDENCE_SYNC_REUSE_HOURS: z.coerce.number().default(12),
  PORTFOLIO_STEP_TIMEOUT_MS: z.coerce.number().default(600000),
  PORTFOLIO_CONCURRENCY: z.coerce.number().int().min(1).max(12).default(4),
  PORTFOLIO_PROCESS_INLINE: z
    .string()
    .default("true")
    .transform((value) => value === "true"),
});

const envInput = {
  ...process.env,
  NODE_ENV: firstDefined(process.env.NODE_ENV, "development"),
  DEV_AUTH_BYPASS: defaultBooleanEnv(process.env.DEV_AUTH_BYPASS, defaultDevAuthBypass),
  T3OS_JWT_ISSUER: firstDefined(
    process.env.T3OS_JWT_ISSUER,
    process.env.AUTH0_ISSUER_BASE_URL,
    "https://staging-auth.t3os.ai/",
  ),
  T3OS_JWT_AUDIENCE: firstDefined(
    process.env.T3OS_JWT_AUDIENCE,
    process.env.AUTH0_AUDIENCE,
    "https://staging-api.equipmentshare.com/es-erp-api",
  ),
  TOKEN_ENCRYPTION_SECRET: firstDefined(
    process.env.TOKEN_ENCRYPTION_SECRET,
    defaultTokenEncryptionSecret,
  ),
};

export const env = envSchema.parse(envInput);

if (hostedRuntime) {
  if (env.DEV_AUTH_BYPASS) {
    throw new Error("DEV_AUTH_BYPASS must be false in hosted environments.");
  }

  if (env.TOKEN_ENCRYPTION_SECRET === "local-dev-encryption-secret") {
    throw new Error("TOKEN_ENCRYPTION_SECRET must be explicitly configured in hosted environments.");
  }
}
