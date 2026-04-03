# Commented out due to zero usage on 2026-03-26 — model has 0 explores, 0 queries in 90d
# connection: "es_snowflake"

# include: "/Dashboards/Dispatching_Metrics/views/v_deliveries.view.lkml"
# include: "/views/analytics/asset_physical.view.lkml"

#MB commented out 5/22/24 goes to old dashboard
# explore: delivery_metrics {
#   from: v_deliveries
#   persist_for: "24 hours"

#   join: asset_physical {
#     view_label: "Assets"
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${delivery_metrics.asset_id} = ${asset_physical.asset_id} ;;
#   }
# }
