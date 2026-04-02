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

function formatPrioritySource(source: InitiativeSummary["prioritySource"]): string {
  if (source === "manual") {
    return "User-ranked";
  }
  if (source === "system") {
    return "System-ranked";
  }
  return "Unranked";
}

function sortInitiatives(rows: InitiativeSummary[]): InitiativeSummary[] {
  return [...rows].sort((left, right) => {
    const leftRank = left.priorityRank ?? Number.MAX_SAFE_INTEGER;
    const rightRank = right.priorityRank ?? Number.MAX_SAFE_INTEGER;
    if (leftRank !== rightRank) {
      return leftRank - rightRank;
    }

    const leftScore = left.priorityScore ?? -1;
    const rightScore = right.priorityScore ?? -1;
    if (leftScore !== rightScore) {
      return rightScore - leftScore;
    }

    return left.code.localeCompare(right.code);
  });
}

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

function asNumber(value: unknown): number {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

export function DashboardPage() {
  const [initiatives, setInitiatives] = useState<InitiativeSummary[]>([]);
  const [rankingRows, setRankingRows] = useState<InitiativeSummary[]>([]);
  const [groupFilter, setGroupFilter] = useState("");
  const [stageFilter, setStageFilter] = useState("");
  const [query, setQuery] = useState("");
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
    } else {
      setInitiatives([]);
      setLoadError("The initiative registry could not be loaded from the local API.");
    }

    if (slack.status === "fulfilled") {
      setSlackStatus(slack.value);
    }

    if (me.status === "fulfilled") {
      setCurrentUser(me.value);
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
      setRankingRows(sortInitiatives(initiatives.filter((initiative) => initiative.isActive)));
    }
  }, [initiatives, rankingDirty]);

  useEffect(() => {
    if (latestRefresh?.status !== "running") {
      return;
    }

    const interval = window.setInterval(() => {
      void (async () => {
        const [initiativeRows, refreshRun] = await Promise.all([
          listInitiatives(),
          getLatestPortfolioRefresh(),
        ]);
        setInitiatives(initiativeRows);
        setLatestRefresh(refreshRun);
      })();
    }, 12000);

    return () => window.clearInterval(interval);
  }, [latestRefresh?.status]);

  const filtered = useMemo(() => {
    return initiatives.filter((initiative) => {
      const matchesQuery =
        !query ||
        `${initiative.code} ${initiative.title} ${initiative.objective}`
          .toLowerCase()
          .includes(query.toLowerCase());
      const matchesGroup = !groupFilter || initiative.group === groupFilter;
      const matchesStage = !stageFilter || initiative.stage === stageFilter;
      return matchesQuery && matchesGroup && matchesStage;
    });
  }, [groupFilter, initiatives, query, stageFilter]);

  const groups = Array.from(new Set(initiatives.map((initiative) => initiative.group))).filter(Boolean);
  const stages = Array.from(new Set(initiatives.map((initiative) => initiative.stage))).filter(Boolean);
  const activeInitiatives = initiatives.filter((initiative) => initiative.isActive);
  const canManagePortfolio =
    currentUser?.type === "service_token" || currentUser?.appRole === "executive";
  const reviewedCount = initiatives.filter((initiative) => initiative.latestOpinionStatus).length;
  const urgentCount = initiatives.filter((initiative) =>
    ["stalled", "at_risk", "needs_attention", "off_track"].includes(
      initiative.latestOpinionStatus ?? "",
    ),
  ).length;
  const rankedCount = initiatives.filter((initiative) => initiative.priorityRank !== null).length;
  const topPriority = rankingRows[0] ?? null;
  const refreshSummary = (latestRefresh?.summary ?? {}) as Record<string, unknown>;
  const processedCount = asNumber(refreshSummary.processedCount);
  const totalCount = asNumber(refreshSummary.totalCount);
  const failureCount = asNumber(refreshSummary.failureCount);

  async function handleLaunchRefresh() {
    setBusy("Starting the full SI refresh...");
    const run = await launchPortfolioRefresh();
    setLatestRefresh(run);
    setBusy("Full SI refresh started. The dashboard will update as the portfolio sync runs.");
  }

  async function handleRecomputeRanking() {
    setBusy("Rebuilding the system priority stack...");
    const rows = await recomputeInitiativeRanking();
    setInitiatives(rows);
    setRankingDirty(false);
    setBusy("System priority stack refreshed.");
  }

  async function handleSaveRanking() {
    setBusy("Saving the priority stack...");
    const rows = await saveInitiativeRanking(rankingRows.map((initiative) => initiative.id));
    setInitiatives(rows);
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
      setOpinionError(error instanceof Error ? error.message : "Unable to load the initiative analysis.");
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
      <section className="hero-card portfolio-hero portfolio-hero-grid">
        <div className="portfolio-hero-copy">
          <div className="eyebrow">SI Portfolio Command</div>
          <h2>Review the full SI portfolio, dive into the evidence, and keep the stack ranked.</h2>
          <p>
            The landing page is now focused on the real operator loop: refresh evidence across all
            initiatives, understand the latest agent view, then manually tune the priority stack when
            leadership wants a different emphasis.
          </p>
          <div className="integration-strip">
            <span className={`status-pill ${slackStatus?.connected ? "status-on_track" : "status-needs_attention"}`}>
              Slack {slackStatus?.connected ? "connected" : "needs install"}
            </span>
            <span className={`status-pill ${googleStatus?.connected ? "status-on_track" : "status-needs_attention"}`}>
              Google {googleStatus?.connected ? "connected" : "needs install"}
            </span>
            {latestRefresh ? (
              <span className={`status-pill ${latestRefresh.status === "running" ? "status-needs_attention" : "status-on_track"}`}>
                Portfolio refresh {latestRefresh.status}
              </span>
            ) : null}
          </div>
        </div>
        <div className="hero-command-panel">
          <div className="hero-command-header">
            <span className="metric-label">Control Surface</span>
            <strong>Operate the portfolio</strong>
          </div>
          <div className="hero-actions hero-actions-vertical">
            {canManagePortfolio ? (
              <button className="primary-button" onClick={() => void handleLaunchRefresh()}>
                Refresh All SI Data
              </button>
            ) : null}
            {canManagePortfolio ? (
              <button className="secondary-button" onClick={() => void handleRecomputeRanking()}>
                Rebuild System Ranking
              </button>
            ) : null}
            {!slackStatus?.connected ? (
              <a
                className="ghost-button"
                href={slackStatus?.installUrl ?? `${getApiBaseUrl()}/integrations/slack/install`}
              >
                Connect Slack
              </a>
            ) : null}
            {!googleStatus?.connected ? (
              <a
                className="ghost-button"
                href={googleStatus?.installUrl ?? `${getApiBaseUrl()}/integrations/google/install`}
              >
                Connect Google
              </a>
            ) : null}
          </div>
          <div className="hero-command-footnote">
            {latestRefresh?.createdAt
              ? `Latest refresh: ${new Date(latestRefresh.createdAt).toLocaleString()}`
              : "No portfolio refresh has been run yet."}
          </div>
        </div>
      </section>

      {!canManagePortfolio ? (
        <section className="notice-card notice-info">
          <strong>Portfolio access</strong>
          <p className="muted">
            You can review the portfolio and drill into SI analysis. Executive users can launch the
            all-SI refresh, rebuild system ranking, and save manual stack changes.
          </p>
        </section>
      ) : null}

      <section className="stats-grid stats-grid-portfolio">
        <article className="stat-card">
          <span className="metric-label">Active SIs</span>
          <strong>{activeInitiatives.length}</strong>
          <div className="metric-subtext">Current active initiatives in the portfolio</div>
        </article>
        <article className="stat-card">
          <span className="metric-label">Reviewed</span>
          <strong>{reviewedCount}</strong>
          <div className="metric-subtext">Initiatives with at least one stored opinion</div>
        </article>
        <article className="stat-card">
          <span className="metric-label">Needs Attention</span>
          <strong>{urgentCount}</strong>
          <div className="metric-subtext">Mixed signals, stalled work, or off-track status</div>
        </article>
        <article className="stat-card">
          <span className="metric-label">Ranked</span>
          <strong>{rankedCount}</strong>
          <div className="metric-subtext">Initiatives currently in the saved priority stack</div>
        </article>
        <article className="stat-card">
          <span className="metric-label">Top Priority</span>
          <strong>{topPriority ? `${topPriority.code}` : "Not ranked yet"}</strong>
          <div className="metric-subtext">{topPriority?.title ?? "Run the refresh to seed the queue."}</div>
        </article>
      </section>

      {busy ? (
        <section className="notice-card notice-info">
          <strong>Portfolio update</strong>
          <p className="muted">{busy}</p>
        </section>
      ) : null}

      {loadError ? (
        <section className="notice-card notice-warning">
          <strong>Dashboard load warning</strong>
          <p className="muted">{loadError}</p>
        </section>
      ) : null}

      <section className="panel panel-tonal">
        <div className="section-header">
          <div>
            <h2>Portfolio Refresh</h2>
            <p className="panel-subtitle">
              Run the full Slack, Drive, tracker, opinion, and KPI pipeline across the full SI portfolio.
            </p>
          </div>
          {latestRefresh ? (
            <span className="muted">
              Last run {new Date(latestRefresh.createdAt).toLocaleString()}
            </span>
          ) : null}
        </div>
        {latestRefresh ? (
          <div className="refresh-grid">
            <article className="setup-card">
              <span className="metric-label">Run Status</span>
              <strong>{latestRefresh.status}</strong>
              <p className="muted">
                {latestRefresh.status === "running"
                  ? "The dashboard will keep polling while the portfolio refresh is active."
                  : "This summary reflects the latest full-portfolio refresh run."}
              </p>
            </article>
            <article className="setup-card">
              <span className="metric-label">Progress</span>
              <strong>
                {processedCount} / {totalCount || activeInitiatives.length}
              </strong>
              <p className="muted">
                {refreshSummary.currentCode
                  ? `Currently processing ${String(refreshSummary.currentCode)}.`
                  : "No active initiative is being processed right now."}
              </p>
            </article>
            <article className="setup-card">
              <span className="metric-label">Failures</span>
              <strong>{failureCount}</strong>
              <p className="muted">
                {failureCount > 0
                  ? "Some initiatives could not be fully synced or evaluated in the last run."
                  : "No initiative-level failures were captured in the latest run."}
              </p>
            </article>
          </div>
        ) : (
          <p className="muted">
            No full-portfolio refresh has been launched yet. Use <strong>Refresh All SI Data</strong> to
            kick off the first complete run.
          </p>
        )}
      </section>

      <section className="panel panel-tonal">
        <div className="section-header">
          <div>
            <h2>Priority Stack</h2>
            <p className="panel-subtitle">
              Drag SIs into the order leadership cares about. The initial ranking comes from evidence of
              progress, process adherence, and actual operating activity.
            </p>
          </div>
          <div className="button-row">
            {rankingDirty && canManagePortfolio ? (
              <button className="primary-button" onClick={() => void handleSaveRanking()}>
                Save Priority Order
              </button>
            ) : null}
            <span className="muted">{rankingRows.length} active SIs in the stack</span>
          </div>
        </div>
        <div className="priority-board">
          {rankingRows.map((initiative, index) => (
            <article
              className={`priority-item ${draggedId === initiative.id ? "dragging" : ""}`}
              key={initiative.id}
              draggable={canManagePortfolio}
              onDragStart={() => {
                if (canManagePortfolio) {
                  setDraggedId(initiative.id);
                }
              }}
              onDragEnd={() => setDraggedId(null)}
              onDragOver={(event) => event.preventDefault()}
              onDrop={() => {
                if (canManagePortfolio) {
                  handleDrop(initiative.id);
                }
              }}
            >
              <div className="priority-rank">#{index + 1}</div>
              <div className="drag-handle" aria-hidden="true">
                ⋮⋮
              </div>
              <div className="priority-body">
                <div className="priority-head">
                  <div>
                    <strong>
                      <Link className="table-link" to={`/initiatives/${initiative.id}`}>
                        {initiative.code} {initiative.title}
                      </Link>
                    </strong>
                    <div className="muted line-clamp">{initiative.priorityReason ?? initiative.objective}</div>
                  </div>
                  <div className="priority-actions">
                    {initiative.latestOpinionStatus ? (
                      <button
                        className={`status-pill opinion-pill-button status-${initiative.latestOpinionStatus}`}
                        onClick={() => void handleOpenOpinion(initiative)}
                      >
                        {formatStatusLabel(initiative.latestOpinionStatus)}
                      </button>
                    ) : (
                      <span className="status-pill">No opinion yet</span>
                    )}
                    <Link className="secondary-button compact-action" to={`/initiatives/${initiative.id}`}>
                      Open SI
                    </Link>
                  </div>
                </div>
                <div className="priority-meta">
                  <span>Group: {initiative.group || "Unassigned"}</span>
                  <span>Stage: {initiative.stage || "Unknown"}</span>
                  <span>
                    Score: {initiative.priorityScore !== null ? initiative.priorityScore.toFixed(1) : "Pending"}
                  </span>
                  <span>Source: {formatPrioritySource(initiative.prioritySource)}</span>
                </div>
              </div>
            </article>
          ))}
        </div>
      </section>

      <section className="panel panel-tonal">
        <div className="section-header">
          <div>
            <h2>Initiative Registry</h2>
            <p className="panel-subtitle">
              Search the portfolio, see the current opinion at a glance, and click directly into a deeper
              analysis.
            </p>
          </div>
          <span className="muted">{filtered.length} shown</span>
        </div>
        <div className="filter-grid">
          <label>
            Search
            <input
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Code, title, objective"
            />
          </label>
          <label>
            Group
            <select value={groupFilter} onChange={(event) => setGroupFilter(event.target.value)}>
              <option value="">All groups</option>
              {groups.map((group) => (
                <option key={group} value={group}>
                  {group}
                </option>
              ))}
            </select>
          </label>
          <label>
            Stage
            <select value={stageFilter} onChange={(event) => setStageFilter(event.target.value)}>
              <option value="">All stages</option>
              {stages.map((stage) => (
                <option key={stage} value={stage}>
                  {stage}
                </option>
              ))}
            </select>
          </label>
        </div>

        <div className="table-wrap">
          <table className="data-table">
            <thead>
              <tr>
                <th>Rank</th>
                <th>SI</th>
                <th>Group</th>
                <th>Stage</th>
                <th>Priority Score</th>
                <th>Latest Opinion</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={6} className="muted">
                    Loading the SI portfolio...
                  </td>
                </tr>
              ) : null}

              {!loading && filtered.length === 0 ? (
                <tr>
                  <td colSpan={6} className="muted">
                    No initiatives match the current filters.
                  </td>
                </tr>
              ) : null}

              {!loading
                ? filtered.map((initiative) => (
                    <tr key={initiative.id}>
                      <td>{initiative.priorityRank ?? "—"}</td>
                      <td>
                        <Link className="table-link" to={`/initiatives/${initiative.id}`}>
                          <strong>{initiative.code}</strong> {initiative.title}
                        </Link>
                        <div className="muted line-clamp">{initiative.objective}</div>
                      </td>
                      <td>{initiative.group}</td>
                      <td>{initiative.stage}</td>
                      <td>{initiative.priorityScore !== null ? initiative.priorityScore.toFixed(1) : "—"}</td>
                      <td>
                        {initiative.latestOpinionStatus ? (
                          <button
                            className={`status-pill opinion-pill-button status-${initiative.latestOpinionStatus}`}
                            onClick={() => void handleOpenOpinion(initiative)}
                          >
                            {formatStatusLabel(initiative.latestOpinionStatus)}
                          </button>
                        ) : (
                          <span className="muted">No opinion yet</span>
                        )}
                      </td>
                    </tr>
                  ))
                : null}
            </tbody>
          </table>
        </div>
      </section>

      {(opinionLoading || opinionError || selectedInitiative) ? (
        <OpinionDrilldownModal
          initiative={selectedInitiative}
          loading={opinionLoading}
          error={opinionError}
          onClose={handleCloseOpinion}
        />
      ) : null}
    </div>
  );
}
