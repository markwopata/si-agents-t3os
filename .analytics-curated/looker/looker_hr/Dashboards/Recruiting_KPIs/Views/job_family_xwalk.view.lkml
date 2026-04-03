view: job_family_xwalk {
  sql_table_name: "GREENHOUSE"."JOB_FAMILY_XWALK"
    ;;

  dimension: job_family {
    type: string
    sql: ${TABLE}."JOB_FAMILY" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [job_name]
  }
}
