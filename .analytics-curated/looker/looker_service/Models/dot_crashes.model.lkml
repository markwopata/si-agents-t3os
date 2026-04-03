connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/dot_crashes.view.lkml"

# Commented out due to low usage on 2026-03-27
# explore: dot_crashes{
#   case_sensitive: no
#   group_label: "DOT Data"
#   label: "DOT Crashes"
# }
