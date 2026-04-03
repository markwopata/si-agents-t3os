view: robotics_logs {

  sql_table_name: "ROBOTICS"."ROBOTICS_LOGS_TEST"
  ;;



  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
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

  dimension: controlling_user {
    description: "Controlling user name"
    type:  string
    sql:  ${TABLE}.controlling_client_id ;;
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

  dimension: current_task_id {
    description: "Current Task ID"
    type:  string
    sql:  ${TABLE}.current_task_id ;;
  }

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
}

# view: robotics_logs {
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
