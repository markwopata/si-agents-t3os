view: customer_charge_asset_info {
  derived_table: { # this was used for the old service dashboard "customer charge" but is actually just customer damage, and includes internal bills.
    # datagroup_trigger: Every_Hour_Update
#     indexes: ["invoice_id"]
    sql: with invoice_amt as (
    select
    invoice_id,
    max(branch_id) as branch_id,
    sum(amount) as total_amt
    from
    ES_WAREHOUSE.PUBLIC.line_items li
    where
    line_item_type_id in (25,26)
    group by
    invoice_id
    ),
    invoice_asset_info as (
    select
    invoice_id,
    max(asset_id) as asset_id
    from
    ES_WAREHOUSE.PUBLIC.line_items li
    where
    asset_id is not null
    group by
    invoice_id
    ),
    invoice_credited as (
    select
    invoice_id,
    invoice_no,
    paid,
    date_created
    from
    ES_WAREHOUSE.PUBLIC.invoices i
    where
    billing_approved_date is not null
    )
    select
    ia.invoice_id,
    ia.branch_id,
    ai.asset_id,
    ia.total_amt,
    ic.invoice_no,
    ic.paid,
    ic.date_created
    from
    invoice_amt ia
    left join invoice_asset_info ai on ia.invoice_id = ai.invoice_id
    left join invoice_credited ic on ia.invoice_id = ic.invoice_id
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: invoice_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: total_amt {
    type: number
    sql: ${TABLE}."TOTAL_AMT" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: paid {
    type: string
    sql: ${TABLE}."PAID" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  measure: total_invoice_amount {
    type: sum
    sql: ${total_amt} ;;
    filters: [last_30_days: "Yes"]
    drill_fields: [detail*]
    value_format_name: usd
  }

  measure: total_amount {
    type: sum
    sql: ${total_amt} ;;
    drill_fields: [detail*]
    value_format_name: usd
  }

  dimension:  current_ytd{
    type: yesno
    sql: (day(${date_created_raw}) <= day(current_date())
          AND month(${date_created_raw}) = month(current_date())
          AND year(${date_created_raw}) = year(current_date()))
          OR
          (month(${date_created_raw}) < month(current_date())
          AND year(${date_created_raw}) = year(current_date())) ;;
  }

  dimension:  last_30_days{
    type: yesno
    sql:  ${date_created_date} <= current_date AND ${date_created_date} >= (current_date - INTERVAL '30 days')
      ;;
  }

  measure: ytd_total_invoice_amount {
    type: sum
    sql: ${total_amt} ;;
    filters: [current_ytd: "Yes"]
    drill_fields: [detail*]
    value_format_name: usd
  }

  set: detail {
    fields: [market_region_xwalk.region_name, market_region_xwalk.market_name, date_created_date, invoice_no, asset_id, assets.make, total_amt]
  }
}
