connection: "es_snowflake_c_analytics"

include: "/views/custom_sql/units_on_rent_rolling_90_days_by_salesperson.view.lkml"
include: "/views/custom_sql/market_region_salesperson_rank_amount.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"

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


#Salesperson last 90 day rolling rentals
explore: units_on_rent_rolling_90_days_by_salesperson {
  case_sensitive: no
  sql_always_where: (('collectors' = {{ _user_attributes['department'] }} OR 'salesperson' = {{ _user_attributes['department'] }} AND ${users.email_address} =  LOWER('{{ _user_attributes['email'] }}') )) OR ${market_region_salesperson_rank_amount.Salesperson_District_Region_Market_Access} ;;

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${units_on_rent_rolling_90_days_by_salesperson.sales_id} = ${users.user_id} ;;
  }

  join: market_region_salesperson_rank_amount {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${market_region_salesperson_rank_amount.salesperson_user_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_salesperson_rank_amount.market_id} = ${market_region_xwalk.market_id} ;;
  }
}
