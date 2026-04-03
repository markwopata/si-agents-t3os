#
# The purpose of this view is tie financial lender id to company id. View requires join
# to telematics_service_providers_assets.view.lkml.
# This is for T3 validation. (https://app.shortcut.com/businessanalytics/story/143565)
#
# Britt Shanklin | Built 2022-08-12

view: lender_to_company_id {
  sql_table_name: "ANALYTICS"."DEBT"."LENDER_TO_COMPANY_ID" ;;

  dimension: financial_lender_id {
    type: number
    sql: ${TABLE}."FINANCIAL_LENDER_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: lender_matches_T3 {
    type: yesno
    sql: ${company_id} = ${telematics_service_providers_assets.company_id} ;;
  }

}
