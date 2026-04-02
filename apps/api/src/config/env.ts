import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { config as loadDotenv } from "dotenv";
import { z } from "zod";

const configDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(configDir, "../../../../");

loadDotenv({ path: resolve(repoRoot, ".env") });
loadDotenv({ path: resolve(repoRoot, ".env.local"), override: true });
loadDotenv();

const envSchema = z.object({
  PORT: z.coerce.number().default(3001),
  HOST: z.string().default("0.0.0.0"),
  CORS_ALLOWED_ORIGINS: z.string().default("http://localhost:3000"),
  DATABASE_URL: z
    .string()
    .default("postgresql://si_management:si_management@localhost:54329/si_management"),
  DEV_AUTH_BYPASS: z
    .string()
    .default("true")
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
  T3OS_EXECUTIVE_EMAILS: z.string().default(""),
  T3OS_GRAPHQL_URL: z
    .string()
    .default("https://staging-api.equipmentshare.com/es-erp-api/graphql"),
  TOKEN_ENCRYPTION_SECRET: z.string().default("local-dev-encryption-secret"),
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
    .default("channels:history,groups:history,channels:read,groups:read,users:read"),
  SLACK_USER_SCOPES: z
    .string()
    .default("channels:history,groups:history,channels:read,groups:read,users:read"),
  GOOGLE_CLIENT_ID: z.string().optional(),
  GOOGLE_CLIENT_SECRET: z.string().optional(),
  GOOGLE_REDIRECT_URI: z.string().default("http://localhost:3001/integrations/google/callback"),
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
  ANALYTICS_CORPUS_PATH: z
    .string()
    .default("/Users/mark.wopata/code/cursor_all_data_org_code"),
  FROSTY_BASE_URL: z.string().default("http://localhost:8888"),
  FROSTY_REQUEST_TIMEOUT_MS: z.coerce.number().default(30000),
  ANALYTICS_SEARCH_TIMEOUT_MS: z.coerce.number().default(20000),
  KPI_RESEARCH_TIMEOUT_MS: z.coerce.number().default(45000),
  EVIDENCE_SYNC_REUSE_HOURS: z.coerce.number().default(12),
  PORTFOLIO_STEP_TIMEOUT_MS: z.coerce.number().default(600000),
});

export const env = envSchema.parse(process.env);
