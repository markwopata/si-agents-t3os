connection: "non_prod_financial_systems"

include: "/views/DBT_FINANCIAL_SYSTEMS/*.view.lkml"

include: "/views/DBT_FINANCIAL_SYSTEMS/VENDORS_GOLD/*.view.lkml"
# include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: stage_matters_changelog {
  view_label: "Stage Matters Changelog"
  join: stage_matters {
    relationship: one_to_many
    sql_on: ${stage_matters.matter_id} = ${stage_matters_changelog.matter_id} ;;
  }
}

explore: stage_fleet__po_headers {
  view_label: "Stage Fleet PO Headers"
}

explore: stage_clustdoc_vendor_app_checks {
  view_label: "Stage ClustDoc Vendor Application Checks"
}

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
