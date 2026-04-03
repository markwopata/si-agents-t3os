connection: "es_snowflake"

include: "/Dashboards/IFTA/ifta_report.view.lkml"

# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: ifta_report {
#   group_label: "IFTA Report"
#   label: "IFTA Report"
#   case_sensitive: no
# }
