connection: "es_snowflake_analytics"

include: "/_base/analytics/parts_inventory/fact_cycle_counts.view.lkml"

explore: fact_cycle_counts {
  label: "cycle_counts"
}
