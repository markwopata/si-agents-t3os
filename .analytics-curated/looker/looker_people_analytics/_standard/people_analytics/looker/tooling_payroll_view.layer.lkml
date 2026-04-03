include: "/_base/people_analytics/looker/tooling_payroll_view.view.lkml"


view: +tooling_payroll_view {

############### DATES ###############
  dimension_group: pay_date {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${pay_date} ;;
  }
}
