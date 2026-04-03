connection: "es_snowflake_analytics"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
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

week_start_day: sunday

explore: engineering_shortcut_stories{
  group_label: "Engineering"
  label: "Workflow Data"

  sql_always_where: NOT ${engineering_shortcut_stories.is_archived} ;;
  # sql_always_where:
  #   contains(${engineering_shortcut_stories.labels}, 'roadmap') OR
  #   contains(${engineering_shortcut_stories.labels}, 'xteam_unplanned') OR
  #   contains(${engineering_shortcut_stories.labels}, 'xteam_planned') OR
  #   contains(${engineering_shortcut_stories.labels}, 'unplanned') OR
  #   contains(${engineering_shortcut_stories.labels}, 'dependency_defect') OR
  #   contains(${engineering_shortcut_stories.labels}, 'techdebt');;
}

# Commented out due to low usage on 2026-03-31
# explore: engineering_shortcut_stories_daily{
#   group_label: "Engineering"
#   label: "Workflow Rollups"
# }

# Commented out due to low usage on 2026-03-31
# explore: eng_prod_deployments {
#   group_label: "Engineering"
#   label: "Prod Deployments"
# }

# Commented out due to low usage on 2026-03-31
# explore: change_failures {
#   group_label: "Engineering"
#   label: "Change Failures"
# }
