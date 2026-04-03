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
}

const PRIMARY_NAV: NavItem[] = [
  {
    label: "Portfolio HQ",
    to: "/",
    badge: "P",
  },
  {
    label: "Initiatives",
    to: "/initiatives",
    badge: "I",
  },
  {
    label: "Contacts",
    to: "/contacts",
    badge: "D",
  },
  {
    label: "Settings",
    to: "/settings",
    badge: "S",
  },
];

const SETTINGS_NAV: NavItem[] = [
  {
    label: "Overview",
    to: "/settings",
    badge: "O",
  },
  {
    label: "API Access",
    to: "/settings/tokens",
    badge: "A",
  },
  {
    label: "Import",
    to: "/settings/import",
    badge: "I",
  },
  {
    label: "Knowledge",
    to: "/settings/knowledge",
    badge: "K",
  },
  {
    label: "Operations",
    to: "/settings/operations",
    badge: "R",
  },
];

function getPageMeta(pathname: string) {
  if (pathname === "/") {
    return {
      eyebrow: "Portfolio HQ",
      title: "Portfolio Overview",
      description: "Review rankings, exceptions, and current actions across the initiative portfolio.",
    };
  }

  if (pathname === "/initiatives") {
    return {
      eyebrow: "Initiative Registry",
      title: "Initiative Registry",
      description: "Filter, compare, and manage initiative records by owner, status, and evidence.",
    };
  }

  if (pathname === "/initiatives/new") {
    return {
      eyebrow: "Initiative Intake",
      title: "New Initiative",
      description: "Create an initiative record and assign the initial operating context.",
    };
  }

  if (pathname.startsWith("/initiatives/")) {
    return {
      eyebrow: "Initiative Review",
      title: "Initiative Detail",
      description: "Assess one initiative across summary, ownership, evidence, and configuration.",
    };
  }

  if (pathname === "/contacts") {
    return {
      eyebrow: "Directory",
      title: "Contact Directory",
      description: "Analyze workspace contacts and maintain ownership mappings against the T3OS directory.",
    };
  }

  if (pathname.startsWith("/settings/operations")) {
    return {
      eyebrow: "Settings",
      title: "Operations",
      description: "Track integration state, refresh activity, and system health.",
    };
  }

  if (pathname.startsWith("/settings/tokens")) {
    return {
      eyebrow: "Settings",
      title: "API Access",
      description: "Create personal agent tokens and review workspace token inventory.",
    };
  }

  if (pathname.startsWith("/settings/import")) {
    return {
      eyebrow: "Settings",
      title: "Workbook Import",
      description: "Load or reconcile registry data from the workbook import flow.",
    };
  }

  if (pathname.startsWith("/settings/knowledge")) {
    return {
      eyebrow: "Settings",
      title: "Knowledge Model",
      description: "Maintain evaluation guidance, operating rules, and reference context.",
    };
  }

  return {
    eyebrow: "Settings",
    title: "Settings Overview",
    description: "Review administrative configuration, imports, knowledge, and operational controls.",
  };
}

function getIdentityLabel(currentUser: CurrentUser | null): string {
  return currentUser?.displayName ?? currentUser?.email ?? currentUser?.id ?? "Unknown";
}

function getInitials(value: string): string {
  return value
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? "")
    .join("") || "U";
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
    currentUser?.type === "service_token" || currentUser?.appRole === "admin";
  const showingSettingsNav = location.pathname.startsWith("/settings");
  const identityLabel = getIdentityLabel(currentUser);

  return (
    <div className={`workspace-frame${shellState.isFallback ? "" : " workspace-frame-embedded"}`}>
      {shellState.isFallback ? (
        <header className="workspace-topbar">
          <div className="workspace-topbar-left">
            <div className="workspace-topbar-mark">SI</div>
            <div className="workspace-topbar-brand">
              <span className="workspace-topbar-company">EquipmentShare</span>
              <span className="workspace-topbar-divider" />
              <span className="workspace-topbar-app">SI Management</span>
            </div>
          </div>
          <div className="workspace-topbar-right" aria-hidden="true">
            <span className="workspace-topbar-icon">o</span>
            <span className="workspace-topbar-icon">*</span>
            <span className="workspace-topbar-icon">[]</span>
            <span className="workspace-topbar-avatar">{getInitials(identityLabel)}</span>
          </div>
        </header>
      ) : null}

      <div className="workspace-shell">
        <aside className="workspace-rail">
          <div className="rail-brand-inline">
            <div className="rail-logo">SI</div>
            <div className="rail-brand-title">SI Management</div>
          </div>

          <nav className="rail-nav-group">
            {PRIMARY_NAV.map((item) => (
              <NavLink key={item.to} to={item.to} end={item.to === "/"} className="rail-nav-link">
                <span className="rail-nav-main">
                  <span className="rail-nav-badge">{item.badge}</span>
                  <span className="rail-nav-title">{item.label}</span>
                </span>
                {item.to === "/settings" ? (
                  <span className="rail-nav-chevron" aria-hidden="true">
                    &gt;
                  </span>
                ) : null}
              </NavLink>
            ))}
          </nav>

          {showingSettingsNav ? (
            <nav className="rail-nav-group rail-subnav-group">
              {SETTINGS_NAV.map((item) => (
                <NavLink
                  key={item.to}
                  to={item.to}
                  end={item.to === "/settings"}
                  className="rail-nav-link rail-subnav-link"
                >
                  <span className="rail-nav-main">
                    <span className="rail-nav-badge">{item.badge}</span>
                    <span className="rail-nav-title">{item.label}</span>
                  </span>
                </NavLink>
              ))}
            </nav>
          ) : null}

          <div className="rail-divider" />

          <div className="rail-footer">
            <div className="rail-footer-group">
              <div className="meta-label">Workspace</div>
              <div className="meta-value">
                {shellState.workspaceName ?? shellState.workspaceId ?? "No active workspace"}
              </div>
            </div>
            <div className="rail-footer-group">
              <div className="meta-label">Signed In</div>
              <div className="meta-value">{identityLabel}</div>
            </div>
            {shellState.isFallback ? (
              <div className="rail-footer-notice">
                Open SI Management through T3OS staging for workspace-aware navigation.
              </div>
            ) : null}
          </div>
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
    </div>
  );
}
