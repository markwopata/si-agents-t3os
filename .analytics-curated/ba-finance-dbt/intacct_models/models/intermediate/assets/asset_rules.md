# Asset Rules + Metrics v0.8

Documented business logic for fleet eligibility, utilization, and OEC-based metric calculations

Purpose: Unified model for historical asset data to be used in looker, branch earnings, asset_financing_snapshots, etc.


## Table of Contents
- [Asset Rules + Metrics v0.7](#asset-rules-metrics-v07)
  - [Table of Contents](#table-of-contents)
    - [TODO](#todo)
  - [Common Definitions](#common-definitions)
      - [Re-rent assets](#re-rent-assets)
      - [ES owned company](#es-owned-company)
      - [Received Assets](#received-assets)
  - [Rules](#rules)
    - [Total Fleet Rules](#total-fleet-rules)
    - [Rental Fleet Rules](#rental-fleet-rules)
    - [Unavailable Assets Rules](#unavailable-assets-rules)
    - [Assets On Rent Rules](#assets-on-rent-rules)
    - [Rental Revenue Rules](#rental-revenue-rules)
  - [Calculating Metrics](#calculating-metrics)
    - [Rental Fleet OEC](#rental-fleet-oec)
    - [Total OEC](#total-oec)
    - [Unavailable OEC](#unavailable-oec)
    - [Unavailable OEC Percent](#unavailable-oec-percent)
    - [OEC On Rent](#oec-on-rent)
    - [OEC On Rent Percent](#oec-on-rent-percent)
    - [Rental Fleet Units](#rental-fleet-units)
    - [Total Units](#total-units)
    - [Units On Rent](#units-on-rent)
    - [Unit Utilization](#unit-utilization)
    - [Financial Utilization](#financial-utilization)
  - [Appendix](#appendix)
    - [Support for ignoring rentals w/ null rental branch](#support-for-ignoring-rentals-w-null-rental-branch)
    - [null order\_status](#null-order_status)
  - [Unavailable OEC Considerations](#unavailable-oec-considerations)

### TODO
- Retail OEC
- On Balance Sheet OEC

## Common Definitions

#### Re-rent assets
*Assets that we have rented from another company in order to fulfill customer request.*
- asset's serial or vin number ilike '%RR%'
- asset's custom name ilike '%RR%'
- In re-rent company

#### ES owned company
*Companies that are owned by EquipmentShare*
- Company must be marked owned in es_companies
  - `analytics.public.es_companies` where `owned = true`
- Ensure we do not include jeff's junk yard, lost, stolen, or destroyed companies.
  - company_ids: `(155, 32365, 32367, 31712)`

#### Received Assets
- An asset is received if has been received in [Fleet Track](https://purchasing.equipmentshare.com)
- Asset will have `order_status = 'Received'` in `company_purchase_order_lines`
- Note: Assets in Shipped status have not been received at the branch yet, so they are still in transit from the OEM.
- If the asset was not purchased through fleet track, we should include the asset if it matches other criteria.
- We do not need to be concerned about `order_status is null` because they are not in the rental fleet. See [appendix](#null-order_status)

## Rules

### Total Fleet Rules
*Definition: Use for showing total OEC including non-rental assets.*

- Any asset with coalesce(rental, inventory branch) that is owned by an [ES company](#es-owned-company)
- [Re-rent assets](#re-rent-assets) excluded from all OEC populations, but must be identifiable by branch
- Only include assets that have been [received](#received-assets) in [Fleet Track](https://purchasing.equipmentshare.com) (if the asset was purchased through Fleet Track)
- Must include some identification for OWN program
  - Open questions:
    - Currently in an own program?
      - Issues: data entry is garbage right now. If it was on a program EOM, we can tell it should be payout program for the month. Otherwise have limited idea.
      - Recommendation use what's in int_payout_programs (some date magic on end dates)
    - Or in program as of end last eom?

### Rental Fleet Rules
*Definition: Fleet that we can rent, usable in financial utilization, time utilization, OEC on rent, unavailable OEC %*

- Asset must have a rental branch owned by an [ES-owned company](#es-owned-company)
    - If an asset is sold to a non-ES company with a valid rental branch, it is still in fleet.
- [Re-rent assets](#re-rent-assets) excluded from all OEC populations, but must be identifiable by branch
- Only include assets that have been [received](#received-assets) in [Fleet Track](https://purchasing.equipmentshare.com) (if the asset was purchased through Fleet Track)
- Do not count assets that were rented with a null rental branch with an [ES-owned](#es-owned-company) inventory branch [1](#appendix-1)

### Unavailable Assets Rules
*Definition: Rental fleet that is currently unavailable to rent (Needs some kind of maintenance work before it can be rented)*

- Asset must be in rental fleet
- Asset must have one of the following asset inventory statuses:
  - Make Ready
  - Needs Inspection
  - Soft Down
  - Hard Down

### Assets On Rent Rules
*Definition: Assets that are currently on rent.*

- The assets must be in rental fleet. 
- Assets must have rented for at least 30 minutes on a day to count as on rent for the day. 
- Assets swapped on rentals during the day should only include the final swapped asset.
  - e.g. Asset A on Rental 1 was swapped for Asset B on 2025-05-01. Only count Asset B for units on rent / OEC on rent.
  - If Asset B ends up on a different rental for at least 30 minutes, it could count towards units on rent / OEC on 
    rent.

### Rental Revenue Rules
*Definition: Revenue generated by asset rentals, specifically for use in financial utilization calculation.*

- Rental revenue includes line types 6, 8, 108, 109 (Additional Hourly Usage, Rental Charge, Rebilled Rental Charge, 
  Manually Created Rental Charge)
- Rental revenue is net of credits
- Credits and invoices must both be billing approved. For credit notes, the status = 'approved', for invoices, there is
  a billing_approved flag.
- Rental revenue must not be to customers that are EquipmentShare - no intercompany revenue will count.
- Revenue will include all rental revenue generated at a market, including non-asset revenue or revenue from assets that
  are not in the rental fleet.

Considerations: Simplify the metric to include all rental revenue at the market because most will use this metric at a
market level. Keeping it at the market level keeps it simpler to calculate and understand. We expect this to inflate
financial utilization by a small amount.

## Calculating Metrics

### Rental Fleet OEC
*Definition: Total OEC of assets in the rental fleet.*

Calculation: `sum(rental_fleet_oec)`

Example SQL:
```sql
select round(sum(rental_fleet_oec), 2) as rental_fleet_oec
from analytics.assets.int_asset_historical as iah
where iah.month_end_date = '2025-07-01'
```

Ballpark Expectation: $7.2b

---

### Total OEC
*Definition: Total OEC of assets including non-rental assets.*

Calculation: `sum(total_oec)`

Example SQL:
```sql
select round(sum(total_oec), 2) as total_oec
from analytics.assets.int_asset_historical iah
where iah.month_end_date = '2025-07-01'
```

Ballpark Expectation: $7.8b

---

### Unavailable OEC
*Definition: Amount of OEC of assets in rental fleet that are unavailable to rent.  Unavailable assets will have
inventory status: Make Ready, Needs Inspection, Soft Down, Hard Down. Unavailability is determined at the end of the
day, see [considerations](#unavailable-oec-considerations).*

Calculation: `sum(unavailable_oec)`

Example SQL:
```sql
select round(sum(unavailable_oec), 2) as unavailable_oec
from analytics.assets.int_asset_historical iah
where iah.month_end_date = '2025-07-01'
```

Ballpark Expectation: $1.0b (14-19% of rental fleet OEC. Company's goal is 8% or lower. 12% is the yellow target)

---

### Unavailable OEC Percent 
*Definition: Percentage of rental fleet OEC that is currently unavailable to rent. If the metric is time based (e.g. for
the period of March), we should use an averaging mechanism. Simply expand the filter to include all the days you want to
cover. Unavailability on a day is determined at the end of the day, see [considerations](#unavailable-oec-considerations).*

Calculation: `sum(unavailable_oec) / sum(rental_fleet_oec)`

Example SQL:
```sql
select round(sum(unavailable_oec) / sum(rental_fleet_oec), 4) as unavailable_oec_percent
from analytics.assets.int_asset_historical iah
where iah.month_end_date = '2025-07-01'
```

Period based example (last 31 days):
```sql
select round(sum(unavailable_oec) / sum(rental_fleet_oec), 4) as unavailable_oec_percent
from analytics.assets.int_asset_historical iah
where daily_timestamp >= current_date - interval '31 day'
```

Ballpark Expectation: 14-19% (Company's goal is 8% or lower. 12% is the yellow target)

---

### OEC On Rent
*Definition: Amount of OEC of assets in rental fleet that are currently on rent.*

Calculation: `sum(oec_on_rent)`

Example SQL:
```sql
select round(sum(oec_on_rent), 2) as oec_on_rent
from analytics.assets.int_asset_historical iah
where iah.month_end_date = '2025-07-01'
```

Ballpark Expectation: $4.1-4.4b (58-60% of rental fleet OEC)

---

### OEC On Rent Percent
*Definition: Percentage of rental fleet OEC that is currently on rent. If the metric is time based (e.g. for the period
 of March), we should use an averaging mechanism. Simply expand the filter to include all the days you want to cover.
 This is the same as time utilization.*

Calculation: `sum(oec_on_rent) / sum(rental_fleet_oec)`

Example SQL:
```sql
select round(sum(oec_on_rent) / sum(rental_fleet_oec), 4) as oec_on_rent_percent
from analytics.assets.int_asset_historical iah
where iah.month_end_date = '2025-07-01'
```

Period based example (last 31 days):
```sql
select round(sum(oec_on_rent) / sum(rental_fleet_oec), 4) as oec_on_rent_percent
from analytics.assets.int_asset_historical iah
where daily_timestamp >= current_date - interval '31 day'
```

Ballpark Expectation: 58-60% (goal 70%)

---
### Time Utilization
*Definition: This is the same as OEC Rent percentage over time (over current or multiple days). Percentage of rental fleet OEC that is currently on rent averaged over a time period.*

Calculation: `sum(oec_on_rent) / sum(rental_fleet_oec)`


Period based example (last 31 days):
```sql
select round(sum(oec_on_rent) / sum(rental_fleet_oec), 4) as oec_on_rent_percent
from analytics.assets.int_asset_historical iah
where daily_timestamp >= current_date - interval '31 day'
```

Ballpark Expectation: 58-60% (goal 70%)

---

### Rental Fleet Units
*Definition: Number of assets in rental fleet.*

Calculation: `sum(rental_fleet_units)`

Example SQL:
```sql
select sum(rental_fleet_units) as rental_fleet_units
from analytics.assets.int_asset_historical iah
where iah.month_end_date = '2025-07-01'
```

Ballpark Expectation: 238k units

---

### Total Units
*Definition: Total number of assets managed by EquipmentShare.*

Calculation: `sum(total_units)`

Example SQL:
```sql
select sum(total_units) as total_units
from analytics.assets.int_asset_historical iah
where iah.month_end_date = '2025-07-01'
```

Ballpark Expectation: 250k units

---

### Units On Rent
*Definition: Number of assets in rental fleet that are currently on rent.*

Calculation: `sum(units_on_rent)`

Example SQL:
```sql
select sum(units_on_rent) as units_on_rent
from analytics.assets.int_asset_historical iah
where iah.month_end_date = '2025-07-01'
```

Ballpark Expectation: 95K units

---

### Unit Utilization
*Definition: Units rented divided by available rental days. The simplification we will use is use asset count which should equal rental days since this is a daily model. If the metric is time based (e.g. for the period of March), we should use an averaging mechanism. Simply expand the filter to include all the days you want to cover.*

Calculation: `sum(units_on_rent) / sum(rental_fleet_units)`

Example SQL:
```sql
select round(sum(units_on_rent) / sum(rental_fleet_units), 4) as unit_utilization
from analytics.assets.int_asset_historical iah
where iah.month_end_date = '2025-07-01'
```

Period based example (last 31 days):
```sql
select round(sum(units_on_rent) / sum(rental_fleet_units), 4) as unit_utilization
from analytics.assets.int_asset_historical iah
where daily_timestamp >= current_date - interval '31 day'
```

Ballpark Expectation: 38%

---

### Financial Utilization
*Definition: Revenue generated by assets in rental fleet divided by rental fleet OEC. Count all rental revenue generated at a market, including non-asset revenue or revenue from assets that are not in the rental fleet. Generally more useful at the market level, use the market_level_asset_metrics_daily table.*

Calculation: `365 * sum(rental_revenue) / sum(rental_fleet_oec)`

Example SQL:
```sql
select round(365 * sum(amd.rental_revenue) / nullif(sum(amd.rental_fleet_oec), 0), 4) as financial_utilization
from analytics.assets.market_level_asset_metrics_daily as amd
where amd.daily_timestamp >= current_timestamp - interval '31 days'
```

Ballpark Expectation: 29% (goal 37%)


## Appendix 

### Support for ignoring rentals w/ null rental branch
TODO NEEDS INVESTIGATION We considered adding some logic around assets with null rental branch. However, the % of OEC associated to this is very small.

Considered logic:
- Asset with a null rental branch but ES-owned inventory branch…
  - Count in rental fleet for 9 months
  - If any of the fields above changes, temporary rental‐fleet status ends and is rechecked according to these rules.

TODO: This shows a bunch of OEC rented that is not in rental fleet in 21/22 and a bunch of non-rental fleet rental revenue.
```sql
select year(iah.daily_timestamp) as year,
       round(sum(iah.rental_fleet_oec) / count(distinct iah.daily_timestamp),0) avg_rental_fleet_oec,
       round(sum(case when iah.rental_revenue != iah.raw_rental_revenue then oec else 0 end) /
       count(distinct iah.daily_timestamp),0)                  as         avg_non_rental_oec,
       round(avg_non_rental_oec / avg_rental_fleet_oec,4)            as         non_rental_oec_pct,
       round(sum(raw_rental_revenue)                       ,0)       as         raw_rental_revenue,
       round(sum(iah.rental_revenue)                       ,0)       as         rental_revenue,
       round(sum(raw_rental_revenue) - sum(rental_revenue) ,0)       as         non_rental_revenue,
       round(non_rental_revenue / nullifzero(sum(rental_revenue)),4) as         non_rental_revenue_pct
from analytics.assets.int_asset_historical iah
where 1 = 1
  and iah.daily_timestamp >= '2020-01-01'
group by all
order by year
```


### null order_status
- performed an analysis that assets with null ```order_status``` should not be included in rental_fleet since they have never been in ```es_owned```

```sql
with missing_assets as (

    select
        distinct 
            l.asset_id
    from intacct_models.stg_es_warehouse_public__company_purchase_order_line_items l
    where l.order_status is null

    )
    select
        l.asset_id
        , l.order_status
        , a.is_es_owned_company
        , l._company_purchase_order_line_items_effective_start_utc_datetime
        , l.order_status
        , *
    from EQUIPMENTSHARE.PUBLIC__SILVER.COMPANY_PURCHASE_ORDER_LINE_ITEMS_PIT l
    inner join assets.int_assets a
        on a.asset_id = l.asset_id 
    where l.asset_id in (select * from missing_assets)
```

## Unavailable OEC Considerations
We are noting that the asset could appear on rent and unavailable on the same day. Unavailable OEC is calculated at
the end of each day. On rent status requires the asset be rented for at least 30 minutes on a day. If it is swapped,
we are ensuring we are not double counting.
