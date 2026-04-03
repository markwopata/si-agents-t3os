view: command_audit {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMMAND_AUDIT"
    ;;
  drill_fields: [command_audit_id]

  dimension: command_audit_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMMAND_AUDIT_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: audit_event_source_id {
    type: number
    sql: ${TABLE}."AUDIT_EVENT_SOURCE_ID" ;;
  }

  dimension: command {
    type: string
    sql: ${TABLE}."COMMAND" ;;
  }

  dimension_group: date_created {
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
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: parameters {
    type: string
    sql: ${TABLE}."PARAMETERS" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension:  command_is_last_month {
    type: yesno
    sql: date_part(month,${date_created_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
      and date_part(year,${date_created_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
  }

  dimension: close_work_order_command {
    type: yesno
    sql: ${command} = 'CloseWorkOrder' ;;
  }

  dimension: work_order_is_null {
    type: yesno
    sql: ${parameters}:work_order_id IS NULL ;;
  }

  measure: total_work_orders_last_month {
    type: count
    filters: [close_work_order_command: "Yes" ,
              work_order_is_null: "No",
              command_is_last_month: "Yes"]
  }

  measure: count {
    type: count
    drill_fields: [command_audit_id]
  }
}
