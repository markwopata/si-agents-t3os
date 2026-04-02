CREATE TABLE IF NOT EXISTS google_installations (
  id text PRIMARY KEY,
  google_user_id text,
  email text NOT NULL,
  access_token_encrypted text NOT NULL,
  refresh_token_encrypted text NOT NULL,
  scope_list jsonb NOT NULL,
  token_expires_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
