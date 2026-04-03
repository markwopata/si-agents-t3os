connection: "es_snowflake_analytics"

include: "/Dashboards/rm_landing_page/*.view.lkml"


# Commented out due to low usage on 2026-03-26
# explore: regional_manager_direct_reports {
#   group_label: "Regional Manager Landing Page"
#   label: "Regional Manager Direct Reports and Navigation Setup"
#   description: "Regional Manager Landing Page when going to Looker"
#   case_sensitive: no
#   persist_for: "10 hours"
# }
