connection: "es_snowflake_analytics"

include: "/Dashboards/Lender_Portal_Management/Views/*.view.lkml"

include: "/views/ES_WAREHOUSE/asset_purchase_history.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/financial_schedules.view.lkml"
include: "/views/ES_WAREHOUSE/financial_lenders.view.lkml"


explore: asset_purchase_history {
  label: "T3 Lender Portal Management"
  join: financial_schedules {
    relationship: one_to_many
    sql_on: ${asset_purchase_history.financial_schedule_id} = ${financial_schedules.financial_schedule_id} ;;
  }

  join: financial_lenders {
    relationship: one_to_many
    sql_on: ${financial_schedules.originating_lender_id} = ${financial_lenders.financial_lender_id} ;;
  }

  join: lender_to_company_id {
    relationship: many_to_many
    sql_on: ${financial_lenders.financial_lender_id} = ${lender_to_company_id.financial_lender_id} ;;
  }

  join: telematics_service_providers_assets {
    relationship: many_to_many
    sql_on: ${asset_purchase_history.asset_id} = ${telematics_service_providers_assets.asset_id} ;;
  }

  join: companies {
    relationship: many_to_one
    sql_on: ${telematics_service_providers_assets.company_id} = ${companies.company_id} ;;
  }
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
 }
