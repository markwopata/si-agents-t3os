connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/PARTS_INVENTORY/parts_cogs_monthly_report.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/unbilled_warranty_monthly_report.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/unbilled_nonwarranty_monthly_report.view.lkml"
include: "/views/custom_sql/ute_vs_temp.view.lkml" #Temporary
include: "/views/ANALYTICS/PARTS_INVENTORY/month_end_t3_inventory_valuation.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/month_end_shopify_ops_inventory_valuation.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/month_end_shopify_ops_revenue.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/t3_parts_inventory_rerents_snapshot.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/open_work_orders_monthly_report.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/service_labor_cogs_monthly_report.view.lkml"
include: "/views/INVENTORY/weighted_average_cost_snapshots.view.lkml"

explore: service_labor_cogs_monthly_report {
  case_sensitive: no
}

explore: open_work_orders_monthly_report {
  case_sensitive: no
}

explore: parts_cogs_monthly_report {
  case_sensitive: no
}

explore: unbilled_warranty_monthly_report {
  case_sensitive: no
}

explore: unbilled_nonwarranty_monthly_report {
  case_sensitive: no
}

#Temporary, will be deleted after project is complete - TA

# Commented out due to low usage on 2026-03-27
# explore: ute_vs_temp {
#   case_sensitive: no
# }

explore: month_end_t3_inventory_valuation {
  case_sensitive: no
  join: weighted_average_cost_snapshots {
    type: inner
    relationship: one_to_one
    sql_on: ${month_end_t3_inventory_valuation.wac_snapshot_id} = ${weighted_average_cost_snapshots.wac_snapshot_id} ;;
  }
}

explore: month_end_shopify_ops_inventory_valuation {
  case_sensitive: no
}

explore: month_end_shopify_ops_revenue {
  case_sensitive: no
}

explore: t3_parts_inventory_rerents_snapshot {
  case_sensitive: no
}
