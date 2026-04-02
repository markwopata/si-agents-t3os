CREATE TABLE IF NOT EXISTS slack_file_events (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  sync_run_id text REFERENCES slack_sync_runs(id) ON DELETE SET NULL,
  channel_id text NOT NULL,
  message_ts text NOT NULL,
  parent_ts text,
  slack_file_id text NOT NULL,
  title text,
  name text,
  mime_type text,
  file_type text,
  pretty_type text,
  size_bytes integer,
  permalink text,
  private_url text,
  private_download_url text,
  text_excerpt text,
  raw_json jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS slack_file_events_channel_message_file_idx
  ON slack_file_events(channel_id, message_ts, slack_file_id);

ALTER TABLE google_file_snapshots
  ADD COLUMN IF NOT EXISTS depth integer NOT NULL DEFAULT 0;

ALTER TABLE google_file_snapshots
  ADD COLUMN IF NOT EXISTS crawl_path text NOT NULL DEFAULT '';

CREATE TABLE IF NOT EXISTS integration_sync_issues (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  source_type text NOT NULL,
  run_id text,
  source_id text,
  severity text NOT NULL DEFAULT 'error',
  error_code text NOT NULL,
  message text NOT NULL,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);
