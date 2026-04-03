import type { CurrentUser, InitiativeSummary } from "@si/domain";
import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { getCurrentUser, listInitiatives } from "../api/client";
import { formatStatusLabel } from "../lib/status-label";

type OwnershipFilter = "all" | "complete" | "partial" | "missing";

function getDaysSince(value: string | null): number | null {
  if (!value) {
    return null;
  }
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return null;
  }
  return Math.floor((Date.now() - date.getTime()) / (1000 * 60 * 60 * 24));
}

function getOwnershipStatus(initiative: InitiativeSummary): OwnershipFilter {
  if (initiative.hasExecOwner && initiative.hasInitiativeOwner) {
    return "complete";
  }
  if (initiative.hasExecOwner || initiative.hasInitiativeOwner || initiative.hasGroupOwner) {
    return "partial";
  }
  return "missing";
}

export function InitiativesPage() {
  const [initiatives, setInitiatives] = useState<InitiativeSummary[]>([]);
  const [currentUser, setCurrentUser] = useState<CurrentUser | null>(null);
  const [query, setQuery] = useState("");
  const [groupFilter, setGroupFilter] = useState("");
  const [stageFilter, setStageFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [ownershipFilter, setOwnershipFilter] = useState<OwnershipFilter>("all");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    async function load() {
      try {
        const [rows, me] = await Promise.all([listInitiatives(), getCurrentUser()]);
        setInitiatives(rows);
        setCurrentUser(me);
      } catch (caughtError) {
        setInitiatives([]);
        setError(caughtError instanceof Error ? caughtError.message : "Unable to load initiatives.");
      } finally {
        setLoading(false);
      }
    }

    void load();
  }, []);

  const groups = useMemo(
    () => Array.from(new Set(initiatives.map((initiative) => initiative.group))).filter(Boolean),
    [initiatives],
  );
  const stages = useMemo(
    () => Array.from(new Set(initiatives.map((initiative) => initiative.stage))).filter(Boolean),
    [initiatives],
  );

  const filtered = useMemo(() => {
    const search = query.trim().toLowerCase();
    return initiatives.filter((initiative) => {
      const matchesSearch =
        !search ||
        [initiative.code, initiative.title, initiative.objective]
          .join(" ")
          .toLowerCase()
          .includes(search);
      const matchesGroup = !groupFilter || initiative.group === groupFilter;
      const matchesStage = !stageFilter || initiative.stage === stageFilter;
      const matchesStatus = !statusFilter || initiative.latestOpinionStatus === statusFilter;
      const matchesOwnership =
        ownershipFilter === "all" || getOwnershipStatus(initiative) === ownershipFilter;

      return matchesSearch && matchesGroup && matchesStage && matchesStatus && matchesOwnership;
    });
  }, [groupFilter, initiatives, ownershipFilter, query, stageFilter, statusFilter]);

  const stats = useMemo(() => {
    const active = initiatives.filter((initiative) => initiative.isActive).length;
    const urgent = initiatives.filter((initiative) =>
      ["stalled", "at_risk", "off_track", "needs_attention"].includes(
        initiative.latestOpinionStatus ?? "",
      ),
    ).length;
    const weakOwnership = initiatives.filter(
      (initiative) => getOwnershipStatus(initiative) !== "complete",
    ).length;
    const stale = initiatives.filter((initiative) => {
      const days = getDaysSince(initiative.latestObservationAt ?? initiative.updatedAt);
      return days !== null && days >= 14;
    }).length;

    return { active, urgent, weakOwnership, stale };
  }, [initiatives]);

  const canManage =
    currentUser?.type === "service_token" || currentUser?.appRole === "admin";

  return (
    <div className="page-stack">
      <section className="hero-card panel-tonal">
        <div>
          <div className="eyebrow">Registry</div>
          <h2>Manage the live initiative portfolio</h2>
          <p>
            Create new initiatives, spot weak ownership coverage, and move quickly from the registry
            into each initiative’s control room.
          </p>
        </div>
        {canManage ? (
          <div className="hero-actions">
            <Link className="primary-button" to="/initiatives/new">
              Create Strategic Initiative
            </Link>
          </div>
        ) : null}
      </section>

      <section className="stats-grid">
        <article className="stat-card">
          <span className="metric-label">Active</span>
          <strong>{loading ? "..." : stats.active}</strong>
          <div className="metric-subtext">Initiatives currently in scope</div>
        </article>
        <article className="stat-card">
          <span className="metric-label">Needs Attention</span>
          <strong>{loading ? "..." : stats.urgent}</strong>
          <div className="metric-subtext">At risk, stalled, or requiring intervention</div>
        </article>
        <article className="stat-card">
          <span className="metric-label">Weak Ownership</span>
          <strong>{loading ? "..." : stats.weakOwnership}</strong>
          <div className="metric-subtext">Missing a full executive + initiative owner shape</div>
        </article>
        <article className="stat-card">
          <span className="metric-label">Stale Assessment</span>
          <strong>{loading ? "..." : stats.stale}</strong>
          <div className="metric-subtext">No recent opinion refresh in the last 14 days</div>
        </article>
      </section>

      <section className="panel">
        <div className="section-header">
          <div>
            <h2>Registry Browser</h2>
            <p className="panel-subtitle">
              Filter the portfolio by stage, group, status, and ownership coverage.
            </p>
          </div>
        </div>

        <div className="filter-grid">
          <input
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Search by code, title, or objective"
          />
          <select value={groupFilter} onChange={(event) => setGroupFilter(event.target.value)}>
            <option value="">All groups</option>
            {groups.map((group) => (
              <option key={group} value={group}>
                {group}
              </option>
            ))}
          </select>
          <select value={stageFilter} onChange={(event) => setStageFilter(event.target.value)}>
            <option value="">All stages</option>
            {stages.map((stage) => (
              <option key={stage} value={stage}>
                {stage}
              </option>
            ))}
          </select>
          <select value={statusFilter} onChange={(event) => setStatusFilter(event.target.value)}>
            <option value="">All status states</option>
            <option value="on_track">On track</option>
            <option value="needs_attention">Needs attention</option>
            <option value="at_risk">At risk</option>
            <option value="stalled">Stalled</option>
            <option value="off_track">Off track</option>
          </select>
          <select
            value={ownershipFilter}
            onChange={(event) => setOwnershipFilter(event.target.value as OwnershipFilter)}
          >
            <option value="all">All ownership states</option>
            <option value="complete">Ownership complete</option>
            <option value="partial">Ownership partial</option>
            <option value="missing">Ownership missing</option>
          </select>
        </div>

        {error ? (
          <div className="notice-card notice-warning" style={{ marginTop: "0.9rem" }}>
            <strong>Registry load warning</strong>
            <p className="muted">{error}</p>
          </div>
        ) : null}

        <div className="table-shell" style={{ marginTop: "0.9rem" }}>
          <table className="data-table">
            <thead>
              <tr>
                <th>Initiative</th>
                <th>Status</th>
                <th>Ownership</th>
                <th>Priority</th>
                <th>Last opinion</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={6}>Loading initiatives...</td>
                </tr>
              ) : filtered.length === 0 ? (
                <tr>
                  <td colSpan={6}>No initiatives matched the current filters.</td>
                </tr>
              ) : (
                filtered.map((initiative) => {
                  const ownership = getOwnershipStatus(initiative);
                  const daysSinceOpinion = getDaysSince(
                    initiative.latestObservationAt ?? initiative.updatedAt,
                  );

                  return (
                    <tr key={initiative.id}>
                      <td>
                        <div className="table-cell-stack">
                          <strong>
                            {initiative.code} {initiative.title}
                          </strong>
                          <span className="muted">
                            {initiative.group || "No group"} • {initiative.stage || "No stage"}
                          </span>
                        </div>
                      </td>
                      <td>
                        <span
                          className={`status-pill ${
                            initiative.latestOpinionStatus === "on_track"
                              ? "status-on_track"
                              : initiative.latestOpinionStatus
                                ? "status-needs_attention"
                                : "status-muted"
                          }`}
                        >
                          {formatStatusLabel(initiative.latestOpinionStatus)}
                        </span>
                      </td>
                      <td>
                        <span
                          className={`status-pill ${
                            ownership === "complete"
                              ? "status-on_track"
                              : ownership === "partial"
                                ? "status-needs_attention"
                                : "status-off_track"
                          }`}
                        >
                          {ownership === "complete"
                            ? "Complete"
                            : ownership === "partial"
                              ? "Partial"
                              : "Missing"}
                        </span>
                      </td>
                      <td>{initiative.priorityRank ? `#${initiative.priorityRank}` : "Unranked"}</td>
                      <td>{daysSinceOpinion === null ? "No opinion yet" : `${daysSinceOpinion}d ago`}</td>
                      <td>
                        <Link className="ghost-button" to={`/initiatives/${initiative.id}`}>
                          Open
                        </Link>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
