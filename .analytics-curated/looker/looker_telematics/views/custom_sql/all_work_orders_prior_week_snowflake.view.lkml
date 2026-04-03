view: all_work_orders_prior_week_snowflake {

  derived_table: {
    sql: select user_id as user_id, last_name as last_name, first_name as first_name, count(distinct work_order_id) as work_order_count
      from ES_WAREHOUSE.work_orders.work_orders_by_tag
      where name in ('New Tracker','New Keypad','Replace Keypad','Replace Tracker')
      and date_completed::date >= dateadd(day, -7, current_date)
      group by user_id, last_name, first_name
      order by work_order_count desc
                                     ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: work_order_count {
    type: number
    sql: ${TABLE}.work_order_count ;;
  }

}
