CREATE TABLE IF NOT EXISTS "agent_query_logs" (
  "id" text PRIMARY KEY NOT NULL,
  "actor_type" text NOT NULL,
  "actor_id" text NOT NULL,
  "actor_email" text,
  "actor_role" text,
  "workspace_id" text,
  "route" text NOT NULL,
  "entity_type" text,
  "entity_id" text,
  "prompt" text,
  "request_payload" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "response_summary" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "status" text NOT NULL,
  "error_text" text,
  "created_at" timestamp with time zone NOT NULL DEFAULT now()
);
