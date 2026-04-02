import { StrictMode, useEffect, useState } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import App from "./App";
import {
  type T3osShellState,
  loadT3osShellState,
  subscribeToWorkspaceChanges,
} from "./lib/t3os";
import "./styles/app.css";

function Root() {
  const [shellState, setShellState] = useState<T3osShellState>({
    isReady: false,
    isFallback: true,
    workspaceId: null,
    workspaceName: null,
    modeLabel: "Connecting to T3OS...",
  });

  useEffect(() => {
    async function refreshShellState() {
      setShellState(await loadT3osShellState());
    }

    void refreshShellState();
    const unsubscribe = subscribeToWorkspaceChanges(() => {
      void refreshShellState();
    });

    return () => unsubscribe();
  }, []);

  return (
    <BrowserRouter>
      <App shellState={shellState} />
    </BrowserRouter>
  );
}

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <Root />
  </StrictMode>,
);
