connection: "es_snowflake_analytics"  # Replace with your actual connection name

include: "rate_achievement_change.view.lkml"

explore: rate_achievement_change {
  label: "Change in Rate Achievement"
  description: "High Level View of Changes in Rate Achievement by Month"
}
