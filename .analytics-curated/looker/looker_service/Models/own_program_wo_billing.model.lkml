connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"
#include: "/views/WORK_ORDERS/company_tags.view.lkml"
include: "/views/WORK_ORDERS/billing_types.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
#include: "/views/ES_WAREHOUSE/equipment_assignments.view.lkml"
#include: "/views/ES_WAREHOUSE/rentals.view.lkml"
#include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
#include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/SCD/scd_asset_inventory_status.view.lkml"
#include: "/views/SCD/scd_asset_company.view.lkml"
#include: "/views/custom_sql/wos_within_24hrs_of_delivery_variable_date.view.lkml"
#include: "/views/WORK_ORDERS/work_order_files.view.lkml"
#include: "/views/TIME_TRACKING/time_entries.view.lkml"
#include: "/views/TIME_TRACKING/time_tracking_event_types.view.lkml"
include: "/views/custom_sql/wo_tags_aggregate.view.lkml"
#include: "/views/INVENTORY/transactions.view.lkml"
#include: "/views/INVENTORY/transaction_items.view.lkml"
#include: "/views/custom_sql/wo_parts_cost.view.lkml"
#include: "/views/ANALYTICS/warranty_accrual.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
#include: "/views/custom_sql/service_tech_hours.view.lkml"
#include: "/views/custom_sql/tech_wos_within_7days_of_delivery.view.lkml"
#include: "/views/custom_sql/tech_wos_completed.view.lkml"
#include: "/views/custom_sql/parts_ordered_vs_used.view.lkml"
include: "/views/custom_sql/es_ownership_3_flags.view.lkml"
#include: "/views/ANALYTICS/company_directory.view.lkml"
#include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
#include: "/views/custom_sql/damage_warranty_recovery.view.lkml"
#include: "/views/custom_sql/wos_needed_for_rentals.view.lkml"
#include: "/views/custom_sql/unavailable_history_365.view.lkml"
include: "/views/ES_WAREHOUSE/asset_service_intervals.view.lkml"
include: "/views/WORK_ORDERS/work_order_originators.view.lkml"
include: "/views/WORK_ORDERS/work_order_statuses.view.lkml"
include: "/views/payout_program_assignments.view.lkml"
include: "/views/originator_types.view.lkml"
include: "/views/ES_WAREHOUSE/asset_warranty_xref.view.lkml"
include: "/views/SCD/scd_asset_hours.view.lkml"
include: "/views/SCD/scd_asset_company.view.lkml"
include: "/views/ANALYTICS/asset_ownership.view.lkml"
include: "/views/payout_programs.view.lkml"

#Work Orders - Work Order Information
explore: work_orders {
  group_label: "Work Orders"
  label: "Work Order Billing with OWN Program"
  case_sensitive: no

join: wo_tags_aggregate {
  type:  left_outer
  relationship: one_to_one
  sql_on: ${work_orders.work_order_id}=${wo_tags_aggregate.work_order_id} ;;
}
  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship:many_to_one
    sql_on: ${work_orders.branch_id} = ${markets.market_id} ;;
  }

  join: billing_types {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
  }

  join: work_order_statuses {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_status_id} = ${work_order_statuses.work_order_status_id} ;;
  }

  join: work_order_originators { #past service
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${work_order_originators.work_order_id} ;; #is this the right col to join on?
  }

  join: originator_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_originators.originator_type_id} = ${originator_types.originator_type_id} ;; #is this the right col to join on?
  }

  join: asset_service_intervals { #future service
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${asset_service_intervals.work_order_id} ;; #is this the right col to join on?
  }

  join: invoices {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.invoice_number} = ${invoices.invoice_no} ;;
  }

  join: asset_owner {
    from: companies
    type: inner
    relationship: one_to_one
    sql_on: ${assets.company_id} = ${asset_owner.company_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.company_id} = ${companies.company_id} ;;
  }

  join: payout_program_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${payout_program_assignments.asset_id}
      and  current_date >= ${payout_program_assignments.start_date}
      and current_date <= coalesce(${payout_program_assignments.end_date}, '2099-12-31') ;;
  }

  join: payout_programs {
    type: left_outer
    relationship: many_to_one
    sql_on: ${payout_programs.payout_program_id} = ${payout_program_assignments.payout_program_id} ;;
  }

  # Make sure company id is EquipmentShare branch (by joining to the xwalk table)

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
  }

  #ownership flag
  join: es_ownership_3_flags {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${es_ownership_3_flags.asset_id} ;;
  }

  # flex50 flag
  join: asset_warranty_xref {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_warranty_xref.asset_id}
            and coalesce(${work_orders.date_billed_date},${work_orders.date_completed_date},${work_orders.date_created_date}) <= coalesce(${asset_warranty_xref.date_deleted_date},current_date)
            and coalesce(${work_orders.date_billed_date},${work_orders.date_completed_date},${work_orders.date_created_date}) >= ${asset_warranty_xref.date_created_date}
            AND ${asset_warranty_xref.warranty_id} = 900 ;;
  }

  join: scd_asset_hours {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.asset_id} = ${scd_asset_hours.asset_id}
    AND ${work_orders.date_created_raw} >= ${scd_asset_hours.date_start_raw}
    AND ${work_orders.date_created_raw} <= ${scd_asset_hours.date_end_raw};;
  }

  join: scd_asset_inventory_status {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.asset_id} = ${scd_asset_inventory_status.asset_id}
          AND ${work_orders.date_created_raw} >= ${scd_asset_inventory_status.date_start_raw}
          AND ${work_orders.date_created_raw} <= ${scd_asset_inventory_status.date_end_raw};;
  }

  join: scd_asset_company {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${scd_asset_company.asset_id}
      AND ${work_orders.date_created_raw} >= ${scd_asset_company.date_start_raw}
      AND ${work_orders.date_created_raw} <= ${scd_asset_company.date_end_raw};;
  }

  join: owner_at_wo_creation {
    from: companies
    type: left_outer
    relationship: many_to_one
    sql_on: ${scd_asset_company.company_id} = ${owner_at_wo_creation.company_id} ;;
  }

  join: asset_ownership {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_ownership.asset_id} = ${work_orders.asset_id} ;;
  }
}
