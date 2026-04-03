connection: "clio"

include: "/views/custom_sql/clio_matters.view.lkml"
include: "/views/custom_sql/third_party_collections.view.lkml"
include: "/views/custom_sql/third_party_assignments_monthly.view.lkml"
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

explore: clio_matters {
  label: "CLIO Matters"
  sql_always_where: {{ _user_attributes['clio_access'] }} = 'yes' ;;

}

explore: third_party_collections {
  label: "Third Party Collections Reconciliation"
  }

explore: third_party_assignments_monthly {
  label: "Third Party Assigments "
}

# }
