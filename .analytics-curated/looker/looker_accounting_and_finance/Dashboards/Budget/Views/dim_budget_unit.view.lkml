view: dim_budget_unit {
  sql_table_name: "CORPORATE_BUDGET"."DIM_BUDGET_UNIT" ;;

  dimension: approved_budget {
    type: number
    sql: ${TABLE}."APPROVED_BUDGET" ;;
  }
  dimension: q_1_budget {
    type: number
    sql: ${TABLE}."Q_1_BUDGET" ;;
  }
  dimension: q_2_budget {
    type: number
    sql: ${TABLE}."Q_2_BUDGET" ;;
  }
  dimension: q_3_budget {
    type: number
    sql: ${TABLE}."Q_3_BUDGET" ;;
  }
  dimension: q_4_budget {
    type: number
    sql: ${TABLE}."Q_4_BUDGET" ;;
  }
  dimension: budget_year {
    type: number
    sql: ${TABLE}."BUDGET_YEAR" ;;
  }
  dimension: expense_line_id {
    type: string
    sql: ${TABLE}."EXPENSE_LINE_ID" ;;
  }
  dimension: pk_budget_unit {
    type: string
    sql: ${TABLE}."PK_BUDGET_UNIT" ;;
  }
  dimension: strategic_initiative {
    type: yesno
    label: "Strategic Initiative"
    sql: ${TABLE}."STRATEGIC_INITIATIVE" ;;
  }
  dimension: sub_department_id {
    type: number
    sql: ${TABLE}."SUB_DEPARTMENT_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [sub_department_id, expense_line_id, budget_year]
  }
}
