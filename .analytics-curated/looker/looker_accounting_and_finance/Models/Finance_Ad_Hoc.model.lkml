connection: "es_snowflake_analytics"

include: "/views/custom_sql/asset_locations_by_lender.view.lkml"
include: "/views/custom_sql/asset_locations_by_lender_v2.view.lkml"
include: "/views/custom_sql/payment_forecast.view.lkml"
include: "/views/custom_sql/payment_forecast_new.view.lkml"
include: "/views/financial_lenders.view.lkml"
include: "/views/ANALYTICS/lender_to_company_id.view.lkml"
include: "/views/custom_sql/IES_amort_asset_level.view.lkml"
include: "/views/custom_sql/IES_amort_dealer_level.view.lkml"
include: "/views/custom_sql/IES_amort_companywide_level.view.lkml"
include: "/views/custom_sql/asset_market_tmstp.view.lkml"
# include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard


explore: asset_locations_by_lender {case_sensitive: no}
explore: asset_locations_by_lender_v2 {case_sensitive: no}
explore: payment_forecast {case_sensitive: no}
explore: payment_forecast_new {case_sensitive: no}
explore: financial_lenders {
  case_sensitive: no

  join: lender_to_company_id {
    type: left_outer
    relationship: one_to_one
    sql_on: ${financial_lenders.financial_lender_id} = ${lender_to_company_id.financial_lender_id} ;;

}
}
explore: ies_amort_asset_level {case_sensitive: no}
explore: ies_amort_dealer_level {case_sensitive: no}
explore: ies_amort_companywide_level {case_sensitive: no}
explore: asset_market_tmstp {case_sensitive: no}
