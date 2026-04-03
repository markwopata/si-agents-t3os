connection: "es_snowflake_analytics"

# include: "/views/custom_sql/paycor_hours_detail.view.lkml"
# include: "/views/custom_sql/paycor_hours_new.view.lkml"
# include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
# include: "/views/custom_sql/paycor_track_hours.view.lkml"
# include: "/views/custom_sql/paycor_track_combined_hours.view.lkml"
# include: "/views/ANALYTICS/market_directory.view.lkml"
# include: "/views/ANALYTICS/dept_mapping_mkt_directory.view.lkml"

# # datagroup: 6AM_update {
# #   sql_trigger: SELECT FLOOR((EXTRACT(epoch from CURRENT_TIMESTAMP()) - 60*60*12)/(60*60*24)) ;;
# #   max_cache_age: "24 hours"
# # }

# # datagroup: Every_Hour_Update {
# #   sql_trigger: SELECT DATE_PART('hour', CURRENT_TIMESTAMP()) ;;
# #   max_cache_age: "1 hour"
# # }

# # datagroup: Every_5_Min_Update {
# #   sql_trigger: SELECT DATE_PART('minute', CURRENT_TIMESTAMP()) ;;
# #   max_cache_age: "5 minutes"}


#MB commented out 5/23/24 explore returned unused or tied to old dashboard
# explore: paycor_hours_detail {

#   #label: "Re-Rent Inventory Information"
#   #group_label: "Asset Information"
#   case_sensitive: no
#   #sql_always_where: ${location_name}  not in ('Remote','Corporate Office','Telematics Office','Telematics Warehouse')
#   #and ${hours} > 0;;



#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${paycor_hours_detail.loc_dept}=${market_region_xwalk.abbreviation} ;;
#   }



# }

# explore: paycor_hours_new {
#   case_sensitive: no
#   }


# explore: paycor_track_hours {
#   case_sensitive: no
# }

# explore: paycor_track_combined_hours {
#   case_sensitive: no
#   sql_always_where: ${paycor_track_combined_hours.loc_name} not in ('COR','REM') and ${market_directory.market_type} is not null;;

#   join: dept_mapping_mkt_directory {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${paycor_track_combined_hours.dept_name}=${dept_mapping_mkt_directory.dept_name} ;;
#   }

#   join: market_directory {
#     type: inner
#     relationship: many_to_one
#     sql_on: (${dept_mapping_mkt_directory.dept_mapping} = upper(${market_directory.market_type})) and (${paycor_track_combined_hours.loc_name} = ${market_directory.paycor_name}) and ${market_directory.market_type} is not null;;
#   }

#   join: market_region_xwalk {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${market_directory.market_id}=${market_region_xwalk.market_id} ;;
#   }
# }
