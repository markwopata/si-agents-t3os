connection: "es_snowflake_analytics"

# include: "/views/custom_sql/telematics_health_report.view.lkml"                # include all views in the views/ folder in this project

# commenting out unused explore 5/22/24
# explore: telematics_health_report {
#   label: "Telematics Health Report"
#   case_sensitive: no
#   persist_for: "10 minutes"
# }
