import path from "node:path";
import { fileURLToPath } from "node:url";

const currentDir = path.dirname(fileURLToPath(import.meta.url));

export const projectRoot = path.resolve(currentDir, "../../../..");

export function resolveFromProjectRoot(...segments: string[]): string {
  return path.resolve(projectRoot, ...segments);
}

