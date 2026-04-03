connection: "es_snowflake_analytics"

include: "./*.view.lkml"                # include all views in the folder in this project

# Commented out due to low usage on 2026-03-26
# explore: fleet_sales {
#   group_label: "Fleet"
#   label: "Fleet Sales Combined Dashboard"
#   case_sensitive: no
# }
