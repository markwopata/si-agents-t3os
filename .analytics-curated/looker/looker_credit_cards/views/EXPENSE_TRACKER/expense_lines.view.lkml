view: expense_lines {
  sql_table_name: "SWORKS"."EXPENSE_TRACKER"."EXPENSE_LINES" ;;

  dimension: expense_line_id  {
    type: number
    primary_key: yes
    sql: ${TABLE}."EXPENSE_LINE_ID" ;;
  }

  dimension: name {
    label: "Expense Line"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }
}
