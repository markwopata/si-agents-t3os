connection: "es_snowflake_analytics"


include: "/views/custom_sql/asset_files_custom.view"
include: "/views/custom_sql/asset_photos_count.view"
include: "/views/custom_sql/asset_photos_url_path.view"

# include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: asset_files_custom {
#   group_label: "Asset Photos"
#   case_sensitive: no
# }

# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: asset_photos_count {
#   group_label: "Asset Photos"
#   case_sensitive: no
# }

# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: asset_photos_url_path {
#   group_label: "Asset Photos"
#   case_sensitive: no
# }
