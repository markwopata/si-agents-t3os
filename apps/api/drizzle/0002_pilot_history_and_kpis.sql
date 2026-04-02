CREATE TABLE IF NOT EXISTS pilot_batches (
  id text PRIMARY KEY,
  status text NOT NULL,
  cohort_codes jsonb NOT NULL,
  summary jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  finished_at timestamptz
);

CREATE TABLE IF NOT EXISTS slack_sync_runs (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  channel_id text NOT NULL,
  channel_name text,
  status text NOT NULL,
  sync_mode text NOT NULL DEFAULT 'full_backfill',
  summary jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  finished_at timestamptz
);

CREATE TABLE IF NOT EXISTS slack_message_events (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  sync_run_id text REFERENCES slack_sync_runs(id) ON DELETE SET NULL,
  channel_id text NOT NULL,
  channel_name text,
  ts text NOT NULL,
  message_at timestamptz,
  user_id text,
  text text NOT NULL,
  permalink text,
  reply_count integer NOT NULL DEFAULT 0,
  raw_json jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS slack_message_events_channel_ts_idx
  ON slack_message_events(channel_id, ts);

CREATE TABLE IF NOT EXISTS slack_reply_events (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  sync_run_id text REFERENCES slack_sync_runs(id) ON DELETE SET NULL,
  channel_id text NOT NULL,
  parent_ts text NOT NULL,
  ts text NOT NULL,
  message_at timestamptz,
  user_id text,
  text text NOT NULL,
  raw_json jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS slack_reply_events_channel_ts_idx
  ON slack_reply_events(channel_id, ts);

CREATE TABLE IF NOT EXISTS google_sync_runs (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  root_file_id text,
  status text NOT NULL,
  summary jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  finished_at timestamptz
);

CREATE TABLE IF NOT EXISTS google_file_snapshots (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  sync_run_id text REFERENCES google_sync_runs(id) ON DELETE SET NULL,
  file_id text NOT NULL,
  parent_file_id text,
  name text NOT NULL,
  mime_type text,
  modified_time timestamptz,
  last_modifying_user text,
  web_view_link text,
  raw_json jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS google_revision_events (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  sync_run_id text REFERENCES google_sync_runs(id) ON DELETE SET NULL,
  file_id text NOT NULL,
  revision_id text NOT NULL,
  modified_time timestamptz,
  last_modifying_user text,
  raw_json jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS google_revision_events_file_revision_idx
  ON google_revision_events(file_id, revision_id);

CREATE TABLE IF NOT EXISTS tracker_parse_runs (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  google_sync_run_id text REFERENCES google_sync_runs(id) ON DELETE SET NULL,
  tracker_file_id text NOT NULL,
  tracker_name text NOT NULL,
  sheet_name text NOT NULL,
  status text NOT NULL,
  summary jsonb NOT NULL DEFAULT '{}'::jsonb,
  raw_sheet_json jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tracker_summary_fields (
  id text PRIMARY KEY,
  parse_run_id text NOT NULL REFERENCES tracker_parse_runs(id) ON DELETE CASCADE,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  field_key text NOT NULL,
  label text NOT NULL,
  value text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tracker_row_items (
  id text PRIMARY KEY,
  parse_run_id text NOT NULL REFERENCES tracker_parse_runs(id) ON DELETE CASCADE,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  row_number integer NOT NULL,
  item_type text,
  description text NOT NULL DEFAULT '',
  prioritization text,
  phase text,
  impact_potential text,
  impact_value text,
  confidence text,
  current_value_estimate text,
  status text,
  notes text,
  last_edited text,
  submitted_by text,
  raw_json jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS kpi_research_runs (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  agent_run_id text REFERENCES agent_runs(id) ON DELETE SET NULL,
  status text NOT NULL,
  summary jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  finished_at timestamptz
);

CREATE TABLE IF NOT EXISTS kpi_findings (
  id text PRIMARY KEY,
  research_run_id text NOT NULL REFERENCES kpi_research_runs(id) ON DELETE CASCADE,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  finding_class text NOT NULL,
  source_type text NOT NULL,
  metric_key text NOT NULL,
  label text NOT NULL,
  metric_value text,
  unit text,
  narrative text,
  source_ref text,
  provenance jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);
