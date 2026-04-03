view: warranty_missed_opp_flipped {
  derived_table: {
    sql:
select date_trunc(month, wr.review_date) as month
    , wr.review_date
    , dwo.work_order_market_id as market_id
    , wr.work_order_id
    , i.invoice_id
    , wr.invoice_no
    , zeroifnull(woc.wo_cost) as work_order_value
    , (zeroifnull(w.warranty_credits_paid_amount) + zeroifnull(w.warranty_credits_denied_amount) + zeroifnull(w.warranty_credits_pending_amount)) as filed_amount
from ANALYTICS.WARRANTIES.WARRANTY_REVIEWS wr
join (select distinct work_order_id from ANALYTICS.WARRANTIES.WARRANTY_REVIEWS where warranty_state ilike '%missed%') mm
    on mm.work_order_id = wr.work_order_id
join FLEET_OPTIMIZATION.GOLD.DIM_WORK_ORDERS_FLEET_OPT dwo
    on dwo.work_order_id = wr.work_order_id
left join FLEET_OPTIMIZATION.GOLD.DIM_INVOICES_FLEET_OPT i
    on i.invoice_no = trim(wr.invoice_no)
left join FLEET_OPTIMIZATION.GOLD.FACT_WARRANTY_CREDITS w
    on w.warranty_credits_invoice_key = i.invoice_key
left join (
        select dwo.work_order_id
            , sum(zeroifnull(wl.work_order_line_amount)) as wo_cost
        from PLATFORM.GOLD.DIM_WORK_ORDERS dwo
        join PLATFORM.GOLD.FACT_WORK_ORDER_LINES wl
            on wl.work_order_line_work_order_key = dwo.work_order_key
        group by 1
    ) woc
    on woc.work_order_id = wr.work_order_id
where (wr.is_current = true or wr.warranty_state = 'Segmented Claim') and warranty_state <> 'Not Warranty';;
  }

  dimension: month {
    type: date
    convert_tz: no
    sql: ${TABLE}.month ;;
  }
  dimension_group: review {
    type: time
    sql: ${TABLE}.review_date ;;
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
  }
  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }
  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.invoice_id ;;
  }
  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice_no ;;
    label: "Warranty Invoice No"
    html: <a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ invoice_no._value }}</a> ;;
  }
  dimension: work_order_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}.work_order_value ;;
  }
  dimension: invoice_amount {
    type: number
    value_format_name: usd
    label: "Warranty Invoice Amount"
    sql: ${TABLE}.filed_amount ;;
  }
  dimension: filed {
    type:yesno
    sql: iff(${invoice_id} is null, false, true) ;;
  }
  measure: unbilled_missed_opp {
    type: sum
    filters: [filed: "no"]
    value_format_name: usd_0
    sql: ${work_order_value} ;;
    drill_fields: [detail*]
  }
  measure: count_unbilled_missed_opp {
    type: count
    filters: [filed: "no"]
  }
  measure: total_work_order_value {
    type: sum_distinct
    sql_distinct_key: ${work_order_id};;
    value_format_name: usd_0
    sql: ${work_order_value} ;;
    drill_fields: [detail*]
  }
  measure: count_distinct_work_order_id {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [detail*]
  }
  measure: billed_missed_opp {
    type: sum
    value_format_name: usd_0
    sql: ${invoice_amount} ;;
    drill_fields: [detail*]
  }
  measure: count_billed_missed_opp {
    type: count_distinct
    filters: [filed: "yes"]
    sql: ${work_order_id} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      market_region_xwalk.market_name
      , work_order_id
      , work_orders.date_completed_date
      , work_orders.work_order_status_name
      , work_orders.asset_id
      , dim_assets_fleet_opt.asset_equipment_make
      , dim_assets_fleet_opt.asset_equipment_model_name
      , work_order_value
      , review_date
      , invoice_no
      , invoice_amount
    ]
  }
}
