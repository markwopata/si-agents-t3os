view: driver_log_summary {
  sql_table_name: "ELOGS"."DRIVER_LOG_SUMMARY"
    ;;

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

  dimension: co_driver {
    type: string
    sql: ${TABLE}."CO_DRIVER" ;;
  }

  dimension_group: date {
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
    sql: CAST(${TABLE}."DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: distance {
    type: number
    sql: ${TABLE}."DISTANCE" ;;
  }

  dimension: driver_id {
    type: number
    sql: ${TABLE}."DRIVER_ID" ;;
  }

  dimension: exemption_type_id {
    type: number
    sql: ${TABLE}."EXEMPTION_TYPE_ID" ;;
  }

  dimension: on_duty {
    type: number
    sql: ${TABLE}."ON_DUTY" ;;
  }

  dimension: shipping_docs {
    type: string
    sql: ${TABLE}."SHIPPING_DOCS" ;;
  }

  dimension: signed {
    type: yesno
    sql: ${TABLE}."SIGNED" ;;
  }

  dimension: signed_by {
    type: string
    sql: ${TABLE}."SIGNED_BY" ;;
  }

  dimension: signed_by_signature_reference {
    type: string
    sql: ${TABLE}."SIGNED_BY_SIGNATURE_REFERENCE" ;;
  }

  dimension_group: signed {
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
    sql: CAST(${TABLE}."SIGNED_ON" AS TIMESTAMP_NTZ) ;;
  }

  dimension: violation_break {
    type: yesno
    sql: ${TABLE}."VIOLATION_BREAK" ;;
  }

  dimension: violation_cycle {
    type: yesno
    sql: ${TABLE}."VIOLATION_CYCLE" ;;
  }

  dimension: violation_drive {
    type: yesno
    sql: ${TABLE}."VIOLATION_DRIVE" ;;
  }

  dimension: violation_shift {
    type: yesno
    sql: ${TABLE}."VIOLATION_SHIFT" ;;
  }

  measure: shift_violation_count {
    type: count
    filters: [violation_shift: "Yes"]
    drill_fields: [driver_detail*]
  }

  measure: break_violation_count {
    type: count
    filters: [violation_break: "Yes"]
    drill_fields: [driver_detail*]
  }

  measure: drive_violation_count {
    type: count
    filters: [violation_drive: "Yes"]
    drill_fields: [driver_detail*]
  }

  measure: unique_drivers {
    type: count_distinct
    sql: ${driver_id} ;;
    drill_fields: [driver_id]
  }

  set: driver_detail {
    fields: [
      driver_id,
      date_time
    ]
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
