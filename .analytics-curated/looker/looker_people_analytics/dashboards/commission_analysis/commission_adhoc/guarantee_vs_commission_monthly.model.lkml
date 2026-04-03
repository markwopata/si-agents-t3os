connection: "es_snowflake_analytics"  # Replace with your actual connection name

include: "guarantee_vs_commission_monthly.view.lkml"

explore: guarantee_vs_commission_monthly {
  label: "Guarantee vs. Commission Monthly"
  description: "Analyzing Guarantee vs. Commission on each salesrep"
}
