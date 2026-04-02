CREATE TABLE IF NOT EXISTS initiatives (
  id text PRIMARY KEY,
  code text NOT NULL UNIQUE,
  title text NOT NULL,
  objective text NOT NULL DEFAULT '',
  "group" text NOT NULL DEFAULT '',
  target_cadence text NOT NULL DEFAULT '',
  update_type text NOT NULL DEFAULT '',
  stage text NOT NULL DEFAULT '',
  l_class text NOT NULL DEFAULT '',
  progress text NOT NULL DEFAULT '',
  lead_performance text NOT NULL DEFAULT '',
  administration_health text NOT NULL DEFAULT '',
  impact_type text NOT NULL DEFAULT '',
  in_cap_plan boolean,
  is_active boolean NOT NULL DEFAULT true,
  source_row_number integer,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS initiative_people (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  role text NOT NULL,
  display_name text NOT NULL,
  email text,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS initiative_links (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  link_type text NOT NULL,
  label text NOT NULL DEFAULT '',
  url text NOT NULL DEFAULT '',
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS initiative_period_snapshots (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  period_key text NOT NULL,
  category text NOT NULL,
  status text NOT NULL DEFAULT '',
  baseline_value text NOT NULL DEFAULT '',
  booked_value text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS knowledge_documents (
  id text PRIMARY KEY,
  initiative_id text REFERENCES initiatives(id) ON DELETE CASCADE,
  document_type text NOT NULL,
  slug text NOT NULL UNIQUE,
  title text NOT NULL,
  content text NOT NULL DEFAULT '',
  version integer NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS service_tokens (
  id text PRIMARY KEY,
  label text NOT NULL,
  token_hash text NOT NULL,
  token_preview text NOT NULL,
  scopes jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS audit_events (
  id text PRIMARY KEY,
  actor_type text NOT NULL,
  actor_id text NOT NULL,
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id text NOT NULL,
  payload jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS source_import_batches (
  id text PRIMARY KEY,
  source_name text NOT NULL,
  source_path text NOT NULL,
  status text NOT NULL,
  summary jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS source_import_rows (
  id text PRIMARY KEY,
  batch_id text NOT NULL REFERENCES source_import_batches(id) ON DELETE CASCADE,
  sheet_name text NOT NULL,
  row_number integer NOT NULL,
  row_key text,
  raw_json jsonb NOT NULL,
  mapped_json jsonb,
  error_text text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS slack_installations (
  id text PRIMARY KEY,
  team_id text NOT NULL,
  team_name text NOT NULL,
  slack_user_id text NOT NULL,
  access_token_encrypted text NOT NULL,
  scope_list jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS agent_runs (
  id text PRIMARY KEY,
  requested_by_type text NOT NULL,
  requested_by_id text NOT NULL,
  run_scope text NOT NULL,
  initiative_id text REFERENCES initiatives(id) ON DELETE SET NULL,
  status text NOT NULL,
  summary jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  finished_at timestamptz
);

CREATE TABLE IF NOT EXISTS agent_observations (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  agent_run_id text REFERENCES agent_runs(id) ON DELETE SET NULL,
  status_recommendation text NOT NULL,
  progress_assessment text NOT NULL,
  confidence_score real NOT NULL,
  top_blockers jsonb NOT NULL,
  suggested_next_actions jsonb NOT NULL,
  evidence_summary text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS agent_evidence_refs (
  id text PRIMARY KEY,
  observation_id text NOT NULL REFERENCES agent_observations(id) ON DELETE CASCADE,
  source_type text NOT NULL,
  source_id text NOT NULL,
  title text NOT NULL,
  url text,
  excerpt text NOT NULL,
  metadata jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS initiative_status_history (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  observation_id text REFERENCES agent_observations(id) ON DELETE SET NULL,
  status_recommendation text NOT NULL,
  rationale text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

