connection: "es_snowflake_analytics"

include: "/views/es_admin_customer_service/*.view.lkml"

# Commented out due to low usage on 2026-03-26.
# explore: customer_service_es_admin_actions {
#   group_label: "Customer Service"
#   case_sensitive: no
# }
