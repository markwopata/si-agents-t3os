view: keypad_code_assignment_statuses {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."KEYPAD_CODE_ASSIGNMENT_STATUSES"
    ;;
  drill_fields: [keypad_code_assignment_status_id]

  dimension: keypad_code_assignment_status_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."KEYPAD_CODE_ASSIGNMENT_STATUS_ID" ;;
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
    sql: ${TABLE}.CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
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
    sql: ${TABLE}.CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [keypad_code_assignment_status_id, name]
  }
}
