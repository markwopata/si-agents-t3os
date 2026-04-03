connection: "es_snowflake"

include: "/views/custom_sql/exxon_on_off_rent_with_spend.view.lkml"

explore: exxon_on_off_rent_with_spend {
  group_label: "Rentals"
  label: "Exxon Spend By Rental"
  case_sensitive: no
  description: "Used to pull data for industrial tools team to put together data for Exxon"
}
