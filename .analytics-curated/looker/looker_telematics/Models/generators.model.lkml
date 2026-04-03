connection: "es_snowflake_analytics"

include: "/views/custom_sql/generator_summary.view.lkml"
include: "/views/ANALYTICS/generator_alerts.view.lkml"
include: "/views/custom_sql/generator_engine_active.view.lkml"
include: "/views/custom_sql/generators_charts.view.lkml"
include: "/views/custom_sql/generator_string.view.lkml"


# explore: generator_summary {
#   case_sensitive: no
#   persist_for: "1 minute"
#   sql_always_where: ${generator_engine_active.name} = 'engine_active' and  ${generator_engine_active.value} = 'true' and ${equipment_class_name} like '%Generator%';;


#   join: generator_alerts {
#     type:  left_outer
#     relationship: many_to_one
#     sql_on: ${generator_summary.asset_id} = ${generator_alerts.asset_id} ;;
#   }

#   join: generator_engine_active {
#     type:  inner
#     relationship: many_to_one
#     sql_on: ${generator_summary.asset_id} = ${generator_engine_active.asset_id} ;;
#   }
# }



# explore: generators_charts {
#   case_sensitive: no
#   persist_for: "1 minute"
#   sql_always_where: ${generator_engine_active.name} = 'engine_active' and  ${generator_engine_active.value} = 'true' and ${generator_summary.equipment_class_name} like '%Generator%';;


#     join: generator_summary {
#     type:  left_outer
#     relationship: many_to_one
#     sql_on: ${generator_summary.asset_id} = ${generators_charts.asset_id} ;;
#   }

#   join: generator_alerts {
#     type:  left_outer
#     relationship: many_to_one
#     sql_on: ${generator_summary.asset_id} = ${generator_alerts.asset_id} ;;
#   }

#   join: generator_engine_active {
#     type:  inner
#     relationship: many_to_one
#     sql_on: ${generator_summary.asset_id} = ${generator_engine_active.asset_id} ;;
#   }
# }


# explore: generator_string {
#   case_sensitive: no
#   persist_for: "1 minute"}
