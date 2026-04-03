import { Link } from "react-router-dom";

const SETTINGS_CARDS = [
  {
    title: "API Access",
    description: "Create personal API tokens for agents and, as an admin, audit or revoke workspace tokens.",
    to: "/settings/tokens",
  },
  {
    title: "Import",
    description: "Load or reconcile the SI registry from the workbook when the admin team needs a bulk update.",
    to: "/settings/import",
  },
  {
    title: "Knowledge",
    description: "Maintain the global SI operating model, evaluation guidance, and leadership expectations.",
    to: "/settings/knowledge",
  },
  {
    title: "Operations",
    description: "Track Slack/Google connection state, portfolio refresh runs, and operational system health.",
    to: "/settings/operations",
  },
];

export function SettingsPage() {
  return (
    <div className="page-stack">
      <section className="hero-card panel-tonal">
        <div>
          <div className="eyebrow">Settings</div>
          <h2>Govern the SI system without crowding the decision surfaces</h2>
          <p>
            Keep import, global guidance, integrations, and operational controls organized in one
            admin area while Portfolio HQ stays focused on portfolio decisions.
          </p>
        </div>
      </section>

      <section className="settings-grid">
        {SETTINGS_CARDS.map((card) => (
          <Link key={card.to} className="settings-card" to={card.to}>
            <div className="metric-label">Settings</div>
            <h3>{card.title}</h3>
            <p>{card.description}</p>
            <span className="settings-card-link">Open {card.title}</span>
          </Link>
        ))}
      </section>
    </div>
  );
}
