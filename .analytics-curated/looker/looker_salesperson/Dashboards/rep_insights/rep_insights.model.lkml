connection: "es_snowflake_analytics"

include: "/Dashboards/rep_insights/*.view.lkml"
include: "/Dashboards/Market_Operations_1378/Current/current_guarantee_commissions_status.view.lkml"



# Commented out due to low usage on 2026-03-26
# explore: rep_assets_on_rent_insights {
#   group_label: "TAM Insights"
#   label: "TAM Assets On Rent Insights"
#   description: "Insights into declining assets on rent of TAMS along with duration/impact"
#   case_sensitive: no
#   persist_for: "10 hours"
#
#   join: current_guarantee_commissions_status {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${current_guarantee_commissions_status.salesperson_user_id} = ${rep_assets_on_rent_insights.salesperson_user_id} ;;
#   }
# }
#
# explore: rep_rental_revenue_insights {
#   group_label: "TAM Insights"
#   label: "TAM Rental Revenue Insights"
#   description: "Insight into not meeting rental revenue threshold"
#   case_sensitive: no
#   persist_for: "10 hours"
#
#   join: current_guarantee_commissions_status {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${current_guarantee_commissions_status.salesperson_user_id} = ${rep_rental_revenue_insights.salesperson_user_id} ;;
#   }
# }
#
# explore: rep_new_accounts_insights {
#   group_label: "TAM Insights"
#   label: "TAM New Account Insights"
#   description: "Insight into low new account threshold or no new accounts"
#   case_sensitive: no
#   persist_for: "10 hours"
#
#   join: current_guarantee_commissions_status {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${current_guarantee_commissions_status.salesperson_user_id} = ${rep_new_accounts_insights.salesperson_user_id} ;;
#   }
# }
#
# explore: rep_actively_renting_customers_insights {
#   group_label: "TAM Insights"
#   label: "TAM Actively Renting Customers Insights"
#   description: "Insight into declining of actively renting customers of TAMS along with duration/impact"
#   case_sensitive: no
#   persist_for: "10 hours"
#
#   join: current_guarantee_commissions_status {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${current_guarantee_commissions_status.salesperson_user_id} = ${rep_actively_renting_customers_insights.salesperson_user_id} ;;
#   }
# }
#
# explore: rsm_insights_dashboard_info {
#   group_label: "TAM Insights"
#   label: "RSM Insights Dashboard Info"
#   description: "A drilldown linked to an html object explains metrics within the dashboard"
#   case_sensitive: no
#   persist_for: "24 hours"
# }
