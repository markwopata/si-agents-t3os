import { closePool, runMigrations } from "../db/migrate.js";

await runMigrations();
await closePool();

