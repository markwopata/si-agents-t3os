view: keypad_code_assignments {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."KEYPAD_CODE_ASSIGNMENTS"
    ;;
  drill_fields: [keypad_code_assignment_id]

  dimension: keypad_code_assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."KEYPAD_CODE_ASSIGNMENT_ID" ;;
  }

  dimension: _es_update_timestamp {
    type: date_time
    sql: ${TABLE}.CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: company_keypad_code_id {
    type: number
    sql: ${TABLE}."COMPANY_KEYPAD_CODE_ID" ;;
  }

  dimension: date_created {
    type: date_time
    sql: ${TABLE}.CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: end_date {
    type: date_time
    sql: ${TABLE}.CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: is_local_code {
    type: yesno
    sql: ${TABLE}."IS_LOCAL_CODE" ;;
  }

  dimension: keypad_code_assignment_status_id {
    type: number
    sql: ${TABLE}."KEYPAD_CODE_ASSIGNMENT_STATUS_ID" ;;
  }

  dimension: keypad_code_id {
    type: number
    sql: ${TABLE}."KEYPAD_CODE_ID" ;;
  }

  dimension: keypad_id {
    type: number
    sql: ${TABLE}."KEYPAD_ID" ;;
  }

  dimension: start_date {
    type: date_time
    sql: ${TABLE}.CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [keypad_code_assignment_id]
  }
}
