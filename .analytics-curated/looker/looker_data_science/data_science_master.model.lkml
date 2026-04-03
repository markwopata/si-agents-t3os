connection: "es_warehouse_rw"

include: "can_snapshot_data_usage.view"
include: "can_snapshot_data_usage_diff.view"

# Commented out due to low usage on 2026-03-26
# explore: can_snapshot_data_usage {
#   from: can_snapshot_data_usage
# }

# Commented out due to low usage on 2026-03-26
# explore: can_snapshot_data_usage_diff {
#   from: can_snapshot_data_usage_diff
# }
