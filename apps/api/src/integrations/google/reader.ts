import type { InitiativeDetail, InitiativeGoogleEvidence } from "@si/domain";
import { getGoogleAccessToken } from "./service.js";

interface GoogleDriveFile {
  id?: string;
  name?: string;
  mimeType?: string;
  modifiedTime?: string;
  webViewLink?: string;
  lastModifyingUser?: {
    displayName?: string;
    emailAddress?: string;
  };
}

interface GoogleDriveRevision {
  id?: string;
  modifiedTime?: string;
  lastModifyingUser?: {
    displayName?: string;
    emailAddress?: string;
  };
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function parseGoogleFileLink(url: string): { fileId: string; kind: "folder" | "file" } | null {
  try {
    const parsed = new URL(url);
    const parts = parsed.pathname.split("/").filter(Boolean);

    if (parts.includes("folders")) {
      const folderId = parts[parts.indexOf("folders") + 1];
      if (folderId) {
        return { fileId: folderId, kind: "folder" };
      }
    }

    if (parts.includes("d")) {
      const fileId = parts[parts.indexOf("d") + 1];
      if (fileId) {
        return { fileId, kind: "file" };
      }
    }

    const fileId = parsed.searchParams.get("id");
    if (fileId) {
      return { fileId, kind: "file" };
    }

    return null;
  } catch {
    return null;
  }
}

async function googleApi<T>(token: string, url: URL): Promise<T> {
  for (let attempt = 0; attempt < 8; attempt += 1) {
    const response = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (response.status === 429) {
      const retryAfterSeconds = Number(response.headers.get("retry-after") ?? String(5 * (attempt + 1)));
      await sleep((Number.isFinite(retryAfterSeconds) ? retryAfterSeconds : 5 * (attempt + 1)) * 1000);
      continue;
    }

    if (!response.ok) {
      throw new Error(`Google API failed with HTTP ${response.status}`);
    }

    return (await response.json()) as T;
  }

  throw new Error("Google API exhausted retry attempts after repeated rate limits");
}

async function getFile(token: string, fileId: string): Promise<GoogleDriveFile> {
  const url = new URL(`https://www.googleapis.com/drive/v3/files/${fileId}`);
  url.searchParams.set(
    "fields",
    "id,name,mimeType,modifiedTime,webViewLink,lastModifyingUser(displayName,emailAddress)",
  );
  url.searchParams.set("supportsAllDrives", "true");
  return googleApi<GoogleDriveFile>(token, url);
}

async function listFolderFiles(token: string, folderId: string): Promise<GoogleDriveFile[]> {
  const url = new URL("https://www.googleapis.com/drive/v3/files");
  url.searchParams.set("q", `'${folderId}' in parents and trashed = false`);
  url.searchParams.set(
    "fields",
    "files(id,name,mimeType,modifiedTime,webViewLink,lastModifyingUser(displayName,emailAddress))",
  );
  url.searchParams.set("pageSize", "8");
  url.searchParams.set("orderBy", "modifiedTime desc");
  url.searchParams.set("supportsAllDrives", "true");
  url.searchParams.set("includeItemsFromAllDrives", "true");
  const payload = await googleApi<{ files?: GoogleDriveFile[] }>(token, url);
  return payload.files ?? [];
}

async function listRevisions(token: string, fileId: string): Promise<GoogleDriveRevision[]> {
  const url = new URL(`https://www.googleapis.com/drive/v3/files/${fileId}/revisions`);
  url.searchParams.set("fields", "revisions(id,modifiedTime,lastModifyingUser(displayName,emailAddress))");
  url.searchParams.set("pageSize", "5");
  url.searchParams.set("supportsAllDrives", "true");
  const payload = await googleApi<{ revisions?: GoogleDriveRevision[] }>(token, url);
  return payload.revisions ?? [];
}

function formatUser(
  user: { displayName?: string; emailAddress?: string } | undefined,
): string | null {
  if (!user) {
    return null;
  }

  return user.displayName ?? user.emailAddress ?? null;
}

export async function fetchGoogleEvidenceForInitiative(
  initiative: InitiativeDetail,
): Promise<InitiativeGoogleEvidence> {
  const token = await getGoogleAccessToken();
  const fileTargets = initiative.links
    .filter((link) => /google\.(com|usercontent)/i.test(link.url))
    .map((link) => ({
      linkId: link.id,
      label: link.label,
      url: link.url,
      parsed: parseGoogleFileLink(link.url),
    }));

  if (!token) {
    return {
      connected: false,
      initiativeId: initiative.id,
      issues: [],
      files: fileTargets.map((target) => ({
        linkId: target.linkId,
        label: target.label,
        url: target.url,
        fileId: target.parsed?.fileId ?? null,
        name: null,
        mimeType: null,
        readable: false,
        error: "Google is not connected.",
        modifiedTime: null,
        lastModifyingUser: null,
        webViewLink: null,
        depth: 0,
        crawlPath: target.label,
        revisions: [],
        children: [],
      })),
      fetchedAt: new Date().toISOString(),
    };
  }

  const files = await Promise.all(
    fileTargets.map(async (target) => {
      if (!target.parsed) {
        return {
          linkId: target.linkId,
          label: target.label,
          url: target.url,
          fileId: null,
          name: null,
          mimeType: null,
          readable: false,
          error: "Unable to parse Google file or folder ID.",
          modifiedTime: null,
          lastModifyingUser: null,
          webViewLink: null,
          depth: 0,
          crawlPath: target.label,
          revisions: [],
          children: [],
        };
      }

      try {
        const file = await getFile(token, target.parsed.fileId);
        const revisions = await listRevisions(token, target.parsed.fileId).catch(() => []);
        const children =
          target.parsed.kind === "folder"
            ? await Promise.all(
                (await listFolderFiles(token, target.parsed.fileId)).map(async (child) => ({
                  id: child.id ?? "",
                  parentFileId: file.id ?? null,
                  depth: 1,
                  crawlPath: `${file.name ?? target.label} / ${child.name ?? ""}`.trim(),
                  name: child.name ?? "",
                  mimeType: child.mimeType ?? null,
                  modifiedTime: child.modifiedTime ?? null,
                  lastModifyingUser: formatUser(child.lastModifyingUser),
                  webViewLink: child.webViewLink ?? null,
                  revisions: child.id
                    ? (await listRevisions(token, child.id).catch(() => [])).map((revision) => ({
                        id: revision.id ?? "",
                        modifiedTime: revision.modifiedTime ?? null,
                        lastModifyingUser: formatUser(revision.lastModifyingUser),
                      }))
                    : [],
                })),
              )
            : [];

        return {
          linkId: target.linkId,
          label: target.label,
          url: target.url,
          fileId: file.id ?? target.parsed.fileId,
          name: file.name ?? null,
          mimeType: file.mimeType ?? null,
          readable: true,
          error: null,
          modifiedTime: file.modifiedTime ?? null,
          lastModifyingUser: formatUser(file.lastModifyingUser),
          webViewLink: file.webViewLink ?? null,
          depth: 0,
          crawlPath: file.name ?? target.label,
          revisions: revisions.map((revision) => ({
            id: revision.id ?? "",
            modifiedTime: revision.modifiedTime ?? null,
            lastModifyingUser: formatUser(revision.lastModifyingUser),
          })),
          children,
        };
      } catch (error) {
        return {
          linkId: target.linkId,
          label: target.label,
          url: target.url,
          fileId: target.parsed.fileId,
          name: null,
          mimeType: null,
          readable: false,
          error: error instanceof Error ? error.message : "Unable to read Google file.",
          modifiedTime: null,
          lastModifyingUser: null,
          webViewLink: null,
          depth: 0,
          crawlPath: target.label,
          revisions: [],
          children: [],
        };
      }
    }),
  );

  return {
    connected: true,
    initiativeId: initiative.id,
    files,
    issues: [],
    fetchedAt: new Date().toISOString(),
  };
}

export { parseGoogleFileLink };
