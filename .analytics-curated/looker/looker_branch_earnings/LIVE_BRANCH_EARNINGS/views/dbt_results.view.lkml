view: dbt_results {

  sql_table_name: "DBT_RESULTS"."DBT_RESULTS" ;;

  dimension: compiled_path {
    type: string
    sql: ${TABLE}."COMPILED_PATH" ;;
  }
  dimension: database_name {
    type: string
    sql: ${TABLE}."DATABASE_NAME" ;;
  }
  dimension: execution_time_in_minutes {
    type: number
    sql: ${TABLE}."EXECUTION_TIME" / 60 ;;
  }
  dimension: failures {
    type: string
    sql: ${TABLE}."FAILURES" ;;
  }
  dimension: invocation_id {
    type: string
    sql: ${TABLE}."INVOCATION_ID" ;;
  }
  dimension: message {
    type: string
    sql: ${TABLE}."MESSAGE" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME"
  ;;
  }
  dimension: path {
    type: string
    sql: ${TABLE}."PATH" ;;
  }
  dimension: resource_type {
    type: string
    sql: ${TABLE}."RESOURCE_TYPE" ;;
  }
  dimension: result_id {
    type: string
    sql: ${TABLE}."RESULT_ID" ;;
  }
  dimension: rows_affected {
    type: number
    sql: ${TABLE}."ROWS_AFFECTED" ;;
  }
  dimension: schema_name {
    type: string
    sql: ${TABLE}."SCHEMA_NAME" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension_group: run_time {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.time_of_run ;;
  }
  dimension: unique_id {
    type: string
    sql: ${TABLE}."UNIQUE_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [database_name, name, schema_name]
  }
}
