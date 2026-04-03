import type { InitiativeDetail } from "@si/domain";
import { Link } from "react-router-dom";
import { formatStatusLabel } from "../lib/status-label";

interface OpinionDrilldownModalProps {
  initiative: InitiativeDetail | null;
  loading: boolean;
  error: string;
  onClose: () => void;
}

export function OpinionDrilldownModal({
  initiative,
  loading,
  error,
  onClose,
}: OpinionDrilldownModalProps) {
  if (!initiative && !loading && !error) {
    return null;
  }

  const latest = initiative?.observations[0] ?? null;
  const history = initiative?.observations.slice(1, 6) ?? [];

  return (
    <div className="modal-backdrop" role="dialog" aria-modal="true" aria-label="Opinion drilldown">
      <div className="modal-card">
        <div className="section-header">
          <div>
            <div className="eyebrow">Opinion Drilldown</div>
            <h2>
              {initiative ? `${initiative.code} ${initiative.title}` : "Loading analysis"}
            </h2>
          </div>
          <button className="ghost-button" onClick={onClose}>
            Close
          </button>
        </div>

        {loading ? <p className="muted">Loading the latest opinion analysis...</p> : null}
        {error ? <p className="error-text">{error}</p> : null}

        {!loading && !error && initiative && !latest ? (
          <p className="muted">No evaluation has run yet for this initiative.</p>
        ) : null}

        {!loading && !error && initiative && latest ? (
          <div className="page-stack">
            <div className="metric-strip">
              <div>
                <div className="metric-label">Status</div>
                <div className="metric-value">
                  <span className={`status-pill status-${latest.statusRecommendation}`}>
                    {formatStatusLabel(latest.statusRecommendation)}
                  </span>
                </div>
              </div>
              <div>
                <div className="metric-label">Confidence</div>
                <div className="metric-value">{Math.round(latest.confidenceScore * 100)}%</div>
              </div>
              <div>
                <div className="metric-label">Evaluated</div>
                <div className="metric-value">{new Date(latest.createdAt).toLocaleString()}</div>
              </div>
            </div>

            <section className="modal-section">
              <h3>Assessment</h3>
              <p>{latest.progressAssessment}</p>
            </section>

            <div className="two-column">
              <section className="modal-section">
                <h3>Top Blockers</h3>
                <ul className="flat-list">
                  {latest.topBlockers.length === 0 ? <li>No blockers captured.</li> : null}
                  {latest.topBlockers.map((blocker) => (
                    <li key={blocker}>{blocker}</li>
                  ))}
                </ul>
              </section>

              <section className="modal-section">
                <h3>Suggested Next Actions</h3>
                <ul className="flat-list">
                  {latest.suggestedNextActions.length === 0 ? <li>No next actions captured.</li> : null}
                  {latest.suggestedNextActions.map((action) => (
                    <li key={action}>{action}</li>
                  ))}
                </ul>
              </section>
            </div>

            <section className="modal-section">
              <h3>Evidence Summary</h3>
              <pre className="evidence-pre">{latest.evidenceSummary}</pre>
            </section>

            {latest.evidenceReferences.length > 0 ? (
              <section className="modal-section">
                <h3>Evidence References</h3>
                <div className="stack-list">
                  {latest.evidenceReferences.map((reference) => (
                    <div className="history-item evidence-item" key={reference.id}>
                      <div className="metric-label">{reference.sourceType.replace("_", " ")}</div>
                      <strong>{reference.title}</strong>
                      <div>{reference.excerpt}</div>
                      {reference.url ? (
                        <a href={reference.url} target="_blank" rel="noreferrer" className="table-link">
                          Open source
                        </a>
                      ) : null}
                    </div>
                  ))}
                </div>
              </section>
            ) : null}

            {history.length > 0 ? (
              <section className="modal-section">
                <h3>Recent Opinion History</h3>
                <div className="history-stack">
                  {history.map((entry) => (
                    <div className="history-item" key={entry.id}>
                      <span className={`status-pill status-${entry.statusRecommendation}`}>
                        {formatStatusLabel(entry.statusRecommendation)}
                      </span>
                      <span className="muted">{new Date(entry.createdAt).toLocaleString()}</span>
                    </div>
                  ))}
                </div>
              </section>
            ) : null}

            <div className="button-row">
              <Link
                className="secondary-button"
                to={`/initiatives/${initiative.id}#latest-opinion`}
                onClick={onClose}
              >
                Open Full Initiative Analysis
              </Link>
            </div>
          </div>
        ) : null}
      </div>
    </div>
  );
}
