view: pending_inspections_per_day {
  derived_table: {
    sql:
    with generated_dates as (
      SELECT dateadd(day, '-' || row_number() over (order by null), dateadd(day, 1, current_date())
          ) as generated_date
          , TIMESTAMP_NTZ_FROM_PARTS(generated_date::DATE, '09:00:00'::TIME) as generated_datetime
      FROM table(generator(rowcount => 2000))
      )
      select generated_datetime as four_am
          , wo.branch_id
          , wo.work_order_id
      , case
               when woo.ORIGINATOR_TYPE_ID = 3 then 'MGI'
               when wo.WORK_ORDER_TYPE_ID = 1 then 'General'
               when wo.WORK_ORDER_TYPE_ID = 2 then 'Inspection'
       else 'Unknown' end                                     as wo_type_origin
        from generated_dates gd
        join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
            on generated_datetime > wo.date_created
                and generated_datetime < coalesce(wo.date_completed, current_timestamp)
        left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_ORIGINATORS as woo on wo.WORK_ORDER_ID = woo.WORK_ORDER_ID
        join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
            on m.market_id = wo.branch_id
        where wo.archived_date is null ;;
  }

  dimension_group: report_date {
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
    sql: CAST(${TABLE}.four_am AS TIMESTAMP_NTZ) ;;
  }

  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.branch_id ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}.work_order_id ;;
  }
  dimension: wo_type_origin {
    type: string
    sql: ${TABLE}.wo_type_origin ;;
  }

  # count of pending inspections for any grouping
  measure: total_pending_inspections {
    type: count_distinct
    sql: ${work_order_id} ;;
  }

  # distinct days in the result set
  measure: total_days_in_results {
    label: "Total days pending"
    type: count_distinct
    sql: ${report_date_date} ;;
  }

  # average inspections per day
  measure: avg_pending_inspections {
    type: number
    value_format_name: decimal_1
    sql: ${total_pending_inspections} / NULLIF(${total_days_in_results}, 0) ;;
    drill_fields: [work_order_details*, total_days_in_results]
  }
  set: work_order_details {
    fields: [
              work_orders.date_created_date,
              work_orders.date_completed_date,
              market_region_xwalk.market_name,
              work_orders.work_order_id_with_link_to_work_order,
              work_orders.description,
              work_orders.work_order_status_name,
              billing_types.name,
            ]
  }
}
