view: time_tracking_entries {
  sql_table_name: "TIME_TRACKING"."TIME_TRACKING_ENTRIES"
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

  dimension: created_by_id {
    type: number
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }

  dimension_group: created {
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
    sql: CAST(${TABLE}."CREATED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: duration {
    type: number
    sql: ${TABLE}."DURATION" ;;
  }

  dimension_group: end {
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
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: end_event_id {
    type: number
    sql: ${TABLE}."END_EVENT_ID" ;;
  }

  dimension: entry_id {
    type: string
    sql: ${TABLE}."ENTRY_ID" ;;
  }

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
  }

  dimension: event_type_id {
    type: number
    sql: ${TABLE}."EVENT_TYPE_ID" ;;
  }

  dimension: is_revised {
    type: yesno
    sql: ${TABLE}."IS_REVISED" ;;
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: overtime_duration {
    type: number
    sql: ${TABLE}."OVERTIME_DURATION" ;;
  }

  dimension: revised_by_id {
    type: number
    sql: ${TABLE}."REVISED_BY_ID" ;;
  }

  dimension_group: revised {
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
    sql: CAST(${TABLE}."REVISED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: source_application_id {
    type: number
    sql: ${TABLE}."SOURCE_APPLICATION_ID" ;;
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
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: start_event_id {
    type: number
    sql: ${TABLE}."START_EVENT_ID" ;;
  }

  dimension: system_generated {
    type: yesno
    sql: ${TABLE}."SYSTEM_GENERATED" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: work_cords {
    type: string
    sql: ${TABLE}."WORK_CORDS" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  measure: total_duration {
    type: sum
    sql: ${duration} ;;
  }

  measure: total_overtime_duration {
    type: sum
    sql: ${overtime_duration} ;;
  }

  measure: format_total_duration {
    type: number
    sql: ${total_duration}/ 86400.0 ;;
    value_format: "[hh]:mm:ss"
    drill_fields: [time_tracking_detail*]
  }

  measure: hour_format_total_duration {
    type: number
    sql: ${total_duration}/ 86400.0 ;;
    value_format: "[h]"
    drill_fields: [time_tracking_detail*]
  }

  measure: hour_format_total_overtime_duration {
    type: number
    sql: ${total_overtime_duration}/ 86400.0 ;;
    value_format: "[h]"
    drill_fields: [time_tracking_detail*]
  }

  dimension_group: total_time_cards {
    type: duration
    sql_start: ${start_raw} ;;
    sql_end: ${end_raw} ;;
    intervals: [day, hour, minute]
  }

  set: time_tracking_detail {
    fields: [start_time,
      end_time,
      duration,
      overtime_duration,
      work_order_id]
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
