connection: "es_snowflake_analytics"

include: "/driver_performance/*"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/driver_performance/seat_belt/*"

# explore: driver_performance {
#   group_label: "Driver Performance"
#   label: "Weekly Driver Performance"
#   case_sensitive: no
# }

# explore: driver_response_to_coaching {
#   group_label: "Driver Performance"
#   label: "Driver Performance After Coaching"
#   case_sensitive: no
# }

# explore: driver_video_events {
#   group_label: "Driver Performance"
#   label: "Driver Events with Video"
#   case_sensitive: no
# }

explore: driver_safety_rating {
  group_label: "Driver Performance V2"
  label: "Weekly Driver Performance"
  case_sensitive: no
  persist_for: "12 hours"

  join: drivers {
    type: left_outer
    relationship: one_to_many
    sql_on: ${drivers.operator_id} = ${driver_safety_rating.operator_id} ;;
  }
}

explore: driver_performance_coaching_recs_testing {
  group_label: "Driver Performance V2"
  label: "Weekly Driver Coaching Recommendations"
  case_sensitive: no
  persist_for: "12 hours"
}


explore: driver_video_events_review {
  group_label: "Driver Performance"
  label: "Driver Events Video Review"
  case_sensitive: no
  persist_for: "12 hours"
}

explore: market_driver_performance {
  group_label: "Driver Performance"
  label: "Market Driving Performance"
  case_sensitive: no
  persist_for: "12 hours"
  sql_always_where: ${employee_title_permissions.person_access} = TRUE ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_driver_performance.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: employee_title_permissions {
    type: left_outer
    relationship: one_to_many
    sql_on: TO_VARCHAR(${employee_title_permissions.subject_market_id}) = ${market_driver_performance.market_id} ;;
  }
}

explore: market_driver_risk {
  group_label: "Driver Performance"
  label: "Driver Market Performance"
  case_sensitive: no
  persist_for: "12 hours"
  sql_always_where: ${employee_title_permissions.person_access} = TRUE ;;

  join: employee_title_permissions {
    type: inner
    relationship: one_to_many
    sql_on: TO_VARCHAR(${employee_title_permissions.subject_operator_id}) = ${market_driver_risk.operator_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_driver_risk.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: primary_event_coaching {
    from: event_coaching_library
    type: left_outer
    relationship: many_to_many
    sql_on: ${primary_event_coaching.event_name} = ${market_driver_risk.primary_contributing_event} ;;
  }

  join: secondary_event_coaching {
    from: event_coaching_library
    type: left_outer
    relationship: many_to_many
    sql_on: ${secondary_event_coaching.event_name} = ${market_driver_risk.secondary_contributing_event} ;;
  }
}

explore: seat_belt_detection {
  group_label: "Driver Performance"
  label: "Seat Belt - Operator Summary"
  case_sensitive: no
  description: "Operators ranked by frequency of No Seat Belt events during daylight hours (7 AM - 6 PM local). Off-hours events shown separately as potential false alerts. Join to event detail to drill into individual events and video."

  join: seat_belt_events {
    type: left_outer
    relationship: one_to_many
    sql_on: ${seat_belt_detection.operator_id} = ${seat_belt_events.operator_id} ;;
  }
}
