CREATE TABLE IF NOT EXISTS "user_api_tokens" (
  "id" text PRIMARY KEY NOT NULL,
  "owner_user_id" text NOT NULL,
  "owner_email" text,
  "owner_display_name" text,
  "owner_workspace_id" text,
  "label" text NOT NULL,
  "token_hash" text NOT NULL,
  "token_preview" text NOT NULL,
  "scopes" jsonb NOT NULL,
  "last_used_at" timestamp with time zone,
  "created_at" timestamp with time zone NOT NULL DEFAULT now()
);
