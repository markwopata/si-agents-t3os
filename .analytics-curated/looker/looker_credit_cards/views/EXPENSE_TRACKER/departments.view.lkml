view: departments {
  sql_table_name: "SWORKS"."EXPENSE_TRACKER"."DEPARTMENTS" ;;

  dimension: department_id  {
    type: number
    primary_key: yes
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }

  dimension: name {
    label: "Department"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

}
