view: disc_gh_ukg {
  sql_table_name: "PUBLIC"."DISC_GH_UKG"
    ;;

  dimension: disc_code {
    type: string
    sql: ${TABLE}."DISC_CODE" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}."EXTERNAL_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  dimension: was_hired {
    type: yesno
    sql: ${TABLE}."EMPLOYEE_ID" is not null;;
  }
}
