connection: "es_snowflake_analytics"

include: "rate_comparisons.view.lkml"

explore: rate_comparisons {
  label: "Rate Comparisons"
  description: "Compares quoted rental rates vs branch rental rate floor and flags billed mismatches."
}
