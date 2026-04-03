view: hiring_team_by_job_view {
  sql_table_name: "GREENHOUSE"."HIRING_TEAM_BY_JOB_VIEW"
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

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: role {
    type: string
    sql: ${TABLE}."ROLE" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [job_name, name]
  }
}
