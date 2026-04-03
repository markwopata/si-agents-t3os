view: warranty_invoice_asset_info {
  sql_table_name: ANALYTICS.WARRANTIES.WARRANTY_INVOICES ;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    primary_key: yes
  }

  dimension: gl_accounts {
    type: string
    sql: iff(${TABLE}.invoice_id in (
      select distinct invoice_id
      from ES_WAREHOUSE.PUBLIC.LINE_ITEMS
      where line_item_type_id in (22, 23))
      , 'Warranty Revenue', 'Warranty Denials and Expired Claims Revenue') ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: total_amt_requested{
    type: number
    sql: ${TABLE}."TOTAL_AMT" ;;
  }

  dimension: credit_amt {
    type: number
    sql: ${TABLE}."CREDIT_AMT" ;;
  }

  dimension: denied_amt {
    type: number
    sql: ${TABLE}.total_Denied_amt ;;
  }

  dimension: full_denial {
    type: string
    sql: ${TABLE}.full_denial ;;
  }

  measure: denied_count {
    type: count
    filters: [full_denial: "true"]
    drill_fields: [detail*]
  }

  dimension: pending_amt {
    type:  number
    sql: ${TABLE}."PENDING_AMT" ;;
  }

  measure: pending_count {
    type: count
    filters: [warranty_status: "Pending"]
  }

  dimension: paid_amt {
    type: number
    sql:  ${TABLE}."PAID_AMT" ;;
  }


  dimension: claim_closure_days {
    type: number
    sql:  ${TABLE}."CLAIM_CLOSURE_DAYS" ;;
  }

  measure: credit_amt_sum {
    type: sum
    sql: ${credit_amt} ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: paid {
    type: string
    sql: ${TABLE}."PAID" ;;
  }

  dimension: warranty_status {
    type: string
    sql: case when ${paid} = 'No' or ${paid} is null then 'Pending'
          when ${paid} = 'Yes' and ${denied_amt} = ${total_amt_requested} then 'Denied'
          ELSE 'Paid'
          END;;
  }
  dimension: warranty_recovery {
    type: number
    sql: ${pending_amt}+${paid_amt} ;;
  }

  dimension: warranty_team_created {
    type: string
    sql: ${TABLE}.warranty_team_created ;;
  }

  measure: total_invoice_amount {
    type: sum
    sql: ${total_amt_requested} ;;
    drill_fields: [detail*]
    value_format_name: usd_0

    link: {
      label: "View Warranty History"
      url: "https://equipmentshare.looker.com/looks/60?f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.district]={{ _filters['market_region_xwalk.district'] | url_encode }}&toggle=det"
    }
  }

  measure: total_invoice_amount_paid {
    type: sum
    sql: ${paid_amt} ;;
    drill_fields: [detail*]
    value_format_name: usd_0
    # filters: [warranty_status: "Paid"] #Removed by TA on April 18, 2024, creates inaccuracies in totals because logic creating this field is outdated.
    link: {
      label: "View Warranty History"
      url: "https://equipmentshare.looker.com/looks/60?f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.district]={{ _filters['market_region_xwalk.district'] | url_encode }}&toggle=det"
    }
  }

  measure: amount_paid_per_claim {
    type: average
    drill_fields: [detail*]
    value_format_name: usd_0
    sql:  ${paid_amt} ;;
  }

  measure: total_invoice_amount_pending {
    type: sum
    sql: ${pending_amt} ;;
    drill_fields: [detail*]
    value_format_name: usd_0
    # filters: [warranty_status: "Pending"] #Removed by TA on April 18, 2024, creates inaccuracies in totals because logic creating this field is outdated.
    link: {
      label: "View Warranty History"
      url: "https://equipmentshare.looker.com/looks/60?f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.district]={{ _filters['market_region_xwalk.district'] | url_encode }}&toggle=det"
    }
  }

  measure: total_invoice_amount_denied {
    type: sum
    sql: ${denied_amt} ;;
    drill_fields: [detail*]
    value_format_name: usd_0
    # filters: [warranty_status: "Denied"] #Removed by TA on April 18, 2024, creates inaccuracies in totals because logic creating this field is outdated.
    link: {
      label: "View Warranty History"
      url: "https://equipmentshare.looker.com/looks/60?f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.district]={{ _filters['market_region_xwalk.district'] | url_encode }}&toggle=det"
    }
  }

  measure: total_warranty_denied {
    type: sum
    sql: -${denied_amt} ;;
    drill_fields: [detail*]
    value_format_name: usd
    filters: [warranty_status: "Denied"]
    link: {
      label: "View Warranty History"
      url: "https://equipmentshare.looker.com/looks/60?f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.district]={{ _filters['market_region_xwalk.district'] | url_encode }}&toggle=det"
    }
  }

  measure: total_warranty_recovery {
    type: sum
    sql: ${warranty_recovery} ;;
    value_format_name: usd
    link: {
      label: "View Warranty History"
      url: "https://equipmentshare.looker.com/looks/60?f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.district]={{ _filters['market_region_xwalk.district'] | url_encode }}&toggle=det"
    }
  }

  measure: recovery_percentage {
    type: number
    value_format_name: percent_0
    sql: ${total_invoice_amount_paid} / ${total_invoice_amount} ;;
    drill_fields: [detail*]
  }

  dimension: unpaid {
    type: number
    value_format_name: usd
    sql: ${total_amt_requested} - ${paid_amt} ;;
  }

  measure: total_unpaid {
    type: sum
    value_format_name: usd
    sql: ${unpaid} ;;
    drill_fields: [detail*]
  }

  measure: count_paid {
    type: count
    filters: [warranty_status: "Paid"]
    drill_fields: [detail*]
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  measure: min_created_date {
    type: date
    sql: min(${created_date}) ;;
  }

  measure: days_in_period {
    type: number
    sql: datediff(day, ${min_created_date}, current_date()) ;;
  }

  measure: weeks_in_period {
    type: number
    sql: datediff(week, ${min_created_date}, current_date()) ;;
  }

  dimension_group: billing_approved {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: warranty_parts_requested  {
    type: number
    sql:  ${TABLE}."WARRANTY_PARTS_REQUESTED" ;;
  }

  measure: total_parts_requested {
    type: sum
    value_format_name: usd_0
    sql: ${warranty_parts_requested} ;;
    drill_fields: [detail*]
  }

  dimension: warranty_labor_requested  {
    type: number
    sql:  ${TABLE}."WARRANTY_LABOR_REQUESTED" ;;
  }

  measure: total_labor_requested {
    type: sum
    value_format_name: usd_0
    sql: ${warranty_labor_requested} ;;
    drill_fields: [detail*]
  }


# Used to join to warranty_invoices_xwalk in service_warranty model
dimension: formatted_invoice_no {
  type:  number
  sql: replace(${invoice_no}, '-000', '') ;;
}

dimension: plus_minus {
  type:  number
  sql:  ${total_amt_requested} - ${credit_amt};;
}

measure: total_invoice_amount_2018 {
  type: sum
  sql:  case when ${billing_approved_date} < 2019-01-01 and ${billing_approved_date} >= 2018-01-01 then ${total_amt_requested} end ;;
}

  measure: invoice_count {
    type: count_distinct
    sql: ${TABLE}."INVOICE_ID" ;;
    # html: {{total_invoice_amount._rendered_value}} Claimed Warranty with {{invoice_count._rendered_value}} Invoices ;;
    drill_fields: [detail*]
  }

  measure: invoice_count_w_total_amt {
    type: count_distinct
    sql: ${TABLE}."INVOICE_ID" ;;
    html: {{total_invoice_amount_paid._rendered_value}} Paid Warranty on {{invoice_count._rendered_value}} Invoices ;;
    drill_fields: [detail*]
  }

  # -------------------- rolling 30 days section --------------------
  dimension:  last_30_days{
    type: yesno
    sql:  ${billing_approved_date} <= current_date AND ${billing_approved_date} >= (current_date - INTERVAL '30 days')
      ;;
  }

  dimension:  30_60_days{
    type: yesno
    sql:  ${billing_approved_date} <= (current_date - INTERVAL '30 days') AND ${billing_approved_date} >= (current_date - INTERVAL '60 days')
      ;;
  }
  measure: 30_day_count {
    type: count_distinct
    filters: [last_30_days: "Yes"]
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  measure: 30_60_day_count {
    type: count_distinct
    filters: [30_60_days: "Yes"]
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  measure: 30_day_count_paid {
    type: count_distinct
    filters: [last_30_days: "Yes", warranty_status: "Paid"]
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  measure: 30_60_day_count_paid {
    type: count_distinct
    filters: [30_60_days: "Yes", warranty_status: "Paid"]
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  measure: 30_day_cost {
    type: sum
    filters: [last_30_days: "Yes"]
    value_format_name:usd
    value_format: "$#,##0"
    sql:${total_amt_requested};;
  }

  measure: 30_60_day_cost {
    type: sum
    filters: [30_60_days: "Yes"]
    value_format_name:usd
    value_format: "$#,##0"
    sql:${total_amt_requested};;
  }

  measure: 30_day_cost_paid {
    type: sum
    value_format_name:usd
    value_format: "$#,##0"
    filters: [last_30_days: "Yes", warranty_status: "Paid"]
    sql:${paid_amt};;
  }

  measure: 30_60_day_cost_paid {
    type: sum
    value_format_name:usd
    value_format: "$#,##0"
    filters: [30_60_days: "Yes", warranty_status: "Paid"]
    sql:${paid_amt};;
  }

# -------------------- updated rolling 30 days section --------------------

  measure: since_30_days_cost {
    type: sum
    filters: [last_30_days: "No"]
    value_format_name:usd
    value_format: "$#,##0"
    sql:${total_amt_requested};;
  }

  measure: since_30_days_cost_paid {
    type: sum
    value_format_name:usd
    value_format: "$#,##0"
    filters: [last_30_days: "No", warranty_status: "Paid"]
    sql:${paid_amt};;
  }

  measure: avg_claim_closure {
    type: average
    value_format: "0"
    sql: ${TABLE}.claim_closure_days ;;
  }

  measure: since_30_days_avg_claim_closure {
    type: average
    filters: [last_30_days: "No"]
    value_format: "0"
    sql: ${TABLE}.claim_closure_days ;;
  }

  # -------------------- end rolling 30 days section --------------------

  dimension: admin_link_to_invoice {
    label: "Invoice ID"
    type: string
    html: <u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_id}}" target="new" style="color: #0063f3; text-decoration: underline;">{{invoice_id._value}}</a></font></u> ;;
    sql: ${invoice_id}  ;;
  }

  dimension: work_order_id_with_link_to_work_order {
    label: "Work Order ID"
    type: string
    sql: ${work_order_id} ;;
    html:<u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a></font></u> ;;
  }

  parameter: max_rank {
    type: number
  }

  dimension: rank_limit {
    type:  number
    sql:  {% parameter max_rank %} ;;
  }

dimension: public_note {
  type: string
  sql: ${TABLE}.public_note ;;
}

dimension: WO_or_note {
  label: "WO or Invoice Note"
  type: string
  sql: coalesce(${work_order_id_with_link_to_work_order}::string, ${public_note}) ;;
}

dimension: days_to_make_claim {
  type: number
  sql: ${TABLE}.days_to_claim ;;
}

measure: outstanding_invoices_count {
  type: count
  filters: [pending_amt: "> 0"]
  drill_fields: [market_region_xwalk.region_name
      , market_region_xwalk.market_name
      , invoices.date_created_date
      , invoices.invoice_no
      , admin_link_to_invoice
      , companies.customer_name
      , asset_id
      , assets_aggregate.make
      , assets_aggregate.model
      , total_invoice_amount
      , total_invoice_amount_pending
      , WO_or_note

  ]
}

  set: detail {
    fields: [market_region_xwalk.region_name
      , market_region_xwalk.market_name
      , invoices.date_created_date
      , invoices.invoice_no
      , admin_link_to_invoice
      , companies.customer_name
      , asset_id
      , assets_aggregate.make
      , assets_aggregate.model
      , full_denial
      , total_invoice_amount
      , total_invoice_amount_paid
      , total_invoice_amount_pending
      , total_invoice_amount_denied
      , WO_or_note
      ]
  }

  dimension: days_since_jan_1 {
    type: number
    sql: datediff(day, date_trunc(year, current_date()), current_date()) ;;
  }

  dimension: claim_date_to_jan_1 {
    type: number
    sql: datediff(day, date_trunc(year, ${created_raw}), ${created_raw}) ;;
  }

  dimension: show_in_ytd_comparison {
    type: yesno
    sql: ${claim_date_to_jan_1} <= ${days_since_jan_1} ;;
  }

  dimension: claim_numbers {
    type: string
    sql: ${TABLE}.claim_numbers ;;
  }
}

view: warranty_oem_summary {
  derived_table: {
    sql:
select left(date_trunc(year, wi.date_created), 4) as year
    , aa.make
    , sum(wi.total_amt) as claim_amt
    , sum(wi.paid_amt) as paid_amt
    , sum(wi.total_denied_amt) as denied_amt
    , sum(wi.pending_amt) as pending_amt
from ANALYTICS.WARRANTIES.WARRANTY_INVOICES wi
left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    on aa.asset_id = wi.asset_id
group by left(date_trunc(year, wi.date_created), 4), aa.make ;;
  }

  dimension: year {
    type: number
    value_format_name: id
    sql: ${TABLE}.year ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: claim_amt {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.claim_amt;;
  }

  measure: total_claim_amt {
    type: sum
    value_format_name: usd_0
    sql: ${claim_amt} ;;
  }

  dimension: paid_amt {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.paid_amt;;
  }

  measure: total_paid_amt {
    type: sum
    value_format_name: usd_0
    sql: ${paid_amt} ;;
  }

  dimension: denied_amt {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.denied_amt;;
  }

  measure: total_denied_amt {
    type: sum
    value_format_name: usd_0
    sql: ${denied_amt} ;;
  }

  dimension: pending_amt {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.pending_amt;;
  }

  measure: total_pending_amt {
    type: sum
    value_format_name: usd_0
    sql: ${pending_amt} ;;
  }
}

view: warranty_oem_yr_claim_summary_by_make { #This is so we have an adjusted claims per week goal based on how much we have submitted YTD
  derived_table: {
    sql: with generated_dates as (
    SELECT dateadd(week, '-' || row_number() over (order by null), date_trunc(week, current_date())
        ) as generated_date
    FROM table(generator(rowcount => 1000))
)

select generated_date
    , make
    , sum(claim_amt) as claims_for_that_year
from generated_dates gd
join ${warranty_oem_summary.SQL_TABLE_NAME}
    on year = left(date_trunc(year, generated_date), 4)
group by generated_date, make ;;
  }

  dimension: generated_date {
    type: date
    sql: ${TABLE}.generated_date ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make;;
  }

  dimension: claims_for_that_year {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.claims_for_that_year ;;
  }

  measure: total_claims_for_that_year {
    type: sum
    value_format_name: usd_0
    sql: ${claims_for_that_year} ;;
  }


}
