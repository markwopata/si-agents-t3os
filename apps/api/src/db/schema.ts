import {
  boolean,
  integer,
  jsonb,
  pgTable,
  real,
  text,
  timestamp,
  uniqueIndex,
} from "drizzle-orm/pg-core";

export const initiatives = pgTable(
  "initiatives",
  {
    id: text("id").primaryKey(),
    code: text("code").notNull(),
    title: text("title").notNull(),
    objective: text("objective").notNull().default(""),
    group: text("group").notNull().default(""),
    targetCadence: text("target_cadence").notNull().default(""),
    updateType: text("update_type").notNull().default(""),
    stage: text("stage").notNull().default(""),
    lClass: text("l_class").notNull().default(""),
    progress: text("progress").notNull().default(""),
    leadPerformance: text("lead_performance").notNull().default(""),
    administrationHealth: text("administration_health").notNull().default(""),
    impactType: text("impact_type").notNull().default(""),
    inCapPlan: boolean("in_cap_plan"),
    isActive: boolean("is_active").notNull().default(true),
    priorityRank: integer("priority_rank"),
    priorityScore: real("priority_score"),
    priorityReason: text("priority_reason"),
    prioritySource: text("priority_source"),
    rankingUpdatedAt: timestamp("ranking_updated_at", { withTimezone: true }),
    sourceRowNumber: integer("source_row_number"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => ({
    codeIdx: uniqueIndex("initiatives_code_idx").on(table.code),
  }),
);

export const initiativePeople = pgTable("initiative_people", {
  id: text("id").primaryKey(),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  role: text("role").notNull(),
  displayName: text("display_name").notNull(),
  email: text("email"),
  t3osContactId: text("t3os_contact_id"),
  t3osWorkspaceMemberId: text("t3os_workspace_member_id"),
  t3osUserId: text("t3os_user_id"),
  sourceType: text("source_type").notNull().default("local"),
  sortOrder: integer("sort_order").notNull().default(0),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const initiativeLinks = pgTable("initiative_links", {
  id: text("id").primaryKey(),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  linkType: text("link_type").notNull(),
  label: text("label").notNull().default(""),
  url: text("url").notNull().default(""),
  sortOrder: integer("sort_order").notNull().default(0),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const initiativePeriodSnapshots = pgTable("initiative_period_snapshots", {
  id: text("id").primaryKey(),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  periodKey: text("period_key").notNull(),
  category: text("category").notNull(),
  status: text("status").notNull().default(""),
  baselineValue: text("baseline_value").notNull().default(""),
  bookedValue: text("booked_value").notNull().default(""),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const knowledgeDocuments = pgTable(
  "knowledge_documents",
  {
    id: text("id").primaryKey(),
    initiativeId: text("initiative_id").references(() => initiatives.id, { onDelete: "cascade" }),
    documentType: text("document_type").notNull(),
    slug: text("slug").notNull(),
    title: text("title").notNull(),
    content: text("content").notNull().default(""),
    version: integer("version").notNull().default(1),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => ({
    slugIdx: uniqueIndex("knowledge_documents_slug_idx").on(table.slug),
  }),
);

export const initiativeAnnotations = pgTable("initiative_annotations", {
  id: text("id").primaryKey(),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  annotationType: text("annotation_type").notNull(),
  title: text("title").notNull(),
  content: text("content").notNull().default(""),
  metadata: jsonb("metadata").$type<Record<string, unknown>>().notNull().default({}),
  createdByType: text("created_by_type").notNull(),
  createdById: text("created_by_id").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

export const initiativeRunConfigs = pgTable("initiative_run_configs", {
  id: text("id").primaryKey(),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  cadenceMode: text("cadence_mode").notNull().default("manual"),
  cadenceDetail: text("cadence_detail").notNull().default(""),
  alertThresholds: jsonb("alert_thresholds").$type<Record<string, unknown>>().notNull().default({}),
  customKpiRulesMarkdown: text("custom_kpi_rules_markdown").notNull().default(""),
  customInstructionsMarkdown: text("custom_instructions_markdown").notNull().default(""),
  goodLooksLikeMarkdown: text("good_looks_like_markdown").notNull().default(""),
  ownerNotesMarkdown: text("owner_notes_markdown").notNull().default(""),
  updatedByType: text("updated_by_type").notNull(),
  updatedById: text("updated_by_id").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

export const serviceTokens = pgTable("service_tokens", {
  id: text("id").primaryKey(),
  label: text("label").notNull(),
  tokenHash: text("token_hash").notNull(),
  tokenPreview: text("token_preview").notNull(),
  scopes: jsonb("scopes").$type<string[]>().notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const userApiTokens = pgTable("user_api_tokens", {
  id: text("id").primaryKey(),
  ownerUserId: text("owner_user_id").notNull(),
  ownerEmail: text("owner_email"),
  ownerDisplayName: text("owner_display_name"),
  ownerWorkspaceId: text("owner_workspace_id"),
  label: text("label").notNull(),
  tokenHash: text("token_hash").notNull(),
  tokenPreview: text("token_preview").notNull(),
  scopes: jsonb("scopes").$type<string[]>().notNull(),
  lastUsedAt: timestamp("last_used_at", { withTimezone: true }),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const auditEvents = pgTable("audit_events", {
  id: text("id").primaryKey(),
  actorType: text("actor_type").notNull(),
  actorId: text("actor_id").notNull(),
  action: text("action").notNull(),
  entityType: text("entity_type").notNull(),
  entityId: text("entity_id").notNull(),
  payload: jsonb("payload").$type<Record<string, unknown>>().notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const agentQueryLogs = pgTable("agent_query_logs", {
  id: text("id").primaryKey(),
  actorType: text("actor_type").notNull(),
  actorId: text("actor_id").notNull(),
  actorEmail: text("actor_email"),
  actorRole: text("actor_role"),
  workspaceId: text("workspace_id"),
  route: text("route").notNull(),
  entityType: text("entity_type"),
  entityId: text("entity_id"),
  prompt: text("prompt"),
  requestPayload: jsonb("request_payload").$type<Record<string, unknown>>().notNull().default({}),
  responseSummary: jsonb("response_summary")
    .$type<Record<string, unknown>>()
    .notNull()
    .default({}),
  status: text("status").notNull(),
  errorText: text("error_text"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const legacyContactMigrationRuns = pgTable("legacy_contact_migration_runs", {
  id: text("id").primaryKey(),
  mode: text("mode").notNull(),
  status: text("status").notNull(),
  workspaceId: text("workspace_id").notNull(),
  businessContactId: text("business_contact_id"),
  createdByType: text("created_by_type").notNull(),
  createdById: text("created_by_id").notNull(),
  summary: jsonb("summary").$type<Record<string, unknown>>().notNull().default({}),
  contactCandidates: jsonb("contact_candidates")
    .$type<Array<Record<string, unknown>>>()
    .notNull()
    .default([]),
  reviewQueue: jsonb("review_queue")
    .$type<Array<Record<string, unknown>>>()
    .notNull()
    .default([]),
  errorText: text("error_text"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  finishedAt: timestamp("finished_at", { withTimezone: true }),
});

export const sourceImportBatches = pgTable("source_import_batches", {
  id: text("id").primaryKey(),
  sourceName: text("source_name").notNull(),
  sourcePath: text("source_path").notNull(),
  status: text("status").notNull(),
  summary: jsonb("summary").$type<Record<string, unknown>>().notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const sourceImportRows = pgTable("source_import_rows", {
  id: text("id").primaryKey(),
  batchId: text("batch_id")
    .notNull()
    .references(() => sourceImportBatches.id, { onDelete: "cascade" }),
  sheetName: text("sheet_name").notNull(),
  rowNumber: integer("row_number").notNull(),
  rowKey: text("row_key"),
  rawJson: jsonb("raw_json").$type<Record<string, unknown>>().notNull(),
  mappedJson: jsonb("mapped_json").$type<Record<string, unknown>>(),
  errorText: text("error_text"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const slackInstallations = pgTable("slack_installations", {
  id: text("id").primaryKey(),
  teamId: text("team_id").notNull(),
  teamName: text("team_name").notNull(),
  slackUserId: text("slack_user_id").notNull(),
  accessTokenEncrypted: text("access_token_encrypted").notNull(),
  scopeList: jsonb("scope_list").$type<string[]>().notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

export const googleInstallations = pgTable("google_installations", {
  id: text("id").primaryKey(),
  googleUserId: text("google_user_id"),
  email: text("email").notNull(),
  accessTokenEncrypted: text("access_token_encrypted").notNull(),
  refreshTokenEncrypted: text("refresh_token_encrypted").notNull(),
  scopeList: jsonb("scope_list").$type<string[]>().notNull(),
  tokenExpiresAt: timestamp("token_expires_at", { withTimezone: true }),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

export const pilotBatches = pgTable("pilot_batches", {
  id: text("id").primaryKey(),
  status: text("status").notNull(),
  cohortCodes: jsonb("cohort_codes").$type<string[]>().notNull(),
  summary: jsonb("summary").$type<Record<string, unknown>>().notNull().default({}),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  finishedAt: timestamp("finished_at", { withTimezone: true }),
});

export const portfolioRefreshRuns = pgTable("portfolio_refresh_runs", {
  id: text("id").primaryKey(),
  status: text("status").notNull(),
  summary: jsonb("summary").$type<Record<string, unknown>>().notNull().default({}),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  finishedAt: timestamp("finished_at", { withTimezone: true }),
});

export const slackSyncRuns = pgTable("slack_sync_runs", {
  id: text("id").primaryKey(),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  channelId: text("channel_id").notNull(),
  channelName: text("channel_name"),
  status: text("status").notNull(),
  syncMode: text("sync_mode").notNull().default("full_backfill"),
  summary: jsonb("summary").$type<Record<string, unknown>>().notNull().default({}),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  finishedAt: timestamp("finished_at", { withTimezone: true }),
});

export const slackMessageEvents = pgTable(
  "slack_message_events",
  {
    id: text("id").primaryKey(),
    initiativeId: text("initiative_id")
      .notNull()
      .references(() => initiatives.id, { onDelete: "cascade" }),
    syncRunId: text("sync_run_id").references(() => slackSyncRuns.id, { onDelete: "set null" }),
    channelId: text("channel_id").notNull(),
    channelName: text("channel_name"),
    ts: text("ts").notNull(),
    messageAt: timestamp("message_at", { withTimezone: true }),
    userId: text("user_id"),
    text: text("text").notNull(),
    permalink: text("permalink"),
    replyCount: integer("reply_count").notNull().default(0),
    rawJson: jsonb("raw_json").$type<Record<string, unknown>>().notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => ({
    slackMessageUnique: uniqueIndex("slack_message_events_channel_ts_idx").on(table.channelId, table.ts),
  }),
);

export const slackReplyEvents = pgTable(
  "slack_reply_events",
  {
    id: text("id").primaryKey(),
    initiativeId: text("initiative_id")
      .notNull()
      .references(() => initiatives.id, { onDelete: "cascade" }),
    syncRunId: text("sync_run_id").references(() => slackSyncRuns.id, { onDelete: "set null" }),
    channelId: text("channel_id").notNull(),
    parentTs: text("parent_ts").notNull(),
    ts: text("ts").notNull(),
    messageAt: timestamp("message_at", { withTimezone: true }),
    userId: text("user_id"),
    text: text("text").notNull(),
    rawJson: jsonb("raw_json").$type<Record<string, unknown>>().notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => ({
    slackReplyUnique: uniqueIndex("slack_reply_events_channel_ts_idx").on(table.channelId, table.ts),
  }),
);

export const slackFileEvents = pgTable(
  "slack_file_events",
  {
    id: text("id").primaryKey(),
    initiativeId: text("initiative_id")
      .notNull()
      .references(() => initiatives.id, { onDelete: "cascade" }),
    syncRunId: text("sync_run_id").references(() => slackSyncRuns.id, { onDelete: "set null" }),
    channelId: text("channel_id").notNull(),
    messageTs: text("message_ts").notNull(),
    parentTs: text("parent_ts"),
    slackFileId: text("slack_file_id").notNull(),
    title: text("title"),
    name: text("name"),
    mimeType: text("mime_type"),
    fileType: text("file_type"),
    prettyType: text("pretty_type"),
    sizeBytes: integer("size_bytes"),
    permalink: text("permalink"),
    privateUrl: text("private_url"),
    privateDownloadUrl: text("private_download_url"),
    textExcerpt: text("text_excerpt"),
    rawJson: jsonb("raw_json").$type<Record<string, unknown>>().notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => ({
    slackFileUnique: uniqueIndex("slack_file_events_channel_message_file_idx").on(
      table.channelId,
      table.messageTs,
      table.slackFileId,
    ),
  }),
);

export const googleSyncRuns = pgTable("google_sync_runs", {
  id: text("id").primaryKey(),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  rootFileId: text("root_file_id"),
  status: text("status").notNull(),
  summary: jsonb("summary").$type<Record<string, unknown>>().notNull().default({}),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  finishedAt: timestamp("finished_at", { withTimezone: true }),
});

export const googleFileSnapshots = pgTable("google_file_snapshots", {
  id: text("id").primaryKey(),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  syncRunId: text("sync_run_id").references(() => googleSyncRuns.id, { onDelete: "set null" }),
  fileId: text("file_id").notNull(),
  parentFileId: text("parent_file_id"),
  depth: integer("depth").notNull().default(0),
  crawlPath: text("crawl_path").notNull().default(""),
  name: text("name").notNull(),
  mimeType: text("mime_type"),
  modifiedTime: timestamp("modified_time", { withTimezone: true }),
  lastModifyingUser: text("last_modifying_user"),
  webViewLink: text("web_view_link"),
  rawJson: jsonb("raw_json").$type<Record<string, unknown>>().notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const integrationSyncIssues = pgTable("integration_sync_issues", {
  id: text("id").primaryKey(),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  sourceType: text("source_type").notNull(),
  runId: text("run_id"),
  sourceId: text("source_id"),
  severity: text("severity").notNull().default("error"),
  errorCode: text("error_code").notNull(),
  message: text("message").notNull(),
  metadata: jsonb("metadata").$type<Record<string, unknown>>().notNull().default({}),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const documentContentExtracts = pgTable(
  "document_content_extracts",
  {
    id: text("id").primaryKey(),
    initiativeId: text("initiative_id")
      .notNull()
      .references(() => initiatives.id, { onDelete: "cascade" }),
    syncRunId: text("sync_run_id"),
    sourceType: text("source_type").notNull(),
    sourceKey: text("source_key").notNull(),
    sourceId: text("source_id").notNull(),
    parentSourceId: text("parent_source_id"),
    title: text("title").notNull(),
    mimeType: text("mime_type"),
    extractor: text("extractor").notNull(),
    extractionStatus: text("extraction_status").notNull(),
    extractedText: text("extracted_text").notNull().default(""),
    summary: text("summary").notNull().default(""),
    sourceUpdatedAt: timestamp("source_updated_at", { withTimezone: true }),
    metadata: jsonb("metadata").$type<Record<string, unknown>>().notNull().default({}),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => ({
    documentExtractSourceKeyIdx: uniqueIndex("document_content_extracts_source_key_idx").on(
      table.sourceType,
      table.sourceKey,
    ),
  }),
);

export const googleRevisionEvents = pgTable(
  "google_revision_events",
  {
    id: text("id").primaryKey(),
    initiativeId: text("initiative_id")
      .notNull()
      .references(() => initiatives.id, { onDelete: "cascade" }),
    syncRunId: text("sync_run_id").references(() => googleSyncRuns.id, { onDelete: "set null" }),
    fileId: text("file_id").notNull(),
    revisionId: text("revision_id").notNull(),
    modifiedTime: timestamp("modified_time", { withTimezone: true }),
    lastModifyingUser: text("last_modifying_user"),
    rawJson: jsonb("raw_json").$type<Record<string, unknown>>().notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => ({
    googleRevisionUnique: uniqueIndex("google_revision_events_file_revision_idx").on(
      table.fileId,
      table.revisionId,
    ),
  }),
);

export const trackerParseRuns = pgTable("tracker_parse_runs", {
  id: text("id").primaryKey(),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  googleSyncRunId: text("google_sync_run_id").references(() => googleSyncRuns.id, {
    onDelete: "set null",
  }),
  trackerFileId: text("tracker_file_id").notNull(),
  trackerName: text("tracker_name").notNull(),
  sheetName: text("sheet_name").notNull(),
  status: text("status").notNull(),
  summary: jsonb("summary").$type<Record<string, unknown>>().notNull().default({}),
  rawSheetJson: jsonb("raw_sheet_json").$type<unknown[]>().notNull().default([]),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const trackerSummaryFields = pgTable("tracker_summary_fields", {
  id: text("id").primaryKey(),
  parseRunId: text("parse_run_id")
    .notNull()
    .references(() => trackerParseRuns.id, { onDelete: "cascade" }),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  fieldKey: text("field_key").notNull(),
  label: text("label").notNull(),
  value: text("value").notNull().default(""),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const trackerRowItems = pgTable("tracker_row_items", {
  id: text("id").primaryKey(),
  parseRunId: text("parse_run_id")
    .notNull()
    .references(() => trackerParseRuns.id, { onDelete: "cascade" }),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  rowNumber: integer("row_number").notNull(),
  itemType: text("item_type"),
  description: text("description").notNull().default(""),
  prioritization: text("prioritization"),
  phase: text("phase"),
  impactPotential: text("impact_potential"),
  impactValue: text("impact_value"),
  confidence: text("confidence"),
  currentValueEstimate: text("current_value_estimate"),
  status: text("status"),
  notes: text("notes"),
  lastEdited: text("last_edited"),
  submittedBy: text("submitted_by"),
  rawJson: jsonb("raw_json").$type<Record<string, unknown>>().notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const agentRuns = pgTable("agent_runs", {
  id: text("id").primaryKey(),
  requestedByType: text("requested_by_type").notNull(),
  requestedById: text("requested_by_id").notNull(),
  runScope: text("run_scope").notNull(),
  initiativeId: text("initiative_id").references(() => initiatives.id, { onDelete: "set null" }),
  status: text("status").notNull(),
  summary: jsonb("summary").$type<Record<string, unknown>>(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  finishedAt: timestamp("finished_at", { withTimezone: true }),
});

export const kpiResearchRuns = pgTable("kpi_research_runs", {
  id: text("id").primaryKey(),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  agentRunId: text("agent_run_id").references(() => agentRuns.id, { onDelete: "set null" }),
  status: text("status").notNull(),
  summary: jsonb("summary").$type<Record<string, unknown>>().notNull().default({}),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  finishedAt: timestamp("finished_at", { withTimezone: true }),
});

export const kpiFindings = pgTable("kpi_findings", {
  id: text("id").primaryKey(),
  researchRunId: text("research_run_id")
    .notNull()
    .references(() => kpiResearchRuns.id, { onDelete: "cascade" }),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  findingClass: text("finding_class").notNull(),
  sourceType: text("source_type").notNull(),
  metricKey: text("metric_key").notNull(),
  label: text("label").notNull(),
  metricValue: text("metric_value"),
  unit: text("unit"),
  narrative: text("narrative"),
  sourceRef: text("source_ref"),
  provenance: jsonb("provenance").$type<Record<string, unknown>>().notNull().default({}),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const agentObservations = pgTable("agent_observations", {
  id: text("id").primaryKey(),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  agentRunId: text("agent_run_id").references(() => agentRuns.id, { onDelete: "set null" }),
  statusRecommendation: text("status_recommendation").notNull(),
  progressAssessment: text("progress_assessment").notNull(),
  confidenceScore: real("confidence_score").notNull(),
  topBlockers: jsonb("top_blockers").$type<string[]>().notNull(),
  suggestedNextActions: jsonb("suggested_next_actions").$type<string[]>().notNull(),
  evidenceSummary: text("evidence_summary").notNull(),
  upcomingQuarterEarningsImpact: jsonb("upcoming_quarter_earnings_impact")
    .$type<Record<string, unknown> | null>()
    .default(null),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const agentObservationReviews = pgTable(
  "agent_observation_reviews",
  {
    id: text("id").primaryKey(),
    observationId: text("observation_id")
      .notNull()
      .references(() => agentObservations.id, { onDelete: "cascade" }),
    initiativeId: text("initiative_id")
      .notNull()
      .references(() => initiatives.id, { onDelete: "cascade" }),
    verdict: text("verdict").notNull(),
    note: text("note").notNull().default(""),
    reviewerType: text("reviewer_type").notNull(),
    reviewerId: text("reviewer_id").notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => ({
    observationReviewUnique: uniqueIndex("agent_observation_reviews_observation_idx").on(
      table.observationId,
    ),
  }),
);

export const agentEvidenceRefs = pgTable("agent_evidence_refs", {
  id: text("id").primaryKey(),
  observationId: text("observation_id")
    .notNull()
    .references(() => agentObservations.id, { onDelete: "cascade" }),
  sourceType: text("source_type").notNull(),
  sourceId: text("source_id").notNull(),
  title: text("title").notNull(),
  url: text("url"),
  excerpt: text("excerpt").notNull(),
  metadata: jsonb("metadata").$type<Record<string, unknown>>().notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export const initiativeStatusHistory = pgTable("initiative_status_history", {
  id: text("id").primaryKey(),
  initiativeId: text("initiative_id")
    .notNull()
    .references(() => initiatives.id, { onDelete: "cascade" }),
  observationId: text("observation_id").references(() => agentObservations.id, {
    onDelete: "set null",
  }),
  statusRecommendation: text("status_recommendation").notNull(),
  rationale: text("rationale").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});
