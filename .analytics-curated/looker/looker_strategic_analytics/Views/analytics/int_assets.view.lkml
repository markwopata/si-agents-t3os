
view: int_assets {
  sql_table_name: analytics.assets.int_assets ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_type_id {
    type: string
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: equipment_make_id {
    type: string
    sql: ${TABLE}."EQUIPMENT_MAKE_ID" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: equipment_model_id {
    type: string
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: license_plate_number {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_NUMBER" ;;
  }

  dimension: serial_number_or_vin {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_OR_VIN" ;;
  }

  dimension: equipment_class_id {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: category_id {
    type: string
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: parent_category_id {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_ID" ;;
  }

  dimension: parent_category_name {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_NAME" ;;
  }

  dimension: sub_category_id {
    type: string
    sql: ${TABLE}."SUB_CATEGORY_ID" ;;
  }

  dimension: sub_category_name {
    type: string
    sql: ${TABLE}."SUB_CATEGORY_NAME" ;;
  }

  dimension: asset_company_id {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }

  dimension: owning_company_name {
    type: string
    sql: ${TABLE}."OWNING_COMPANY_NAME" ;;
  }

  dimension: is_es_owned_company {
    type: yesno
    sql: ${TABLE}."IS_ES_OWNED_COMPANY" ;;
  }

  dimension: rental_branch_id {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: rental_branch_name {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_NAME" ;;
  }

  dimension: inventory_branch_id {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: inventory_branch_name {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH_NAME" ;;
  }

  dimension: service_branch_id {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }

  dimension: service_branch_name {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH_NAME" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_company_id {
    type: number
    sql: ${TABLE}."MARKET_COMPANY_ID" ;;
  }

  dimension: is_managed_by_es_owned_market {
    type: yesno
    sql: ${TABLE}."IS_MANAGED_BY_ES_OWNED_MARKET" ;;
  }

  dimension: is_rerent_asset {
    type: yesno
    sql: ${TABLE}."IS_RERENT_ASSET" ;;
  }

  dimension: is_in_transit {
    type: yesno
    sql: ${TABLE}."IS_IN_TRANSIT" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension_group: first_rental_date {
    type: time
    sql: ${TABLE}."FIRST_RENTAL_DATE" ;;
  }

  dimension_group: latest_rental_start_date {
    type: time
    sql: ${TABLE}."LATEST_RENTAL_START_DATE" ;;
  }

  dimension_group: last_rental_date {
    type: time
    sql: ${TABLE}."LAST_RENTAL_DATE" ;;
  }

  dimension_group: last_off_rent_date {
    type: time
    sql: ${TABLE}."LAST_OFF_RENT_DATE" ;;
  }

  dimension_group: purchase_date {
    type: time
    sql: ${TABLE}."PURCHASE_DATE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
    value_format_name: usd
  }

  measure: oec_sum {
    type: sum
    sql: ${oec} ;;
    value_format_name: usd
  }

  dimension: business_segment_id {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT_ID" ;;
  }

  dimension: business_segment_name {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT_NAME" ;;
  }

  dimension: tracker_id {
    type: string
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension_group: tracker_install_date {
    type: time
    sql: ${TABLE}."TRACKER_INSTALL_DATE" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: payout_program_id {
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_ID" ;;
  }

  dimension: payout_program_name {
    type: string
    sql: ${TABLE}."PAYOUT_PROGRAM_NAME" ;;
  }

  dimension: payout_program_type_id {
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_TYPE_ID" ;;
  }

  dimension: payout_program_type {
    type: string
    sql: ${TABLE}."PAYOUT_PROGRAM_TYPE" ;;
  }

  dimension: asset_payout_percentage {
    type: number
    sql: ${TABLE}."ASSET_PAYOUT_PERCENTAGE" ;;
  }

  dimension: is_payout_program_unpaid {
    type: yesno
    sql: ${TABLE}."IS_PAYOUT_PROGRAM_UNPAID" ;;
  }

  dimension: is_payout_program_enrolled {
    type: yesno
    sql: ${TABLE}."IS_PAYOUT_PROGRAM_ENROLLED" ;;
  }

  dimension: is_own_program_asset {
    type: yesno
    sql: ${TABLE}."IS_OWN_PROGRAM_ASSET" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: inventory_transit_status {
    type: string
    sql: ${TABLE}."INVENTORY_TRANSIT_STATUS" ;;
  }

  dimension: battery_voltage_type_id {
    type: string
    sql: ${TABLE}."BATTERY_VOLTAGE_TYPE_ID" ;;
  }

  dimension: battery_voltage_type {
    type: string
    sql: ${TABLE}."BATTERY_VOLTAGE_TYPE" ;;
  }

  dimension: url_admin {
    type: string
    sql: ${TABLE}."URL_ADMIN" ;;
  }

  dimension: url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
  }

  dimension: is_deleted {
    type: yesno
    sql: ${TABLE}."IS_DELETED" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension_group: date_deleted {
    type: time
    sql: ${TABLE}."DATE_DELETED" ;;
  }

  set: detail {
    fields: [
        asset_id,
  asset_type_id,
  asset_type,
  equipment_make_id,
  make,
  equipment_model_id,
  model,
  year,
  custom_name,
  serial_number,
  vin,
  license_plate_number,
  serial_number_or_vin,
  equipment_class_id,
  equipment_class,
  category_id,
  category,
  parent_category_id,
  parent_category_name,
  sub_category_id,
  sub_category_name,
  asset_company_id,
  owning_company_name,
  is_es_owned_company,
  rental_branch_id,
  rental_branch_name,
  inventory_branch_id,
  inventory_branch_name,
  service_branch_id,
  service_branch_name,
  state,
  market_id,
  market_name,
  market_company_id,
  is_managed_by_es_owned_market,
  is_rerent_asset,
  is_in_transit,
  status,
  first_rental_date_time,
  latest_rental_start_date_time,
  last_rental_date_time,
  last_off_rent_date_time,
  purchase_date_time,
  invoice_number,
  oec,
  business_segment_id,
  business_segment_name,
  tracker_id,
  tracker_install_date_time,
  description,
  payout_program_id,
  payout_program_name,
  payout_program_type_id,
  payout_program_type,
  asset_payout_percentage,
  is_payout_program_unpaid,
  is_payout_program_enrolled,
  is_own_program_asset,
  asset_inventory_status,
  inventory_transit_status,
  battery_voltage_type_id,
  battery_voltage_type,
  url_admin,
  url_t3,
  is_deleted,
  date_created_time,
  date_updated_time,
  date_deleted_time
    ]
  }
}
