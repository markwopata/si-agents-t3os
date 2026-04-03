connection: "es_snowflake_analytics"

include: "*.view.lkml"

# Commented out due to low usage on 2026-03-26
# explore: rental_substitution_outliers{
#   group_label: "Rental Substitution Outliers"
#   label: "Rental Substitution Outliers"
#   case_sensitive: no
# }
