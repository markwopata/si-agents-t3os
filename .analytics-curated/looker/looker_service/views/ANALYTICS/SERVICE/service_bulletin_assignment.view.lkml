view: service_bulletin_assignment {
  sql_table_name: "ANALYTICS"."SERVICE"."SERVICE_BULLETIN_ASSIGNMENT" ;;
  drill_fields: [service_bulletin_assignment_id]

  dimension: service_bulletin_assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SERVICE_BULLETIN_ASSIGNMENT_ID" ;;
    value_format_name: id
  }
  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }
  dimension: assigned_by {
    type: string
    sql: ${TABLE}."ASSIGNED_BY" ;;
  }
  dimension_group: date_assigned {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_ASSIGNED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: is_current {
    type: yesno
    sql: ${TABLE}."IS_CURRENT" ;;
  }
  dimension: service_bulletin_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."SERVICE_BULLETIN_ID" ;;
    value_format_name: id
  }
  dimension: updated_by {
    type: string
    sql: ${TABLE}."UPDATED_BY" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }
  measure: count {
    type: count
    drill_fields: [service_bulletin_assignment_id, service_bulletins.service_bulletin_name, service_bulletins.service_bulletin_id]
  }
}
