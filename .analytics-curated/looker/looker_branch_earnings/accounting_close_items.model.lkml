connection: "es_snowflake_c_analytics"

include: "/**/**.view.lkml"                # include all views in the views/ folder in this project
include: "suggestions.lkml"

# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: credit_card_inventory_reclass {
  label: "Credit Card Inventory Reclass"
  description: "Automating an accounting entry for inventory that is purchased on credit cards."
}

explore: gl_to_cc_join {
  label: "Merchant Spend Report"
  description: "GL to CC transaction join that has merchant and account detail for procurement."
}
