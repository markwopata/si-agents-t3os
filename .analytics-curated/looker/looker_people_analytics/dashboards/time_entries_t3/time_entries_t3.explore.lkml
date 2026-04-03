include: "/_standard/people_analytics/looker/time_entries_t3.layer.lkml"
include: "/_standard/analytics/public/market_region_xwalk.layer.lkml"

# line below is new
include: "/_base/people_analytics/looker/time_entries_t3_time_lag_PL.view.lkml"

explore: time_entries_t3 {
  from:time_entries_t3
  group_label: "Time Entries"
  label: "Time Entries with Market Information"
  case_sensitive: no


  join: market_region_xwalk {
    relationship: one_to_many
    type: left_outer
    sql_on: ${time_entries_t3.market_id} = ${market_region_xwalk.market_id} ;;
  }

# any code below this line is new
  join: time_entries_t3_time_lag_PL {
    relationship: one_to_one
    type: left_outer
    sql_on: ${time_entries_t3.full_name} = ${time_entries_t3_time_lag_PL.full_name} ;;
  }

}
