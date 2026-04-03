view: greenhouse_eeid_matches {
  sql_table_name: "GREENHOUSE"."GREENHOUSE_EEID_MATCHES"
    ;;

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }

}
