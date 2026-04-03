connection: "es_snowflake_analytics"

include: "/Dashboards/retail_sales/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.

explore:deal_sales_assets {
  group_label: "Deal Sales"
  label: "Deal Equipment Sales"
  case_sensitive: no
  description: "Filtered view of used equipment sales including ONLY those assets with associated incentive/deal"
  persist_for: "1 hour"
  fields: [ALL_FIELDS *]
}

explore:deals_not_sold {
  group_label: "Deal Sales"
  label: "Unsold Deal Assets"
  case_sensitive: no
  description: "Filtered view of ONLY those assets with associated incentive/deal that have not yet sold"
  persist_for: "1 hour"
  fields: [ALL_FIELDS *]
}
