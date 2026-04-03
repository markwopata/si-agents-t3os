connection: "es_snowflake_analytics"

########### ANALYTICS ###########
include: "/views/ANALYTICS/asset_nbv_all_owners.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/views/ANALYTICS/dvir_detail.view.lkml"
include: "/views/ANALYTICS/fulfillment_center_markets.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/overdue_inspections_12_mo.view.lkml"
include: "/views/ANALYTICS/v_line_items.view.lkml"
include: "/views/ANALYTICS/warranty_accrual.view.lkml"
include: "/views/ANALYTICS/PUBLIC/historical_utilization.view.lkml"
include: "/views/ANALYTICS/SERVICE/daily_work_order_info.view.lkml"
########### custom_sql ###########
include: "/views/custom_sql/company_directory_with_vehicle.view.lkml"
include: "/views/custom_sql/completed_pm_work_orders.view.lkml"
include: "/views/custom_sql/cost_to_maintain.view.lkml"
include: "/views/custom_sql/current_oec_per_branch.view.lkml"
include: "/views/custom_sql/customer_damage_margin.view.lkml"
include: "/views/custom_sql/customer_charge_asset_info.view.lkml"
include: "/views/custom_sql/customer_charge.view.lkml"
include: "/views/custom_sql/damage_warranty_recovery.view.lkml"
include: "/views/custom_sql/daily_asset_usage.view.lkml"
include: "/views/custom_sql/daily_revenue_per_inventory_status_ytd.view.lkml"
include: "/views/custom_sql/driver_assignment.view.lkml"
include: "/views/custom_sql/driver_portal_vs_t3.view.lkml"
include: "/views/custom_sql/est_work_order_cost.view.lkml"
include: "/views/custom_sql/get_past_dates.view.lkml"
include: "/views/custom_sql/headcount_by_oec.view.lkml"
include: "/views/custom_sql/histroical_pm_compliance.view.lkml"
include: "/views/custom_sql/open_work_orders.view.lkml"
include: "/views/custom_sql/parts_ordered_vs_used.view.lkml"
include: "/views/custom_sql/pending_inspections_per_day.view.lkml"
include: "/views/custom_sql/rental_branch_oec.view.lkml"
include: "/views/custom_sql/service_tech_hours.view.lkml"
include: "/views/custom_sql/service_tech_top_25.view.lkml"
include: "/views/custom_sql/service_efficiency.view.lkml"
include: "/views/custom_sql/7day_breakdowns.view.lkml"
include: "/views/custom_sql/tech_wos_within_7days_of_delivery.view.lkml"
include: "/views/custom_sql/tech_wos_completed.view.lkml"
include: "/views/custom_sql/time_tracking_work_code.view.lkml"
include: "/views/custom_sql/time_types_by_date.view.lkml"
include: "/views/custom_sql/transportation_assets.view.lkml"
include: "/views/custom_sql/training_hours_by_tech.view.lkml"
include: "/views/custom_sql/t3_purchase_order_details.view.lkml"
include: "/views/custom_sql/unavailable_history_365.view.lkml"
include: "/views/custom_sql/unavailable_history_hard_soft_down.view.lkml"
include: "/views/custom_sql/unbilled_work_orders.view.lkml"
include: "/views/custom_sql/work_orders_after_purchase.view.lkml"
include: "/views/custom_sql/work_orders_completed_last_30_days.view.lkml"
include: "/views/custom_sql/work_order_task_pass_fail.view.lkml"
include: "/views/custom_sql/work_orders_within_48_hrs_of_asset_being_assigned.view.lkml"
include: "/views/custom_sql/wos_needed_for_rentals.view.lkml"
include: "/views/custom_sql/wo_ccc_problem_group.view.lkml"
include: "/views/custom_sql/wo_response_time.view.lkml"
include: "/views/custom_sql/wo_parts_cost.view.lkml"
include: "/views/custom_sql/wo_tags_aggregate.view.lkml"
include: "/views/custom_sql/wos_within_24hrs_of_delivery.view.lkml"
include: "/views/custom_sql/wos_within_24hrs_of_delivery_variable_date.view.lkml"
include: "/views/custom_sql/ytd_open_work_orders.view.lkml"
include: "/views/custom_sql/asset_engines.view.lkml"
########### DATA_SCIENCE ###########
include: "/views/DATA_SCIENCE/fresh_cccs.view.lkml"
include: "/views/DATA_SCIENCE/all_equipment_rouse_estimates.view.lkml"
########### ES_WAREHOUSE ###########
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/asset_service_intervals.view.lkml"
# include: "/views/ES_WAREHOUSE/asset_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
include: "/views/ES_WAREHOUSE/asset_warranty_xref.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/company_purchase_order_line_items.view.lkml"
include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/maintenance_group_intervals.view.lkml"
include: "/views/ES_WAREHOUSE/maintenance_groups.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/service_intervals.view.lkml"
include: "/views/ES_WAREHOUSE/tracking_diagnostic_codes.view.lkml"
include: "/views/ES_WAREHOUSE/tracking_obd_dtc_codes.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
########### INVENTORY ###########
include: "/views/INVENTORY/transactions.view.lkml"
include: "/views/INVENTORY/transaction_items.view.lkml"
########### SCD ###########
include: "/views/SCD/scd_asset_company.view.lkml"
include: "/views/SCD/scd_asset_inventory_status.view.lkml"
include: "/views/SCD/scd_asset_odometer.view.lkml"
include: "/views/SCD/scd_asset_hours.view.lkml"
########### TIME_TRACKING ###########
include: "/views/TIME_TRACKING/time_entries.view.lkml"
include: "/views/TIME_TRACKING/time_tracking_event_types.view.lkml"
########### WORK_ORDERS ###########
include: "/views/WORK_ORDERS/billing_types.view.lkml"
include: "/views/WORK_ORDERS/company_tags.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/views/WORK_ORDERS/work_orders_by_tag.view.lkml"
include: "/views/WORK_ORDERS/work_order_company_tags.view.lkml"
include: "/views/WORK_ORDERS/work_order_files.view.lkml"
include: "/views/WORK_ORDERS/work_order_originators.view.lkml"
include: "/views/WORK_ORDERS/work_order_user_assignments.view.lkml"
########### Not In Folder ###########
include: "/views/originator_types.view.lkml"
########### DASHBOARDS ###########
include: "/Dashboards/Service/Views/Analytics/wo_updates.view.lkml"
include: "/views/custom_sql/work_order_invoice_link.view.lkml"
include: "/views/custom_sql/es_ownership_3_flags.view.lkml"
include: "/views/payout_program_assignments.view.lkml"
include: "/views/payout_programs.view.lkml"
include: "/views/custom_sql/work_order_line_items.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ANALYTICS/line_item_types.view.lkml"
include: "/views/custom_sql/monthly_warranty_accrual.view.lkml"
include: "/views/WORK_ORDERS/beta_ccc_clustering.view.lkml"
include: "/views/ES_WAREHOUSE/line_item_type_erp_refs.view.lkml"
include: "/views/ES_WAREHOUSE/command_audit.view.lkml"
include: "/views/custom_sql/work_orders_with_open_pos.view.lkml"
include: "/views/custom_sql/prev_and_current_asset_branch.view.lkml"
########### PLATFORM ###########
include: "/views/PLATFORM/v_assets.view.lkml"
include: "/views/SCD/scd_asset_inventory.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_timeframe_windows_historic.view.lkml"
include: "/views/FLEET_OPTIMIZATION/utilization_asset_historical.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/fact_monday_dot_techs.view.lkml"
include: "/views/custom_sql/year_trailing_class_utilization.view.lkml"
include: "/views/SAASY/PUBLIC/ccc_entries.view.lkml"
include: "/views/SAASY/PUBLIC/cccs.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_companies_fleet_opt.view.lkml"
include: "/views/ANALYTICS/ASSETS/int_equipment_assignments.view.lkml"
include: "/views/ANALYTICS/SERVICE/hard_down_processing.view.lkml"
########### BUSINESS INTELLIGENCE ###########
include: "/views/business_intelligence/fact_operator_assignments.view.lkml"
include: "/views/WORK_ORDERS/urgency_levels.view.lkml"

explore: hard_down_processing {
  case_sensitive: no
  description: "Data from the Hard Down Processing Retool App"

  join: users {
    type: inner
    relationship: many_to_one
    sql_on: ${hard_down_processing.user_id} = ${users.user_id} ;;
  }

  join: work_orders {
    type: inner
    relationship: many_to_one
    sql_on: ${hard_down_processing.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: dim_assets_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${dim_assets_fleet_opt.asset_id} ;;
  }
}

explore: monthly_warranty_accrual {
  case_sensitive: no
  description: "Current raw code for the warranty accrual"
}

explore: pending_inspections_per_day {
  case_sensitive: no
  description: "Number of Work Orders pending at each branch at 4 am CT each day"

  join: market_region_xwalk {
    type: inner
    relationship: one_to_one
    sql_on: ${pending_inspections_per_day.branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: current_oec_per_branch {
    type: inner
    relationship: many_to_one
    sql_on: ${pending_inspections_per_day.branch_id} = ${current_oec_per_branch.market_id} ;;
  }

  join: rental_branch_oec {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${rental_branch_oec.market_id} ;;
  }
  join: work_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${pending_inspections_per_day.work_order_id} = ${work_orders.work_order_id};;
  }
  join: billing_types {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
  }
}

# Commented out due to low usage on 2026-03-27
# explore: open_work_orders {
#   description: "Open Work Orders for Asset Buy-Backs"
# }

# Commented out due to low usage on 2026-03-27
# explore: unbilled_work_orders {
#   description: "Unbilled Work Orders for Asset Buy-Backs"
# }

explore: histroical_pm_compliance {
  label: "Historical PM Compliance"

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${histroical_pm_compliance.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: transportation_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${histroical_pm_compliance.asset_id} = ${transportation_assets.asset_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${histroical_pm_compliance.asset_id} ;;
  }

  join: company_purchase_order_line_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_purchase_order_line_items.asset_id} = ${histroical_pm_compliance.asset_id} ;;
  }

  join: work_order_originators {
    type: left_outer
    relationship: many_to_one
    sql_on: ${histroical_pm_compliance.maintenance_group_interval_id} = ${work_order_originators.originator_id} ;;
  }

  join: work_orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${histroical_pm_compliance.asset_id} = ${work_orders.asset_id} and ${work_order_originators.work_order_id} = ${work_orders.work_order_id} ;;
  }

  # depreciated and commented 05/22/2025 - Don Hannant
  # join: asset_statuses {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${asset_statuses.asset_id} = ${histroical_pm_compliance.asset_id} ;;
  # }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: CAST(${users.user_id} as string) = ${asset_status_key_values.value} ;;
    # sql_where: ${asset_status_key_values.name} = 'driver_user_id' ;;
  }
  # join: users {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${users.user_id} = ${asset_statuses.driver_user_id} ;;
  # }
}

# Commented out due to low usage on 2026-03-27
# explore: training_hours_by_tech {
#   label: "Training Hours by Tech"
#
#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${markets.market_id} = ${training_hours_by_tech.market_id} ;;
#   }
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-27
# explore: headcount_by_oec {
#   label: "Headcount by OEC"
#
#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${markets.market_id} = ${headcount_by_oec.market_id} ;;
#   }
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-27
# explore: time_types_by_date {
#   label: "Time Types by Date"
#
#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${markets.market_id} = ${time_types_by_date.branch_id} ;;
#   }
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#   }
# }

explore: assets {
  label: "Asset Roster"
  sql_always_where: ${markets.active} = TRUE and ${markets.company_id} = 1854 ;;

  join: transportation_assets {
    type: inner
    relationship: one_to_one
    sql_on: ${transportation_assets.asset_id} = ${assets.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${assets.rental_branch_id},${assets.inventory_branch_id})=${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: assets_aggregate {
    type: inner
    relationship: one_to_one
    sql_on: ${assets_aggregate.asset_id} = ${assets.asset_id};;
  }

  join: tracking_diagnostic_codes {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${tracking_diagnostic_codes.asset_id} ;;
  }

  join: dvir_detail {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${dvir_detail.asset_id} ;;
  }

  join: work_orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.asset_id} = ${assets.asset_id} ;;
  }

  join: scd_asset_odometer {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${scd_asset_odometer.asset_id} ;;
    sql_where: ${scd_asset_odometer.current_flag} = 1 ;;
  }

  join: scd_asset_hours {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${scd_asset_hours.asset_id} ;;
    sql_where: ${scd_asset_hours.current_flag} = 1 ;;
  }

# depreciated and commented on 05-22-2025 Don Hannant
  # join: asset_statuses {
  #   type: left_outer
  #   relationship: one_to_many
  #   sql_on: ${asset_statuses.asset_id} = ${assets.asset_id} ;;
  # }

  join: company_purchase_order_line_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_purchase_order_line_items.asset_id} = ${assets.asset_id} ;;
  }

  join: completed_pm_work_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${completed_pm_work_orders.asset_id}
      and ${transportation_assets.asset_id} = ${completed_pm_work_orders.asset_id};;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: CAST(${users.user_id} as string) = ${asset_status_key_values.value} ;;
    # sql_where: ${asset_status_key_values.name} = 'driver_user_id' ;;
  }

  # join: users {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${users.user_id} = ${asset_statuses.driver_user_id} ;;
  # }

  join: daily_asset_usage {
    type: left_outer
    relationship: one_to_many
    sql_on: ${transportation_assets.asset_id} = ${daily_asset_usage.asset_id} ;;
  }

  join: driver_portal_vs_t3 {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${driver_portal_vs_t3.asset_id} ;;
  }

  # join: asset_nbv_all_owners {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${assets.asset_id} = ${asset_nbv_all_owners.asset_id} ;;
  # }

  join: company_directory_with_vehicle {
    type: left_outer
    relationship: one_to_many
    sql_on: ${markets.market_id} = ${company_directory_with_vehicle.market_id} and ${assets.license_type} = ${company_directory_with_vehicle.license_type};;
  }

  join: fact_operator_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${fact_operator_assignments.asset_id} and ${fact_operator_assignments.current_assignment} ;;
  }

  join: rental_market {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.rental_branch_id} = ${rental_market.market_id} ;;
  }

  join: inventory_market {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.inventory_branch_id} = ${inventory_market.market_id} ;;
  }

  join: service_market {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.service_branch_id} = ${service_market.market_id} ;;
  }

  join: v_assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_assets.asset_id} = ${assets.asset_id} ;;
  }
}

explore: daily_revenue_per_inventory_status_ytd {

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${daily_revenue_per_inventory_status_ytd.market_id} = ${market_region_xwalk.market_id} ;;
  }
}
explore: fact_monday_dot_techs {
  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${fact_monday_dot_techs.market_id} = ${market_region_xwalk.market_id} ;;
  }
}
explore: tracking_diagnostic_codes{
  label: "Diagnostic Codes"

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${tracking_diagnostic_codes.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${assets.rental_branch_id},${assets.inventory_branch_id})=${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: company_purchase_order_line_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_purchase_order_line_items.asset_id} = ${assets.asset_id} ;;
  }

  join: transportation_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transportation_assets.asset_id} = ${assets.asset_id} ;;
  }

  join: tracking_obd_dtc_codes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tracking_obd_dtc_codes.code} = ${tracking_diagnostic_codes.code} ;;
  }
}

explore: overdue_inspections_12_mo {
  label: "Year to Date Trend of Overdue Inspections"

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${overdue_inspections_12_mo.market_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${overdue_inspections_12_mo.asset_id};;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${overdue_inspections_12_mo.asset_id} ;;
  }

  join: transportation_assets {
    type: left_outer
    relationship: one_to_many
    sql_on: ${transportation_assets.asset_id} = ${assets.asset_id} ;;
  }

  join: company_purchase_order_line_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_purchase_order_line_items.asset_id} = ${assets.asset_id} ;;
  }
}

# Commented out due to low usage on 2026-03-27
# explore: maintenance_group_interval_study {
#   from: assets
#
#   join: maintenance_groups {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${maintenance_group_interval_study.maintenance_group_id} = ${maintenance_groups.maintenance_group_id} ;;
#   }
#
#   join: maintenance_group_intervals {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${maintenance_group_interval_study.maintenance_group_id} = ${maintenance_group_intervals.maintenance_group_id} ;;
#   }
#
#   join: service_intervals {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${maintenance_group_intervals.service_interval_id} = ${service_intervals.service_interval_id} ;;
#   }
#
#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${maintenance_groups.company_id} = ${companies.company_id} ;;
#   }
#
#   join: work_order_originators {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${maintenance_group_intervals.maintenance_group_interval_id} = ${work_order_originators.originator_id} ;;
#   }
#
#   join: asset_service_intervals {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${maintenance_group_interval_study.asset_id} = ${asset_service_intervals.asset_id} and ${maintenance_group_intervals.maintenance_group_interval_id} = ${asset_service_intervals.maintenance_group_interval_id} ;;
#     fields: [asset_service_intervals.asset_id,asset_service_intervals.maintenance_group_interval_id,asset_service_intervals.date_created_date,asset_service_intervals.date_created_month,asset_service_intervals.count_assets_mgi,asset_service_intervals.count_assets_month]
#   }
#
#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${maintenance_group_interval_study.service_branch_id} = ${markets.market_id} ;;
#   }
#
#   join: asset_company {
#     from: companies
#     type: left_outer
#     relationship: many_to_one
#     # sql_on: ${markets.company_id} = ${asset_company.company_id} ;;
#     sql_on: ${maintenance_group_interval_study.company_id} = ${asset_company.company_id} ;;
#   }
#
#   join: asset_under_warranty {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${maintenance_group_interval_study.asset_id} = ${asset_under_warranty.asset_id} ;;
#   }
#
#   join: maintenance_group_interval_group {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${maintenance_groups.maintenance_group_id} = ${maintenance_group_interval_group.maintenance_group_id} ;;
#   }
# }

explore: scd_asset_inventory_status {
  group_label: "Service"
  label: "Year to date Trend of Severe Status"
  sql_always_where:
  ((${assets.company_id} <> 11606
  and LEFT(${assets.serial_number}, 2) <> 'RR'
  and LEFT(${assets.custom_name}, 2) <> 'RR')
  or ${assets.serial_number} is null);;

  join: get_past_dates {
    type: inner
    relationship: many_to_one
    sql_on: ${get_past_dates.generateddate_date} >= ${scd_asset_inventory_status.date_start_date} and ${get_past_dates.generateddate_date} < ${scd_asset_inventory_status.date_end_date};;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${scd_asset_inventory_status.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${assets.rental_branch_id},${assets.inventory_branch_id})=${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${assets.asset_id};;
  }
}

explore: ytd_open_work_orders {
  group_label: "Service"
  label: "Year to date of Open Work Orders on Each Day"

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ytd_open_work_orders.branch_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${ytd_open_work_orders.asset_id} = ${assets.asset_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${assets.asset_id};;
  }
}

explore: work_orders_after_purchase {
  label: "Work Orders within 365 days of Asset purchase date"

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${work_orders_after_purchase.branch_id} ;;
  }
}


explore: time_tracking_work_code {
  label: "Time Tracking By Work Code"

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${time_tracking_work_code.branch_id} = ${market_region_xwalk.market_id} ;;
  }
}

#Work Orders Completed in the last 30 days

# Commented out due to low usage on 2026-03-27
# explore: work_orders_completed_last_30_days {
#   group_label: "Service"
#   label: "WO's Completed By Day Last 30 Days"
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${work_orders_completed_last_30_days.branch_id} = ${market_region_xwalk.market_id} ;;
#   }
# }

#Work Orders Within 48 Hours of Asset Being Assigned
explore: work_orders_within_48_hrs_of_asset_being_assigned {
  group_label: "Service"
  label: "WO's Created within 48 hrs of asset being assigned"

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders_within_48_hrs_of_asset_being_assigned.work_order_branch_id} = ${market_region_xwalk.market_id} ;;
  }
}

#Customer Charge Information - damage
explore: customer_charge_asset_info {
  group_label: "Invoice Information"
  label: "Pulling Customer Charge Info"
  case_sensitive: no

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${customer_charge_asset_info.branch_id}  ;;
  }

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${customer_charge_asset_info.asset_id} = ${assets.asset_id} ;;
  }

}

explore: line_items_and_credits {
  from:  v_line_items
  group_label: "Invoice Information"
  label: "Line Items and Credits"
  case_sensitive: no

  join: invoices {
    type: inner
    relationship: many_to_one
    sql_on: ${line_items_and_credits.invoice_id}=${invoices.invoice_id} ;;
  }

  join: companies {
    type:  inner
    relationship: many_to_one
    sql_on: ${invoices.company_id}=${companies.company_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${line_items_and_credits.branch_id}  ;;
  }

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${line_items_and_credits.asset_id} = ${assets.asset_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${assets.asset_id};;
  }

  join: work_orders {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${invoices.invoice_id}=${work_orders.invoice_id} ;;
  }

}

# Commented out due to low usage on 2026-03-27
# explore: customer_damage_margin { #want to delete this explore once the one below is built out
#   join: market_region_xwalk {
#     type: left_outer
#     relationship:  many_to_one
#     sql_on: ${customer_damage_margin.branch_id}=${market_region_xwalk.market_id} ;;
#   }
# }

explore: customer_charge{
  join: market_region_xwalk {
    type: left_outer
    relationship:  many_to_one
    sql_on: ${customer_charge.branch_id}=${market_region_xwalk.market_id} ;;
  }
  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${customer_charge.asset_id};;
  }
}

#Work Orders - Work Order Information
explore: work_orders {
  group_label: "Work Orders"
  label: "Work Order Information"
  case_sensitive: no
  # sql_always_where: ${work_orders_by_tag.name} NOT IN ('New ECM-01','New ECM-01','Replace ECM-01','New ESCDM','Replace ESCDM','New Keypad','Replace Keypad','New Tracker','Replace Tracker','Tracker repair','New BLE device','Replace BLE device','Camera Install')  ;;
  # Want to exclude out telematics tags

  join: urgency_levels {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.urgency_level_id} = ${work_orders.urgency_level_id} ;;
  }

  join: last_interaction_date {
    type: left_outer
    relationship: one_to_one
    sql_on: ${last_interaction_date.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: work_orders_with_open_pos {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${work_orders_with_open_pos.work_order_id}  ;;
  }

  join: billing_types {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
  }

  join: wo_updates {
    type: left_outer
    relationship: one_to_many
    sql_on: ${wo_updates.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: work_order_originators {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${work_order_originators.work_order_id} ;;
  }

  join: originator_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_originators.originator_type_id} = ${originator_types.originator_type_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.invoice_number} = ${invoices.invoice_no} ;;
  }

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets.asset_id} ;;
  }

  join: v_assets {
    type: inner
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${v_assets.asset_id} ;;
  }
  join: asset_engines {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${v_assets.asset_id}=${asset_engines.asset_id} ;;
  }
  join: asset_owner {
    from: companies
    type: inner
    relationship: one_to_one
    sql_on: ${assets.company_id} = ${asset_owner.company_id} ;;
  }

  join: prev_and_current_asset_inventory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${prev_and_current_asset_inventory.asset_id} = ${work_orders.asset_id} ;;
  }

  join: prev_and_current_asset_branch {
    type: left_outer
    relationship: many_to_one
    sql_on: ${prev_and_current_asset_branch.asset_id} = ${work_orders.asset_id}  ;;
  }

  join: current_asset_branch {
    from: market_region_xwalk
    type: left_outer
    relationship: many_to_one
    sql_on: ${current_asset_branch.market_id} = ${prev_and_current_asset_branch.current_branch_id} ;;
  }

  join: markets {
    type: left_outer
    relationship:many_to_one
    sql_on: ${work_orders.branch_id} = ${markets.market_id} ;;
  }

  join: rentals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${rentals.asset_id} ;;
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

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.company_id} = ${companies.company_id} ;;
  }

  join: equipment_assignments {
    type: inner
    relationship: many_to_one
    sql_on: ${equipment_assignments.asset_id} = ${work_orders.asset_id}
             AND ${equipment_assignments.rental_id} = ${rentals.rental_id}
             AND (${work_orders.date_completed_date} BETWEEN ${equipment_assignments.start_date} AND ${equipment_assignments.end_date}
               OR ${work_orders.date_created_date} BETWEEN ${equipment_assignments.start_date} AND ${equipment_assignments.end_date});;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
  }

  join: fulfillment_center_markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_name} = ${fulfillment_center_markets.location} ;;
  }

  join: t3_purchase_order_details {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.work_order_id} = ${t3_purchase_order_details.allocation_id} ;;
  }

  join: current_oec_per_branch {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${current_oec_per_branch.market_id} ;;
  }

  join: rental_branch_oec {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${rental_branch_oec.market_id} ;;
  }

  join: work_orders_by_tag {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.work_order_id} = ${work_orders_by_tag.work_order_id} ;;
  }

  join: wo_response_time {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${wo_response_time.work_order_id} ;;
  }

  join: work_order_company_tags {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.work_order_id} = ${work_order_company_tags.work_order_id}
    and ${work_order_company_tags.deleted_on_date} is null;; #historical tags are now remaining in this table so deleted on needs to be null to get to current tags #HL 12.15.25
  }

  join: company_tags {
    type: inner
    relationship: one_to_one
    sql_on: ${work_order_company_tags.company_tag_id} = ${company_tags.company_tag_id} ;;
  }

  join: current_inventory_status {
    from: scd_asset_inventory_status
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${current_inventory_status.asset_id} AND
      ${current_inventory_status.current_flag};;
  }

  join: work_order_files {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.work_order_id} = ${work_order_files.work_order_id} ;;
  }

  join: time_entries {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.work_order_id} = ${time_entries.work_order_id} and
        not ${time_entries.archived} and
            ${time_entries.event_type_id} = 1 ;;
  }

  join: time_entries_agg {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${time_entries_agg.work_order_id};;
  }

  join: wo_tags_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${wo_tags_aggregate.work_order_id} ;;
  }

  join: wo_user_assignments_agg {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${wo_user_assignments_agg.work_order_id} ;;
  }

  join: wo_parts_cost_agg {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${wo_parts_cost_agg.work_order_id} ;;
  }

  join: scd_asset_company {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.asset_id} = ${scd_asset_company.asset_id}
      and ${work_orders.date_completed_date} BETWEEN ${scd_asset_company.date_start_date} AND ${scd_asset_company.date_end_date}
      ;;
  }

  join: owner_at_work_order_completion {
    from: companies
    type: left_outer
    relationship: one_to_one
    sql_on: ${scd_asset_company.company_id} = ${owner_at_work_order_completion.company_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${assets.asset_id};;
  }

  join: company_purchase_order_line_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_purchase_order_line_items.asset_id} = ${assets.asset_id} ;;
  }

  join: transportation_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transportation_assets.asset_id} = ${assets.asset_id} ;;
  }

  join: est_work_order_cost {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${est_work_order_cost.work_order_id} ;;
  }

  join: work_order_task_pass_fail {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${work_order_task_pass_fail.work_order_id} ;;
  }

  join: maintenance_group_intervals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_originators.originator_id} = ${maintenance_group_intervals.maintenance_group_interval_id} ;;
  }

  join: maintenance_groups {
    type: left_outer
    relationship: many_to_one
    sql_on: ${maintenance_group_intervals.maintenance_group_id} = ${maintenance_groups.maintenance_group_id} ;;
  }

  join: mg_company {
    from: companies
    type: left_outer
    relationship: many_to_one
    sql_on: ${maintenance_groups.company_id} = ${mg_company.company_id} ;;
  }

  join: fresh_cccs {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${fresh_cccs.work_order_id} ;;
  }

  join: work_order_to_invoice {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_order_to_invoice.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: invoice_linked_by_loop {
    from: invoices
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoice_linked_by_loop.invoice_id} = ${work_order_to_invoice.invoice_id} ;;
  }

  join: invoice_creator_by_loop {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.created_by_user_id} = ${invoice_creator_by_loop.user_id} ;;
  }

  join: line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoice_linked_by_loop.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: line_item_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
  }

  join: line_item_type_erp_refs {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_type_erp_refs.line_item_type_id} ;;
  }

  join: billed_company_by_loop {
    from: companies
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoice_linked_by_loop.company_id} = ${billed_company_by_loop.company_id} ;;
  }

  join: payout_program_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${payout_program_assignments.asset_id} = ${work_orders.asset_id}
      and ${payout_program_assignments.start_date} < ${work_orders.date_completed_date}
      and coalesce(${payout_program_assignments.end_date}, '2099-12-31') >= ${work_orders.date_completed_date} ;;
  }

  join: payout_programs {
    type: left_outer
    relationship: many_to_one
    sql_on: ${payout_programs.payout_program_id} = ${payout_program_assignments.payout_program_id} ;;
  }

  join: work_order_line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.work_order_id} = ${work_order_line_items.work_order_id} ;;
  }

  join: beta_ccc_clustering {
    type: left_outer
    relationship: one_to_one
    sql_on: ${beta_ccc_clustering.work_order_id} = ${work_orders.work_order_id} ;;
  }
#Used to get the correct ute timeframe in next join. This will get us the ute for the year leading up to the creation of the work order
  join: prev_year_timeframe {
    from: dim_timeframe_windows_historic
    type: left_outer
    relationship: many_to_one
    sql_on: ${prev_year_timeframe.run_month} = ${work_orders.date_created_month}
      and ${prev_year_timeframe.timeframe} = 'annually'
      and ${prev_year_timeframe.start_date} > '2023-01-01';; #Per Lexie, Pre October 2022 the Ute ratio is unreliable due to missing historic days in fleet totals - TA June 2025
  }

  join: year_trailing_utilization {
    from: utilization_asset_historical
    type: left_outer
    relationship: many_to_one
    sql_on: ${year_trailing_utilization.asset_id} = ${work_orders.asset_id}
      and ${year_trailing_utilization.tf_key} = ${prev_year_timeframe.tf_key};;
  }

  join: accumulated_depreciation_on_open_work_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${accumulated_depreciation_on_open_work_orders.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: dim_assets_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_assets_fleet_opt.asset_id} = ${work_orders.asset_id}  ;;
  }

  join: year_trailing_district_class_utilization_agg {
    type: left_outer
    relationship: many_to_one
    sql_on: ${year_trailing_district_class_utilization_agg.asset_equipment_class_name} = ${dim_assets_fleet_opt.asset_equipment_class_name}
      and ${year_trailing_district_class_utilization_agg.district} = ${current_asset_branch.district} ;;
  }

  join: year_trailing_region_class_utilization_agg {
    type: left_outer
    relationship: many_to_one
    sql_on: ${year_trailing_region_class_utilization_agg.asset_equipment_class_name} = ${dim_assets_fleet_opt.asset_equipment_class_name}
      and ${year_trailing_region_class_utilization_agg.region_id} = ${current_asset_branch.region} ;;
  }

  join: expected_lost_revenue_on_open_hard_downs {
    type: left_outer
    relationship: one_to_one
    sql_on: ${expected_lost_revenue_on_open_hard_downs.work_order_id} = ${work_orders.work_order_id} ;;
  }

# New - uses snowflake table
  join: expected_lost_revenue {
    type: left_outer
    relationship: one_to_one
    sql_on: ${expected_lost_revenue.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: accumulated_depreciation_in_current_status {
    type: left_outer
    relationship: one_to_one
    sql_on: ${accumulated_depreciation_in_current_status.asset_id} = ${work_orders.asset_id} ;;
  }

  join: accumulated_depreciation_since_last_rental {
    type: left_outer
    relationship: one_to_one
    sql_on: ${accumulated_depreciation_since_last_rental.asset_id} = ${work_orders.asset_id} ;;
  }

  join: wo_ccc_problem_group {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${wo_ccc_problem_group.work_order_id} ;;
  }

  join: asset_scoring {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_scoring.asset_id} = ${work_orders.asset_id} ;;
  }

  join: cccs {
    type: left_outer
    relationship: one_to_one
    sql_on: ${cccs.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: latest_ccc_entries {
    type: left_outer
    relationship: one_to_one
    sql_on: ${latest_ccc_entries.ccc_id} = ${cccs.ccc_id};;
  }

  join: all_equipment_rouse_estimates {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${all_equipment_rouse_estimates.asset_id} ;;
  }

  join: time_between_failures {
    type: left_outer
    relationship: one_to_one
    sql_on: ${time_between_failures.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: active_rental_assignment {
    from: int_equipment_assignments
    type: left_outer
    relationship: many_to_many
    sql_on: ${active_rental_assignment.asset_id} = ${work_orders.asset_id}
      and ${active_rental_assignment.date_start_raw} <= ${work_order_files.date_created_raw}
      and ${active_rental_assignment.date_end_raw} >= ${work_orders.date_created_raw};;
  }

  join: active_rental_assignment_rentals {
    from: rentals
    type: left_outer
    relationship: many_to_many
    sql_on: ${active_rental_assignment.rental_id} = ${active_rental_assignment_rentals.rental_id} ;;
  }

  join: active_rental_assignment_orders {
    from: orders
    type: left_outer
    relationship: many_to_many
    sql_on: ${active_rental_assignment_orders.order_id} = ${active_rental_assignment_rentals.order_id} ;;
  }

  join: active_rental_assignment_customer {
    from: dim_companies_fleet_opt
    type: left_outer
    relationship: many_to_many
    sql_on: ${active_rental_assignment_orders.company_id} = ${active_rental_assignment_customer.company_id} ;;
  }

  join: hard_down_processing {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${hard_down_processing.work_order_id}
      and ${hard_down_processing.is_current};;
  }
}

explore: wos_within_24hrs_of_delivery {
  case_sensitive: no

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${wos_within_24hrs_of_delivery.work_order_branch_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: work_orders {
    type: inner
    relationship: many_to_one
    sql_on: ${wos_within_24hrs_of_delivery.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: orders {
    type: inner
    relationship: one_to_many
    sql_on: ${market_region_xwalk.market_id}= ${orders.market_id} ;;
  }

  join: deliveries {
    type: inner
    relationship:  one_to_one
    sql_on: ${orders.order_id}= ${deliveries.order_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${work_orders.asset_id};;
  }

  join: delivery_customer {
    from: dim_companies_fleet_opt
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.company_id} = ${delivery_customer.company_id} ;;
  }
}

# Commented out due to low usage on 2026-03-27
# explore: wos_within_24hrs_of_delivery_variable_date {
#   case_sensitive: no
#
#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${wos_within_24hrs_of_delivery_variable_date.work_order_branch_id} = ${markets.market_id} ;;
#   }
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#   }
#
#   join: work_orders {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${wos_within_24hrs_of_delivery_variable_date.work_order_id} = ${work_orders.work_order_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-27
# explore: warranty_accrual {}

explore: service_tech_scorecard {
  from: service_tech_expected_hours

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${service_tech_scorecard.market_id}=${market_region_xwalk.market_id} ;;
  }

  join: work_orders {
    type: inner
    relationship: many_to_one
    sql_on: ${service_tech_scorecard.work_order_id}=${work_orders.work_order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${service_tech_scorecard.tech_id}=${users.user_id};;
    sql_where: ${users.company_id}= '1854' ;;
  }

  join: company_directory {
    type: inner
    relationship: one_to_one
    sql_on: ${users.employee_id}=${company_directory.employee_id} ;;
  }

  join: work_order_originators {
    type: inner
    relationship:  many_to_one
    sql_on: ${work_orders.work_order_id}=${work_order_originators.work_order_id} ;;
  }

  join: service_tech_top_25 {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${service_tech_top_25.tech_id} = ${service_tech_scorecard.tech_id}
      and ${service_tech_top_25.work_order_id} = ${service_tech_scorecard.work_order_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${work_orders.asset_id} ;;
  }

}

explore: market_region_xwalk {
  label: "Closures Per Tech"

  join: work_orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${market_region_xwalk.market_id} = ${work_orders.branch_id} ;;
  }

  join: company_directory {
    type: left_outer
    relationship: one_to_many
    sql_on: ${market_region_xwalk.market_id} = ${company_directory.market_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets.asset_id} ;;
  }
}

explore: tech_wos_within_7days_of_delivery {
  # Combined with service_efficiency now... this might be able to be deleted?  DLH 11/19/2025

  join: market_region_xwalk {
    type: left_outer
    relationship:  many_to_one
    sql_on: ${tech_wos_within_7days_of_delivery.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: current_oec_per_branch {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tech_wos_within_7days_of_delivery.market_id} = ${current_oec_per_branch.market_id} ;;
  }

  join: rental_branch_oec {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${rental_branch_oec.market_id} ;;
  }

  join: last_work_order {
    from: work_orders
    type: inner
    relationship: many_to_one
    sql_on: ${tech_wos_within_7days_of_delivery.last_wo_id} = ${last_work_order.work_order_id} ;;
  }

  join: breakdown_work_order {
    from: work_orders
    type: left_outer
    relationship: many_to_one
    sql_on: ${tech_wos_within_7days_of_delivery.breakdown_wo_id} = ${breakdown_work_order.work_order_id} ;;

  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tech_wos_within_7days_of_delivery.last_tech_id} = ${users.user_id};;
    sql_where:  ${users.company_id} = '1854' ;;
  }

  join: company_directory {
    type: inner
    relationship: one_to_one
    sql_on: ${users.employee_id} = ${company_directory.employee_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${breakdown_work_order.asset_id} ;;
  }
}

explore: damage_warranty_recovery { #used for operations overview % of rental revenue. damage and warranty revenue side needs to be reworked to match how revenue is being updated in service dashboard
  label: "Damage and Warranty Recovery"

  join: market_region_xwalk {
    type: inner
    relationship: one_to_one
    sql_on: ${damage_warranty_recovery.market_id} =${market_region_xwalk.market_id}  ;;
  }
}

explore: wos_needed_for_rentals {

  join: market_region_xwalk {
    type: left_outer
    relationship:  many_to_one
    sql_on: ${wos_needed_for_rentals.market_id}=${market_region_xwalk.market_id} ;;
  }
}

explore: unavailable_history_365 {

  join: market_region_xwalk {
    type: inner
    relationship:  many_to_one
    sql_on: ${unavailable_history_365.market_id}=${market_region_xwalk.market_id} ;;
  }
}

# Commented out due to low usage on 2026-03-27
# explore: unavailable_history_hard_soft_down {
#   join: market_region_xwalk {
#     type: inner
#     relationship:  many_to_one
#     sql_on: ${unavailable_history_hard_soft_down.rental_branch_id}=${market_region_xwalk.market_id};;
#   }
# }

# Commented out due to low usage on 2026-03-27
# explore: cost_to_maintain{}

# Commented out due to low usage on 2026-03-27
# explore: historical_utilization  {
#   always_join: [assets_aggregate,scd_asset_inventory_status]
#   join: assets_aggregate {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${assets_aggregate.asset_id}=${historical_utilization.asset_id} ;;
#   }
#
#   join: scd_asset_inventory_status {
#     type: inner
#     relationship: one_to_one
#     sql_on: ${historical_utilization.asset_id} = ${scd_asset_inventory_status.asset_id}
#         and ${historical_utilization.dte_date} >= ${scd_asset_inventory_status.date_start_date}
#         and ${historical_utilization.dte_date} < ${scd_asset_inventory_status.date_end_date} ;;
#   }
#   join: market_region_xwalk {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${historical_utilization.market_id}=${market_region_xwalk.market_id} ;;
#   }
# }

explore: service_efficiency {
  persist_for: "16 hours"

  join: market_region_xwalk {
    type: left_outer
    relationship:  many_to_one
    sql_on: ${service_efficiency.branch_id} = ${market_region_xwalk.market_id} ;;
  }
  join: company_directory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${service_efficiency.employee_id} = ${company_directory.employee_id} ;;
  }
  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${service_efficiency.user_id} = ${users.user_id} ;;
  }
  join: se_headcount_oec_agg {
    view_label: "SE Headcount OEC Agg"
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${se_headcount_oec_agg.market_id};;
  }
  join: work_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${service_efficiency.work_order_id} = ${work_orders.work_order_id} ;;
  }
  join: billing_types {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
  }
  join: time_entries_agg {
    type: left_outer
    relationship: one_to_one
    sql_on: ${service_efficiency.work_order_id} = ${time_entries_agg.work_order_id} and
        not ${time_entries_agg.archived} and
            ${time_entries_agg.event_type_id} = 1 ;;
  }
  join: time_entries {
    type: left_outer
    relationship: one_to_many
    sql_on: ${service_efficiency.work_order_id} = ${time_entries.work_order_id} and
        not ${time_entries.archived} and
            ${time_entries.event_type_id} = 1 ;;
  }
  join: 7day_breakdowns {
    type: left_outer
    relationship: one_to_many
    sql_on: ${7day_breakdowns.breakdown_branch_id} = ${market_region_xwalk.market_id} ;;
    # ${7day_breakdowns.breakdown_wo_id} = ${work_orders.work_order_id} ;;
  }
  join: v_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${v_assets.asset_market_id} = ${market_region_xwalk.market_id} ;;
  }
}
