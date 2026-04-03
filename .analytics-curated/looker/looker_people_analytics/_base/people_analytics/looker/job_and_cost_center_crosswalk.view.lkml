view: job_and_cost_center_crosswalk {
  sql_table_name: "APPLICATION_ZAPIER"."JOBS" ;;

  dimension: business_title {
    type: string
    sql: ${TABLE}."BUSINESS_TITLE" ;;
  }
  dimension: cost_center {
    type: string
    sql: ${TABLE}."COST_CENTER" ;;
  }
  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }
  dimension: division {
    type: string
    sql: ${TABLE}."DIVISION" ;;
  }
  dimension: flsa_status {
    type: string
    sql: ${TABLE}."FLSA_STATUS" ;;
  }
  dimension: job_profile {
    type: string
    sql: ${TABLE}."JOB_PROFILE" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  measure: count {
    type: count
  }
}
