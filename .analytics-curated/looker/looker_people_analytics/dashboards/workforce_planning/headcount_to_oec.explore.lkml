include: "/_standard/custom_sql/market_oec.view.lkml"
include: "/_standard/analytics/payroll/company_directory.layer.lkml"
include: "/_standard/analytics/public/market_region_xwalk.layer.lkml"
include: "/_standard/analytics/gs/revmodel_market_rollout_conservative.layer.lkml"

view: +market_oec {

  measure: OEC_per_headcount{
    type: number
    sql:   ${headcount_to_oec.oec_measure}/${company_directory.employee_count};;
    value_format: "0.00,,\" M\""
    link: {
      label: "OEC:Headcount Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/1507?Market%20Name=&Employee%20Title=&Region%20Name=&District=&Market%20Type=&"
    }
  }
}

explore: headcount_to_oec {
  from: market_oec
  group_label: "Workforce Planning"
  label: "Current Headcount with Market OEC"
  case_sensitive: no

  join: company_directory {
    relationship: many_to_many
    type: left_outer
    sql_on: ${headcount_to_oec.market_id}::text=${company_directory.market_id}::text;;
  }

  join: market_region_xwalk {
    relationship: one_to_many
    type: left_outer
    sql_on: ${headcount_to_oec.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: revmodel_market_rollout_conservative {
    relationship: one_to_many
    type: left_outer
    sql_on: ${market_region_xwalk.market_id}::text = ${revmodel_market_rollout_conservative.market_id}::text;;
  }


}
