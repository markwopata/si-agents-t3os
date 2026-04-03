view: locations_by_job_view {
  sql_table_name: "GREENHOUSE"."LOCATIONS_BY_JOB_VIEW"
    ;;

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension: job_status {
    type: string
    sql: ${TABLE}."JOB_STATUS" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: office_id {
    type: number
    sql: ${TABLE}."OFFICE_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [job_name]
  }
}
