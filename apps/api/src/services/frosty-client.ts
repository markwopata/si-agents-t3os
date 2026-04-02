type JsonRpcEnvelope = {
  jsonrpc: "2.0";
  id: number;
  method: string;
  params?: Record<string, unknown>;
};

type FrostyToolCallResult = {
  content?: Array<{
    type?: string;
    text?: string;
    [key: string]: unknown;
  }>;
  [key: string]: unknown;
};

export type FrostySqlResult = {
  success?: boolean;
  error?: string | null;
  statement_type?: string | null;
  columns?: string[];
  data?: Array<Record<string, unknown> | unknown[]>;
  row_count?: number | null;
  [key: string]: unknown;
};

export class FrostyError extends Error {
  constructor(
    message: string,
    readonly statusCode?: number,
    readonly details?: string,
  ) {
    super(message);
    this.name = "FrostyError";
  }
}

const MCP_HEADERS = {
  "Content-Type": "application/json",
  Accept: "application/json, text/event-stream",
};

let sessionId: string | null = null;
let initializePromise: Promise<string> | null = null;
let requestCounter = 1;
const DEFAULT_FROSTY_TIMEOUT_MS = Number(process.env.FROSTY_REQUEST_TIMEOUT_MS ?? "30000");

function nextRequestId(): number {
  requestCounter += 1;
  return requestCounter;
}

function buildJsonRpc(method: string, params?: Record<string, unknown>): JsonRpcEnvelope {
  return {
    jsonrpc: "2.0",
    id: nextRequestId(),
    method,
    ...(params ? { params } : {}),
  };
}

function parseSsePayload(bodyText: string): Record<string, unknown> {
  for (const line of bodyText.split("\n")) {
    if (line.startsWith("data: ")) {
      return JSON.parse(line.slice(6)) as Record<string, unknown>;
    }
  }
  throw new FrostyError("Frosty returned an SSE response without a JSON payload.");
}

async function parseResponseEnvelope(response: Response): Promise<Record<string, unknown>> {
  const bodyText = await response.text();
  const contentType = response.headers.get("content-type") ?? "";

  if (!response.ok) {
    throw new FrostyError(
      `Frosty request failed with HTTP ${response.status}.`,
      response.status,
      bodyText,
    );
  }

  if (contentType.includes("application/json")) {
    return JSON.parse(bodyText) as Record<string, unknown>;
  }

  return parseSsePayload(bodyText);
}

async function fetchWithTimeout(
  input: string,
  init: RequestInit,
  timeoutMs = DEFAULT_FROSTY_TIMEOUT_MS,
): Promise<Response> {
  const controller = new AbortController();
  const timeoutHandle = setTimeout(() => controller.abort(), timeoutMs);

  try {
    return await fetch(input, {
      ...init,
      signal: controller.signal,
    });
  } catch (error) {
    if (error instanceof Error && error.name === "AbortError") {
      throw new FrostyError(`Frosty request timed out after ${timeoutMs}ms.`);
    }
    throw error;
  } finally {
    clearTimeout(timeoutHandle);
  }
}

async function initializeSession(baseUrl: string): Promise<string> {
  if (sessionId) {
    return sessionId;
  }

  if (!initializePromise) {
    initializePromise = (async () => {
      const response = await fetchWithTimeout(`${baseUrl}/mcp`, {
        method: "POST",
        headers: MCP_HEADERS,
        body: JSON.stringify(
          buildJsonRpc("initialize", {
            protocolVersion: "2025-03-26",
            capabilities: {},
            clientInfo: {
              name: "si-management-platform",
              version: "0.1.0",
            },
          }),
        ),
      });

      await parseResponseEnvelope(response);
      const freshSessionId = response.headers.get("mcp-session-id");
      if (!freshSessionId) {
        throw new FrostyError("Frosty did not return an MCP session id.");
      }
      sessionId = freshSessionId;
      return freshSessionId;
    })().finally(() => {
      initializePromise = null;
    });
  }

  return initializePromise;
}

async function requestWithSession(
  baseUrl: string,
  method: string,
  params?: Record<string, unknown>,
  attempt = 1,
): Promise<Record<string, unknown>> {
  const activeSessionId = await initializeSession(baseUrl);

  let response: Response;
  try {
    response = await fetchWithTimeout(`${baseUrl}/mcp`, {
      method: "POST",
      headers: {
        ...MCP_HEADERS,
        "Mcp-Session-Id": activeSessionId,
      },
      body: JSON.stringify(buildJsonRpc(method, params)),
    });
  } catch (error) {
    if (attempt === 1) {
      sessionId = null;
      return requestWithSession(baseUrl, method, params, attempt + 1);
    }
    throw error;
  }

  if (response.status === 404 && attempt === 1) {
    sessionId = null;
    return requestWithSession(baseUrl, method, params, attempt + 1);
  }

  if (response.status === 202) {
    try {
      response = await fetchWithTimeout(
        `${baseUrl}/mcp`,
        {
          method: "GET",
          headers: {
            ...MCP_HEADERS,
            "Mcp-Session-Id": activeSessionId,
          },
        },
        DEFAULT_FROSTY_TIMEOUT_MS,
      );
    } catch (error) {
      if (attempt === 1) {
        sessionId = null;
        return requestWithSession(baseUrl, method, params, attempt + 1);
      }
      throw error;
    }
  }

  return parseResponseEnvelope(response);
}

function extractToolJson(result: FrostyToolCallResult): FrostySqlResult {
  const textBlock = result.content?.find((entry) => typeof entry.text === "string")?.text;
  if (!textBlock) {
    throw new FrostyError("Frosty tool response did not include text content.");
  }
  return JSON.parse(textBlock) as FrostySqlResult;
}

export async function executeSqlThroughFrosty(
  query: string,
  baseUrl = process.env.FROSTY_BASE_URL ?? "http://localhost:8888",
): Promise<FrostySqlResult> {
  const envelope = await requestWithSession(baseUrl, "tools/call", {
    name: "sql_execute",
    arguments: {
      query,
    },
  });

  const result = envelope.result as FrostyToolCallResult | undefined;
  if (!result) {
    throw new FrostyError("Frosty returned no result payload for sql_execute.", undefined, JSON.stringify(envelope));
  }

  return extractToolJson(result);
}

export async function getFrostyStatus(baseUrl = process.env.FROSTY_BASE_URL ?? "http://localhost:8888"): Promise<{
  health: Record<string, unknown>;
  auth: Record<string, unknown>;
}> {
  const [healthResponse, authResponse] = await Promise.all([
    fetch(`${baseUrl}/health`),
    fetch(`${baseUrl}/auth/status`),
  ]);

  if (!healthResponse.ok) {
    throw new FrostyError(`Frosty health check failed with HTTP ${healthResponse.status}.`);
  }

  if (!authResponse.ok) {
    throw new FrostyError(`Frosty auth check failed with HTTP ${authResponse.status}.`);
  }

  return {
    health: (await healthResponse.json()) as Record<string, unknown>,
    auth: (await authResponse.json()) as Record<string, unknown>,
  };
}
