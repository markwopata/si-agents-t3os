connection: "es_snowflake_analytics"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/Dashboards/Customer_Rebates/views/customer_rebates_line_item_details.view.lkml"
include: "/views/ANALYTICS/customer_rebate_agreements.view.lkml"
# include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
 explore: customer_rebates_line_item_details{

join: market_region_xwalk {

  sql_on: ${customer_rebates_line_item_details.branch_id} = ${market_region_xwalk.market_id} ;;
  relationship: one_to_one
}


 }


explore: customer_rebate_agreements {



}
