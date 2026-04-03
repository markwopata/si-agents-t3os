connection: "es_snowflake"

include: "/Dashboards/retail_sales/used_sales_test/*.view.lkml"                # include all views in the in this project folder

# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
explore: recent_sales {
  group_label: "Fleet"
  label: "Used Equipment Sales Test"
  case_sensitive: no
}
