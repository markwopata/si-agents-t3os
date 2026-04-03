connection: "es_snowflake_analytics"

include: "quote_details.view.lkml"

explore: quote_details {
  label: "Quote Details"
  description: "Quote rates and duration counts."
}
