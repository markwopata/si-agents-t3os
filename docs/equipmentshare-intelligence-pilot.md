# EquipmentShare Intelligence Pilot

## Why this exists

The consolidated handoff makes a clear point: the company intelligence platform
should start with analytics, stay grounded in real code and governed data, and
avoid overbuilding the platform before usage teaches us what really matters.

This repo now has an explicit pilot path that reflects that guidance.

## Pilot decision

We are treating Slack as a discovery source, not a source of truth.

Slack is useful for:

- learning the language people actually use,
- validating which analytics domains are alive in daily work,
- mining realistic prompt shapes,
- and surfacing recurring investigative questions.

Slack is not sufficient for:

- canonical metric definitions,
- final source-of-truth decisions,
- or unrestricted knowledge capture from sensitive conversations.

## What was validated

On 2026-04-05, live Slack searches were used to pressure-test the handoff's
domain model. Searches included terms such as:

- `branch earnings`
- `rate achievement`
- `OEC`
- `Docebo`
- `BiSTrack`
- `Workday payroll`
- `Anaplan`
- `OWN Program`
- `TCO`
- `utilization`
- `Intacct`
- `Sage`

That sample confirmed that the handoff themes are reflected in real
EquipmentShare language, and that several of them need to be split more cleanly
for routing and governance:

- branch earnings should not absorb all accounting and revenue questions,
- general ledger and fixed assets need their own accounting-oriented domains,
- customer and revenue analysis deserves its own business-facing domain,
- maintenance and work-order analytics should be separate from broad fleet views,
- OWN and asset disposition are related but not the same domain,
- people/payroll needs stricter handling than broad operational domains.

The same sample also reinforced a safety point: DM and group-DM results do show
up in broad Slack search, so the production backfill should default to channel
history and require explicit approval before DM ingestion is included.

The domain map was then pressure-tested against Looker usage from
`system__activity history 2026-04-05T2222.xlsx`. The strongest usage signals
were:

- `Inventory Information`
- `Company Directory`
- `Customer Dashboard`
- `Salesperson`
- `Market Dashboard`
- `Service Dashboard`
- `Asset Details`
- `Trending Branch Earnings`

That usage reinforced that fleet/inventory, customer-commercial analysis,
branch-market performance, and service-maintenance are not edge domains. They
are among the most actively consumed analytics surfaces in the company.

## Domains to organize around

The current pilot should organize the project around these domains:

1. Branch Earnings and P&L
2. General Ledger and Accounting
3. Fixed Assets and Depreciation
4. Customers and Revenue
5. Pricing and Rate Achievement
6. Fleet, Assets, OEC, and Utilization
7. Maintenance and Work Orders
8. Fleet Optimization and TCO
9. Materials and Distribution
10. People, Compensation, and Payroll
11. Learning and Training
12. Planning and Management Reporting
13. OWN Program
14. Asset Disposition and Valuation

These are intentionally business-shaped, not system-shaped. Tables and repos
map into them later.

## Shared semantic layer

Not everything belongs to a business domain. Some entities should be modeled as
shared conformed dimensions used by many domains at once.

Examples:

- branch, market, district, and region crosswalks
- fiscal calendar and reporting periods
- customer and account hierarchies
- asset, class, category, and OEM hierarchies
- employee, manager, and org structure dimensions

These shared dimensions should sit above the domains and be referenced by them.
For example, branch earnings, fleet, maintenance, pricing, and customer revenue
all need the same market-region crosswalk rather than each domain inventing its
own copy.

## What was implemented

The repo now includes an analytics-domain catalog service that:

- seeds the domain map from the handoff,
- layers in observed Slack signals from stored Slack evidence,
- and mines analytics-style prompt candidates from Slack text.

The service is exposed through:

- `GET /knowledge/analytics/domains`

That endpoint is a pilot artifact, not the final platform contract. Its job is
to make the domain backbone explicit and give the rest of the system something
stable to organize around.

## Current limitations

- The Slack-backed analysis uses stored Slack evidence already synced into this
  app. It does not yet perform workspace-wide Slack backfill on demand.
- Prompt extraction is heuristic. It is good enough for pilot taxonomy and
  sample prompt mining, but not yet a reviewed prompt library.
- Domain counts are computed from a bounded recent working set of stored Slack
  evidence so the endpoint stays responsive while the corpus is still evolving.
- Heavy threaded channels can hit Slack `conversations.replies` rate limits,
  which means backfill reliability still needs another pass for very large help
  and BA channels.

## Next execution steps

1. Add a Slack backfill path for approved channels or curated channel cohorts.
2. Persist reviewed prompt candidates rather than regenerating them on each
   request.
3. Add domain ownership, trust tier, and sensitivity review workflow.
4. Join Slack-derived prompt patterns with repo-derived source families and
   verified query candidates.
5. Use the catalog as the routing backbone for the analytics agent.
