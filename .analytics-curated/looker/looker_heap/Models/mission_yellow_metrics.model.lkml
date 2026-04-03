connection: "es_snowflake"

include: "/views/mission_yellow_metrics/*.view.lkml"
include: "/views/ES_WAREHOUSE/*.view.lkml"

explore: daily_active_users_by_company {
  group_label: "Mission Yellow"
  label: "T3 Mission Yellow DAU"
  case_sensitive: no
}

explore: tracked_assets_by_day {
  group_label: "Mission Yellow"
  label: "T3 Mission Yellow Tracked Assets/Companies"
  case_sensitive: no
}

explore: new_user_cohorts {
  group_label: "Mission Yellow"
  label: "T3 Mission Yellow New User Cohorts"
  case_sensitive: no
}
