import type { CurrentUser } from "@si/domain";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { createInitiative, getCurrentUser } from "../api/client";

const EMPTY_FORM = {
  code: "",
  title: "",
  objective: "",
  group: "",
  targetCadence: "",
  updateType: "",
  stage: "",
  lClass: "",
  progress: "",
  leadPerformance: "",
  administrationHealth: "",
  impactType: "",
  inCapPlan: "",
  isActive: "true",
};

export function InitiativeEditorPage() {
  const navigate = useNavigate();
  const [currentUser, setCurrentUser] = useState<CurrentUser | null>(null);
  const [form, setForm] = useState(EMPTY_FORM);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    void getCurrentUser()
      .then(setCurrentUser)
      .catch(() => setCurrentUser(null));
  }, []);

  const canCreate =
    currentUser?.type === "service_token" || currentUser?.appRole === "executive";

  async function handleCreate() {
    try {
      setBusy(true);
      setError("");
      const created = await createInitiative({
        code: form.code,
        title: form.title,
        objective: form.objective,
        group: form.group,
        targetCadence: form.targetCadence,
        updateType: form.updateType,
        stage: form.stage,
        lClass: form.lClass,
        progress: form.progress,
        leadPerformance: form.leadPerformance,
        administrationHealth: form.administrationHealth,
        impactType: form.impactType,
        inCapPlan: form.inCapPlan === "" ? null : form.inCapPlan === "true",
        isActive: form.isActive === "true",
      });
      navigate(`/initiatives/${created.id}`);
    } catch (caughtError) {
      setError(caughtError instanceof Error ? caughtError.message : "Unable to create initiative.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="page-stack">
      <section className="hero-card panel-tonal">
        <div>
          <div className="eyebrow">Initiative Intake</div>
          <h2>Create a strategic initiative</h2>
          <p>
            Seed the registry with the minimum viable SI record, then complete ownership, evidence,
            and operating guidance inside the control room.
          </p>
        </div>
      </section>

      {!canCreate ? (
        <section className="notice-card notice-warning">
          <strong>Creation is limited to executive users.</strong>
          <p className="muted">
            You can review existing initiatives, but only executives and service-token operators can
            create new strategic initiatives.
          </p>
        </section>
      ) : null}

      <section className="panel">
        <div className="section-header">
          <h2>Core SI Record</h2>
          {canCreate ? (
            <div className="button-row">
              <button className="ghost-button" onClick={() => navigate("/initiatives")}>
                Cancel
              </button>
              <button
                className="primary-button"
                disabled={busy || !form.code.trim() || !form.title.trim()}
                onClick={() => void handleCreate()}
              >
                Create Initiative
              </button>
            </div>
          ) : null}
        </div>

        <div className="form-grid">
          <input value={form.code} onChange={(event) => setForm({ ...form, code: event.target.value })} placeholder="Code" />
          <input value={form.title} onChange={(event) => setForm({ ...form, title: event.target.value })} placeholder="Title" />
          <input value={form.group} onChange={(event) => setForm({ ...form, group: event.target.value })} placeholder="Group" />
          <input
            value={form.targetCadence}
            onChange={(event) => setForm({ ...form, targetCadence: event.target.value })}
            placeholder="Cadence"
          />
          <input
            value={form.updateType}
            onChange={(event) => setForm({ ...form, updateType: event.target.value })}
            placeholder="Update type"
          />
          <input value={form.stage} onChange={(event) => setForm({ ...form, stage: event.target.value })} placeholder="Stage" />
          <input value={form.lClass} onChange={(event) => setForm({ ...form, lClass: event.target.value })} placeholder="L Class" />
          <input
            value={form.impactType}
            onChange={(event) => setForm({ ...form, impactType: event.target.value })}
            placeholder="Impact type"
          />
          <select value={form.inCapPlan} onChange={(event) => setForm({ ...form, inCapPlan: event.target.value })}>
            <option value="">In cap plan?</option>
            <option value="true">Yes</option>
            <option value="false">No</option>
          </select>
          <select value={form.isActive} onChange={(event) => setForm({ ...form, isActive: event.target.value })}>
            <option value="true">Active</option>
            <option value="false">Inactive</option>
          </select>
          <textarea
            value={form.objective}
            onChange={(event) => setForm({ ...form, objective: event.target.value })}
            placeholder="Objective"
          />
          <textarea
            value={form.progress}
            onChange={(event) => setForm({ ...form, progress: event.target.value })}
            placeholder="Current progress summary"
          />
          <textarea
            value={form.leadPerformance}
            onChange={(event) => setForm({ ...form, leadPerformance: event.target.value })}
            placeholder="Lead performance"
          />
          <textarea
            value={form.administrationHealth}
            onChange={(event) => setForm({ ...form, administrationHealth: event.target.value })}
            placeholder="Administration health"
          />
        </div>

        {error ? <p className="error-text">{error}</p> : null}
      </section>
    </div>
  );
}
