create table if not exists "agent_observation_reviews" (
  "id" text primary key,
  "observation_id" text not null references "agent_observations"("id") on delete cascade,
  "initiative_id" text not null references "initiatives"("id") on delete cascade,
  "verdict" text not null,
  "note" text not null default '',
  "reviewer_type" text not null,
  "reviewer_id" text not null,
  "created_at" timestamp with time zone not null default now(),
  "updated_at" timestamp with time zone not null default now()
);

create unique index if not exists "agent_observation_reviews_observation_idx"
  on "agent_observation_reviews" ("observation_id");
