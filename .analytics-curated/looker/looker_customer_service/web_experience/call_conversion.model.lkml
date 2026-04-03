connection: "es_snowflake_analytics"

include: "/web_experience/*.view.lkml"

explore: call_conversion {
  # join: orders {
  #   relationship: many_to_one
  #   sql_on: ${orders.id} = ${order_items.order_id} ;;
  # }
}
