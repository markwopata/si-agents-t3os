view: time_entries {
  sql_table_name: "ES_WAREHOUSE"."TIME_TRACKING"."TIME_ENTRIES"
    ;;
  drill_fields: [time_entry_id]

  dimension: time_entry_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TIME_ENTRY_ID" ;;
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

  dimension: approval_status {
    type: string
    sql: ${TABLE}."APPROVAL_STATUS" ;;
  }

  dimension: archived {
    type: yesno
    sql: ${TABLE}."ARCHIVED" ;;
  }

  dimension_group: archived {
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
    sql: CAST(${TABLE}."ARCHIVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
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

  dimension: event_type_id {
    type: number
    sql: ${TABLE}."EVENT_TYPE_ID" ;;
  }

  dimension: is_revision {
    type: yesno
    sql: ${TABLE}."IS_REVISION" ;;
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: needs_revision {
    type: yesno
    sql: ${TABLE}."NEEDS_REVISION" ;;
  }

  dimension: note_id {
    type: number
    sql: ${TABLE}."NOTE_ID" ;;
  }

  dimension: overtime_hours {
    type: number
    sql: ${TABLE}."OVERTIME_HOURS" ;;
  }

  dimension: overtime_json {
    type: string
    sql: ${TABLE}."OVERTIME_JSON" ;;
  }

  dimension: overtime_state {
    type: string
    sql: ${TABLE}."OVERTIME_STATE" ;;
  }

  dimension: regular_hours {
    type: number
    sql: ${TABLE}."REGULAR_HOURS" ;;
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

  measure: max_start_date {
    type: date
    sql: max(${start_date}) ;;
  }

  measure: max_created_date {
    type: date
    sql: max(${created_time}) ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: total_minutes {
    type: number
    sql: (${regular_hours} + ${overtime_hours}) * 60 ;;
  }

  measure: sum_total_minutes {
    type: sum
    sql: (${regular_hours} + ${overtime_hours}) * 60  ;;
  }

  # converts regular hours to ##hrs ##mins format
  dimension: hours_minutes {
    type: string
    sql: CONCAT(FLOOR(${regular_hours} + ${overtime_hours}), ' hrs, ', FLOOR(((${regular_hours} + ${overtime_hours}) * 60) % 60), ' mins') ;;
  }

  measure: total_hours {
    type: sum
    sql: ${regular_hours} + ${overtime_hours} ;;
  }
  measure: total_approved_hours {
    type: sum
    sql: ${regular_hours} + ${overtime_hours} ;;
    filters: [approval_status: "Approved"]
  }
  measure: total_unapproved_hours {
    type: sum
    sql: ${regular_hours} + ${overtime_hours} ;;
    filters: [approval_status: "Unapproved"]
  }

  measure: total_time_formatted {
    type: string
    label: "Total Time"
    sql:  FLOOR(${total_hours}) || ' hrs ' || FLOOR(${total_hours} * 60) % 60 || ' mins';;
  }

  # Defined by Shayne. https://app.shortcut.com/businessanalytics/story/107149/add-estimated-dollar-amount-to-total-of-all-closed-customer-damages-not-billed
  measure: estimated_labor {
    value_format_name: usd_0
    type: sum
    filters: [event_type_id: "1"] # Only on-duty time
    sql: (${regular_hours} + ${overtime_hours}) * 175 ;;
  }

  measure: count {
    type: count
    drill_fields: [time_entry_id]
  }

  measure: technician {
    hidden: yes
    sql: 1=1 ;;
    drill_fields: [users.full_name,total_hours]
  }
}

view: time_entries_agg {
  derived_table: {
    sql:
      SELECT work_order_id,
            archived,
            event_type_id,
            round(SUM(regular_hours + overtime_hours),2) AS total_hours
      FROM ${time_entries.SQL_TABLE_NAME} as time_entries
      WHERE archived = 0 AND event_type_id = 1
      GROUP BY work_order_id, archived, event_type_id ;;
  }

  dimension: work_order_id {
    type: string sql: ${TABLE}.work_order_id ;;
    primary_key: yes }

  dimension: archived {
    type: yesno
    sql: ${TABLE}."ARCHIVED" ;;
  }

  dimension: event_type_id {
    type: number
    sql: ${TABLE}."EVENT_TYPE_ID" ;;
  }

  dimension: total_hours {
    type: number
    sql: ${TABLE}."TOTAL_HOURS" ;;
  }

  measure: labor_hours {
    type: sum
    sql: ${TABLE}.total_hours ;; }

  measure: labor_value_100 {
    type: number
    value_format_name: usd
    sql: ${labor_hours} * 100 ;;
  }

}
