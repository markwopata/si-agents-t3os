import type {
  ContactSummary,
  ApiToken,
  ApiTokenCreateInput,
  ObservationReview,
  ObservationReviewUpsertInput,
  GoogleInstallStatus,
  CurrentUser,
  CreateOrUpdateContactInput,
  ImportSummary,
  InitiativeDetail,
  InitiativeAnnotationCreateInput,
  InitiativeGoogleEvidence,
  InitiativeKpiResearch,
  InitiativeRunConfigUpsertInput,
  InitiativeSlackEvidence,
  InitiativeTracker,
  InitiativeSummary,
  KnowledgeDocumentUpsertInput,
  PilotCandidate,
  PilotRun,
  PortfolioRefreshRun,
  SlackInstallStatus,
  UpdateContactInput,
  WorkspaceMemberSummary,
} from "@si/domain";
import { getT3osAccessToken } from "../lib/t3os";

const LOCAL_API_BASE_URL = "http://localhost:3001";
const HOSTED_API_BASE_URL =
  import.meta.env.VITE_T3OS_API_BASE_URL || "https://si-agents-api.onrender.com";

function resolveApiBaseUrl(): string {
  const explicit = import.meta.env.VITE_API_BASE_URL?.trim();
  if (explicit) {
    return explicit;
  }

  if (typeof window === "undefined") {
    return LOCAL_API_BASE_URL;
  }

  const isLocalHost = ["localhost", "127.0.0.1"].includes(window.location.hostname);
  const hasT3osShell = Boolean(window.T3os?.auth?.getToken);

  if (hasT3osShell) {
    return HOSTED_API_BASE_URL;
  }

  return isLocalHost ? LOCAL_API_BASE_URL : HOSTED_API_BASE_URL;
}

function resolveApiBaseUrlForToken(token: string | null): string {
  const explicit = import.meta.env.VITE_API_BASE_URL?.trim();
  if (explicit) {
    return explicit;
  }

  if (typeof window === "undefined") {
    return LOCAL_API_BASE_URL;
  }

  const isLocalHost = ["localhost", "127.0.0.1"].includes(window.location.hostname);
  if (isLocalHost && !token) {
    return LOCAL_API_BASE_URL;
  }

  return HOSTED_API_BASE_URL;
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const token = await getT3osAccessToken();
  const response = await fetch(`${resolveApiBaseUrlForToken(token)}${path}`, {
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(init?.headers ?? {}),
    },
    ...init,
  });

  if (!response.ok) {
    throw new Error(await response.text());
  }

  return response.json() as Promise<T>;
}

export function getApiBaseUrl(): string {
  return resolveApiBaseUrl();
}

export function getCurrentUser(): Promise<CurrentUser> {
  return request("/me");
}

export function listApiTokens(includeAllForAdmin = false): Promise<ApiToken[]> {
  const query = includeAllForAdmin ? "?all=true" : "";
  return request(`/api-tokens${query}`);
}

export function createApiToken(
  payload: ApiTokenCreateInput,
): Promise<{ id: string; token: string }> {
  return request("/api-tokens", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function deleteApiToken(tokenId: string): Promise<{ ok: boolean }> {
  return request(`/api-tokens/${tokenId}`, {
    method: "DELETE",
  });
}

export function listPlatformContacts(
  workspaceId: string,
  contactType?: "PERSON" | "BUSINESS",
): Promise<{ workspaceId: string; items: ContactSummary[] }> {
  const query = new URLSearchParams({ workspaceId });
  if (contactType) {
    query.set("contactType", contactType);
  }
  return request(`/platform/contacts?${query.toString()}`);
}

export function listPlatformWorkspaceMembers(
  workspaceId: string,
): Promise<{ workspaceId: string; items: WorkspaceMemberSummary[] }> {
  return request(`/platform/workspace-members?${new URLSearchParams({ workspaceId }).toString()}`);
}

export function createPlatformContact(
  payload: CreateOrUpdateContactInput,
): Promise<ContactSummary> {
  return request("/platform/contacts", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function updatePlatformContact(
  contactId: string,
  payload: UpdateContactInput,
): Promise<ContactSummary> {
  return request(`/platform/contacts/${contactId}`, {
    method: "PATCH",
    body: JSON.stringify(payload),
  });
}

export function invitePlatformWorkspaceMember(payload: {
  workspaceId: string;
  email: string;
  roles: string[];
}): Promise<WorkspaceMemberSummary> {
  return request("/platform/workspace-members/invite", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function updatePlatformWorkspaceMemberRoles(
  userId: string,
  payload: {
    workspaceId: string;
    roles: string[];
  },
): Promise<WorkspaceMemberSummary> {
  return request(`/platform/workspace-members/${userId}/roles`, {
    method: "PATCH",
    body: JSON.stringify(payload),
  });
}

export function removePlatformWorkspaceMember(
  userId: string,
  workspaceId: string,
): Promise<{ ok: boolean }> {
  return request(`/platform/workspace-members/${userId}?${new URLSearchParams({ workspaceId }).toString()}`, {
    method: "DELETE",
  });
}

export function listInitiatives(): Promise<InitiativeSummary[]> {
  return request("/initiatives");
}

export function getInitiative(initiativeId: string): Promise<InitiativeDetail> {
  return request(`/initiatives/${initiativeId}`);
}

export function getInitiativeSlackEvidence(
  initiativeId: string,
): Promise<InitiativeSlackEvidence> {
  return request(`/initiatives/${initiativeId}/slack-evidence`);
}

export function getInitiativeGoogleEvidence(
  initiativeId: string,
): Promise<InitiativeGoogleEvidence> {
  return request(`/initiatives/${initiativeId}/google-evidence`);
}

export function getInitiativeTracker(initiativeId: string): Promise<InitiativeTracker> {
  return request(`/initiatives/${initiativeId}/tracker`);
}

export function getInitiativeKpiResearch(
  initiativeId: string,
): Promise<InitiativeKpiResearch> {
  return request(`/initiatives/${initiativeId}/kpi-research`);
}

export function getInitiativeRunConfig(
  initiativeId: string,
): Promise<InitiativeDetail["runConfig"]> {
  return request(`/initiatives/${initiativeId}/run-config`);
}

export function saveInitiativeRunConfig(
  initiativeId: string,
  payload: InitiativeRunConfigUpsertInput,
): Promise<NonNullable<InitiativeDetail["runConfig"]>> {
  return request(`/initiatives/${initiativeId}/run-config`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

export function createInitiativeAnnotation(
  initiativeId: string,
  payload: InitiativeAnnotationCreateInput,
): Promise<InitiativeDetail["annotations"][number]> {
  return request(`/initiatives/${initiativeId}/annotations`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function deleteInitiativeAnnotation(
  initiativeId: string,
  annotationId: string,
): Promise<{ ok: boolean }> {
  return request(`/initiatives/${initiativeId}/annotations/${annotationId}`, {
    method: "DELETE",
  });
}

export function createInitiative(payload: Record<string, unknown>): Promise<InitiativeDetail> {
  return request("/initiatives", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function updateInitiative(
  initiativeId: string,
  payload: Record<string, unknown>,
): Promise<InitiativeDetail> {
  return request(`/initiatives/${initiativeId}`, {
    method: "PATCH",
    body: JSON.stringify(payload),
  });
}

export function archiveInitiative(initiativeId: string): Promise<{ ok: boolean }> {
  return request(`/initiatives/${initiativeId}`, {
    method: "DELETE",
  });
}

export function replacePeople(
  initiativeId: string,
  people: InitiativeDetail["people"],
): Promise<{ ok: boolean }> {
  return request(`/initiatives/${initiativeId}/people`, {
    method: "PUT",
    body: JSON.stringify({ people }),
  });
}

export function replaceLinks(
  initiativeId: string,
  links: InitiativeDetail["links"],
): Promise<{ ok: boolean }> {
  return request(`/initiatives/${initiativeId}/links`, {
    method: "PUT",
    body: JSON.stringify({ links }),
  });
}

export function replaceSnapshots(
  initiativeId: string,
  snapshots: InitiativeDetail["snapshots"],
): Promise<{ ok: boolean }> {
  return request(`/initiatives/${initiativeId}/period-snapshots`, {
    method: "PUT",
    body: JSON.stringify({ snapshots }),
  });
}

export function getGlobalKnowledge(): Promise<{
  id: string;
  title: string;
  slug: string;
  content: string;
  version: number;
  updatedAt: string;
}> {
  return request("/knowledge/global");
}

export function saveGlobalKnowledge(
  payload: KnowledgeDocumentUpsertInput,
): Promise<{
  id: string;
  title: string;
  slug: string;
  content: string;
  version: number;
  updatedAt: string;
}> {
  return request("/knowledge/global", {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

export function saveInitiativeKnowledge(
  initiativeId: string,
  payload: KnowledgeDocumentUpsertInput,
): Promise<{
  id: string;
  title: string;
  slug: string;
  content: string;
  version: number;
  updatedAt: string;
}> {
  return request(`/knowledge/initiatives/${initiativeId}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

export async function importWorkbook(file?: File): Promise<ImportSummary> {
  if (!file) {
    return request("/imports/si-workbook", {
      method: "POST",
      body: JSON.stringify({}),
    });
  }

  const formData = new FormData();
  formData.append("file", file);
  const token = await getT3osAccessToken();
  const response = await fetch(`${resolveApiBaseUrlForToken(token)}/imports/si-workbook`, {
    method: "POST",
    headers: token ? { Authorization: `Bearer ${token}` } : undefined,
    body: formData,
  });

  if (!response.ok) {
    throw new Error(await response.text());
  }

  return response.json() as Promise<ImportSummary>;
}

export function runInitiativeEvaluation(
  initiativeId: string,
  options?: { refreshKpis?: boolean },
): Promise<{ runId: string; observationId: string }> {
  return request(`/agent/run/${initiativeId}`, {
    method: "POST",
    body: JSON.stringify({ refreshKpis: options?.refreshKpis ?? true }),
  });
}

export function runAllEvaluations(
  options?: { refreshKpis?: boolean },
): Promise<{ runIds: string[] }> {
  return request("/agent/run-all", {
    method: "POST",
    body: JSON.stringify({ refreshKpis: options?.refreshKpis ?? true }),
  });
}

export function launchPortfolioRefresh(): Promise<PortfolioRefreshRun> {
  return request("/portfolio/refresh", {
    method: "POST",
  });
}

export function getLatestPortfolioRefresh(): Promise<PortfolioRefreshRun | null> {
  return request("/portfolio/refresh/latest");
}

export function getPortfolioRefresh(runId: string): Promise<PortfolioRefreshRun | null> {
  return request(`/portfolio/refresh/runs/${runId}`);
}

export function previewPilotCohort(): Promise<PilotCandidate[]> {
  return request("/pilot/cohort");
}

export function runPilotBatch(): Promise<{ batchId: string; cohort: PilotCandidate[] }> {
  return request("/pilot/run", {
    method: "POST",
  });
}

export function getLatestPilotBatch(): Promise<PilotRun | null> {
  return request("/pilot/latest");
}

export function getPilotBatch(batchId: string): Promise<PilotRun | null> {
  return request(`/pilot/runs/${batchId}`);
}

export function syncInitiativeHistory(
  initiativeId: string,
): Promise<{
  ok: boolean;
  slackSync: { runIds: string[]; messagesSynced: number; repliesSynced: number };
  googleSync: {
    runId: string;
    trackerCandidate: { trackerFileId: string; trackerName: string; webViewLink: string | null } | null;
    snapshotCount: number;
    revisionCount: number;
  };
  trackerParseRunId: string | null;
}> {
  return request(`/initiatives/${initiativeId}/sync-history`, {
    method: "POST",
  });
}

export function runInitiativeKpiResearch(
  initiativeId: string,
): Promise<{ researchRunId: string }> {
  return request(`/initiatives/${initiativeId}/research-kpis`, {
    method: "POST",
  });
}

export function saveInitiativeRanking(orderedIds: string[]): Promise<InitiativeSummary[]> {
  return request("/initiatives/ranking", {
    method: "PUT",
    body: JSON.stringify({ orderedIds }),
  });
}

export function recomputeInitiativeRanking(): Promise<InitiativeSummary[]> {
  return request("/initiatives/ranking/recompute", {
    method: "POST",
  });
}

export function saveObservationReview(
  observationId: string,
  payload: ObservationReviewUpsertInput,
): Promise<ObservationReview> {
  return request(`/observations/${observationId}/review`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

export function getSlackStatus(): Promise<SlackInstallStatus> {
  return request("/integrations/slack/status");
}

export function getGoogleStatus(): Promise<GoogleInstallStatus> {
  return request("/integrations/google/status");
}
