import type { InitiativeDetail } from "@si/domain";
import { formatStatusLabel } from "../lib/status-label";

interface OpinionPanelProps {
  initiative: InitiativeDetail;
}

export function OpinionPanel({ initiative }: OpinionPanelProps) {
  const latest = initiative.observations[0];
  const history = initiative.observations.slice(1, 6);

  if (!latest) {
    return (
      <section className="panel" id="latest-opinion">
        <div className="section-header">
          <h2>Agent Opinion</h2>
        </div>
        <p className="muted">No evaluation has run yet for this initiative.</p>
      </section>
    );
  }

  return (
    <section className="panel" id="latest-opinion">
      <div className="section-header">
        <h2>Latest Agent Opinion</h2>
        <span className={`status-pill status-${latest.statusRecommendation}`}>
          {formatStatusLabel(latest.statusRecommendation)}
        </span>
      </div>
      <div className="metric-strip">
        <div>
          <div className="metric-label">Confidence</div>
          <div className="metric-value">{Math.round(latest.confidenceScore * 100)}%</div>
        </div>
        <div>
          <div className="metric-label">Evaluated</div>
          <div className="metric-value">
            {new Date(latest.createdAt).toLocaleString()}
          </div>
        </div>
      </div>
      <p>{latest.progressAssessment}</p>
      <div className="two-column">
        <div>
          <h3>Top Blockers</h3>
          <ul className="flat-list">
            {latest.topBlockers.length === 0 ? <li>No blockers captured.</li> : null}
            {latest.topBlockers.map((blocker) => (
              <li key={blocker}>{blocker}</li>
            ))}
          </ul>
        </div>
        <div>
          <h3>Suggested Next Actions</h3>
          <ul className="flat-list">
            {latest.suggestedNextActions.map((action) => (
              <li key={action}>{action}</li>
            ))}
          </ul>
        </div>
      </div>
      <details>
        <summary>Evidence summary</summary>
        <pre className="evidence-pre">{latest.evidenceSummary}</pre>
      </details>
      {latest.evidenceReferences.length > 0 ? (
        <div className="stack-list">
          <h3>Evidence References</h3>
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
      ) : null}
      {history.length > 0 ? (
        <div className="history-stack">
          <h3>Recent History</h3>
          {history.map((entry) => (
            <div className="history-item" key={entry.id}>
              <span className={`status-pill status-${entry.statusRecommendation}`}>
                {formatStatusLabel(entry.statusRecommendation)}
              </span>
              <span className="muted">{new Date(entry.createdAt).toLocaleString()}</span>
            </div>
          ))}
        </div>
      ) : null}
    </section>
  );
}
