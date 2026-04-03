connection: "es_snowflake"

include: "/Dashboards/Asset_Creation_Metrics/Views/*.view.lkml"

# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: create_asset_column_completion_percentages {
#   group_label: "Asset Creation Metrics"
#   label: "Percentage of column completion during asset creation"
#   case_sensitive: no
# }

# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: create_asset_column_totals {
#   group_label: "Asset Creation Metrics"
#   label: "Total columns completed during asset creation"
#   case_sensitive: no
# }

# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: asset_edit_information {
#   group_label: "Asset Creation Metrics"
#   label: "Asset edit totals and info"
#   case_sensitive: no
# }

# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: heap_creation_events_and_pages {
#   group_label: "Asset Creation Metrics"
#   label: "Heap data"
#   case_sensitive: no
# }

##testing
