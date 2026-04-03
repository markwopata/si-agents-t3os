CREATE TABLE IF NOT EXISTS legacy_contact_migration_runs (
  id text PRIMARY KEY,
  mode text NOT NULL,
  status text NOT NULL,
  workspace_id text NOT NULL,
  business_contact_id text,
  created_by_type text NOT NULL,
  created_by_id text NOT NULL,
  summary jsonb NOT NULL DEFAULT '{}'::jsonb,
  contact_candidates jsonb NOT NULL DEFAULT '[]'::jsonb,
  review_queue jsonb NOT NULL DEFAULT '[]'::jsonb,
  error_text text,
  created_at timestamptz NOT NULL DEFAULT now(),
  finished_at timestamptz
);
