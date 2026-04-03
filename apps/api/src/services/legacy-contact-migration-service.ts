import type {
  ContactSummary,
  LegacyContactMigrationBusinessResolution,
  LegacyContactMigrationContactCandidate,
  LegacyContactMigrationHrMatch,
  LegacyContactMigrationInput,
  LegacyContactMigrationResponse,
  LegacyContactMigrationReviewItem,
  LegacyContactMigrationSummary,
  WorkspaceMemberSummary,
} from "@si/domain";
import { and, desc, eq, inArray } from "drizzle-orm";
import { env } from "../config/env.js";
import { db } from "../db/client.js";
import { initiativePeople, initiatives, legacyContactMigrationRuns } from "../db/schema.js";
import { createId } from "../lib/id.js";
import { recordAuditEvent, type AuditActor } from "../lib/audit.js";
import { executeSqlThroughFrostyWithWarehouse, type FrostySqlResult } from "./frosty-client.js";
import {
  createPlatformContact,
  listPlatformContacts,
  listPlatformWorkspaceMembers,
} from "./t3os-platform-service.js";

type LegacyAssignmentRow = {
  personId: string;
  initiativeId: string;
  initiativeCode: string;
  initiativeTitle: string;
  role: LegacyContactMigrationReviewItem["role"];
  displayName: string;
  email: string | null;
};

type CandidateBundle = LegacyContactMigrationContactCandidate & {
  assignmentIds: string[];
};

type NameLookup = {
  firstName: string;
  lastName: string;
};

type BuildMigrationDatasetResult = {
  businessResolution: LegacyContactMigrationBusinessResolution;
  summary: LegacyContactMigrationSummary;
  contactCandidates: CandidateBundle[];
  reviewQueue: LegacyContactMigrationReviewItem[];
};

type HrCandidateRow = LegacyContactMigrationHrMatch & {
  location?: string | null;
  defaultCostCentersFullPath?: string | null;
  nickname?: string | null;
  matchFirstName?: string | null;
  matchLastName?: string | null;
};

const ACTIVE_EMPLOYEE_STATUSES = new Set([
  "active",
  "external payroll",
  "leave with pay",
  "leave withoutout pay",
  "leave without pay",
  "work comp leave",
]);

function normalizeEmail(email: string | null | undefined): string | null {
  if (!email) {
    return null;
  }
  const normalized = email.trim().toLowerCase();
  return normalized.length > 0 ? normalized : null;
}

function normalizeName(name: string | null | undefined): string {
  return (name ?? "").trim().toLowerCase().replace(/\s+/g, " ");
}

function parseNameLookup(name: string | null | undefined): NameLookup | null {
  if (!name) {
    return null;
  }

  const normalized = name
    .replace(/\([^)]*\)/g, " ")
    .replace(/[^A-Za-z' -]+/g, " ")
    .trim()
    .replace(/\s+/g, " ");

  if (!normalized || normalized.includes("@")) {
    return null;
  }

  const tokens = normalized.split(" ").filter(Boolean);
  if (tokens.length < 2 || tokens.length > 4) {
    return null;
  }

  const bannedTokens = new Set(["from", "with", "add", "this", "that", "to", "and"]);
  if (tokens.some((token) => bannedTokens.has(token.toLowerCase()))) {
    return null;
  }

  return {
    firstName: tokens[0]!.toLowerCase(),
    lastName: tokens[tokens.length - 1]!.toLowerCase(),
  };
}

function escapeSqlLiteral(value: string): string {
  return value.replace(/'/g, "''");
}

function normalizeSqlRows(result: FrostySqlResult): Array<Record<string, unknown>> {
  if (!Array.isArray(result.data)) {
    return [];
  }

  return result.data.map((row) => {
    if (!Array.isArray(row)) {
      return row as Record<string, unknown>;
    }
    return Object.fromEntries((result.columns ?? []).map((column, index) => [column, row[index] ?? null]));
  });
}

function parseNullableString(value: unknown): string | null {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

function parseNullableInt(value: unknown): number | null {
  if (typeof value === "number" && Number.isFinite(value)) {
    return Math.trunc(value);
  }
  if (typeof value === "string" && value.trim()) {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
  }
  return null;
}

function getRowValue(row: Record<string, unknown>, key: string): unknown {
  return row[key] ?? row[key.toUpperCase()] ?? row[key.toLowerCase()];
}

function rowIsActive(candidate: HrCandidateRow): boolean {
  return ACTIVE_EMPLOYEE_STATUSES.has((candidate.employeeStatus ?? "").trim().toLowerCase());
}

function buildWorkspaceMemberMatch(member: WorkspaceMemberSummary | null): CandidateBundle["workspaceMemberMatch"] {
  if (!member?.user?.email) {
    return null;
  }

  return {
    userId: member.userId,
    email: member.user.email,
    roles: member.roles,
  };
}

async function listLegacyAssignments(initiativeIds?: string[]): Promise<LegacyAssignmentRow[]> {
  const conditions = [eq(initiativePeople.sourceType, "local")];
  if (initiativeIds && initiativeIds.length > 0) {
    conditions.push(inArray(initiativePeople.initiativeId, initiativeIds));
  }

  const rows = await db
    .select({
      personId: initiativePeople.id,
      initiativeId: initiativePeople.initiativeId,
      initiativeCode: initiatives.code,
      initiativeTitle: initiatives.title,
      role: initiativePeople.role,
      displayName: initiativePeople.displayName,
      email: initiativePeople.email,
    })
    .from(initiativePeople)
    .innerJoin(initiatives, eq(initiativePeople.initiativeId, initiatives.id))
    .where(and(...conditions));

  return rows as LegacyAssignmentRow[];
}

async function resolveBusinessContact(
  token: string,
  workspaceId: string,
  businessContactId?: string,
): Promise<LegacyContactMigrationBusinessResolution> {
  const businesses = await listPlatformContacts({
    token,
    workspaceId,
    contactType: "BUSINESS",
  });

  if (businessContactId) {
    const selected = businesses.find((contact) => contact.id === businessContactId) ?? null;
    return {
      status: selected ? "resolved" : "missing",
      businessContactId: selected?.id ?? null,
      businessName: selected?.name ?? null,
      matches: selected ? [{ id: selected.id, name: selected.name }] : [],
    };
  }

  const matches = businesses.filter((contact) => normalizeName(contact.name) === "equipmentshare");
  if (matches.length === 1) {
    return {
      status: "resolved",
      businessContactId: matches[0]!.id,
      businessName: matches[0]!.name,
      matches: matches.map((match) => ({ id: match.id, name: match.name })),
    };
  }

  return {
    status: matches.length === 0 ? "missing" : "ambiguous",
    businessContactId: null,
    businessName: null,
    matches: matches.map((match) => ({ id: match.id, name: match.name })),
  };
}

async function fetchHrMatchesByEmail(emails: string[]): Promise<Map<string, HrCandidateRow[]>> {
  if (emails.length === 0) {
    return new Map();
  }

  const valuesClause = emails.map((email) => `('${escapeSqlLiteral(email)}')`).join(",\n      ");
  const query = `
with target_emails(email) as (
  select column1
  from values
      ${valuesClause}
),
ee_candidates as (
  select
    lower(work_email) as normalized_email,
    to_varchar(employee_id) as employee_id,
    trim(concat(coalesce(first_name, ''), ' ', coalesce(last_name, ''))) as full_name,
    employee_title,
    employee_status,
    direct_manager_name,
    market_id,
    work_phone,
    _es_update_timestamp as updated_at,
    'EE_COMPANY_DIRECTORY_12_MONTH' as source
  from ANALYTICS.PAYROLL.EE_COMPANY_DIRECTORY_12_MONTH
  where work_email is not null
    and lower(work_email) in (select email from target_emails)
),
company_candidates as (
  select
    lower(work_email) as normalized_email,
    to_varchar(employee_id) as employee_id,
    trim(concat(coalesce(first_name, ''), ' ', coalesce(last_name, ''))) as full_name,
    employee_title,
    employee_status,
    direct_manager_name,
    market_id,
    work_phone,
    last_updated_date as updated_at,
    'COMPANY_DIRECTORY' as source
  from ANALYTICS.PAYROLL.COMPANY_DIRECTORY
  where work_email is not null
    and lower(work_email) in (select email from target_emails)
),
all_candidates as (
  select * from ee_candidates
  union all
  select * from company_candidates
)
select *
from all_candidates;
`;

  const result = await executeSqlThroughFrostyWithWarehouse(query, env.FROSTY_SQL_WAREHOUSE);
  if (result.success === false) {
    throw new Error(result.error ?? "HR contact enrichment query failed.");
  }
  const rows = normalizeSqlRows(result);
  const grouped = new Map<string, HrCandidateRow[]>();

  for (const row of rows) {
    const email = parseNullableString(getRowValue(row, "normalized_email"));
    if (!email) {
      continue;
    }
    const current = grouped.get(email) ?? [];
    current.push({
      email,
      employeeId: parseNullableString(getRowValue(row, "employee_id")),
      fullName: parseNullableString(getRowValue(row, "full_name")) ?? email,
      employeeTitle: parseNullableString(getRowValue(row, "employee_title")),
      employeeStatus: parseNullableString(getRowValue(row, "employee_status")),
      directManagerName: parseNullableString(getRowValue(row, "direct_manager_name")),
      marketId: parseNullableInt(getRowValue(row, "market_id")),
      workPhone: parseNullableString(getRowValue(row, "work_phone")),
      source:
        getRowValue(row, "source") === "COMPANY_DIRECTORY"
          ? "COMPANY_DIRECTORY"
          : "EE_COMPANY_DIRECTORY_12_MONTH",
      updatedAt: parseNullableString(getRowValue(row, "updated_at")),
    });
    grouped.set(email, current);
  }

  for (const [email, candidates] of grouped.entries()) {
    grouped.set(
      email,
      [...candidates].sort((left, right) => {
        const leftTime = left.updatedAt ? Date.parse(left.updatedAt) : 0;
        const rightTime = right.updatedAt ? Date.parse(right.updatedAt) : 0;
        return rightTime - leftTime;
      }),
    );
  }

  return grouped;
}

async function fetchCorporateHrMatchesByName(lookups: NameLookup[]): Promise<Map<string, HrCandidateRow[]>> {
  if (lookups.length === 0) {
    return new Map();
  }

  const valuesClause = lookups
    .map((lookup) => `('${escapeSqlLiteral(lookup.firstName)}', '${escapeSqlLiteral(lookup.lastName)}')`)
    .join(",\n      ");

  const query = `
with target_names(first_name, last_name) as (
  select column1, column2
  from values
      ${valuesClause}
),
corporate_candidates as (
  select
    lower(work_email) as normalized_email,
    to_varchar(employee_id) as employee_id,
    trim(concat(coalesce(first_name, ''), ' ', coalesce(last_name, ''))) as full_name,
    employee_title,
    employee_status,
    direct_manager_name,
    market_id,
    work_phone,
    location,
    default_cost_centers_full_path,
    nickname,
    _es_update_timestamp as updated_at,
    'EE_COMPANY_DIRECTORY_12_MONTH' as source,
    lower(first_name) as match_first_name,
    lower(last_name) as match_last_name,
    lower(split_part(coalesce(nullif(nickname, ''), first_name), ' ', 1)) as nickname_first_name
  from ANALYTICS.PAYROLL.EE_COMPANY_DIRECTORY_12_MONTH
  where work_email is not null
    and (
      default_cost_centers_full_path ilike 'Corp/%'
      or default_cost_centers_full_path ilike '%/Corporate/%'
      or location ilike '%Corporate%'
      or location in ('Executive', 'Data Org', 'Corporate Finance')
    )
),
matched_candidates as (
  select
    normalized_email,
    employee_id,
    full_name,
    employee_title,
    employee_status,
    direct_manager_name,
    market_id,
    work_phone,
    location,
    default_cost_centers_full_path,
    nickname,
    updated_at,
    source,
    target_names.first_name as match_first_name,
    target_names.last_name as match_last_name
  from corporate_candidates
  inner join target_names
    on corporate_candidates.match_last_name = target_names.last_name
   and (
     corporate_candidates.match_first_name = target_names.first_name
     or corporate_candidates.nickname_first_name = target_names.first_name
   )
)
select *
from matched_candidates;
`;

  const result = await executeSqlThroughFrostyWithWarehouse(query, env.FROSTY_SQL_WAREHOUSE);
  if (result.success === false) {
    throw new Error(result.error ?? "Corporate HR name lookup failed.");
  }

  const rows = normalizeSqlRows(result);
  const grouped = new Map<string, HrCandidateRow[]>();

  for (const row of rows) {
    const firstName = parseNullableString(getRowValue(row, "match_first_name"));
    const lastName = parseNullableString(getRowValue(row, "match_last_name"));
    const email = parseNullableString(getRowValue(row, "normalized_email"));
    if (!firstName || !lastName || !email) {
      continue;
    }

    const key = `${firstName}:${lastName}`;
    const current = grouped.get(key) ?? [];
    current.push({
      email,
      employeeId: parseNullableString(getRowValue(row, "employee_id")),
      fullName: parseNullableString(getRowValue(row, "full_name")) ?? email,
      employeeTitle: parseNullableString(getRowValue(row, "employee_title")),
      employeeStatus: parseNullableString(getRowValue(row, "employee_status")),
      directManagerName: parseNullableString(getRowValue(row, "direct_manager_name")),
      marketId: parseNullableInt(getRowValue(row, "market_id")),
      workPhone: parseNullableString(getRowValue(row, "work_phone")),
      source: "EE_COMPANY_DIRECTORY_12_MONTH",
      updatedAt: parseNullableString(getRowValue(row, "updated_at")),
      location: parseNullableString(getRowValue(row, "location")),
      defaultCostCentersFullPath: parseNullableString(getRowValue(row, "default_cost_centers_full_path")),
      nickname: parseNullableString(getRowValue(row, "nickname")),
      matchFirstName: firstName,
      matchLastName: lastName,
    });
    grouped.set(key, current);
  }

  for (const [key, candidates] of grouped.entries()) {
    grouped.set(
      key,
      [...candidates].sort((left, right) => {
        const leftTime = left.updatedAt ? Date.parse(left.updatedAt) : 0;
        const rightTime = right.updatedAt ? Date.parse(right.updatedAt) : 0;
        return rightTime - leftTime;
      }),
    );
  }

  return grouped;
}

function pickCorporateNameMatch(candidates: HrCandidateRow[]): {
  status: LegacyContactMigrationContactCandidate["status"];
  match: HrCandidateRow | null;
} {
  if (candidates.length === 0) {
    return {
      status: "no_hr_match",
      match: null,
    };
  }

  const activeCandidates = candidates.filter(rowIsActive);
  const pool = activeCandidates.length > 0 ? activeCandidates : candidates;
  const distinctEmployeeIds = new Set(
    pool
      .map((candidate) => candidate.employeeId)
      .filter((value): value is string => typeof value === "string" && value.length > 0),
  );

  if (distinctEmployeeIds.size > 1) {
    return {
      status: "ambiguous_match",
      match: null,
    };
  }

  return {
    status: "matched_employee",
    match: pool[0] ?? null,
  };
}

export function pickHrMatch(candidates: HrCandidateRow[]): {
  status: LegacyContactMigrationContactCandidate["status"];
  match: HrCandidateRow | null;
} {
  if (candidates.length === 0) {
    return {
      status: "no_hr_match",
      match: null,
    };
  }

  const activeCandidates = candidates.filter(rowIsActive);
  const pool = activeCandidates.length > 0 ? activeCandidates : candidates;
  const preferredSource = pool.some((candidate) => candidate.source === "EE_COMPANY_DIRECTORY_12_MONTH")
    ? "EE_COMPANY_DIRECTORY_12_MONTH"
    : "COMPANY_DIRECTORY";
  const preferredPool = pool.filter((candidate) => candidate.source === preferredSource);

  const distinctEmployeeIds = new Set(
    preferredPool
      .map((candidate) => candidate.employeeId)
      .filter((value): value is string => typeof value === "string" && value.length > 0),
  );

  if (distinctEmployeeIds.size > 1) {
    return {
      status: "ambiguous_match",
      match: null,
    };
  }

  const sorted = [...preferredPool].sort((left, right) => {
    const leftTime = left.updatedAt ? Date.parse(left.updatedAt) : 0;
    const rightTime = right.updatedAt ? Date.parse(right.updatedAt) : 0;
    return rightTime - leftTime;
  });

  return {
    status: "matched_employee",
    match: sorted[0] ?? null,
  };
}

function buildSuggestedContacts(
  assignment: LegacyAssignmentRow,
  contacts: ContactSummary[],
): LegacyContactMigrationReviewItem["suggestedContacts"] {
  const target = normalizeName(assignment.displayName);
  if (!target) {
    return [];
  }

  return contacts
    .filter((contact) => {
      const name = normalizeName(contact.name);
      return name === target || name.includes(target) || target.includes(name);
    })
    .slice(0, 3)
    .map((contact) => ({
      contactId: contact.id,
      name: contact.name,
      email: contact.email,
    }));
}

function summarizeDataset(input: {
  assignments: LegacyAssignmentRow[];
  contactCandidates: CandidateBundle[];
  reviewQueue: LegacyContactMigrationReviewItem[];
}): LegacyContactMigrationSummary {
  return {
    totalLegacyRows: input.assignments.length,
    distinctEmails: input.contactCandidates.length,
    matchedEmployees: input.contactCandidates.filter((candidate) => candidate.status === "matched_employee").length,
    alreadyInT3os: input.contactCandidates.filter((candidate) => candidate.status === "already_in_t3os").length,
    toCreate: input.contactCandidates.filter(
      (candidate) => candidate.status === "matched_employee" && !candidate.existingContactId,
    ).length,
    remappableAssignments: input.contactCandidates
      .filter((candidate) => candidate.status === "matched_employee" || candidate.status === "already_in_t3os")
      .reduce((sum, candidate) => sum + candidate.assignmentCount, 0),
    missingEmail: input.reviewQueue.filter((item) => item.reason === "missing_email").length,
    ambiguous: input.contactCandidates.filter((candidate) => candidate.status === "ambiguous_match").length,
    noHrMatch: input.contactCandidates.filter((candidate) => candidate.status === "no_hr_match").length,
  };
}

async function buildMigrationDataset(input: {
  token: string;
  workspaceId: string;
  businessContactId?: string;
  initiativeIds?: string[];
}): Promise<BuildMigrationDatasetResult> {
  const assignments = await listLegacyAssignments(input.initiativeIds);
  const [workspaceContacts, workspaceMembers, businessResolution] = await Promise.all([
    listPlatformContacts({
      token: input.token,
      workspaceId: input.workspaceId,
      contactType: "PERSON",
    }),
    listPlatformWorkspaceMembers({
      token: input.token,
      workspaceId: input.workspaceId,
    }),
    resolveBusinessContact(input.token, input.workspaceId, input.businessContactId),
  ]);

  const byEmail = new Map<string, LegacyAssignmentRow[]>();
  const reviewQueue: LegacyContactMigrationReviewItem[] = [];
  const missingEmailAssignments: LegacyAssignmentRow[] = [];

  for (const assignment of assignments) {
    const normalizedEmail = normalizeEmail(assignment.email);
    if (!normalizedEmail) {
      missingEmailAssignments.push(assignment);
      continue;
    }

    const current = byEmail.get(normalizedEmail) ?? [];
    current.push(assignment);
    byEmail.set(normalizedEmail, current);
  }

  const hrMatchesByEmail = await fetchHrMatchesByEmail(Array.from(byEmail.keys()));
  const corporateNameLookupMap = new Map<string, NameLookup>();
  for (const assignment of missingEmailAssignments) {
    const lookup = parseNameLookup(assignment.displayName);
    if (!lookup) {
      continue;
    }
    corporateNameLookupMap.set(`${lookup.firstName}:${lookup.lastName}`, lookup);
  }
  const corporateNameLookups = Array.from(corporateNameLookupMap.values());
  const corporateHrMatchesByName = await fetchCorporateHrMatchesByName(corporateNameLookups);
  const workspaceContactsByEmail = new Map<string, ContactSummary>();
  for (const contact of workspaceContacts) {
    const normalizedEmail = normalizeEmail(contact.email);
    if (normalizedEmail && !workspaceContactsByEmail.has(normalizedEmail)) {
      workspaceContactsByEmail.set(normalizedEmail, contact);
    }
  }

  const workspaceMembersByEmail = new Map<string, WorkspaceMemberSummary>();
  for (const member of workspaceMembers) {
    const normalizedEmail = normalizeEmail(member.user?.email ?? null);
    if (normalizedEmail && !workspaceMembersByEmail.has(normalizedEmail)) {
      workspaceMembersByEmail.set(normalizedEmail, member);
    }
  }

  for (const assignment of missingEmailAssignments) {
    const lookup = parseNameLookup(assignment.displayName);
    if (!lookup) {
      reviewQueue.push({
        initiativeId: assignment.initiativeId,
        initiativeCode: assignment.initiativeCode,
        initiativeTitle: assignment.initiativeTitle,
        initiativePersonId: assignment.personId,
        legacyDisplayName: assignment.displayName,
        legacyEmail: null,
        role: assignment.role,
        reason: "missing_email",
        suggestedContacts: buildSuggestedContacts(assignment, workspaceContacts),
      });
      continue;
    }

    const key = `${lookup.firstName}:${lookup.lastName}`;
    const { status, match } = pickCorporateNameMatch(corporateHrMatchesByName.get(key) ?? []);
    const matchedEmail = normalizeEmail(match?.email);

    if (status === "matched_employee" && matchedEmail) {
      const current = byEmail.get(matchedEmail) ?? [];
      current.push({
        ...assignment,
        email: matchedEmail,
      });
      byEmail.set(matchedEmail, current);
      if (!hrMatchesByEmail.has(matchedEmail) && match) {
        hrMatchesByEmail.set(matchedEmail, [match]);
      }
      continue;
    }

    reviewQueue.push({
      initiativeId: assignment.initiativeId,
      initiativeCode: assignment.initiativeCode,
      initiativeTitle: assignment.initiativeTitle,
      initiativePersonId: assignment.personId,
      legacyDisplayName: assignment.displayName,
      legacyEmail: null,
      role: assignment.role,
      reason: status === "ambiguous_match" ? "ambiguous_match" : "missing_email",
      suggestedContacts: buildSuggestedContacts(assignment, workspaceContacts),
    });
  }

  const contactCandidates: CandidateBundle[] = [];
  for (const [normalizedEmail, emailAssignments] of byEmail.entries()) {
    const existingContact = workspaceContactsByEmail.get(normalizedEmail) ?? null;
    const workspaceMember = workspaceMembersByEmail.get(normalizedEmail) ?? null;
    const { status, match } = pickHrMatch(hrMatchesByEmail.get(normalizedEmail) ?? []);

    const candidateStatus =
      existingContact !== null ? "already_in_t3os" : status;

    const candidate: CandidateBundle = {
      normalizedEmail,
      legacyNames: Array.from(
        new Set(emailAssignments.map((assignment) => assignment.displayName).filter(Boolean)),
      ),
      assignmentCount: emailAssignments.length,
      initiativeCount: new Set(emailAssignments.map((assignment) => assignment.initiativeId)).size,
      status:
        businessResolution.status !== "resolved" && candidateStatus === "matched_employee"
          ? "business_unresolved"
          : candidateStatus,
      existingContactId: existingContact?.id ?? null,
      existingContactName: existingContact?.name ?? null,
      hrMatch: match,
      workspaceMemberMatch: buildWorkspaceMemberMatch(workspaceMember),
      assignmentIds: emailAssignments.map((assignment) => assignment.personId),
    };
    contactCandidates.push(candidate);

    if (
      candidate.status === "ambiguous_match" ||
      candidate.status === "no_hr_match" ||
      candidate.status === "business_unresolved"
    ) {
      for (const assignment of emailAssignments) {
        reviewQueue.push({
          initiativeId: assignment.initiativeId,
          initiativeCode: assignment.initiativeCode,
          initiativeTitle: assignment.initiativeTitle,
          initiativePersonId: assignment.personId,
          legacyDisplayName: assignment.displayName,
          legacyEmail: normalizeEmail(assignment.email),
          role: assignment.role,
          reason: candidate.status,
          suggestedContacts: buildSuggestedContacts(assignment, workspaceContacts),
        });
      }
    }
  }

  const summary = summarizeDataset({
    assignments,
    contactCandidates,
    reviewQueue,
  });

  return {
    businessResolution,
    summary,
    contactCandidates,
    reviewQueue,
  };
}

async function insertMigrationRun(input: {
  mode: "preview" | "execute";
  workspaceId: string;
  businessContactId?: string | null;
  actor: AuditActor;
}): Promise<string> {
  const runId = createId("legacy_contact_migration");
  await db.insert(legacyContactMigrationRuns).values({
    id: runId,
    mode: input.mode,
    status: "running",
    workspaceId: input.workspaceId,
    businessContactId: input.businessContactId ?? null,
    createdByType: input.actor.type,
    createdById: input.actor.id,
  });
  return runId;
}

async function finalizeMigrationRun(input: {
  runId: string;
  status: "completed" | "failed";
  businessContactId?: string | null;
  summary: LegacyContactMigrationSummary;
  contactCandidates: LegacyContactMigrationContactCandidate[];
  reviewQueue: LegacyContactMigrationReviewItem[];
  errorText?: string;
}): Promise<void> {
  await db
    .update(legacyContactMigrationRuns)
    .set({
      status: input.status,
      businessContactId: input.businessContactId ?? null,
      summary: input.summary,
      contactCandidates: input.contactCandidates,
      reviewQueue: input.reviewQueue,
      errorText: input.errorText ?? null,
      finishedAt: new Date(),
    })
    .where(eq(legacyContactMigrationRuns.id, input.runId));
}

function buildResponse(input: {
  runId: string;
  mode: "preview" | "execute";
  status: "completed" | "failed";
  workspaceId: string;
  businessResolution: LegacyContactMigrationBusinessResolution;
  summary: LegacyContactMigrationSummary;
  contactCandidates: LegacyContactMigrationContactCandidate[];
  reviewQueue: LegacyContactMigrationReviewItem[];
}): LegacyContactMigrationResponse {
  return {
    runId: input.runId,
    mode: input.mode,
    status: input.status,
    workspaceId: input.workspaceId,
    businessResolution: input.businessResolution,
    summary: input.summary,
    contactCandidates: input.contactCandidates,
    reviewQueue: input.reviewQueue,
    createdAt: new Date().toISOString(),
    finishedAt: new Date().toISOString(),
  };
}

export async function previewLegacyContactsMigration(input: {
  token: string;
  actor: AuditActor;
  payload: LegacyContactMigrationInput;
}): Promise<LegacyContactMigrationResponse> {
  const runId = await insertMigrationRun({
    mode: "preview",
    workspaceId: input.payload.workspaceId,
    businessContactId: input.payload.businessContactId ?? null,
    actor: input.actor,
  });

  let dataset: BuildMigrationDatasetResult | null = null;

  try {
    dataset = await buildMigrationDataset({
      token: input.token,
      workspaceId: input.payload.workspaceId,
      businessContactId: input.payload.businessContactId,
      initiativeIds: input.payload.initiativeIds,
    });

    await finalizeMigrationRun({
      runId,
      status: "completed",
      businessContactId: dataset.businessResolution.businessContactId,
      summary: dataset.summary,
      contactCandidates: dataset.contactCandidates,
      reviewQueue: dataset.reviewQueue,
    });

    await recordAuditEvent({
      actor: input.actor,
      action: "platform.legacy_contacts.preview",
      entityType: "legacy_contact_migration_run",
      entityId: runId,
      payload: {
        workspaceId: input.payload.workspaceId,
        summary: dataset.summary,
      },
    });

    return buildResponse({
      runId,
      mode: "preview",
      status: "completed",
      workspaceId: input.payload.workspaceId,
      businessResolution: dataset.businessResolution,
      summary: dataset.summary,
      contactCandidates: dataset.contactCandidates,
      reviewQueue: dataset.reviewQueue,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Legacy contact preview failed";
    await finalizeMigrationRun({
      runId,
      status: "failed",
      businessContactId: dataset?.businessResolution.businessContactId ?? null,
      summary:
        dataset?.summary ?? {
          totalLegacyRows: 0,
          distinctEmails: 0,
          matchedEmployees: 0,
          alreadyInT3os: 0,
          toCreate: 0,
          remappableAssignments: 0,
          missingEmail: 0,
          ambiguous: 0,
          noHrMatch: 0,
        },
      contactCandidates: dataset?.contactCandidates ?? [],
      reviewQueue: dataset?.reviewQueue ?? [],
      errorText: message,
    });
    throw error;
  }
}

export async function executeLegacyContactsMigration(input: {
  token: string;
  actor: AuditActor;
  payload: LegacyContactMigrationInput;
}): Promise<LegacyContactMigrationResponse> {
  const runId = await insertMigrationRun({
    mode: "execute",
    workspaceId: input.payload.workspaceId,
    businessContactId: input.payload.businessContactId ?? null,
    actor: input.actor,
  });

  let dataset: BuildMigrationDatasetResult | null = null;

  try {
    dataset = await buildMigrationDataset({
      token: input.token,
      workspaceId: input.payload.workspaceId,
      businessContactId: input.payload.businessContactId,
      initiativeIds: input.payload.initiativeIds,
    });

    if (dataset.businessResolution.status !== "resolved" || !dataset.businessResolution.businessContactId) {
      throw new Error("EquipmentShare business contact could not be resolved in the target workspace.");
    }

    let createdContacts = 0;
    let reusedContacts = 0;
    let remappedAssignments = 0;

    for (const candidate of dataset.contactCandidates) {
      if (candidate.status !== "matched_employee" && candidate.status !== "already_in_t3os") {
        continue;
      }

      let contactId = candidate.existingContactId;
      if (!contactId) {
        const hrMatch = candidate.hrMatch;
        if (!hrMatch) {
          continue;
        }

        const created = await createPlatformContact({
          token: input.token,
          payload: {
            contactType: "PERSON",
            workspaceId: input.payload.workspaceId,
            businessId: dataset.businessResolution.businessContactId,
            name: hrMatch.fullName,
            email: hrMatch.email,
            phone: hrMatch.workPhone,
            role: hrMatch.employeeTitle,
          },
        });
        contactId = created.id;
        createdContacts += 1;
      } else {
        reusedContacts += 1;
      }

      if (!contactId || candidate.assignmentIds.length === 0) {
        continue;
      }

      await db
        .update(initiativePeople)
        .set({
          t3osContactId: contactId,
          t3osUserId: candidate.workspaceMemberMatch?.userId ?? null,
          t3osWorkspaceMemberId: candidate.workspaceMemberMatch?.userId ?? null,
          sourceType: "t3os",
          displayName:
            candidate.hrMatch?.fullName ??
            candidate.existingContactName ??
            candidate.legacyNames[0] ??
            "",
          email: candidate.normalizedEmail,
        })
        .where(inArray(initiativePeople.id, candidate.assignmentIds));

      remappedAssignments += candidate.assignmentIds.length;
      candidate.existingContactId = contactId;
    }

    const finalSummary: LegacyContactMigrationSummary = {
      ...dataset.summary,
      createdContacts,
      reusedContacts,
      remappedAssignments,
    };

    await finalizeMigrationRun({
      runId,
      status: "completed",
      businessContactId: dataset.businessResolution.businessContactId,
      summary: finalSummary,
      contactCandidates: dataset.contactCandidates,
      reviewQueue: dataset.reviewQueue,
    });

    await recordAuditEvent({
      actor: input.actor,
      action: "platform.legacy_contacts.execute",
      entityType: "legacy_contact_migration_run",
      entityId: runId,
      payload: {
        workspaceId: input.payload.workspaceId,
        summary: finalSummary,
      },
    });

    return buildResponse({
      runId,
      mode: "execute",
      status: "completed",
      workspaceId: input.payload.workspaceId,
      businessResolution: dataset.businessResolution,
      summary: finalSummary,
      contactCandidates: dataset.contactCandidates,
      reviewQueue: dataset.reviewQueue,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Legacy contact migration failed";
    await finalizeMigrationRun({
      runId,
      status: "failed",
      businessContactId: dataset?.businessResolution.businessContactId ?? null,
      summary:
        dataset?.summary ?? {
          totalLegacyRows: 0,
          distinctEmails: 0,
          matchedEmployees: 0,
          alreadyInT3os: 0,
          toCreate: 0,
          remappableAssignments: 0,
          missingEmail: 0,
          ambiguous: 0,
          noHrMatch: 0,
        },
      contactCandidates: dataset?.contactCandidates ?? [],
      reviewQueue: dataset?.reviewQueue ?? [],
      errorText: message,
    });
    throw error;
  }
}

export async function getLatestLegacyContactMigrationRun(
  workspaceId: string,
): Promise<LegacyContactMigrationResponse | null> {
  const run = await db.query.legacyContactMigrationRuns.findFirst({
    where: eq(legacyContactMigrationRuns.workspaceId, workspaceId),
    orderBy: [desc(legacyContactMigrationRuns.createdAt)],
  });

  if (!run) {
    return null;
  }

  return {
    runId: run.id,
    mode: run.mode as LegacyContactMigrationResponse["mode"],
    status: run.status as LegacyContactMigrationResponse["status"],
    workspaceId: run.workspaceId,
    businessResolution: {
      status: run.businessContactId ? "resolved" : "missing",
      businessContactId: run.businessContactId,
      businessName: null,
      matches: run.businessContactId ? [{ id: run.businessContactId, name: "EquipmentShare" }] : [],
    },
    summary: run.summary as LegacyContactMigrationSummary,
    contactCandidates: run.contactCandidates as LegacyContactMigrationContactCandidate[],
    reviewQueue: run.reviewQueue as LegacyContactMigrationReviewItem[],
    createdAt: run.createdAt.toISOString(),
    finishedAt: run.finishedAt ? run.finishedAt.toISOString() : null,
  };
}
