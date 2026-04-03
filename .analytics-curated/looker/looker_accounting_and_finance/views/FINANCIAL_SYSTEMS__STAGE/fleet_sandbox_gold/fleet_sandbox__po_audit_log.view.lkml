view: fleet_sandbox__po_audit_log {
  sql_table_name: "FLEET_GOLD"."FLEET_SANDBOX__PO_AUDIT_LOG" ;;

  dimension: action_taken {
    type: string
    sql: ${TABLE}."ACTION_TAKEN" ;;
  }
  dimension: change_field {
    type: string
    sql: ${TABLE}."CHANGE_FIELD" ;;
  }
  dimension: change_value {
    type: string
    sql: ${TABLE}."CHANGE_VALUE" ;;
  }
  dimension: email_user {
    type: string
    sql: ${TABLE}."EMAIL_USER" ;;
  }
  dimension: fk_po_audit_log_id {
    type: number
    sql: ${TABLE}."FK_PO_AUDIT_LOG_ID" ;;
  }
  dimension: fk_user_id {
    type: number
    sql: ${TABLE}."FK_USER_ID" ;;
  }
  dimension: name_user {
    type: string
    sql: ${TABLE}."NAME_USER" ;;
  }
  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_LOADED" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
  }
}
