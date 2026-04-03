import type { CurrentUser, GoogleInstallStatus, PortfolioRefreshRun, SlackInstallStatus } from "@si/domain";
import { useEffect, useState } from "react";
import {
  getCurrentUser,
  getGoogleStatus,
  getLatestPortfolioRefresh,
  getSlackStatus,
  launchPortfolioRefresh,
  runAllEvaluations,
} from "../api/client";

function asNumber(value: unknown): number {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

export function OperationsPage() {
  const [currentUser, setCurrentUser] = useState<CurrentUser | null>(null);
  const [slackStatus, setSlackStatus] = useState<SlackInstallStatus | null>(null);
  const [googleStatus, setGoogleStatus] = useState<GoogleInstallStatus | null>(null);
  const [latestRefresh, setLatestRefresh] = useState<PortfolioRefreshRun | null>(null);
  const [busy, setBusy] = useState("");

  async function load() {
    const [me, slack, google, refresh] = await Promise.all([
      getCurrentUser(),
      getSlackStatus(),
      getGoogleStatus(),
      getLatestPortfolioRefresh(),
    ]);
    setCurrentUser(me);
    setSlackStatus(slack);
    setGoogleStatus(google);
    setLatestRefresh(refresh);
  }

  useEffect(() => {
    void load();
  }, []);

  const canOperate =
    currentUser?.type === "service_token" || currentUser?.appRole === "admin";
  const refreshSummary = (latestRefresh?.summary ?? {}) as Record<string, unknown>;

  async function handleLaunchRefresh() {
    setBusy("Starting portfolio refresh...");
    await launchPortfolioRefresh();
    await load();
    setBusy("Portfolio refresh started.");
  }

  async function handleRerunAssessments() {
    setBusy("Launching portfolio-wide KPI + assessment rerun...");
    await runAllEvaluations({ refreshKpis: true });
    setBusy("Portfolio-wide KPI + assessment rerun started.");
  }

  return (
    <div className="page-stack">
      <section className="hero-card panel-tonal">
        <div>
          <div className="eyebrow">Operations</div>
          <h2>Monitor integrations and system health</h2>
          <p>
            Keep the pipes visible here so the executive-facing portfolio surfaces can stay focused
            on decisions, not plumbing.
          </p>
        </div>
        {canOperate ? (
          <div className="hero-actions">
            <button className="primary-button" onClick={() => void handleLaunchRefresh()}>
              Start Portfolio Refresh
            </button>
            <button className="secondary-button" onClick={() => void handleRerunAssessments()}>
              Rerun KPI + Assessment
            </button>
          </div>
        ) : null}
      </section>

      {busy ? (
        <section className="notice-card notice-info">
          <strong>Operations</strong>
          <p className="muted">{busy}</p>
        </section>
      ) : null}

      <section className="stats-grid">
        <article className="stat-card">
          <span className="metric-label">Slack</span>
          <strong>{slackStatus?.connected ? "Connected" : "Needs install"}</strong>
          <div className="metric-subtext">{slackStatus?.teamName ?? "Workspace install pending"}</div>
        </article>
        <article className="stat-card">
          <span className="metric-label">Google</span>
          <strong>{googleStatus?.connected ? "Connected" : "Needs install"}</strong>
          <div className="metric-subtext">{googleStatus?.email ?? "Workspace install pending"}</div>
        </article>
        <article className="stat-card">
          <span className="metric-label">Latest refresh</span>
          <strong>{latestRefresh?.status ?? "Never run"}</strong>
          <div className="metric-subtext">
            {latestRefresh?.createdAt
              ? new Date(latestRefresh.createdAt).toLocaleString()
              : "No portfolio refresh recorded yet"}
          </div>
        </article>
      </section>

      <section className="panel">
        <div className="section-header">
          <h2>Portfolio Refresh Status</h2>
        </div>
        {!latestRefresh ? (
          <p className="muted">No portfolio refresh has been run yet.</p>
        ) : (
          <div className="stats-grid">
            <article className="stat-card">
              <span className="metric-label">Processed</span>
              <strong>{asNumber(refreshSummary.processedCount)}</strong>
            </article>
            <article className="stat-card">
              <span className="metric-label">Total</span>
              <strong>{asNumber(refreshSummary.totalCount)}</strong>
            </article>
            <article className="stat-card">
              <span className="metric-label">Failures</span>
              <strong>{asNumber(refreshSummary.failureCount)}</strong>
            </article>
          </div>
        )}
      </section>
    </div>
  );
}
