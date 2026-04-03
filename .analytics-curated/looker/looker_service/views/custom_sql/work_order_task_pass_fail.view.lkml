view: work_order_task_pass_fail {
  derived_table: {
    sql:
with wosi as (
    select WORK_ORDER_ID
        , WORK_ORDER_STATE_ITEM_TYPE_ID
        , date_updated
        , lag(date_updated) over (partition by work_order_id order by date_updated asc) as last_task
        , datediff(second, last_task, date_updated) time_between_tasks
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_STATE_ITEMS
)

select WORK_ORDER_ID
    , count(work_order_id) as wo_count
    , sum(WORK_ORDER_STATE_ITEM_TYPE_ID) pass_fail
    , iff(pass_fail = wo_count, 1, 0) as pass
    , avg(time_between_tasks) seconds_between_tasks
from wosi
group by work_order_id;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.work_order_id ;;
  }

  measure: total {
    type: count
    drill_fields: [
        work_orders.work_order_id_with_link_to_work_order
        , work_orders.date_completed_date
        , pass
        , seconds_between_tasks
        , assets_aggregate.asset_id
        , assets_aggregate.make
        , assets_aggregate.model
        ]
  }

  dimension: pass {
    type: number
    sql: ${TABLE}.pass ;;
  }

  measure: total_passed {
    type: sum
    sql: ${pass} ;;
  }

  dimension: seconds_between_tasks {
    type: number
    value_format_name: decimal_4
    sql: ${TABLE}.seconds_between_tasks ;;
  }
}
