view: tracker_type_required {
  derived_table: {
    sql: select ASS.ASSET_ID,
       TTR.Tracker_Req_Type,
       case
           when TTR.Tracker_Req_Type = 'Uncategorized' then 'Uncategorized'
           when TTR.Tracker_Req_Type = 'No Tracker Needed' then 'No Tracker Needed'
           when TTR.Tracker_Req_Type = 'Un-trackable' then 'Un-trackable'
           when ASS.TRACKER_ID is null then 'NO TRACKER'
           --Per Bryan Walsh May 2023 wants these specific model(s) to say correct tracker if it has ANY kind of tracker - PB
           when ASS.TRACKER_ID is not null
               and (UPPER(ASS.MODEL) like UPPER('E-AIRH 250%') or UPPER(ASS.MAKE) like UPPER('SMARTECH')
                  or (UPPER(ASS.MAKE) like UPPER('CAPS') and UPPER(ASS.MODEL) like UPPER('PCHH%'))
                  or (UPPER(ASS.MAKE) like UPPER('PIONEER') and UPPER(ASS.MODEL) like UPPER('EPP66%'))) then 'CORRECT TRACKER'
           when TTR.Tracker_Req_Type = 'MC-4+ ONLY' and TRK.TRACKER_TYPE_ID in (23, 39, 40, 41) then 'CORRECT TRACKER'
           when TTR.Tracker_Req_Type = 'MC-4+ or PUI-CAN' and TRK.TRACKER_TYPE_ID in (23, 30, 31, 39, 40, 41) then 'CORRECT TRACKER'
           --Per Bryan Walsh Jan 2023 we need to make an exception for 2830 type trackers to be OK for MC4 installs due to availability issues - PB
           when TTR.Tracker_Req_Type = 'MC-4+ or PUI-CAN' and TRK.TRACKER_TYPE_ID in (4)
              --Per Bryan Walsh May 2023, making exception for 'Smartech' units that come with MC4's but dont need them due to shortages
               and (TTR.HAS_CAN = 'NO' OR upper(ASS.MAKE) like upper('%SMARTECH%')) then 'CORRECT TRACKER'
           when TTR.Tracker_Req_Type = 'MCX/LMU' and TRK.TRACKER_TYPE_ID in (1, 37) then 'CORRECT TRACKER'
           when TTR.Tracker_Req_Type = 'Slap N Track' and TRK.TRACKER_TYPE_ID in (25, 26, 34, 38) then 'CORRECT TRACKER'
           when TTR.Tracker_Req_Type = 'BLE Attachment' and TRK.TRACKER_TYPE_ID in (24) then 'CORRECT TRACKER'
           when TTR.Tracker_Req_Type = 'BLE tool' and TRK.TRACKER_TYPE_ID in (21, 22, 35, 36, 68) then 'CORRECT TRACKER'
           else 'INCORRECT TRACKER'
           end
                             as TRACKER_INSTALL_STATUS,
       TTR.KEYPAD_REQ,
       case
           when KPAD.KEYPAD_ASSET_ASSIGNMENT_ID is not null then 'Keypad'
           when TTR.Keypad_Req = 'Keypad Required' and KPAD.KEYPAD_ASSET_ASSIGNMENT_ID is null then 'Missing Keypad'
           else 'No Keypad Required'
           end
                             as KEYPAD_INSTALL_STATUS,
       TTR.KEYPAD_REQ_TYPE,
       TTR.SECONDARY_TRACKER as Secondary_Tracker_Req,
       TTR.CAMERA_REQ,
       case
           when TTR.CAMERA_REQ = 'Camera Required' and CAM.CAMERA_ID is not null then 'Camera'
           when TTR.CAMERA_REQ = 'Camera Required' and CAM.CAMERA_ID is null then 'MISSING CAMERA'
           else 'No Camera Required'
           end
                             as CAMERA_INSTALL_STATUS,
       TTR.HAS_CAN
from ES_WAREHOUSE.PUBLIC.ASSETS ASS
         left join ANALYTICS.LOOKER_INPUTS.TRACKER_TYPE_REQUIRED TTR
                   on UPPER(ASS.MAKE) = UPPER(TTR.MAKE) and UPPER(ASS.MODEL) = UPPER(TTR.MODEL)
         left join ES_WAREHOUSE.PUBLIC.ASSET_CAMERA_ASSIGNMENTS CAM
                   on ASS.ASSET_ID = CAM.ASSET_ID
                       and CAM.DATE_UNINSTALLED is NULL
         left join ES_WAREHOUSE.PUBLIC.TRACKERS TRK
                   on ASS.TRACKER_ID = TRK.TRACKER_ID
         left join ES_WAREHOUSE.PUBLIC.KEYPAD_ASSET_ASSIGNMENTS KPAD
                   on ASS.ASSET_ID = KPAD.ASSET_ID
                       and KPAD.END_DATE is NULL
      ;;
  }

  dimension: tracker_install_status {
    type: string
    sql: ${TABLE}."TRACKER_INSTALL_STATUS" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_id_with_t3_service_link {
    type: number
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{asset_id}}/service" target="_blank">{{ asset_id._value }}</a></font></u> ;;
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: installed_tracker_type {
    type: string
    sql: ${TABLE}."INSTALLED_TRACKER_TYPE" ;;
  }

  dimension: tracker_req_type {
    type: string
    sql: ${TABLE}."TRACKER_REQ_TYPE" ;;
  }

  dimension: keypad_req {
    type: string
    sql: ${TABLE}."KEYPAD_REQ" ;;
  }

  dimension: keypad_req_type {
    type: string
    sql: ${TABLE}."KEYPAD_REQ_TYPE" ;;
  }

  dimension: keypad_install_status {
    type: string
    sql: ${TABLE}."KEYPAD_INSTALL_STATUS" ;;
  }

  dimension: secondary_tracker_req {
    type: string
    sql: ${TABLE}."SECONDARY_TRACKER_REQ" ;;
  }

  dimension: camera_req {
    type: string
    sql: ${TABLE}."CAMERA_REQ" ;;
  }

  dimension: camera_install_status {
    type: string
    sql: ${TABLE}."CAMERA_INSTALL_STATUS" ;;
  }

  dimension: has_can {
    type: string
    sql: ${TABLE}."HAS_CAN" ;;
  }

  measure: count_of_assets_with_fleetcam_cameras {
    type: count
    drill_fields: [detail*]
    filters: [camera_vendors.name: "fleetcam"]
    html: <font color="green">{{ value }}</font>;;
  }

  measure: total_count_of_units_missing_fleetcam {
    type: count
    drill_fields: [detail*]
    filters: [camera_vendors.name: "-fleetcam"]
    html: <font color="red">{{ value }}</font>;;
  }

  measure: count_of_assets_with_owlcam_cameras {
    type: count
    drill_fields: [detail*]
    filters: [camera_vendors.name: "owlcam"]
    html: <font color="gold">{{ value }}</font>;;
  }

  # measure: count_of_assets_needing_a_camera {
  #   type: count
  #   drill_fields: [detail*]
  #   filters: [camera_vendors.name: "NULL", camera_install_status: "MISSING CAMERA"]
  # }

  # measure: count_of_assets_with_cameras_without_type {
  #   type: count
  #   drill_fields: [detail*]
  #   filters: [camera_vendors.name: "NULL", camera_install_status: "Camera"]
  # }

  measure: correct_installed_tracker_count {
    type:  count
    drill_fields: [detail_2*]
    filters: [tracker_install_status: "CORRECT TRACKER"]
  }

  measure: Incorrect_or_no_tracker_count {
    type:  count
    drill_fields: [detail_2*]
    filters: [tracker_install_status: "NO TRACKER, INCORRECT TRACKER"]
  }

  measure: telematics_install_score {
    type:  number
    value_format: "0.0\%"
    drill_fields: [detail_2*]
    sql:  (${correct_installed_tracker_count}/NULLIF((${correct_installed_tracker_count}+${Incorrect_or_no_tracker_count}), 0)) * 100 ;;
  }

  measure: telematics_total_KPI {
    type:  number
    value_format: "0.0\%"
    drill_fields: [detail_2*]
    sql:  ((${asset_statuses.healthy_tracker_count}+${correct_installed_tracker_count})/
    NULLIF((${asset_statuses.healthy_tracker_count}+${asset_statuses.unhealthy_tracker_count}+${correct_installed_tracker_count}+${Incorrect_or_no_tracker_count}), 0)) * 100 ;;
  }

  # dimension: telematics_grade {
  #   type: string
  #   sql: case when ${telematics_total_KPI} => 97 then 'A+'
  #             when ${telematics_total_KPI} => 93 and ${telematics_total_KPI} < 97 then 'A'
  #       else 'F'
  #       END ;;
  # }

  set: detail {
    fields: [market_region_xwalk.market_name,
      asset_id_with_t3_service_link,
      assets.make,
      assets.model,
      categories.name,
      tracker_req_type,
      tracker_types.name,
      tracker_install_status,
      has_can,
      trackers.serial_with_trackers_manager_link,
      # tracker_firmware_version_log.firmware_version,
      keypad_req,
      keypad_controller_types.keypad_controller_name,
      keypads.serial_number,
      trackers_keypads.firmware_version,
      camera_req,
      camera_vendors.name,
      asset_statuses.asset_inventory_status,
      last_complete_delivery.jobsite_link,
      asset_statuses.disconnected_tracker,
      asset_statuses.dead_batteries,
      asset_statuses.battery_voltage,
      asset_statuses.no_communication_in_greater_than_96hrs,
      asset_statuses.last_checkin_timestamp,
      asset_statuses.no_gps_in_greater_than_96hrs,
      asset_statuses.last_location_timestamp,
      asset_statuses.tracker_health
    ]
  }

  set: detail_2 {
    fields: [market_region_xwalk.market_name,
      asset_id,
      assets.rental_branch_id,
      assets.service_branch_id,
      assets.make,
      assets.model,
      categories.name,
      tracker_req_type,
      tracker_types.name,
      tracker_install_status,
      has_can,
      trackers.serial_with_trackers_manager_link,
      # tracker_firmware_version_log.firmware_version,
      keypad_req,
      keypad_controller_types.keypad_controller_name,
      keypads.serial_number,
      trackers_keypads.firmware_version,
      camera_req,
      asset_statuses.asset_inventory_status,
      # last_complete_delivery.jobsite_link,
      asset_statuses.disconnected_tracker,
      asset_statuses.dead_batteries,
      asset_statuses.battery_voltage,
      asset_statuses.no_communication_in_greater_than_96hrs,
      asset_statuses.last_checkin_timestamp,
      asset_statuses.no_gps_in_greater_than_96hrs,
      asset_statuses.last_location_timestamp,
      asset_statuses.tracker_health
    ]
  }
}
