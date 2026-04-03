connection: "es_snowflake_analytics"

include: "/Dashboards/Inventory_Branch_Scorecard/views/*.view.lkml"
# include: "/Dashboards/Inventory_Branch_Scorecard/views/deadstock_ratio_aggregate.view.lkml"
include: "//service/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "//service/views/ANALYTICS/warranty_invoices.view.lkml"
include: "//service/views/custom_sql/trending_dead_stock.view.lkml"
include: "//service/views/custom_sql/warranty_invoices.view.lkml"
include: "//service/views/custom_sql/wo_tags_aggregate.view.lkml"
include: "//service/views/WORK_ORDERS/work_orders.view.lkml"



#include: "/Dashboards/Service_Branch_Scorecard/Views/market_region_xwalk_and_dates.view.lkml"

explore: inventory_branch_scorecard {
  label: "Inventory Branch Scorecard"
  persist_for: "24 hours"
  sql_always_where:
      ${inventory_branch_scorecard.District_Region_Market_Access}
      or 'developer' = {{ _user_attributes['department'] }}
      or 'admin' = {{ _user_attributes['department'] }}
      or TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}') = 'jabbok@equipmentshare.com';;
  from: market_region_xwalk_and_dates

#Branch Ranking Filter
  join: branch_ranking_filter {
    type: left_outer
    relationship: one_to_many
    sql_on: ${inventory_branch_scorecard.market_id} = ${branch_ranking_filter.market_id} ;;
  }
#Branch Contact - Orders by Part Manager first, then Parts Associate, Service Manager and finally General Manager.  Grabs whoever is available in that order
  join: branch_contact {
    type: left_outer
    relationship: one_to_one
    sql_on: ${inventory_branch_scorecard.market_id} = ${branch_contact.market_id} ;;
  }
#Deadstock Ratio
  join: deadstock_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${inventory_branch_scorecard.market_id} = ${deadstock_aggregate.market_id} and
            ${inventory_branch_scorecard.month} = ${deadstock_aggregate.month} ;;
  }
#Warranty Denials
  join: warranty_denials_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${inventory_branch_scorecard.market_id} = ${warranty_denials_aggregate.branch_id} and
            ${inventory_branch_scorecard.month} = ${warranty_denials_aggregate.month} ;;
  }
#Work Order Aggregate
  join: parts_needed_wo_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${inventory_branch_scorecard.market_id} = ${parts_needed_wo_aggregate.branch_id} and
            ${inventory_branch_scorecard.month} = ${parts_needed_wo_aggregate.month} ;;
  }
#manual adjustment aggregate
  join: manual_adjustment_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${inventory_branch_scorecard.market_id} = ${manual_adjustment_aggregate.market_id} and
            ${inventory_branch_scorecard.month} = ${manual_adjustment_aggregate.month} ;;
  }
#min / max Aggregate
  join: min_max_use_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${inventory_branch_scorecard.market_id} = ${min_max_use_aggregate.branch_id} and
            ${inventory_branch_scorecard.month} = ${min_max_use_aggregate.month} ;;
  }
#bin Locations Usage Aggregate
  join: bin_locations_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${inventory_branch_scorecard.market_id} = ${bin_locations_aggregate.branch_id} and
            ${inventory_branch_scorecard.month} = ${bin_locations_aggregate.month} ;;
  }
#Purchae Order Aggregate
  join: purchase_order_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${inventory_branch_scorecard.market_id} = ${purchase_order_aggregate.branch_id} and
            ${inventory_branch_scorecard.month} = ${purchase_order_aggregate.month} ;;
  }
}
