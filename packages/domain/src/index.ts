import { z } from "zod";

export const personRoleEnum = z.enum([
  "exec_owner",
  "group_owner",
  "initiative_owner",
  "si_analytics_owner",
  "sales_lead",
  "ops_lead",
  "analytics_lead",
  "pm",
  "other_invitee",
]);

export const linkTypeEnum = z.enum([
  "folder",
  "channel",
  "playbook",
  "dashboard",
  "other",
]);

export const snapshotCategoryEnum = z.enum([
  "financial",
  "kpi",
]);

export const knowledgeDocumentTypeEnum = z.enum([
  "global",
  "initiative",
]);

export const initiativeAnnotationTypeEnum = z.enum([
  "detail_note",
  "operating_instruction",
  "analysis_instruction",
  "kpi_suggestion",
]);

export const appUserRoleEnum = z.enum([
  "admin",
  "executive",
  "member",
]);

export const runCadenceModeEnum = z.enum([
  "manual",
  "daily",
  "weekly",
  "monthly",
]);

export const tokenScopeEnum = z.enum([
  "read:initiatives",
  "write:initiatives",
  "read:knowledge",
  "write:knowledge",
  "read:observations",
  "write:observations",
  "read:platform",
  "write:platform",
  "run:agents",
  "manage:tokens",
]);

export const agentRunStatusEnum = z.enum([
  "queued",
  "running",
  "completed",
  "failed",
]);

export const statusRecommendationEnum = z.enum([
  "on_track",
  "stalled",
  "at_risk",
  "off_track",
  "needs_attention",
]);

export const prioritySourceEnum = z.enum([
  "system",
  "manual",
]);

export const observationReviewVerdictEnum = z.enum([
  "agree",
  "needs_adjustment",
  "incorrect",
]);

export const initiativeBaseSchema = z.object({
  code: z.string().min(1),
  title: z.string().min(1),
  objective: z.string().default(""),
  group: z.string().default(""),
  targetCadence: z.string().default(""),
  updateType: z.string().default(""),
  stage: z.string().default(""),
  lClass: z.string().default(""),
  progress: z.string().default(""),
  leadPerformance: z.string().default(""),
  administrationHealth: z.string().default(""),
  impactType: z.string().default(""),
  inCapPlan: z.boolean().nullable().default(null),
  isActive: z.boolean().default(true),
  sourceRowNumber: z.number().int().nullable().default(null),
});

export const initiativeCreateSchema = initiativeBaseSchema;

export const initiativeUpdateSchema = initiativeBaseSchema.partial();

export const initiativePersonSchema = z.object({
  id: z.string().optional(),
  role: personRoleEnum,
  displayName: z.string().default(""),
  email: z.string().email().nullable().optional(),
  t3osContactId: z.string().nullable().optional(),
  t3osWorkspaceMemberId: z.string().nullable().optional(),
  t3osUserId: z.string().nullable().optional(),
  sourceType: z.string().default("local"),
  directorySource: z.enum(["t3os", "legacy_local"]).optional(),
  directoryResolved: z.boolean().optional(),
  sortOrder: z.number().int().default(0),
});

export const peopleReplaceSchema = z.object({
  people: z.array(initiativePersonSchema),
});

export const initiativeLinkSchema = z.object({
  id: z.string().optional(),
  linkType: linkTypeEnum,
  label: z.string().default(""),
  url: z.string().url().or(z.literal("")),
  sortOrder: z.number().int().default(0),
});

export const linksReplaceSchema = z.object({
  links: z.array(initiativeLinkSchema),
});

export const periodSnapshotSchema = z.object({
  id: z.string().optional(),
  periodKey: z.string().min(1),
  category: snapshotCategoryEnum,
  status: z.string().default(""),
  baselineValue: z.string().default(""),
  bookedValue: z.string().default(""),
});

export const periodSnapshotsReplaceSchema = z.object({
  snapshots: z.array(periodSnapshotSchema),
});

export const knowledgeDocumentUpsertSchema = z.object({
  title: z.string().min(1),
  slug: z.string().min(1),
  content: z.string().default(""),
  documentType: knowledgeDocumentTypeEnum,
  initiativeId: z.string().nullable().optional(),
});

export const serviceTokenCreateSchema = z.object({
  label: z.string().min(1),
  scopes: z.array(tokenScopeEnum).min(1),
});

export const apiTokenCreateSchema = z.object({
  label: z.string().min(1),
  scopes: z.array(tokenScopeEnum).min(1),
  ownerUserId: z.string().optional(),
  ownerEmail: z.string().email().optional(),
  ownerDisplayName: z.string().optional(),
  ownerWorkspaceId: z.string().optional(),
});

export const serviceTokenSchema = z.object({
  id: z.string(),
  label: z.string(),
  scopes: z.array(tokenScopeEnum),
  tokenPreview: z.string(),
  createdAt: z.string(),
});

export const apiTokenSchema = z.object({
  id: z.string(),
  label: z.string(),
  scopes: z.array(tokenScopeEnum),
  tokenPreview: z.string(),
  createdAt: z.string(),
  lastUsedAt: z.string().nullable(),
  ownerUserId: z.string().nullable().optional(),
  ownerEmail: z.string().nullable().optional(),
  ownerDisplayName: z.string().nullable().optional(),
  ownerWorkspaceId: z.string().nullable().optional(),
});

export const initiativeSummarySchema = z.object({
  id: z.string(),
  code: z.string(),
  title: z.string(),
  objective: z.string(),
  group: z.string(),
  targetCadence: z.string(),
  updateType: z.string(),
  stage: z.string(),
  lClass: z.string(),
  progress: z.string(),
  leadPerformance: z.string(),
  administrationHealth: z.string(),
  impactType: z.string(),
  inCapPlan: z.boolean().nullable(),
  isActive: z.boolean(),
  priorityRank: z.number().int().nullable(),
  priorityScore: z.number().nullable(),
  priorityReason: z.string().nullable(),
  prioritySource: prioritySourceEnum.nullable(),
  rankingUpdatedAt: z.string().nullable(),
  latestOpinionStatus: statusRecommendationEnum.nullable(),
  latestOpinionConfidence: z.number().nullable(),
  latestObservationAt: z.string().nullable(),
  peopleCount: z.number().int(),
  hasExecOwner: z.boolean(),
  hasGroupOwner: z.boolean(),
  hasInitiativeOwner: z.boolean(),
  updatedAt: z.string(),
});

export const initiativeDetailSchema = initiativeSummarySchema.extend({
  sourceRowNumber: z.number().int().nullable(),
  people: z.array(initiativePersonSchema.extend({ id: z.string() })),
  links: z.array(initiativeLinkSchema.extend({ id: z.string() })),
  snapshots: z.array(periodSnapshotSchema.extend({ id: z.string() })),
  knowledgeDocument: z
    .object({
      id: z.string(),
      title: z.string(),
      slug: z.string(),
      content: z.string(),
      version: z.number().int(),
      updatedAt: z.string(),
    })
    .nullable(),
  annotations: z.array(
    z.object({
      id: z.string(),
      annotationType: initiativeAnnotationTypeEnum,
      title: z.string(),
      content: z.string(),
      metadata: z.record(z.string(), z.unknown()),
      createdByType: z.string(),
      createdById: z.string(),
      createdAt: z.string(),
      updatedAt: z.string(),
    }),
  ),
  runConfig: z
    .object({
      id: z.string(),
      cadenceMode: runCadenceModeEnum,
      cadenceDetail: z.string(),
      alertThresholds: z.object({
        maxTrackerStalenessDays: z.number().int().nullable(),
        attentionBlockerCount: z.number().int().nullable(),
        minimumSlackMessages30d: z.number().int().nullable(),
        minimumDriveUpdates30d: z.number().int().nullable(),
        minimumOnTrackScore: z.number().min(0).max(1).nullable(),
      }),
      customKpiRulesMarkdown: z.string(),
      customInstructionsMarkdown: z.string(),
      goodLooksLikeMarkdown: z.string(),
      ownerNotesMarkdown: z.string(),
      updatedByType: z.string(),
      updatedById: z.string(),
      updatedAt: z.string(),
    })
    .nullable(),
  observations: z.array(
    z.object({
      id: z.string(),
      agentRunId: z.string().nullable(),
      statusRecommendation: statusRecommendationEnum,
      progressAssessment: z.string(),
      confidenceScore: z.number(),
      topBlockers: z.array(z.string()),
      suggestedNextActions: z.array(z.string()),
      evidenceSummary: z.string(),
      evidenceReferences: z.array(
        z.object({
          id: z.string(),
          sourceType: z.string(),
          sourceId: z.string(),
          title: z.string(),
          url: z.string().nullable(),
          excerpt: z.string(),
          metadata: z.record(z.string(), z.unknown()),
        }),
      ),
      review: z
        .object({
          id: z.string(),
          observationId: z.string(),
          verdict: observationReviewVerdictEnum,
          note: z.string(),
          reviewerType: z.string(),
          reviewerId: z.string(),
          updatedAt: z.string(),
        })
        .nullable()
        .optional(),
      createdAt: z.string(),
    }),
  ),
});

export const importSummarySchema = z.object({
  batchId: z.string(),
  importedCount: z.number().int(),
  skippedCount: z.number().int(),
  warnings: z.array(z.string()),
});

export const slackInstallStatusSchema = z.object({
  connected: z.boolean(),
  configured: z.boolean(),
  clientIdConfigured: z.boolean(),
  clientSecretConfigured: z.boolean(),
  redirectUri: z.string(),
  redirectUriSecure: z.boolean(),
  installUrl: z.string().nullable(),
  requiredUserScopes: z.array(z.string()),
  missingRequirements: z.array(z.string()),
  teamName: z.string().nullable(),
  slackUserId: z.string().nullable(),
  connectedAt: z.string().nullable(),
});

export const googleInstallStatusSchema = z.object({
  connected: z.boolean(),
  configured: z.boolean(),
  clientIdConfigured: z.boolean(),
  clientSecretConfigured: z.boolean(),
  redirectUri: z.string(),
  installUrl: z.string().nullable(),
  requiredScopes: z.array(z.string()),
  missingRequirements: z.array(z.string()),
  email: z.string().nullable(),
  connectedAt: z.string().nullable(),
});

export const slackEvidenceMessageSchema = z.object({
  ts: z.string(),
  userId: z.string().nullable(),
  text: z.string(),
  permalink: z.string().nullable(),
  attachments: z.array(
    z.object({
      id: z.string(),
      title: z.string().nullable(),
      name: z.string().nullable(),
      mimeType: z.string().nullable(),
      fileType: z.string().nullable(),
      prettyType: z.string().nullable(),
      sizeBytes: z.number().int().nullable(),
      permalink: z.string().nullable(),
      privateUrl: z.string().nullable(),
      privateDownloadUrl: z.string().nullable(),
      textExcerpt: z.string().nullable(),
    }),
  ),
  replyCount: z.number().int(),
  replies: z.array(
    z.object({
      ts: z.string(),
      userId: z.string().nullable(),
      text: z.string(),
      attachments: z.array(
        z.object({
          id: z.string(),
          title: z.string().nullable(),
          name: z.string().nullable(),
          mimeType: z.string().nullable(),
          fileType: z.string().nullable(),
          prettyType: z.string().nullable(),
          sizeBytes: z.number().int().nullable(),
          permalink: z.string().nullable(),
          privateUrl: z.string().nullable(),
          privateDownloadUrl: z.string().nullable(),
          textExcerpt: z.string().nullable(),
        }),
      ),
    }),
  ),
});

export const integrationSyncIssueSchema = z.object({
  id: z.string(),
  sourceType: z.string(),
  runId: z.string().nullable(),
  sourceId: z.string().nullable(),
  severity: z.string(),
  errorCode: z.string(),
  message: z.string(),
  metadata: z.record(z.string(), z.unknown()),
  createdAt: z.string(),
});

export const documentContentExtractSchema = z.object({
  id: z.string(),
  sourceType: z.string(),
  sourceKey: z.string(),
  sourceId: z.string(),
  parentSourceId: z.string().nullable(),
  title: z.string(),
  mimeType: z.string().nullable(),
  extractor: z.string(),
  extractionStatus: z.string(),
  summary: z.string(),
  extractedText: z.string(),
  sourceUpdatedAt: z.string().nullable(),
  metadata: z.record(z.string(), z.unknown()),
  updatedAt: z.string(),
});

export const slackEvidenceChannelSchema = z.object({
  channelId: z.string(),
  channelName: z.string().nullable(),
  label: z.string(),
  url: z.string(),
  readable: z.boolean(),
  error: z.string().nullable(),
  messages: z.array(slackEvidenceMessageSchema),
});

export const initiativeSlackEvidenceSchema = z.object({
  connected: z.boolean(),
  initiativeId: z.string(),
  channels: z.array(slackEvidenceChannelSchema),
  issues: z.array(integrationSyncIssueSchema),
  fetchedAt: z.string(),
});

export const googleEvidenceRevisionSchema = z.object({
  id: z.string(),
  modifiedTime: z.string().nullable(),
  lastModifyingUser: z.string().nullable(),
});

export const googleEvidenceFileSchema = z.object({
  linkId: z.string(),
  label: z.string(),
  url: z.string(),
  fileId: z.string().nullable(),
  name: z.string().nullable(),
  mimeType: z.string().nullable(),
  readable: z.boolean(),
  error: z.string().nullable(),
  modifiedTime: z.string().nullable(),
  lastModifyingUser: z.string().nullable(),
  webViewLink: z.string().nullable(),
  depth: z.number().int().default(0),
  crawlPath: z.string().default(""),
  revisions: z.array(googleEvidenceRevisionSchema),
  children: z.array(
    z.object({
      id: z.string(),
      parentFileId: z.string().nullable(),
      depth: z.number().int(),
      crawlPath: z.string(),
      name: z.string(),
      mimeType: z.string().nullable(),
      modifiedTime: z.string().nullable(),
      lastModifyingUser: z.string().nullable(),
      webViewLink: z.string().nullable(),
      revisions: z.array(googleEvidenceRevisionSchema),
    }),
  ),
});

export const initiativeGoogleEvidenceSchema = z.object({
  connected: z.boolean(),
  initiativeId: z.string(),
  files: z.array(googleEvidenceFileSchema),
  issues: z.array(integrationSyncIssueSchema),
  fetchedAt: z.string(),
});

export const trackerSummaryFieldSchema = z.object({
  id: z.string(),
  fieldKey: z.string(),
  label: z.string(),
  value: z.string(),
});

export const trackerRowItemSchema = z.object({
  id: z.string(),
  rowNumber: z.number().int(),
  itemType: z.string().nullable(),
  description: z.string(),
  prioritization: z.string().nullable(),
  phase: z.string().nullable(),
  impactPotential: z.string().nullable(),
  impactValue: z.string().nullable(),
  confidence: z.string().nullable(),
  currentValueEstimate: z.string().nullable(),
  status: z.string().nullable(),
  notes: z.string().nullable(),
  lastEdited: z.string().nullable(),
  submittedBy: z.string().nullable(),
});

export const initiativeTrackerSchema = z.object({
  connected: z.boolean(),
  initiativeId: z.string(),
  latestParseRunId: z.string().nullable(),
  trackerFileId: z.string().nullable(),
  trackerName: z.string().nullable(),
  sheetName: z.string().nullable(),
  summaryFields: z.array(trackerSummaryFieldSchema),
  items: z.array(trackerRowItemSchema),
  parsedAt: z.string().nullable(),
  summary: z.record(z.string(), z.unknown()),
});

export const kpiFindingSchema = z.object({
  id: z.string(),
  findingClass: z.string(),
  sourceType: z.string(),
  metricKey: z.string(),
  label: z.string(),
  metricValue: z.string().nullable(),
  unit: z.string().nullable(),
  narrative: z.string().nullable(),
  sourceRef: z.string().nullable(),
  provenance: z.record(z.string(), z.unknown()),
});

export const initiativeKpiResearchSchema = z.object({
  initiativeId: z.string(),
  latestResearchRunId: z.string().nullable(),
  findings: z.array(kpiFindingSchema),
  summary: z.record(z.string(), z.unknown()),
  researchedAt: z.string().nullable(),
});

export const initiativeAnnotationCreateSchema = z.object({
  annotationType: initiativeAnnotationTypeEnum,
  title: z.string().min(1),
  content: z.string().min(1),
  metadata: z.record(z.string(), z.unknown()).default({}),
});

export const initiativeRunConfigUpsertSchema = z.object({
  cadenceMode: runCadenceModeEnum.default("manual"),
  cadenceDetail: z.string().default(""),
  alertThresholds: z
    .object({
      maxTrackerStalenessDays: z.number().int().nullable().default(null),
      attentionBlockerCount: z.number().int().nullable().default(null),
      minimumSlackMessages30d: z.number().int().nullable().default(null),
      minimumDriveUpdates30d: z.number().int().nullable().default(null),
      minimumOnTrackScore: z.number().min(0).max(1).nullable().default(null),
    })
    .default({
      maxTrackerStalenessDays: null,
      attentionBlockerCount: null,
      minimumSlackMessages30d: null,
      minimumDriveUpdates30d: null,
      minimumOnTrackScore: null,
    }),
  customKpiRulesMarkdown: z.string().default(""),
  customInstructionsMarkdown: z.string().default(""),
  goodLooksLikeMarkdown: z.string().default(""),
  ownerNotesMarkdown: z.string().default(""),
});

export const storedSlackMessageSchema = z.object({
  id: z.string(),
  channelId: z.string(),
  channelName: z.string().nullable(),
  ts: z.string(),
  text: z.string(),
  userId: z.string().nullable(),
  permalink: z.string().nullable(),
  attachments: z.array(
    z.object({
      id: z.string(),
      title: z.string().nullable(),
      name: z.string().nullable(),
      mimeType: z.string().nullable(),
      fileType: z.string().nullable(),
      prettyType: z.string().nullable(),
      sizeBytes: z.number().int().nullable(),
      permalink: z.string().nullable(),
      privateUrl: z.string().nullable(),
      privateDownloadUrl: z.string().nullable(),
      textExcerpt: z.string().nullable(),
    }),
  ),
  replyCount: z.number().int(),
  messageAt: z.string().nullable(),
  replies: z.array(
    z.object({
      id: z.string(),
      ts: z.string(),
      text: z.string(),
      userId: z.string().nullable(),
      messageAt: z.string().nullable(),
      attachments: z.array(
        z.object({
          id: z.string(),
          title: z.string().nullable(),
          name: z.string().nullable(),
          mimeType: z.string().nullable(),
          fileType: z.string().nullable(),
          prettyType: z.string().nullable(),
          sizeBytes: z.number().int().nullable(),
          permalink: z.string().nullable(),
          privateUrl: z.string().nullable(),
          privateDownloadUrl: z.string().nullable(),
          textExcerpt: z.string().nullable(),
        }),
      ),
    }),
  ),
});

export const storedGoogleFileSchema = z.object({
  id: z.string(),
  fileId: z.string(),
  parentFileId: z.string().nullable(),
  depth: z.number().int(),
  crawlPath: z.string(),
  name: z.string(),
  mimeType: z.string().nullable(),
  modifiedTime: z.string().nullable(),
  lastModifyingUser: z.string().nullable(),
  webViewLink: z.string().nullable(),
});

export const initiativeRawEvidenceSchema = z.object({
  initiativeId: z.string(),
  slackMessages: z.array(storedSlackMessageSchema),
  googleFiles: z.array(storedGoogleFileSchema),
  syncIssues: z.array(integrationSyncIssueSchema),
  documentExtracts: z.array(documentContentExtractSchema),
  trackerSheetRows: z.array(z.array(z.string())),
  latestTrackerParseRunId: z.string().nullable(),
  latestObservationId: z.string().nullable(),
  latestResearchRunId: z.string().nullable(),
});

export const initiativeAskRequestSchema = z.object({
  question: z.string().min(3),
  includeRawEvidence: z.boolean().default(false),
});

export const executivePortfolioQueryRequestSchema = z.object({
  question: z.string().min(3),
  limit: z.number().int().min(1).max(25).default(5),
});

export const executivePortfolioQueryResponseSchema = z.object({
  question: z.string(),
  interpretedIntent: z.enum([
    "best_progress",
    "needs_attention",
    "stale",
    "priority_stack",
    "portfolio_summary",
  ]),
  generatedAt: z.string(),
  summary: z.string(),
  items: z.array(
    z.object({
      initiativeId: z.string(),
      code: z.string(),
      title: z.string(),
      status: statusRecommendationEnum.nullable(),
      confidence: z.number().nullable(),
      priorityRank: z.number().int().nullable(),
      ownershipStatus: z.enum(["complete", "partial", "missing"]),
      lastReviewedAt: z.string().nullable(),
      read: z.string(),
    }),
  ),
});

export const initiativeAgentQueryModeEnum = z.enum(["raw", "insights", "assess", "full"]);

export const initiativeAgentQueryRefreshPolicyEnum = z.enum(["if_stale", "always", "never"]);

export const initiativeAgentQueryRequestSchema = z.object({
  mode: initiativeAgentQueryModeEnum.default("insights"),
  refreshPolicy: initiativeAgentQueryRefreshPolicyEnum.default("if_stale"),
  staleAfterMinutes: z.number().int().min(1).max(24 * 60).default(60),
  refreshKpis: z.boolean().optional(),
});

export const initiativeAskResponseSchema = z.object({
  initiativeId: z.string(),
  question: z.string(),
  answer: z.string(),
  confidence: z.number(),
  evidence: z.array(
    z.object({
      sourceType: z.string(),
      title: z.string(),
      excerpt: z.string(),
      url: z.string().nullable().optional(),
      metadata: z.record(z.string(), z.unknown()).optional(),
    }),
  ),
  followUps: z.array(z.string()),
  generatedAt: z.string(),
});

export const currentUserSchema = z.object({
  id: z.string(),
  type: z.enum(["human", "service_token"]),
  email: z.string().nullable(),
  displayName: z.string().nullable(),
  appRole: appUserRoleEnum.nullable(),
  workspaceId: z.string().nullable().default(null),
  t3osUserId: z.string().nullable().default(null),
  authSource: z.enum(["local_headers", "t3os_jwt", "api_token", "service_token"]).default("local_headers"),
  scopes: z.array(z.string()),
});

export const platformContactTypeEnum = z.enum(["PERSON", "BUSINESS"]);

export const contactSummarySchema = z.object({
  id: z.string(),
  contactType: platformContactTypeEnum,
  workspaceId: z.string(),
  name: z.string(),
  email: z.string().nullable(),
  phone: z.string().nullable(),
  role: z.string().nullable(),
  businessId: z.string().nullable(),
  businessName: z.string().nullable(),
  address: z.string().nullable(),
  updatedAt: z.string().nullable(),
  createdAt: z.string().nullable(),
});

export const workspaceMemberSummarySchema = z.object({
  userId: z.string(),
  roles: z.array(z.string()),
  user: z
    .object({
      id: z.string(),
      name: z.string().nullable(),
      email: z.string().nullable(),
    })
    .nullable(),
});

export const listPlatformContactsResponseSchema = z.object({
  workspaceId: z.string(),
  items: z.array(contactSummarySchema),
});

export const listWorkspaceMembersResponseSchema = z.object({
  workspaceId: z.string(),
  items: z.array(workspaceMemberSummarySchema),
});

export const legacyContactMigrationReasonEnum = z.enum([
  "matched_employee",
  "already_in_t3os",
  "ambiguous_match",
  "missing_email",
  "no_hr_match",
  "business_unresolved",
]);

export const legacyContactMigrationRunStatusEnum = z.enum([
  "running",
  "completed",
  "failed",
]);

export const legacyContactMigrationModeEnum = z.enum(["preview", "execute"]);

export const legacyContactMigrationInputSchema = z.object({
  workspaceId: z.string(),
  businessContactId: z.string().optional(),
  initiativeIds: z.array(z.string()).optional(),
});

export const legacyContactMigrationHrMatchSchema = z.object({
  email: z.string().email(),
  employeeId: z.string().nullable(),
  fullName: z.string(),
  employeeTitle: z.string().nullable(),
  employeeStatus: z.string().nullable(),
  directManagerName: z.string().nullable(),
  marketId: z.number().int().nullable(),
  workPhone: z.string().nullable(),
  source: z.enum(["EE_COMPANY_DIRECTORY_12_MONTH", "COMPANY_DIRECTORY"]),
  updatedAt: z.string().nullable(),
});

export const legacyContactMigrationWorkspaceMemberMatchSchema = z.object({
  userId: z.string(),
  email: z.string().email(),
  roles: z.array(z.string()),
});

export const legacyContactMigrationContactCandidateSchema = z.object({
  normalizedEmail: z.string().email(),
  legacyNames: z.array(z.string()),
  assignmentCount: z.number().int(),
  initiativeCount: z.number().int(),
  status: legacyContactMigrationReasonEnum,
  existingContactId: z.string().nullable(),
  existingContactName: z.string().nullable(),
  hrMatch: legacyContactMigrationHrMatchSchema.nullable(),
  workspaceMemberMatch: legacyContactMigrationWorkspaceMemberMatchSchema.nullable(),
});

export const legacyContactMigrationReviewItemSchema = z.object({
  initiativeId: z.string(),
  initiativeCode: z.string(),
  initiativeTitle: z.string(),
  initiativePersonId: z.string(),
  legacyDisplayName: z.string(),
  legacyEmail: z.string().email().nullable(),
  role: personRoleEnum,
  reason: legacyContactMigrationReasonEnum,
  suggestedContacts: z.array(
    z.object({
      contactId: z.string(),
      name: z.string(),
      email: z.string().email().nullable(),
    }),
  ),
});

export const legacyContactMigrationSummarySchema = z.object({
  totalLegacyRows: z.number().int(),
  distinctEmails: z.number().int(),
  matchedEmployees: z.number().int(),
  alreadyInT3os: z.number().int(),
  toCreate: z.number().int(),
  remappableAssignments: z.number().int(),
  missingEmail: z.number().int(),
  ambiguous: z.number().int(),
  noHrMatch: z.number().int(),
  createdContacts: z.number().int().optional(),
  reusedContacts: z.number().int().optional(),
  remappedAssignments: z.number().int().optional(),
});

export const legacyContactMigrationBusinessResolutionSchema = z.object({
  status: z.enum(["resolved", "missing", "ambiguous"]),
  businessContactId: z.string().nullable(),
  businessName: z.string().nullable(),
  matches: z.array(
    z.object({
      id: z.string(),
      name: z.string(),
    }),
  ),
});

export const legacyContactMigrationResponseSchema = z.object({
  runId: z.string(),
  mode: legacyContactMigrationModeEnum,
  status: legacyContactMigrationRunStatusEnum,
  workspaceId: z.string(),
  businessResolution: legacyContactMigrationBusinessResolutionSchema,
  summary: legacyContactMigrationSummarySchema,
  contactCandidates: z.array(legacyContactMigrationContactCandidateSchema),
  reviewQueue: z.array(legacyContactMigrationReviewItemSchema),
  createdAt: z.string(),
  finishedAt: z.string().nullable(),
});

export const createOrUpdateContactInputSchema = z.discriminatedUnion("contactType", [
  z.object({
    contactType: z.literal("PERSON"),
    workspaceId: z.string(),
    name: z.string().min(1),
    email: z.string().email(),
    phone: z.string().optional().nullable(),
    role: z.string().optional().nullable(),
    businessId: z.string().min(1),
    resourceMapIds: z.array(z.string()).optional(),
  }),
  z.object({
    contactType: z.literal("BUSINESS"),
    workspaceId: z.string(),
    name: z.string().min(1),
    phone: z.string().optional().nullable(),
    address: z.string().optional().nullable(),
    taxId: z.string().min(1),
    website: z.string().optional().nullable(),
    brandId: z.string().optional().nullable(),
    latitude: z.number().optional().nullable(),
    longitude: z.number().optional().nullable(),
    placeId: z.string().optional().nullable(),
  }),
]);

export const updateContactInputSchema = z.discriminatedUnion("contactType", [
  z.object({
    contactType: z.literal("PERSON"),
    name: z.string().optional(),
    email: z.string().email().optional(),
    phone: z.string().optional().nullable(),
    role: z.string().optional().nullable(),
    businessId: z.string().optional(),
    resourceMapIds: z.array(z.string()).optional(),
  }),
  z.object({
    contactType: z.literal("BUSINESS"),
    name: z.string().optional(),
    phone: z.string().optional().nullable(),
    address: z.string().optional().nullable(),
    taxId: z.string().optional(),
    website: z.string().optional().nullable(),
    brandId: z.string().optional().nullable(),
    latitude: z.number().optional().nullable(),
    longitude: z.number().optional().nullable(),
    placeId: z.string().optional().nullable(),
  }),
]);

export const inviteWorkspaceMemberInputSchema = z.object({
  workspaceId: z.string(),
  email: z.string().email(),
  roles: z.array(z.string()).min(1),
});

export const updateWorkspaceMemberRolesInputSchema = z.object({
  workspaceId: z.string(),
  roles: z.array(z.string()).min(1),
});

export const assignSiParticipantInputSchema = z.object({
  role: personRoleEnum,
  displayName: z.string().min(1),
  email: z.string().email().nullable().optional(),
  t3osContactId: z.string().nullable().optional(),
  t3osWorkspaceMemberId: z.string().nullable().optional(),
  t3osUserId: z.string().nullable().optional(),
  sourceType: z.string().default("t3os"),
  sortOrder: z.number().int().default(0),
});

export const pilotCandidateSchema = z.object({
  initiativeId: z.string(),
  code: z.string(),
  title: z.string(),
  group: z.string(),
  trackerDetected: z.boolean(),
  trackerName: z.string().nullable(),
});

export const pilotRunSchema = z.object({
  batchId: z.string(),
  status: z.string(),
  cohort: z.array(pilotCandidateSchema),
  summary: z.record(z.string(), z.unknown()),
  createdAt: z.string(),
  finishedAt: z.string().nullable(),
});

export const initiativeRankingUpdateSchema = z.object({
  orderedIds: z.array(z.string()).min(1),
});

export const portfolioRefreshRunSchema = z.object({
  runId: z.string(),
  status: z.string(),
  summary: z.record(z.string(), z.unknown()),
  createdAt: z.string(),
  finishedAt: z.string().nullable(),
});

export const observationReviewSchema = z.object({
  id: z.string(),
  observationId: z.string(),
  verdict: observationReviewVerdictEnum,
  note: z.string(),
  reviewerType: z.string(),
  reviewerId: z.string(),
  updatedAt: z.string(),
});

export const observationReviewUpsertSchema = z.object({
  verdict: observationReviewVerdictEnum,
  note: z.string().default(""),
});

export const agentObservationSchema = z.object({
  id: z.string(),
  initiativeId: z.string(),
  statusRecommendation: statusRecommendationEnum,
  progressAssessment: z.string(),
  confidenceScore: z.number(),
  topBlockers: z.array(z.string()),
  suggestedNextActions: z.array(z.string()),
  evidenceSummary: z.string(),
  evidenceReferences: z.array(
    z.object({
      id: z.string(),
      sourceType: z.string(),
      sourceId: z.string(),
      title: z.string(),
      url: z.string().nullable(),
      excerpt: z.string(),
      metadata: z.record(z.string(), z.unknown()),
    }),
  ),
  createdAt: z.string(),
});

export type PersonRole = z.infer<typeof personRoleEnum>;
export type LinkType = z.infer<typeof linkTypeEnum>;
export type SnapshotCategory = z.infer<typeof snapshotCategoryEnum>;
export type TokenScope = z.infer<typeof tokenScopeEnum>;
export type StatusRecommendation = z.infer<typeof statusRecommendationEnum>;
export type PrioritySource = z.infer<typeof prioritySourceEnum>;
export type ObservationReviewVerdict = z.infer<typeof observationReviewVerdictEnum>;
export type InitiativeCreateInput = z.infer<typeof initiativeCreateSchema>;
export type InitiativeUpdateInput = z.infer<typeof initiativeUpdateSchema>;
export type InitiativePersonInput = z.infer<typeof initiativePersonSchema>;
export type InitiativeLinkInput = z.infer<typeof initiativeLinkSchema>;
export type PeriodSnapshotInput = z.infer<typeof periodSnapshotSchema>;
export type KnowledgeDocumentUpsertInput = z.infer<typeof knowledgeDocumentUpsertSchema>;
export type InitiativeAnnotationCreateInput = z.infer<typeof initiativeAnnotationCreateSchema>;
export type InitiativeRunConfigUpsertInput = z.infer<typeof initiativeRunConfigUpsertSchema>;
export type ServiceTokenCreateInput = z.infer<typeof serviceTokenCreateSchema>;
export type ApiTokenCreateInput = z.infer<typeof apiTokenCreateSchema>;
export type InitiativeSummary = z.infer<typeof initiativeSummarySchema>;
export type InitiativeDetail = z.infer<typeof initiativeDetailSchema>;
export type ImportSummary = z.infer<typeof importSummarySchema>;
export type SlackInstallStatus = z.infer<typeof slackInstallStatusSchema>;
export type GoogleInstallStatus = z.infer<typeof googleInstallStatusSchema>;
export type InitiativeSlackEvidence = z.infer<typeof initiativeSlackEvidenceSchema>;
export type InitiativeGoogleEvidence = z.infer<typeof initiativeGoogleEvidenceSchema>;
export type InitiativeTracker = z.infer<typeof initiativeTrackerSchema>;
export type KpiFinding = z.infer<typeof kpiFindingSchema>;
export type InitiativeKpiResearch = z.infer<typeof initiativeKpiResearchSchema>;
export type InitiativeRawEvidence = z.infer<typeof initiativeRawEvidenceSchema>;
export type InitiativeAskRequest = z.infer<typeof initiativeAskRequestSchema>;
export type InitiativeAskResponse = z.infer<typeof initiativeAskResponseSchema>;
export type ExecutivePortfolioQueryRequest = z.infer<typeof executivePortfolioQueryRequestSchema>;
export type ExecutivePortfolioQueryResponse = z.infer<typeof executivePortfolioQueryResponseSchema>;
export type CurrentUser = z.infer<typeof currentUserSchema>;
export type ContactSummary = z.infer<typeof contactSummarySchema>;
export type WorkspaceMemberSummary = z.infer<typeof workspaceMemberSummarySchema>;
export type LegacyContactMigrationInput = z.infer<typeof legacyContactMigrationInputSchema>;
export type LegacyContactMigrationHrMatch = z.infer<typeof legacyContactMigrationHrMatchSchema>;
export type LegacyContactMigrationWorkspaceMemberMatch = z.infer<
  typeof legacyContactMigrationWorkspaceMemberMatchSchema
>;
export type LegacyContactMigrationContactCandidate = z.infer<
  typeof legacyContactMigrationContactCandidateSchema
>;
export type LegacyContactMigrationReviewItem = z.infer<typeof legacyContactMigrationReviewItemSchema>;
export type LegacyContactMigrationSummary = z.infer<typeof legacyContactMigrationSummarySchema>;
export type LegacyContactMigrationBusinessResolution = z.infer<
  typeof legacyContactMigrationBusinessResolutionSchema
>;
export type LegacyContactMigrationResponse = z.infer<typeof legacyContactMigrationResponseSchema>;
export type CreateOrUpdateContactInput = z.infer<typeof createOrUpdateContactInputSchema>;
export type UpdateContactInput = z.infer<typeof updateContactInputSchema>;
export type InviteWorkspaceMemberInput = z.infer<typeof inviteWorkspaceMemberInputSchema>;
export type UpdateWorkspaceMemberRolesInput = z.infer<typeof updateWorkspaceMemberRolesInputSchema>;
export type AssignSiParticipantInput = z.infer<typeof assignSiParticipantInputSchema>;
export type PilotCandidate = z.infer<typeof pilotCandidateSchema>;
export type PilotRun = z.infer<typeof pilotRunSchema>;
export type PortfolioRefreshRun = z.infer<typeof portfolioRefreshRunSchema>;
export type AgentObservation = z.infer<typeof agentObservationSchema>;
export type ObservationReview = z.infer<typeof observationReviewSchema>;
export type ObservationReviewUpsertInput = z.infer<typeof observationReviewUpsertSchema>;
export type ServiceToken = z.infer<typeof serviceTokenSchema>;
export type ApiToken = z.infer<typeof apiTokenSchema>;

export const personRoleLabels: Record<PersonRole, string> = {
  exec_owner: "Exec Owner",
  group_owner: "Group Owner",
  initiative_owner: "Initiative Owner",
  si_analytics_owner: "SI Analytics Owner",
  sales_lead: "Sales Lead",
  ops_lead: "Ops Lead",
  analytics_lead: "Analytics Lead",
  pm: "PM",
  other_invitee: "Other Invitee",
};

export const linkTypeLabels: Record<LinkType, string> = {
  folder: "Folder",
  channel: "Slack Channel",
  playbook: "Playbook",
  dashboard: "Dashboard",
  other: "Other",
};
