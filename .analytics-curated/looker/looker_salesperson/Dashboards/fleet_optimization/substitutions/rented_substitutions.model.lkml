connection: "es_snowflake_c_analytics"

include: "*.view.lkml"

explore: rented_substitutions {
  label: "Rental Substitutions"
}
