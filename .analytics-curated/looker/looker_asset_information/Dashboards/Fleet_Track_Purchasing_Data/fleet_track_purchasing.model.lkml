connection: "es_snowflake"

include: "/Dashboards/Fleet_Track_Purchasing_Data/Views/*.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"

# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: fleet_track {
#   from: company_purchase_orders
#
#   join: company_purchase_order_line_items {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${fleet_track.company_purchase_order_id} = ${company_purchase_order_line_items.company_purchase_order_id} ;;
#   }
#
#
#
# }
