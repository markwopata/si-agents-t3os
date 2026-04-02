declare global {
  interface Window {
    T3osConfig?: {
      mount?: string;
      theme?: string;
      autoLogin?: boolean;
      callbackPath?: string;
    };
    T3os?: {
      auth?: {
        getToken?: () => Promise<string | null>;
      };
      workspace?: {
        id?: string;
        name?: string;
        getCurrentId?: () => string | null;
        on?: (event: string, handler: () => void) => (() => void) | void;
      };
      isReady?: () => Promise<boolean>;
    };
  }
}

export interface T3osShellState {
  isReady: boolean;
  isFallback: boolean;
  workspaceId: string | null;
  workspaceName: string | null;
  modeLabel: string;
}

export async function waitForT3osReady(timeoutMs = 1200): Promise<boolean> {
  if (!window.T3os?.isReady) {
    return false;
  }

  const timeout = new Promise<boolean>((resolve) => {
    window.setTimeout(() => resolve(false), timeoutMs);
  });

  return Promise.race([window.T3os.isReady(), timeout]);
}

export function getCurrentWorkspaceId(): string | null {
  try {
    if (typeof window.T3os?.workspace?.getCurrentId === "function") {
      return window.T3os.workspace.getCurrentId() ?? null;
    }
  } catch {
    return window.T3os?.workspace?.id ?? null;
  }

  return window.T3os?.workspace?.id ?? null;
}

export function getCurrentWorkspaceName(): string | null {
  return window.T3os?.workspace?.name ?? null;
}

export async function getT3osAccessToken(): Promise<string | null> {
  try {
    return (await window.T3os?.auth?.getToken?.()) ?? null;
  } catch {
    return null;
  }
}

export async function loadT3osShellState(timeoutMs = 1600): Promise<T3osShellState> {
  const isReady = await waitForT3osReady(timeoutMs);
  const workspaceId = getCurrentWorkspaceId();
  const workspaceName = getCurrentWorkspaceName();

  if (!isReady) {
    return {
      isReady: false,
      isFallback: true,
      workspaceId,
      workspaceName,
      modeLabel: "Engineering fallback (T3OS unavailable)",
    };
  }

  return {
    isReady: true,
    isFallback: false,
    workspaceId,
    workspaceName,
    modeLabel: workspaceName ? `T3OS workspace: ${workspaceName}` : "T3OS workspace connected",
  };
}

export function subscribeToWorkspaceChanges(callback: () => void): () => void {
  const unsubscribers: Array<() => void> = [];

  const unsubscribe = window.T3os?.workspace?.on?.("change", callback);
  if (typeof unsubscribe === "function") {
    unsubscribers.push(unsubscribe);
  }

  const focusHandler = () => callback();
  window.addEventListener("focus", focusHandler);
  unsubscribers.push(() => window.removeEventListener("focus", focusHandler));

  return () => {
    unsubscribers.forEach((unsub) => unsub());
  };
}
