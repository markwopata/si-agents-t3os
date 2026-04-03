include: "/_base/people_analytics/looker/gl_report.view.lkml"

view: +gl_report {
  label: "GL Report"

  dimension: gl_primary_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."JOURNAL_ID" ;;
    # hidden: yes
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: CAST(${_es_update_timestamp} AS TIMESTAMP_NTZ) ;;
    # sql: ${_es_update_timestamp} ;;
  }
  # dimension: corrected_cost_center {
  #   type: string
  #   sql: ${TABLE}."CORRECTED_COST_CENTER" ;;
  # }

  # dimension: cost_centers_full_path {
  #   type: string
  #   sql: ${TABLE}."COST_CENTERS_FULL_PATH" ;;
  # }

  dimension: credit {
    type: number
    # sql: try_to_number(${credit}) ;;
    value_format_name: usd_0
  }

  dimension: debit {
    type: number
    # sql: try_to_number(${debit}) ;;
    value_format_name: usd_0
  }

  # dimension: default_cost_center_full_path {
  #   type: string
  #   sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  # }

  # dimension: division {
  #   type: string
  #   sql: ${TABLE}."DIVISION" ;;
  # }

  dimension: employee_id {
    type: number
    value_format_name: id
  }

  dimension: gl_account_no {
    type: number
    value_format_name: id
  }

  # dimension: gl_account_no_description {
  #   type: string
  #   sql: ${TABLE}."GL_ACCOUNT_NO_DESCRIPTION" ;;
  # }

  # dimension: hours {
  #   type: number
  #   sql: ${TABLE}."HOURS" ;;
  # }

  # dimension: intaact_code {
  #   type: number
  # }

  # dimension: job_title {
  #   type: string
  #   sql: ${TABLE}."JOB_TITLE" ;;
  # }

  # dimension: labor_distribution_profile {
  #  type: string
  #  sql: ${TABLE}."LABOR_DISTRIBUTION_PROFILE" ;;
  # }

  # dimension: location {
  #   type: string
  #   sql: ${TABLE}."LOCATION" ;;
  # }

  dimension_group: pay_date {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: CAST(${pay_date} AS TIMESTAMP_NTZ) ;;
    # sql: ${pay_date} ;;
  }

  dimension_group: pay_period_end {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: CAST(${pay_period_end} AS TIMESTAMP_NTZ);;
    # sql: ${pay_period_end} ;;
  }

  dimension_group: pay_period_start {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: CAST(${pay_period_start} AS TIMESTAMP_NTZ) ;;
    # sql: ${pay_period_start} ;;
  }

  # dimension: payroll_name {
  #   type: string
  #   sql: ${TABLE}."PAYROLL_NAME" ;;
  # }

  # dimension: payroll_status {
  #   type: string
  #   sql: ${TABLE}."PAYROLL_STATUS" ;;
  # }

  measure: total_amount {
    label: "Amount"
    type: sum
    value_format: "$#,##0.00;(#,##0.00);-"
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
