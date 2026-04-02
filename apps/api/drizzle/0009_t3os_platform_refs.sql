ALTER TABLE initiative_people
  ADD COLUMN IF NOT EXISTS t3os_contact_id text;

ALTER TABLE initiative_people
  ADD COLUMN IF NOT EXISTS t3os_workspace_member_id text;

ALTER TABLE initiative_people
  ADD COLUMN IF NOT EXISTS t3os_user_id text;

ALTER TABLE initiative_people
  ADD COLUMN IF NOT EXISTS source_type text NOT NULL DEFAULT 'local';
