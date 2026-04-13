# EquipmentShare Analytics Agent Executive Deck v1

This brief is the source narrative for the first executive presentation about
the EquipmentShare analytics-agent project. It is meant to be presentation
ready and can be used to regenerate a deck in Figma Slides, Google Slides, or
another presentation tool.

## Deck thesis

EquipmentShare should build an analytics-first company intelligence platform,
not a generic analytics chatbot.

The strongest near-term value comes from combining:

- repo-aware reasoning over real EquipmentShare code and models,
- governed read-only execution for live data,
- a shared semantic layer for cross-domain consistency,
- and domain-aware routing for messy business questions.

## Audience

- executives and business sponsors
- analytics and data leadership
- technical builders who need enough specificity to trust the plan

## Core evidence to anchor the story

- The prototype has already been useful across finance and branch earnings,
  forecasting, fleet and OEC, pricing, TCO, materials, payroll, training, and
  asset valuation.
- Slack discovery validated live company language such as `branch earnings`,
  `OEC`, `utilization`, `rate achievement`, `Workday payroll`, `BiSTrack`,
  `Anaplan`, `OWN`, `TCO`, and `Intacct`.
- Looker usage shows that some of the most heavily used analytics surfaces are
  not edge cases. Top usage signals include `Inventory Information` (`227,990`
  runs), `Company Directory` (`86,447`), `Customer Dashboard` (`78,887`),
  `Salesperson` (`73,961`), `Market Dashboard` (`58,570`), and `Service
  Dashboard` (`55,349`).
- Weighted domain signals from dashboard usage point first to fleet and assets,
  then customer and revenue, shared semantic infrastructure, branch
  performance, maintenance, accounting operations, and pricing.

## Recommended slide flow

### 1. Title

Takeaway:
Analytics is the strongest first use case for a company intelligence platform
at EquipmentShare.

Key points:

- This is an EquipmentShare-specific intelligence layer, not a generic chatbot.
- The deck is grounded in prototype work, Slack discovery, and LookML usage.
- The project is already proving value on real business questions.

Visual direction:

- premium editorial title slide
- industrial but restrained
- graphite, warm sand, and gold accents

### 2. Why this needs to exist

Takeaway:
High-value analytics work is investigative, cross-system, and too brittle for a
generic LLM or naive catalog search.

Key points:

- Important questions are often "why did this move?" or "why does this not tie
  out?" rather than "what is metric X?"
- Knowledge is fragmented across dbt, LookML, docs, dashboards, operational
  replicas, and analyst memory.
- Freshness, provenance, source trust, and sensitivity are first-order
  requirements.

### 3. Proof from real prototype work

Takeaway:
The opportunity is real because the prototype already works across multiple
domains.

Key points:

- solved domains include branch earnings, forecasting, fleet, pricing, TCO,
  materials, payroll, training, and valuation
- artifact outputs already include SQL, markdown briefs, PDFs, and setup guides
- the pattern works because the system can search code, form hypotheses, query
  live data, and explain logic

### 4. What company usage is telling us

Takeaway:
Slack and Looker usage show where the company actually spends analytical
attention.

Key points:

- Slack validates the language and workflows alive in daily work.
- Looker usage shows that fleet, customer, branch, and service analytics are
  core surfaces, not fringe requests.
- Shared lookup and hierarchy assets are heavily used and deserve explicit
  treatment as semantic infrastructure.

### 5. Domain backbone plus shared semantic layer

Takeaway:
The platform should be organized around business domains with a shared semantic
layer above them.

Key points:

- core domains: branch earnings, GL, fixed assets, customers and revenue,
  pricing, fleet, maintenance, TCO, materials, people, learning, planning,
  OWN, and asset disposition
- OWN and asset disposition should remain separate domains
- shared conformed dimensions should sit above them:
  branch-market-region, customer hierarchy, fiscal calendar, asset hierarchy,
  and org structure

### 6. Most-used metric families

Takeaway:
The first metric registry should start from the metrics that show up repeatedly
in high-usage dashboards and the matched LookML.

Key points:

- fleet and assets: inventory counts, asset status, asset availability, OEC,
  rental revenue, financial utilization
- customer and commercial: customer revenue, salesperson performance,
  commission payouts, clawbacks, quote-request workflow
- branch and accounting: branch earnings amount, GAAP amount, difference or
  tie-out analysis, collections and finance operations
- maintenance and pricing: maintenance and repair amount, parts and warranty
  activity, benchmark rates, achieved-rate points, benchmark percentages

Supporting analysis:

- see [looker-metric-deep-dive-2026-04-06.md](/Users/mark.wopata/Documents/projects/SI-agent/docs/looker-metric-deep-dive-2026-04-06.md)

### 7. Platform architecture

Takeaway:
The system routes business questions through domain-aware knowledge and governed
execution services before assembling a response.

Key points:

- gateway and orchestration layer
- domain router
- knowledge services for code, docs, trust, memory, and shared semantics
- execution services for read-only SQL, freshness, provenance, and permissions
- answer modes: explain, SQL/code, direct answer, or artifact

Supporting visual:

- [Analytics Agent Architecture](https://www.figma.com/online-whiteboard/create-diagram/fd26a1dd-cb5c-471d-b680-80bad167277c?utm_source=chatgpt&utm_content=edit_in_figjam&oai_id=&request_id=07a9bb7d-a15a-486b-bba7-6be92dea6e3f)

### 8. Question-to-answer lifecycle

Takeaway:
Governance is built into the flow, not bolted on afterward.

Key points:

- interpret intent and detect domain
- gather likely logic from code, LookML, docs, and reviewed memory
- choose sources by trust, grain, freshness, and sensitivity
- run governed read-only SQL when needed
- validate with provenance and caveats
- capture reusable prompt and query patterns back into reviewed memory

Supporting visual:

- [Analytics Question Lifecycle](https://www.figma.com/online-whiteboard/create-diagram/1aa71435-db85-4882-81fe-19908cb0cc51?utm_source=chatgpt&utm_content=edit_in_figjam&oai_id=&request_id=e3dea2cc-d314-478a-a654-f9e2c1a1f5b5)

### 9. Governance, trust, and sensitivity

Takeaway:
This becomes durable only if it is explicit about trust tiers and permissions.

Key points:

- Tier 1: canonical dbt marts and official docs
- Tier 2: LookML and downstream semantic logic
- Tier 3: curated playbooks and reviewed memory
- Tier 4: staging and raw operational content
- sensitivity tiers: `broad_internal`, `operational_sensitive`,
  `finance_restricted`, `confidential_people`, `customer_sensitive`

### 10. Prompt portfolio and 90-day build plan

Takeaway:
The project should launch with real prompts, real domains, and a concrete pilot
path.

Key points:

- example prompts:
  - Why did branch earnings move this month, and which categories drove the
    variance?
  - Which customers are driving revenue growth, and which top accounts are the
    biggest movers by branch?
  - Which markets are underperforming on utilization, and which classes are
    driving the highest maintenance cost or downtime?
  - Explain how rate achievement was calculated for this invoice.
  - How did this transaction hit the GL, and why does this reconciliation not
    tie out?
  - Walk me through the official TCO formula and separate OWN economics from
    asset-disposition performance.
- 90-day plan:
  - stand up the analyst-facing ask surface and domain routing
  - tighten the shared semantic layer and approved Slack ingestion
  - expand verified queries plus freshness, provenance, and sensitivity policy

## Design notes

- Avoid generic AI imagery.
- Use confident internal-strategy styling, not startup marketing language.
- Keep diagrams readable for executives.
- Show real evidence and numbers rather than abstract platform claims.

## Next iteration after Slack thread backfill

Once the deeper `help-looker` and `help-branch-earnings` thread hydration is
complete, this deck should be updated with:

- stronger prompt clusters from real Slack conversations
- clearer ownership and workflow patterns by domain
- more complete evidence on what business questions recur most often
- refined examples for branch earnings and Looker-support investigations
