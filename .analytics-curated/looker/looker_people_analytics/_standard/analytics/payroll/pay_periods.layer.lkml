include: "/_base/analytics/payroll/pay_periods.view.lkml"

view: +pay_periods {
  label: "Payroll Pay Periods"


  dimension: comm_check_date {
    description: "Indicator for commission pay periods."
  }
  dimension_group: pay_date_from {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${pay_date_from} ;;
    description: "Starting date for bi-weekly pay period."
  }
  dimension_group: pay_date_to {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${pay_date_to} ;;
    description: "Last date for bi-weekly pay period."
  }
  # dimension: pay_id {
  #   type: number
  #   sql: ${TABLE}."PAY_ID" ;;
  # }
  dimension_group: paycheck {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${paycheck} ;;
    description: "Payroll pay date for bi-weekly pay period."
  }
  measure: count {
    type: count
  }
}
