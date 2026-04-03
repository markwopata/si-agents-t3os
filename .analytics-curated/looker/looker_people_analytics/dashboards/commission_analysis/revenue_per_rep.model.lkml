connection: "es_snowflake_analytics"  # Replace with your actual connection name

include: "revenue_per_rep.view.lkml"

explore: revenue_per_rep {
  label: "Revenue Analysis by Salesrep"
  description: "Analyze Core Rental Revenue by Salesrep"
}
