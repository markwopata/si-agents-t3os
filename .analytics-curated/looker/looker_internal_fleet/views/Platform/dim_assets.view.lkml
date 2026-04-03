view: dim_assets {
  sql_table_name: "PLATFORM"."GOLD"."DIM_ASSETS" ;;

  dimension: asset_active {
    type: yesno
    sql: ${TABLE}."ASSET_ACTIVE" ;;
  }
  dimension: asset_alert_enter_geofence {
    type: yesno
    sql: ${TABLE}."ASSET_ALERT_ENTER_GEOFENCE" ;;
  }
  dimension: asset_alert_exit_geofence {
    type: yesno
    sql: ${TABLE}."ASSET_ALERT_EXIT_GEOFENCE" ;;
  }
  dimension: asset_company_id {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }
  dimension: asset_company_key {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_KEY" ;;
  }
  dimension: asset_current_oec {
    type: number
    sql: ${TABLE}."ASSET_CURRENT_OEC" ;;
  }
  dimension_group: asset_date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_DATE_CREATED" ;;
  }
  dimension_group: asset_date_updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_DATE_UPDATED" ;;
  }
  dimension: asset_description {
    type: string
    sql: ${TABLE}."ASSET_DESCRIPTION" ;;
  }
  dimension: asset_equipment_category_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_CATEGORY_NAME" ;;
  }
  dimension: asset_equipment_class_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_CLASS_NAME" ;;
  }
  dimension: asset_equipment_contractor_owned {
    type: yesno
    sql: ${TABLE}."ASSET_EQUIPMENT_CONTRACTOR_OWNED" ;;
  }
  dimension: asset_equipment_make {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MAKE" ;;
  }
  dimension: asset_equipment_model_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MODEL_NAME" ;;
  }
  dimension: asset_equipment_subcategory_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_SUBCATEGORY_NAME" ;;
  }
  dimension: asset_equipment_type {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_TYPE" ;;
  }
  dimension_group: asset_first_rental_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_FIRST_RENTAL_START_DATE" ;;
  }
  dimension: asset_hours {
    type: number
    sql: ${TABLE}."ASSET_HOURS" ;;
  }
  dimension: asset_id {
    type: string
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_id_with_t3_link {
    type: number
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{asset_id}}/history" target="_blank">{{ asset_id._value }}</a></font></u> ;;
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_ifta_reporting {
    type: yesno
    sql: ${TABLE}."ASSET_IFTA_REPORTING" ;;
  }
  dimension: asset_inventory_market_id {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_MARKET_ID" ;;
  }
  dimension: asset_inventory_market_key {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_MARKET_KEY" ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }
  dimension_group: asset_inventory_status {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_INVENTORY_STATUS_DATE" ;;
  }
  dimension: asset_key {
    type: string
    sql: ${TABLE}."ASSET_KEY" ;;
  }
  dimension: asset_last_location {
    type: string
    sql: ${TABLE}."ASSET_LAST_LOCATION" ;;
  }
  dimension: asset_market_id {
    type: string
    sql: ${TABLE}."ASSET_MARKET_ID" ;;
  }
  dimension: asset_market_key {
    type: string
    sql: ${TABLE}."ASSET_MARKET_KEY" ;;
  }
  dimension_group: asset_most_recent_on_rent {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_MOST_RECENT_ON_RENT_DATE" ;;
  }
  dimension: asset_net_book_value {
    type: number
    sql: ${TABLE}."ASSET_NET_BOOK_VALUE" ;;
  }
  dimension: asset_never_rented {
    type: yesno
    sql: ${TABLE}."ASSET_NEVER_RENTED" ;;
  }
  dimension: asset_odometer {
    type: number
    sql: ${TABLE}."ASSET_ODOMETER" ;;
  }
  dimension_group: asset_oem_delivery {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_OEM_DELIVERY_DATE" ;;
  }
  dimension: asset_payout_program {
    type: string
    sql: ${TABLE}."ASSET_PAYOUT_PROGRAM" ;;
  }
  dimension: asset_payout_program_billing_type {
    type: string
    sql: ${TABLE}."ASSET_PAYOUT_PROGRAM_BILLING_TYPE" ;;
  }
  dimension: asset_payout_program_percentage {
    type: number
    sql: ${TABLE}."ASSET_PAYOUT_PROGRAM_PERCENTAGE" ;;
  }
  dimension: asset_payout_program_type {
    type: string
    sql: ${TABLE}."ASSET_PAYOUT_PROGRAM_TYPE" ;;
  }
  dimension_group: asset_purchase {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_PURCHASE_DATE" ;;
  }
  dimension_group: asset_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."ASSET_RECORDTIMESTAMP" ;;
  }
  dimension: asset_rentable {
    type: yesno
    sql: ${TABLE}."ASSET_RENTABLE" ;;
  }
  dimension: asset_rental_market_id {
    type: string
    sql: ${TABLE}."ASSET_RENTAL_MARKET_ID" ;;
  }
  dimension: asset_rental_market_key {
    type: string
    sql: ${TABLE}."ASSET_RENTAL_MARKET_KEY" ;;
  }
  dimension: asset_serial_number {
    type: string
    sql: ${TABLE}."ASSET_SERIAL_NUMBER" ;;
  }
  dimension: asset_service_market_id {
    type: string
    sql: ${TABLE}."ASSET_SERVICE_MARKET_ID" ;;
  }
  dimension: asset_service_market_key {
    type: string
    sql: ${TABLE}."ASSET_SERVICE_MARKET_KEY" ;;
  }
  dimension: asset_source {
    type: string
    sql: ${TABLE}."ASSET_SOURCE" ;;
  }
  dimension: asset_tracker_id {
    type: number
    sql: ${TABLE}."ASSET_TRACKER_ID" ;;
  }
  dimension: asset_underperforming_flag {
    type: yesno
    sql: ${TABLE}."ASSET_UNDERPERFORMING_FLAG" ;;
  }
  dimension: asset_vin {
    type: string
    sql: ${TABLE}."ASSET_VIN" ;;
  }
  dimension: asset_year {
    type: number
    sql: ${TABLE}."ASSET_YEAR" ;;
  }
  measure: count {
    type: count
    drill_fields: [asset_equipment_class_name, asset_equipment_model_name, asset_equipment_subcategory_name, asset_equipment_category_name]
  }
}
