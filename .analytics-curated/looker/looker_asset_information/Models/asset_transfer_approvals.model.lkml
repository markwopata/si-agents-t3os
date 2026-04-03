connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/asset_transfer_approval_log.view.lkml"


# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: asset_transfer_approval_log {
#   group_label: "Asset Transfer Approval Log"
# }
