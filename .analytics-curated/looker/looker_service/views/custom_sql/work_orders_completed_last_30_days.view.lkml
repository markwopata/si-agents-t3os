view: work_orders_completed_last_30_days {
  derived_table: {
    sql: with work_orders_last_30 as (
    select
      wo.date_completed::date as date_completed,
      wo.work_order_id,
      wo.branch_id,
      wt.name as work_order_type,
      mrx.market_name,
      mrx.region_name,
      mrx.district
    from
      ES_WAREHOUSE.work_orders.work_orders wo
      left join ES_WAREHOUSE.work_orders.work_order_types wt on wo.work_order_type_id = wt.work_order_type_id
      inner join ANALYTICS.PUBLIC.market_region_xwalk mrx on mrx.market_id = wo.branch_id
    where
      wo.date_completed is not null
      and wo.archived_date is null
      and wo.date_completed::date between dateadd(day,-30,(dateadd(day,-1,current_date)))::date and dateadd(day,-1,current_date)::date
),
  wo_last_30_count as (
      select date_completed,
             BRANCH_ID,
             work_order_type,
             MARKET_NAME,
             REGION_NAME,
             DISTRICT,
             count(*) as total_complete
      from
        work_orders_last_30
      group by date_completed,
               work_order_type,
               branch_id,
               market_name,
               region_name,
               district
  )
select work_orders_last_30.*,
       wo_last_30_count.total_complete
       from work_orders_last_30 left join wo_last_30_count
       on work_orders_last_30.date_completed = wo_last_30_count.date_completed
        and work_orders_last_30.BRANCH_ID = wo_last_30_count.BRANCH_ID
        and work_orders_last_30.work_order_type = wo_last_30_count.work_order_type
        and work_orders_last_30.MARKET_NAME = wo_last_30_count.MARKET_NAME
        and work_orders_last_30.REGION_NAME = wo_last_30_count.REGION_NAME
        and work_orders_last_30.DISTRICT = wo_last_30_count.DISTRICT;;
  }

  dimension: primary_key {
    primary_key: yes
    hidden: yes
    sql: concat(${date_completed}, ${work_order_type}, ${branch_id}, ${market_name}, ${region_name}, ${district} ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: work_order_id_with_link_to_work_order {
    type: string
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/home/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  }

  dimension: date_completed {
    type: date
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension: work_order_type {
    type: string
    sql: ${TABLE}."WORK_ORDER_TYPE" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: total_complete {
    type: number
    sql: ${TABLE}."TOTAL_COMPLETE" ;;
    drill_fields: [work_order_id_with_link_to_work_order]
  }

  measure: work_orders_completed {
    type: count
    sql_distinct_key: ${primary_key} ;;
    drill_fields: [work_order_id_with_link_to_work_order]
  }

  measure: number_of_days {
    type: count_distinct
    sql: ${date_completed} ;;
    drill_fields: [detail*]
  }

  measure: average_work_orders_completed_last_30_days {
    type: number
    sql: ${work_orders_completed}/${number_of_days} ;;
    value_format_name: decimal_1
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      date_completed,
      region_name,
      market_name,
      work_order_type,
      work_orders_completed
    ]
  }

}
