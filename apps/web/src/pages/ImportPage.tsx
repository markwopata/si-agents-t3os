import { useEffect, useState } from "react";
import type { CurrentUser, ImportSummary } from "@si/domain";
import { getCurrentUser, importWorkbook } from "../api/client";

export function ImportPage() {
  const [currentUser, setCurrentUser] = useState<CurrentUser | null>(null);
  const [file, setFile] = useState<File | undefined>();
  const [summary, setSummary] = useState<ImportSummary | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const canImport = currentUser?.type === "service_token" || currentUser?.appRole === "admin";

  useEffect(() => {
    void getCurrentUser()
      .then(setCurrentUser)
      .catch(() => setCurrentUser(null));
  }, []);

  async function handleImport(useDefaultPath: boolean) {
    try {
      setBusy(true);
      setError("");
      const result = await importWorkbook(useDefaultPath ? undefined : file);
      setSummary(result);
    } catch (caughtError) {
      setError(caughtError instanceof Error ? caughtError.message : "Import failed");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="page-stack">
      <section className="panel">
        <div className="section-header">
          <h2>Import Strategic Initiatives Workbook</h2>
        </div>
        <p className="muted">
          Use the default workbook path on disk or upload a workbook directly from your browser.
        </p>
        {!canImport ? (
          <p className="muted">Workbook import is limited to admins.</p>
        ) : null}
        <div className="button-row">
          <button
            className="primary-button"
            disabled={busy || !canImport}
            onClick={() => void handleImport(true)}
          >
            Import Default Workbook
          </button>
          <input
            type="file"
            accept=".xlsx"
            disabled={!canImport}
            onChange={(event) => setFile(event.target.files?.[0])}
          />
          <button
            className="secondary-button"
            disabled={busy || !file || !canImport}
            onClick={() => void handleImport(false)}
          >
            Upload Workbook
          </button>
        </div>
        {error ? <p className="error-text">{error}</p> : null}
      </section>

      {summary ? (
        <section className="panel">
          <div className="section-header">
            <h2>Import Summary</h2>
          </div>
          <div className="stats-grid">
            <article className="stat-card">
              <span className="metric-label">Batch</span>
              <strong>{summary.batchId}</strong>
            </article>
            <article className="stat-card">
              <span className="metric-label">Imported</span>
              <strong>{summary.importedCount}</strong>
            </article>
            <article className="stat-card">
              <span className="metric-label">Skipped</span>
              <strong>{summary.skippedCount}</strong>
            </article>
          </div>
          <ul className="flat-list">
            {summary.warnings.length === 0 ? <li>No warnings.</li> : null}
            {summary.warnings.map((warning) => (
              <li key={warning}>{warning}</li>
            ))}
          </ul>
        </section>
      ) : null}
    </div>
  );
}
