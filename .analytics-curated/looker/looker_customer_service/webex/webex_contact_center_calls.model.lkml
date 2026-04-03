connection: "es_snowflake_analytics"

include: "/webex/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
explore: webex_contact_center_calls {
  }

explore: webex_contect_center_branch_rollovers {
}
