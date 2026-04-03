include: "/_base/people_analytics/looker/gl_payroll_aggregate.view.lkml"

view: +gl_payroll_aggregate {




  dimension_group: period_start_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${period_start_date};;

  }


}
