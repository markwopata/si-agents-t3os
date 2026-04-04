import type { ApiToken, CurrentUser, TokenScope, WorkspaceMemberSummary } from "@si/domain";
import { useEffect, useMemo, useState } from "react";
import {
  createApiToken,
  deleteApiToken,
  getCurrentUser,
  listApiTokens,
  listPlatformWorkspaceMembers,
} from "../api/client";
import { getCurrentWorkspaceId } from "../lib/t3os";

const TOKEN_SCOPE_OPTIONS: Array<{ value: TokenScope; label: string; description: string }> = [
  {
    value: "read:initiatives",
    label: "Read initiatives",
    description: "Registry, details, ownership, and initiative metadata.",
  },
  {
    value: "write:initiatives",
    label: "Write initiatives",
    description: "Create, update, archive, and manage initiative mappings.",
  },
  {
    value: "read:knowledge",
    label: "Read knowledge",
    description: "Global and initiative markdown guidance.",
  },
  {
    value: "write:knowledge",
    label: "Write knowledge",
    description: "Update global or SI-specific markdown content.",
  },
  {
    value: "read:observations",
    label: "Read observations",
    description: "Assessment history, KPI outputs, and stored insight runs.",
  },
  {
    value: "write:observations",
    label: "Write observations",
    description: "Review or adjust stored assessment artifacts.",
  },
  {
    value: "read:platform",
    label: "Read platform",
    description: "T3OS-backed contacts, workspace members, and platform state.",
  },
  {
    value: "write:platform",
    label: "Write platform",
    description: "Manage T3OS-backed contacts and related platform records.",
  },
  {
    value: "run:agents",
    label: "Run agents",
    description: "Trigger SI assessment, evaluation, and portfolio actions.",
  },
  {
    value: "manage:tokens",
    label: "Manage tokens",
    description: "Create and revoke personal API tokens.",
  },
];

const DEFAULT_TOKEN_SCOPES: TokenScope[] = [
  "read:initiatives",
  "read:knowledge",
  "read:observations",
];

function formatDateTime(value: string | null): string {
  if (!value) {
    return "Never";
  }

  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return "Unknown";
  }

  return parsed.toLocaleString();
}

function getOwnerLabel(token: ApiToken): string {
  return token.ownerDisplayName ?? token.ownerEmail ?? token.ownerUserId ?? "Unknown owner";
}

export function ApiTokensPage() {
  const [status, setStatus] = useState<{ tone: "info" | "success" | "warning"; message: string } | null>(null);
  const [currentUser, setCurrentUser] = useState<CurrentUser | null>(null);
  const [tokens, setTokens] = useState<ApiToken[]>([]);
  const [workspaceMembers, setWorkspaceMembers] = useState<WorkspaceMemberSummary[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [label, setLabel] = useState("");
  const [selectedScopes, setSelectedScopes] = useState<TokenScope[]>(DEFAULT_TOKEN_SCOPES);
  const [revealedToken, setRevealedToken] = useState("");
  const [busyTokenId, setBusyTokenId] = useState("");
  const [search, setSearch] = useState("");
  const [creationMode, setCreationMode] = useState<"self" | "delegate">("self");
  const [selectedOwnerUserId, setSelectedOwnerUserId] = useState("");

  const isAdmin = currentUser?.type === "service_token" || currentUser?.appRole === "admin";
  const workspaceId = getCurrentWorkspaceId();

  async function load() {
    setLoading(true);
    setError("");

    try {
      const me = await getCurrentUser();
      setCurrentUser(me);
      const loadMembers =
        me.appRole === "admin" && workspaceId
          ? listPlatformWorkspaceMembers(workspaceId)
          : Promise.resolve({ workspaceId: workspaceId ?? "", items: [] });
      const [tokenItems, memberItems] = await Promise.all([
        listApiTokens(me.type === "service_token" || me.appRole === "admin"),
        loadMembers,
      ]);
      setTokens(tokenItems);
      setWorkspaceMembers(memberItems.items);
    } catch (caughtError) {
      setError(
        caughtError instanceof Error ? caughtError.message : "Unable to load API token inventory.",
      );
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void load();
  }, [workspaceId]);

  const sortedWorkspaceMembers = useMemo(
    () =>
      [...workspaceMembers].sort((left, right) => {
        const leftLabel = (left.user?.name ?? left.user?.email ?? left.userId).toLowerCase();
        const rightLabel = (right.user?.name ?? right.user?.email ?? right.userId).toLowerCase();
        return leftLabel.localeCompare(rightLabel);
      }),
    [workspaceMembers],
  );

  const selectedOwner = useMemo(
    () => sortedWorkspaceMembers.find((member) => member.userId === selectedOwnerUserId) ?? null,
    [selectedOwnerUserId, sortedWorkspaceMembers],
  );

  const createValidationMessage = useMemo(() => {
    if (!label.trim()) {
      return "Add a label so the token is easy to recognize later.";
    }
    if (creationMode === "delegate" && !selectedOwner) {
      return "Select the workspace user who should own this token.";
    }
    if (selectedScopes.length === 0) {
      return "Select at least one scope for the token.";
    }
    return "";
  }, [creationMode, label, selectedOwner, selectedScopes]);

  const visibleTokens = useMemo(() => {
    const searchValue = search.trim().toLowerCase();
    const source = [...tokens].sort((left, right) => {
      const ownerCompare = getOwnerLabel(left).localeCompare(getOwnerLabel(right));
      if (ownerCompare !== 0) {
        return ownerCompare;
      }
      return left.label.localeCompare(right.label);
    });

    if (!searchValue) {
      return source;
    }

    return source.filter((token) =>
      [
        token.label,
        token.ownerDisplayName ?? "",
        token.ownerEmail ?? "",
        token.ownerWorkspaceId ?? "",
        token.scopes.join(" "),
        token.tokenPreview,
      ]
        .join(" ")
        .toLowerCase()
        .includes(searchValue),
    );
  }, [search, tokens]);

  const myTokens = useMemo(
    () =>
      visibleTokens.filter((token) =>
        currentUser?.type === "service_token"
          ? true
          : token.ownerUserId === currentUser?.id,
      ),
    [currentUser?.id, currentUser?.type, visibleTokens],
  );

  const otherTokens = useMemo(
    () =>
      isAdmin
        ? visibleTokens.filter((token) => token.ownerUserId !== currentUser?.id)
        : [],
    [currentUser?.id, isAdmin, visibleTokens],
  );

  function toggleScope(scope: TokenScope) {
    setSelectedScopes((current) =>
      current.includes(scope)
        ? current.filter((value) => value !== scope)
        : [...current, scope],
    );
  }

  async function handleCreateToken() {
    if (!label.trim()) {
      setStatus({ tone: "warning", message: "Add a label so the token is easy to recognize later." });
      return;
    }

    if (creationMode === "delegate" && !selectedOwner) {
      setStatus({ tone: "warning", message: "Select the workspace user who should own this token." });
      return;
    }

    if (selectedScopes.length === 0) {
      setStatus({ tone: "warning", message: "Select at least one scope for the token." });
      return;
    }

    setStatus({ tone: "info", message: "Creating token..." });
    setRevealedToken("");

    try {
      const created = await createApiToken({
        label: label.trim(),
        scopes: selectedScopes,
        ...(creationMode === "delegate" && selectedOwner
          ? {
              ownerUserId: selectedOwner.userId,
              ownerEmail: selectedOwner.user?.email ?? undefined,
              ownerDisplayName: selectedOwner.user?.name ?? undefined,
              ownerWorkspaceId: workspaceId ?? undefined,
            }
          : {}),
      });
      setRevealedToken(created.token);
      setLabel("");
      setSelectedScopes(DEFAULT_TOKEN_SCOPES);
      setSelectedOwnerUserId("");
      setCreationMode("self");
      setStatus({
        tone: "success",
        message: "Token created. Copy it now because it will not be shown again.",
      });
      await load();
    } catch (caughtError) {
      setStatus({
        tone: "warning",
        message: caughtError instanceof Error ? caughtError.message : "Token creation failed.",
      });
    }
  }

  async function handleDeleteToken(token: ApiToken) {
    const confirmation = window.confirm(
      `Revoke "${token.label}" for ${getOwnerLabel(token)}? This cannot be undone.`,
    );

    if (!confirmation) {
      return;
    }

    setBusyTokenId(token.id);
    setStatus({ tone: "info", message: `Revoking ${token.label}...` });

    try {
      await deleteApiToken(token.id);
      setTokens((current) => current.filter((item) => item.id !== token.id));
      setStatus({
        tone: "success",
        message: `Revoked ${token.label}.`,
      });
      void load();
    } catch (caughtError) {
      setStatus({
        tone: "warning",
        message: caughtError instanceof Error ? caughtError.message : "Token revoke failed.",
      });
    } finally {
      setBusyTokenId("");
    }
  }

  async function handleCopyToken() {
    if (!revealedToken) {
      return;
    }

    try {
      await navigator.clipboard.writeText(revealedToken);
      setStatus({ tone: "success", message: "Token copied to clipboard." });
    } catch {
      setStatus({
        tone: "warning",
        message: "Copy failed. Select the token manually and copy it now.",
      });
    }
  }

  return (
    <div className="page-stack">
      <section className="hero-card panel-tonal compact">
        <div>
          <div className="eyebrow">API Access</div>
          <h2>User tokens</h2>
          <p>
            Create personal API tokens for agents and integrations. Admins can also audit and
            revoke tokens across the workspace.
          </p>
        </div>
      </section>

      {error ? (
        <section className="notice-card notice-warning">
          <strong>Token inventory unavailable.</strong>
          <p className="muted">{error}</p>
        </section>
      ) : null}

      {status ? (
        <section
          className={`notice-card ${
            status.tone === "success"
              ? "notice-success"
              : status.tone === "warning"
                ? "notice-warning"
                : "notice-info"
          }`}
        >
          <strong>API access</strong>
          <p className="muted">{status.message}</p>
        </section>
      ) : null}

      {revealedToken ? (
        <section className="panel">
          <div className="section-header">
            <div>
              <h2>Copy your new token now</h2>
              <p className="panel-subtitle">
                For safety, we only reveal the full token once at creation time.
              </p>
            </div>
            <button className="secondary-button" onClick={() => void handleCopyToken()}>
              Copy Token
            </button>
          </div>
          <div className="setup-code">{revealedToken}</div>
        </section>
      ) : null}

      <section className="token-page-grid">
        <article className="panel">
          <div className="section-header">
            <div>
              <h2>Create token</h2>
              <p className="panel-subtitle">
                {creationMode === "delegate"
                  ? "Admins can create a token owned by a selected workspace member. Final scopes are capped to that user's role."
                  : "The token can only request scopes your current role already has."}
              </p>
            </div>
          </div>

          <div className="notice-card notice-info">
            <strong>Workspace-bound</strong>
            <p className="muted">
              This token will be bound to the current T3OS workspace and can only be used for that
              workspace's token inventory and platform operations.
            </p>
          </div>

          {isAdmin ? (
            <div className="button-row token-creation-mode">
              <button
                className={creationMode === "self" ? "primary-button" : "ghost-button"}
                onClick={() => setCreationMode("self")}
              >
                Create For Me
              </button>
              <button
                className={creationMode === "delegate" ? "primary-button" : "ghost-button"}
                onClick={() => setCreationMode("delegate")}
              >
                Create For Workspace User
              </button>
            </div>
          ) : null}

          <div className="form-grid">
            <input
              value={label}
              placeholder="Example: Jabbok executive agent"
              onChange={(event) => setLabel(event.target.value)}
            />
            {isAdmin && creationMode === "delegate" ? (
              <select
                value={selectedOwnerUserId}
                onChange={(event) => setSelectedOwnerUserId(event.target.value)}
              >
                <option value="">Select a workspace member</option>
                {sortedWorkspaceMembers.map((member) => (
                  <option key={member.userId} value={member.userId}>
                    {member.user?.name ?? member.user?.email ?? member.userId}
                    {member.user?.email ? ` (${member.user.email})` : ""}
                  </option>
                ))}
              </select>
            ) : null}
          </div>

          {creationMode === "delegate" && selectedOwner ? (
            <div className="notice-card notice-info">
              <strong>Creating for {selectedOwner.user?.name ?? selectedOwner.user?.email ?? selectedOwner.userId}</strong>
              <p className="muted">
                {selectedOwner.user?.email ?? "No email available"} · Token ownership and role will
                be resolved from this workspace member.
              </p>
            </div>
          ) : null}

          {createValidationMessage ? (
            <div className="notice-card notice-warning">
              <strong>Before you create the token</strong>
              <p className="muted">{createValidationMessage}</p>
            </div>
          ) : null}

          <div className="token-scope-grid">
            {TOKEN_SCOPE_OPTIONS.map((scope) => {
              const checked = selectedScopes.includes(scope.value);
              const allowed = currentUser?.scopes?.includes(scope.value) ?? false;

              return (
                <label
                  key={scope.value}
                  className={`token-scope-card${checked ? " token-scope-card-selected" : ""}${allowed ? "" : " token-scope-card-disabled"}`}
                >
                  <input
                    type="checkbox"
                    checked={checked}
                    disabled={!allowed}
                    onChange={() => toggleScope(scope.value)}
                  />
                  <div className="token-scope-copy">
                    <strong>{scope.label}</strong>
                    <span>{scope.description}</span>
                  </div>
                </label>
              );
            })}
          </div>

          <div className="button-row">
            <button
              className="primary-button"
              onClick={() => void handleCreateToken()}
              disabled={Boolean(createValidationMessage)}
              title={createValidationMessage || "Create token"}
            >
              Create Token
            </button>
          </div>
        </article>

        <article className="panel">
          <div className="section-header">
            <div>
              <h2>{isAdmin ? "Workspace token inventory" : "Your tokens"}</h2>
              <p className="panel-subtitle">
                {isAdmin
                  ? "Admins can inspect every user-owned token in the workspace and revoke any one of them."
                  : "Review and revoke your existing tokens."}
              </p>
            </div>
          </div>

          <div className="filter-grid">
            <input
              type="search"
              value={search}
              placeholder={isAdmin ? "Search by owner, label, scope, or preview" : "Search your tokens"}
              onChange={(event) => setSearch(event.target.value)}
            />
          </div>

          {loading ? (
            <p className="muted">Loading token inventory...</p>
          ) : (
            <div className="page-stack">
              <div className="table-shell">
                <div className="table-wrap">
                  <table className="data-table compact-table">
                    <thead>
                      <tr>
                        {isAdmin ? <th>Owner</th> : null}
                        <th>Label</th>
                        <th>Scopes</th>
                        <th>Preview</th>
                        <th>Last used</th>
                        <th>Created</th>
                        <th aria-label="Actions" />
                      </tr>
                    </thead>
                    <tbody>
                      {myTokens.length === 0 && otherTokens.length === 0 ? (
                        <tr>
                          <td colSpan={isAdmin ? 7 : 6} className="muted">
                            No tokens matched the current view.
                          </td>
                        </tr>
                      ) : null}

                      {myTokens.map((token) => (
                        <tr key={token.id}>
                          {isAdmin ? (
                            <td>
                              <div className="table-cell-stack">
                                <strong>{getOwnerLabel(token)}</strong>
                                <span className="muted">{token.ownerEmail ?? token.ownerUserId}</span>
                              </div>
                            </td>
                          ) : null}
                          <td>{token.label}</td>
                          <td>
                            <div className="scope-list token-scope-list">
                              {token.scopes.map((scope) => (
                                <span key={scope} className="shell-badge shell-badge-muted">
                                  {scope}
                                </span>
                              ))}
                            </div>
                          </td>
                          <td>
                            <code>{token.tokenPreview}</code>
                          </td>
                          <td>{formatDateTime(token.lastUsedAt)}</td>
                          <td>{formatDateTime(token.createdAt)}</td>
                          <td>
                            <button
                              className="ghost-button"
                              disabled={busyTokenId === token.id}
                              onClick={() => void handleDeleteToken(token)}
                            >
                              {busyTokenId === token.id ? "Revoking..." : "Revoke"}
                            </button>
                          </td>
                        </tr>
                      ))}

                      {isAdmin
                        ? otherTokens.map((token) => (
                            <tr key={token.id}>
                              <td>
                                <div className="table-cell-stack">
                                  <strong>{getOwnerLabel(token)}</strong>
                                  <span className="muted">{token.ownerEmail ?? token.ownerUserId}</span>
                                </div>
                              </td>
                              <td>{token.label}</td>
                              <td>
                                <div className="scope-list token-scope-list">
                                  {token.scopes.map((scope) => (
                                    <span key={scope} className="shell-badge shell-badge-muted">
                                      {scope}
                                    </span>
                                  ))}
                                </div>
                              </td>
                              <td>
                                <code>{token.tokenPreview}</code>
                              </td>
                              <td>{formatDateTime(token.lastUsedAt)}</td>
                              <td>{formatDateTime(token.createdAt)}</td>
                              <td>
                                <button
                                  className="ghost-button"
                                  disabled={busyTokenId === token.id}
                                  onClick={() => void handleDeleteToken(token)}
                                >
                                  {busyTokenId === token.id ? "Revoking..." : "Revoke"}
                                </button>
                              </td>
                            </tr>
                          ))
                        : null}
                    </tbody>
                  </table>
                </div>
              </div>

              {isAdmin ? (
                <div className="notice-card notice-info">
                  <strong>Admin note</strong>
                  <p className="muted">
                    You can audit every user token and revoke any one of them here, but full token
                    secrets are only visible once at creation time and are never stored in plain text.
                  </p>
                </div>
              ) : null}
            </div>
          )}
        </article>
      </section>
    </div>
  );
}
