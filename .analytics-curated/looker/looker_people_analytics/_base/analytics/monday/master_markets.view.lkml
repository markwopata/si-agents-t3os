view: master_markets {
  sql_table_name: "ANALYTICS"."MONDAY"."MASTER_MARKETS_BOARD" ;;

  dimension: actual_first_rental_date {
    type: date_raw
    sql: ${TABLE}."ACTUAL_FIRST_RENTAL_DATE" ;;
  }
  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }
  dimension: basic_operational_readiness_completed_date {
    type: date_raw
    sql: ${TABLE}."BASIC_OPERATIONAL_READINESS_COMPLETED_DATE" ;;
  }
  dimension: basic_operational_readiness_target_date {
    type: date_raw
    sql: ${TABLE}."BASIC_OPERATIONAL_READINESS_TARGET_DATE" ;;
  }
  dimension: board_id {
    type: string
    sql: ${TABLE}."BOARD_ID" ;;
  }
  dimension: branch_abbreviation {
    type: string
    sql: ${TABLE}."BRANCH_ABBREVIATION" ;;
  }
  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }
  dimension: building_type {
    type: string
    sql: ${TABLE}."TOTAL_ACRES" ;;
  }
  dimension: business_license_status {
    type: string
    sql: ${TABLE}."BUSINESS_LICENSE_STATUS" ;;
  }
  dimension: certificate_of_occupancy_status {
    type: string
    sql: ${TABLE}."CERTIFICATE_OF_OCCUPANCY_STATUS" ;;
  }
  dimension: close_date {
    type: date_raw
    sql: ${TABLE}."CLOSE_DATE" ;;
  }
  dimension: construction_project_manager_name {
    type: date_raw
    sql: ${TABLE}."CONSTRUCTION_PROJECT_MANAGER_NAME" ;;
  }
  dimension: division {
    type: string
    sql: ${TABLE}."DIVISION" ;;
  }
  dimension: drawings_status {
    type: string
    sql: ${TABLE}."DRAWINGS_STATUS" ;;
  }
  dimension: due_diligence_end_date {
    type: date_raw
    sql: ${TABLE}."DUE_DILIGENCE_END_DATE" ;;
  }
  dimension: early_fleet_placement_comments {
    type: string
    sql: ${TABLE}."EARLY_FLEET_PLACEMENT_COMMENTS" ;;
  }
  dimension: fleet_placement_flag {
    type: string
    sql: ${TABLE}."FLEET_PLACEMENT_FLAG" ;;
  }
  dimension: fleet_transportation_status {
    type: string
    sql: ${TABLE}."FLEET_TRANSPORTATION_STATUS" ;;
  }
  dimension: general_manager_email {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_EMAIL" ;;
  }
  dimension: general_manager_name {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_NAME" ;;
  }
  dimension: general_manager_recruiting_status {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_RECRUITING_STATUS" ;;
  }
  dimension: group_id {
    type: string
    sql: ${TABLE}."GROUP_ID" ;;
  }
  dimension: grouping_name {
    type: string
    sql: ${TABLE}."GROUPING_NAME" ;;
  }
  dimension: group_title {
    type: string
    sql: ${TABLE}."GROUP_TITLE" ;;
  }
  dimension: is_acive_project {
    type: yesno
    sql: ${TABLE}."IS_ACTIVE_PROJECT" ;;
  }
  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: last_updated_date {
    type: date_raw
    sql: ${TABLE}."LAST_UPDATED_DATE" ;;
  }
  dimension: launch_phase {
    type: string
    sql: ${TABLE}."LAUNCH_PHASE" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }
  dimension: new_market_notifications_status {
    type: string
    sql: ${TABLE}."NEW_MARKET_NOTIFICATIONS_STATUS" ;;
  }
  dimension: office_sq_ft {
    type: string
    sql: ${TABLE}."OFFICE_SQ_FT" ;;
  }
  dimension: point_of_contact_status {
    type: string
    sql: ${TABLE}."POINT_OF_CONTACT_STATUS" ;;
  }
  dimension: possession_date {
    type: date_raw
    sql: ${TABLE}."POSSESSION_DATE" ;;
  }
  dimension: project_manager_name {
    type: string
    sql: ${TABLE}."PROJECT_MANAGER_NAME" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }
  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }
  dimension: sales_service_email {
    type: string
    sql: ${TABLE}."SALES_SERVICE_EMAIL" ;;
  }
  dimension: shop_sq_ft {
    type: string
    sql: ${TABLE}."SHOP_SQ_FT" ;;
  }
  dimension: target_construction_completion_date {
    type: date_raw
    sql: ${TABLE}."TARGET_CONSTRUCTION_COMPLETION_DATE" ;;
  }
  dimension: total_acres {
    type: number
    sql: ${TABLE}."TOTAL_ACRES" ;;
  }
  dimension: total_sq_ft {
    type: number
    sql: ${TABLE}."TOTAL_SQ_FT" ;;
  }
  dimension: transaction_type {
    type: string
    sql: ${TABLE}."TRANSACTION_TYPE" ;;
  }
  dimension: url_market_google_drive_folder {
    type: string
    sql: ${TABLE}."URL_MARKET_GOOGLE_DRIVE_FOLDER" ;;
  }
  dimension: usable_acres {
    type: number
    sql: ${TABLE}."USABLE_ACRES" ;;
  }
  dimension: utilities_status {
    type: string
    sql: ${TABLE}."UTILITIES_STATUS" ;;
  }
  dimension: washbay_completion_date {
    type: date_raw
    sql: ${TABLE}."WASHBAY_COMPLETION_DATE" ;;
  }
  dimension: yard_status {
    type: string
    sql: ${TABLE}."YARD_STATUS" ;;
  }
  measure: count {
    type: count
    drill_fields: [grouping_name]
  }
}
