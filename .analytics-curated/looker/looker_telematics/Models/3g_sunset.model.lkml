connection: "es_snowflake_analytics"

# include: "/views/custom_sql/3g_sunset.view.lkml"
# include: "/views/custom_sql/tracker_type_buckets.view.lkml"
# include: "/views/ANALYTICS/high_risk_devices.view.lkml"

# commenting out unused explore 5/22/24
# explore: 3g_sunset {
#   case_sensitive: no
#   persist_for: "5 minutes"
#   sql_always_where: ${update_status} <> 'N/A' and ${risk_level} <> 'N/A'  ;;

#   join: high_risk_devices {
#     type:  left_outer
#     relationship: many_to_one
#     sql_on: ${3g_sunset.tracker_serial} = ${high_risk_devices.serial_number} ;;
#   }

#   join: tracker_type_buckets {
#     type:  left_outer
#     relationship: many_to_one
#     sql_on: ${3g_sunset.tracker_id} = ${tracker_type_buckets.tracker_id} ;;
#   }
#   }
