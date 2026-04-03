view: dim_assets_fleet_opt {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_ASSETS_FLEET_OPT" ;;

  dimension: asset_abl_flag {
    type: yesno
    sql: ${TABLE}."ASSET_ABL_FLAG" ;;
  }
  dimension: asset_abs_flag {
    type: yesno
    sql: ${TABLE}."ASSET_ABS_FLAG" ;;
  }
  dimension: asset_active {
    type: yesno
    sql: ${TABLE}."ASSET_ACTIVE" ;;
  }
  dimension: asset_bench_target_price {
    type: number
    sql: ${TABLE}."ASSET_BENCH_TARGET_PRICE" ;;
  }
  dimension: asset_company_id {
    type: number
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
    value_format_name: id
  }
  dimension: asset_company_key {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_KEY" ;;
  }
  dimension: asset_current_finance_status {
    type: string
    sql: ${TABLE}."ASSET_CURRENT_FINANCE_STATUS" ;;
  }
  dimension: asset_current_net_book_value {
    type: number
    sql: ${TABLE}."ASSET_CURRENT_NET_BOOK_VALUE" ;;
    value_format_name: usd
  }
  dimension: asset_current_oec {
    type: number
    sql: ${TABLE}."ASSET_CURRENT_OEC" ;;
    value_format_name: usd
  }
  dimension: asset_custom_name {
    type: string
    sql: ${TABLE}."ASSET_CUSTOM_NAME" ;;
  }
  dimension_group: asset_date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_DATE_CREATED" ;;
  }
  dimension: asset_deal_sales_flag {
    type: yesno
    sql: ${TABLE}."ASSET_DEAL_SALES_FLAG" ;;
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
  dimension: asset_equipment_make_and_model {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MAKE_AND_MODEL" ;;
  }
  dimension: asset_equipment_make_id {
    type: number
    sql: ${TABLE}."ASSET_EQUIPMENT_MAKE_ID" ;;
    value_format_name: id
  }
  dimension: asset_equipment_model_id {
    type: number
    sql: ${TABLE}."ASSET_EQUIPMENT_MODEL_ID" ;;
    value_format_name: id
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
  dimension: asset_floor_target_price {
    type: number
    sql: ${TABLE}."ASSET_FLOOR_TARGET_PRICE" ;;
    value_format_name: usd
  }
  dimension: asset_has_operational_lease {
    type: yesno
    sql: ${TABLE}."ASSET_HAS_OPERATIONAL_LEASE" ;;
  }
  dimension: asset_has_subsidy {
    type: yesno
    sql: ${TABLE}."ASSET_HAS_SUBSIDY" ;;
  }
  dimension: asset_hours {
    type: number
    sql: ${TABLE}."ASSET_HOURS" ;;
  }
  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/service/work-orders" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: asset_inventory_market_id {
    type: number
    sql: ${TABLE}."ASSET_INVENTORY_MARKET_ID" ;;
    value_format_name: id
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
  dimension: asset_is_main_mover {
    type: yesno
    sql: ${TABLE}."ASSET_IS_MAIN_MOVER" ;;
  }
  dimension: asset_key {
    type: string
    sql: ${TABLE}."ASSET_KEY" ;;
  }
  dimension: asset_main_mover_attachment_type {
    type: string
    sql: ${TABLE}."ASSET_MAIN_MOVER_ATTACHMENT_TYPE" ;;
  }
  dimension: asset_main_mover_type {
    type: string
    sql: ${TABLE}."ASSET_MAIN_MOVER_TYPE" ;;
  }
  dimension: asset_maintenance_service_provider_market_id {
    type: number
    sql: ${TABLE}."ASSET_MAINTENANCE_SERVICE_PROVIDER_MARKET_ID" ;;
    value_format_name: id
  }
  dimension: asset_maintenance_service_provider_market_key {
    type: string
    sql: ${TABLE}."ASSET_MAINTENANCE_SERVICE_PROVIDER_MARKET_KEY" ;;
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
  dimension_group: asset_most_recent_pricing {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."ASSET_MOST_RECENT_PRICING_DATE" ;;
  }
  dimension: asset_name {
    type: string
    sql: ${TABLE}."ASSET_NAME" ;;
  }
  dimension: asset_never_rented {
    type: yesno
    sql: ${TABLE}."ASSET_NEVER_RENTED" ;;
  }
  dimension: asset_odometer {
    type: number
    sql: ${TABLE}."ASSET_ODOMETER" ;;
  }
  dimension: asset_oef_deal_flag {
    type: yesno
    sql: ${TABLE}."ASSET_OEF_DEAL_FLAG" ;;
  }
  dimension: asset_oem_deal_flag {
    type: yesno
    sql: ${TABLE}."ASSET_OEM_DEAL_FLAG" ;;
  }
  dimension_group: asset_oem_delivery {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_OEM_DELIVERY_DATE" ;;
  }
  dimension: asset_online_target_price {
    type: number
    sql: ${TABLE}."ASSET_ONLINE_TARGET_PRICE" ;;
    value_format_name: usd
  }
  dimension: asset_own_flag {
    type: yesno
    sql: ${TABLE}."ASSET_OWN_FLAG" ;;
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
  dimension: asset_pie_flag {
    type: yesno
    sql: ${TABLE}."ASSET_PIE_FLAG" ;;
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
    type: number
    sql: ${TABLE}."ASSET_RENTAL_MARKET_ID" ;;
    value_format_name: id
  }
  dimension: asset_rental_market_key {
    type: string
    sql: ${TABLE}."ASSET_RENTAL_MARKET_KEY" ;;
  }
  dimension: asset_serial_number {
    type: string
    sql: ${TABLE}."ASSET_SERIAL_NUMBER" ;;
  }
  dimension: asset_source {
    type: string
    sql: ${TABLE}."ASSET_SOURCE" ;;
  }
  dimension: asset_subsidy_value {
    type: number
    sql: ${TABLE}."ASSET_SUBSIDY_VALUE" ;;
  }
  dimension: asset_underperforming_flag {
    type: yesno
    sql: ${TABLE}."ASSET_UNDERPERFORMING_FLAG" ;;
  }
  dimension: asset_vin {
    type: string
    sql: ${TABLE}."ASSET_VIN" ;;
  }
  dimension: asset_weight_lbs {
    type: number
    sql: ${TABLE}."ASSET_WEIGHT_LBS" ;;
  }
  dimension: asset_year {
    type: number
    sql: ${TABLE}."ASSET_YEAR" ;;
    value_format_name: id
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    value_format_name: id
  }
  dimension: equipment_class_key {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_KEY" ;;
  }
  dimension: is_asset_eligible_for_sale {
    type: yesno
    sql: ${TABLE}."IS_ASSET_ELIGIBLE_FOR_SALE" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  asset_equipment_subcategory_name,
  asset_equipment_class_name,
  asset_name,
  asset_custom_name,
  asset_equipment_category_name,
  asset_equipment_model_name
  ]
  }

}
