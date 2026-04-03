
connection: "es_snowflake_analytics"  # Replace with your actual connection name

include: "out_of_market.view.lkml"

explore: out_of_market {
  label: "Salesrep Revenue Outside Their Market"
  description: "Analyzing data of the salesreps outside their market"
}
