connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/custom_sql/work_orders_open_rolling_90.view.lkml"
include: "/views/custom_sql/assets_in_statuses_over_x_days_rolling_90.view.lkml"
include: "/views/custom_sql/work_orders_open_count_past_90_days.view.lkml"
include: "/views/custom_sql/unavailable_last_90_days_history.view.lkml"

#SELECT FLOOR(EXTRACT(epoch from NOW()) / (X*60*60))
#if you need every x hours updated replace the x with the number you are needing

# datagroup: 6AM_update {
#   sql_trigger: SELECT FLOOR((DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) - 60*60*12)/(60*60*24)) ;;
#   max_cache_age: "24 hours"
# }

# datagroup: Every_Hour_Update {
#   sql_trigger: SELECT HOUR(CURRENT_TIME()) ;;
#   max_cache_age: "1 hour"
# }

# datagroup: Every_Two_Hours_Update {
#   sql_trigger: SELECT FLOOR(DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) / (2*60*60)) ;;
#   max_cache_age: "2 hours"
# }

# datagroup: Every_5_Min_Update {
#   sql_trigger: SELECT DATE_PART('minute', CURRENT_TIMESTAMP) ;;
#   max_cache_age: "5 minutes"
# }

#Work Orders Open Rolling 90

# Commented out due to low usage on 2026-03-27
# explore: work_orders_open_rolling_90 {
#   case_sensitive: no
#   group_label: "Service"
#   label: "Work Orders Open Rolling 90"
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${work_orders_open_rolling_90.market_id} = ${market_region_xwalk.market_id} ;;
#   }
# }

#Assets In Status for X Days Rolling 90
explore: assets_in_statuses_over_x_days_rolling_90 {
  case_sensitive: no
  group_label: "Service"
  label: "Assets in Statuses Over X Days Rolling 90"

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${assets_in_statuses_over_x_days_rolling_90.market_id} ;;
  }
}

#Works orders open past 90 days

# Commented out due to low usage on 2026-03-27
# explore: work_orders_open_count_past_90_days {
#   group_label: "Service"
#   label: "Total WO's Open Last 90 Days"
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${work_orders_open_count_past_90_days.branch_id} = ${market_region_xwalk.market_id} ;;
#   }
# }

#Service - Unavailable History - Past 90 days for unavailable history
explore: unavailable_last_90_days_history {
  group_label: "Service"
  label: "Unavailable History"
  description: "Past 90 days for unavailable history"
  case_sensitive: no

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${unavailable_last_90_days_history.rental_branch_id} ;;
  }
}
