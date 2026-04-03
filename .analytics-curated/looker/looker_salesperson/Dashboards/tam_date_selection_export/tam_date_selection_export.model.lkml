connection: "es_snowflake_analytics"

include: "/Dashboards/tam_date_selection_export/*.view.lkml"


# Commented out due to low usage on 2026-03-26
# explore: tam_date_selection_export {
#   group_label: "TAM Metric Export"
#   label: "Date Selection for TAM Metric Export"
#   description: "Allows user to select two dates to compare TAM metrics"
#   case_sensitive: no
# }
