view: gl_report {
  sql_table_name:"PEOPLE_ANALYTICS"."LOOKER"."GL_REPORT" ;;

  dimension: gl_primary_key {
    primary_key: yes
    type: string
    sql: CONCAT(${TABLE}."EMPLOYEE_ID",${TABLE}."INTAACT_CODE",   ${TABLE}."COST_CENTERS_FULL_PATH" , ${TABLE}."DIVISION" , ${TABLE}."LOCATION" ,  ${TABLE}."PAY_DATE"::date ,${TABLE}."GL_ACCOUNT_NO", ${TABLE}."GL_ACCOUNT_NO_DESCRIPTION", ${TABLE}."PAY_PERIOD_END",${TABLE}."PAY_PERIOD_START" ,${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH", ${TABLE}."CORRECTED_COST_CENTER", ${TABLE}."JOB_TITLE" , ${TABLE}."_ES_UPDATE_TIMESTAMP", ${TABLE}."PAYROLL_NAME" , ${TABLE}."PAYROLL_STATUS" ) ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: corrected_cost_center {
    type: string
    sql: ${TABLE}."CORRECTED_COST_CENTER" ;;
  }

  dimension: cost_centers_full_path {
    type: string
    sql: ${TABLE}."COST_CENTERS_FULL_PATH" ;;
  }

  dimension: credit {
    type: number
    sql: try_to_number(${TABLE}."CREDIT") ;;
    value_format_name: usd_0
  }

  dimension: debit {
    type: number
    sql: try_to_number(${TABLE}."DEBIT") ;;
    value_format_name: usd_0
  }

  dimension: default_cost_center_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }

  dimension: division {
    type: string
    sql: ${TABLE}."DIVISION" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format:"0"
  }

  dimension: gl_account_no {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NO" ;;
  }


  dimension: gl_account_no_description {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NO_DESCRIPTION" ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: intaact_code {
    type: string
    sql: ${TABLE}."INTAACT_CODE" ;;
  }

  dimension: job_title {
    type: string
    sql: ${TABLE}."JOB_TITLE" ;;
  }

 # dimension: labor_distribution_profile {
 #  type: string
 #  sql: ${TABLE}."LABOR_DISTRIBUTION_PROFILE" ;;
 # }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension_group: pay_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."PAY_DATE"::date ;;
  }

  dimension_group: pay_period_end {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."PAY_PERIOD_END"::date ;;
  }

  dimension_group: pay_period_start {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."PAY_PERIOD_START"::date ;;
  }

  dimension: payroll_name {
    type: string
    sql: ${TABLE}."PAYROLL_NAME" ;;
  }

  dimension: payroll_status {
    type: string
    sql: ${TABLE}."PAYROLL_STATUS" ;;
  }

  measure: total_amount {
    label: "Amount"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${credit} - ${debit} ;;
  }

  measure: count {
    type: count_distinct
    sql: ${employee_id} ;;
  }

  measure: credit_total {
    type: sum
    sql: ${credit} ;;
    value_format: "$#,###.00;($#,###.00)"
  }

  measure: debit_total {
    type:  sum
    sql: ${debit} * -1 ;;
    value_format: "$#,###.00;($#,###.00)"
  }

  measure: hours_worked{
    type: sum
    sql: ${hours} ;;
  }

  measure: avg_credit_per_employee {
    type:  average
    sql:  ${credit} ;;
    value_format_name: usd_0
  }

  measure: avg_debit_per_employee {
    type: average
    sql: ${debit} ;;
    value_format_name: usd_0
  }

  measure: credit_to_debit_ratio {
    type: number
    sql: ${credit} / NULLIF(${debit}, 0) ;;
    value_format_name: usd_0
  }

  measure: total_labor_costs {
    type: sum
    sql: ${credit} + ${debit} ;;
    value_format_name: usd_0
  }

  measure: avg_cost_per_employee {
    type: average
    sql: ${credit} + ${debit} ;;
    value_format_name: usd_0
  }

  measure: hourly_rate {
    type: average
    sql: (${credit} + ${debit}) / ${hours} ;;
    value_format_name: usd_0
  }
}
