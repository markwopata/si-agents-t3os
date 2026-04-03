connection: "es_snowflake_analytics"

include: "/views/custom_sql/telematics_mothership.view.lkml"
include: "/views/ANALYTICS/telematics_regions.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/trackers_mapping.view.lkml"
include: "/views/TRACKERS/current_morey_device_field_configurations.view.lkml"
include: "/views/custom_sql/telematics_mothership_hist.view.lkml"
include: "/views/custom_sql/morey_report_eid_config_check.view.lkml"
include: "/views/custom_sql/fleetcam_driver_scoring.view.lkml"
include: "/views/custom_sql/Keycode_usage_analysis.view.lkml"
include: "/views/ES_WAREHOUSE/work_orders.view.lkml"
include: "/views/ES_WAREHOUSE/work_orders_by_tag.view.lkml"
include: "/views/ES_WAREHOUSE/asset_purchase_history.view.lkml"
include: "/views/custom_sql/telematics_warehouse_all_shipments.view.lkml"
include: "/views/ANALYTICS/assets_sold_with_trackers.view.lkml"
include: "/views/FINANCIAL_SYSTEMS/T3_SAAS_GOLD/warehouse_shipment_data.view.lkml"
include: "/views/FINANCIAL_SYSTEMS/TELEMATICS_GOLD/devices_aggregate.view.lkml"
include: "/views/BUSINESS_INTELLIGENCE/fact_tracker_vbus_events.view.lkml"
include: "/views/BUSINESS_INTELLIGENCE/stg_t3__rental_status_info.view.lkml"

datagroup: mothership_data_update {
  sql_trigger: select max(DATA_REFRESH_TIMESTAMP) from business_intelligence.triage.stg_t3__telematics_health ;;
  max_cache_age: "1 hour"
  description: "Looker default is 1 hour. This ensures that even if it hasn't been an hour it will still update the data as triggered by the DATA_REFRESH_TIMESTAMP"
}

explore: telematics_mothership {
  persist_with: mothership_data_update
  case_sensitive: no

  join: trackers_mapping {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${telematics_mothership.tracker_id} = ${trackers_mapping.esdb_tracker_id} ;;
  }

  join: current_morey_device_field_configurations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${trackers_mapping.tracker_tracker_id} = ${current_morey_device_field_configurations.tracker_id};;
  }

  join: current_morey_vbus_configuration_only {
    from: current_morey_device_field_configurations
    type: left_outer
    relationship: one_to_many
    sql_on: ${trackers_mapping.tracker_tracker_id} = ${current_morey_vbus_configuration_only.tracker_id}
        and ${current_morey_vbus_configuration_only.configuration_eid} = '44d';;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: many_to_one
    sql_on: ${telematics_mothership.asset_id} = ${asset_purchase_history.asset_id} ;;
  }

  join: fact_tracker_vbus_events {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${telematics_mothership.tracker_serial} = ${fact_tracker_vbus_events.tracker_device_serial} ;;
  }

  join: stg_t3__rental_status_info {
    # Be careful, there can be multiple entries in here if there is also a reservation on a unit
    # Use filters to prevent duplicates
    type: left_outer
    relationship: one_to_many
    sql_on: ${telematics_mothership.asset_id} = ${stg_t3__rental_status_info.asset_id} ;;
  }
}


explore: telematics_mothership_hist {
  case_sensitive: no
}


explore: morey_report_eid_config_check {
  case_sensitive: no

  join: telematics_mothership {
    type: left_outer
    relationship: many_to_one
    sql_on: ${morey_report_eid_config_check.asset_id} = ${telematics_mothership.asset_id} ;;
  }
}

explore: fleetcam_driver_scoring {
  case_sensitive: no
}

explore: Keycode_usage_analysis {
  case_sensitive: no
}

explore: work_orders {
  label: "Telematics Work Orders"
  case_sensitive: no

  join: work_orders_by_tag {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders._work_order_id} = ${work_orders_by_tag.work_order_id} ;;
  }

  join: telematics_mothership {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${telematics_mothership.asset_id} ;;
  }
}

explore: telematics_warehouse_all_shipments {
  case_sensitive: no

  join: telematics_mothership_trackers {
    from: telematics_mothership
    type: left_outer
    relationship: many_to_one
    sql_on: ${telematics_warehouse_all_shipments.SERIAL_FORMATTED} = ${telematics_mothership_trackers.tracker_serial} ;;
  }

  join: telematics_mothership_keypads {
    from: telematics_mothership
    type: left_outer
    relationship: many_to_one
    sql_on: ${telematics_warehouse_all_shipments.SERIAL_FORMATTED} = ${telematics_mothership_keypads.keypad_serial} ;;
  }

  join: telematics_mothership_cameras {
    from: telematics_mothership
    type: left_outer
    relationship: many_to_one
    sql_on: ${telematics_warehouse_all_shipments.SERIAL_FORMATTED} = ${telematics_mothership_cameras.camera_serial} ;;
  }
}

explore: assets_sold_with_trackers {
  case_sensitive: no
}

explore: warehouse_shipment_data {
  case_sensitive: no

  join: devices_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${warehouse_shipment_data.shipped_serial_formatted} = ${devices_aggregate.serial_formatted} ;;
  }
}
