view: pa_employee_access {
  sql_table_name: "ANALYTICS"."PAYROLL"."PA_EMPLOYEE_ACCESS" ;;



  dimension: employee_email {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: manager_access_emails {
    type: string
    sql: ${TABLE}."MANAGER_ACCESS_EMAILS" ;;
  }
}
