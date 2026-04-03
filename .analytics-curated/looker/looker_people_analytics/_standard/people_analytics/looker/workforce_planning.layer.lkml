include: "/_base/people_analytics/looker/workforce_planning.view.lkml"


view: +workforce_planning {

  ############### DIMENSIONS ###############
  dimension: average_salary {
    value_format: "$#,##0.00"
    skip_drill_filter: yes
  }

  dimension: compensation_through_prev_month {
    value_format: "$#,##0.00"
    skip_drill_filter: yes
  }

  dimension: months_left {
    skip_drill_filter: yes
  }
}
