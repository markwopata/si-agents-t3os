ALTER TABLE "agent_query_logs"
ADD COLUMN "log_type" text NOT NULL DEFAULT 'query',
ADD COLUMN "auth_source" text,
ADD COLUMN "method" text,
ADD COLUMN "request_path" text,
ADD COLUMN "status_code" integer,
ADD COLUMN "duration_ms" integer,
ADD COLUMN "user_agent" text;
