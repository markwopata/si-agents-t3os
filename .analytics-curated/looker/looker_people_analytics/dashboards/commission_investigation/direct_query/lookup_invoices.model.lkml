connection: "es_snowflake_analytics"

include: "lookup_invoices.view.lkml"

explore: lookup_invoices {
  label: "Lookup Invoices"
  description: "Look up invoices."
}
