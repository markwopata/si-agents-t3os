view: work_orders_open_rolling_90 {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
#     indexes: ["MARKET_ID"]
    sql: with get_past_days as
    (
    select
    dateadd(
    day,
    '-' || row_number() over (order by null),
    dateadd(day, '+1', current_date())
    ) as generated_date
    from table (generator(rowcount => 90))
    ),
    days_open as (
    select
    pd.generated_date,
    m.market_id,
    wo.work_order_id,
    wo.work_order_type_id,
    wot.NAME as work_order_type,
    wo.date_created,
    wo.date_completed,
    pd.generated_date - wo.date_created::date as days_in_status
    from
    ES_WAREHOUSE.WORK_ORDERS.work_orders wo
    inner join get_past_days pd on pd.generated_date::date between wo.date_created::date and coalesce(wo.date_completed::date,current_date)
    inner join ES_WAREHOUSE.PUBLIC.markets m on m.market_id = wo.branch_id
    left join ES_WAREHOUSE.work_orders.work_order_types wot on wot.work_order_type_id = wo.work_order_type_id
    where
    wo.archived_date is null
    and m.company_id = 1854
    )
    select
    generated_date::date as generated_date,
    work_order_type,
    market_id,
    sum(case when days_in_status >= 45 then 1 end) as open_wo_count
    from
    days_open
    group by
    generated_date::date,
    work_order_type,
    market_id
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: generated_date {
    type: date
    sql: ${TABLE}."GENERATED_DATE" ;;
  }

  dimension: work_order_type {
    type: string
    sql: ${TABLE}."WORK_ORDER_TYPE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: open_wo_count {
    type: number
    sql: ${TABLE}."OPEN_WO_COUNT" ;;
  }

  measure: total_work_orders_open {
    type: sum
    sql: ${open_wo_count} ;;
  }

  measure: average_work_orders_open_last_90_days {
    type: number
    sql: ${total_work_orders_open}/90 ;;
    value_format_name: decimal_1
    drill_fields: [detail*]
  }

  set: detail {
    fields: [generated_date, market_region_xwalk.region_name, market_region_xwalk.market_name, work_order_type, total_work_orders_open]
  }
}
