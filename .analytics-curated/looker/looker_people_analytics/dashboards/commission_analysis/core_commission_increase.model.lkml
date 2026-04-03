connection: "es_snowflake_analytics"  # Replace with your actual connection name

include: "core_commission_increase.view.lkml"

explore: core_commission_increase {
  label: "Commission Data"
  description: "Commission transactions with finance segment details"
}
