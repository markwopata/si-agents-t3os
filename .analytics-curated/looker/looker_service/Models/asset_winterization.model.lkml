connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/SERVICE/asset_winterization_alert.view.lkml"


# Commented out due to low usage on 2026-03-27
# explore: asset_winterization_alert {
#   case_sensitive: no
# }
