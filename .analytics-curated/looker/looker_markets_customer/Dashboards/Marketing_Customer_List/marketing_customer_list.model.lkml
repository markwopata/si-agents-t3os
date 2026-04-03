connection: "es_snowflake_analytics"

# include: "/Dashboards/Marketing_Customer_List/views/company_revenue_by_date.view.lkml"
# include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
# include: "/views/ES_WAREHOUSE/locations.view.lkml"
# include: "/views/ES_WAREHOUSE/states.view.lkml"

#MB commented out 5/23/24 explore returned unused or tied to old dashboard
# # This explore is very specific to the marketing program beginning May 2023 and should not be
# # used elsewhere.
# explore: company_revenue_by_date {
#   group_label: "Marketing Customer Lists"
#   label: "Marketing Customer Lists - Over $100k"
#   case_sensitive: no

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${company_revenue_by_date.market_id} = ${market_region_xwalk.market_id} ;;
#   }

#   join: locations {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${company_revenue_by_date.billing_location_id} = ${locations.location_id} ;;
#   }

#   join: states {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${locations.state_id} = ${states.state_id} ;;
#   }
# }
