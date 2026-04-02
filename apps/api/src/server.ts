import { env } from "./config/env.js";
import { buildApp } from "./app.js";
import { recoverPortfolioRefreshRuns } from "./services/portfolio-service.js";

const app = await buildApp();

await recoverPortfolioRefreshRuns();

await app.listen({
  port: env.PORT,
  host: env.HOST,
});
