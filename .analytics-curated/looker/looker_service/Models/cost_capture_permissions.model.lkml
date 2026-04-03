connection: "es_snowflake_analytics"

# include: "/views/custom_sql/cost_capture_user_permissions.view.lkml"
include: "/views/custom_sql/cost_capture_locations.view.lkml"

# explore: cost_capture_user_permissions {
#   case_sensitive: no
#   group_label: "Cost Capture"
#   label: "User Permissions"
# }

explore: cost_capture_locations {
  case_sensitive: no
  group_label: "Cost Capture"
  label: "Region and Location Mappings"
}
