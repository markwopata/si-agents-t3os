connection: "es_snowflake_analytics"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/views/rental_requests/*.view.lkml"                 # include all views in this project
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

# Commented out due to low usage on 2026-03-26.
# explore: customer_support_rental_requests {}

# Commented out due to low usage on 2026-03-26.
# explore: dead_deals {}

# Commented out due to low usage on 2026-03-26.
# explore: rental_request_revenue {}

# Commented out due to low usage on 2026-03-26.
# explore: web_submissions {
#   view_name: web_submissions
#   case_sensitive: no
#   persist_for: "30 minutes"
# }


# Commented out due to low usage on 2026-03-26.
# explore: quotes_table_dead_deals {
# }
