 connection: "es_snowflake_analytics"

include: "/Dashboards/Service_Bulletin_Lookup_Tool/Views/assets_service_bulletin.view.lkml"
#include: "/Dashboards/Service_Bulletin_Lookup_Tool/Views/warranty_work_orders.view.lkml"
include: "/Dashboards/Service_Bulletin_Lookup_Tool/Views/warranty_work_orders_beta.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/asset_purchase_history.view.lkml"
include: "/views/ES_WAREHOUSE/work_orders.view.lkml"
include: "/views/ES_WAREHOUSE/billing_types.view.lkml"
include: "/views/ES_WAREHOUSE/work_orders_by_tag.view.lkml"
include: "/views/market_region_xwalk.view.lkml"
include: "/views/SCD/scd_asset_inventory_status.view.lkml"
include: "/views/ES_WAREHOUSE/company_tags.view.lkml"
include: "/views/ES_WAREHOUSE/work_order_company_tags.view.lkml"
include: "/views/custom_sql/work_orders_with_non_telematics_parts.view.lkml"
include: "/views/custom_sql/assets_under_warranty.view.lkml"
include: "/views/custom_sql/warranty_denial_rate.view.lkml"
include: "/views/ANALYTICS/oem_notification_dates.view.lkml"
include: "/views/custom_sql/transportation_assets.view.lkml"
include: "/views/custom_sql/warrantable_assets_aggregate.view.lkml"
include: "/views/custom_sql/warranty_admin_asset_assignment.view.lkml"
include: "/views/BASE/assets_aggregate_base.view.lkml"
include: "/views/custom_sql/warranty_missed_opportunity.view.lkml"
include: "/views/custom_sql/days_since_needs_more_info_added.view.lkml"

explore: oem_notification_dates {
  description: "Number of days until a Warranty Claim is due"
  case_sensitive: no
}

explore: warranty_work_order_lookup {
  from: assets_aggregate_base
  label: "Asset Warranty Lookup"
  case_sensitive: no


  join: warranty_admin_asset_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${warranty_work_order_lookup.asset_id} = ${warranty_admin_asset_assignments.asset_id} ;;
  }

  join: warranty_work_orders_beta { #Base Code
    type: inner
    relationship: one_to_one
    sql_on: ${warranty_work_order_lookup.asset_id} = ${warranty_work_orders_beta.asset_id} ;;
  }

  join: billing_types {
    type: left_outer
    relationship:  one_to_one
    sql_on: ${warranty_work_orders_beta.billing_type_id} = ${billing_types.billing_type_id} ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: work_order_company_tags {
    type: left_outer
    relationship: one_to_many
    sql_on: ${warranty_work_orders_beta.work_order_id} = ${work_order_company_tags.work_order_id} ;;
  }

  join: company_tags {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_order_company_tags.company_tag_id} = ${company_tags.company_tag_id} ;;
  }

  join: work_orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.work_order_id} = ${warranty_work_orders_beta.work_order_id} ;;
  }

  #filter to only wo which have at least 1 non telematics part
  join: work_orders_with_non_telematics_parts {
    type:  inner
    relationship: one_to_one
    sql_on:  ${work_orders.work_order_id} = ${work_orders_with_non_telematics_parts.work_order_id} ;;
  }

  join: assets_under_warranty {
    type: left_outer
    relationship: many_to_one
    sql_on:${warranty_work_order_lookup.asset_id} = ${assets_under_warranty.asset_id} ;;
  }

  join: oem_notification_dates {
    type: left_outer
    relationship: many_to_one
    sql_on: ${oem_notification_dates.oem} = ${warranty_work_order_lookup.make} ;;
  }

  join: transportation_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${warranty_work_order_lookup.asset_id} = ${transportation_assets.asset_id} ;;
  }

  join: warranty_missed_opportunity {
    type: left_outer
    relationship: one_to_one
    sql_on: ${warranty_missed_opportunity.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: days_since_needs_more_info_added {
    type: left_outer
    relationship: one_to_one
    sql_on: ${days_since_needs_more_info_added.work_order_id} = ${warranty_work_orders_beta.work_order_id} ;;
  }
}

# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: warranty_denial_rate {
#   case_sensitive: no
#   description: "Total Warranty Claims and Denials by OEM based on days it took to bill"
# }
