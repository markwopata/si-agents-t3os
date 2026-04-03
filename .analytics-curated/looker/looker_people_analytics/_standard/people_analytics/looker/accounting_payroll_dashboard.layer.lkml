include: "/_base/people_analytics/looker/accounting_payroll_dashboard.view.lkml"

view: +accounting_payroll_dashboard {

############### DIMENSIONS ###############
  dimension: intaact_code {
    value_format_name: id
  }
  dimension: gl_account_no {
    value_format_name: id
  }
  dimension: debit {
    value_format: "$#,##0.00"
  }
  dimension: credit {
    value_format: "$#,##0.00"
  }
  dimension: total {
    type: number
    value_format: "$#,##0.00"
    sql: ${credit} - ${debit} ;;
  }

  ############### DATES ###############
  dimension_group: pay_date {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${pay_date};;
  }
  dimension_group: pay_period_start {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${pay_period_start};;
  }
  dimension_group: pay_period_end {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${pay_period_end};;
  }

  ############### MEASURES ###############
  measure: sum_of_credit {
    type: sum
    sql: ${credit} ;;
    description: "Sum of the credit column."
    value_format: "$#,##0.00"
    drill_fields: [drill_fields_pay_category*]
  }

  measure: sum_of_debit {
    type: sum
    sql: ${debit} ;;
    description: "Sum of the debit column."
    value_format: "$#,##0.00"
    drill_fields: [drill_fields_pay_category*]
  }

  measure: sum_of_total_pay_category_drills {
    type: sum
    sql: ${total} ;;
    description: "Sum of the total column with drill fields for the pay category visualization."
    value_format: "$#,##0.00"
    drill_fields: [drill_fields_pay_category*]
  }

  measure: sum_of_total_gl_code_drills {
    type: sum
    sql: ${total} ;;
    description: "Sum of the total column with drill fields for the GL Codes visualization."
    value_format: "$#,##0.00"
    drill_fields: [drill_fields_gl_codes*]
  }

  measure: pay_date_count_distinct {
    type: count_distinct
    sql: ${pay_date_date} ;;
    description: "Distinct Pay Dates given a certain time period."
  }

  measure: percent_of_total {
    type: number
    sql: SUM((${credit}-${debit}))/NULLIF(SUM(SUM(${credit}-${debit})) OVER (), 0) ;;
    value_format_name: percent_1
  }

  ############### SETS ###############
  set: drill_fields_pay_category {
    fields: [division,
      region,
      district,
      payroll_location,
      pay_category,
      pay_date_count_distinct,
      sum_of_credit,
      sum_of_debit,
      sum_of_total_pay_category_drills]
  }

  set: drill_fields_gl_codes {
    fields: [pay_category,
      sum_of_credit,
      sum_of_debit,
      sum_of_total_gl_code_drills,
      percent_of_total]
  }

}
