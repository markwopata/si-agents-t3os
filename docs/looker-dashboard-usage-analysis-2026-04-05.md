# Looker Dashboard Usage Analysis

This note summarizes the dashboard usage export from
`system__activity history 2026-04-05T2222.xlsx` and maps the most-used
dashboards back to the curated LookML repos stored in this project.

## Method

- Parsed the workbook export and aggregated `History Dashboard Run Count` by
  `Dashboard ID` and `Dashboard Title`.
- Matched dashboard IDs directly against LookML references in
  [`.analytics-curated/looker`](/Users/mark.wopata/Documents/projects/SI-agent/.analytics-curated/looker).
- Used dashboard titles and the repo paths where the IDs appear to classify each
  dashboard into an analytics domain.

## Top Dashboard Signals

Top aggregated dashboards from the export:

| Dashboard ID | Dashboard Title | Run Count | Likely Domain | Notes |
| --- | --- | ---: | --- | --- |
| 27 | Inventory Information | 227,990 | Fleet / Inventory / Assets | Strong match in `looker_asset_information` inventory views. |
| 342 | Company Directory | 86,447 | Shared Semantic Layer | Org and market-directory behavior, not one single business domain. |
| 28 | Customer Dashboard | 78,887 | Customers / Sales / Revenue | Strong match through customer dashboard links and company views. |
| 5 | Salesperson | 73,961 | Customers / Sales / Revenue | Strong match to `looker_salesperson/Models/salesperson_master.model.lkml`. |
| 2288 | Market Dashboard | 58,570 | Branch Earnings / Market P&L | Strong manifest and link match in `looker_branch_earnings`. |
| 49 | Service Dashboard | 55,349 | Maintenance / Work Orders | Strong service-dashboard signal across service and market-region views. |
| 169 | Asset Details | 37,924 | Fleet / Inventory / Assets | Strong asset-detail drill path in `looker_asset_information`. |
| 1423 | Trending Branch Earnings | 27,615 | Branch Earnings / Market P&L | Direct manifest match in `looker_branch_earnings`. |
| 135 | Individual Credit Cards | 24,776 | GL / Accounting / Finance Ops | Finance operations signal. |
| 52 | Company Look Up | 19,320 | Shared Semantic Layer / Customer | Lookup-style dashboard used by multiple business flows. |
| 479 | Equipment Sales Quote Request | 18,604 | Customers / Sales / Revenue | Commercial quote workflow. |
| 62 | Class Count By Locations | 17,889 | Fleet / Inventory / Assets | Inventory-by-class signal. |
| 540 | Parts Transactions | 14,965 | Maintenance / Work Orders / Materials | Strong parts-and-service signal. |
| 157 | Collectors Manager Dashboard | 14,364 | GL / Accounting / Finance Ops | Collections and AR operations. |
| 1577 | Asset Availability Finder | 13,268 | Fleet / Inventory / Assets | Availability and supply-side fleet operations. |
| 183 | Benchmark and Online Rates by Class and Market | 11,496 | Pricing / Rate Achievement | Strong pricing signal. |
| 579 | Tracker Mothership | 10,811 | Fleet / Telematics | Operational fleet monitoring. |
| 2337 | District - Market Rankings | 9,286 | Branch Earnings / Market P&L | District and market performance ranking. |
| 180 | Branch Earnings Dashboard | 9,093 | Branch Earnings / Market P&L | Direct manifest match in `looker_branch_earnings`. |
| 2126 | Warranty Overview | 8,315 | Maintenance / Work Orders | Warranty-service signal. |

## Domain Implications

These usage patterns reinforce the current domain split:

- Fleet, inventory, and asset detail should stay first-class. The biggest usage
  signal in the export is inventory and asset lookup, not just utilization.
- Customers, sales, and revenue should remain a distinct commercial domain.
  `Customer Dashboard`, `Salesperson`, and quote-request workflows are heavily
  used.
- Branch earnings and market performance are strongly validated by `Market
  Dashboard`, `Trending Branch Earnings`, `District - Market Rankings`, and
  `Branch Earnings Dashboard`.
- Maintenance and service deserve their own domain. `Service Dashboard`,
  `Warranty Overview`, and `Parts Transactions` are too important to bury under
  generic fleet.
- GL and finance-ops work is validated by `Individual Credit Cards`, `AP -
  Bills`, and `Collectors Manager Dashboard`.
- Shared semantic infrastructure is clearly real. `Company Directory`, `Company
  Look Up`, and repeated `market_region_xwalk` references show that some of the
  most-used assets are cross-domain lookup and hierarchy layers, not end-user
  metrics.

## Most Likely Common Metrics

Based on the highest-usage dashboards and the LookML repos they touch, the most
commonly used metric families appear to be:

- inventory counts and asset availability
- asset-level detail and status
- customer revenue and account activity
- salesperson productivity and revenue attribution
- branch earnings, market performance, and trend comparisons
- service volume, parts activity, and warranty activity
- benchmark, online, and achieved rates

This does not yet produce a canonical ranked measure list. That would require a
second-pass parser over the matched dashboard models and explores to enumerate
the exact measures used by tiles. Still, the dashboard usage already gives a
clear domain-weighting signal.
