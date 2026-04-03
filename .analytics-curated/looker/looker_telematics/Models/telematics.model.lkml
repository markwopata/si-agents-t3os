connection: "es_snowflake_c_analytics"

include: "/views/custom_sql/telematics_db_snowflake.view.lkml"
include: "/views/custom_sql/telematics_all_assets_snowflake.view.lkml"
include: "/views/custom_sql/telematics_ble.view.lkml"
include: "/views/custom_sql/telematics_keypads.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/tracker_types.view.lkml"
include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/net_terms.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/custom_sql/owl_cam.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
# include: "/views/ANALYTICS/telematics_new_tracker_work_order_no_tracker_id.view.lkml"
include: "/views/ES_WAREHOUSE/work_orders.view.lkml"
include: "/views/ES_WAREHOUSE/work_orders_by_tag.view.lkml"
include: "/views/custom_sql/asset_inventory_status.view.lkml"
include: "/views/custom_sql/top_20_work_orders_prior_week_snowflake.view.lkml"
include: "/views/custom_sql/top_20_work_orders_ytd_snowflake.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/line_item_types.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/collector_mktassignments.view.lkml"
include: "/views/ANALYTICS/credit_app_master_list.view.lkml"
include: "/views/custom_sql/sales_rep_main_market.view.lkml"
include: "/views/custom_sql/asset_purchase_history_facts_final.view.lkml"
include: "/views/custom_sql/telematics_set_snowflake.view.lkml"
include: "/views/custom_sql/telematics_ts_snowflake.view.lkml"
include: "/views/custom_sql/work_order_payroll.view.lkml"
include: "/views/custom_sql/all_work_orders_prior_week_snowflake.view.lkml"
include: "/views/custom_sql/all_work_orders_ytd_snowflake.view.lkml"
include: "/views/custom_sql/payroll_hours.view.lkml"
include: "/views/custom_sql/work_order_summary.view.lkml"
include: "/views/custom_sql/ool.view.lkml"
include: "/views/custom_sql/aws_cost.view.lkml"
include: "/views/custom_sql/telematics_asset_info.view.lkml"
include: "/views/custom_sql/contractor_owned_es_rental_fleet.view.lkml"
include: "/views/custom_sql/telematics_branch_trend.view.lkml"
include: "/views/ES_WAREHOUSE/keypad_firmware.view.lkml"
include: "/views/ES_WAREHOUSE/tracker_firmware_version_log.view.lkml"
include: "/views/ES_WAREHOUSE/tracker_types.view.lkml"
include: "/views/ES_WAREHOUSE/tracker_vendors.view.lkml"
include: "/views/ES_WAREHOUSE/trackers_mapping.view.lkml"
include: "/views/ES_WAREHOUSE/cameras.view.lkml"
include: "/views/ES_WAREHOUSE/camera_vendors.view.lkml"
include: "/views/ES_WAREHOUSE/categories.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/telematics_health_report.view.lkml"
include: "/views/custom_sql/tracker_type_required.view.lkml"
include: "/views/ES_WAREHOUSE/v_out_of_lock.view.lkml"
include: "/views/ES_WAREHOUSE/out_of_lock_7_days_rolling.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ANALYTICS/rental_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/scd_asset_inventory_status.view.lkml"
include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
include: "/views/ES_WAREHOUSE/locations.view.lkml"
include: "/views/ES_WAREHOUSE/states.view.lkml"
include: "/views/custom_sql/last_complete_delivery.view.lkml"
include: "/views/ES_WAREHOUSE/trackers.view.lkml"
include: "/views/ES_WAREHOUSE/asset_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/keypad_controller_types.view.lkml"
include: "/views/custom_sql/sub_categories.view.lkml"
include: "/views/ES_WAREHOUSE/keypads.view.lkml"
include: "/views/ES_WAREHOUSE/keypad_asset_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/keypad_code_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/keypad_code_assignment_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/trackers_keypads.view.lkml"
include: "/views/ANALYTICS/telematics_regions.view.lkml"
include: "/views/custom_sql/es_owned_assets.view.lkml"
include: "/views/ES_WAREHOUSE/asset_last_location.view.lkml"
include: "/views/ANALYTICS/asset_ownership.view.lkml"



# datagroup: 6AM_update {
#   sql_trigger: SELECT FLOOR((EXTRACT(epoch from CURRENT_TIMESTAMP()) - 60*60*12)/(60*60*24)) ;;
#   max_cache_age: "24 hours"
# }

# datagroup: Every_Hour_Update {
#   sql_trigger: SELECT DATE_PART('hour', CURRENT_TIMESTAMP()) ;;
#   max_cache_age: "1 hour"
# }

# datagroup: Every_5_Min_Update {
#   sql_trigger: SELECT DATE_PART('minute', CURRENT_TIMESTAMP()) ;;
#   max_cache_age: "5 minutes"}


# explore: telematics_db_snowflake {
#   case_sensitive: no
#   persist_for: "1 minute"

#   join:telematics_all_assets_snowflake {
#     type:left_outer
#     relationship: one_to_one
#     sql_on: ${telematics_db_snowflake.asset_id}=${telematics_all_assets_snowflake.asset_id};;
#   }

#   join: assets {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${telematics_all_assets_snowflake.asset_id} =${assets.asset_id} ;;
#   }


#   join: asset_inventory_status {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${assets.asset_id}=${asset_inventory_status.asset_id} ;;
#   }

#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.company_id}=${companies.company_id} ;;
#   }

#   join: net_terms {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${companies.net_terms_id}=${net_terms.net_terms_id} ;;
#   }

#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${companies.company_id}=${markets.company_id} ;;
#   }

#   join: categories {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.category_id} = ${categories.category_id} ;;
#   }
# }

# explore: telematics_keypads { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
#   persist_for: "1 minute"
# }

# explore: telematics_ble {
#   case_sensitive: no
#   persist_for: "1 minute"

# }

# explore: owl_cam { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
#   persist_for: "1 minute"}

# explore: ool {
#   case_sensitive: no
#   persist_for: "1 minute"

#   join: asset_inventory_status {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${asset_inventory_status.asset_id} = ${ool.final_asset_id} ;;
#   }

#   join: work_orders {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${ool.final_asset_id} = ${work_orders.asset_id} ;;
#   }

# }

# explore: work_orders_by_tag { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
#   persist_for: "1 minute"



#     join: work_orders {
#       type: left_outer
#       relationship: many_to_one
#       sql_on: ${work_orders_by_tag.work_order_id} = ${work_orders.work_order_id} ;;
#     }

#     join: markets {
#       type: left_outer
#       relationship: many_to_one
#       sql_on: ${markets.market_id} = ${work_orders.branch_id} ;;
#     }

#     join: market_region_xwalk {
#       type: left_outer
#       relationship: many_to_one
#       sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#     }

#     join: assets {
#       type: left_outer
#       relationship: many_to_one
#       sql_on: ${work_orders.branch_id} = ${assets.inventory_branch_id} ;;
#     }

#     join: categories {
#       type: left_outer
#       relationship: many_to_one
#       sql_on: ${assets.category_id} = ${categories.category_id} ;;
#     }
#   }


# explore: top_20_work_orders_prior_week_snowflake { --MB comment out 10-10-23 due to inactivity
#     case_sensitive: no
#     persist_for: "1 minute"
#     sql_always_where: ${work_orders_by_tag.name} in ('New Tracker','New Keypad','Replace Tracker','Replace Keypad')
#         and ${work_orders_by_tag.date_completed_date} >= dateadd(day,-7,current_date)  ;;


#       join: work_orders_by_tag {
#         type: inner
#         relationship: many_to_one
#         sql_on: ${work_orders_by_tag.user_id} = ${top_20_work_orders_prior_week_snowflake.user_id} ;;
#       }

#       join: work_orders {
#         type: left_outer
#         relationship: many_to_one
#         sql_on: ${work_orders_by_tag.work_order_id} = ${work_orders.work_order_id} ;;
#       }

#       join: markets {
#         type: left_outer
#         relationship: many_to_one
#         sql_on: ${markets.market_id} = ${work_orders.branch_id} ;;
#       }

#       join: market_region_xwalk {
#         type: left_outer
#         relationship: many_to_one
#         sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#       }

#       join: assets {
#         type: left_outer
#         relationship: many_to_one
#         sql_on: ${work_orders.branch_id} = ${assets.inventory_branch_id} ;;
#       }

#       join: categories {
#         type: left_outer
#         relationship: many_to_one
#         sql_on: ${assets.category_id} = ${categories.category_id} ;;
#       }
#     }

    # explore: top_20_work_orders_ytd_snowflake { --MB comment out 10-10-23 due to inactivity
    #   case_sensitive: no
    #   persist_for: "1 minute"
    #   sql_always_where: ${work_orders_by_tag.name} in ('New Tracker','New Keypad','Replace Tracker','Replace Keypad')
    #         ;;


      # join: work_orders_by_tag {
      #   type: inner
      #   relationship: many_to_one
      #   sql_on: ${work_orders_by_tag.user_id} = ${top_20_work_orders_ytd_snowflake.user_id} ;;
      # }

      # join: work_orders {
      #   type: left_outer
      #   relationship: many_to_one
      #   sql_on: ${work_orders_by_tag.work_order_id} = ${work_orders.work_order_id} ;;
      # }

      # join: markets {
      #   type: left_outer
      #   relationship: many_to_one
      #   sql_on: ${markets.market_id} = ${work_orders.branch_id} ;;
      # }

      # join: market_region_xwalk {
      #   type: left_outer
      #   relationship: many_to_one
      #   sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
      # }

      # join: assets {
      #   type: left_outer
      #   relationship: many_to_one
      #   sql_on: ${work_orders.branch_id} = ${assets.inventory_branch_id} ;;
      # }

      # join: categories {
      #   type: left_outer
      #   relationship: many_to_one
      #   sql_on: ${assets.category_id} = ${categories.category_id} ;;
      # }
      #   }

# explore: invoices { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
#   sql_always_where: ${line_item_types.line_item_type_id} in (30,31,32,33,34) ;;


#   join: line_items {
#     type: inner
#     relationship: many_to_many
#     sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
#   }

#   join: line_item_types {
#     type: left_outer
#     relationship: many_to_one
#     sql_on:  ${line_items.line_item_type_id}=${line_item_types.line_item_type_id} ;;
#   }

#   join: assets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${line_items.asset_id}=${assets.asset_id}  ;;
#   }

#   join: asset_status_key_values {
#     type:  left_outer
#     relationship: one_to_one
#     sql_on: ${assets.asset_id} = ${asset_status_key_values.asset_id} ;;
#   }

#   join: asset_purchase_history_facts_final {
#     type:  left_outer
#     relationship:  one_to_one
#     sql_on: ${assets.asset_id} = ${asset_purchase_history_facts_final.asset_id} ;;
#   }

#   join: orders {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders.order_id} =${invoices.order_id};;
#   }

#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: coalesce(${orders.market_id},${assets.rental_branch_id},${assets.inventory_branch_id}) = ${markets.market_id} ;;
#   }


#   join: users {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders.salesperson_user_id} = ${users.user_id} ;;
#   }

#   join: customer {
#     from: users
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders.user_id} = ${customer.user_id} ;;
#   }

#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${customer.company_id} = ${companies.company_id} ;;
#   }


#   join: sales_rep_main_market {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${users.user_id} = ${sales_rep_main_market.salesperson_user_id} ;;
#   }

#   join: net_terms {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#   }

#   join: collector_mktassignments {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${collector_mktassignments.market_id} = ${markets.market_id} ;;
#   }

#   join: credit_app_master_list {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${users.user_id} = ${credit_app_master_list.salesperson_user_id} ;;
#   }

#   join: categories {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.category_id} = ${categories.category_id} ;;
#   }
# }

# explore: telematics_ts_snowflake { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
#   persist_for: "1 minute"


#   join: telematics_set_snowflake {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${telematics_ts_snowflake.asset_id} = ${telematics_set_snowflake.asset_id} ;;
#   }
# }

# explore: work_orders {
#   case_sensitive: no
#   sql_always_where: ${creator_user_id} in (46481,
#     32231,
#     31851,
#     17336,
#     21261,
#     20529,
#     11580,
#     47484,
#     24259,
#     29510,
#     28002,
#     10080,
#     50324,
#     28000,
#     7822,
#     16803,
#     45923,
#     31470,
#     11700,
#     9519,
#     20558,
#     15178,
#     29900,
#     45947,
#     28984,
#     31040,
#     20049,
#     12168,
#     30308,
#     19467,
#     36719,
#     32742,
#     19963,
#     20975,
#     12313,
#     31730,
#     16395,
#     30225,
#     37464,
#     38310,
#     16086,
#     42346,
#     15520,
#     29111,
#     15780
#     ) ;;

#     join: users {
#       type:  left_outer
#       relationship: many_to_one
#       sql_on: ${users.user_id} = ${work_orders.creator_user_id} ;;
#     }

#     join: work_order_payroll {
#       type:  left_outer
#       relationship: many_to_one
#       sql_on: ${work_order_payroll.user_id} = ${work_orders.creator_user_id} and ${work_order_payroll.work_order_id} = ${work_order_id} ;;
#     }

#   }


# explore: all_work_orders_prior_week_snowflake { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
#   persist_for: "1 minute"
#   sql_always_where: ${work_orders_by_tag.name} in ('New Tracker','New Keypad','Replace Tracker','Replace Keypad')
#     and ${work_orders_by_tag.date_completed_date} >= dateadd(day,-7,current_date)  ;;


#   join: work_orders_by_tag {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${work_orders_by_tag.user_id} = ${all_work_orders_prior_week_snowflake.user_id} ;;
#   }

#   join: work_orders {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${work_orders_by_tag.work_order_id} = ${work_orders.work_order_id} ;;
#   }

#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${markets.market_id} = ${work_orders.branch_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#   }

#   join: assets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${work_orders.branch_id} = ${assets.inventory_branch_id} ;;
#   }

#   join: categories {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.category_id} = ${categories.category_id} ;;
#   }
# }

# explore: all_work_orders_ytd_snowflake { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
#   persist_for: "1 minute"
#   sql_always_where: ${work_orders_by_tag.name} in ('New Tracker','New Keypad','Replace Tracker','Replace Keypad')
#     ;;


#   join: work_orders_by_tag {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${work_orders_by_tag.user_id} = ${all_work_orders_ytd_snowflake.user_id} ;;
#   }

#   join: work_orders {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${work_orders_by_tag.work_order_id} = ${work_orders.work_order_id} ;;
#   }

#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${markets.market_id} = ${work_orders.branch_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#   }

#   join: assets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${work_orders.branch_id} = ${assets.inventory_branch_id} ;;
#   }

#   join: categories {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.category_id} = ${categories.category_id} ;;
#   }
# }

# explore: payroll_hours {
#   case_sensitive: no
#   persist_for: "1 minute"

#   join: users {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${payroll_hours.user_id} = ${users.user_id} ;;
#   }

#   join: work_order_summary {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${payroll_hours.work_order_id} = ${work_order_summary.work_order_id} and ${payroll_hours.user_id} = ${work_order_summary.user_id} ;;
#   }

#   }

# explore: work_order_summary {
#   case_sensitive: no
#   persist_for: "1 minute"

#   join: users {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${work_order_summary.user_id} = ${users.user_id} ;;
#   }
# }

# explore: aws_cost{}

# explore: contractor_owned_es_rental_fleet { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
#   persist_for: "1 minute"}

# explore: telematics_new_tracker_work_order_no_tracker_id{} --MB comment out 10-10-23 due to inactivity

# explore: telematics_branch_trend{}

# explore: telematics_asset_info { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
#   }

# explore: es_owned_assets {}


explore: assets {
  label: "Tracker Master"
  case_sensitive: no
  # persist_for: "1 minute"
 sql_always_where: ((SUBSTR(TRIM(${assets.serial_number}), 1, 3) != 'RR-' and SUBSTR(TRIM(${assets.serial_number}), 1, 2) != 'RR') or ${assets.serial_number} is null)
                    and NOT (${assets.deleted})
                    and ${assets.company_id} <> 155 --excluding Jeff's Junkyard;;

  join: cameras {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.camera_id} = ${cameras.camera_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.company_id} = ${companies.company_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    #sql_on: ${assets.rental_branch_id} = ${markets.market_id} ;; --commenting out on 8/07/23 to add employee vehicles back in
    sql_on: coalesce(${assets.rental_branch_id}, ${assets.inventory_branch_id}) = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    #sql_on: ${assets.rental_branch_id} = ${market_region_xwalk.market_id} ;; --commenting out on 8/07/23 to add employee vehicles back in
    sql_on: coalesce(${assets.rental_branch_id}, ${assets.inventory_branch_id}) = ${market_region_xwalk.market_id} ;;
  }

  join: trackers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.tracker_id} = ${trackers.tracker_id} ;;
  }

  join: tracker_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trackers.tracker_type_id} = ${tracker_types.tracker_type_id} ;;
  }

  join: tracker_vendors {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trackers.vendor_id} = ${tracker_vendors.tracker_vendor_id} ;;
  }

  join: camera_vendors {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${cameras.camera_vendor_id} = ${camera_vendors.camera_vendor_id} ;;
  }

  join: trackers_mapping {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trackers.device_serial} = ${trackers_mapping.tracker_device_serial} ;;
  }

  join: tracker_firmware_version_log {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.tracker_id} = ${tracker_firmware_version_log.tracker_id} and ${tracker_firmware_version_log.end_timestamp} is null ;;
  }

  join: keypad_asset_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${keypad_asset_assignments.asset_id} and ${keypad_asset_assignments.end_date} is NULL ;;
  }

  join: keypads {
    type: left_outer
    relationship: many_to_one
    sql_on: ${keypad_asset_assignments.keypad_id} = ${keypads.keypad_id} ;;
  }

  join: keypad_code_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${keypad_asset_assignments.keypad_id} = ${keypad_code_assignments.keypad_id} ;;
  }

  join: keypad_code_assignment_statuses {
    type: left_outer
    relationship: many_to_one
    sql_on: ${keypad_code_assignments.keypad_code_assignment_status_id} = ${keypad_code_assignment_statuses.keypad_code_assignment_status_id} ;;
  }

  join: trackers_keypads {
    type: left_outer
    relationship: many_to_one
    sql_on: ${keypads.serial_number} = ${trackers_keypads.serial_number} ;;
  }

  join: keypad_controller_types {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${trackers_keypads.keypad_controller_type_id} = ${keypad_controller_types.keypad_controller_type_id};;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sub_categories.parent_category_id} = ${categories.category_id} ;;
  }

  # Switched to use parent category logic per Andrew Cowherd - 2022-09-16 BES

  join: sub_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.equipment_model_id} = ${sub_categories.equipment_model_id} ;;
  }

  join: equipment_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${equipment_assignments.asset_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_status_key_values.asset_id} ;;
  }

  join: asset_statuses {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_statuses.asset_id} ;;
  }

  join: telematics_health_report {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${telematics_health_report.asset_id} ;;
  }

  join: tracker_type_required {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${tracker_type_required.asset_id} ;;
  }

  join: v_out_of_lock {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${v_out_of_lock.asset_id} ;;
  }

  join: out_of_lock_7_days_rolling {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${out_of_lock_7_days_rolling.asset_id} ;;
  }

  join: work_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${work_orders.asset_id} ;;
  }

  join: work_orders_by_tag {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.work_order_id} = ${work_orders_by_tag.work_order_id} ;;
  }

  join: rentals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${rentals.asset_id} ;;
  }

  join: rental_statuses {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.rental_status_id} = ${rental_statuses.rental_status_id} ;;
  }

  join: scd_asset_inventory_status {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${scd_asset_inventory_status.asset_id} ;;
  }

  join: last_complete_delivery {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${assets.asset_id} = ${last_complete_delivery.asset_id};;
  }

  join: secondary_trackers {
    from:  assets
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = try_to_number(${secondary_trackers.custom_name}) and ${secondary_trackers.company_id} = 42268 ;;
  }

  # Telematics is running off of different regions than the rest of the company - PB
  join:  telematics_regions {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${telematics_regions.market_id} ;;
  }

  join: asset_last_location {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_last_location.asset_id} ;;
  }

  join:  asset_ownership {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_ownership.asset_id} ;;
  }
}
