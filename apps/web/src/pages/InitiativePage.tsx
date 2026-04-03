import type {
  ContactSummary,
  CurrentUser,
  InitiativeDetail,
  InitiativeGoogleEvidence,
  InitiativeKpiResearch,
  InitiativeSlackEvidence,
  InitiativeTracker,
  WorkspaceMemberSummary,
} from "@si/domain";
import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import {
  archiveInitiative,
  createPlatformContact,
  createInitiativeAnnotation,
  deleteInitiativeAnnotation,
  getInitiative,
  getInitiativeGoogleEvidence,
  getInitiativeKpiResearch,
  getInitiativeSlackEvidence,
  getInitiativeTracker,
  getCurrentUser,
  replaceLinks,
  replacePeople,
  replaceSnapshots,
  listPlatformContacts,
  listPlatformWorkspaceMembers,
  runInitiativeEvaluation,
  runInitiativeKpiResearch,
  saveInitiativeRunConfig,
  saveInitiativeKnowledge,
  syncInitiativeHistory,
  updateInitiative,
} from "../api/client";
import { OpinionPanel } from "../components/OpinionPanel";
import { getCurrentWorkspaceId } from "../lib/t3os";

function emptyInitiative(): InitiativeDetail {
  return {
    id: "",
    code: "",
    title: "",
    objective: "",
    group: "",
    targetCadence: "",
    updateType: "",
    stage: "",
    lClass: "",
    progress: "",
    leadPerformance: "",
    administrationHealth: "",
    impactType: "",
    inCapPlan: null,
    isActive: true,
    priorityRank: null,
    priorityScore: null,
    priorityReason: null,
    prioritySource: null,
    rankingUpdatedAt: null,
    latestOpinionStatus: null,
    latestOpinionConfidence: null,
    updatedAt: "",
    sourceRowNumber: null,
    people: [],
    links: [],
    snapshots: [],
    knowledgeDocument: null,
    annotations: [],
    runConfig: null,
    observations: [],
  };
}

function emptySlackEvidence(initiativeId: string): InitiativeSlackEvidence {
  return {
    connected: false,
    initiativeId,
    channels: [],
    issues: [],
    fetchedAt: "",
  };
}

function emptyGoogleEvidence(initiativeId: string): InitiativeGoogleEvidence {
  return {
    connected: false,
    initiativeId,
    files: [],
    issues: [],
    fetchedAt: "",
  };
}

function emptyTracker(initiativeId: string): InitiativeTracker {
  return {
    connected: false,
    initiativeId,
    latestParseRunId: null,
    trackerFileId: null,
    trackerName: null,
    sheetName: null,
    summaryFields: [],
    items: [],
    parsedAt: null,
    summary: {},
  };
}

function emptyKpiResearch(initiativeId: string): InitiativeKpiResearch {
  return {
    initiativeId,
    latestResearchRunId: null,
    findings: [],
    summary: {},
    researchedAt: null,
  };
}

export function InitiativePage() {
  const { initiativeId = "" } = useParams();
  const navigate = useNavigate();
  const [initiative, setInitiative] = useState<InitiativeDetail>(emptyInitiative());
  const [slackEvidence, setSlackEvidence] = useState<InitiativeSlackEvidence>(
    emptySlackEvidence(initiativeId),
  );
  const [googleEvidence, setGoogleEvidence] = useState<InitiativeGoogleEvidence>(
    emptyGoogleEvidence(initiativeId),
  );
  const [tracker, setTracker] = useState<InitiativeTracker>(emptyTracker(initiativeId));
  const [kpiResearch, setKpiResearch] = useState<InitiativeKpiResearch>(emptyKpiResearch(initiativeId));
  const [currentUser, setCurrentUser] = useState<CurrentUser | null>(null);
  const [workspaceContacts, setWorkspaceContacts] = useState<ContactSummary[]>([]);
  const [workspaceBusinesses, setWorkspaceBusinesses] = useState<ContactSummary[]>([]);
  const [workspaceMembers, setWorkspaceMembers] = useState<WorkspaceMemberSummary[]>([]);
  const [workspaceDirectoryStatus, setWorkspaceDirectoryStatus] = useState("");
  const [selectedPlatformContactId, setSelectedPlatformContactId] = useState("");
  const [selectedPlatformRole, setSelectedPlatformRole] =
    useState<InitiativeDetail["people"][number]["role"]>("other_invitee");
  const [annotationDraft, setAnnotationDraft] = useState({
    annotationType: "analysis_instruction" as InitiativeDetail["annotations"][number]["annotationType"],
    title: "",
    content: "",
  });
  const [newPlatformContact, setNewPlatformContact] = useState({
    name: "",
    email: "",
    phone: "",
    businessId: "",
  });
  const [status, setStatus] = useState("Loading...");

  async function loadPlatformDirectory(me: CurrentUser) {
    const workspaceId = me.workspaceId ?? getCurrentWorkspaceId();
    if (
      me.type !== "human" ||
      me.authSource !== "t3os_jwt" ||
      !workspaceId
    ) {
      setWorkspaceContacts([]);
      setWorkspaceBusinesses([]);
      setWorkspaceMembers([]);
      setWorkspaceDirectoryStatus(
        canAccessPlatformDirectory(me)
          ? "Open this page inside T3OS staging to load workspace contacts and members."
          : "",
      );
      return;
    }

    try {
      setWorkspaceDirectoryStatus("Loading workspace contacts and members...");
      const [contactsResponse, businessResponse, membersResponse] = await Promise.all([
        listPlatformContacts(workspaceId, "PERSON"),
        listPlatformContacts(workspaceId, "BUSINESS"),
        listPlatformWorkspaceMembers(workspaceId),
      ]);
      setWorkspaceContacts(contactsResponse.items);
      setWorkspaceBusinesses(businessResponse.items);
      setWorkspaceMembers(membersResponse.items);
      setWorkspaceDirectoryStatus(
        `Loaded ${contactsResponse.items.length} workspace contacts, ${businessResponse.items.length} businesses, and ${membersResponse.items.length} workspace members.`,
      );
    } catch (error) {
      setWorkspaceContacts([]);
      setWorkspaceBusinesses([]);
      setWorkspaceMembers([]);
      setWorkspaceDirectoryStatus(
        error instanceof Error
          ? `Workspace directory unavailable: ${error.message}`
          : "Workspace directory unavailable.",
      );
    }
  }

  async function loadPageData() {
    const [detail, slack, google, trackerResponse, kpiResponse, me] = await Promise.all([
      getInitiative(initiativeId),
      getInitiativeSlackEvidence(initiativeId),
      getInitiativeGoogleEvidence(initiativeId),
      getInitiativeTracker(initiativeId),
      getInitiativeKpiResearch(initiativeId),
      getCurrentUser(),
    ]);
    setInitiative(detail);
    setSlackEvidence(slack);
    setGoogleEvidence(google);
    setTracker(trackerResponse);
    setKpiResearch(kpiResponse);
    setCurrentUser(me);
    await loadPlatformDirectory(me);
  }

  useEffect(() => {
    async function load() {
      await loadPageData();
      setStatus("");
    }
    void load();
  }, [initiativeId]);

  async function reload() {
    await loadPageData();
  }

  async function refreshSlackEvidence() {
    setStatus("Refreshing Slack evidence...");
    setSlackEvidence(await getInitiativeSlackEvidence(initiativeId));
    setStatus("Slack evidence refreshed.");
  }

  async function refreshGoogleEvidence() {
    setStatus("Refreshing Google evidence...");
    setGoogleEvidence(await getInitiativeGoogleEvidence(initiativeId));
    setStatus("Google evidence refreshed.");
  }

  async function handleSaveAll() {
    setStatus("Saving...");
    await updateInitiative(initiativeId, {
      code: initiative.code,
      title: initiative.title,
      objective: initiative.objective,
      group: initiative.group,
      targetCadence: initiative.targetCadence,
      updateType: initiative.updateType,
      stage: initiative.stage,
      lClass: initiative.lClass,
      progress: initiative.progress,
      leadPerformance: initiative.leadPerformance,
      administrationHealth: initiative.administrationHealth,
      impactType: initiative.impactType,
      inCapPlan: initiative.inCapPlan,
      isActive: initiative.isActive,
    });
    await replacePeople(initiativeId, initiative.people);
    await replaceLinks(initiativeId, initiative.links);
    await replaceSnapshots(initiativeId, initiative.snapshots);
    await saveInitiativeKnowledge(initiativeId, {
      title: initiative.knowledgeDocument?.title ?? `${initiative.code} ${initiative.title} Notes`,
      slug:
        initiative.knowledgeDocument?.slug ??
        `initiative-${initiative.code.toLowerCase()}-${initiative.title.toLowerCase().replace(/\s+/g, "-")}`,
      content: initiative.knowledgeDocument?.content ?? "",
      documentType: "initiative",
      initiativeId,
    });
    await reload();
    setStatus("Saved.");
  }

  async function handleSaveKnowledgeOnly() {
    setStatus("Saving initiative knowledge...");
    await saveInitiativeKnowledge(initiativeId, {
      title: initiative.knowledgeDocument?.title ?? `${initiative.code} ${initiative.title} Notes`,
      slug:
        initiative.knowledgeDocument?.slug ??
        `initiative-${initiative.code.toLowerCase()}-${initiative.title.toLowerCase().replace(/\s+/g, "-")}`,
      content: initiative.knowledgeDocument?.content ?? "",
      documentType: "initiative",
      initiativeId,
    });
    await reload();
    setStatus("Initiative knowledge saved.");
  }

  async function handleRunEvaluation() {
    setStatus("Running evaluation...");
    await runInitiativeEvaluation(initiativeId);
    await reload();
    setStatus("Evaluation complete.");
  }

  async function handleSyncHistory() {
    setStatus("Backfilling Slack and Google history...");
    await syncInitiativeHistory(initiativeId);
    await reload();
    setStatus("Historical evidence synced.");
  }

  async function handleRunKpiResearch() {
    setStatus("Running KPI research...");
    await runInitiativeKpiResearch(initiativeId);
    await reload();
    setStatus("KPI research complete.");
  }

  async function handleArchive() {
    await archiveInitiative(initiativeId);
    navigate("/");
  }

  async function handleSaveRunConfig() {
    setStatus("Saving SI run config...");
    await saveInitiativeRunConfig(initiativeId, {
      cadenceMode: initiative.runConfig?.cadenceMode ?? "manual",
      cadenceDetail: initiative.runConfig?.cadenceDetail ?? "",
      alertThresholds: initiative.runConfig?.alertThresholds ?? {
        maxTrackerStalenessDays: null,
        attentionBlockerCount: null,
        minimumSlackMessages30d: null,
        minimumDriveUpdates30d: null,
        minimumOnTrackScore: null,
      },
      customKpiRulesMarkdown: initiative.runConfig?.customKpiRulesMarkdown ?? "",
      customInstructionsMarkdown: initiative.runConfig?.customInstructionsMarkdown ?? "",
      goodLooksLikeMarkdown: initiative.runConfig?.goodLooksLikeMarkdown ?? "",
      ownerNotesMarkdown: initiative.runConfig?.ownerNotesMarkdown ?? "",
    });
    await reload();
    setStatus("SI run config saved.");
  }

  async function handleAddAnnotation() {
    if (!annotationDraft.title.trim() || !annotationDraft.content.trim()) {
      return;
    }
    setStatus("Posting SI instruction...");
    await createInitiativeAnnotation(initiativeId, {
      annotationType: annotationDraft.annotationType,
      title: annotationDraft.title,
      content: annotationDraft.content,
      metadata: {},
    });
    setAnnotationDraft({
      annotationType: "analysis_instruction",
      title: "",
      content: "",
    });
    await reload();
    setStatus("SI instruction posted.");
  }

  async function handleDeleteAnnotation(annotationId: string) {
    setStatus("Removing SI instruction...");
    await deleteInitiativeAnnotation(initiativeId, annotationId);
    await reload();
    setStatus("SI instruction removed.");
  }

  const trackerCurrentFindings = kpiResearch.findings.filter((finding) => finding.findingClass === "tracker_current");
  const analyticsReferenceFindings = kpiResearch.findings
    .filter((finding) => finding.findingClass === "analytics_reference")
    .sort((left, right) => Number(right.provenance.score ?? 0) - Number(left.provenance.score ?? 0));
  const proposalFindings = kpiResearch.findings.filter((finding) => finding.findingClass === "proposal");
  const canManageRecord = currentUser?.type === "service_token" || currentUser?.appRole === "executive";
  const canContribute = canManageRecord || currentUser?.appRole === "participant";
  const canUsePlatformDirectory =
    currentUser?.type === "human" && currentUser.authSource === "t3os_jwt" && Boolean(currentUser.workspaceId);

  function handleAddWorkspacePerson() {
    const contact = workspaceContacts.find((item) => item.id === selectedPlatformContactId);
    if (!contact) {
      return;
    }

    const matchingMember = workspaceMembers.find((member) => {
      const memberEmail = member.user?.email?.toLowerCase();
      return Boolean(contact.email && memberEmail && memberEmail === contact.email.toLowerCase());
    });

    setInitiative({
      ...initiative,
      people: [
        ...initiative.people,
        {
          id: `temp-t3os-${contact.id}-${Date.now()}`,
          role: selectedPlatformRole,
          displayName: contact.name,
          email: contact.email,
          sortOrder: initiative.people.length,
          t3osContactId: contact.id,
          t3osWorkspaceMemberId: matchingMember?.userId ?? null,
          t3osUserId: matchingMember?.user?.id ?? matchingMember?.userId ?? null,
          sourceType: "t3os",
          directorySource: "t3os",
          directoryResolved: true,
        },
      ],
    });
    setSelectedPlatformContactId("");
  }

  async function handleCreateWorkspaceContact() {
    const workspaceId = currentUser?.workspaceId ?? getCurrentWorkspaceId();
    if (!workspaceId || !newPlatformContact.name.trim() || !newPlatformContact.email.trim() || !newPlatformContact.businessId) {
      return;
    }

    setStatus("Creating T3OS contact...");
    const created = await createPlatformContact({
      contactType: "PERSON",
      workspaceId,
      name: newPlatformContact.name.trim(),
      email: newPlatformContact.email.trim(),
      phone: newPlatformContact.phone.trim() || null,
      role: null,
      businessId: newPlatformContact.businessId,
      resourceMapIds: [],
    });

    const matchingMember = workspaceMembers.find((member) => {
      const memberEmail = member.user?.email?.toLowerCase();
      return Boolean(created.email && memberEmail && memberEmail === created.email.toLowerCase());
    });

    setWorkspaceContacts((current) =>
      [...current, created].sort((left, right) => left.name.localeCompare(right.name)),
    );
    setInitiative({
      ...initiative,
      people: [
        ...initiative.people,
        {
          id: `temp-t3os-${created.id}-${Date.now()}`,
          role: selectedPlatformRole,
          displayName: created.name,
          email: created.email,
          sortOrder: initiative.people.length,
          t3osContactId: created.id,
          t3osWorkspaceMemberId: matchingMember?.userId ?? null,
          t3osUserId: matchingMember?.user?.id ?? matchingMember?.userId ?? null,
          sourceType: "t3os",
          directorySource: "t3os",
          directoryResolved: true,
        },
      ],
    });
    setNewPlatformContact({
      name: "",
      email: "",
      phone: "",
      businessId: "",
    });
    setStatus("Created T3OS contact and added it to the SI role draft. Save Record to persist the mapping.");
  }

  function canAccessPlatformDirectory(me: CurrentUser | null): boolean {
    return Boolean(me && me.type === "human" && me.appRole === "executive");
  }

  return (
    <div className="page-stack">
      <section className="hero-card compact">
        <div>
          <div className="eyebrow">Initiative Detail</div>
          <h2>
            {initiative.code} {initiative.title}
          </h2>
          <p>{initiative.objective}</p>
        </div>
        <div className="hero-actions">
          {canManageRecord ? (
            <button className="primary-button" onClick={() => void handleSaveAll()}>
              Save Record
            </button>
          ) : null}
          {canContribute ? (
            <button className="secondary-button" onClick={() => void handleSaveKnowledgeOnly()}>
              Save SI Notes
            </button>
          ) : null}
          {canContribute ? (
            <button className="secondary-button" onClick={() => void handleSyncHistory()}>
              Backfill Evidence
            </button>
          ) : null}
          {canContribute ? (
            <button className="secondary-button" onClick={() => void handleRunEvaluation()}>
              Run Evaluation
            </button>
          ) : null}
          {canContribute ? (
            <button className="secondary-button" onClick={() => void handleRunKpiResearch()}>
              Run KPI Research
            </button>
          ) : null}
          {canManageRecord ? (
            <button className="ghost-button" onClick={() => void handleArchive()}>
              Archive
            </button>
          ) : null}
        </div>
      </section>

      {status ? <div className="muted">{status}</div> : null}

      <section className="notice-card notice-info">
        <strong>Access Model</strong>
        <p className="muted">
          {canManageRecord
            ? "You have executive-level access. You can update the SI record, ownership, ranking, and evaluation instructions."
            : canContribute
              ? "You have participant access to this SI. You can add SI-specific instructions, tune run settings, backfill evidence, and request KPI analysis."
              : "You have read-only access to this SI. You can review the evidence and opinions, but not change the configuration."}
        </p>
      </section>

      {canManageRecord ? (
      <section className="panel">
        <div className="section-header">
          <h2>Core Record</h2>
        </div>
        <div className="form-grid">
          <input
            value={initiative.code}
            onChange={(event) => setInitiative({ ...initiative, code: event.target.value })}
            placeholder="Code"
          />
          <input
            value={initiative.title}
            onChange={(event) => setInitiative({ ...initiative, title: event.target.value })}
            placeholder="Title"
          />
          <input
            value={initiative.group}
            onChange={(event) => setInitiative({ ...initiative, group: event.target.value })}
            placeholder="Group"
          />
          <input
            value={initiative.targetCadence}
            onChange={(event) => setInitiative({ ...initiative, targetCadence: event.target.value })}
            placeholder="Cadence"
          />
          <input
            value={initiative.updateType}
            onChange={(event) => setInitiative({ ...initiative, updateType: event.target.value })}
            placeholder="Update type"
          />
          <input
            value={initiative.stage}
            onChange={(event) => setInitiative({ ...initiative, stage: event.target.value })}
            placeholder="Stage"
          />
          <input
            value={initiative.lClass}
            onChange={(event) => setInitiative({ ...initiative, lClass: event.target.value })}
            placeholder="L Class"
          />
          <input
            value={initiative.impactType}
            onChange={(event) => setInitiative({ ...initiative, impactType: event.target.value })}
            placeholder="Impact type"
          />
          <textarea
            value={initiative.objective}
            onChange={(event) => setInitiative({ ...initiative, objective: event.target.value })}
            placeholder="Objective"
          />
          <textarea
            value={initiative.progress}
            onChange={(event) => setInitiative({ ...initiative, progress: event.target.value })}
            placeholder="Progress"
          />
          <textarea
            value={initiative.leadPerformance}
            onChange={(event) =>
              setInitiative({ ...initiative, leadPerformance: event.target.value })
            }
            placeholder="Lead performance"
          />
          <textarea
            value={initiative.administrationHealth}
            onChange={(event) =>
              setInitiative({ ...initiative, administrationHealth: event.target.value })
            }
            placeholder="Administration health"
          />
        </div>
      </section>
      ) : null}

      {canManageRecord ? (
      <section className="panel">
        <div className="section-header">
          <h2>People</h2>
          <div className="button-row">
            <button
              className="secondary-button"
              onClick={() =>
                setInitiative({
                  ...initiative,
                  people: [
                    ...initiative.people,
                    {
                      id: `temp-${Date.now()}`,
                      role: "other_invitee",
                      displayName: "",
                      email: null,
                      sortOrder: initiative.people.length,
                      sourceType: "local",
                      directorySource: "legacy_local",
                      directoryResolved: true,
                    },
                  ],
                })
              }
            >
              Add Person
            </button>
          </div>
        </div>
        <div className="notice-card notice-info">
          <strong>Workspace Directory</strong>
          <p className="muted">
            T3OS is the canonical directory for workspace contacts and members. Add executive and SI
            participants from the staged workspace when available, then keep the SI-specific role mapping here.
          </p>
          <div className="form-grid">
            <select
              value={selectedPlatformContactId}
              disabled={!canUsePlatformDirectory || workspaceContacts.length === 0}
              onChange={(event) => setSelectedPlatformContactId(event.target.value)}
            >
              <option value="">Select a workspace contact</option>
              {workspaceContacts.map((contact) => (
                <option key={contact.id} value={contact.id}>
                  {contact.name}
                  {contact.email ? ` • ${contact.email}` : ""}
                  {contact.role ? ` • ${contact.role}` : ""}
                </option>
              ))}
            </select>
            <select
              value={selectedPlatformRole}
              onChange={(event) =>
                setSelectedPlatformRole(
                  event.target.value as InitiativeDetail["people"][number]["role"],
                )
              }
            >
              <option value="exec_owner">Exec Owner</option>
              <option value="group_owner">Group Owner</option>
              <option value="initiative_owner">Initiative Owner</option>
              <option value="si_analytics_owner">SI Analytics Owner</option>
              <option value="sales_lead">Sales Lead</option>
              <option value="ops_lead">Ops Lead</option>
              <option value="analytics_lead">Analytics Lead</option>
              <option value="pm">PM</option>
              <option value="other_invitee">Other Invitee</option>
            </select>
            <button
              className="secondary-button"
              disabled={!selectedPlatformContactId || !canUsePlatformDirectory}
              onClick={() => handleAddWorkspacePerson()}
            >
              Add From T3OS
            </button>
          </div>
          <div className="form-grid" style={{ marginTop: "0.75rem" }}>
            <input
              value={newPlatformContact.name}
              disabled={!canUsePlatformDirectory}
              onChange={(event) =>
                setNewPlatformContact((current) => ({ ...current, name: event.target.value }))
              }
              placeholder="New T3OS contact name"
            />
            <input
              value={newPlatformContact.email}
              disabled={!canUsePlatformDirectory}
              onChange={(event) =>
                setNewPlatformContact((current) => ({ ...current, email: event.target.value }))
              }
              placeholder="New T3OS contact email"
            />
            <select
              value={newPlatformContact.businessId}
              disabled={!canUsePlatformDirectory || workspaceBusinesses.length === 0}
              onChange={(event) =>
                setNewPlatformContact((current) => ({ ...current, businessId: event.target.value }))
              }
            >
              <option value="">Select a business</option>
              {workspaceBusinesses.map((business) => (
                <option key={business.id} value={business.id}>
                  {business.name}
                </option>
              ))}
            </select>
            <input
              value={newPlatformContact.phone}
              disabled={!canUsePlatformDirectory}
              onChange={(event) =>
                setNewPlatformContact((current) => ({ ...current, phone: event.target.value }))
              }
              placeholder="Phone (optional)"
            />
            <button
              className="secondary-button"
              disabled={
                !canUsePlatformDirectory ||
                !newPlatformContact.name.trim() ||
                !newPlatformContact.email.trim() ||
                !newPlatformContact.businessId
              }
              onClick={() => void handleCreateWorkspaceContact()}
            >
              Create In T3OS
            </button>
          </div>
          <p className="muted">
            {workspaceDirectoryStatus ||
              (canAccessPlatformDirectory(currentUser)
                ? "Open inside T3OS staging to load workspace contacts."
                : "Only executive users can sync the workspace directory into SI ownership management.")}
          </p>
        </div>
        <div className="stack-list">
          {initiative.people.map((person, index) => (
            <div className="stack-list" key={person.id}>
              <div className="row-grid">
                <select
                  value={person.role}
                  onChange={(event) => {
                    const next = [...initiative.people];
                    next[index] = { ...person, role: event.target.value as typeof person.role };
                    setInitiative({ ...initiative, people: next });
                  }}
                >
                  <option value="exec_owner">Exec Owner</option>
                  <option value="group_owner">Group Owner</option>
                  <option value="initiative_owner">Initiative Owner</option>
                  <option value="si_analytics_owner">SI Analytics Owner</option>
                  <option value="sales_lead">Sales Lead</option>
                  <option value="ops_lead">Ops Lead</option>
                  <option value="analytics_lead">Analytics Lead</option>
                  <option value="pm">PM</option>
                  <option value="other_invitee">Other Invitee</option>
                </select>
                <input
                  value={person.displayName}
                  disabled={person.directorySource === "t3os"}
                  onChange={(event) => {
                    const next = [...initiative.people];
                    next[index] = { ...person, displayName: event.target.value };
                    setInitiative({ ...initiative, people: next });
                  }}
                  placeholder={person.directorySource === "t3os" ? "Hydrated from T3OS" : "Name"}
                />
                <input
                  value={person.email ?? ""}
                  disabled={person.directorySource === "t3os"}
                  onChange={(event) => {
                    const next = [...initiative.people];
                    next[index] = { ...person, email: event.target.value || null };
                    setInitiative({ ...initiative, people: next });
                  }}
                  placeholder={person.directorySource === "t3os" ? "Hydrated from T3OS" : "Email"}
                />
              </div>
              <p className="muted">
                Source: {person.directorySource === "t3os" ? "T3OS workspace" : "Local SI record"}
                {person.directorySource === "t3os"
                  ? person.directoryResolved === false
                    ? " • unresolved"
                    : " • resolved"
                  : ""}
                {person.t3osContactId ? ` • Contact ${person.t3osContactId}` : ""}
                {person.t3osWorkspaceMemberId ? ` • Member ${person.t3osWorkspaceMemberId}` : ""}
              </p>
            </div>
          ))}
        </div>
      </section>
      ) : null}

      {canManageRecord ? (
      <section className="panel">
        <div className="section-header">
          <h2>Links</h2>
          <button
            className="secondary-button"
            onClick={() =>
              setInitiative({
                ...initiative,
                links: [
                  ...initiative.links,
                  {
                    id: `temp-${Date.now()}`,
                    linkType: "other",
                    label: "",
                    url: "",
                    sortOrder: initiative.links.length,
                  },
                ],
              })
            }
          >
            Add Link
          </button>
        </div>
        <div className="stack-list">
          {initiative.links.map((link, index) => (
            <div className="row-grid" key={link.id}>
              <select
                value={link.linkType}
                onChange={(event) => {
                  const next = [...initiative.links];
                  next[index] = { ...link, linkType: event.target.value as typeof link.linkType };
                  setInitiative({ ...initiative, links: next });
                }}
              >
                <option value="folder">Folder</option>
                <option value="channel">Slack Channel</option>
                <option value="playbook">Playbook</option>
                <option value="dashboard">Dashboard</option>
                <option value="other">Other</option>
              </select>
              <input
                value={link.label}
                onChange={(event) => {
                  const next = [...initiative.links];
                  next[index] = { ...link, label: event.target.value };
                  setInitiative({ ...initiative, links: next });
                }}
                placeholder="Label"
              />
              <input
                value={link.url}
                onChange={(event) => {
                  const next = [...initiative.links];
                  next[index] = { ...link, url: event.target.value };
                  setInitiative({ ...initiative, links: next });
                }}
                placeholder="URL"
              />
            </div>
          ))}
        </div>
      </section>
      ) : null}

      {canManageRecord ? (
      <section className="panel">
        <div className="section-header">
          <h2>Period Snapshots</h2>
          <button
            className="secondary-button"
            onClick={() =>
              setInitiative({
                ...initiative,
                snapshots: [
                  ...initiative.snapshots,
                  {
                    id: `temp-${Date.now()}`,
                    periodKey: "",
                    category: "financial",
                    status: "",
                    baselineValue: "",
                    bookedValue: "",
                  },
                ],
              })
            }
          >
            Add Snapshot
          </button>
        </div>
        <div className="stack-list">
          {initiative.snapshots.map((snapshot, index) => (
            <div className="row-grid wide" key={snapshot.id}>
              <input
                value={snapshot.periodKey}
                onChange={(event) => {
                  const next = [...initiative.snapshots];
                  next[index] = { ...snapshot, periodKey: event.target.value };
                  setInitiative({ ...initiative, snapshots: next });
                }}
                placeholder="Period key"
              />
              <select
                value={snapshot.category}
                onChange={(event) => {
                  const next = [...initiative.snapshots];
                  next[index] = {
                    ...snapshot,
                    category: event.target.value as typeof snapshot.category,
                  };
                  setInitiative({ ...initiative, snapshots: next });
                }}
              >
                <option value="financial">Financial</option>
                <option value="kpi">KPI</option>
              </select>
              <input
                value={snapshot.status}
                onChange={(event) => {
                  const next = [...initiative.snapshots];
                  next[index] = { ...snapshot, status: event.target.value };
                  setInitiative({ ...initiative, snapshots: next });
                }}
                placeholder="Status"
              />
              <input
                value={snapshot.baselineValue}
                onChange={(event) => {
                  const next = [...initiative.snapshots];
                  next[index] = { ...snapshot, baselineValue: event.target.value };
                  setInitiative({ ...initiative, snapshots: next });
                }}
                placeholder="Baseline value"
              />
              <input
                value={snapshot.bookedValue}
                onChange={(event) => {
                  const next = [...initiative.snapshots];
                  next[index] = { ...snapshot, bookedValue: event.target.value };
                  setInitiative({ ...initiative, snapshots: next });
                }}
                placeholder="Booked value"
              />
            </div>
          ))}
        </div>
      </section>
      ) : null}

      <section className="panel">
        <div className="section-header">
          <h2>Initiative Knowledge</h2>
          {canContribute ? (
            <button className="secondary-button" onClick={() => void handleSaveKnowledgeOnly()}>
              Save Notes
            </button>
          ) : null}
        </div>
        <textarea
          className="markdown-editor"
          value={initiative.knowledgeDocument?.content ?? ""}
          readOnly={!canContribute}
          onChange={(event) =>
            setInitiative({
              ...initiative,
              knowledgeDocument: {
                id: initiative.knowledgeDocument?.id ?? "",
                title: initiative.knowledgeDocument?.title ?? `${initiative.code} ${initiative.title} Notes`,
                slug:
                  initiative.knowledgeDocument?.slug ??
                  `initiative-${initiative.code.toLowerCase()}-${initiative.title
                    .toLowerCase()
                    .replace(/\s+/g, "-")}`,
                content: event.target.value,
                version: initiative.knowledgeDocument?.version ?? 1,
                updatedAt: initiative.knowledgeDocument?.updatedAt ?? new Date().toISOString(),
              },
            })
          }
        />
        {!canContribute ? (
          <p className="muted">
            Initiative-specific notes are editable by SI participants and executives.
          </p>
        ) : null}
      </section>

      {canContribute ? (
        <section className="panel">
          <div className="section-header">
            <h2>SI Run Config</h2>
            <button className="secondary-button" onClick={() => void handleSaveRunConfig()}>
              Save Run Config
            </button>
          </div>
          <div className="form-grid">
            <select
              value={initiative.runConfig?.cadenceMode ?? "manual"}
              onChange={(event) =>
                setInitiative({
                  ...initiative,
                  runConfig: {
                    id: initiative.runConfig?.id ?? "draft-run-config",
                    cadenceMode: event.target.value as NonNullable<InitiativeDetail["runConfig"]>["cadenceMode"],
                    cadenceDetail: initiative.runConfig?.cadenceDetail ?? "",
                    alertThresholds:
                      initiative.runConfig?.alertThresholds ?? {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      },
                    customKpiRulesMarkdown: initiative.runConfig?.customKpiRulesMarkdown ?? "",
                    customInstructionsMarkdown: initiative.runConfig?.customInstructionsMarkdown ?? "",
                    goodLooksLikeMarkdown: initiative.runConfig?.goodLooksLikeMarkdown ?? "",
                    ownerNotesMarkdown: initiative.runConfig?.ownerNotesMarkdown ?? "",
                    updatedByType: initiative.runConfig?.updatedByType ?? currentUser?.type ?? "human",
                    updatedById: initiative.runConfig?.updatedById ?? currentUser?.id ?? "local-dev-user",
                    updatedAt: initiative.runConfig?.updatedAt ?? new Date().toISOString(),
                  },
                })
              }
            >
              <option value="manual">Manual</option>
              <option value="daily">Daily</option>
              <option value="weekly">Weekly</option>
              <option value="monthly">Monthly</option>
            </select>
            <input
              value={initiative.runConfig?.cadenceDetail ?? ""}
              onChange={(event) =>
                setInitiative({
                  ...initiative,
                  runConfig: {
                    ...(initiative.runConfig ?? {
                      id: "draft-run-config",
                      cadenceMode: "manual",
                      cadenceDetail: "",
                      alertThresholds: {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      },
                      customKpiRulesMarkdown: "",
                      customInstructionsMarkdown: "",
                      goodLooksLikeMarkdown: "",
                      ownerNotesMarkdown: "",
                      updatedByType: currentUser?.type ?? "human",
                      updatedById: currentUser?.id ?? "local-dev-user",
                      updatedAt: new Date().toISOString(),
                    }),
                    cadenceDetail: event.target.value,
                  },
                })
              }
              placeholder="Cadence detail"
            />
            <input
              type="number"
              value={initiative.runConfig?.alertThresholds.maxTrackerStalenessDays ?? ""}
              onChange={(event) =>
                setInitiative({
                  ...initiative,
                  runConfig: {
                    ...(initiative.runConfig ?? {
                      id: "draft-run-config",
                      cadenceMode: "manual",
                      cadenceDetail: "",
                      alertThresholds: {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      },
                      customKpiRulesMarkdown: "",
                      customInstructionsMarkdown: "",
                      goodLooksLikeMarkdown: "",
                      ownerNotesMarkdown: "",
                      updatedByType: currentUser?.type ?? "human",
                      updatedById: currentUser?.id ?? "local-dev-user",
                      updatedAt: new Date().toISOString(),
                    }),
                    alertThresholds: {
                      ...(initiative.runConfig?.alertThresholds ?? {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      }),
                      maxTrackerStalenessDays: event.target.value ? Number(event.target.value) : null,
                    },
                  },
                })
              }
              placeholder="Max tracker staleness days"
            />
            <input
              type="number"
              value={initiative.runConfig?.alertThresholds.attentionBlockerCount ?? ""}
              onChange={(event) =>
                setInitiative({
                  ...initiative,
                  runConfig: {
                    ...(initiative.runConfig ?? {
                      id: "draft-run-config",
                      cadenceMode: "manual",
                      cadenceDetail: "",
                      alertThresholds: {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      },
                      customKpiRulesMarkdown: "",
                      customInstructionsMarkdown: "",
                      goodLooksLikeMarkdown: "",
                      ownerNotesMarkdown: "",
                      updatedByType: currentUser?.type ?? "human",
                      updatedById: currentUser?.id ?? "local-dev-user",
                      updatedAt: new Date().toISOString(),
                    }),
                    alertThresholds: {
                      ...(initiative.runConfig?.alertThresholds ?? {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      }),
                      attentionBlockerCount: event.target.value ? Number(event.target.value) : null,
                    },
                  },
                })
              }
              placeholder="Attention blocker count"
            />
            <input
              type="number"
              value={initiative.runConfig?.alertThresholds.minimumSlackMessages30d ?? ""}
              onChange={(event) =>
                setInitiative({
                  ...initiative,
                  runConfig: {
                    ...(initiative.runConfig ?? {
                      id: "draft-run-config",
                      cadenceMode: "manual",
                      cadenceDetail: "",
                      alertThresholds: {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      },
                      customKpiRulesMarkdown: "",
                      customInstructionsMarkdown: "",
                      goodLooksLikeMarkdown: "",
                      ownerNotesMarkdown: "",
                      updatedByType: currentUser?.type ?? "human",
                      updatedById: currentUser?.id ?? "local-dev-user",
                      updatedAt: new Date().toISOString(),
                    }),
                    alertThresholds: {
                      ...(initiative.runConfig?.alertThresholds ?? {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      }),
                      minimumSlackMessages30d: event.target.value ? Number(event.target.value) : null,
                    },
                  },
                })
              }
              placeholder="Minimum Slack messages in 30d"
            />
            <input
              type="number"
              value={initiative.runConfig?.alertThresholds.minimumDriveUpdates30d ?? ""}
              onChange={(event) =>
                setInitiative({
                  ...initiative,
                  runConfig: {
                    ...(initiative.runConfig ?? {
                      id: "draft-run-config",
                      cadenceMode: "manual",
                      cadenceDetail: "",
                      alertThresholds: {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      },
                      customKpiRulesMarkdown: "",
                      customInstructionsMarkdown: "",
                      goodLooksLikeMarkdown: "",
                      ownerNotesMarkdown: "",
                      updatedByType: currentUser?.type ?? "human",
                      updatedById: currentUser?.id ?? "local-dev-user",
                      updatedAt: new Date().toISOString(),
                    }),
                    alertThresholds: {
                      ...(initiative.runConfig?.alertThresholds ?? {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      }),
                      minimumDriveUpdates30d: event.target.value ? Number(event.target.value) : null,
                    },
                  },
                })
              }
              placeholder="Minimum Drive updates in 30d"
            />
            <input
              type="number"
              step="0.05"
              min="0"
              max="1"
              value={initiative.runConfig?.alertThresholds.minimumOnTrackScore ?? ""}
              onChange={(event) =>
                setInitiative({
                  ...initiative,
                  runConfig: {
                    ...(initiative.runConfig ?? {
                      id: "draft-run-config",
                      cadenceMode: "manual",
                      cadenceDetail: "",
                      alertThresholds: {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      },
                      customKpiRulesMarkdown: "",
                      customInstructionsMarkdown: "",
                      goodLooksLikeMarkdown: "",
                      ownerNotesMarkdown: "",
                      updatedByType: currentUser?.type ?? "human",
                      updatedById: currentUser?.id ?? "local-dev-user",
                      updatedAt: new Date().toISOString(),
                    }),
                    alertThresholds: {
                      ...(initiative.runConfig?.alertThresholds ?? {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      }),
                      minimumOnTrackScore: event.target.value ? Number(event.target.value) : null,
                    },
                  },
                })
              }
              placeholder="Minimum on-track score"
            />
            <textarea
              value={initiative.runConfig?.customInstructionsMarkdown ?? ""}
              onChange={(event) =>
                setInitiative({
                  ...initiative,
                  runConfig: {
                    ...(initiative.runConfig ?? {
                      id: "draft-run-config",
                      cadenceMode: "manual",
                      cadenceDetail: "",
                      alertThresholds: {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      },
                      customKpiRulesMarkdown: "",
                      customInstructionsMarkdown: "",
                      goodLooksLikeMarkdown: "",
                      ownerNotesMarkdown: "",
                      updatedByType: currentUser?.type ?? "human",
                      updatedById: currentUser?.id ?? "local-dev-user",
                      updatedAt: new Date().toISOString(),
                    }),
                    customInstructionsMarkdown: event.target.value,
                  },
                })
              }
              placeholder="Custom instructions for how the SI should be analyzed"
            />
            <textarea
              value={initiative.runConfig?.goodLooksLikeMarkdown ?? ""}
              onChange={(event) =>
                setInitiative({
                  ...initiative,
                  runConfig: {
                    ...(initiative.runConfig ?? {
                      id: "draft-run-config",
                      cadenceMode: "manual",
                      cadenceDetail: "",
                      alertThresholds: {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      },
                      customKpiRulesMarkdown: "",
                      customInstructionsMarkdown: "",
                      goodLooksLikeMarkdown: "",
                      ownerNotesMarkdown: "",
                      updatedByType: currentUser?.type ?? "human",
                      updatedById: currentUser?.id ?? "local-dev-user",
                      updatedAt: new Date().toISOString(),
                    }),
                    goodLooksLikeMarkdown: event.target.value,
                  },
                })
              }
              placeholder="What good looks like for this SI"
            />
            <textarea
              value={initiative.runConfig?.customKpiRulesMarkdown ?? ""}
              onChange={(event) =>
                setInitiative({
                  ...initiative,
                  runConfig: {
                    ...(initiative.runConfig ?? {
                      id: "draft-run-config",
                      cadenceMode: "manual",
                      cadenceDetail: "",
                      alertThresholds: {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      },
                      customKpiRulesMarkdown: "",
                      customInstructionsMarkdown: "",
                      goodLooksLikeMarkdown: "",
                      ownerNotesMarkdown: "",
                      updatedByType: currentUser?.type ?? "human",
                      updatedById: currentUser?.id ?? "local-dev-user",
                      updatedAt: new Date().toISOString(),
                    }),
                    customKpiRulesMarkdown: event.target.value,
                  },
                })
              }
              placeholder="How KPIs should be calculated or interpreted for this SI"
            />
            <textarea
              value={initiative.runConfig?.ownerNotesMarkdown ?? ""}
              onChange={(event) =>
                setInitiative({
                  ...initiative,
                  runConfig: {
                    ...(initiative.runConfig ?? {
                      id: "draft-run-config",
                      cadenceMode: "manual",
                      cadenceDetail: "",
                      alertThresholds: {
                        maxTrackerStalenessDays: null,
                        attentionBlockerCount: null,
                        minimumSlackMessages30d: null,
                        minimumDriveUpdates30d: null,
                        minimumOnTrackScore: null,
                      },
                      customKpiRulesMarkdown: "",
                      customInstructionsMarkdown: "",
                      goodLooksLikeMarkdown: "",
                      ownerNotesMarkdown: "",
                      updatedByType: currentUser?.type ?? "human",
                      updatedById: currentUser?.id ?? "local-dev-user",
                      updatedAt: new Date().toISOString(),
                    }),
                    ownerNotesMarkdown: event.target.value,
                  },
                })
              }
              placeholder="Additional owner/operator notes for this SI"
            />
          </div>
        </section>
      ) : null}

      {canContribute ? (
        <section className="panel">
          <div className="section-header">
            <h2>SI Instructions & Detail Posts</h2>
          </div>
          <div className="stack-list">
            {initiative.annotations.map((annotation) => (
              <article className="history-item evidence-item" key={annotation.id}>
                <div className="section-header">
                  <div>
                    <div className="metric-label">{annotation.annotationType.replace(/_/g, " ")}</div>
                    <strong>{annotation.title}</strong>
                  </div>
                  {canManageRecord ||
                  (currentUser &&
                    annotation.createdByType === currentUser.type &&
                    annotation.createdById === currentUser.id) ? (
                    <button className="ghost-button" onClick={() => void handleDeleteAnnotation(annotation.id)}>
                      Delete
                    </button>
                  ) : null}
                </div>
                <div>{annotation.content}</div>
                <div className="muted">
                  {annotation.createdByType} • {new Date(annotation.updatedAt).toLocaleString()}
                </div>
              </article>
            ))}

            <article className="setup-card">
              <div className="form-grid">
                <select
                  value={annotationDraft.annotationType}
                  onChange={(event) =>
                    setAnnotationDraft({
                      ...annotationDraft,
                      annotationType: event.target.value as typeof annotationDraft.annotationType,
                    })
                  }
                >
                  <option value="analysis_instruction">Analysis Instruction</option>
                  <option value="operating_instruction">Operating Instruction</option>
                  <option value="detail_note">Detail Note</option>
                  <option value="kpi_suggestion">KPI Suggestion</option>
                </select>
                <input
                  value={annotationDraft.title}
                  onChange={(event) => setAnnotationDraft({ ...annotationDraft, title: event.target.value })}
                  placeholder="Instruction title"
                />
                <textarea
                  value={annotationDraft.content}
                  onChange={(event) => setAnnotationDraft({ ...annotationDraft, content: event.target.value })}
                  placeholder="Markdown-style detail or instruction for how this SI should be operated or analyzed"
                />
              </div>
              <div className="button-row">
                <button className="secondary-button" onClick={() => void handleAddAnnotation()}>
                  Post Detail
                </button>
              </div>
            </article>
          </div>
        </section>
      ) : null}

      <section className="panel">
        <div className="section-header">
          <h2>Initiative Tracker</h2>
          <span className="muted">
            {tracker.parsedAt ? `Parsed ${new Date(tracker.parsedAt).toLocaleString()}` : "No tracker parsed yet"}
          </span>
        </div>
        {!tracker.trackerFileId ? (
          <p className="muted">No parsed initiative tracker is stored yet for this SI.</p>
        ) : (
          <div className="stack-list">
            <article className="setup-card">
              <strong>{tracker.trackerName ?? "Tracker"}</strong>
              <div className="muted">{tracker.sheetName}</div>
              <div className="muted">
                {tracker.summaryFields.length} summary fields • {tracker.items.length} parsed rows
              </div>
            </article>
            {tracker.summaryFields.length > 0 ? (
              <div className="table-wrap">
                <table className="data-table compact-table">
                  <thead>
                    <tr>
                      <th>Field</th>
                      <th>Value</th>
                    </tr>
                  </thead>
                  <tbody>
                    {tracker.summaryFields.map((field) => (
                      <tr key={field.id}>
                        <td>{field.label}</td>
                        <td>{field.value || <span className="muted">Blank</span>}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : null}
            {tracker.items.length > 0 ? (
              <div className="table-wrap">
                <table className="data-table compact-table">
                  <thead>
                    <tr>
                      <th>Row</th>
                      <th>Type</th>
                      <th>Description</th>
                      <th>Status</th>
                      <th>Last Edited</th>
                      <th>Submitted By</th>
                    </tr>
                  </thead>
                  <tbody>
                    {tracker.items.slice(0, 12).map((item) => (
                      <tr key={item.id}>
                        <td>{item.rowNumber}</td>
                        <td>{item.itemType ?? <span className="muted">-</span>}</td>
                        <td>{item.description}</td>
                        <td>{item.status ?? <span className="muted">-</span>}</td>
                        <td>{item.lastEdited ?? <span className="muted">-</span>}</td>
                        <td>{item.submittedBy ?? <span className="muted">-</span>}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : null}
          </div>
        )}
      </section>

      <section className="panel">
        <div className="section-header">
          <h2>KPI Research</h2>
          <span className="muted">
            {kpiResearch.researchedAt
              ? `Updated ${new Date(kpiResearch.researchedAt).toLocaleString()}`
              : "No KPI research yet"}
          </span>
        </div>
        {kpiResearch.findings.length === 0 ? (
          <p className="muted">Run KPI research to store tracker KPIs, analytics references, Snowflake discovery, and proposed KPIs.</p>
        ) : (
          <div className="stack-list">
            <section className="modal-section">
              <h3>Current KPI View</h3>
              {trackerCurrentFindings.length === 0 ? (
                <p className="muted">No current tracker KPIs are stored yet.</p>
              ) : (
                <div className="stack-list">
                  {trackerCurrentFindings.map((finding) => (
                    <article className="history-item evidence-item" key={finding.id}>
                      <div className="metric-label">
                        {finding.findingClass.replace(/_/g, " ")} • {finding.sourceType.replace(/_/g, " ")}
                      </div>
                      <strong>{finding.label}</strong>
                      <div>
                        {finding.metricValue ? (
                          <span>
                            {finding.metricValue}
                            {finding.unit ? ` ${finding.unit}` : ""}
                          </span>
                        ) : (
                          <span className="muted">No validated current value stored</span>
                        )}
                      </div>
                      {finding.narrative ? <div>{finding.narrative}</div> : null}
                    </article>
                  ))}
                </div>
              )}
            </section>

            <section className="modal-section">
              <h3>Analytics Support</h3>
              {analyticsReferenceFindings.length === 0 ? (
                <p className="muted">No ranked analytics references are stored yet.</p>
              ) : (
                <div className="stack-list">
                  {analyticsReferenceFindings.slice(0, 10).map((finding) => (
                    <article className="history-item evidence-item" key={finding.id}>
                      <div className="metric-label">
                        {finding.sourceType.replace(/_/g, " ")} • score {String(finding.provenance.score ?? "-")}
                      </div>
                      <strong>{finding.label}</strong>
                      {finding.narrative ? <div>{finding.narrative}</div> : null}
                      {finding.sourceRef ? <div className="muted">{finding.sourceRef}</div> : null}
                    </article>
                  ))}
                </div>
              )}
            </section>

            <section className="modal-section">
              <h3>Proposed KPI Improvements</h3>
              {proposalFindings.length === 0 ? (
                <p className="muted">No KPI proposals are stored yet.</p>
              ) : (
                <div className="stack-list">
                  {proposalFindings.map((finding) => (
                    <article className="history-item evidence-item" key={finding.id}>
                      <div className="metric-label">{finding.sourceType.replace(/_/g, " ")}</div>
                      <strong>{finding.label}</strong>
                      {finding.narrative ? <div>{finding.narrative}</div> : null}
                    </article>
                  ))}
                </div>
              )}
            </section>
          </div>
        )}
      </section>

      <section className="panel">
        <div className="section-header">
          <h2>Slack Evidence</h2>
          <button className="secondary-button" onClick={() => void refreshSlackEvidence()}>
            Refresh Slack Preview
          </button>
        </div>
        {!slackEvidence.connected ? (
          <p className="muted">Slack is not connected for this workspace yet.</p>
        ) : slackEvidence.channels.length === 0 ? (
          <p className="muted">No Slack channel links are mapped for this initiative.</p>
        ) : (
          <div className="stack-list">
            {slackEvidence.issues.length > 0 ? (
              <article className="notice-card notice-warning">
                <strong>Slack sync issues</strong>
                <ul className="flat-list">
                  {slackEvidence.issues.slice(0, 6).map((issue) => (
                    <li key={issue.id}>
                      {issue.errorCode}: {issue.message}
                    </li>
                  ))}
                </ul>
              </article>
            ) : null}
            {slackEvidence.channels.map((channel) => (
              <article className="setup-card" key={channel.channelId}>
                <div className="section-header">
                  <div>
                    <strong>{channel.channelName ? `#${channel.channelName}` : channel.label}</strong>
                    <div className="muted">{channel.url}</div>
                  </div>
                  <span className={`status-pill ${channel.readable ? "status-on_track" : "status-off_track"}`}>
                    {channel.readable ? `${channel.messages.length} recent messages` : "Unreadable"}
                  </span>
                </div>
                {channel.error ? <p className="muted">{channel.error}</p> : null}
                {channel.messages.length > 0 ? (
                  <div className="stack-list">
                    {channel.messages.slice(0, 4).map((message) => (
                        <div className="history-item evidence-item" key={message.ts}>
                          <div className="muted">
                            {new Date(Number(message.ts.split(".")[0]) * 1000).toLocaleString()}
                            {message.userId ? ` • ${message.userId}` : ""}
                          </div>
                          <div>{message.text}</div>
                          {message.attachments.length > 0 ? (
                            <div className="muted">
                              Attachments: {message.attachments.map((attachment) => attachment.name ?? attachment.title ?? attachment.id).join(", ")}
                            </div>
                          ) : null}
                          {message.replies.length > 0 ? (
                            <div className="muted">
                              {message.replies.length} thread repl{message.replies.length === 1 ? "y" : "ies"}
                          </div>
                        ) : null}
                      </div>
                    ))}
                  </div>
                ) : null}
              </article>
            ))}
          </div>
        )}
      </section>

      <section className="panel">
        <div className="section-header">
          <h2>Google Evidence</h2>
          <button className="secondary-button" onClick={() => void refreshGoogleEvidence()}>
            Refresh Google Preview
          </button>
        </div>
        {!googleEvidence.connected ? (
          <p className="muted">Google is not connected for this workspace yet.</p>
        ) : googleEvidence.files.length === 0 ? (
          <p className="muted">No Google Drive or Sheet links are mapped for this initiative.</p>
        ) : (
          <div className="stack-list">
            {googleEvidence.issues.length > 0 ? (
              <article className="notice-card notice-warning">
                <strong>Google sync issues</strong>
                <ul className="flat-list">
                  {googleEvidence.issues.slice(0, 6).map((issue) => (
                    <li key={issue.id}>
                      {issue.errorCode}: {issue.message}
                    </li>
                  ))}
                </ul>
              </article>
            ) : null}
            {googleEvidence.files.map((file) => (
              <article className="setup-card" key={file.linkId}>
                <div className="section-header">
                  <div>
                    <strong>{file.name ?? file.label}</strong>
                    <div className="muted">{file.url}</div>
                  </div>
                  <span className={`status-pill ${file.readable ? "status-on_track" : "status-off_track"}`}>
                    {file.readable ? "Readable" : "Unreadable"}
                  </span>
                </div>
                {file.error ? <p className="muted">{file.error}</p> : null}
                {file.modifiedTime ? (
                  <div className="muted">
                    Last modified {new Date(file.modifiedTime).toLocaleString()}
                    {file.lastModifyingUser ? ` by ${file.lastModifyingUser}` : ""}
                  </div>
                ) : null}
                {file.revisions.length > 0 ? (
                  <div className="stack-list">
                    <h3>Recent Revisions</h3>
                    {file.revisions.map((revision) => (
                      <div className="history-item evidence-item" key={`${file.linkId}-${revision.id}`}>
                        <div>{revision.modifiedTime ? new Date(revision.modifiedTime).toLocaleString() : "Unknown time"}</div>
                        <div className="muted">{revision.lastModifyingUser ?? "Unknown editor"}</div>
                      </div>
                    ))}
                  </div>
                ) : null}
                {file.children.length > 0 ? (
                  <div className="stack-list">
                    <h3>Discovered Folder Files</h3>
                    {file.children.slice(0, 5).map((child) => (
                      <div className="history-item evidence-item" key={child.id}>
                        <strong>{child.name}</strong>
                        <div className="muted">
                          Depth {child.depth} • {child.crawlPath}
                        </div>
                        <div className="muted">
                          {child.modifiedTime ? new Date(child.modifiedTime).toLocaleString() : "Unknown time"}
                          {child.lastModifyingUser ? ` • ${child.lastModifyingUser}` : ""}
                        </div>
                        {child.revisions.length > 0 ? (
                          <div className="muted">Revisions captured: {child.revisions.length}</div>
                        ) : null}
                      </div>
                    ))}
                    {file.children.length > 5 ? (
                      <div className="muted">{file.children.length - 5} more descendant files captured in the sync.</div>
                    ) : null}
                  </div>
                ) : null}
              </article>
            ))}
          </div>
        )}
      </section>

      <OpinionPanel initiative={initiative} />
    </div>
  );
}
