view: tooling_payroll_view {
  sql_table_name: "LOOKER"."TOOLING_PAYROLL_VIEW" ;;

  dimension: business_title {
    type: string
    sql: ${TABLE}."BUSINESS_TITLE" ;;
  }
  dimension: charged_market {
    type: string
    sql: ${TABLE}."CHARGED_MARKET" ;;
  }
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
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: full_cost_center_charged {
    type: string
    sql: ${TABLE}."FULL_COST_CENTER_CHARGED" ;;
  }
  dimension: gl_account_no {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NO" ;;
  }
  dimension: gl_account_no_description {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NO_DESCRIPTION" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension: pay_date {
    type: date_raw
    sql: ${TABLE}."PAY_DATE" ;;
    hidden: yes
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }
  measure: count {
    type: count
    drill_fields: [last_name, first_name]
  }
}
