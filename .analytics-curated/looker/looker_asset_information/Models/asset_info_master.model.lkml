connection: "es_snowflake_analytics"

include: "/views/custom_sql/running_generators.view.lkml"


# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: running_generators {
#   group_label: "Generators"
# }
