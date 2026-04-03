view: stage_matters {
  sql_table_name: "CLIO_GOLD"."MATTERS" ;;
  drill_fields: [matter_id]

  dimension: matter_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."MATTER_ID" ;;
  }
  dimension: case_link {
    type: string
    sql: ${TABLE}."CASE_LINK" ;;
  }
  dimension: court_value {
    type: string
    sql: ${TABLE}."COURT_VALUE" ;;
  }
  dimension: custom_number {
    type: string
    sql: ${TABLE}."CUSTOM_NUMBER" ;;
  }
  dimension: customer_number {
    type: string
    sql: ${TABLE}."CUSTOMER_NUMBER" ;;
  }
  dimension: display_number {
    type: string
    sql: ${TABLE}."DISPLAY_NUMBER" ;;
  }
  dimension_group: extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."EXTRACTED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: judge_value {
    type: string
    sql: ${TABLE}."JUDGE_VALUE" ;;
  }
  dimension: jurisdiction {
    type: string
    sql: ${TABLE}."JURISDICTION" ;;
  }
  dimension_group: last_activity {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LAST_ACTIVITY_DATE" ;;
  }
  dimension_group: matter_close {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MATTER_CLOSE_DATE" ;;
  }
  dimension_group: matter_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."MATTER_CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: matter_open {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MATTER_OPEN_DATE" ;;
  }
  dimension_group: matter_pending {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MATTER_PENDING_DATE" ;;
  }
  dimension: matter_stage_name {
    type: string
    sql: ${TABLE}."MATTER_STAGE_NAME" ;;
  }
  dimension_group: matter_stage_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."MATTER_STAGE_UPDATED_AT" ;;
  }
  dimension: matter_status_value {
    type: string
    sql: ${TABLE}."MATTER_STATUS_VALUE" ;;
  }
  dimension: pg_on_file {
    type: string
    sql: ${TABLE}."PG_ON_FILE" ;;
  }
  dimension: practice_area_name {
    type: string
    sql: ${TABLE}."PRACTICE_AREA_NAME" ;;
  }
  dimension: sps_value {
    type: string
    sql: ${TABLE}."SPS_VALUE" ;;
  }
  measure: count {
    type: count
    drill_fields: [matter_id, matter_stage_name, practice_area_name]
  }
}
