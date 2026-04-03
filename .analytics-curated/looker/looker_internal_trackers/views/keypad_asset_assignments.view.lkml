view: keypad_asset_assignments {
  sql_table_name: "PUBLIC"."KEYPAD_ASSET_ASSIGNMENTS"
    ;;
  drill_fields: [keypad_asset_assignment_id]

  dimension: keypad_asset_assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."KEYPAD_ASSET_ASSIGNMENT_ID" ;;
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

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
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

  dimension: end_date {
    type: date_time
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: keypad_id {
    type: number
    sql: ${TABLE}."KEYPAD_ID" ;;
  }

  dimension_group: start {
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
    sql: ${TABLE}.CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [keypad_asset_assignment_id]
  }
}
