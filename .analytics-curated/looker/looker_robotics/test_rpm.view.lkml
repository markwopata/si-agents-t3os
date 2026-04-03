view: test_rpm {

  derived_table: {
    sql: select
robotics_logs_id as robotics_logs_id,
convert_timezone('America/Chicago', to_timestamp_tz($2:timestamp)) as timestamp,
to_double($2:vehicle.track_loader.engine_rpm) as engine_rpm,
$2:vehicle.autonomous_error_type as autonomous_error_type,
$2:vehicle.autonomous_state as autonomous_state,
$2:vehicle.vehicle_state as vehicle_state,
$2:vehicle.controlling_user as controlling_user,
$2:vehicle.asset_id as asset_id,
$2:vehicle.id as vehicle_id

from "ES_WAREHOUSE"."ROBOTICS"."ROBOTICS_LOGS" as rl
where rl.created_timestamp > dateadd(minute,-60*24*1,current_timestamp)
and to_timestamp_tz($2:timestamp) > dateadd(minute,-60*24*1,current_timestamp)
and $2:protobuf_message_name like 'VehicleStatus'
and $2:logger like 'VehicleObserver_telemetry'
and $2:vehicle.asset_id like '3'

ORDER BY timestamp desc
;;
  }

  dimension: robotics_logs_id {
    description: "Unique ID for each user that has ordered"
    type: number
    sql: ${TABLE}.robotics_logs_id ;;
  }

  dimension: timestamp {
    description: "Timestamp in central time."
    type: date_time
    sql:  ${TABLE}.timestamp ;;
  }
  dimension: engine_rpm {
    description: "Engine RPM"
    type: number
    sql:  ${TABLE}.engine_rpm ;;
  }
  dimension: controlling_user {
    description: "Controlling user name"
    type:  string
    sql:  ${TABLE}.controlling_user ;;
  }
  dimension: autonomous_state {
    description: "Autonomous State"
    type:  string
    sql:  ${TABLE}.autonomous_state ;;
  }
  dimension: autonomous_error_type {
    description: "Autonomous Error Type"
    type:  string
    sql:  ${TABLE}.autonomous_error_type ;;
  }
  dimension: vehicle_state {
    description: "Vehicle State"
    type:  string
    sql:  ${TABLE}.vehicle_state ;;
  }
  dimension: vehicle_id {
    description: "Vehicle ID"
    type:  string
    sql:  ${TABLE}.vehicle_id ;;
  }
  dimension: asset_id {
    description: "Asset ID"
    type:  string
    sql:  ${TABLE}.asset_id ;;
  }
}
  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }


# view: test_rpm {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
