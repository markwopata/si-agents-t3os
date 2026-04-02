CREATE TABLE IF NOT EXISTS initiative_run_configs (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  cadence_mode text NOT NULL DEFAULT 'manual',
  cadence_detail text NOT NULL DEFAULT '',
  alert_thresholds jsonb NOT NULL DEFAULT '{}'::jsonb,
  custom_kpi_rules_markdown text NOT NULL DEFAULT '',
  custom_instructions_markdown text NOT NULL DEFAULT '',
  good_looks_like_markdown text NOT NULL DEFAULT '',
  owner_notes_markdown text NOT NULL DEFAULT '',
  updated_by_type text NOT NULL,
  updated_by_id text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
