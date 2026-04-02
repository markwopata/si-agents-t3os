import type { CurrentUser } from "@si/domain";
import { useEffect, useState } from "react";
import { NavLink } from "react-router-dom";
import { getApiBaseUrl, getCurrentUser } from "../api/client";
import type { T3osShellState } from "../lib/t3os";

interface AppShellProps {
  children: React.ReactNode;
  shellState: T3osShellState;
}

export function AppShell({ children, shellState }: AppShellProps) {
  const [currentUser, setCurrentUser] = useState<CurrentUser | null>(null);

  useEffect(() => {
    void getCurrentUser()
      .then(setCurrentUser)
      .catch(() => setCurrentUser(null));
  }, [shellState.workspaceId, shellState.isReady, shellState.isFallback]);

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand-card">
          <div className="shell-badge-row">
            <span className="shell-badge">EquipmentShare</span>
            <span className="shell-badge shell-badge-muted">T3OS</span>
          </div>
          <h1>SI Control Room</h1>
          <p>
            Strategic initiative command center for evidence, ranking, ownership, and AI-assisted
            review.
          </p>
        </div>

        <nav className="nav-list">
          <NavLink to="/" end className="nav-link">
            Overview
          </NavLink>
          {currentUser?.type === "service_token" || currentUser?.appRole === "executive" ? (
            <NavLink to="/import" className="nav-link">
              Import Workbook
            </NavLink>
          ) : null}
          <NavLink to="/knowledge/global" className="nav-link">
            Global Knowledge
          </NavLink>
        </nav>

        <div className="meta-card">
          <div className="meta-label">Identity</div>
          <div className="meta-value">{shellState.modeLabel}</div>
          <div className="meta-label">Workspace</div>
          <div className="meta-value">
            {shellState.workspaceName ?? shellState.workspaceId ?? "No active workspace"}
          </div>
          <div className="meta-label">User</div>
          <div className="meta-value">
            {currentUser?.displayName ?? currentUser?.email ?? currentUser?.id ?? "Unknown"}
          </div>
          <div className="meta-label">Role</div>
          <div className="meta-value">{currentUser?.appRole ?? currentUser?.type ?? "Unknown"}</div>
          <div className="meta-label">Auth Source</div>
          <div className="meta-value">{currentUser?.authSource ?? "Unknown"}</div>
          <div className="meta-label">API</div>
          <div className="meta-value">{getApiBaseUrl()}</div>
        </div>

        {shellState.isFallback ? (
          <div className="notice-card notice-warning">
            <strong>T3OS is not active</strong>
            <p className="muted">
              This local session is using the engineering fallback. For normal use, open the app through
              T3OS staging so the app bar, workspace selector, and T3OS identity are the primary session.
            </p>
          </div>
        ) : null}
      </aside>

      <main className="main-content">{children}</main>
    </div>
  );
}
