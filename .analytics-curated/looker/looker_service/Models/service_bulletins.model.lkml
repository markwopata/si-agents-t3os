connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/SERVICE/service_bulletins.view.lkml"
include: "/views/ANALYTICS/SERVICE/service_bulletin_assignment.view.lkml"
include: "/views/ANALYTICS/SERVICE/service_bulletin_affected_groups.view.lkml"
include: "/views/PLATFORM/v_assets.view.lkml"
include: "/views/PLATFORM/v_markets.view.lkml"
include: "/views/TIME_TRACKING/time_entries.view.lkml"
include: "/views/WORK_ORDERS/billing_types.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/views/WORK_ORDERS/work_order_files.view.lkml"
include: "/views/WORK_ORDERS/work_order_originators.view.lkml"
include: "/views/custom_sql/warranty_team_billed_wo.view.lkml"
include: "/views/custom_sql/wo_parts_cost.view.lkml"

explore: work_orders {
  label: "Service Bulletin Work Orders"

  join: work_order_originators {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${work_order_originators.work_order_id} and ${work_order_originators.originator_type_id} = 10 ;;
  }

  join: service_bulletin_assignment {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${service_bulletin_assignment.work_order_id} and ${service_bulletin_assignment.is_current} = true and ${service_bulletin_assignment.active} = true ;;
  }

  join: service_bulletins {
    type: inner
    relationship: many_to_one
    sql_on: (${work_order_originators.originator_id} = ${service_bulletins.service_bulletin_id} or ${service_bulletin_assignment.service_bulletin_id} = ${service_bulletins.service_bulletin_id}) and ${service_bulletins.is_current} = true ;;
  }

  join: work_order_files {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${work_order_files.work_order_id} ;;
  }

  join: wo_parts_cost {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${wo_parts_cost.work_order_id} ;;
  }

  join: v_assets {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${v_assets.asset_id} ;;
  }

  join: billing_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
  }

  join: time_entries {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.work_order_id} = ${time_entries.work_order_id} ;;
  }

  join: v_markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.branch_id} = ${v_markets.market_id} ;;
  }

  join: work_order_image_count {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${work_order_image_count.work_order_id} ;;
  }

  join: time_entries_agg {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.work_order_id} = ${time_entries_agg.work_order_id} ;;
  }

  join: warranty_team_billed_wo {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.work_order_id} = ${warranty_team_billed_wo.work_order_id} ;;
  }
}
