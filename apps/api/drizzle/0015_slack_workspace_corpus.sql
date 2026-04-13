CREATE TABLE "slack_workspace_sync_runs" (
  "id" text PRIMARY KEY,
  "status" text NOT NULL,
  "sync_mode" text NOT NULL DEFAULT 'incremental',
  "conversation_types" jsonb NOT NULL DEFAULT '[]'::jsonb,
  "summary" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "finished_at" timestamptz
);

CREATE TABLE "slack_workspace_channels" (
  "channel_id" text PRIMARY KEY,
  "discovery_run_id" text REFERENCES "slack_workspace_sync_runs"("id") ON DELETE SET NULL,
  "name" text,
  "normalized_name" text,
  "conversation_type" text NOT NULL,
  "title" text,
  "topic" text,
  "purpose" text,
  "user_id" text,
  "member_count" integer,
  "is_archived" boolean NOT NULL DEFAULT false,
  "is_private" boolean NOT NULL DEFAULT false,
  "is_im" boolean NOT NULL DEFAULT false,
  "is_mpim" boolean NOT NULL DEFAULT false,
  "is_general" boolean NOT NULL DEFAULT false,
  "is_shared" boolean NOT NULL DEFAULT false,
  "is_ext_shared" boolean NOT NULL DEFAULT false,
  "is_org_shared" boolean NOT NULL DEFAULT false,
  "last_message_ts" text,
  "last_message_at" timestamptz,
  "last_discovered_at" timestamptz NOT NULL DEFAULT now(),
  "last_synced_at" timestamptz,
  "raw_json" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "updated_at" timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE "slack_workspace_sync_issues" (
  "id" text PRIMARY KEY,
  "run_id" text NOT NULL REFERENCES "slack_workspace_sync_runs"("id") ON DELETE CASCADE,
  "channel_id" text,
  "error_code" text NOT NULL,
  "message" text NOT NULL,
  "metadata" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "created_at" timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE "slack_workspace_message_events" (
  "id" text PRIMARY KEY,
  "sync_run_id" text REFERENCES "slack_workspace_sync_runs"("id") ON DELETE SET NULL,
  "channel_id" text NOT NULL REFERENCES "slack_workspace_channels"("channel_id") ON DELETE CASCADE,
  "ts" text NOT NULL,
  "thread_ts" text,
  "parent_ts" text,
  "is_thread_reply" boolean NOT NULL DEFAULT false,
  "message_at" timestamptz,
  "user_id" text,
  "text" text NOT NULL,
  "permalink" text,
  "reply_count" integer NOT NULL DEFAULT 0,
  "raw_json" jsonb NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX "slack_workspace_message_events_channel_ts_idx"
  ON "slack_workspace_message_events" ("channel_id", "ts");

CREATE TABLE "slack_workspace_file_events" (
  "id" text PRIMARY KEY,
  "sync_run_id" text REFERENCES "slack_workspace_sync_runs"("id") ON DELETE SET NULL,
  "channel_id" text NOT NULL REFERENCES "slack_workspace_channels"("channel_id") ON DELETE CASCADE,
  "message_ts" text NOT NULL,
  "parent_ts" text,
  "slack_file_id" text NOT NULL,
  "title" text,
  "name" text,
  "mime_type" text,
  "file_type" text,
  "pretty_type" text,
  "size_bytes" integer,
  "permalink" text,
  "private_url" text,
  "private_download_url" text,
  "text_excerpt" text,
  "raw_json" jsonb NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX "slack_workspace_file_events_channel_message_file_idx"
  ON "slack_workspace_file_events" ("channel_id", "message_ts", "slack_file_id");
