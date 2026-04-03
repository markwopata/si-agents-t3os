import type { CurrentUser } from "@si/domain";
import { useEffect, useState } from "react";
import { getCurrentUser, getGlobalKnowledge, saveGlobalKnowledge } from "../api/client";

export function GlobalKnowledgePage() {
  const [currentUser, setCurrentUser] = useState<CurrentUser | null>(null);
  const [title, setTitle] = useState("");
  const [slug, setSlug] = useState("global-si-operating-model");
  const [content, setContent] = useState("");
  const [status, setStatus] = useState("");
  const canEdit = currentUser?.type === "service_token" || currentUser?.appRole === "admin";

  useEffect(() => {
    async function load() {
      const [document, me] = await Promise.all([getGlobalKnowledge(), getCurrentUser()]);
      setTitle(document.title);
      setSlug(document.slug);
      setContent(document.content);
      setCurrentUser(me);
    }

    void load();
  }, []);

  async function handleSave() {
    setStatus("Saving...");
    await saveGlobalKnowledge({
      title,
      slug,
      content,
      documentType: "global",
      initiativeId: null,
    });
    setStatus("Saved.");
  }

  return (
    <div className="page-stack">
      <section className="panel">
        <div className="section-header">
          <h2>Global SI Knowledge</h2>
          {canEdit ? (
            <button className="primary-button" onClick={() => void handleSave()}>
              Save
            </button>
          ) : null}
        </div>
        {!canEdit ? (
          <p className="muted">
            Global scoring and evaluation guidance is editable by admins only.
          </p>
        ) : null}
        <div className="form-grid">
          <input
            value={title}
            readOnly={!canEdit}
            onChange={(event) => setTitle(event.target.value)}
            placeholder="Title"
          />
          <input
            value={slug}
            readOnly={!canEdit}
            onChange={(event) => setSlug(event.target.value)}
            placeholder="Slug"
          />
          <textarea
            className="markdown-editor"
            value={content}
            readOnly={!canEdit}
            onChange={(event) => setContent(event.target.value)}
          />
        </div>
        {status ? <div className="muted">{status}</div> : null}
      </section>
    </div>
  );
}
