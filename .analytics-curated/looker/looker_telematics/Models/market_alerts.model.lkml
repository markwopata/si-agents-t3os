connection: "es_snowflake_analytics"

# include: "/views/custom_sql/market_alerts_diesel_particles.view.lkml"
# include: "/views/custom_sql/market_alerts_def.view.lkml"
# include: "/views/custom_sql/market_def.view.lkml"
# include: "/views/custom_sql/market_alert_engine_oil_pressure.view.lkml"
# include: "/views/custom_sql/market_alert_low_fuel.view.lkml"
# include: "/views/ANALYTICS/market_alerts.view.lkml"


# explore: market_alerts_def {
#   case_sensitive: no
#   persist_for: "1 minute"

#   join: market_alerts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_alerts.asset_id} = ${market_alerts_def.asset_id} ;;
#   } }

# explore: market_alerts_diesel_particles {
#   case_sensitive: no
#   persist_for: "1 minute"

#   join: market_alerts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_alerts.asset_id} = ${market_alerts_diesel_particles.asset_id} ;;
#   } }

# explore: market_alert_engine_oil_pressure {
#   case_sensitive: no
#   persist_for: "1 minute"

#   join: market_alerts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_alerts.asset_id} = ${market_alert_engine_oil_pressure.asset_id} ;;
#   } }

# explore: market_alert_low_fuel {
#   case_sensitive: no
#   persist_for: "1 minute"

#   join: market_alerts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_alerts.asset_id} = ${market_alert_low_fuel.asset_id} ;;
#   } }


# explore: market_def {
#   case_sensitive: no
#   persist_for: "1 minute"}
