import { cp, mkdir, readdir, rm, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import { env } from "../config/env.js";
import { resolveFromProjectRoot } from "../lib/paths.js";
import { shouldIncludeAnalyticsFile } from "../services/analytics-corpus-service.js";

async function pathExists(targetPath: string): Promise<boolean> {
  try {
    await stat(targetPath);
    return true;
  } catch {
    return false;
  }
}

async function discoverSourceRoots(rootPath: string): Promise<string[]> {
  const candidates = [
    path.join(rootPath, "ba_gitlab_repos", "ba-finance-dbt"),
    path.join(rootPath, "dbt_cloud", "business-intelligence"),
    path.join(rootPath, "looker"),
  ];

  const existing = [];
  for (const candidate of candidates) {
    if (await pathExists(candidate)) {
      existing.push(candidate);
    }
  }

  return existing.length > 0 ? existing : [rootPath];
}

async function copyCuratedFiles(
  sourceRoot: string,
  targetRoot: string,
  filterRoot: string,
): Promise<{ copied: number; skipped: number }> {
  const entries = await readdir(sourceRoot, { withFileTypes: true });
  let copied = 0;
  let skipped = 0;

  for (const entry of entries) {
    const sourcePath = path.join(sourceRoot, entry.name);
    if (entry.isDirectory()) {
      const nested = await copyCuratedFiles(sourcePath, targetRoot, filterRoot);
      copied += nested.copied;
      skipped += nested.skipped;
      continue;
    }

    if (!shouldIncludeAnalyticsFile(sourcePath, filterRoot)) {
      skipped += 1;
      continue;
    }

    const relativePath = path.relative(filterRoot, sourcePath);
    const targetPath = path.join(targetRoot, relativePath);
    await mkdir(path.dirname(targetPath), { recursive: true });
    await cp(sourcePath, targetPath);
    copied += 1;
  }

  return { copied, skipped };
}

async function main(): Promise<void> {
  const sourceRoot = env.ANALYTICS_CORPUS_PATH;
  const targetRoot = env.ANALYTICS_CURATED_CORPUS_PATH.trim() || resolveFromProjectRoot(".analytics-curated");
  const sourceRoots = await discoverSourceRoots(sourceRoot);

  await rm(targetRoot, { recursive: true, force: true });
  await mkdir(targetRoot, { recursive: true });

  let copied = 0;
  let skipped = 0;

  for (const source of sourceRoots) {
    const targetForSource = path.join(targetRoot, path.basename(source));
    const result = await copyCuratedFiles(source, targetForSource, source);
    copied += result.copied;
    skipped += result.skipped;
  }

  await writeFile(
    path.join(targetRoot, "manifest.json"),
    JSON.stringify(
      {
        sourceRoot,
        sourceRoots,
        generatedAt: new Date().toISOString(),
        copied,
        skipped,
      },
      null,
      2,
    ),
    "utf8",
  );

  console.log(`Curated analytics corpus written to ${targetRoot}`);
  console.log(`Copied ${copied} files, skipped ${skipped} files`);
}

await main();
