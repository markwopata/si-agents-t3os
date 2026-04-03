view: v_assets {
  view_label: "Assets"
  sql_table_name: "GOLD"."V_ASSETS" ;;

  dimension: asset_active {
    type: yesno
    sql: ${TABLE}."ASSET_ACTIVE" ;;
  }
  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }
  dimension: asset_company_id {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }
  dimension: asset_company_key {
    type: number
    sql: ${TABLE}."ASSET_COMPANY_KEY" ;;
  }
  dimension: asset_company_name {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_NAME" ;;
  }
  dimension: asset_current_oec {
    type: number
    sql: ${TABLE}."ASSET_CURRENT_OEC" ;;
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
  dimension: asset_first_rental_start {
    type: date
    convert_tz: no
    sql: ${TABLE}."ASSET_FIRST_RENTAL_START_DATE" ;;
  }
  dimension: asset_hours {
    type: number
    sql: ${TABLE}."ASSET_HOURS" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_inventory_market_id {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_MARKET_ID" ;;
  }
  dimension: asset_inventory_market_key {
    type: number
    sql: ${TABLE}."ASSET_INVENTORY_MARKET_KEY" ;;
  }
  dimension: asset_inventory_market_name {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_MARKET_NAME" ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }
  dimension: asset_inventory_status_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."ASSET_INVENTORY_STATUS_DATE" ;;
  }
  dimension: asset_key {
    type: number
    primary_key: yes
    sql: ${TABLE}."ASSET_KEY" ;;
  }
  dimension: asset_market_id {
    type: string
    sql: ${TABLE}."ASSET_MARKET_ID" ;;
  }
  dimension: asset_market_key {
    type: number
    sql: ${TABLE}."ASSET_MARKET_KEY" ;;
  }
  dimension: asset_market_name {
    type: string
    sql: ${TABLE}."ASSET_MARKET_NAME" ;;
  }
  dimension: asset_most_recent_on_rent_date {
    type: date
    convert_tz: no
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
  dimension: asset_oem_delivery_date {
    type: date
    convert_tz: no
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
  dimension: asset_purchase_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."ASSET_PURCHASE_DATE" ;;
  }
  dimension: asset_recordtimestamp {
    type: date
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
    type: number
    sql: ${TABLE}."ASSET_RENTAL_MARKET_KEY" ;;
  }
  dimension: asset_rental_market_name {
    type: string
    sql: ${TABLE}."ASSET_RENTAL_MARKET_NAME" ;;
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
    type: number
    sql: ${TABLE}."ASSET_SERVICE_MARKET_KEY" ;;
  }
  dimension: asset_service_market_name {
    type: string
    sql: ${TABLE}."ASSET_SERVICE_MARKET_NAME" ;;
  }
  dimension: asset_source {
    type: string
    sql: ${TABLE}."ASSET_SOURCE" ;;
  }
  dimension: asset_underperforming_flag {
    type: yesno
    sql: ${TABLE}."ASSET_UNDERPERFORMING_FLAG" ;;
  }
  dimension: asset_vin {
    type: string
    sql: ${TABLE}."ASSET_VIN" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  asset_source,
  asset_id,
  asset_active,
  asset_equipment_type,
  asset_equipment_category_name,
  asset_equipment_subcategory_name,
  asset_equipment_class_name,
  asset_equipment_model_name,
  asset_company_name,
  asset_market_name,
  asset_inventory_market_name,
  asset_service_market_name,
  asset_rental_market_name
  ]
  }

}
