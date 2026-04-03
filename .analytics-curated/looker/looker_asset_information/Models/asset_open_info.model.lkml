connection: "es_snowflake_analytics"

include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/asset_purchase_history.view.lkml"
include: "/views/ES_WAREHOUSE/asset_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/asset_types.view.lkml"
include: "/views/custom_sql/branch_rental_rates_wide.view.lkml"
include: "/views/ES_WAREHOUSE/categories.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes_models_xref.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_models.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/photos.view.lkml"
include: "/views/ES_WAREHOUSE/delivery_photos.view.lkml"
include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
include: "/views/custom_sql/asset_status_key_values_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"
include: "/views/ES_WAREHOUSE/locations.view.lkml"
include: "/views/ES_WAREHOUSE/states.view.lkml"
include: "/views/SCD/scd_asset_company.view.lkml"
include: "/views/SCD/scd_asset_inventory_status.view.lkml"
include: "/views/ANALYTICS/asset_overage_hours.view.lkml"
include: "/views/ANALYTICS/credit_app_master_list.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/rateachievement_benchmark.view.lkml"
include: "/views/ANALYTICS/rateachievement_bookrate.view.lkml"
include: "/views/ANALYTICS/rateachievement_mktassignments.view.lkml"
include: "/views/custom_sql/parent_categories.view.lkml"
include: "/views/custom_sql/sub_categories.view.lkml"
include: "/views/custom_sql/asset_purchase_history_facts.view.lkml"
include: "/views/custom_sql/units_on_rent_rolling_90_days.view.lkml"
include: "/views/custom_sql/units_on_rent_by_class_rolling_90_days.view.lkml"
include: "/views/custom_sql/market_class_inventory_status_count.view.lkml"
include: "/views/custom_sql/photos_organized.view.lkml"
include: "/views/custom_sql/scd_asset_hours_consolidated.view.lkml"
include: "/views/custom_sql/market_inventory_information.view.lkml"
include: "/views/custom_sql/region_inventory_information.view.lkml"
include: "/views/custom_sql/flex_contractor_payouts.view.lkml"
include: "/views/ANALYTICS/plus_payout_output.view.lkml"
include: "/views/ANALYTICS/flex_payout_output.view.lkml"
include: "/views/ANALYTICS/tracker_billing_output.view.lkml"
include: "/views/custom_sql/customer_activity_feed.view.lkml"
include: "/views/ANALYTICS/asset_nbv.view.lkml"
include: "/views/ANALYTICS/asset_nbv_all_owners.view.lkml"
include: "/views/ANALYTICS/asset_rpp.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ANALYTICS/historical_utilization.view.lkml"
include: "/views/ANALYTICS/greensill_class_mapping.view.lkml"
include: "/views/ANALYTICS/financial_utilization.view.lkml"
include: "/views/custom_sql/underperforming_assets.view.lkml"
include: "/views/ES_WAREHOUSE/company_keypad_codes.view.lkml"
include: "/views/ES_WAREHOUSE/keypad_codes.view.lkml"
include: "/views/custom_sql/last_complete_delivery.view.lkml"
include: "/views/ES_WAREHOUSE/company_purchase_orders.view.lkml"
include: "/views/ES_WAREHOUSE/company_purchase_order_line_items.view.lkml"
include: "/views/ANALYTICS/tool_trailer_v_asset_rental.view.lkml"
include: "/views/ANALYTICS/tool_trailer_v_part_rental.view.lkml"
include: "/views/ANALYTICS/tool_trailer_v_assets_on_rent.view.lkml"
include: "/views/custom_sql/tool_trailer_user_based_matching.view.lkml"
include: "/views/ANALYTICS/v_asset_rental_raw_data.view.lkml"
include: "/views/ANALYTICS/v_part_rental_raw_data.view.lkml"
include: "/views/custom_sql/v_out_of_lock.view.lkml"
include: "/views/ANALYTICS/v_asset_billing.view.lkml"
include: "/views/ANALYTICS/v_part_billing.view.lkml"
include: "/views/custom_sql/consumables.view.lkml"
include: "/views/ANALYTICS/used_equipment_sales_price_exceptions.view.lkml"
include: "/views/custom_sql/order_salespersons_pivot.view.lkml"
include: "/views/ANALYTICS/sales_track_logins.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ANALYTICS/utilization_rankings.view.lkml"
include: "/views/ES_WAREHOUSE/branch_rental_rates.view.lkml"
include: "/views/ANALYTICS/rateachievement_points.view.lkml"
include: "/views/ES_WAREHOUSE/assets_extended.view.lkml"
include: "/views/ANALYTICS/wo_updates.view.lkml"
include: "/views/custom_sql/asset_location.view.lkml"
include: "/views/custom_sql/asset_yard_distance.view.lkml"
include: "/views/ES_WAREHOUSE/contracts.view.lkml"
include: "/views/ES_WAREHOUSE/rental_statuses.view.lkml"
include: "/views/ANALYTICS/asset_rental.view.lkml"
include: "/views/custom_sql/fleet_track_allocations.view.lkml"
include: "/views/ES_WAREHOUSE/rentals_rates_refresh.view.lkml"
include: "/views/ANALYTICS/payout_program_schedule_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/payout_program_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/payout_programs.view.lkml"
include: "/views/ANALYTICS/asset_physical.view.lkml"
include: "/views/ANALYTICS/v_line_items.view.lkml"
include: "/views/custom_sql/bulk_rentals.view.lkml"
include: "/views/custom_sql/market_class_on_rent_rates.view.lkml"
include: "/views/BASE/assets_aggregate_base.view.lkml"
include: "/views/BASE/rentals_base.view.lkml"
include: "/views/BASE/rental_types_base.view.lkml"
include: "/views/ANALYTICS/mobile_tool_rental_logs.view.lkml"
include: "/views/ANALYTICS/asset_delivery_date.view.lkml"
include: "/views/ANALYTICS/asset_ownership.view"
include: "/views/ANALYTICS/INTACCT/company_to_sage_vendor_xwalk.view.lkml"
include: "/views/ANALYTICS/INTACCT_MODELS/src_intacct__vendor.view.lkml"
include: "/views/DATA_SCIENCE/all_equipment_rouse_estimates.view.lkml"
include: "/views/custom_sql/asset_utilization_ratio.view.lkml"
include: "/views/ES_WAREHOUSE/asset_odometer.view.lkml"
include: "/views/asset_details.view.lkml"
include: "/views/custom_sql/3c_clusters.view.lkml"
include: "/views/PLATFORM/v_assets.view.lkml"
include: "/views/custom_sql/abs_assets.view.lkml"
include: "/views/custom_sql/period_list_for_abs_assets.view.lkml"
include: "/views/asset_transfer_status.view.lkml"
include: "/views/ANALYTICS/ASSETS/int_assets.view.lkml"
include: "/views/custom_sql/es_asset_inventory_status.view.lkml"
include: "/views/custom_sql/asset_inventory_order_count.view.lkml"
include: "/views/PLATFORM/v_markets.view.lkml"
include: "/views/BUSINESS_INTELLIGENCE/stg_t3__rental_status_info.view.lkml"
include: "/views/FLEET_OPTIMIZATION/v_branch_rates_current_active.view.lkml"
include: "/views/PLATFORM/v_invoices.view.lkml"

explore: assets_inventory {
  from: assets
  label: "Inventory Information - No RR - Open Access"
  group_label: "Asset Information"
  case_sensitive: no
  sql_always_where:
        ((${assets_inventory.company_id} <> 11606 and
     LEFT(${assets_inventory.serial_number}, 2) <> 'RR' and
     LEFT(${assets_inventory.custom_name}, 2) <> 'RR') or
          ${serial_number} is null);;
  persist_for: "1 minute"

  # removed claause in sql_always_where: and (${assets_extended.include_asset} or ${assets_extended.include_asset} is null) - BES 2022-06-30

  # Pulls most recent update from most recent WO for each asset. Jack G 7/6/22
  join: last_wo_update {
    from: wo_updates
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_inventory.asset_id} = ${last_wo_update.asset_id} and
            ${last_wo_update.wo_update_num} = 1 and
            ${last_wo_update.asset_sequence_num} = 1 ;;
  }

  # Replacing last_wo_update - SQL table already filters for most recent Tyler B
  join: wo_updates_latest {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_inventory.asset_id} = ${wo_updates_latest.asset_id} ;;
  }

  join: 3c_clusters {
    type: left_outer
    relationship: one_to_many
    sql_on: ${wo_updates_latest.work_order_id} = ${3c_clusters.work_order_id} ;;
  }

  join: asset_location {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_inventory.asset_id} = ${asset_location.asset_id} ;;
  }

  join: asset_rental {
    type: inner
    relationship: one_to_one
    sql_on: ${assets_inventory.asset_id} = ${asset_rental.asset_id} ;;
  }

  join: asset_ownership {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${asset_ownership.asset_id} ;;
  }

  join: asset_physical {
    type: inner
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_physical.asset_id} ;;
  }

  join: markets {
    view_label: "Asset Market"
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${assets_inventory.rental_branch_id},${assets_inventory.inventory_branch_id})=${markets.market_id} ;;
  }

  join: financial_utilization {
    type: left_outer
    relationship: one_to_one
    sql_on: ${financial_utilization.asset_id} = ${assets.asset_id} and ${assets_inventory.rental_branch_id} = ${financial_utilization.rental_branch_id};;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets_inventory.asset_id}=${assets.asset_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets_inventory.asset_id}=${assets_aggregate.asset_id} ;;
  }

  join: photos_organized {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets_inventory.asset_id}=${photos_organized.asset_id} ;;
  }

  join: scd_asset_hours_consolidated {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_inventory.asset_id}=${scd_asset_hours_consolidated.asset_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_inventory.company_id}=${companies.company_id} ;;
  }

  join: company_purchase_order_line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${markets.market_id} = ${company_purchase_order_line_items.market_id}
      AND ${equipment_classes.equipment_class_id} = ${company_purchase_order_line_items.equipment_class_id};;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_inventory.asset_id}=${asset_purchase_history.asset_id} ;;
  }

  join: company_purchase_orders {
    type:  left_outer
    relationship: one_to_one
    sql_on:  ${company_purchase_order_line_items.company_purchase_order_id} = ${company_purchase_orders.company_purchase_order_id} ;;
  }

  join: company_to_sage_vendor_xwalk {
    type:  inner
    relationship: one_to_one
    sql_on:  ${company_purchase_orders.vendor_id} = ${company_to_sage_vendor_xwalk.company_id} ;;
  }

  join: src_intacct__vendor {
    type:  inner
    relationship: one_to_one
    sql_on:  ${src_intacct__vendor.vendor_id} = ${company_to_sage_vendor_xwalk.vendorid} ;;
  }

  join: equipment_models {
    type: left_outer
    relationship: many_to_many
    sql_on: ${equipment_models.equipment_model_id} = ${assets_inventory.equipment_model_id} ;;
  }

  join: equipment_classes_models_xref {
    type: left_outer
    relationship: many_to_many
    sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${equipment_classes_models_xref.equipment_class_id}=${equipment_classes.equipment_class_id} ;;
  }

  join: parent_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sub_categories.parent_category_id} = ${parent_categories.category_id} AND ${sub_categories.category_id} = ${equipment_classes.category_id} ;;
  }

  join: sub_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_classes.category_id} = ${sub_categories.category_id} ;;
  }

  join: asset_purchase_history_facts_final {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_purchase_history_facts_final.asset_id} = ${assets_inventory.asset_id} ;;
  }

  join: deliveries {
    type: left_outer
    relationship: one_to_many
    sql_on: ${deliveries.order_id} = ${orders.order_id} and ${deliveries.asset_id} = ${assets.asset_id};;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: units_on_rent_rolling_90_days {
    type: left_outer
    relationship: many_to_one
    sql_on: ${units_on_rent_rolling_90_days.market_name} = ${markets.name} ;;
  }

  join: rateachievement_benchmark {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rateachievement_benchmark.equipment_class_id} = ${equipment_classes.equipment_class_id}::TEXT
      AND ${rateachievement_benchmark.market_id} =${market_region_xwalk.market_id};;
  }

  join: rateachievement_bookrate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rateachievement_bookrate.equipment_class_id} = ${equipment_classes.equipment_class_id}::TEXT
      AND ${rateachievement_bookrate.market_id} = ${market_region_xwalk.market_id};;
  }

  join: rateachievement_points {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rateachievement_points.asset_id} = ${assets.asset_id};;
  }

  join: branch_rental_rates_wide {
    view_label: "Branch Rental Rates Wide"
    type: left_outer
    relationship: one_to_many
    sql_on:  ${equipment_classes.equipment_class_id}::TEXT = ${branch_rental_rates_wide.equipment_class_id} AND
      ${branch_rental_rates_wide.branch_id} = ${market_region_xwalk.market_id};;
  }
  join: branch_rental_rates {
    relationship: one_to_many
    sql_on:  ${equipment_classes.equipment_class_id}::TEXT = ${branch_rental_rates.equipment_class_id} AND
      ${branch_rental_rates.branch_id} = ${market_region_xwalk.market_id};;
  }
  join: rentals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.asset_id} = ${assets_inventory.asset_id} ;;
  }

  join: orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.order_id} = ${rentals.order_id} ;;
  }

  join: contracts {
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.order_id} = ${contracts.order_id} ;;
  }

  join: order_salespersons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_salespersons.order_id} = ${orders.order_id} ;;
  }

  join: users {
    view_label: "Sales Reps"
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = coalesce(${order_salespersons.user_id},${orders.salesperson_user_id}) ;;
  }

  join: customer_user {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.user_id} = ${customer_user.user_id} ;;
  }

  join: customer_company {
    view_label: "Customer"
    from: companies
    type: left_outer
    relationship: many_to_one
    sql_on: ${customer_user.company_id} = ${customer_company.company_id} ;;
  }

  join: order_market {
    from: market_region_xwalk
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${line_items.branch_id}, ${orders.market_id}) = ${order_market.market_id} ;;
  }

  join: scd_asset_inventory_status {
    type: left_outer
    relationship: many_to_one
    sql_on: ${scd_asset_inventory_status.asset_id} = ${assets_inventory.asset_id} ;;
  }

  # Joining this in so that I can fix the assets_aggregate measures for days in hard/soft down statuses.
  # Going to asset_status_key_values is not the right way to do it because the inventory status
  # gets updated when a work order is created. -Jack G 11/14/22
  join: current_inventory_status {
    from: scd_asset_inventory_status
    type: inner
    relationship: one_to_one
    sql_on: ${assets_inventory.asset_id} = ${current_inventory_status.asset_id} and ${current_inventory_status.current_flag} = 1 ;;
  }

  # Add join to markets for rsp specifically - Britt Shanklin 6.30.2022
  join: rental_market {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_market.market_id} = ${assets_inventory.rental_branch_id} ;;
  }

  join: service_market {
    from: markets
    type:  left_outer
    relationship:many_to_one
    sql_on:  ${service_market.market_id} = ${assets_inventory.service_branch_id} ;;
  }

  join: customer_activity_feed {
    type:  left_outer
    relationship:one_to_many
    sql_on:  ${assets_inventory.asset_id} = ${customer_activity_feed.asset_id} ;;
  }

  join: last_complete_delivery {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${last_complete_delivery.asset_id} = ${assets.asset_id} ;;
  }

  join: last_rental_details {
    from: rentals
    type: left_outer
    relationship: one_to_one
    sql_on: ${last_complete_delivery.rental_id} = ${last_rental_details.rental_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: one_to_one
    sql_on: ${orders.order_id} = ${invoices.order_id} ;;
  }

  join: line_items {
    type: inner
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: asset_line_items {
    from: v_line_items
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${asset_line_items.asset_id} ;;
  }

  join: asset_line_item_market {
    from: market_region_xwalk
    relationship: many_to_one
    sql_on: ${asset_line_items.branch_id} = ${asset_line_item_market.market_id} ;;
  }

  join: bulk_rentals {
    type: left_outer
    relationship: one_to_many
    sql_on: ${bulk_rentals.order_id} = ${orders.order_id} and ${bulk_rentals.is_bulk};;
  }

  join: most_recent_rental {
    from: rentals
    type: left_outer
    relationship: one_to_one
    sql_on: ${most_recent_rental.rental_id} = ${asset_rental.last_rental_id} and ${asset_rental.last_rental_id} is not null;;
  }

  join: asset_delivery_date {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_inventory.asset_id} = ${asset_delivery_date.asset_id};;
  }

  join: asset_transfer_status {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id}=${asset_transfer_status.asset_id} ;;
  }
}



# Commented out — 0 queries in 90 days, no dashboard or Look ties
#Asset Information - Inventory Information with Open Access
# explore: assets_inventory_with_open_access {
#   from: assets
#   label: "Inventory Information with Open Access"
#   group_label: "Asset Information"
#   case_sensitive: no
#
#   join: assets_aggregate {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${assets_inventory_with_open_access.asset_id} = ${assets_aggregate.asset_id} ;;
#   }
#
#   join: companies {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${assets_aggregate.company_id} = ${companies.company_id} ;;
#   }
#
#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: coalesce(${assets_inventory_with_open_access.rental_branch_id},${assets_inventory_with_open_access.inventory_branch_id})=${markets.market_id} ;;
#   }
#
#   join: asset_status_key_values {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${asset_status_key_values.asset_id} = ${assets_inventory_with_open_access.asset_id} ;;
#   }
#
#   join: asset_purchase_history {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${assets_inventory_with_open_access.asset_id}=${asset_purchase_history.asset_id} ;;
#   }
#
#   join: equipment_models {
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${equipment_models.equipment_model_id} = ${assets_inventory_with_open_access.equipment_model_id} ;;
#   }
#
#   join: custom_categories {
#     from: categories
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets_inventory_with_open_access.category_id} = ${custom_categories.category_id} ;;
#   }
#
#   join: equipment_classes_models_xref {
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
#   }
#
#   join: equipment_classes {
#     type: left_outer
#     relationship: many_to_one
#     sql_on:  ${equipment_classes_models_xref.equipment_class_id}=${equipment_classes.equipment_class_id} ;;
#   }
#
#   join: assets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets_inventory_with_open_access.asset_id} = ${assets.asset_id}  ;;
#   }
#
#   join: parent_categories {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${sub_categories.category_id} = ${parent_categories.category_id} AND ${sub_categories.category_id} = ${equipment_classes.category_id} ;;
#   }
#
#   join: sub_categories {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${equipment_classes.category_id} = ${sub_categories.category_id} ;;
#   }
#
#   join: asset_purchase_history_facts_final {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${asset_purchase_history_facts_final.asset_id} = ${assets_inventory_with_open_access.asset_id} ;;
#   }
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#   }
#
#   join: units_on_rent_rolling_90_days {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${units_on_rent_rolling_90_days.market_name} = ${markets.name} ;;
#   }
#
#   join: rateachievement_benchmark {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${rateachievement_benchmark.equipment_class_id} = ${equipment_classes.equipment_class_id}::TEXT
#       AND ${rateachievement_benchmark.market_id} =${market_region_xwalk.market_id};;
#   }
#
#   join: rateachievement_bookrate {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${rateachievement_bookrate.equipment_class_id} = ${equipment_classes.equipment_class_id}::TEXT
#       AND ${rateachievement_bookrate.market_id} = ${market_region_xwalk.market_id};;
#   }
#
#   join: rentals {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${rentals.asset_id} = ${assets_inventory_with_open_access.asset_id} ;;
#   }
#
#   join: orders {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders.order_id} = ${rentals.order_id} ;;
#   }
#
#   join: order_salespersons {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders.order_id} = ${order_salespersons.order_id} ;;
#   }
#
#   join: users {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${users.user_id} = coalesce(${order_salespersons.user_id},${orders.salesperson_user_id}) ;;
#   }
#
#   join: asset_types {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id};;
#   }
#
#   join: scd_asset_inventory_status {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${scd_asset_inventory_status.asset_id} = ${assets.asset_id} ;;
#   }
#
# }

explore: companies {
  label: "Company keypads"
  case_sensitive: no

  join: company_keypad_codes {
    type: inner
    relationship: one_to_many
    sql_on: ${companies.company_id} = ${company_keypad_codes.company_id} ;;
  }

  join: keypad_codes {
    type: inner
    relationship: one_to_one
    sql_on: ${company_keypad_codes.keypad_code_id} = ${keypad_codes.keypad_code_id} ;;
  }
}

explore: asset_inventory_order_count {
  group_label: "Asset Information"
  case_sensitive: no
  }

explore: market_class_inventory_status_count {
  group_label: "Asset Information"
  label: "Asset Status Count for Each Market and Class"
  case_sensitive: no

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${market_class_inventory_status_count.market_id} ;;
  }

  join: parent_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sub_categories.parent_category_id} = ${parent_categories.category_id} AND ${sub_categories.category_id} = ${market_class_inventory_status_count.category_id} ;;
  }

  join: sub_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_class_inventory_status_count.category_id} = ${sub_categories.category_id} ;;
  }

  join: financial_utilization {
    type: left_outer
    relationship: one_to_many
    sql_on: ${market_class_inventory_status_count.class_name} = ${financial_utilization.class}
      and ${market_class_inventory_status_count.market_id} = ${financial_utilization.rental_branch_id};;
  }

  join: market_class_on_rent_rates{
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_class_inventory_status_count.market_id} = ${market_class_on_rent_rates.market_id}
      and ${market_class_inventory_status_count.class_name} = ${market_class_on_rent_rates.class_name};;
  }

  join: asset_transfer_status {
    type:  left_outer
    relationship: one_to_one
    sql_on:  ${financial_utilization.asset_id} = ${asset_transfer_status.asset_id} ;;
  }
}

#MB commented out 5/23/24 explore returned unused or tied to old dashboard
#Asset Information - Summarized Asset Information by Market
# explore: market_inventory_information {
#   label: "Summarized Asset Information by Market"
#   group_label: "Asset Information"
# }

#Asset Information - Summarized Asset Information by Region
# explore: region_inventory_information {
#   label: "Summarized Asset Information by Region"
#   group_label: "Asset Information"

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${region_inventory_information.market_id} = ${market_region_xwalk.market_id} ;;
#   }

#   join: credit_app_master_list {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${market_region_xwalk.market_id} = ${credit_app_master_list.market_id} ;;
#   }

#   join: users {
#     sql_table_name: ES_WAREHOUSE.PUBLIC.users ;;
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${users.user_id} = ${credit_app_master_list.salesperson_user_id} ;;
#   }
# }

#Asset Information - Units on Rent With Open Access
explore: orders_open {
  from: orders
  group_label: "Asset Information"
  label: "Units on Rent Information Open Access"
  case_sensitive: no
  sql_always_where: ((SUBSTR(TRIM(${assets.serial_number}), 1, 3) != 'RR-' and SUBSTR(TRIM(${assets.serial_number}), 1, 2) != 'RR') or ${assets.serial_number} is null) ;;

  join: order_salespersons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders_open.order_id} = ${order_salespersons.order_id} ;;
  }

  join: rentals {
    type: inner
    relationship: many_to_one
    sql_on: ${rentals.order_id} = ${orders_open.order_id} ;;
  }

  join: equipment_assignments {
    type: inner
    relationship: many_to_one
    sql_on: ${equipment_assignments.rental_id} = ${rentals.rental_id} ;;
  }

  join: assets  {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${equipment_assignments.asset_id} ;;
  }

  join: assets_aggregate {
    type: inner
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_purchase_history.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_purchase_history_facts_final {
    type:  left_outer
    relationship:  one_to_one
    sql_on: ${assets.asset_id} = ${asset_purchase_history_facts_final.asset_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${order_salespersons.user_id},${orders_open.salesperson_user_id}) = ${users.user_id} ;;
  }

  join: requested_by_user {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${requested_by_user.user_id} = ${orders_open.user_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${orders_open.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
  }

  join: customer {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders_open.user_id} = ${customer.user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${customer.company_id} = ${companies.company_id} ;;
  }

  join: sales_track_logins {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${sales_track_logins.company_id} ;;
  }

  join: historical_utilization  {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${historical_utilization.asset_id} ;;
  }

  join: last_complete_delivery {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${last_complete_delivery.order_id} = ${orders_open.order_id} and ${assets.asset_id} = ${last_complete_delivery.asset_id};;
  }

  join: locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${last_complete_delivery.location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: many_to_one
    sql_on: ${states.state_id} = ${locations.state_id} ;;
  }

  join: order_salespersons_pivot {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.order_id} = ${order_salespersons_pivot.order_id} ;;
  }
}

#Asset Information - Units on Re-Rent With Open Access
explore: orders_rerent_open {
  from: orders
  group_label: "Asset Information"
  label: "Units on Re-Rent Information Open Access"
  case_sensitive: no
  sql_always_where: (SUBSTR(TRIM(${assets.serial_number}), 1, 3) = 'RR-' and SUBSTR(TRIM(${assets.serial_number}), 1, 2) = 'RR' OR ${assets.serial_number} IS NULL) ;;

  join: order_salespersons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders_rerent_open.order_id} = ${order_salespersons.order_id} ;;
  }

  join: rentals {
    type: inner
    relationship: many_to_one
    sql_on: ${rentals.order_id} = ${orders_rerent_open.order_id} ;;
  }

  join: equipment_assignments {
    type: inner
    relationship: many_to_one
    sql_on: ${equipment_assignments.rental_id} = ${rentals.rental_id} ;;
  }

  join: assets  {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${equipment_assignments.asset_id} ;;
  }

  # join: asset_statuses {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${assets.asset_id}=${asset_statuses.asset_id} ;;
  # }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_purchase_history.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_purchase_history_facts_final {
    type:  left_outer
    relationship:  one_to_one
    sql_on: ${assets.asset_id} = ${asset_purchase_history_facts_final.asset_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${order_salespersons.user_id},${orders_rerent_open.salesperson_user_id}) = ${users.user_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${orders_rerent_open.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
  }

  join: customer {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders_rerent_open.user_id} = ${customer.user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${customer.company_id} = ${companies.company_id} ;;
  }

  join: asset_company {
    from: companies
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_company.company_id} = ${assets.company_id} ;;
  }

  # join: net_terms {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  # }

  # join: market_region_salesperson {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  # }

  join: equipment_models {
    type: left_outer
    relationship: many_to_many
    sql_on: ${equipment_models.equipment_model_id} = ${assets.equipment_model_id} ;;
  }

  join: equipment_classes_models_xref {
    type: left_outer
    relationship: many_to_many
    sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${equipment_classes.equipment_class_id} = ${equipment_classes_models_xref.equipment_class_id} ;;
  }

}

# explore: asset_overage_hours { --MB comment out 10-10-23 due to inactivity
#   label: "Asset Overage Hours"
#   group_label: "Asset Information"
#   case_sensitive: no

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${asset_overage_hours.market_id} = ${market_region_xwalk.market_id};;
#   }
# }

# explore: flex_contractor_payouts {} --MB comment out 10-10-23 due to inactivity

explore: plus_payout_output{
  group_label: "Program Payout"
}

explore: flex_payout_output{
  group_label: "Program Payout"
  case_sensitive: no
  join: payout_program_schedule_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${flex_payout_output.asset_id} = ${payout_program_schedule_assignments.asset_id} ;;
  }

  join: payout_program_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${flex_payout_output.asset_id} = ${payout_program_assignments.asset_id}
      and (${flex_payout_output.dte_date} between ${payout_program_assignments.start_date} and coalesce(${payout_program_assignments.end_date}, '2099-01-01')) ;;
  }

  join: payout_programs {
    type: left_outer
    relationship: one_to_one
    sql_on: ${payout_program_assignments.payout_program_id} = ${payout_programs.payout_program_id} ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${flex_payout_output.asset_id}=${asset_purchase_history.asset_id} ;;
  }
}

explore: tracker_billing_output {
  group_label: "Program Payout"
  case_sensitive: no
}


explore: asset_replacement_value {
  from: asset_nbv
  label: "Asset Replacement Value"
  group_label: "Asset Information"
  case_sensitive: no

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_nbv_all_owners.market_id} = ${market_region_xwalk.market_id}  ;;
  }

  join: asset_physical {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_replacement_value.asset_id} = ${asset_physical.asset_id} ;;
  }

  join: asset_utilization_ratio {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_replacement_value.asset_id} = ${asset_utilization_ratio.asset_id}  ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_replacement_value.market_id} = ${markets.market_id}  ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_replacement_value.asset_id}=${asset_purchase_history.asset_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_replacement_value.asset_id} = ${assets.asset_id}  ;;
  }

  join: FSID {
    from: asset_purchase_history
    relationship: one_to_one
    sql_on: ${asset_nbv_all_owners.asset_id} = ${FSID.asset_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_replacement_value.asset_id} = ${asset_status_key_values.asset_id};;
  }

  join: asset_rpp {
    type: full_outer
    relationship: one_to_one
    sql_on: ${asset_replacement_value.asset_id} = ${asset_rpp.asset_id}  ;;
  }

  join: asset_nbv_all_owners {
    type: full_outer
    relationship: one_to_one
    sql_on: ${asset_replacement_value.asset_id} = ${asset_nbv_all_owners.asset_id}  ;;
  }

  # I'm re-joining assets back in because the original join doesn't always end up with a value for every asset b/c of custom sql
  join: assets_on_asset_nbv_all_owners{
    from: assets
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_replacement_value.asset_id} = ${assets_on_asset_nbv_all_owners.asset_id}  ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_nbv_all_owners.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: company_purchase_order_line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets_aggregate.asset_id} = ${company_purchase_order_line_items.asset_id} ;;
  }

  join: company_purchase_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_line_items.company_purchase_order_id} = ${company_purchase_orders.company_purchase_order_id};;
  }

  join: vendors {
    from: companies
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_orders.vendor_id} = ${vendors.company_id} ;;
  }

  join: greensill_class_mapping {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets_aggregate.equipment_class_id} = ${greensill_class_mapping.equipment_class_id} ;;
  }

  join: used_equipment_sales_price_exceptions {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_replacement_value.asset_id} = ${used_equipment_sales_price_exceptions.asset_id}  ;;
  }

  join: rentals {
    type: left_outer
    relationship: one_to_many
    sql_on: ${asset_replacement_value.asset_id}=${rentals.asset_id} ;;
  }

  join: equipment_assignments {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets_aggregate.asset_id} = ${equipment_assignments.asset_id} ;;
  }

  join: orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.order_id}=${rentals.order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: one_to_one
    sql_on: ${orders.salesperson_user_id}=${users.user_id} ;;
  }

  join: asset_ownership {
    type: left_outer
    relationship: one_to_many
    sql_on: ${asset_nbv_all_owners.asset_id}=${asset_ownership.asset_id} ;;
  }

  join: all_equipment_rouse_estimates {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_nbv_all_owners.asset_id} = ${all_equipment_rouse_estimates.asset_id} ;;
  }

  join: asset_odometer {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_nbv_all_owners.asset_id} = ${asset_odometer.asset_id} ;;
  }
}

# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: asset_purchase_history_facts_final {
#   description: "Displays total unavailable OEC for assets that are Pending Return, Make Ready, Needs Inspection, Soft Down, and Hard down"
#   label: "Total Unavailable OEC"
#   case_sensitive: no
#   sql_always_where: ${asset_status_key_values.value} IN ('Pending Return','Make Ready','Needs Inspection', 'Soft Down','Hard Down') ;;
#
#   join: asset_status_key_values {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${asset_purchase_history_facts_final.asset_id} = ${asset_status_key_values.asset_id};;
#   }
#
#   join: asset_purchase_history {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${asset_purchase_history_facts_final.asset_id} = ${asset_purchase_history.asset_id} ;;
#   }
#
#   join: assets {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${asset_purchase_history_facts_final.asset_id} = ${assets.asset_id};;
#   }
#
#   join: markets {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${assets.rental_branch_id} = ${markets.market_id} ;;
#   }
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.rental_branch_id} = ${market_region_xwalk.market_id};;
#   }
# }
explore: underperforming_assets {
  description: "Displays list of assets that have not been rented in the last 90 days."
  label: "Under-performing Assets"
  case_sensitive: no

  # Commenting out because xwalk is now joined in at the underperforming_assets query itself -- KC 2/14/2024

  # join: market_region_xwalk {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${underperforming_assets.rental_branch_id} = ${market_region_xwalk.market_id} ;;
  # }

  # depreciated and commented 05/22/2025 - Don Hannant
  # join: asset_statuses {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${underperforming_assets.asset_id} = ${asset_statuses.asset_id} ;;
  # }

  join: v_assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_assets.asset_id} = ${assets.asset_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${underperforming_assets.asset_id} = ${assets.asset_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.company_id} = ${companies.company_id} ;;
  }

  # Leaving in the markets join because it's needed for a different view (I'm not specifically sure which one) -- KC 2/14/2024

  join: markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.rental_branch_id} = ${markets.market_id} ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id}=${asset_purchase_history.asset_id} ;;
  }

}

explore: asset_ownership_history {
  from: assets
  label: "Asset Ownership History"
  group_label: "Asset Information"

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${asset_ownership_history.rental_branch_id},${asset_ownership_history.inventory_branch_id})=${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${asset_ownership_history.rental_branch_id},${asset_ownership_history.inventory_branch_id}) = ${market_region_xwalk.market_id} ;;
  }

  join: scd_asset_company {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_ownership_history.asset_id}=${scd_asset_company.asset_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${scd_asset_company.company_id}=${companies.company_id} ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_ownership_history.asset_id}=${asset_purchase_history.asset_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_ownership_history.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: one_to_many
    sql_on: ${asset_ownership_history.asset_id} = ${asset_status_key_values.asset_id} ;;
  }
}

explore: tool_trailer_v_asset_rental {
  group_label: "Tool Trailer"
  case_sensitive: no
}

explore: tool_trailer_v_part_rental {
  group_label: "Tool Trailer"
  case_sensitive: no
}

explore: tool_trailer_v_assets_on_rent {
  group_label: "Tool Trailer"
  case_sensitive: no
}

# explore: tool_trailer_user_based_matching {} --MB comment out 10-10-23 due to inactivity

explore: v_asset_billing {
  group_label: "Tool Trailer"
  case_sensitive: no
}

explore: v_part_billing {
  group_label: "Tool Trailer"
  case_sensitive: no
}

explore: v_asset_rental_raw_data {
  group_label: "Tool Trailer"
  case_sensitive: no
}

explore: v_part_rental_raw_data {
  group_label: "Tool Trailer"
  case_sensitive: no
}

explore: consumables {
  group_label: "Tool Trailer"
  case_sensitive: no

  join: v_invoices {
    type: inner
    relationship: one_to_one
    sql_on: ${consumables.invoice_id} = ${v_invoices.invoice_id} ;;
  }
}

# explore: v_out_of_lock {}

explore: user_info {
  from: users

  join: companies {
    type: inner
    relationship: many_to_one
    sql_on: ${user_info.company_id} = ${companies.company_id} ;;
  }
}
# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: utilization_rankings {
#   case_sensitive: no
#   always_join: [market_region_xwalk]
#
#   join: market_region_xwalk {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${utilization_rankings.market_id} = ${market_region_xwalk.market_id} ;;
#   }
# }

# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: market_region_xwalk {
#   from: market_region_xwalk
#   description: "Explore for fleet team to assign assets to markets"
#   label: "Asset Allocations"
#   case_sensitive: no
#
#   join: asset_status_key_values_aggregate {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${market_region_xwalk.market_id} = ${asset_status_key_values_aggregate.market_id};;
#   }
#
#   join: fleet_track_allocations {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${fleet_track_allocations.market_id} = ${asset_status_key_values_aggregate.market_id} and
#       ${fleet_track_allocations.equipment_class_id} = ${asset_status_key_values_aggregate.equipment_class_id};;
#   }
#
#   join: rateachievement_points {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${rateachievement_points.equipment_class_id} = ${asset_status_key_values_aggregate.equipment_class_id} and
#       ${rateachievement_points.market_id} = ${asset_status_key_values_aggregate.market_id};;
#     fields: [true_price_per_month]
#   }
#
#   join: equipment_classes {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${fleet_track_allocations.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
#   }
# }

# explore: asset_yard_distance {
# }

explore: overdue_rentals {
  from: orders
  case_sensitive: no
  sql_always_where: ${rental_statuses.name} = 'On Rent' ;;
  # fields: [ALL_FIELDS*,
  #   -rentals.market_rentals_below_floor,
  #   -rentals.rentals_below_floor]

  join: rentals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${overdue_rentals.order_id} = ${rentals.order_id} ;;
  }

  join: bulk_rentals {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.order_id} = ${bulk_rentals.order_id} ;;
  }

  join: rental_statuses {
    type: inner
    relationship: one_to_one
    sql_on: ${rentals.rental_status_id} = ${rental_statuses.rental_status_id} ;;
  }

  join: markets{
    type: left_outer
    relationship: one_to_many
    sql_on: ${overdue_rentals.market_id} = ${markets.market_id}  ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: assets_aggregate {
    type: inner
    relationship: many_to_one
    sql_on: ${rentals.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets_aggregate.asset_id} = ${asset_status_key_values.asset_id} ;;
  }

  #joining with field needed for links in rental view to resolve warning due to changes from Looker in liquid parsing
  join: users {
    fields: [users.Full_Name_with_ID]
    type: left_outer
    relationship: many_to_one
    sql_on: ${overdue_rentals.salesperson_user_id} = ${users.user_id} ;;
  }
}

explore: tool_trailer_rental {
  from: orders
  group_label: "Tool Trailers"
  label: "Tool Trailer Rental Information"
  case_sensitive: no

  join: rentals_base {
    type: left_outer
    relationship: one_to_many
    sql_on: ${tool_trailer_rental.order_id} = ${rentals_base.order_id};;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tool_trailer_rental.market_id} = ${markets.market_id} ;;
  }

  join: user_customers {
    from: users
    relationship: many_to_one
    sql_on: ${tool_trailer_rental.user_id} = ${user_customers.user_id};;
  }

  join: company_customers {
    from: companies
    relationship: many_to_one
    sql_on: ${user_customers.company_id} = ${company_customers.company_id} ;;
  }

  join: assets_aggregate_base {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals_base.asset_id} = ${assets_aggregate_base.asset_id};;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets_aggregate_base.asset_id} = ${asset_status_key_values.asset_id};;
  }

  join: rental_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals_base.rental_type_id} = ${rental_types.rental_type_id} ;;
  }
}

explore: mobile_tool_rental_logs {
  group_label: "Tool Trailers"
  label: "Tool Trailer Rental Logs"
  case_sensitive: no
}

explore: asset_details {
  from: asset_details
  group_label: "Asset Details"
  label: "Asset Details"
  case_sensitive: no
  join: assets {
    type: left_outer
    relationship: one_to_many
    sql_on: ${asset_details.asset_id} = ${assets.asset_id};;
  }
  join: asset_status_key_values {
    type: left_outer
    relationship: one_to_many
    sql_on: ${asset_details.asset_id} = ${asset_status_key_values.asset_id};;
  }
  join: rentals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_details.asset_id} = ${rentals.asset_id} ;;
  }
  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.rental_branch_id} = ${markets.market_id} ;;
  }
  join: asset_purchase_history {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_details.asset_id} = ${asset_purchase_history.asset_id} ;;
  }
  join: deliveries {
    type: left_outer
    relationship: one_to_many
    sql_on: ${asset_details.asset_id} = ${deliveries.asset_id} ;;
  }
  join: delivery_photos {
    type: left_outer
    relationship: one_to_many
    sql_on: ${deliveries.delivery_id} = ${delivery_photos.delivery_id} ;;
  }
  join: photos {
    type: left_outer
    relationship: one_to_many
    sql_on: ${delivery_photos.photo_id} = ${photos.photo_id} ;;
  }
  join: companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.company_id}=${companies.company_id} ;;
  }
  join: asset_transfer_status {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id}=${asset_transfer_status.asset_id} AND ${asset_transfer_status.row_num} = 1   ;;
  }
}

# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: abs_assets {
#   from: abs_assets
#   label: "ABS Assets"
#
#   join: period_list_for_abs_assets {
#     type: inner
#     relationship: one_to_one
#     sql_on: ${abs_assets.period_date} = ${period_list_for_abs_assets.period_date} ;;
#
#   }
# }

datagroup: inventory_info_askv {
  sql_trigger: select max(_es_update_timestamp) from es_warehouse.public.asset_status_key_values ;;
  max_cache_age: "1 hour"
  description: "Looking at es_warehouse.public.asset_status_key_values to get most recent update."
}


explore: int_assets {
  group_label: "Assets"
  label: "Assets with Markets and Inventory Information"
  description: "Powering Inventroy Information"
  sql_always_where: ${is_managed_by_es_owned_market} = TRUE AND ${is_rerent_asset} = FALSE AND ${rental_branch_id} is not null ;;
  case_sensitive: no
  persist_with: inventory_info_askv

  join: es_asset_inventory_status {
    type: inner
    relationship: one_to_one
    sql_on: ${int_assets.asset_id} = ${es_asset_inventory_status.asset_id} ;;
  }

  join: v_branch_rates_current_active {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_branch_rates_current_active.equipment_class_id} = ${int_assets.equipment_class_id} AND ${v_branch_rates_current_active.branch_id} = ${int_assets.market_id} ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${int_assets.rental_branch_id} = ${market_region_xwalk.market_id} ;;
  }
}

explore: stg_t3__rental_status_info {
  label: "Rental Info Triage"
  sql_always_where: ${v_markets.market_abbreviation} LIKE('MTT%') ;;

  join: v_markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${stg_t3__rental_status_info.market_id} = ${v_markets.market_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${stg_t3__rental_status_info.company_id} = ${companies.company_id} ;;
  }

  join: v_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${stg_t3__rental_status_info.asset_id} = ${v_assets.asset_id} ;;
  }
  join: rentals {
    type:  inner
    relationship: one_to_one
    sql_on: ${stg_t3__rental_status_info.rental_id} = ${rentals.rental_id} ;;
  }
  join: orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.order_id} = ${orders.order_id} ;;
  }
  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.user_id} = ${users.user_id} ;;
  }
  join: rental_statuses {
    type: inner
    relationship: one_to_one
    sql_on: ${rentals.rental_status_id} = ${rental_statuses.rental_status_id} ;;
  }

}
