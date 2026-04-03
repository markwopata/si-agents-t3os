include: "/_base/people_analytics/looker/gl_payroll_detail.view.lkml"

view: +gl_payroll_detail{




  dimension_group: entry_date{
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${entry_date};;

  }


}
