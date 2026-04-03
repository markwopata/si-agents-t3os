view: gl_payroll_aggregate {
  sql_table_name: "LOOKER"."GL_PAYROLL_AGGREGATE" ;;

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }
  dimension: account_normal_balance {
    type: string
    sql: ${TABLE}."ACCOUNT_NORMAL_BALANCE" ;;
  }
  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }
  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: period_start_date {
    type: date_raw
    sql: ${TABLE}."PERIOD_START_DATE" ;;
    hidden: yes
  }
  measure: count {
    type: count
    drill_fields: [account_name]
  }
}
