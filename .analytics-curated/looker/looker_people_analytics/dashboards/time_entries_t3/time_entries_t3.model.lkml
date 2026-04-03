connection: "es_snowflake_pa_c_analytics"

include: "/dashboards/time_entries_t3/time_entries_t3.explore.lkml"

# code below this line is new
include: "/_base/people_analytics/looker/time_entries_t3_time_lag_PL.view.lkml"
