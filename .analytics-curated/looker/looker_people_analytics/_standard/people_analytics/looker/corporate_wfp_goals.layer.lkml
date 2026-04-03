include: "/_base/people_analytics/looker/corporate_wfp_goals.view.lkml"

view: +corporate_wfp_goals {

############### DIMENSIONS ###############


  ############### DATES ###############


  ############### MEASURES ###############

  measure: goal_2025_end_headcount_sum {
    type: sum
    sql: ${goal_2025_end_headcount} ;;

  }

  measure: goal_2025_total_payroll_sum {
    type: sum
    sql: ${goal_2025_total_payroll} ;;

  }

 }
