connection: "es_snowflake"

include: "/Dashboards/retail_sales/target_sales.view.lkml"           # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
# Commented out due to low usage on 2026-03-26
# explore: target_sales {
#   group_label: "Fleet"
#   label: "Target Sales Pilot"
#   case_sensitive: no
# }
