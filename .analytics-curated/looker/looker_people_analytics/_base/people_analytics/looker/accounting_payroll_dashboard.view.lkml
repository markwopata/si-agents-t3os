view: accounting_payroll_dashboard {
  sql_table_name: "LOOKER"."ACCOUNTING_PAYROLL_DASHBOARD" ;;

  dimension: credit {
    type: number
    sql: ${TABLE}."CREDIT" ;;
  }
  dimension: debit {
    type: number
    sql: ${TABLE}."DEBIT" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: division {
    type: string
    sql: ${TABLE}."DIVISION" ;;
  }
  dimension: gl_account_no {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NO" ;;
  }
  dimension: intaact_code {
    type: string
    sql: ${TABLE}."INTAACT_CODE" ;;
  }
  dimension: pay_category {
    type: string
    sql: ${TABLE}."PAY_CATEGORY" ;;
  }
  dimension: pay_component_category {
    type: string
    sql: ${TABLE}."PAY_COMPONENT_CATEGORY" ;;
  }
  dimension: pay_date {
    type: date_raw
    sql: ${TABLE}."PAY_DATE" ;;
  }
  dimension: pay_period_end {
    type: date_raw
    sql: ${TABLE}."PAY_PERIOD_END" ;;
  }
  dimension: pay_period_start {
    type: date_raw
    sql: ${TABLE}."PAY_PERIOD_START" ;;
  }
  dimension: payroll_location {
    type: string
    sql: ${TABLE}."PAYROLL_LOCATION" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }
  measure: count {
    type: count
  }
}
