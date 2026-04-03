view: job_name_job_family_xwalk {
  sql_table_name: "GREENHOUSE"."JOB_NAME_JOB_FAMILY_XWALK"
    ;;

  dimension: job_family {
    type: string
    sql: ${TABLE}."JOB_FAMILY" ;;
  }

  dimension: job_family_group {
    type: string
    sql: ${TABLE}."JOB_FAMILY_GROUP" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension: job_profile {
    type: string
    sql: ${TABLE}."JOB_PROFILE" ;;
  }

  measure: count {
    type: count
    drill_fields: [job_name]
  }
}
