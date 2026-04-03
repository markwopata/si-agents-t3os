connection: "es_snowflake_data_science"

include: "abnormal_asset_operation.view"
include: "can_snapshot_report.view"
include: "aod_asset_sparklines.view"
include: "aod_asset_drilldown.view"
include: "aod_asset_drilldown_v2.view"
include: "frequent_parts.view"
include: "frequent_part_tags.view"
include: "semaphore_wokb_integration.view"
include: "semaphore_wokb_integration_0.2.view"
include: "cluster_word_cloud.view"
include: "cluster_word_cloud_details.view"
include: "aod_jedunn_trendlines.view"
include: "service_revenue_ratios_v0.0.1.view"
include: "cluster_word_cloud_stats.view"
include: "rental_revenue_proportion_isolate.view"
include: "aod_asset_trendlines_beta.view"
include: "asset_unique_dtcs.view"
include: "asset_ignition_count_hourly.view"
include: "asset_tracking_incidents_ignition_count_hourly.view"
include: "asset_trips_per_day.view"
include: "trip_time_distance.view"
include: "trips_anomalies.view"
include: "morey_vbus_records_wip.view"

# Commented out due to low usage on 2026-03-26
# explore: aod_asset_sparklines {
#   from: aod_asset_sparklines
# }

# Commented out due to low usage on 2026-03-26
# explore: aod_asset_drilldown {
#   from: aod_asset_drilldown
# }

# Commented out due to low usage on 2026-03-26
# explore: aod_asset_drilldown_v2 {
#   from: aod_asset_drilldown_v2
# }

# Commented out due to low usage on 2026-03-26
# explore: can_snapshot_report {
#   from: can_snapshot_report
# }

# Commented out due to low usage on 2026-03-26
# explore: frequent_parts {
#   from: frequent_parts
# }

# Commented out due to low usage on 2026-03-26
# explore: frequent_part_tags {
#   from: frequent_part_tags
# }

# Commented out due to low usage on 2026-03-26
# explore: semaphore_wokb_integration {
#   from:  semaphore_wokb_integration
# }

# explore: semaphore_wokb_integration_v2 { --MB comment out 10-10-23 due to inactivity
#   from:  semaphore_wokb_integration_v2
# }

# explore: cluster_word_cloud { --MB comment out 10-10-23 due to inactivity
#   from:  cluster_word_cloud
# }

# explore: cluster_word_cloud_details { --MB comment out 10-10-23 due to inactivity
#   from:  cluster_word_cloud_details
# }

# Commented out due to low usage on 2026-03-26
# explore: aod_jedunn_trendlines {
#   from:  aod_jedunn_trendlines
# }

# Commented out due to low usage on 2026-03-26
# explore: service_revenue_ratios_v0_0_1 {
#   from:  service_revenue_ratios_v0_0_1
# }

# explore: cluster_word_cloud_stats { --MB comment out 10-10-23 due to inactivity
#   from:  cluster_word_cloud_stats
# }

# Commented out due to low usage on 2026-03-26
# explore: rental_revenue_proportion_isolate {
#   from:  rental_revenue_proportion_isolate
# }

# Commented out due to low usage on 2026-03-26
# explore: aod_asset_trendlines_beta {
#   from: aod_asset_trendlines_beta
# }

# Commented out due to low usage on 2026-03-26
# explore: asset_unique_dtcs {
#   from: asset_unique_dtcs
# }

# Commented out due to low usage on 2026-03-26
# explore: asset_ignition_count_hourly {
#   from: asset_ignition_count_hourly
# }

# Commented out due to low usage on 2026-03-26
# explore: asset_trips_per_day {
#   from:  asset_trips_per_day
# }

# Commented out due to low usage on 2026-03-26
# explore: asset_tracking_incidents_ignition_count_hourly {
#   from:  asset_tracking_incidents_ignition_count_hourly
# }

# Commented out due to low usage on 2026-03-26
# explore: trip_time_distance {
#   from:  trip_time_distance
# }

# Commented out due to low usage on 2026-03-26
# explore: trip_anomalies {
#   from: trip_anomalies
# }

# Commented out due to low usage on 2026-03-26
# explore: morey_vbus_records_wip{
#   from: morey_vbus_records_wip
# }
