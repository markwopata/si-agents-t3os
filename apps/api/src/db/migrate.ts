import fs from "node:fs/promises";
import path from "node:path";
import { db, pool } from "./client.js";
import { resolveFromProjectRoot } from "../lib/paths.js";

export async function runMigrations(): Promise<void> {
  const migrationsDir = resolveFromProjectRoot("apps/api/drizzle");
  const files = (await fs.readdir(migrationsDir))
    .filter((file) => file.endsWith(".sql"))
    .sort();

  await pool.query(`
    CREATE TABLE IF NOT EXISTS __app_migrations (
      id text PRIMARY KEY,
      applied_at timestamptz NOT NULL DEFAULT now()
    )
  `);

  for (const file of files) {
    const alreadyApplied = await pool.query("SELECT 1 FROM __app_migrations WHERE id = $1", [file]);
    if (alreadyApplied.rowCount) {
      continue;
    }

    const sql = await fs.readFile(path.join(migrationsDir, file), "utf8");
    await pool.query("BEGIN");
    try {
      await pool.query(sql);
      await pool.query("INSERT INTO __app_migrations (id) VALUES ($1)", [file]);
      await pool.query("COMMIT");
    } catch (error) {
      await pool.query("ROLLBACK");
      throw error;
    }
  }
}

export async function closePool(): Promise<void> {
  await pool.end();
}
