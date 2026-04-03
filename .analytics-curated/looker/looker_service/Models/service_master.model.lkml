connection: "es_snowflake"

#include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/views/custom_sql/asset_invoice_amounts.view.lkml"
# include: "/views/assets_postgres.view.lkml"
# include: "/views/scd_asset_inventory_status_postgres.view.lkml"
# include: "/views/custom_sql/service_expenses_and_rental_revenue_comparison.view.lkml"
# include: "/views/market_region_xwalk_postgres.view.lkml"



#MB commented out 5/22/24 ties to no active dashboard/look
#Assets tied to WO and Invoices
# explore: asset_invoice_amounts {

#   join: assets_postgres {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets_postgres.asset_id} = ${asset_invoice_amounts.asset_id} ;;
#   }

#   join: scd_asset_inventory_status_postgres {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${scd_asset_inventory_status_postgres.asset_id} = ${assets_postgres.asset_id} ;;
#   }
# }

# #Service Expenses vs Service and Rental Revenue
# explore: service_expenses_and_rental_revenue_comparison {

#   join: market_region_xwalk_postgres {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_region_xwalk_postgres.market_id} = ${service_expenses_and_rental_revenue_comparison.market_id} ;;
#   }

# }
