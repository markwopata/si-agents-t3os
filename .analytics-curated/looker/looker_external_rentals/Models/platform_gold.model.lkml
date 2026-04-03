connection: "reportingc_warehouse"

# Shared dimensions (for future explores / joins)
include: "/views/platform_gold/dim_assets.view.lkml"
include: "/views/platform_gold/dim_companies.view.lkml"
include: "/views/platform_gold/dim_dates.view.lkml"
include: "/views/platform_gold/dim_locations.view.lkml"
include: "/views/platform_gold/dim_parts.view.lkml"
include: "/views/platform_gold/dim_rentals.view.lkml"
include: "/views/platform_gold/dim_users.view.lkml"

# Fact tables (PLATFORM.GOLD)
include: "/views/platform_gold/fact_asset_last_checkins.view.lkml"
include: "/views/platform_gold/fact_equipment_assignments.view.lkml"
include: "/views/platform_gold/fact_trips_legacy.view.lkml"
include: "/views/platform_gold/fact_tracking_incidents.view.lkml"
include: "/views/platform_gold/fact_tracker_events.view.lkml"
include: "/views/platform_gold/fact_state_boundary_incidents.view.lkml"
include: "/views/platform_gold/fact_state_trips.view.lkml"
include: "/views/platform_gold/fact_custom_boundary_incidents.view.lkml"
include: "/views/platform_gold/fact_custom_trips.view.lkml"
include: "/views/platform_gold/fact_invoice_line_details.view.lkml"
include: "/views/platform_gold/fact_work_order_lines.view.lkml"
include: "/views/platform_gold/fact_inventory_transactions.view.lkml"
include: "/views/platform_gold/fact_weighted_average_cost_snapshot_history.view.lkml"
include: "/views/platform_gold/fact_store_part_inventory_levels.view.lkml"
include: "/views/platform_gold/fact_hourly_asset_usage.view.lkml"

# -----------------------------------------------------------------------------
# Explores
# -----------------------------------------------------------------------------

explore: fact_asset_last_checkins {
  label: "Asset Last Checkins"
  group_label: "Platform Gold"
  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_asset_last_checkins.asset_last_checkin_asset_key} = ${dim_assets.asset_key} ;;
  }
  join: checkin_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_asset_last_checkins.asset_last_checkin_date_key} = ${checkin_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_equipment_assignments {
  label: "Equipment Assignments"
  group_label: "Platform Gold"
  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_equipment_assignments.equipment_assignment_asset_key} = ${dim_assets.asset_key} ;;
  }
  join: dim_rentals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_equipment_assignments.equipment_assignment_rental_key} = ${dim_rentals.rental_key} ;;
  }
  join: start_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_equipment_assignments.equipment_assignment_start_date_date_key} = ${start_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
  join: end_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_equipment_assignments.equipment_assignment_end_date_date_key} = ${end_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_trips_legacy {
  label: "Trips (Legacy)"
  group_label: "Platform Gold"
  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_trips_legacy.trips_legacy_asset_key} = ${dim_assets.asset_key} ;;
  }
  join: driver {
    from: dim_users
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_trips_legacy.trips_legacy_driver_user_key} = ${driver.user_key} ;;
    fields: [user_id, user_full_name, user_email]
  }
  join: start_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_trips_legacy.trips_legacy_start_timestamp_date_key} = ${start_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
  join: end_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_trips_legacy.trips_legacy_end_timestamp_date_key} = ${end_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_tracking_incidents {
  label: "Tracking Incidents"
  group_label: "Platform Gold"
  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_tracking_incidents.tracking_incident_asset_key} = ${dim_assets.asset_key} ;;
  }
  join: report_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_tracking_incidents.tracking_incident_report_date_key} = ${report_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_tracker_events {
  label: "Tracker Events"
  group_label: "Platform Gold"
  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_tracker_events.tracker_events_asset_key} = ${dim_assets.asset_key} ;;
  }
  join: driver {
    from: dim_users
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_tracker_events.tracker_events_driver_user_key} = ${driver.user_key} ;;
    fields: [user_id, user_full_name, user_email]
  }
  join: report_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_tracker_events.tracker_events_latest_report_date_key} = ${report_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_state_boundary_incidents {
  label: "State Boundary Incidents"
  group_label: "Platform Gold"
  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_state_boundary_incidents.state_boundary_incidents_asset_key} = ${dim_assets.asset_key} ;;
  }
  join: incident_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_state_boundary_incidents.state_boundary_incidents_date_key} = ${incident_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_state_trips {
  label: "State Trips"
  group_label: "Platform Gold"
  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_state_trips.state_trips_asset_key} = ${dim_assets.asset_key} ;;
  }
  join: enter_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_state_trips.state_trips_enter_date_key} = ${enter_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
  join: exit_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_state_trips.state_trips_exit_date_key} = ${exit_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_custom_boundary_incidents {
  label: "Custom Boundary Incidents"
  group_label: "Platform Gold"
  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_custom_boundary_incidents.custom_boundary_incidents_asset_key} = ${dim_assets.asset_key} ;;
  }
  join: incident_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_custom_boundary_incidents.custom_boundary_incidents_date_key} = ${incident_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_custom_trips {
  label: "Custom Trips"
  group_label: "Platform Gold"
  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_custom_trips.custom_trips_asset_key} = ${dim_assets.asset_key} ;;
  }
  join: enter_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_custom_trips.custom_trips_enter_date_key} = ${enter_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
  join: exit_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_custom_trips.custom_trips_exit_date_key} = ${exit_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_invoice_line_details {
  label: "Invoice Line Details"
  group_label: "Platform Gold"
  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_invoice_line_details.invoice_line_details_asset_key} = ${dim_assets.asset_key} ;;
  }
  join: dim_rentals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_invoice_line_details.invoice_line_details_rental_key} = ${dim_rentals.rental_key} ;;
  }
  join: dim_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_invoice_line_details.invoice_line_details_company_key} = ${dim_companies.company_key} ;;
  }
  join: billing_approved_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_invoice_line_details.invoice_line_details_gl_billing_approved_date_key} = ${billing_approved_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_work_order_lines {
  label: "Work Order Lines"
  group_label: "Platform Gold"
  join: dim_parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_work_order_lines.work_order_line_part_key} = ${dim_parts.part_key} ;;
  }
  join: line_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_work_order_lines.work_order_line_date_key} = ${line_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_inventory_transactions {
  label: "Inventory Transactions"
  group_label: "Platform Gold"
  join: dim_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_inventory_transactions.inventory_transaction_company_key} = ${dim_companies.company_key} ;;
  }
  join: dim_rentals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_inventory_transactions.inventory_transaction_rental_key} = ${dim_rentals.rental_key} ;;
  }
  join: dim_parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_inventory_transactions.inventory_transaction_part_key} = ${dim_parts.part_key} ;;
  }
  join: completed_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_inventory_transactions.inventory_transaction_completed_date_key} = ${completed_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_weighted_average_cost_snapshot_history {
  label: "Weighted Average Cost Snapshot History"
  group_label: "Platform Gold"
  join: dim_parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_weighted_average_cost_snapshot_history.wac_snapshot_part_key} = ${dim_parts.part_key} ;;
  }
  join: start_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_weighted_average_cost_snapshot_history.wac_snapshot_start_date_key} = ${start_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
  join: end_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_weighted_average_cost_snapshot_history.wac_snapshot_end_date_key} = ${end_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_store_part_inventory_levels {
  label: "Store Part Inventory Levels"
  group_label: "Platform Gold"
  join: dim_parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_store_part_inventory_levels.store_part_inventory_levels_part_key} = ${dim_parts.part_key} ;;
  }
  join: created_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_store_part_inventory_levels.store_part_inventory_levels_created_date_key} = ${created_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}

explore: fact_hourly_asset_usage {
  label: "Hourly Asset Usage"
  group_label: "Platform Gold"
  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_hourly_asset_usage.hourly_asset_usage_asset_key} = ${dim_assets.asset_key} ;;
  }
  join: start_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_hourly_asset_usage.hourly_asset_usage_start_range_date_key} = ${start_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
  join: end_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_hourly_asset_usage.hourly_asset_usage_end_range_date_key} = ${end_date.date_key} ;;
    fields: [dt_date, dt_week, dt_month, dt_year]
  }
}
