connection: "es_snowflake"

include: "/views/company_purchase_order_line_items.view.lkml"
include: "/views/company_purchase_orders.view.lkml"
include: "/views/company_purchase_order_types.view.lkml"
include: "/views/deliveries.view"
include: "/views/vendors.view.lkml"
include: "/views/equipment_models.view.lkml"
include: "/views/equipment_makes.view.lkml"
include: "/views/equipment_classes_models_xref.view.lkml"
include: "/views/equipment_classes.view.lkml"
include: "/views/assets.view"
include: "/views/markets.view"
include: "/views/markets_public_rsps.view"
include: "/views/tracking_events_fix.view"
include: "/views/tracking_incidents.view"
include: "/views/trips.view"
include: "/views/market_region_xwalk.view"
include: "/views/master_vehicle_and_trailer_db.view"
include: "/views/users.view"
include: "/views/scd_asset_driver.view"
include: "/views/scd_asset_inventory_status.view"
include: "/views/scd_asset_msp.view"
include: "/views/scd_asset_rsp.view"
include: "/views/users.view"
# include: "/views/asset_statuses.view"
include: "/views/asset_purchase_history.view"
include: "/views/rentals.view"
include: "/views/payout_program_assignments.view"
include: "/views/payout_programs.view"
include: "/views/command_audit.view"
include: "/views/asset_types.view"
include: "/views/asset_nbv_all_owners.view"
include: "/views/*.view.lkml"
include: "24_hour_tracker_unplug_monitor.view"
include: "asset_moved_off_yard_past_48hours.view"
include: "/views/custom_sql/retail_invoice_asset_credits.view.lkml"
include: "/views/custom_sql/service_invoice_asset_credits.view.lkml"
include: "/views/v_payout_programs.view.lkml"
include: "/views/asset_physical.view.lkml"
include: "/views/business_segments.view.lkml"
include: "/views/custom_sql/vendor_reimbursements.view.lkml"
include: "/views/custom_sql/vendor_reimbursement_accrual.view.lkml"
include: "/views/assets_by_market.view.lkml"
include: "/views/custom_sql/rpo_equipment_revenue.view.lkml"
include: "/views/locations.view"
include: "/views/v_assets.view"
include: "/views/custom_sql/asset_max_daily_hours.view.lkml"
include: "/views/custom_sql/asset_id_by_invoice.view.lkml"
include: "/retail_invoice_sales_reps.view.lkml"
include: "/views/custom_sql/fleet_track_data.view.lkml"
include: "/views/custom_sql/aph_vendor.view.lkml"
include: "/views/custom_sql/assets_for_fleet_track_data.view.lkml"
include: "/views/custom_sql/abl_category_for_fleet_track_data.view.lkml"
include: "/views/custom_sql/audit_log_parameter_changes.view.lkml"
include: "/views/Analytics/gold_vendor_reimbursements_invoice_summary.view.lkml"
include: "/views/Analytics/gold_vendor_reimbursements_accrual_summary.view.lkml"

#test commit after repo reset
#SELECT FLOOR(EXTRACT(epoch from NOW()) / (X*60*60))
#if you need every x hours updated replace the x with the number you are needing

# datagroup: 6AM_update {
#   sql_trigger: SELECT FLOOR((EXTRACT(epoch from NOW()) - 60*60*12)/(60*60*24)) ;;
#   max_cache_age: "24 hours"
# }

# datagroup: Every_Hour_Update {
#   sql_trigger: SELECT DATE_PART('hour', NOW()) ;;
#   max_cache_age: "1 hour"
# }

# datagroup: Every_Two_Hours_Update {
#   sql_trigger: SELECT FLOOR(EXTRACT(epoch from NOW()) / (2*60*60)) ;;
#   max_cache_age: "2 hours"
# }

# datagroup: Every_5_Min_Update {
#   sql_trigger: SELECT DATE_PART('minute', NOW()) ;;
#   max_cache_age: "5 minutes"
# }

# explore: scd_asset_driver { --MB comment out 10-10-23 due to inactivity

#   join: users {
#     type: left_outer
#     relationship:  many_to_one
#     sql_on:  ${scd_asset_driver.user_id} = ${users.user_id};;
#   }

#   join: assets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on:  ${scd_asset_driver.asset_id} = ${assets.asset_id} ;;
#   }

#   join: equipment_models {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${equipment_models.equipment_model_id} = ${assets.equipment_model_id} ;;
#   }

#   join: equipment_classes_models_xref {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
#   }

#   join: equipment_classes {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${equipment_classes.equipment_class_id} = ${equipment_classes_models_xref.equipment_class_id} ;;
#   }

#   join: equipment_makes {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${equipment_makes.equipment_make_id} = ${equipment_models.equipment_make_id} ;;
#   }

#   sql_always_where: ${scd_asset_driver.driver_name} is not null and ${assets.company_id} = 1854 ;;

# }

explore: fleet_track_data {
  from: fleet_track_data
  label: "Fleet Track Data"

  join: asset_nbv_all_owners {
    sql_on: ${fleet_track_data.asset_id} = ${asset_nbv_all_owners.asset_id} ;;
    relationship: many_to_one
    type: left_outer
  }

  join: aph_vendor {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${fleet_track_data.asset_id}=${aph_vendor.asset_id} ;;
  }

  join: assets_for_fleet_track_data {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${fleet_track_data.asset_id}=${assets_for_fleet_track_data.asset_id} ;;
  }

  join: asset_purchase_history {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${fleet_track_data.asset_id}=${asset_purchase_history.asset_id} ;;
  }

  join: abl_category_for_fleet_track_data {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${fleet_track_data.asset_id}=${abl_category_for_fleet_track_data.asset_id} ;;
  }
}

explore: scd_asset_msp {

  join: users {
    type: left_outer
    relationship:  many_to_one
    sql_on:  ${scd_asset_msp.user_id} = ${users.user_id};;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${scd_asset_msp.asset_id} = ${assets.asset_id} ;;
  }

  join: markets_public_rsps {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${scd_asset_msp.service_branch_id} = ${markets_public_rsps.market_id} ;;
  }

  join: equipment_models {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${assets.equipment_model_id} ;;
  }

  join: equipment_classes_models_xref {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_classes.equipment_class_id} = ${equipment_classes_models_xref.equipment_class_id} ;;
  }

  join: equipment_makes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_makes.equipment_make_id} = ${equipment_models.equipment_make_id} ;;
  }

  sql_always_where: ${assets.company_id} = 1854 and ${scd_asset_msp.user_id} is not null ;;

}

explore: scd_asset_rsp {

  join: users {
    type: left_outer
    relationship:  many_to_one
    sql_on:  ${scd_asset_rsp.user_id} = ${users.user_id};;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${scd_asset_rsp.asset_id} = ${assets.asset_id} ;;
  }

  join: markets_public_rsps {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${scd_asset_rsp.rental_branch_id} = ${markets_public_rsps.market_id} ;;
  }

  join: equipment_models {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${assets.equipment_model_id} ;;
  }

  join: equipment_classes_models_xref {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_classes.equipment_class_id} = ${equipment_classes_models_xref.equipment_class_id} ;;
  }

  join: equipment_makes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_makes.equipment_make_id} = ${equipment_models.equipment_make_id} ;;
  }

  sql_always_where: ${assets.company_id} = 1854 and ${scd_asset_rsp.user_id} is not null;;

}

explore: scd_asset_rsp_window {
  join: users {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${scd_asset_rsp_window.user_id} = ${users.user_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${scd_asset_rsp_window.asset_id} ;;
  }

  join: asset_owner {
    from:  companies
    relationship: one_to_one
    sql_on: ${assets.company_id} = ${asset_owner.company_id} ;;
  }

  join: markets_public_rsps {
    type: left_outer
    relationship: many_to_one
    sql_on: ${scd_asset_rsp_window.rental_branch_id} = ${markets_public_rsps.market_id} ;;
  }

  join: previous_market {
    from: markets
    type: left_outer
    relationship: one_to_one
    sql_on: ${scd_asset_rsp_window.previous_rsp_id} = ${previous_market.market_id} ;;
  }

  join: equipment_models {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${assets.equipment_model_id} ;;
  }

  join: equipment_classes_models_xref {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_classes.equipment_class_id} = ${equipment_classes_models_xref.equipment_class_id} ;;
  }

  join: equipment_makes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_makes.equipment_make_id} = ${equipment_models.equipment_make_id} ;;
  }
}

# explore: asset_purchase_history_logs_window { --MB comment out 10-10-23 due to inactivity

#   join: users {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${asset_purchase_history_logs_window.generated_by_user_id} = ${users.user_id} ;;
#   }

#   join: asset_purchase_history {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${asset_purchase_history_logs_window.purchase_history_id} = ${asset_purchase_history.purchase_history_id} ;;
#   }

# }

explore: scd_asset_company_window {

  join: assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${scd_asset_company_window.asset_id} = ${assets.asset_id} ;;
  }

  join: previous_company {
    from: companies
    type: left_outer
    relationship: one_to_one
    sql_on:  ${scd_asset_company_window.previous_company_id} = ${previous_company.company_id} ;;
  }

  join: equipment_models {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${assets.equipment_model_id} ;;
  }

  join: equipment_classes_models_xref {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_classes.equipment_class_id} = ${equipment_classes_models_xref.equipment_class_id} ;;
  }

  join: equipment_makes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_makes.equipment_make_id} = ${equipment_models.equipment_make_id} ;;
  }

}

explore: company_purchase_order_line_items {

  persist_for: "15 minutes"

  sql_always_where: ${deleted_date} IS NULL and ${company_purchase_orders.approved_by_user_id} is not null ;;

  join: assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_line_items.asset_id} = ${assets.asset_id} ;;
  }

  # Adding for request to add parent and sub category - 9/21/23
  join: asset_physical {
    type: left_outer
    relationship: one_to_many
    sql_on: ${equipment_classes.name} = ${asset_physical.equip_class_name} ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_line_items.asset_id} = ${asset_purchase_history.asset_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.company_id} = ${companies.company_id} ;;
  }

  join: company_purchase_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_line_items.company_purchase_order_id} = ${company_purchase_orders.company_purchase_order_id} ;;
  }

  join: vendors {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_orders.vendor_id} = ${vendors.company_id} ;;
  }

  join: markets_public_rsps {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_line_items.market_id} = ${markets_public_rsps.market_id} ;;
  }

  join: asset_market_public_rsps {
    from:  markets_public_rsps
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.service_branch_id} = ${asset_market_public_rsps.market_id} ;;
  }

  join: company_purchase_order_types {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_types.company_purchase_order_type_id} = ${company_purchase_orders.company_purchase_order_type_id} ;;
  }

  join: equipment_models {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_line_items.equipment_model_id} = ${equipment_models.equipment_model_id} ;;
  }

  join: equipment_makes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_make_id} = ${equipment_makes.equipment_make_id} ;;
  }

  join: similar_serials {
    from: assets
    type: left_outer
    relationship: many_to_many
    sql_on: ${company_purchase_order_line_items.serial_last_5} = ${similar_serials.serial_last_5} and ${similar_serials.equipment_make_id} = ${equipment_makes.equipment_make_id} ;;
  }

  join: equipment_classes_models_xref {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_classes.equipment_class_id} = coalesce(${equipment_classes_models_xref.equipment_class_id}, ${company_purchase_order_line_items.equipment_class_id}) ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets_public_rsps.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: business_segments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_classes.business_segment_id} = ${business_segments.business_segment_id} ;;
  }


  join: net_terms {
    type: left_outer
    relationship: many_to_one
    sql_on: ${vendors.net_terms_id} = ${net_terms.net_terms_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_purchase_orders.created_by_user_id} = ${users.user_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_line_items.market_id} = ${markets.market_id} ;;
  }
}

explore: incoming_fleet_limited {
  extends: [company_purchase_order_line_items]
  view_name: company_purchase_order_line_items
  persist_for: "2 hours"
  sql_always_where: 'collectors' = {{ _user_attributes['department'] }} OR
                    'developer'  = {{ _user_attributes['department'] }} OR
                    'god view'   = {{ _user_attributes['department'] }} OR
                    'telematics' = {{ _user_attributes['department'] }} OR
                    'warranty'   = {{ _user_attributes['department'] }} OR
                    'fleet'      = {{ _user_attributes['department'] }} OR
                    (('managers' = {{ _user_attributes['department'] }} OR 'rental coordinators' = {{ _user_attributes['department'] }}
                     OR 'users' = {{ _user_attributes['department'] }})
                      AND ${market_region_xwalk.District_Region_Market_Access}) ;;
}

explore: assets {

  join: asset_physical {
    type: inner
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_physical.asset_id} ;;
  }

  join: msp {
    from:  markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.service_branch_id} = ${msp.market_id} ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id}=${asset_types.asset_type_id} ;;
  }

  join: rsp {
    from:  markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.rental_branch_id} = ${rsp.market_id} ;;
  }

  join: equipment_models {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${assets.equipment_model_id} ;;
  }

  join: equipment_classes_models_xref {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_classes.equipment_class_id} = ${equipment_classes_models_xref.equipment_class_id} ;;
  }

  join: equipment_makes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_makes.equipment_make_id} = ${equipment_models.equipment_make_id} ;;
  }

  join: companies {
    type:  left_outer
    relationship: one_to_one
    sql_on:  ${assets.company_id} = ${companies.company_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.inventory_branch_id} = ${markets.market_id} ;;
  }

  join: markets_public_rsps {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${assets.inventory_branch_id} = ${markets_public_rsps.market_id} ;;
  }

  join: rentals {
    type:  left_outer
    relationship:  one_to_many
    sql_on:  ${assets.asset_id} = ${rentals.asset_id} ;;
  }

  join: rental_purchase_options {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${rentals.rental_purchase_option_id} = ${rental_purchase_options.rental_purchase_option_id} ;;
  }

  join: tracking_incidents {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${tracking_incidents.asset_id};;
  }

  join: trips {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.tracker_id} = ${trips.tracker_id} AND date_trunc('Month',${tracking_incidents.report_timestamp_raw}) = date_trunc('Month',${trips.start_timestamp_raw}) ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_table_name: analytics.public.market_region_xwalk ;;
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: master_vehicle_and_trailer_db {
    type: left_outer
    relationship: one_to_one
    sql_table_name: analytics.public.master_vehicle_and_trailer_db ;;
    sql_on: ${assets.asset_id} = ${master_vehicle_and_trailer_db.asset_number} ;;
  }

  join: users {
    type: left_outer
    relationship: one_to_one
    sql_on: ${master_vehicle_and_trailer_db.curr_user} = ${users.full_name} ;;
  }

  join: scd_asset_inventory_status {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${scd_asset_inventory_status.asset_id} ;;
  }

  join: payout_program_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${payout_program_assignments.asset_id} = ${assets.asset_id} ;;
  }

  join: payout_programs {
    type: left_outer
    relationship: one_to_one
    sql_on: ${payout_program_assignments.payout_program_id} = ${payout_programs.payout_program_id} ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_purchase_history.asset_id} ;;
  }

  join: tracking_events {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tracking_incidents.tracking_event_id} = ${tracking_events.tracking_event_id} ;;
  }

  join: work_orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${work_orders.asset_id} ;;
  }

  join: deliveries {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${deliveries.asset_id} ;;
  }

  join: create_record {
    from: command_audit
    type: left_outer
    relationship: one_to_one
    sql_on: ${create_record.parameters}:asset_id = ${assets.asset_id} and ${create_record.command} = 'CreateAsset' ;;
  }

  join: 24_hour_tracker_unplug_monitor {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${24_hour_tracker_unplug_monitor.asset_id} ;;
  }

  join: asset_moved_off_yard_past_48hours {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_moved_off_yard_past_48hours.asset_id} ;;
  }

  join: inventory_status {
    from: asset_status_key_values
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${inventory_status.asset_id} and ${inventory_status.name} = 'asset_inventory_status' ;;
  }

  join: v_assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${v_assets.asset_id} ;;
  }
}
# Removed credit_note portion of sql_always_where for Andrew Cowherd. -Jack G. 7/14/21
# Updated sql_always_where to include 50-RPO Equipment Sales per Andrew Cowherd. -Jack G. 7/21/21
# Updated sql_always_where to include 110 - New Attachment Sale per Andrew Cowherd. -Jack G 1/20/22
# Updated sql_always_where to include 111 - Used Attachment Sale per Andrew Cowherd. -Jack G 1/28/22
# Updated sql_always_where to include 120 - MS Agriculture Sale per Andrew Cowherd. 7.14.2023 BES
# - also added this to the retail_invoice_assets_credits view for the credit note line items.
# Updated sql_always_where to include 123 - Re-marketing Agreement Equipment Sale per Andrew Cowherd. 3.18.2024 Kyle C
# Updated sql_always_where to include 125, 126 - Retail to Rental Dealership Equipment Sale and LSD - OWN Equipment Sales per Andrew Cowherd. 3.21.2024 Kyle C
# Updated sql_always_where to include 127 - OWN Equipment Sale 4.18.2024 Kyle C

explore: line_items {
  view_name: line_items
  sql_always_where:  ${line_item_type_id} in (24, 50, 80, 81, 110, 111, 118, 120, 123, 125, 126, 127, 141, 145, 146, 147, 148, 149, 150, 152, 153)
  --and (${v_payout_programs.is_current} is null or ${v_payout_programs.is_current})
  --and ${credit_note_line_items.credit_note_line_item_id} is null
  ;;

  join: assets {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${line_items.derived_asset_id} = ${assets.asset_id} ;;
  }
  join: assets_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${assets_aggregate.asset_id} ;;
  }
  join: asset_owner {
    from:  companies
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.company_id} = ${asset_owner.company_id} ;;
  }
  join: equipment_models {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${assets.equipment_model_id} = ${equipment_models.equipment_model_id} ;;
  }
  join: equipment_makes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.equipment_make_id} = ${equipment_makes.equipment_make_id} ;;
  }
  join: equipment_classes_models_xref {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
  }
  join: equipment_classes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_classes_models_xref.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
  }
  join: asset_purchase_history {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${assets.asset_id} = ${asset_purchase_history.asset_id} ;;
  }
  join: company_purchase_order_line_items {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${asset_purchase_history.asset_id} = ${company_purchase_order_line_items.asset_id} ;;
  }
  join: company_purchase_orders {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${company_purchase_order_line_items.company_purchase_order_id} = ${company_purchase_orders.company_purchase_order_id} ;;
  }
  join: company_purchase_order_types {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_orders.company_purchase_order_type_id} = ${company_purchase_order_types.company_purchase_order_type_id} ;;
  }
  join: asset_vendors {
    from: companies
    type:  left_outer
    relationship:  many_to_many
    sql_on:  ${company_purchase_orders.vendor_id} = ${asset_vendors.company_id} ;;
  }
  join: financial_schedules {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${asset_purchase_history.financial_schedule_id} = ${financial_schedules.financial_schedule_id} ;;
  }
  join: financial_lenders {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${financial_schedules.originating_lender_id} = ${financial_lenders.financial_lender_id} ;;
  }
  join: asset_nbv_all_owners {
    type: left_outer
    relationship:  one_to_one
    sql_on: ${assets.asset_id} = ${asset_nbv_all_owners.asset_id};;
  }
  join: categories {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${assets.category_id} = ${categories.category_id};;
  }
  join: invoices {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${line_items.invoice_id} = ${invoices.invoice_id};;
  }
  join: asset_max_daily_hours {
    type: left_outer
    relationship: many_to_many
    sql_on: ${assets.asset_id} = ${asset_max_daily_hours.asset_id} and ${invoices.invoice_trunc_date} = ${asset_max_daily_hours.invoice_date};;
  }
  join: orders {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${invoices.order_id} = ${orders.order_id};;
  }
  join: users {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${orders.user_id} = ${users.user_id};;
  }
  join: order_salespersons {
    type:  left_outer
    relationship:  one_to_many
    sql_on:  ${orders.order_id} = ${order_salespersons.order_id};;
  }
  join: companies {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${users.company_id} = ${companies.company_id};;
  }
  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${locations.location_id} = ${companies.billing_location_id} ;;
  }
  join: company_contact_location {
    from:  locations
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.billing_location_id} = ${company_contact_location.location_id} ;;
  }
  join: company_billing_contact {
    from:  users
    type:  left_outer
    relationship: one_to_one
    sql_on: ${company_contact_location.user_id} =${company_billing_contact.user_id};;
  }
  join: line_item_types {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
  }
  join: net_terms {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  }
  join: markets {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${assets.market_id} = ${markets.market_id};;
  }
  # join: collector_mktassignments {
  #   view_label: "Collector Market Assignments"
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${collector_mktassignments.market_id} = ${markets.market_id} ;;
  # }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.market_id} = ${market_region_xwalk.market_id} ;;
  }
  # join: rateachievement_points {
  #   type: left_outer
  #   relationship: many_to_many
  #   sql_on: ${rateachievement_points.salesperson_user_id} = ${orders.salesperson_user_id} and ${line_items.invoice_id} = ${rateachievement_points.invoice_id} ;;
  # }
  # join: salesperson_to_market {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${users.user_id} = ${salesperson_to_market.salesperson_user_id} ;;
  # }

    join: credit_note_line_items {
      type:  left_outer
      relationship: one_to_one
      sql_on: ${line_items.line_item_id} = ${credit_note_line_items.line_item_id} ;;
    }

    join: credit_notes {
      type: left_outer
      relationship: many_to_one
      sql_on: ${credit_note_line_items.credit_note_id} = ${credit_notes.credit_note_id} ;;
    }

    join: retail_invoice_asset_credits {
      type: left_outer
      relationship: many_to_one
      sql_on: ${invoices.invoice_id} = ${retail_invoice_asset_credits.invoice_id} ;;
    }

  # Add current payout program per Cowherd - 2023.5.10
  join: v_payout_programs {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${v_payout_programs.asset_id} ;;
  }
  join: invoice_creator  {
    from:  users
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.created_by_user_id} = ${invoice_creator.user_id} ;;
  }

  join: retail_invoice_sales_reps{
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${orders.order_id} = ${retail_invoice_sales_reps.order_id};;
  }

  join: fleet_opt_nbv_by_month{
    type: left_outer
    view_label: "Monthly Net Book Values"
    relationship: one_to_many
    sql_on: ${line_items.derived_asset_id} = ${fleet_opt_nbv_by_month.asset_id}
     ;;
  }

  join: fleet_opt_line_item_matched_nbvs {
    type: left_outer
    view_label: "Matched Net Book Value"
    relationship: one_to_one
    sql_on: ${line_items.asset_id} = ${fleet_opt_line_item_matched_nbvs.asset_id}
      AND ${line_items.line_item_id} = ${fleet_opt_line_item_matched_nbvs.line_item_id};;
  }

}

# Duplicate of line item explore used in retail invoice dashboard for service - Britt S 2023.1.16
# https://app.shortcut.com/businessanalytics/story/216485/service-invoice-with-credits-dashboard-andrew-cowherd
explore: line_items_extended {
  extends: [line_items]
  label: "Service Invoices"
  sql_always_where: ${line_items.line_item_type_id} in (11, 13, 25, 26)
  and (${v_payout_programs.is_current} is null or ${v_payout_programs.is_current});;

  join: service_invoice_asset_credits {
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.invoice_id} = ${service_invoice_asset_credits.invoice_id} ;;
  }

}

explore: rpo_rentals {

  from:  rentals_current

  join: rpo_assets {
    from:  assets
    type: left_outer
    relationship: one_to_many
    sql_on: ${rpo_rentals.asset_id} = ${rpo_assets.asset_id} ;;
  }

  join: equipment_models {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${rpo_assets.equipment_model_id} = ${equipment_models.equipment_model_id} ;;
  }
  join: equipment_makes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rpo_assets.equipment_make_id} = ${equipment_makes.equipment_make_id} ;;
  }

  join: equipment_classes_models_xref {
    type: left_outer
    relationship: many_to_many
    sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id};;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${equipment_classes_models_xref.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
  }

  join: orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rpo_rentals.order_id} = ${orders.order_id} ;;
  }

  join: ordering_user{
    from: users
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.user_id} = ${ordering_user.user_id};;
  }

  join: ordering_company {
    from: companies
    type: left_outer
    relationship: one_to_one
    sql_on: ${ordering_user.company_id} = ${ordering_company.company_id};;
  }

  join: rental_purchase_options {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rpo_rentals.rental_purchase_option_id} = ${rental_purchase_options.rental_purchase_option_id} ;;
  }

  join: ordering_market {
    from: markets
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.market_id} = ${ordering_market.market_id} ;;
  }

  join: inventory_status {
    from: asset_status_key_values
    type: left_outer
    relationship: one_to_many
    sql_on: ${rpo_assets.asset_id} = ${inventory_status.asset_id} and ${inventory_status.name} = 'asset_inventory_status';;
  }

  sql_always_where: ${inventory_status.value} = 'On RPO' and ${rental_rank} = 1  ;;

}

explore: inbound_ordered_fleet {
  join: markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${inbound_ordered_fleet.market_id} = ${markets.market_id} ;;
  }

  join: equipment_makes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${inbound_ordered_fleet.equipment_make_id} = ${equipment_makes.equipment_make_id};;
  }
  join: equipment_models {
    type: left_outer
    relationship: one_to_one
    sql_on: ${inbound_ordered_fleet.equipment_model_id} = ${equipment_models.equipment_model_id} ;;
  }
}

explore: company_purchase_order_audit_log {
  join: company_purchase_order_line_items {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_line_items.company_purchase_order_line_item_id} = ${company_purchase_order_audit_log.company_purchase_order_line_item_id};;
  }

  join: company_purchase_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_line_items.company_purchase_order_id} = ${company_purchase_orders.company_purchase_order_id};;
  }

  join: company_purchase_order_types {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_orders.company_purchase_order_type_id} = ${company_purchase_order_types.company_purchase_order_type_id};;
  }

  join: users {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.user_id} = ${company_purchase_order_audit_log.user_id} ;;
  }
}

explore: re_rent_history {}

explore: branch_asset_assignments {
  group_label: "Asset Transfers"
  label: "Asset Rental Branch Transfers"
  case_sensitive: no

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${branch_asset_assignments.branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: users {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.user_id} = ${branch_asset_assignments.user_id} ;;
  }
}

explore: vendor_reimbursements {}

explore: vendor_reimbursement_accrual {}

explore: assets_by_market {
  label: "Assets By Market"

 # sql_always_where:
  #'developer' = {{ _user_attributes['department'] }}
  #OR 'admin'     = {{ _user_attributes['department'] }}
  #OR 'finance'   = {{ _user_attributes['department'] }}
  #OR 'fleet'     = {{ _user_attributes['department'] }}
  #OR 'god view'  = {{ _user_attributes['department'] }}
  #OR 'ram'       = {{ _user_attributes['job_role']   }}
  #OR ${market_region_xwalk.District_Region_Market_Access};;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_by_market.market_id}::varchar = ${market_region_xwalk.market_id}::varchar ;;
  }

  join: markets {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets_by_market.market_id}::varchar = ${markets.market_id}::varchar  ;;
  }

  join: asset_id_by_invoice {
    type: left_outer
    relationship: many_to_many
    sql_on: ${assets_by_market.asset_id}::varchar = ${asset_id_by_invoice.asset_id}::varchar;;
  }
}

explore: rpo_equipment_sales {}

explore: v_assets {
  view_name: v_assets

  join: assets {
  type: left_outer
  relationship: one_to_one
  sql_on: ${assets.asset_id} = ${v_assets.asset_id}
  --and ${assets.make}=${v_assets.asset_equipment_make}
  --and ${assets.model}=${v_assets.asset_equipment_model_name}
  ;;
  }

  join: equipment_makes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_makes.name} = ${v_assets.asset_equipment_make};;
  }

  join: equipment_models {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${equipment_models.name} = ${v_assets.asset_equipment_model_name};;
  }

  join: equipment_classes {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${equipment_classes.name} = ${v_assets.asset_class} ;;
  }

}

explore: equipment_classes {

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_classes.category_id} = ${categories.category_id} ;;
  }

  join: business_segments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_classes.business_segment_id} = ${business_segments.business_segment_id} ;;
  }

}
explore: audit_log_parameter_changes {label:"p2p_fleet_track_audit_log"}

explore: gold_vendor_reimbursements_invoice_summary  {}

explore: gold_vendor_reimbursements_accrual_summary  {}
