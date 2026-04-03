view: job_profiles {
  sql_table_name: "GREENHOUSE"."JOB_PROFILES"
    ;;

  dimension: job_family {
    type: string
    sql: ${TABLE}."JOB_FAMILY" ;;
  }

  dimension: job_family_group {
    type: string
    sql: ${TABLE}."JOB_FAMILY_GROUP" ;;
  }

  dimension: job_profile {
    type: string
    sql: ${TABLE}."JOB_PROFILE" ;;
  }

  dimension: job_title {
    type: string
    sql: ${TABLE}."JOB_TITLE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
