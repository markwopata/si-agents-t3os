connection: "es_snowflake_analytics"

# include: "/views/custom_sql/ukg_track_combined_hours.view.lkml"
# include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
# #include: "/views/ANALYTICS/intaact_code_by_ee.view.lkml"
# #include: "/views/ANALYTICS/intacct_code_by_ee.view.lkml"
# include: "/views/ANALYTICS/company_directory.view.lkml"

#MB commented out 5/23/24 explore returned unused or tied to old dashboard
# explore: ukg_track_combined_hours {
#   case_sensitive: no


#   join: company_directory {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${company_directory.employee_id}=${ukg_track_combined_hours.employee_number} ;;
#   }

#   join: market_region_xwalk {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${company_directory.market_id}=${market_region_xwalk.market_id} ;;
#   }
# }
