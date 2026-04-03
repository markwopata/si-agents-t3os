view: dim_expense_line {
  sql_table_name: "ANALYTICS"."CORPORATE_BUDGET"."DIM_EXPENSE_LINE"
    ;;

  dimension: expense_line_id {
    type: number
    sql: ${TABLE}."EXPENSE_LINE_ID" ;;
  }

  dimension: expense_line_name {
    suggest_persist_for: "0 minutes"
    type: string
    sql: ${TABLE}."EXPENSE_LINE_NAME" ;;
  }

  dimension_group: expense_line_updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."EXPENSE_LINE_UPDATED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: expense_line_year {
    type: number
    sql: ${TABLE}."EXPENSE_LINE_YEAR" ;;
  }

  dimension: gl_mapping {
    type: number
    label: "GL Mapping"
    value_format: "0"
    sql: ${TABLE}."GL_MAPPING" ;;
  }

  dimension: pk_expense_line {
    primary_key: yes
    type: number
    sql: ${TABLE}."PK_EXPENSE_LINE" ;;
  }

  dimension: expense_category {
    type: string
    sql: ${TABLE}."EXPENSE_CATEGORY" ;;
  }

  dimension: expense_line_account_type {
    type: string
    sql: ${TABLE}."EXPENSE_LINE_ACCOUNT_TYPE" ;;
  }

  measure: count {
    type: count
    drill_fields: [expense_line_name]
  }
}
