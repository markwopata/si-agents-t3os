connection: "es_snowflake_analytics"  # Replace with your actual connection name

include: "guarantee_vs_commission.view.lkml"

explore: guarantee_vs_commission {
  label: "Guarantee vs. Commission"
  description: "Analyzing Guarantee vs. Commission on each salesrep"
}
