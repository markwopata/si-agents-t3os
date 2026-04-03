view: work_order_payroll {

  derived_table: {
    sql:
   SELECT tte.user_id AS user_id, tte.start_date AS start_date,
tte.end_date AS end_date, tte.WORK_ORDER_ID AS work_order_id,
wo.DATE_CREATED AS date_created,
wo.DATE_COMPLETED AS date_completed, (u.LAST_NAME||', '||u.FIRST_NAME) AS installer,
sum(tte.duration)/3600 AS payroll_hours
FROM ES_WAREHOUSE.TIME_TRACKING.TIME_TRACKING_ENTRIES AS tte
LEFT JOIN ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS AS wo
ON (wo.WORK_ORDER_ID = tte.WORK_ORDER_ID) AND (tte.user_id = wo.CREATOR_USER_ID)
LEFT JOIN es_warehouse.PUBLIC.USERS AS u
ON u.user_id = tte.USER_ID
WHERE tte.event_type_id = 1
GROUP BY tte.user_id, tte.start_date, tte.end_date, tte.WORK_ORDER_ID, wo.DATE_CREATED,
wo.DATE_COMPLETED, (u.LAST_NAME||', '||u.FIRST_NAME)
                         ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: start_date {
    type: date_time
    sql: ${TABLE}.start_date ;;
  }

  dimension: end_date {
    type: date_time
    sql: ${TABLE}.end_date ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}.work_order_id ;;
  }

  dimension: date_created {
    type: date_time
    sql: ${TABLE}.date_created ;;
  }

  dimension: date_completed {
    type: date_time
    sql: ${TABLE}.date_completed ;;
  }

  dimension: installer {
    type: string
    sql: ${TABLE}.installer ;;
  }

  dimension: payroll_hours {
    type: number
    sql: ${TABLE}.payroll_hours ;;
  }

  measure: work_order_count {
    type: count_distinct
    sql: ${work_order_id} ;;
  }

  measure: hours_spent_on_work_order {
    type:  sum
    #sql: case when ${work_order_id} is null then 0 else ${payroll_hours} end ;;
    sql: ${payroll_hours} ;;
    filters: [work_order_id: "NOT NULL"]
  }

  measure: hours_not_spent_on_work_order {
    type:  sum
    #sql: case when ${work_order_id} is null then ${payroll_hours}  else 0  end ;;
    sql: ${payroll_hours}  ;;
    filters: [work_order_id: "NULL"]
  }

  }
