ALTER TABLE initiatives
  ADD COLUMN IF NOT EXISTS priority_rank integer,
  ADD COLUMN IF NOT EXISTS priority_score real,
  ADD COLUMN IF NOT EXISTS priority_reason text,
  ADD COLUMN IF NOT EXISTS priority_source text,
  ADD COLUMN IF NOT EXISTS ranking_updated_at timestamptz;

CREATE TABLE IF NOT EXISTS portfolio_refresh_runs (
  id text PRIMARY KEY,
  status text NOT NULL,
  summary jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  finished_at timestamptz
);
