import { processNextPortfolioRefreshRun } from "../services/portfolio-service.js";

async function main(): Promise<void> {
  let processedCount = 0;

  for (;;) {
    const run = await processNextPortfolioRefreshRun();
    if (!run) {
      console.log(`[portfolio-worker] no queued portfolio refresh runs found after ${processedCount} processed`);
      return;
    }

    processedCount += 1;
    console.log(`[portfolio-worker] processed portfolio refresh ${run.runId} with status ${run.status}`);
  }
}

void main().catch((error) => {
  console.error("[portfolio-worker] failed", error);
  process.exitCode = 1;
});
