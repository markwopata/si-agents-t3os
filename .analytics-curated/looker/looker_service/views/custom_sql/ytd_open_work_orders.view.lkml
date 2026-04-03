view: ytd_open_work_orders {
 derived_table: {
   sql: with get_past_days as (
    select
        dateadd(day, '-' || row_number() over (order by null),
        dateadd(day, '+1', current_timestamp())) as generateddate
    from table (generator(rowcount => 400)))

    select
    d.generateddate as date_of,
    wo.BRANCH_ID,
    wo.DATE_CREATED,
    iff(wo.work_order_status_id=1 or wo.date_completed is null, '9999-12-31',wo.DATE_COMPLETED) end_date,
    wo.WORK_ORDER_ID,
    wo.WORK_ORDER_TYPE_ID,
    wo.ARCHIVED_DATE,
    wo.asset_id
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS as wo
    inner join get_past_days as d
    on d.generateddate <= end_date
    and d.generateddate >= wo.DATE_CREATED
    and wo.WORK_ORDER_TYPE_ID = 1
    and wo.ARCHIVED_DATE is null;;
    }


dimension_group: date_of {
  type: time
  timeframes: [raw,date,time,week,month,quarter,year]
  sql: ${TABLE}."DATE_OF" ;;
}

dimension: date_created {
  type: date
  sql: ${TABLE}."DATE_CREATED" ;;
}

dimension: date_completed {
  type: date
  sql: ${TABLE}."END_DATE" ;;
}

dimension: branch_id {
  type: string
  sql: ${TABLE}."BRANCH_ID" ;;
}

dimension: work_order_id {
  type: string
  sql: ${TABLE}."WORK_ORDER_ID" ;;
}

dimension: work_order_type_id {
  type: string
  sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
}

dimension: archived_date {
  type: date
  sql: ${TABLE}."ARCHIVED_DATE" ;;
}

dimension: asset_id {
  type: string
  sql: ${TABLE}."ASSET_ID" ;;
}

measure: open_work_orders {
  type: count_distinct
  sql: ${work_order_id} ;;
}

}
