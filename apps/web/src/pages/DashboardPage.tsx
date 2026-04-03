import type {
  CurrentUser,
  GoogleInstallStatus,
  InitiativeDetail,
  InitiativeSummary,
  PortfolioRefreshRun,
  SlackInstallStatus,
} from "@si/domain";
import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import {
  getApiBaseUrl,
  getCurrentUser,
  getGoogleStatus,
  getInitiative,
  getLatestPortfolioRefresh,
  getSlackStatus,
  launchPortfolioRefresh,
  listInitiatives,
  recomputeInitiativeRanking,
  saveInitiativeRanking,
} from "../api/client";
import { OpinionDrilldownModal } from "../components/OpinionDrilldownModal";
import { formatStatusLabel } from "../lib/status-label";

function moveInitiative(
  items: InitiativeSummary[],
  draggedId: string,
  targetId: string,
): InitiativeSummary[] {
  const draggedIndex = items.findIndex((item) => item.id === draggedId);
  const targetIndex = items.findIndex((item) => item.id === targetId);
  if (draggedIndex < 0 || targetIndex < 0 || draggedIndex === targetIndex) {
    return items;
  }

  const next = [...items];
  const [dragged] = next.splice(draggedIndex, 1);
  if (!dragged) {
    return items;
  }
  next.splice(targetIndex, 0, dragged);
  return next;
}

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

function getOwnershipStatus(initiative: InitiativeSummary): "complete" | "partial" | "missing" {
  if (initiative.hasExecOwner && initiative.hasInitiativeOwner) {
    return "complete";
  }
  if (initiative.hasExecOwner || initiative.hasInitiativeOwner || initiative.hasGroupOwner) {
    return "partial";
  }
  return "missing";
}

function asNumber(value: unknown): number {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

export function DashboardPage() {
  const [initiatives, setInitiatives] = useState<InitiativeSummary[]>([]);
  const [rankingRows, setRankingRows] = useState<InitiativeSummary[]>([]);
  const [query, setQuery] = useState("");
  const [groupFilter, setGroupFilter] = useState("");
  const [stageFilter, setStageFilter] = useState("");
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState("");
  const [loadError, setLoadError] = useState("");
  const [currentUser, setCurrentUser] = useState<CurrentUser | null>(null);
  const [slackStatus, setSlackStatus] = useState<SlackInstallStatus | null>(null);
  const [googleStatus, setGoogleStatus] = useState<GoogleInstallStatus | null>(null);
  const [latestRefresh, setLatestRefresh] = useState<PortfolioRefreshRun | null>(null);
  const [selectedInitiative, setSelectedInitiative] = useState<InitiativeDetail | null>(null);
  const [opinionLoading, setOpinionLoading] = useState(false);
  const [opinionError, setOpinionError] = useState("");
  const [draggedId, setDraggedId] = useState<string | null>(null);
  const [rankingDirty, setRankingDirty] = useState(false);

  async function loadDashboard() {
    setLoading(true);
    setLoadError("");

    const [initiativeRows, me, slack, google, refreshRun] = await Promise.allSettled([
      listInitiatives(),
      getCurrentUser(),
      getSlackStatus(),
      getGoogleStatus(),
      getLatestPortfolioRefresh(),
    ]);

    if (initiativeRows.status === "fulfilled") {
      setInitiatives(initiativeRows.value);
      setRankingRows(initiativeRows.value.filter((initiative) => initiative.isActive));
    } else {
      setInitiatives([]);
      setRankingRows([]);
      setLoadError("The portfolio could not be loaded from the API.");
    }

    if (me.status === "fulfilled") {
      setCurrentUser(me.value);
    }
    if (slack.status === "fulfilled") {
      setSlackStatus(slack.value);
    }
    if (google.status === "fulfilled") {
      setGoogleStatus(google.value);
    }
    if (refreshRun.status === "fulfilled") {
      setLatestRefresh(refreshRun.value);
    }

    setLoading(false);
  }

  useEffect(() => {
    void loadDashboard();
  }, []);

  useEffect(() => {
    if (!rankingDirty) {
      setRankingRows(initiatives.filter((initiative) => initiative.isActive));
    }
  }, [initiatives, rankingDirty]);

  useEffect(() => {
    if (latestRefresh?.status !== "running") {
      return;
    }

    const interval = window.setInterval(() => {
      void loadDashboard();
    }, 12000);

    return () => window.clearInterval(interval);
  }, [latestRefresh?.status]);

  const groups = useMemo(
    () => Array.from(new Set(initiatives.map((initiative) => initiative.group))).filter(Boolean),
    [initiatives],
  );
  const stages = useMemo(
    () => Array.from(new Set(initiatives.map((initiative) => initiative.stage))).filter(Boolean),
    [initiatives],
  );
  const canManagePortfolio =
    currentUser?.type === "service_token" || currentUser?.appRole === "executive";

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
      return matchesSearch && matchesGroup && matchesStage;
    });
  }, [groupFilter, initiatives, query, stageFilter]);

  const stats = useMemo(() => {
    const active = initiatives.filter((initiative) => initiative.isActive).length;
    const ranked = initiatives.filter((initiative) => initiative.priorityRank !== null).length;
    const stale = initiatives.filter((initiative) => {
      const days = getDaysSince(initiative.latestObservationAt ?? initiative.updatedAt);
      return days !== null && days >= 14;
    }).length;
    const weakOwnership = initiatives.filter(
      (initiative) => getOwnershipStatus(initiative) !== "complete",
    ).length;
    const exceptions = initiatives.filter((initiative) =>
      ["stalled", "at_risk", "off_track", "needs_attention"].includes(
        initiative.latestOpinionStatus ?? "",
      ),
    ).length;

    return { active, ranked, stale, weakOwnership, exceptions };
  }, [initiatives]);

  const exceptionGroups = useMemo(
    () => ({
      intervention: initiatives.filter((initiative) =>
        ["stalled", "at_risk", "off_track", "needs_attention"].includes(
          initiative.latestOpinionStatus ?? "",
        ),
      ),
      stale: initiatives.filter((initiative) => {
        const days = getDaysSince(initiative.latestObservationAt ?? initiative.updatedAt);
        return days !== null && days >= 14;
      }),
      weakOwnership: initiatives.filter(
        (initiative) => getOwnershipStatus(initiative) !== "complete",
      ),
      lowConfidence: initiatives.filter(
        (initiative) =>
          initiative.priorityRank !== null &&
          initiative.priorityRank <= 10 &&
          initiative.latestOpinionConfidence !== null &&
          initiative.latestOpinionConfidence < 0.6,
      ),
    }),
    [initiatives],
  );

  const topPriority = rankingRows[0] ?? null;
  const refreshSummary = (latestRefresh?.summary ?? {}) as Record<string, unknown>;

  async function handleLaunchRefresh() {
    setBusy("Starting the full portfolio refresh...");
    await launchPortfolioRefresh();
    await loadDashboard();
    setBusy("Portfolio refresh started.");
  }

  async function handleRecomputeRanking() {
    setBusy("Rebuilding the system priority stack...");
    const rows = await recomputeInitiativeRanking();
    setInitiatives(rows);
    setRankingRows(rows.filter((initiative) => initiative.isActive));
    setRankingDirty(false);
    setBusy("System priority stack refreshed.");
  }

  async function handleSaveRanking() {
    setBusy("Saving the executive priority stack...");
    const rows = await saveInitiativeRanking(rankingRows.map((initiative) => initiative.id));
    setInitiatives(rows);
    setRankingRows(rows.filter((initiative) => initiative.isActive));
    setRankingDirty(false);
    setBusy("Priority stack saved.");
  }

  async function handleOpenOpinion(initiativeSummary: InitiativeSummary) {
    setSelectedInitiative(null);
    setOpinionError("");
    setOpinionLoading(true);
    try {
      const detail = await getInitiative(initiativeSummary.id);
      setSelectedInitiative(detail);
    } catch (error) {
      setOpinionError(
        error instanceof Error ? error.message : "Unable to load the initiative analysis.",
      );
    } finally {
      setOpinionLoading(false);
    }
  }

  function handleCloseOpinion() {
    setSelectedInitiative(null);
    setOpinionError("");
    setOpinionLoading(false);
  }

  function handleDrop(targetId: string) {
    if (!draggedId) {
      return;
    }
    setRankingRows((current) => moveInitiative(current, draggedId, targetId));
    setRankingDirty(true);
    setDraggedId(null);
  }

  return (
    <div className="page-stack">
      <section className="hero-card panel-tonal portfolio-hq-hero">
        <div className="portfolio-hero-copy">
          <div className="eyebrow">Portfolio HQ</div>
          <h2>See the stack, catch the exceptions, and direct executive attention fast.</h2>
          <p>
            This home screen is now designed around the real admin loop: keep the portfolio ranked,
            identify stale or weakly owned initiatives, and jump into the control room only when a
            decision needs to be made.
          </p>
          <div className="integration-strip">
            <span className={`status-pill ${slackStatus?.connected ? "status-on_track" : "status-needs_attention"}`}>
              Slack {slackStatus?.connected ? "connected" : "needs install"}
            </span>
            <span className={`status-pill ${googleStatus?.connected ? "status-on_track" : "status-needs_attention"}`}>
              Google {googleStatus?.connected ? "connected" : "needs install"}
            </span>
            <span className={`status-pill ${latestRefresh?.status === "running" ? "status-needs_attention" : "status-muted"}`}>
              Refresh {latestRefresh?.status ?? "not started"}
            </span>
          </div>
        </div>
        <div className="hero-command-panel">
          <div className="hero-command-header">
            <span className="metric-label">Executive actions</span>
            <strong>Operate the portfolio</strong>
          </div>
          <div className="hero-actions hero-actions-vertical">
            {canManagePortfolio ? (
              <Link className="primary-button" to="/initiatives/new">
                Create Initiative
              </Link>
            ) : null}
            {canManagePortfolio ? (
              <button className="secondary-button" onClick={() => void handleLaunchRefresh()}>
                Refresh All SI Data
              </button>
            ) : null}
            {canManagePortfolio ? (
              <button className="ghost-button" onClick={() => void handleRecomputeRanking()}>
                Rebuild System Ranking
              </button>
            ) : null}
            <Link className="ghost-button" to="/settings/operations">
              Open Operations
            </Link>
            <div className="hero-command-footnote">
              {latestRefresh?.createdAt
                ? `Latest refresh: ${new Date(latestRefresh.createdAt).toLocaleString()}`
                : "No portfolio refresh has been run yet."}
            </div>
          </div>
        </div>
      </section>

      {busy ? (
        <section className="notice-card notice-info">
          <strong>Portfolio update</strong>
          <p className="muted">{busy}</p>
        </section>
      ) : null}

      {loadError ? (
        <section className="notice-card notice-warning">
          <strong>Portfolio load warning</strong>
          <p className="muted">{loadError}</p>
        </section>
      ) : null}

      <section className="stats-grid stats-grid-portfolio">
        <article className="stat-card">
          <span className="metric-label">Active SIs</span>
          <strong>{loading ? "..." : stats.active}</strong>
          <div className="metric-subtext">Current initiatives in scope</div>
        </article>
        <article className="stat-card">
          <span className="metric-label">Ranked Stack</span>
          <strong>{loading ? "..." : stats.ranked}</strong>
          <div className="metric-subtext">Initiatives with a stored priority rank</div>
        </article>
        <article className="stat-card">
          <span className="metric-label">Exceptions</span>
          <strong>{loading ? "..." : stats.exceptions}</strong>
          <div className="metric-subtext">Stalled, at risk, off track, or mixed-signal work</div>
        </article>
        <article className="stat-card">
          <span className="metric-label">Weak Ownership</span>
          <strong>{loading ? "..." : stats.weakOwnership}</strong>
          <div className="metric-subtext">Missing a full executive + initiative owner shape</div>
        </article>
        <article className="stat-card">
          <span className="metric-label">Stale Assessment</span>
          <strong>{loading ? "..." : stats.stale}</strong>
          <div className="metric-subtext">No fresh opinion in the last 14 days</div>
        </article>
      </section>

      <section className="exception-grid">
        <article className="panel exception-panel">
          <div className="section-header">
            <h2>Needs Executive Attention</h2>
            <span className="muted">{exceptionGroups.intervention.length} SIs</span>
          </div>
          <div className="exception-list">
            {exceptionGroups.intervention.slice(0, 5).map((initiative) => (
              <Link key={initiative.id} className="exception-item" to={`/initiatives/${initiative.id}`}>
                <strong>{initiative.code}</strong>
                <span>{initiative.title}</span>
                <span className="muted">{formatStatusLabel(initiative.latestOpinionStatus)}</span>
              </Link>
            ))}
            {exceptionGroups.intervention.length === 0 ? (
              <div className="muted">No urgent exception states at the moment.</div>
            ) : null}
          </div>
        </article>

        <article className="panel exception-panel">
          <div className="section-header">
            <h2>Stale Or Weakly Owned</h2>
            <span className="muted">
              {exceptionGroups.stale.length + exceptionGroups.weakOwnership.length} signals
            </span>
          </div>
          <div className="exception-list">
            {exceptionGroups.stale.slice(0, 3).map((initiative) => (
              <Link key={`stale-${initiative.id}`} className="exception-item" to={`/initiatives/${initiative.id}`}>
                <strong>{initiative.code}</strong>
                <span>{initiative.title}</span>
                <span className="muted">
                  {getDaysSince(initiative.latestObservationAt ?? initiative.updatedAt)}d since review
                </span>
              </Link>
            ))}
            {exceptionGroups.weakOwnership.slice(0, 3).map((initiative) => (
              <Link key={`ownership-${initiative.id}`} className="exception-item" to={`/initiatives/${initiative.id}?tab=ownership`}>
                <strong>{initiative.code}</strong>
                <span>{initiative.title}</span>
                <span className="muted">Ownership {getOwnershipStatus(initiative)}</span>
              </Link>
            ))}
            {exceptionGroups.stale.length === 0 && exceptionGroups.weakOwnership.length === 0 ? (
              <div className="muted">Nothing is currently stale or under-owned.</div>
            ) : null}
          </div>
        </article>

        <article className="panel exception-panel">
          <div className="section-header">
            <h2>Low-Confidence Priorities</h2>
            <span className="muted">{exceptionGroups.lowConfidence.length} SIs</span>
          </div>
          <div className="exception-list">
            {exceptionGroups.lowConfidence.slice(0, 5).map((initiative) => (
              <Link key={initiative.id} className="exception-item" to={`/initiatives/${initiative.id}?tab=assessment`}>
                <strong>#{initiative.priorityRank}</strong>
                <span>
                  {initiative.code} {initiative.title}
                </span>
                <span className="muted">
                  {initiative.latestOpinionConfidence !== null
                    ? `${Math.round(initiative.latestOpinionConfidence * 100)}% confidence`
                    : "No confidence score"}
                </span>
              </Link>
            ))}
            {exceptionGroups.lowConfidence.length === 0 ? (
              <div className="muted">Top priorities currently have healthy confidence.</div>
            ) : null}
          </div>
        </article>
      </section>

      <section className="panel">
        <div className="section-header">
          <div>
            <h2>Priority Stack</h2>
            <p className="panel-subtitle">
              Drag the highest-priority initiatives into the order leadership actually wants.
            </p>
          </div>
          <div className="button-row">
            {rankingDirty && canManagePortfolio ? (
              <button className="primary-button" onClick={() => void handleSaveRanking()}>
                Save Executive Ranking
              </button>
            ) : null}
            <span className="muted">{rankingRows.length} active SIs</span>
          </div>
        </div>

        <div className="priority-board">
          {rankingRows.slice(0, 8).map((initiative, index) => (
            <article
              key={initiative.id}
              className={`priority-item ${draggedId === initiative.id ? "dragging" : ""}`}
              draggable={canManagePortfolio}
              onDragStart={() => setDraggedId(initiative.id)}
              onDragOver={(event) => event.preventDefault()}
              onDrop={() => handleDrop(initiative.id)}
            >
              <div className="priority-rank">#{index + 1}</div>
              <div className="priority-body">
                <div className="priority-head">
                  <div>
                    <strong>
                      {initiative.code} {initiative.title}
                    </strong>
                    <div className="muted line-clamp">
                      {initiative.priorityReason ?? initiative.objective}
                    </div>
                  </div>
                  <div className="priority-actions">
                    <button
                      className="ghost-button"
                      onClick={() => void handleOpenOpinion(initiative)}
                    >
                      Open opinion
                    </button>
                    <Link className="ghost-button" to={`/initiatives/${initiative.id}`}>
                      Control room
                    </Link>
                  </div>
                </div>
                <div className="priority-meta">
                  <span className={`status-pill status-${initiative.latestOpinionStatus ?? "muted"}`}>
                    {formatStatusLabel(initiative.latestOpinionStatus)}
                  </span>
                  <span>
                    Score:{" "}
                    {initiative.priorityScore !== null ? initiative.priorityScore.toFixed(1) : "Pending"}
                  </span>
                  <span>
                    Ownership: {getOwnershipStatus(initiative)}
                  </span>
                </div>
              </div>
            </article>
          ))}
        </div>
      </section>

      <section className="panel">
        <div className="section-header">
          <div>
            <h2>Portfolio Table</h2>
            <p className="panel-subtitle">
              Scan the full portfolio, then jump into the control room where needed.
            </p>
          </div>
        </div>

        <div className="filter-grid">
          <input
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Search code, title, or objective"
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
        </div>

        <div className="table-shell" style={{ marginTop: "0.9rem" }}>
          <table className="data-table">
            <thead>
              <tr>
                <th>Initiative</th>
                <th>Status</th>
                <th>Ownership</th>
                <th>Priority</th>
                <th>Freshness</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={6}>Loading portfolio...</td>
                </tr>
              ) : filtered.length === 0 ? (
                <tr>
                  <td colSpan={6}>No initiatives matched the current filters.</td>
                </tr>
              ) : (
                filtered.map((initiative) => (
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
                    <td>{getOwnershipStatus(initiative)}</td>
                    <td>{initiative.priorityRank ? `#${initiative.priorityRank}` : "Unranked"}</td>
                    <td>
                      {getDaysSince(initiative.latestObservationAt ?? initiative.updatedAt) ?? "—"}d
                    </td>
                    <td>
                      <div className="button-row">
                        <button
                          className="ghost-button"
                          onClick={() => void handleOpenOpinion(initiative)}
                        >
                          Opinion
                        </button>
                        <Link className="ghost-button" to={`/initiatives/${initiative.id}`}>
                          Open
                        </Link>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>

      <OpinionDrilldownModal
        initiative={selectedInitiative}
        loading={opinionLoading}
        error={opinionError}
        onClose={handleCloseOpinion}
      />

      {!slackStatus?.connected || !googleStatus?.connected ? (
        <section className="notice-card notice-warning">
          <strong>Workspace integrations still need attention.</strong>
          <p className="muted">
            Use <Link to="/settings/operations">Settings → Operations</Link> to finish the hosted
            workspace setup, or install directly from{" "}
            <a href={slackStatus?.installUrl ?? `${getApiBaseUrl()}/integrations/slack/install`}>
              Slack
            </a>{" "}
            and{" "}
            <a href={googleStatus?.installUrl ?? `${getApiBaseUrl()}/integrations/google/install`}>
              Google
            </a>
            .
          </p>
        </section>
      ) : null}

      {latestRefresh ? (
        <section className="notice-card notice-info">
          <strong>Refresh snapshot</strong>
          <p className="muted">
            {asNumber(refreshSummary.processedCount)} processed / {asNumber(refreshSummary.totalCount)} total
            with {asNumber(refreshSummary.failureCount)} failures on the latest portfolio refresh.
          </p>
        </section>
      ) : null}
    </div>
  );
}
