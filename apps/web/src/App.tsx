import type { T3osShellState } from "./lib/t3os";
import { Navigate, Route, Routes } from "react-router-dom";
import { AppShell } from "./components/AppShell";
import { ContactsPage } from "./pages/ContactsPage";
import { DashboardPage } from "./pages/DashboardPage";
import { GlobalKnowledgePage } from "./pages/GlobalKnowledgePage";
import { ImportPage } from "./pages/ImportPage";
import { InitiativeEditorPage } from "./pages/InitiativeEditorPage";
import { InitiativePage } from "./pages/InitiativePage";
import { InitiativesPage } from "./pages/InitiativesPage";
import { OperationsPage } from "./pages/OperationsPage";
import { SettingsPage } from "./pages/SettingsPage";

interface AppProps {
  shellState: T3osShellState;
}

export default function App({ shellState }: AppProps) {
  const routeKey = shellState.workspaceId ?? (shellState.isFallback ? "fallback" : "t3os");

  return (
    <AppShell shellState={shellState}>
      <Routes key={routeKey}>
        <Route path="/" element={<DashboardPage />} />
        <Route path="/initiatives" element={<InitiativesPage />} />
        <Route path="/initiatives/new" element={<InitiativeEditorPage />} />
        <Route path="/contacts" element={<ContactsPage />} />
        <Route path="/settings" element={<SettingsPage />} />
        <Route path="/settings/import" element={<ImportPage />} />
        <Route path="/settings/knowledge" element={<GlobalKnowledgePage />} />
        <Route path="/settings/operations" element={<OperationsPage />} />
        <Route path="/initiatives/:initiativeId" element={<InitiativePage />} />
        <Route path="/import" element={<Navigate to="/settings/import" replace />} />
        <Route path="/knowledge/global" element={<Navigate to="/settings/knowledge" replace />} />
      </Routes>
    </AppShell>
  );
}
