import type { T3osShellState } from "./lib/t3os";
import { Route, Routes } from "react-router-dom";
import { AppShell } from "./components/AppShell";
import { DashboardPage } from "./pages/DashboardPage";
import { GlobalKnowledgePage } from "./pages/GlobalKnowledgePage";
import { ImportPage } from "./pages/ImportPage";
import { InitiativePage } from "./pages/InitiativePage";

interface AppProps {
  shellState: T3osShellState;
}

export default function App({ shellState }: AppProps) {
  const routeKey = shellState.workspaceId ?? (shellState.isFallback ? "fallback" : "t3os");

  return (
    <AppShell shellState={shellState}>
      <Routes key={routeKey}>
        <Route path="/" element={<DashboardPage />} />
        <Route path="/import" element={<ImportPage />} />
        <Route path="/knowledge/global" element={<GlobalKnowledgePage />} />
        <Route path="/initiatives/:initiativeId" element={<InitiativePage />} />
      </Routes>
    </AppShell>
  );
}
