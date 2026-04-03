view: work_order_user_assignments {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_USER_ASSIGNMENTS" ;;
  drill_fields: [work_order_user_assignment_id]

  dimension: work_order_user_assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_USER_ASSIGNMENT_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  dimension: work_order_user_assignment_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_USER_ASSIGNMENT_TYPE_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [work_order_user_assignment_id]
  }
}
view: wo_user_assignments_agg {
  derived_table: {
    sql: select work_order_id
    , listagg(concat(u.first_name,' ',u.last_name),', ') assigned
    from "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_USER_ASSIGNMENTS" wo
    join ES_WAREHOUSE.PUBLIC.USERS u
    on wo.user_id=u.user_id
    where u.company_id=1854 and wo.end_date is not null
    group by 1;;
  }

  dimension: work_order_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: assigned_users {
    type: string
    sql: ${TABLE}."ASSIGNED" ;;
  }
}
