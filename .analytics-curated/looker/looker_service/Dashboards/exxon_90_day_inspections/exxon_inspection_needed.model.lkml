connection: "es_snowflake_analytics"

include: "/Dashboards/exxon_90_day_inspections/assets_needing_exxon_inspection.view.lkml"

# Commented out due to low usage on 2026-03-27
# explore: assets_needing_exxon_inspection {
#   case_sensitive: no
#   description: "A list of assets on rent to Exxon that have not had an Exxon tagged inspection in over 80 days"
# }
