view: sub_departments {
  sql_table_name: "SWORKS"."EXPENSE_TRACKER"."SUB_DEPARTMENTS" ;;

  dimension: sub_departments_id  {
    type: number
    primary_key: yes
    sql: ${TABLE}."SUB_DEPARTMENT_ID" ;;
  }

  dimension: department_id {
    type: number
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }

  dimension: name {
    label: "Sub Department"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

}
