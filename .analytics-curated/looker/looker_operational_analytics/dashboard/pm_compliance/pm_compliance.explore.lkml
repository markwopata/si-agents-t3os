include: "/_base/es_warehouse/public/service_records.view.lkml"
include: "/_base/es_warehouse/scd/scd_asset_msp.view.lkml"
include: "/_base/es_warehouse/work_orders/work_order_originators.view.lkml"
include: "/_base/es_warehouse/work_orders/work_orders.view.lkml"
include: "/_base/platform/gold/v_assets.view.lkml"
include: "/_base/platform/gold/v_markets.view.lkml"
include: "/_standard/custom_sql/most_recent_per_record.view.lkml"
include: "/_standard/custom_sql/work_order_parts.view.lkml"
include: "/_standard/es_warehouse/time_entries.layer.lkml"
include: "/_standard/es_warehouse/work_order_files.layer.lkml"

explore: work_orders {
  label: "PM Compliance"

  join: work_order_originators {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${work_order_originators.work_order_id} and ${work_order_originators.originator_type_id} = 3 ;;
  }

  join: service_records {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${service_records.work_order_id} ;;
  }

  join: most_recent_per_record {
    type: inner
    relationship: one_to_one
    sql_on: ${service_records.service_record_id} = ${most_recent_per_record.service_record_id} and ${most_recent_per_record.service_interval_type_id} = 4;;
  }

  join: work_order_files {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.work_order_id} = ${work_order_files.work_order_id} ;;
  }

  join: work_order_parts {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.work_order_id} = ${work_order_parts.work_order_id} ;;
    fields: [wo_part,work_order_id,part_id,part_number,part_description,transaction_cost,part_cost,final_quantity,part_list,total_part_cost]
  }

  join: time_entries {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.work_order_id} = ${time_entries.work_order_id} ;;
  }

  join: scd_asset_msp {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.asset_id} = ${scd_asset_msp.asset_id}
      and ${work_orders.date_created_date} between ${scd_asset_msp.date_start_date} and ${scd_asset_msp.date_end_date} ;;
  }

  join: v_markets {
    type: inner
    relationship: one_to_one
    sql_on: ${scd_asset_msp.service_branch_id} = ${v_markets.market_id} ;;
  }

  join: v_assets {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.asset_id} = ${v_assets.asset_id} ;;
  }
}
