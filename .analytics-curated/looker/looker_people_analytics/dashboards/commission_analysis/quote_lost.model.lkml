connection: "es_snowflake_analytics"  # Replace with your actual connection name

include: "quote_lost.view.lkml"

explore: quote_lost {
  label: "Quote Lost Data"
  description: "Quote Lost by Missed Rental Reasons"
}
