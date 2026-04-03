connection: "es_snowflake_analytics"

include: "/intercom/*.view.lkml"

# Commented out due to low usage on 2026-03-26.
# explore: intercom_section_history {
#   group_label: "Customer Service"
#   case_sensitive: no
#   }
