# Looker Metric Deep Dive

This note extends the earlier dashboard usage analysis with a closer look at
the metric families and LookML structures behind the highest-usage dashboards.

It is not yet a tile-perfect dashboard parser. It is a practical first pass for
building the analytics-agent domain registry and prompt library around real
EquipmentShare semantics.

## Method

1. Aggregate dashboard usage from `system__activity history 2026-04-05T2222.xlsx`
   by `dashboard_id` and `dashboard_title`.
2. Match those dashboard IDs and titles against the mirrored LookML repos in
   [`.analytics-curated/looker`](/Users/mark.wopata/Documents/projects/SI-agent/.analytics-curated/looker).
3. Read the most relevant model and view files behind the highest-usage
   dashboards.
4. Pull concrete measure names and structural signals to identify the metric
   families the agent should understand first.

## High-signal dashboard mapping

### Fleet and asset visibility

- `27 Inventory Information` (`227,990` runs)
- `169 Asset Details` (`37,924` runs)
- `1577 Asset Availability Finder` (`13,268` runs)
- `62 Class Count By Locations` (`17,889` runs)

These signals reinforce that the company relies heavily on asset-level
visibility, inventory counts, availability, and status lookups.

Concrete measure signals:

- [`financial_utilization.view.lkml`](/Users/mark.wopata/Documents/projects/SI-agent/.analytics-curated/looker/looker_asset_information/views/ANALYTICS/financial_utilization.view.lkml)
  includes:
  - `rental_revenue`
  - `ttl_oec`
  - `fin_util`
  - `count`

### Customer, revenue, and salesperson performance

- `28 Customer Dashboard` (`78,887` runs)
- `5 Salesperson` (`73,961` runs)
- `479 Equipment Sales Quote Request` (`18,604` runs)

Structural evidence:

- [`salesperson_master.model.lkml`](/Users/mark.wopata/Documents/projects/SI-agent/.analytics-curated/looker/looker_salesperson/Models/salesperson_master.model.lkml)
  is explicitly labeled `Salesperson` and includes customer revenue, company
  activity, market-region, rate, and utilization related views in one working
  model.
- [`MW_Customer_TAM.view.lkml`](/Users/mark.wopata/Documents/projects/SI-agent/.analytics-curated/looker/looker_branch_earnings/views/custom_sql/MW_Customer_TAM.view.lkml)
  links directly to customer-oriented dashboards and company detail flows.

Concrete measure signals:

- [`commission_transactions.view.lkml`](/Users/mark.wopata/Documents/projects/SI-agent/.analytics-curated/looker/looker_salesperson/views/ANALYTICS/commission_transactions.view.lkml)
  includes:
  - `commission_total`
  - `credits_total`
  - `clawback_total`
  - `reimbursement_total`
  - `final_commission_payout`
  - `revenue_total`
  - `salesperson_db_total`
  - `count`
- [`commissions.view.lkml`](/Users/mark.wopata/Documents/projects/SI-agent/.analytics-curated/looker/looker_salesperson/views/ANALYTICS/commissions.view.lkml)
  includes:
  - `total_clawbacks`
  - `revenue_amount`
  - `count`

### Branch earnings and market performance

- `2288 Market Dashboard` (`58,570` runs)
- `1423 Trending Branch Earnings` (`27,615` runs)
- `180 Branch Earnings Dashboard` (`9,093` runs)
- `2337 District - Market Rankings` (`9,286` runs)

Structural evidence:

- [`manifest.lkml`](/Users/mark.wopata/Documents/projects/SI-agent/.analytics-curated/looker/looker_branch_earnings/manifest.lkml)
  defines:
  - `db_branch_earnings_dashboard` -> dashboard `180`
  - `db_market_dashboard` -> dashboard `2288`
- [`market_region_xwalk.view.lkml`](/Users/mark.wopata/Documents/projects/SI-agent/.analytics-curated/looker/looker_branch_earnings/views/ANALYTICS/market_region_xwalk.view.lkml)
  links directly to both dashboards, which reinforces that market-region
  crosswalks are shared semantic infrastructure rather than isolated helper
  tables.

Concrete measure signals:

- [`stat_gaap_account_comparison.view.lkml`](/Users/mark.wopata/Documents/projects/SI-agent/.analytics-curated/looker/looker_branch_earnings/views/ANALYTICS/stat_gaap_account_comparison.view.lkml)
  includes:
  - `gaap_amount`
  - `branch_earnings_amount`
  - `difference`

### Maintenance, service, and repair

- `49 Service Dashboard` (`55,349` runs)
- `540 Parts Transactions` (`14,965` runs)
- `2126 Warranty Overview` (`8,315` runs)

These signals validate that maintenance and work-order analytics should be
first-class rather than absorbed into generic fleet.

Concrete measure signals:

- [`maintenance_and_repair.view.lkml`](/Users/mark.wopata/Documents/projects/SI-agent/.analytics-curated/looker/looker_branch_earnings/views/ANALYTICS/maintenance_and_repair.view.lkml)
  includes:
  - `sum_of_amount`

### Pricing and rate achievement

- `183 Benchmark and Online Rates by Class and Market` (`11,496` runs)

Concrete measure signals:

- [`rateachievement_points.view.lkml`](/Users/mark.wopata/Documents/projects/SI-agent/.analytics-curated/looker/looker_asset_information/views/ANALYTICS/rateachievement_points.view.lkml)
  includes:
  - `total_inv_amt`
  - `total_day_benchmarks`
  - `total_week_benchmarks`
  - `total_month_benchmarks`
  - `total_benchmarks`
  - `total_points`
  - `perc_of_day_bench`
  - `perc_of_week_bench`
  - `perc_of_month_bench`
  - `count`
  - `count_of_assets`
  - `final_market_distinct_count`

## What this means for the analytics agent

### 1. The first metric registry should be domain-first

The initial canonical metric registry should center on:

- inventory counts, asset status, availability, and OEC
- customer revenue, salesperson performance, and commission flows
- branch earnings tie-out metrics
- maintenance and repair cost or activity
- benchmark and achieved-rate metrics

### 2. Shared semantic infrastructure is not optional

`Company Directory`, `Company Look Up`, and repeated `market_region_xwalk`
behavior all point to the same conclusion: conformed dimensions are some of the
highest-value analytics assets in the stack.

The agent needs a first-class shared semantic layer for:

- branch, district, market, and region
- company, customer, and account hierarchy
- asset class and equipment hierarchy
- employee and org structure
- fiscal calendar and reporting period logic

### 3. The prompt library should start from real measure families

Example prompt families that align well with the observed LookML:

- Explain why `branch_earnings_amount` differs from `gaap_amount` for this
  market and period.
- Show `rental_revenue`, `ttl_oec`, and `fin_util` by market and class.
- Explain `total_points` and benchmark percentages for this rate achievement
  population.
- Show `final_commission_payout`, `commission_total`, and `clawback_total` by
  salesperson and month.
- Compare maintenance and repair `sum_of_amount` across classes, branches, or
  periods.

## Open follow-up work

- Parse matched dashboard definitions more precisely so tile-level fields can be
  enumerated.
- Join this deeper LookML inspection with Slack prompt mining once the larger
  thread backfill is complete.
- Separate canonical approved metric definitions from merely common downstream
  reporting fields.
