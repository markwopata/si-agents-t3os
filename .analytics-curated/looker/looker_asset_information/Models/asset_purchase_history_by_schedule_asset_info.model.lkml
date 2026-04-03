connection: "es_snowflake_analytics"

include: "/views/ES_WAREHOUSE/asset_purchase_history.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/financial_schedules.view.lkml"
include: "/views/ES_WAREHOUSE/financial_lenders.view.lkml"
include: "/views/ANALYTICS/net_terms_finance_status.view.lkml"
include: "/views/ANALYTICS/phoenix_id_types.view.lkml"
include: "/views/custom_sql/guidance_lines_of_credit.view.lkml"
include: "/views/custom_sql/aph_vendor.view.lkml"
include: "/views/custom_sql/aph_log.view.lkml"
include: "/views/ANALYTICS/greensill_assets_paid_off.view.lkml"
include: "/views/ANALYTICS/all_greensill.view.lkml"
include: "/views/custom_sql/ez_ar.view.lkml"
include: "/views/ANALYTICS/net_terms_finance_status_vendor.view.lkml"
include: "/views/custom_sql/abl_category.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"

# datagroup: 6AM_update {
#   sql_trigger: SELECT FLOOR((EXTRACT(epoch from CURRENT_TIMESTAMP()) - 60*60*12)/(60*60*24)) ;;
#   max_cache_age: "24 hours"
# }

# datagroup: Every_Hour_Update {
#   sql_trigger: SELECT DATE_PART('hour', CURRENT_TIMESTAMP()) ;;
#   max_cache_age: "1 hour"
# }

# datagroup: Every_5_Min_Update {
#   sql_trigger: SELECT DATE_PART('minute', CURRENT_TIMESTAMP()) ;;
#   max_cache_age: "5 minutes"}


explore: asset_purchase_history {
  case_sensitive: no
  # persist_for: "1 minute"
  sql_always_where:
     coalesce(${invoice_purchase_date}::date,${assets.created_date}::date) >= '1/1/2019' and  (${financial_schedule_id} in (1391,1572,1355,1359,1358,2399,1719,1722,1620,1619,1617,1613,1721,1718,1712,1621,1618,1720)
    OR ${financial_schedule_id} is null
    or ${all_greensill.greensill_asset} = 'Y') or ${all_greensill.purchase_created_date::date} >= '1/1/2019' or ${ez_ar.is_ez} = 'Y' ;;


  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id}=${asset_purchase_history.asset_id} ;;
  }


  join: aph_vendor {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id}=${aph_vendor.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${assets.rental_branch_id},${assets.inventory_branch_id})=${markets.market_id} and ${assets.company_id}=${markets.company_id} ;;
  }

  join: financial_schedules {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_purchase_history.financial_schedule_id}=${financial_schedules.financial_schedule_id}  ;;
  }

  join: financial_lenders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${financial_schedules.originating_lender_id}=${financial_lenders.financial_lender_id}  ;;
  }

  #join: net_terms_finance_status {
  #  type: left_outer
   # relationship: many_to_one
  #  sql_on: ${net_terms_finance_status.make}=${assets.make}  ;;
  #}

  join: net_terms_finance_status_vendor {
    type: left_outer
    relationship: many_to_one
    sql_on: ${net_terms_finance_status_vendor.vendor_id}=${aph_vendor.vendor_id}  ;;
  }

  join: phoenix_id_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${phoenix_id_types.financial_schedule_id}=${asset_purchase_history.financial_schedule_id}  ;;
    #test
  }

  join: greensill_assets_paid_off {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_purchase_history.asset_id}=${greensill_assets_paid_off.asset_id}  ;;
    #test
  }

  join: all_greensill {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_purchase_history.asset_id}=${all_greensill.asset_id}  ;;
    #test
  }

  join: ez_ar {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_purchase_history.asset_id}=${ez_ar.asset_id}  ;;
    #test
  }

  join: abl_category {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_purchase_history.asset_id}=${abl_category.asset_id}  ;;
  }
  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.company_id}=${companies.company_id}  ;;
  }
}

#MB commented out 5/23/24 explore returned unused or tied to old dashboard
# explore: guidance_lines_of_credit {
#   case_sensitive: no
# }

explore: aph_log {
  group_label: "Asset Purchase History Log"
  case_sensitive: no
  # persist_for: "2 minutes"
}
