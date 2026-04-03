view: public_keypads {
  sql_table_name: "PUBLIC"."KEYPADS"
    ;;
  drill_fields: [keypad_id]

  dimension: keypad_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."KEYPAD_ID" ;;
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

  dimension: asset_id {
    type: number
    # hidden: yes
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: keypads_count {
    type: count_distinct
    sql: ${keypad_id} ;;
    drill_fields: [keypad_id]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      keypad_id,
      assets.asset_id,
      assets.custom_name,
      assets.name,
      assets.driver_name,
      trackers_keypads.count
    ]
  }
}
