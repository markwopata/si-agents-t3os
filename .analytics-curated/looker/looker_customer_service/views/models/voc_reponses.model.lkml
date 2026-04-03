connection: "es_snowflake_analytics"

include: "/views/voc_responses/*.view.lkml"

# Commented out due to low usage on 2026-03-26.
# explore: voc_responses {
#   group_label: "Customer Service"
#   case_sensitive: no
# }

# Commented out due to low usage on 2026-03-26.
# explore: voc_responses_retool {
#   group_label: "Customer Service"
#   case_sensitive: no
# }
