# EquipmentShare Analytics Domain Map

This seed records the current domain taxonomy for the EquipmentShare
intelligence project. It started from the consolidated handoff and was refined
after pressure-testing the language against live Slack usage on 2026-04-05.

## Shared Conformed Dimensions

Some building blocks should sit above the domain taxonomy because they are used
everywhere. This includes crosswalks such as branch to market to region,
customer hierarchies, fiscal calendars, asset hierarchies, and org structures.

These should be treated as shared semantic infrastructure rather than assigned
to a single domain owner.

The same point is reinforced by Looker usage. `Company Directory`, `Company
Look Up`, and repeated `market_region_xwalk` references show that some of the
highest-value analytics assets are shared lookup and hierarchy layers used
across many domains.

## Branch Earnings and P&L

Why this exists:
Branch earnings is a business-performance domain, not a catch-all for every
finance question. It should focus on branch-level scorecards, margin, opex, and
local operating performance.

Typical systems:
`ba-finance-dbt`, `marts/branch_earnings`, branch scorecards, regional finance
dashboards.

Typical prompts:
- Why did branch earnings move this month?
- Which categories are driving the branch variance?
- Which branches are outperforming or underperforming plan?

Sensitivity:
`finance_restricted`

## General Ledger and Accounting

Why this exists:
GL and accounting questions have their own vocabulary, source systems, and
controls. Journal entries, trial balance, close, and reconciliation work should
not be buried inside branch-performance analytics.

Typical systems:
Intacct, accounting marts, close and reconciliation reporting.

Typical prompts:
- How did this transaction hit the GL?
- Why does the trial balance not tie out?
- Which journal-entry populations explain this reconciliation break?

Sensitivity:
`finance_restricted`

## Fixed Assets and Depreciation

Why this exists:
Fixed-asset accounting has its own data model and business logic: capex,
depreciation, transfers, disposals, and book value.

Typical systems:
Fixed-asset subledger, depreciation schedules, capex reporting.

Typical prompts:
- Show depreciation expense by class and branch.
- Which fixed-asset transfers changed NBV this quarter?
- How did this disposal move through the ledger and GL?

Sensitivity:
`finance_restricted`

## Customers and Revenue

Why this exists:
Customer and revenue analysis is a first-class business domain. It needs its
own routing because customer performance, key accounts, and profitability
questions are not the same as accounting or branch close work.

Typical systems:
Revenue marts, customer analytics dashboards, rental revenue reporting.

Typical prompts:
- Which customers are driving revenue growth?
- Show rental revenue by top accounts and biggest movers.
- Compare customer profitability across branches or segments.

Sensitivity:
`customer_sensitive`

## Pricing and Rate Achievement

Why this exists:
Pricing work has its own language, data model, and workflow. Slack repeatedly
frames this domain in terms of rate logic, benchmark and floor rates, points,
timing, and commission impact.

Typical systems:
`analytics.public.rateachievement_points`, pricing dashboards, rate admin tools.

Typical prompts:
- Explain how rate achievement was calculated for this invoice.
- Compare benchmark, floor, and invoiced rates.
- What changed after a pricing update?

Sensitivity:
`operational_sensitive`

## Fleet, Assets, OEC, and Utilization

Why this exists:
This domain covers fleet shape, OEC, on-rent behavior, availability, and
utilization. It should stay focused on fleet visibility rather than shop
operations or resale.

Typical systems:
`analytics.assets`, asset financing snapshots, utilization dashboards.

Typical prompts:
- Show OEC by region or class.
- Which markets are underperforming on utilization?
- How much unavailable OEC is in the fleet?

Sensitivity:
`operational_sensitive`

## Maintenance and Work Orders

Why this exists:
Maintenance questions are about work orders, downtime, labor, parts, PM
compliance, and repair-cycle performance. They should not be folded into broad
fleet analytics.

Typical systems:
Work-order sources, service dashboards, downtime workflows.

Typical prompts:
- Show work-order volume and downtime by branch.
- Which classes are driving the highest maintenance cost?
- Compare PM compliance and hard-down incidents by region.

Sensitivity:
`operational_sensitive`

## Fleet Optimization and TCO

Why this exists:
TCO and optimization work crosses fleet and finance, but the logic is
specialized enough to earn its own domain. It is about ownership economics and
scenario comparison, not just fleet visibility.

Typical systems:
`fleet_optimization.gold.fact_total_cost_to_own`, fleet optimization docs.

Typical prompts:
- Walk me through the official TCO formula.
- Compare TCO across classes or scenarios.
- Which upstream data improves the model's accuracy?

Sensitivity:
`operational_sensitive`

## Materials and Distribution

Why this exists:
Materials questions are shaped by systems coverage and operational exceptions,
especially BiSTrack and Sage. This domain is not just another revenue slice.

Typical systems:
BiSTrack, Sage, materials marts, `analytics.bt_dbo`.

Typical prompts:
- Show monthly materials revenue by location.
- Which stores are not on BiSTrack?
- What limits exist for stores without the same system coverage?

Sensitivity:
`operational_sensitive`

## People, Compensation, and Payroll

Why this exists:
People and payroll work needs separate handling and tighter controls than broad
operational domains.

Typical systems:
Workday RAAS, payroll detail, base compensation history.

Typical prompts:
- What changed in payroll detail for this team?
- Which pay components explain the variance?
- What questions need elevated permissions?

Sensitivity:
`confidential_people`

## Learning and Training

Why this exists:
Docebo and training completion work shows up as a distinct analytics use case
with its own tables, report-replication needs, and external-training questions.

Typical systems:
`analytics.docebo`, `people_analytics.docebo`, training reports.

Typical prompts:
- Replicate this training completion report.
- Show how completion has progressed over time.
- Which Docebo tables are the right starting point?

Sensitivity:
`broad_internal`

## Planning and Management Reporting

Why this exists:
Planning work centers around Anaplan, cash-flow views, targets, and management
reporting outputs. It is adjacent to finance, but the workflows are different.

Typical systems:
`marts/anaplan`, cash-flow forecast reports, planning spreadsheets.

Typical prompts:
- Summarize the weekly cash flow forecast.
- What should live in Anaplan versus Snowflake?
- Which planning outputs should feed management reporting?

Sensitivity:
`finance_restricted`

## OWN Program

Why this exists:
OWN has its own business language around enrollments, payouts, revenue share,
and program performance. It should be separated from resale and disposition.

Typical systems:
OWN payout tables, OWN enrollment sources, program reporting.

Typical prompts:
- How much OWN Program activity are we doing?
- How do payouts relate to OEC enrolled in the program?
- Which branches are driving OWN Program volume?

Sensitivity:
`finance_restricted`

## Asset Disposition and Valuation

Why this exists:
Asset sales, buybacks, wholesale values, and resale performance form a distinct
domain from OWN. The core questions are about valuation and realized
disposition economics.

Typical systems:
Asset sale reporting, Rouse estimate models, buyback workflows.

Typical prompts:
- Compare actual resale proceeds to wholesale value.
- Which classes have the biggest residual gap?
- Show buyback and disposition activity by OEM, class, and branch.

Sensitivity:
`finance_restricted`
