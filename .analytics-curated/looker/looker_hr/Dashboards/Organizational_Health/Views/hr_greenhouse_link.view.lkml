view: hr_greenhouse_link {
  sql_table_name: "ANALYTICS"."PAYROLL"."EMPLOYEE_GREENHOUSE_LINK" ;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }

  dimension: candidate_id {
    type: number
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }

  dimension: greenhouse_link {
    type: string
    sql: ${TABLE}."GREENHOUSE_LINK" ;;
  }

  dimension: link_to_greenhouse_html {
    label: "Greenhouse Link"
    type: string
    html: <a href ="{{greenhouse_link._value}}"target="_blank"><img src="https://www.greenhouse.io/favicon.ico" width="16" height="16">Greenhouse</a></font></u> ;;
    sql: ${greenhouse_link} ;;
  }

  set: detail {
    fields: [employee_id, greenhouse_application_id, candidate_id, greenhouse_link]
  }
}
