include: "/_base/people_analytics/looker/payroll_details.view.lkml"

view: +payroll_details {
  label: "Payroll Detail"

  dimension: pd_primary_key {
    primary_key: yes
    type: string
    sql:CONCAT(${employee_id},${intaact},${_cost_centers_full_path},${_cost_centers_name_department},
    ${_cost_centers_name_division},${_es_update_timestamp},${cost_centersdivision},
    ${gl_account_no_description},${pay_period_end},${pay_period_start},${default_cost_centers_full_path},
    ${gl_account_no},${jobs_hr1}, ${payroll_name},${payroll_status},${payroll_system_id},${debit}) ;;
  }

  # dimension: _cost_centers_full_path {
  #   type: string
  #   sql: ${TABLE}."_COST_CENTERS_FULL_PATH" ;;
  # }
  # dimension: _cost_centers_name_department {
  #   type: string
  #   sql: ${TABLE}."_COST_CENTERS_NAME_(DEPARTMENT)" ;;
  # }
  # dimension: _cost_centers_name_division {
  #   type: string
  #   sql: ${TABLE}."_COST_CENTERS_NAME_(DIVISION)" ;;
  # }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  # dimension: cost_centersdivision {
  #   type: string
  #   sql: ${TABLE}."COST_CENTERS(DIVISION)" ;;
  # }
  # dimension: credit {
  #   type: number
  #   sql: ${TABLE}."CREDIT" ;;
  # }
  # dimension: debit {
  #   type: number
  #   sql: ${TABLE}."DEBIT" ;;
  # }
  # dimension: default_cost_centers_full_path {
  #   type: string
  #   sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  # }
  # dimension: default_cost_centers_intaact {
  #   type: number
  #   sql: ${TABLE}."DEFAULT_COST_CENTERS_INTAACT" ;;
  # }
  # dimension: description {
  #   type: string
  #   sql: ${TABLE}."DESCRIPTION" ;;
  # }
  # dimension: employee_id {
  #   value_format_name: id
  # }
  # dimension: entry_type {
  #   type: string
  #   sql: ${TABLE}."ENTRY_TYPE" ;;
  # }
  # dimension: first_name {
  #   type: string
  #   sql: ${TABLE}."FIRST_NAME" ;;
  # }

  dimension: Employee_name {
    type: string
    sql: CONCAT(${first_name},' ', ${last_name}) ;;
  }

  # dimension: gl_account_no {
  #   type: string
  #   sql: ${TABLE}."GL_ACCOUNT_NO" ;;
  # }
  # dimension: gl_account_no_description {
  #   type: string
  #   sql: ${TABLE}."GL_ACCOUNT_NO_DESCRIPTION" ;;
  # }
  # dimension: hours {
  #   type: number
  #   sql: ${TABLE}."HOURS" ;;
  # }
  # dimension: intaact {
  #   type: string
  #   sql: ${TABLE}."INTAACT" ;;
  # }
  dimension: jobs_hr1 {
    type: string
    label: "Employee Title"
    sql: ${TABLE}."JOBS_(HR)(1)" ;;
  }
  # dimension: labor_distribution_profile {
  #   type: string
  #   sql: ${TABLE}."LABOR_DISTRIBUTION_PROFILE" ;;
  # }
  # dimension: last_name {
  #   type: string
  #   sql: ${TABLE}."LAST_NAME" ;;
  # }
  dimension_group: pay_day {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: CAST(${pay_day} AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: pay_period_end {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${pay_period_end} ;;
  }
  dimension_group: pay_period_start {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${pay_period_start};;
  }
  # dimension: payroll_name {
  #   type: string
  #   sql: ${TABLE}."PAYROLL_NAME" ;;
  # }
  # dimension: payroll_status {
  #   type: string
  #   sql: ${TABLE}."PAYROLL_STATUS" ;;
  # }
  # dimension: payroll_system_id {
  #   type: number
  #   sql: ${TABLE}."PAYROLL_SYSTEM_ID" ;;
  # }
  # measure: count {
  #   type: count
  #   drill_fields: [first_name, last_name, payroll_name]
  # }

  measure: avg_compensation {
    type: average
    sql: ${debit} ;;
    value_format_name: usd_0
  }

  measure: cumulative_total_payroll {
    type: running_total
    sql: ${total_debit} ;;
    value_format_name: usd
  }

  measure: employee_distinct_count {
    type: count_distinct
    sql: ${employee_id} ;;
    drill_fields: [first_name, last_name, employee_id, jobs_hr1, total_debit, total_hours]
  }

  measure: hourly_rate {
    type: number
    sql: ${total_debit} / ${total_hours} ;;
    value_format_name: usd
  }

  measure: total_hours {
    type: sum
    sql: ${hours} ;;
    value_format_name: decimal_2
    drill_fields: [description, gl_account_no_description, gl_account_no, first_name, last_name, employee_id, company_directory.employee_status]
  }

  measure: total_debit {
    type: sum
    sql: ${debit} ;;
    value_format_name: usd
    # html: {{ rendered_value }} | {{total_debit._rendered_value }} ;;
    drill_fields: [first_name, last_name, employee_id, description, gl_account_no_description, gl_account_no, total_debit, company_directory.employee_status]
  }

  measure: total_credit {
    type: sum
    sql: ${credit} ;;
    value_format_name: usd_0
    drill_fields: [first_name, last_name, employee_id, total_debit, total_hours]
  }

  measure: total_debit_increase {
    type: percent_of_previous
    sql: ${total_debit};;
    # value_format_name: percent_2
    html: Increase Rate : {{rendered_value}} || {{total_debit._rendered_value }} || {{cumulative_total_payroll._rendered_value }};;
  }
}
