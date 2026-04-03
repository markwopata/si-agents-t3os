#view: VW_SNOWFLAKE_DATABASE {
  # # You can specify the table name if it's different from the view name:
#  sql_table_name: SNOWFLAKE.ACCOUNT_USAGE.DATABASES ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }

#  dimension: COLUMNS_HTML {
#    type: string
#    sql: ${TABLE}.COLUMNS_HTML ;;
#  }

#  dimension: COLUMN_HTML {
#    type: string
#    sql: ${TABLE}.COLUMN_HTML ;;
#  }

#  dimension: TABLES_HTML {
#    type: string
#    sql: ${TABLE}.TABLES_HTML ;;
#  }

#  dimension: TABLE_HTML {
#    type: string
#    sql: ${TABLE}.TABLE_HTML ;;
#  }

#  dimension: SCHEMAS_HTML {
#    type: string
#    sql: ${TABLE}.SCHEMAS_HTML ;;
#  }

#  dimension: SCHEMA_HTML {
#    type: string
#    sql: ${TABLE}.SCHEMA_HTML ;;
#  }

#  dimension: DATABASES_HTML {
#    type: string
#    sql: ${TABLE}.DATABASES_HTML ;;
#  }

#  dimension: DATABASE_HTML {
#    type: string
#    sql: ${TABLE}.DATABASE_HTML ;;
#  }

#  dimension: SERVERS_HTML {
#    type: string
#    sql: ${TABLE}.SERVERS_HTML ;;
#  }

#  dimension: DELETED {
#    type: string
#    sql: ${TABLE}.DELETED ;;
#  }

#  dimension: SERVER_HTML {
#    type: string
#    sql: ${TABLE}.SERVERS_HTML ;;
#  }

#}


#measure: COLUMN_NAME_ASSET {
#  type: sum
#  sql: ${COLUMN_NAME_ASSET} ;;
#  html:
#    <ul>
#      <li> value: {{ value }} </li>
#      <li> rendered_value: {{ rendered_value }} </li>
#      <li> linked_value: {{ linked_value }} </li>
#      <li> link: {{ link }} </li>
#      <li> model: {{ _model._name }} </li>
#      <li> view: {{ _view._name }} </li>
#      <li> explore: {{ _explore._name }} </li>
#      <li> field: {{ _field._name }} </li>
#      <li> dialect: {{ _dialect._name }} </li>
#      <li> access filter: {{ _access_filters['company.name'] }} </li>
#      <li> user attribute: {{ _user_attributes['region'] }} </li>
#      <li> query timezone: {{ _query._query_timezone }} </li>
#      <li> filters: {{ _filters['order.total_order_amount'] }} </li>
#    </ul> ;;
#}

# view: databases {
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
