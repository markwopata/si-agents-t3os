connection: "es_snowflake"

# include: "/views/delivery_research/*.view.lkml"
# include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
# include: "/views/custom_sql/rentals_days_revenue_by_company.view.lkml"

#MB commented out 5/23/24 explore returned unused or tied to old dashboard
# explore: delivery_type_breakdown_by_branch {
#   group_label: "Deliveries"
#   label: "Delivery Type by Branch"
#   case_sensitive: no

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${delivery_type_breakdown_by_branch.branch}) = ${market_region_xwalk.market_name} ;;
#   }
# }

# explore: total_orders_by_branch_by_day {
#   group_label: "Delivery Research"
#   label: "Orders by Branch by Day"
#   case_sensitive: no

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${total_orders_by_branch_by_day.branch}) = ${market_region_xwalk.market_name} ;;
#   }
# }

# explore: actively_renting_customers_during_timeframe {
#   group_label: "Delivery Research"
#   label: "Active Rental Customers"
#   case_sensitive: no
# }

# explore: rentals_days_revenue_by_company {
#   group_label: "Delivery Research"
#   label: "Rentals, Average Days, and Revenue Segments"
# }

# explore: total_orders_by_branch_by_day {
#   group_label: "Deliveries"
#   label: "Total Orders Breakdown"
#   case_sensitive: no
# }
