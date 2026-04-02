import { env } from "../config/env.js";
import { closePool } from "../db/migrate.js";
import { importWorkbookFromFile } from "../services/import-service.js";

const sourcePath = process.argv[2] ?? env.WORKBOOK_PATH;
const summary = await importWorkbookFromFile(sourcePath);
console.log(JSON.stringify(summary, null, 2));
await closePool();

