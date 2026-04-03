view: delivery_metrics {
  derived_table: {
    sql:
      with delivery_count as (
  select
    m.market_id,
    m.market_name,
    date_trunc(month, d.completed_date) as delivery_month,
    count(*) as deliveries
  from es_warehouse.public.deliveries d
  join es_warehouse.public.orders o
    on d.order_id = o.order_id
  join analytics.BRANCH_EARNINGS.market m
    on o.market_id = m.child_market_id
  join analytics.public.MARKET_REGION_XWALK mrx
    on m.market_id = mrx.market_id
  where d.completed_date >= '2022-01-01'
  and d.facilitator_type_id <> 3
  and d.asset_id is not null
  group by m.market_id, m.market_name, date_trunc(month, d.completed_date)
),
delivery_rev as (
  select
    m.market_id,
    m.market_name,
    date_trunc(month, ld.billing_approved_date) as billed_month,
    sum(ld.amount) as delivery_rev
  from analytics.INTACCT_MODELS.INT_ADMIN_INVOICE_AND_CREDIT_LINE_DETAIL ld
  join analytics.BRANCH_EARNINGS.market m
    on ld.market_id = m.child_market_id
  join analytics.public.MARKET_REGION_XWALK mrx
    on m.market_id = mrx.market_id
  where ld.line_item_type_id = 5
    and ld.billing_approved_date >= '2022-01-01'
  group by m.market_id, m.market_name, date_trunc(month, ld.billing_approved_date)
),
last_driver_snap as (
  select
    m.market_id,
    m.market_name,
    date_trunc(month, cdv._es_update_timestamp) as delivery_month,
    cdv.employee_id
  from analytics.payroll.STG_ANALYTICS_PAYROLL__COMPANY_DIRECTORY_VAULT cdv
  join analytics.BRANCH_EARNINGS.market m
    on cdv.market_id = m.child_market_id
  where cdv.employee_title ilike '%driver%'
  and cdv.is_active_employee = 'true'
  qualify cdv._es_update_timestamp = max(cdv._es_update_timestamp) over (
    partition by m.market_id, date_trunc(month, cdv._es_update_timestamp)
  )
),
driver_count as (
  select
    market_id,
    market_name,
    delivery_month,
    count(distinct employee_id) as num_drivers
  from last_driver_snap
  group by market_id, market_name, delivery_month
),
rental_length as (
  select
    m.market_id,
    m.market_name,
    pp.display,
    date_trunc(month, r.end_date) as month_year,
    avg(datediff(day, r.start_date, r.end_date)) as avg_rental_length_days
  from es_warehouse.public.rentals r
  join es_warehouse.public.orders o
    on r.order_id = o.order_id
  join analytics.branch_earnings.market m
    on o.market_id = m.child_market_id
  join analytics.gs.PLEXI_PERIODS pp
    on month(r.end_date) = pp.month_num
   and year(r.end_date) = pp.year
  where r.start_date is not null
    and r.end_date >= '2022-01-01'
  group by m.market_id, m.market_name, pp.display, date_trunc(month, r.end_date)
),
branch_transfer_haul as (
  select
    m.market_id,
    date_trunc(month, beds.gl_date) as month_year,
    -1 * sum(beds.amt) as branch_transfer_haul_amount
  from analytics.public.BRANCH_EARNINGS_DDS_SNAP beds
  join analytics.BRANCH_EARNINGS.market m
    on beds.mkt_id = m.child_market_id
  where beds.acctno = '6031'
  group by m.market_id, date_trunc(month, beds.gl_date)
)
select
  dc.market_id,
  dc.market_name,
  dc.delivery_month,
  pp.display,
  dc.deliveries,
  hlf.delivery_revenue,
  coalesce(drive.num_drivers, 0) as num_drivers,
  hlf.delivery_expense,
  hlf.delivery_expense / dc.deliveries as avg_cost_of_delivery,
  hlf.delivery_revenue / dc.deliveries as avg_delivery_rev,
  hlf.rental_revenue,
  rl.avg_rental_length_days,
  hlf.outside_hauling_expense,
  coalesce(bth.branch_transfer_haul_amount, 0) as branch_transfer_haul_amount
from delivery_count dc
left join delivery_rev dr
  on dc.market_id = dr.market_id
 and dc.delivery_month = date_trunc(month, dr.billed_month)
left join driver_count drive
  on dc.market_id = drive.market_id
 and dc.delivery_month = drive.delivery_month
left join analytics.BRANCH_EARNINGS.HIGH_LEVEL_FINANCIALS hlf
  on dc.market_id = hlf.market_id
 and dc.delivery_month = date_trunc(month, hlf.gl_date)
left join analytics.gs.PLEXI_PERIODS pp
  on month(dc.delivery_month) = pp.month_num
 and year(dc.delivery_month) = pp.year
left join rental_length rl
  on dc.market_id = rl.market_id
 and dc.delivery_month = rl.month_year
left join branch_transfer_haul bth
  on dc.market_id = bth.market_id
 and dc.delivery_month = bth.month_year
where hlf.delivery_expense > 0
  and hlf.delivery_revenue > 0

      ;;
  }
  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: delivery_month {
    label: "Delivery Month"
    type: date
    sql: ${TABLE}."DELIVERY_MONTH" ;;
  }

  measure: deliveries {
    label: "Deliveries"
    type: sum
    sql: ${TABLE}."DELIVERIES" ;;
  }

  measure: delivery_revenue {
    label: "Delivery Revenue"
    type: sum
    sql: ${TABLE}."DELIVERY_REVENUE" ;;
  }

  measure: num_drivers {
    label: "# of Drivers"
    type: average
    sql: ${TABLE}."NUM_DRIVERS" ;;
  }

  measure: delivery_expense {
    label: "Cost of Delivery"
    type: sum
    sql: ${TABLE}."DELIVERY_EXPENSE" ;;
  }

  measure: avg_cost_of_delivery {
    label: "Avg Cost of Delivery"
    type: average
    sql: ${TABLE}."AVG_COST_OF_DELIVERY" ;;
  }

  measure: avg_delivery_rev {
    label: "Avg Delivery Revenue"
    type: average
    sql: ${TABLE}."AVG_DELIVERY_REV" ;;
  }

  measure: rental_revenue {
    label: "Rental Revenue"
    type:  sum
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }

  measure: outside_hauling_expense {
    label: "Outside Hauling Expense"
    type:  sum
    sql: ${TABLE}."OUTSIDE_HAULING_EXPENSE" ;;
  }

  measure: avg_rental_length_days {
    label: "Avg Rental Length in Days"
    type: sum
    sql: ${TABLE}."AVG_RENTAL_LENGTH_DAYS" ;;
  }

  measure: branch_transfer_haul_amount {
    label: "Branch Transfer Expense"
    type: sum
    sql: ${TABLE}."BRANCH_TRANSFER_HAUL_AMOUNT" ;;
  }

}
