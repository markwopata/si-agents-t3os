include: "/_base/people_analytics/looker/rolling_turnover_12_months_by_market.view.lkml"




view: +rolling_turnover_12_months_by_market{

  ############### MEASURES ###############
  measure: turnover_rate {
    type: number
    sql: ${terminations_12_mo}/${avg_headcount_12_mo} ;;
    description: "Rolling 12 month turnover."
    value_format: "0.00\%"
  }

}
