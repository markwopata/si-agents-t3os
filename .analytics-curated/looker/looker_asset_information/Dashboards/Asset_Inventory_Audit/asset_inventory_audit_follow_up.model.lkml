connection: "es_snowflake"

include: "/Dashboards/Asset_Inventory_Audit/Views/ES_Warehouse/contracts.view.lkml"
include: "/Dashboards/Asset_Inventory_Audit/Views/ES_Warehouse/assets.view.lkml"
include: "/Dashboards/Asset_Inventory_Audit/Views/ES_Warehouse/asset_status_key_values.view.lkml"
include: "/Dashboards/Asset_Inventory_Audit/Views/ES_Warehouse/assets_aggregate.view.lkml"
include: "/Dashboards/Asset_Inventory_Audit/Views/ES_Warehouse/companies.view.lkml"
include: "/Dashboards/Asset_Inventory_Audit/Views/ES_Warehouse/invoices.view.lkml"
include: "/Dashboards/Asset_Inventory_Audit/Views/ES_Warehouse/locations.view.lkml"
include: "/Dashboards/Asset_Inventory_Audit/Views/ES_Warehouse/orders.view.lkml"
include: "/Dashboards/Asset_Inventory_Audit/Views/ES_Warehouse/rentals.view.lkml"
include: "/Dashboards/Asset_Inventory_Audit/Views/Analytics/market_region_xwalk.view.lkml"
include: "/Dashboards/Asset_Inventory_Audit/Views/ES_Warehouse/markets.view.lkml"


# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: assets {
#   label: "Asset Inventory Audit"
#   case_sensitive: no
#
#   join: asset_owner {
#     from: companies
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${assets.company_id} = ${asset_owner.company_id} ;;
#   }
#
#   join: asset_rental_branch {
#     from: markets
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.rental_branch_id} = ${asset_rental_branch.market_id} ;;
#   }
#   join: asset_rental_branch_owner {
#     from: companies
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${asset_rental_branch.company_id} = ${asset_rental_branch_owner.company_id} ;;
#   }
#
#   join: asset_service_branch {
#     from: markets
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.rental_branch_id} = ${asset_service_branch.market_id} ;;
#   }
#   join: asset_service_branch_owner {
#     from: companies
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${asset_service_branch.company_id} = ${asset_service_branch_owner.company_id} ;;
#   }
#
#   join: asset_inventory_branch {
#     from: markets
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.rental_branch_id} = ${asset_inventory_branch.market_id} ;;
#   }
#   join: asset_inventory_branch_owner {
#     from: companies
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${asset_inventory_branch.company_id} = ${asset_inventory_branch_owner.company_id} ;;
#   }
#
#
# }
