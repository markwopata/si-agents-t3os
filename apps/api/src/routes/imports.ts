import type { FastifyPluginAsync } from "fastify";
import { env } from "../config/env.js";
import { requireScope } from "../plugins/auth.js";
import { requireAdmin } from "../services/authorization-service.js";
import { importWorkbookFromBuffer, importWorkbookFromFile } from "../services/import-service.js";

export const importRoutes: FastifyPluginAsync = async (app) => {
  app.post("/imports/si-workbook", async (request) => {
    requireScope(request, "write:initiatives");
    requireAdmin(request);

    if (request.isMultipart()) {
      const file = await request.file();
      if (!file) {
        throw new Error("No file uploaded");
      }
      const buffer = await file.toBuffer();
      return importWorkbookFromBuffer(buffer, file.filename);
    }

    const body = (request.body ?? {}) as { sourcePath?: string };
    return importWorkbookFromFile(body.sourcePath || env.WORKBOOK_PATH);
  });
};
