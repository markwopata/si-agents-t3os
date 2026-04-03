view: assets {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ASSETS"
    ;;
  drill_fields: [asset_id]


  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID";;
  }

  dimension: asset_id_clean {
    description: "Displays 'No asset ID' instead of NULLs"
    type: string
    sql:  COALESCE(CAST(${TABLE}."ASSET_ID" as string), 'No asset ID');;
  }

  dimension: asset_id_wo_link {
    label: "Asset ID WO Link"
    type: number
    value_format_name: id
    sql: ${asset_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/service/work-orders" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: analog_to_digital_fuel_level_curve_id {
    type: number
    sql: ${TABLE}."ANALOG_TO_DIGITAL_FUEL_LEVEL_CURVE_ID" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  measure: DOT_asset {
    type: count_distinct
  sql: ${TABLE}."ASSET_ID";;
  filters: [asset_class: "'Delivery Trailer'
, 'Delivery Trucks'
, 'Dual Axle Dump Truck, 10 - 12 Yd'
, 'Office Trailer, 8%20%'
, 'Service Truck'
, 'Single Axle Dump Truck, 3/4 Yd - Diesel'
, 'Single Axle Dump Truck, 5/6 Yd - Diesel'
, 'Water Truck 2,000 - 2,500 Gal - Diesel'
, 'Water Truck 4,000 - 4,500 Gal  - Diesel'"]
  }

  dimension: asset_settings_id {
    type: number
    sql: ${TABLE}."ASSET_SETTINGS_ID" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: available_for_rent {
    type: yesno
    sql: ${TABLE}."AVAILABLE_FOR_RENT" ;;
  }

  dimension: available_to_rapid_rent {
    type: yesno
    sql: ${TABLE}."AVAILABLE_TO_RAPID_RENT" ;;
  }

  dimension: battery_voltage_type_id {
    type: number
    sql: ${TABLE}."BATTERY_VOLTAGE_TYPE_ID" ;;
  }

  dimension: camera_id {
    type: number
    sql: ${TABLE}."CAMERA_ID" ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: dot_number_id {
    type: number
    sql: ${TABLE}."DOT_NUMBER_ID" ;;
  }

  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  dimension: elog_device_id {
    type: number
    sql: ${TABLE}."ELOG_DEVICE_ID" ;;
  }

  dimension: elogs_certified {
    type: yesno
    sql: ${TABLE}."ELOGS_CERTIFIED" ;;
  }

  dimension: equipment_condition_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CONDITION_ID" ;;
  }

  dimension: equipment_make_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_MAKE_ID" ;;
  }

  dimension: equipment_model_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: maintenance_group_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
  }

  dimension: maintenance_group_yn {
    type: yesno
    sql: iff(${maintenance_group_id} is not null,true,false) ;;
  }

  dimension: missing_maintenance_group_yn {
    type: yesno
    sql: iff(${maintenance_group_id} is null,true,false) ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: name {
    label: "Asset Details"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: payout_percentage {
    type: number
    sql: ${TABLE}."PAYOUT_PERCENTAGE" ;;
  }

  dimension: photo_id {
    type: number
    sql: ${TABLE}."PHOTO_ID" ;;
  }

  dimension_group: placed_in_service {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."PLACED_IN_SERVICE" ;;
  }

  dimension: missed_placed_in_service_date {
    type: yesno
    sql: iff(${TABLE}."PLACED_IN_SERVICE" is null, true, false) ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }

  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }

  dimension: purchase_price {
    type: number
    sql: ${TABLE}."PURCHASE_PRICE" ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: service_branch_id {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }

  dimension: time_fence_id {
    type: number
    sql: ${TABLE}."TIME_FENCE_ID" ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: transportation_corporate {
    type: yesno
    sql: contains(${driver_name},'Corporate "DO NOT CHANGE"') ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: weekly_minimum {
    type: yesno
    sql: ${TABLE}."WEEKLY_MINIMUM" ;;
  }

  dimension: weight_lbs {
    type: number
    sql: ${TABLE}."WEIGHT_LBS" ;;
  }

  dimension: year {
    type: number
    value_format: "0"
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: make_and_model {
    type: string
    sql: concat(${make},' ',${model}) ;;
  }

  dimension: re_rent {
    type: yesno
    sql: SUBSTR(TRIM(${serial_number}), 1, 3) = 'RR-'
      or SUBSTR(TRIM(${serial_number}), 1, 2) = 'RR' ;;
  }

  dimension: license_type {
    type: string
    sql: case
        when contains(lower(asset_class),'non-cdl') then 'Non-CDL'
        when contains(lower(asset_class),'non cdl') then 'Non-CDL'
        when contains(lower(asset_class),'light') then 'Other'
        when contains(lower(asset_class),'deliver') then 'CDL'
        when contains(lower(asset_class),'deck') and contains(lower(asset_class),'trailer') then 'CDL'
        when contains(lower(asset_class),'pickup') then 'Non-CDL'
        when contains(lower(asset_class),'rental truck') then 'Non-CDL'
        when contains(lower(asset_class),'van') then 'Non-CDL'
        when contains(lower(asset_class),'500 gallon') then 'CDL'
        when contains(lower(asset_class),'501') then 'Non-CDL'
        when contains(lower(asset_class),'gallon') then 'Tanker'
        when contains(lower(asset_class),'service truck') then 'CDL'
        when contains(lower(asset_class),'dual') then 'CDL'
        when contains(lower(asset_class),'flat') then 'CDL'
        when contains(lower(asset_class),'2,500') then 'Non-CDL'
        when contains(lower(asset_class),'enclosed') then 'Non-CDL'
        when contains(lower(asset_class),'4,500') then 'Tanker'
        else 'Other'
    end ;;
  }

  measure: count {
    type: count
    drill_fields: [asset_id, custom_name, name, driver_name]
  }

  measure: count_distinct {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [transportation_assets.asset_id,asset_class,make,model,markets.name]
  }

  measure: count_by_company {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [asset_id,maintenance_group_id]
  }

  measure: count_by_company_no {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [maintenance_group_yn: "No"]
    drill_fields: [asset_id,maintenance_group_id]
  }

  measure: count_by_company_yes {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [maintenance_group_yn: "Yes"]
    drill_fields: [asset_id,maintenance_group_id]
  }

  measure: perc_of_fleet_no_mgi {
    type: number
    sql: ${count_by_company_no} / ${count_by_company} ;;
    drill_fields: [count_by_company_no,count_by_company]
  }

  measure: perc_of_fleet_mgi {
    type: number
    sql: ${count_by_company_yes} / ${count_by_company} ;;
    drill_fields: [count_by_company_yes,count_by_company]
  }
}
