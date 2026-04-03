view: keypad_controller_types {
  sql_table_name: "TRACKERS"."KEYPAD_CONTROLLER_TYPES"
    ;;
  drill_fields: [keypad_controller_type_id]

  dimension: keypad_controller_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."KEYPAD_CONTROLLER_TYPE_ID" ;;
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

  dimension: board_type {
    type: number
    sql: ${TABLE}."BOARD_TYPE" ;;
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

  dimension: keypad_controller_type_canonical_id {
    type: string
    sql: ${TABLE}."KEYPAD_CONTROLLER_TYPE_CANONICAL_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [keypad_controller_type_id, name]
  }
}
