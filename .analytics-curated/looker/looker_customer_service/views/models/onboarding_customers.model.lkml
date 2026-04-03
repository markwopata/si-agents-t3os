connection: "es_snowflake_analytics"

include: "/views/*.view.lkml"

# Commented out due to low usage on 2026-03-26.
# explore: onboarding_customers {
#   group_label: "Customer Service"
#   case_sensitive: no
#   }
