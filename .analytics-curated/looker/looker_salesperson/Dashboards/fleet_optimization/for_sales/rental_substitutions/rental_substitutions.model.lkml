connection: "es_snowflake_analytics"

include: "./*.view.lkml"                # include all views in the views/ folder in this project

explore: rental_substitutions{
  group_label: "Rental Substitutions"
  label: "Rental Substitutions"
  case_sensitive: no
}
