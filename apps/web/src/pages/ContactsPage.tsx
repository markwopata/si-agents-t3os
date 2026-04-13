import type { ContactSummary } from "@si/domain";
import { useEffect, useMemo, useState } from "react";
import { listPlatformContacts } from "../api/client";
import {
  getCurrentWorkspaceId,
  getCurrentWorkspaceName,
  subscribeToWorkspaceChanges,
} from "../lib/t3os";

type ContactTypeFilter = "All" | "PERSON" | "BUSINESS";
type ContactsView = "table" | "grid";

const VIEW_STORAGE_KEY = "si-contacts-view";

function formatContactTimestamp(value: string | null): string {
  if (!value) {
    return "Recently synced";
  }

  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return "Recently synced";
  }

  return parsed.toLocaleDateString(undefined, {
    month: "short",
    day: "numeric",
    year: "numeric",
  });
}

function getInitials(name: string): string {
  return name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? "")
    .join("");
}

export function ContactsPage() {
  const [contacts, setContacts] = useState<ContactSummary[]>([]);
  const [workspaceId, setWorkspaceId] = useState<string | null>(() => getCurrentWorkspaceId());
  const [workspaceName, setWorkspaceName] = useState<string | null>(() => getCurrentWorkspaceName());
  const [query, setQuery] = useState("");
  const [filter, setFilter] = useState<ContactTypeFilter>("All");
  const [view, setView] = useState<ContactsView>("table");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const stored = window.localStorage.getItem(VIEW_STORAGE_KEY);
    if (stored === "table" || stored === "grid") {
      setView(stored);
    }
  }, []);

  useEffect(() => {
    return subscribeToWorkspaceChanges(() => {
      setWorkspaceId(getCurrentWorkspaceId());
      setWorkspaceName(getCurrentWorkspaceName());
    });
  }, []);

  useEffect(() => {
    if (!workspaceId) {
      setContacts([]);
      setLoading(false);
      setError("");
      return;
    }

    const activeWorkspaceId = workspaceId;
    let cancelled = false;

    async function loadContacts() {
      try {
        setLoading(true);
        setError("");
        const response = await listPlatformContacts(
          activeWorkspaceId,
          filter === "All" ? undefined : filter,
        );
        if (!cancelled) {
          setContacts(response.items);
        }
      } catch (caughtError) {
        if (!cancelled) {
          setContacts([]);
          setError(
            caughtError instanceof Error
              ? caughtError.message
              : "Unable to load workspace contacts.",
          );
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    void loadContacts();

    return () => {
      cancelled = true;
    };
  }, [filter, workspaceId]);

  const filteredContacts = useMemo(() => {
    const search = query.trim().toLowerCase();
    const sorted = [...contacts].sort((left, right) => left.name.localeCompare(right.name));

    if (!search) {
      return sorted;
    }

    return sorted.filter((contact) => {
      const haystack = [
        contact.name,
        contact.email ?? "",
        contact.phone ?? "",
        contact.role ?? "",
        contact.businessName ?? "",
        contact.address ?? "",
      ]
        .join(" ")
        .toLowerCase();

      return haystack.includes(search);
    });
  }, [contacts, query]);

  const stats = useMemo(() => {
    const total = contacts.length;
    const people = contacts.filter((contact) => contact.contactType === "PERSON").length;
    const businesses = contacts.filter((contact) => contact.contactType === "BUSINESS").length;

    return { total, people, businesses };
  }, [contacts]);

  function handleViewChange(nextView: ContactsView) {
    setView(nextView);
    window.localStorage.setItem(VIEW_STORAGE_KEY, nextView);
  }

  return (
    <div className="page-stack">
      {!workspaceId ? (
        <section className="notice-card notice-warning">
          <strong>No T3OS workspace is active.</strong>
          <p className="muted">
            Open SI Management inside T3OS staging so the workspace directory can provide the same
            contacts catalog used by the T3OS contacts application.
          </p>
        </section>
      ) : null}

      <section className="stats-grid">
        <article className="stat-card">
          <span className="metric-label">Total Contacts</span>
          <strong>{loading ? "..." : stats.total}</strong>
        </article>
        <article className="stat-card">
          <span className="metric-label">Individuals</span>
          <strong>{loading ? "..." : stats.people}</strong>
        </article>
        <article className="stat-card">
          <span className="metric-label">Businesses</span>
          <strong>{loading ? "..." : stats.businesses}</strong>
        </article>
      </section>

      <section className="panel">
        <div className="section-header">
          <div>
            <h2>Browse Contacts</h2>
            <p className="panel-subtitle">
              Search workspace participants, businesses, and linked company records.
            </p>
          </div>
          <div className="contacts-header-actions">
            <span className="shell-badge shell-badge-muted">
              {workspaceName ?? workspaceId ?? "Workspace pending"}
            </span>
            <button
              className="ghost-button"
              disabled={!workspaceId || loading}
              onClick={() => {
                setWorkspaceId(getCurrentWorkspaceId());
                setWorkspaceName(getCurrentWorkspaceName());
              }}
            >
              Refresh
            </button>
          </div>
        </div>

        <div className="contacts-toolbar">
          <div className="contacts-search">
            <input
              type="search"
              value={query}
              placeholder="Search by name, email, role, business, or address"
              onChange={(event) => setQuery(event.target.value)}
            />
          </div>

          <div className="contacts-toolbar-actions">
            <div className="contacts-filter-row">
              {(["All", "PERSON", "BUSINESS"] as ContactTypeFilter[]).map((option) => (
                <button
                  key={option}
                  className={option === filter ? "primary-button" : "ghost-button"}
                  onClick={() => setFilter(option)}
                >
                  {option === "All"
                    ? "All"
                    : option === "PERSON"
                      ? "Individuals"
                      : "Businesses"}
                </button>
              ))}
            </div>

            <div className="contacts-view-toggle">
              <button
                className={view === "table" ? "primary-button" : "ghost-button"}
                onClick={() => handleViewChange("table")}
              >
                Table
              </button>
              <button
                className={view === "grid" ? "primary-button" : "ghost-button"}
                onClick={() => handleViewChange("grid")}
              >
                Grid
              </button>
            </div>
          </div>
        </div>

        {error ? (
          <div className="notice-card notice-warning" style={{ marginTop: "0.9rem" }}>
            <strong>Contacts failed to load.</strong>
            <p className="muted">{error}</p>
          </div>
        ) : null}

        {loading ? (
          <div className="contacts-empty-state">
            <strong>Loading workspace contacts...</strong>
            <p className="muted">Pulling people and business records from the active T3OS workspace.</p>
          </div>
        ) : filteredContacts.length === 0 ? (
          <div className="contacts-empty-state">
            <strong>No contacts matched this view.</strong>
            <p className="muted">
              Try broadening the search or switching back to all contact types for the workspace.
            </p>
          </div>
        ) : view === "grid" ? (
          <div className="contacts-card-grid">
            {filteredContacts.map((contact) => (
              <article key={contact.id} className="contact-card">
                <div className={`contact-avatar contact-avatar-${contact.contactType.toLowerCase()}`}>
                  {getInitials(contact.name)}
                </div>
                <div className="contact-card-header">
                  <div>
                    <h3>{contact.name}</h3>
                    <p className="muted">
                      {contact.contactType === "PERSON" ? "Individual contact" : "Business contact"}
                    </p>
                  </div>
                  <span className={`status-pill contact-type-pill contact-type-${contact.contactType.toLowerCase()}`}>
                    {contact.contactType === "PERSON" ? "Person" : "Business"}
                  </span>
                </div>

                <dl className="contact-card-details">
                  {contact.email ? (
                    <div>
                      <dt>Email</dt>
                      <dd>{contact.email}</dd>
                    </div>
                  ) : null}
                  {contact.phone ? (
                    <div>
                      <dt>Phone</dt>
                      <dd>{contact.phone}</dd>
                    </div>
                  ) : null}
                  {contact.role ? (
                    <div>
                      <dt>Role</dt>
                      <dd>{contact.role}</dd>
                    </div>
                  ) : null}
                  {contact.businessName ? (
                    <div>
                      <dt>Business</dt>
                      <dd>{contact.businessName}</dd>
                    </div>
                  ) : null}
                  {contact.address ? (
                    <div>
                      <dt>Address</dt>
                      <dd>{contact.address}</dd>
                    </div>
                  ) : null}
                </dl>

                <div className="contact-card-footer">
                  <span className="muted">Updated {formatContactTimestamp(contact.updatedAt)}</span>
                </div>
              </article>
            ))}
          </div>
        ) : (
          <div className="table-wrap" style={{ marginTop: "0.95rem" }}>
            <table className="data-table contacts-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Type</th>
                  <th>Role / Business</th>
                  <th>Email / Phone</th>
                  <th>Address</th>
                  <th>Updated</th>
                </tr>
              </thead>
              <tbody>
                {filteredContacts.map((contact) => (
                  <tr key={contact.id}>
                    <td>
                      <div className="contact-table-name">
                        <div
                          className={`contact-avatar contact-avatar-${contact.contactType.toLowerCase()} contact-avatar-small`}
                        >
                          {getInitials(contact.name)}
                        </div>
                        <div>
                          <strong>{contact.name}</strong>
                          <div className="muted">{contact.id}</div>
                        </div>
                      </div>
                    </td>
                    <td>
                      <span
                        className={`status-pill contact-type-pill contact-type-${contact.contactType.toLowerCase()}`}
                      >
                        {contact.contactType === "PERSON" ? "Person" : "Business"}
                      </span>
                    </td>
                    <td>{contact.role ?? contact.businessName ?? "Not provided"}</td>
                    <td>
                      <div>{contact.email ?? "No email"}</div>
                      <div className="muted">{contact.phone ?? "No phone"}</div>
                    </td>
                    <td>{contact.address ?? "Not provided"}</td>
                    <td>{formatContactTimestamp(contact.updatedAt)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </div>
  );
}
