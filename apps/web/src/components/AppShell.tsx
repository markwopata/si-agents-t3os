import type { CurrentUser } from "@si/domain";
import { useEffect, useMemo, useState } from "react";
import { Link, NavLink, useLocation } from "react-router-dom";
import { getApiBaseUrl, getCurrentUser } from "../api/client";
import type { T3osShellState } from "../lib/t3os";

interface AppShellProps {
  children: React.ReactNode;
  shellState: T3osShellState;
}

interface NavItem {
  label: string;
  to: string;
  badge: string;
  description: string;
}

const PRIMARY_NAV: NavItem[] = [
  {
    label: "Portfolio HQ",
    to: "/",
    badge: "P",
    description: "Ranked portfolio, exceptions, and executive actions",
  },
  {
    label: "Initiatives",
    to: "/initiatives",
    badge: "I",
    description: "Create, edit, and manage the SI registry",
  },
  {
    label: "Directory",
    to: "/contacts",
    badge: "D",
    description: "T3OS-backed contacts, ownership, and assignments",
  },
  {
    label: "Settings",
    to: "/settings",
    badge: "S",
    description: "Import, governance, integrations, and operations",
  },
];

const SETTINGS_NAV: NavItem[] = [
  {
    label: "Overview",
    to: "/settings",
    badge: "O",
    description: "Admin surfaces and governance entrypoints",
  },
  {
    label: "Import",
    to: "/settings/import",
    badge: "I",
    description: "Workbook-backed registry ingest",
  },
  {
    label: "Knowledge",
    to: "/settings/knowledge",
    badge: "K",
    description: "Global SI operating model and evaluation guidance",
  },
  {
    label: "Operations",
    to: "/settings/operations",
    badge: "R",
    description: "Integrations, refresh state, and run health",
  },
];

function getPageMeta(pathname: string) {
  if (pathname === "/") {
    return {
      eyebrow: "Portfolio HQ",
      title: "Strategic Initiative command center",
      description:
        "Monitor the ranked stack, catch exceptions early, and steer the portfolio from one executive surface.",
    };
  }

  if (pathname === "/initiatives") {
    return {
      eyebrow: "Initiative Registry",
      title: "Create and manage the SI portfolio",
      description:
        "Review the full registry, filter by ownership and status, and launch new strategic initiatives without leaving the control room.",
    };
  }

  if (pathname === "/initiatives/new") {
    return {
      eyebrow: "Initiative Intake",
      title: "Create a new strategic initiative",
      description:
        "Stand up a new SI record, seed the operating context, and route it into the portfolio with the right ownership from day one.",
    };
  }

  if (pathname.startsWith("/initiatives/")) {
    return {
      eyebrow: "Initiative Control Room",
      title: "Operate one initiative end to end",
      description:
        "Move between summary, ownership, evidence, assessment, and settings without losing the executive thread.",
    };
  }

  if (pathname === "/contacts") {
    return {
      eyebrow: "Directory",
      title: "Use T3OS as the system of record for ownership",
      description:
        "Browse workspace contacts, map people into SI roles, and keep the portfolio aligned with the canonical T3OS directory.",
    };
  }

  if (pathname.startsWith("/settings/operations")) {
    return {
      eyebrow: "Settings",
      title: "Observe integrations and system health",
      description:
        "Track refresh runs, connection state, and admin operations without crowding the Portfolio HQ experience.",
    };
  }

  if (pathname.startsWith("/settings/import")) {
    return {
      eyebrow: "Settings",
      title: "Import the workbook into the live registry",
      description:
        "Use workbook ingest as a secondary admin flow when you need to seed or reconcile the initiative registry.",
    };
  }

  if (pathname.startsWith("/settings/knowledge")) {
    return {
      eyebrow: "Settings",
      title: "Maintain the global SI operating model",
      description:
        "Keep the evaluation philosophy, leadership expectations, and scoring guidance aligned with how SIs should really operate.",
    };
  }

  return {
    eyebrow: "Settings",
    title: "System governance and admin controls",
    description:
      "Keep import, knowledge, integrations, and operational plumbing organized away from the day-to-day decision surfaces.",
  };
}

function UserSummary({ currentUser }: { currentUser: CurrentUser | null }) {
  return (
    <div className="meta-card shell-user-card">
      <div className="meta-label">Identity</div>
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
  );
}

export function AppShell({ children, shellState }: AppShellProps) {
  const [currentUser, setCurrentUser] = useState<CurrentUser | null>(null);
  const location = useLocation();

  useEffect(() => {
    void getCurrentUser()
      .then(setCurrentUser)
      .catch(() => setCurrentUser(null));
  }, [shellState.workspaceId, shellState.isReady, shellState.isFallback]);

  const pageMeta = useMemo(() => getPageMeta(location.pathname), [location.pathname]);
  const canCreateInitiative =
    currentUser?.type === "service_token" || currentUser?.appRole === "executive";
  const showingSettingsNav = location.pathname.startsWith("/settings");

  return (
    <div className="workspace-shell">
      <aside className="workspace-rail">
        <div className="rail-brand-card">
          <div className="rail-logo">SI</div>
          <div>
            <div className="shell-badge-row">
              <span className="shell-badge">EquipmentShare</span>
              <span className="shell-badge shell-badge-muted">T3OS</span>
            </div>
            <h1>SI Management</h1>
            <p>Executive control surface for portfolio decisions, assignments, and governance.</p>
          </div>
        </div>

        <nav className="rail-nav-group">
          <div className="rail-group-label">Primary</div>
          {PRIMARY_NAV.map((item) => (
            <NavLink key={item.to} to={item.to} end={item.to === "/"} className="rail-nav-link">
              <span className="rail-nav-badge">{item.badge}</span>
              <span className="rail-nav-copy">
                <span className="rail-nav-title">{item.label}</span>
                <span className="rail-nav-description">{item.description}</span>
              </span>
            </NavLink>
          ))}
        </nav>

        {showingSettingsNav ? (
          <nav className="rail-nav-group rail-subnav-group">
            <div className="rail-group-label">Settings</div>
            {SETTINGS_NAV.map((item) => (
              <NavLink key={item.to} to={item.to} end={item.to === "/settings"} className="rail-nav-link rail-subnav-link">
                <span className="rail-nav-badge">{item.badge}</span>
                <span className="rail-nav-copy">
                  <span className="rail-nav-title">{item.label}</span>
                  <span className="rail-nav-description">{item.description}</span>
                </span>
              </NavLink>
            ))}
          </nav>
        ) : null}

        <div className="rail-spacer" />

        <div className="meta-card workspace-chip-card">
          <div className="meta-label">Workspace</div>
          <div className="meta-value">
            {shellState.workspaceName ?? shellState.workspaceId ?? "No active workspace"}
          </div>
          <div className="meta-label">Session</div>
          <div className="meta-value">{shellState.modeLabel}</div>
        </div>

        <UserSummary currentUser={currentUser} />

        {shellState.isFallback ? (
          <div className="notice-card notice-warning rail-notice">
            <strong>T3OS shell unavailable</strong>
            <p className="muted">
              This local session is using the engineering fallback. Open SI Management through T3OS
              staging for workspace-aware navigation and identity.
            </p>
          </div>
        ) : null}
      </aside>

      <div className="workspace-stage">
        <header className="workspace-header">
          <div className="workspace-header-copy">
            <div className="eyebrow">{pageMeta.eyebrow}</div>
            <h2>{pageMeta.title}</h2>
            <p>{pageMeta.description}</p>
          </div>
          <div className="workspace-header-actions">
            <span className="shell-badge shell-badge-muted">
              {shellState.workspaceName ?? shellState.workspaceId ?? "Workspace pending"}
            </span>
            {canCreateInitiative ? (
              <Link className="primary-button" to="/initiatives/new">
                New Initiative
              </Link>
            ) : null}
          </div>
        </header>

        <main className="workspace-main">{children}</main>
      </div>
    </div>
  );
}
