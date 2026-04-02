CREATE TABLE IF NOT EXISTS document_content_extracts (
  id text PRIMARY KEY,
  initiative_id text NOT NULL REFERENCES initiatives(id) ON DELETE CASCADE,
  sync_run_id text,
  source_type text NOT NULL,
  source_key text NOT NULL,
  source_id text NOT NULL,
  parent_source_id text,
  title text NOT NULL,
  mime_type text,
  extractor text NOT NULL,
  extraction_status text NOT NULL,
  extracted_text text NOT NULL DEFAULT '',
  summary text NOT NULL DEFAULT '',
  source_updated_at timestamptz,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS document_content_extracts_source_key_idx
  ON document_content_extracts(source_type, source_key);
