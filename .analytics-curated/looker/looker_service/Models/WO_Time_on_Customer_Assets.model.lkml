connection: "es_snowflake"

#include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project

# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard
## pulling in specific views since the above is causing errors in the project validate lookml 2.28.25 HL
include: "/views/TIME_TRACKING/time_entries.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/custom_sql/es_ownership.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
explore: time_entries {
  always_filter: {
    filters: [archived: "false"]}


  join: assets_aggregate{
    type:  inner
    relationship: one_to_one
    sql_on: ${time_entries.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: users {
    type:  inner
    relationship: one_to_one
    sql_on: ${users.user_id} = ${time_entries.user_id} ;;
  }


  join: companies {
    type: inner
    relationship: one_to_one
    sql_on:  ${companies.company_id} = ${assets_aggregate.company_id} ;;
  }

  join: es_ownership {
    type: inner
    relationship:  one_to_one
    sql_on: ${assets_aggregate.company_id} = ${es_ownership.company_id} ;;
  }

  join: work_orders {
    type: inner
    relationship: one_to_one
    sql_on:  ${time_entries.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.branch_id} = ${market_region_xwalk.market_id};;
  }
}
