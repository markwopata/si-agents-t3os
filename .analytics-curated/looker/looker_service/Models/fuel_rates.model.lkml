connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/fuel_rates.view.lkml"

explore: fuel_rates{
  case_sensitive: no
  label: "Fuel Rates"
}
