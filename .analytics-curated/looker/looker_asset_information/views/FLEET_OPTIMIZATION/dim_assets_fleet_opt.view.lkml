view: dim_assets_fleet_opt {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_ASSETS_FLEET_OPT"
    ;;

  dimension: asset_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}."ASSET_KEY" ;;
  }

  dimension: asset_source {
    type: string
    sql: ${TABLE}."ASSET_SOURCE" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_active {
    type: yesno
    sql: ${TABLE}."ASSET_ACTIVE" ;;
  }

  dimension: asset_year {
    type: string
    sql: ${TABLE}."ASSET_YEAR" ;;
  }

  dimension: asset_description {
    type: string
    sql: ${TABLE}."ASSET_DESCRIPTION" ;;
  }

  dimension: asset_vin {
    type: string
    sql: ${TABLE}."ASSET_VIN" ;;
  }

  dimension: asset_serial_number {
    type: yesno
    sql: ${TABLE}."ASSET_SERIAL_NUMBER" ;;
  }

  dimension: asset_inventory_market_id {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_MARKET_ID" ;;
  }

  dimension: asset_inventory_market_key {
    type: number
    hidden: yes
    sql: ${TABLE}."ASSET_INVENTORY_MARKET_KEY" ;;
  }

  dimension: asset_rental_market_id {
    type: string
    sql: ${TABLE}."ASSET_RENTAL_MARKET_ID" ;;
  }

  dimension: asset_rental_market_key {
    type: number
    hidden: yes
    sql: ${TABLE}."ASSET_RENTAL_MARKET_KEY" ;;
  }

  dimension: asset_service_market_id {
    type: string
    sql: ${TABLE}."ASSET_SERVICE_MARKET_ID" ;;
  }

  dimension: asset_service_market_key {
    type: number
    hidden: yes
    sql: ${TABLE}."ASSET_SERVICE_MARKET_KEY" ;;
  }

  dimension: asset_market_id {
    description: "This is a coalesce between Rental Branch ID and Inventory Branch ID. If an asset has a Rental Branch ID, that will always populate. If an asset does not have a Rental Branch ID but has an Inventory Branch ID, then that will populate. "
    type: string
    sql: ${TABLE}."ASSET_MARKET_ID" ;;
  }

  dimension: asset_market_key {
    type: number
    hidden: yes
    sql: ${TABLE}."ASSET_MARKET_KEY" ;;
  }

  dimension: asset_company_id {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }

  dimension: asset_company_key {
    type: number
    hidden: yes
    sql: ${TABLE}."ASSET_COMPANY_KEY" ;;
  }

  dimension: asset_equipment_make {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MAKE" ;;
  }

  dimension: asset_equipment_type {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_TYPE" ;;
  }

  dimension: asset_equipment_model_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MODEL_NAME" ;;
  }

  dimension: asset_equipment_class_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_CLASS_NAME" ;;
  }

  dimension: asset_equipment_class_id {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_CLASS_ID" ;;
  }

  dimension: asset_equipment_class_key {
    type: string
    hidden: yes
    sql: ${TABLE}."ASSET_EQUIPMENT_CLASS_ID" ;;
  }

  dimension: asset_equipment_subcategory_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_SUBCATEGORY_NAME" ;;
  }

  dimension: asset_equipment_category_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_CATEGORY_NAME" ;;
  }

  dimension: asset_equipment_contractor_owned {
    type: yesno
    sql: ${TABLE}."ASSET_EQUIPMENT_CONTRACTOR_OWNED" ;;
  }

  dimension: asset_payout_program {
    type: string
    sql: ${TABLE}."ASSET_PAYOUT_PROGRAM" ;;
  }

  dimension: asset_payout_program_type {
    type: string
    sql: ${TABLE}."ASSET_PAYOUT_PROGRAM_TYPE" ;;
  }

  dimension: asset_payout_program_billing_type {
    type: string
    sql: ${TABLE}."ASSET_PAYOUT_PROGRAM_BILLING_TYPE" ;;
  }

  dimension: asset_payout_program_percentage {
    type: string
    sql: ${TABLE}."ASSET_PAYOUT_PROGRAM_PERCENTAGE" ;;
  }

  dimension_group: asset_oem_delivery_date {
    type: time
    sql: ${TABLE}."ASSET_OEM_DELIVERY_DATE" ;;
  }

  dimension_group: asset_purchase_date {
    type: time
    sql: ${TABLE}."ASSET_PURCHASE_DATE" ;;
  }

  dimension: asset_current_oec {
    type: number
    sql: ${TABLE}."ASSET_CURRENT_OEC" ;;
  }

  dimension: asset_rentable {
    type: yesno
    sql: ${TABLE}."ASSET_RENTABLE" ;;
  }

  dimension_group: asset_first_rental_start_date {
    type: time
    sql: ${TABLE}."ASSET_FIRST_RENTAL_START_DATE" ;;
  }

  dimension_group: asset_most_recent_on_rent_date {
    type: time
    sql: ${TABLE}."ASSET_MOST_RECENT_ON_RENT_DATE" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension_group: asset_inventory_status_date {
    type: time
    sql: ${TABLE}."ASSET_INVENTORY_STATUS_DATE" ;;
  }

  dimension: asset_hours {
    type: string
    sql: ${TABLE}."ASSET_HOURS" ;;
  }

  dimension: asset_odometer {
    type: string
    sql: ${TABLE}."ASSET_ODOMETER" ;;
  }

  dimension: asset_underperforming_flag {
    type: yesno
    sql: ${TABLE}."ASSET_UNDERPERFORMING_FLAG" ;;
  }

  dimension: asset_never_rented {
    type: yesno
    sql: ${TABLE}."ASSET_NEVER_RENTED" ;;
  }

  dimension: asset_net_book_value_descriptive {
    type: number
    sql: ${TABLE}."ASSET_NET_BOOK_VALUE_DESCRIPTIVE" ;;
    value_format_name: usd
  }

  dimension: asset_own_flag {
    type: yesno
    sql: ${TABLE}."ASSET_OWN_FLAG" ;;
  }

  dimension: asset_deal_sales_flag {
    type: yesno
    sql: ${TABLE}."ASSET_DEAL_SALES_FLAG" ;;
  }

  dimension: asset_oem_deal_flag {
    type: yesno
    sql: ${TABLE}."ASSET_OEM_DEAL_FLAG" ;;
  }

  dimension: asset_abs_deal_flag {
    type: yesno
    sql: ${TABLE}."ASSET_ABS_DEAL_FLAG" ;;
  }

  dimension_group: asset_recordtimestamp {
    hidden: yes
    type: time
    sql: ${TABLE}."ASSET_RECORDTIMESTAMP" ;;
  }

  measure: count_of_assets {
    type: count
    description: "This is counting the primary key 'Asset Key' but it's the same count as counting distinct Asset ID(s)"
    filters: [asset_id: "--1"]
  }

  measure: total_oec {
    label: "Total Current OEC"
    type: sum
    sql: ${asset_current_oec} ;;
    value_format_name: usd
  }

  measure: total_descriptive_net_book_value {
    type: sum
    sql: ${asset_net_book_value_descriptive} ;;
    value_format_name: usd
  }

}
