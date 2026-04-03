connection: "es_snowflake_analytics"

include: "/**/*.view.lkml"

# Commented out due to low usage on 2026-03-26.
# explore: interactions_by_day {
#   group_label: "Customer Service"
#   case_sensitive: no
#   }
