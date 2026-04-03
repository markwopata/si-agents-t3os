connection: "es_snowflake_analytics"

##include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/views/ANALYTICS/dvir_detail.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/command_audit.view.lkml"
include: "/views/custom_sql/districts_regions.view.lkml"
include: "/views/SCD/scd_asset_inventory_status.view.lkml"
include: "/views/ES_WAREHOUSE/scd_asset_msp.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/company_purchase_order_line_items.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/custom_sql/transportation_assets.view.lkml"
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
explore: dvir_detail {
  case_sensitive:  no

  join: work_orders {
    type:  inner
    relationship: many_to_one
    sql_on: ${dvir_detail.work_order_id} = ${work_orders.work_order_id}
          AND ${dvir_detail.asset_id} = ${work_orders.asset_id}
          ;;
  }

  join: scd_asset_msp {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.branch_id} = ${scd_asset_msp.service_branch_id}
          AND ${work_orders.asset_id} = ${scd_asset_msp.asset_id};;
  }

  join: markets {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.branch_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: assets_aggregate {
    type: inner
    relationship: one_to_one
    sql_on:  ${work_orders.asset_id} = ${assets_aggregate.asset_id}
      ;;
  }

  join: users {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.creator_user_id} = ${users.user_id} ;;
  }

  ##trying to pull user who closed the WO here. Need to follow up with Kim on this
  join: command_audit {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${work_orders.work_order_id} = ${command_audit.work_order_id}
      AND CAST(${work_orders.date_completed_date} AS DATE) = CAST(${command_audit.date_created_date} AS DATE);;
    sql_where: ${command_audit.command} = 'CloseWorkOrder';;
  }

  join: users_2 {
    from: users
    type: inner
    relationship: one_to_one
    sql_on: ${command_audit.user_id} = ${users.user_id};;
  }

  join: scd_asset_inventory_status {
    type: inner
    relationship: many_to_one
    sql_on:  ${assets_aggregate.asset_id} = ${scd_asset_inventory_status.asset_id} ;;
  }

  join: company_purchase_order_line_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_purchase_order_line_items.asset_id} = ${dvir_detail.asset_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dvir_detail.asset_id} = ${assets.asset_id} ;;
  }

  join: transportation_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transportation_assets.asset_id} = ${assets.asset_id} ;;
  }
}
