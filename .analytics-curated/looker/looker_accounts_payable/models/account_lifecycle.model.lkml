connection: "es_snowflake_analytics"

include: "/views/custom_sql/account_lifecycle.view.lkml"
include: "/views/custom_sql/account_lifecycle_details.view.lkml"
# include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }
explore: account_lifecycle {
  join: account_lifecycle_details {
    type: inner
    relationship: many_to_one
    sql_on: ${account_lifecycle.company_id} =${account_lifecycle_details.company_id} ;;
  }
}
