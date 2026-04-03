view: assets {
  sql_table_name: "PUBLIC"."ASSETS"
    ;;
  drill_fields: [asset_id]

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
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
    label: "Class"
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
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
    label: "Asset"
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
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: market_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: name {
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
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: ownership_type {
    label: "Ownership"
    type: string
    sql: case when ${company_id} = ('{{ _user_attributes['company_id'] }}'::numeric) then 'Owned' else 'Rented' END;;
    # sql: case when ${company_id} = 50 then 'Owned' else 'Rented' end  ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
  }

  dimension: asset_linked_to_track_details {
    group_label: "Link to T3 History Page"
    label: "Asset"
    type: string
    sql: ${custom_name};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/history?selectedDate={{ current_date._filterable_value }}" target="_blank">{{value}}</a></font?</u>;;
  }


  dimension: make_and_model {
    type: string
    sql: concat(${make},' ',${model}) ;;
  }

  dimension: asset_custom_name_to_asset_info {
    group_label: "Link to T3 Status Page"
    label: "Asset"
    type: string
    sql: ${custom_name};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: asset_custom_name_to_service_page {
    group_label: "Link to T3 Service Page"
    label: "Asset"
    type: string
    sql: ${custom_name};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/service" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: driver_vehicle_type{
    label: "Driver"
    type: string
    sql: CASE WHEN ${asset_type_id} = 2 --vehicle asset type
         THEN COALESCE(${driver_name},'')
         ELSE ''
         END;;
  }

  dimension: vehicle_vin_serial_number{
    label: "Serial Num/VIN"
    type: string
    sql: CASE WHEN ${asset_type_id} = 2 --vehicle asset type
         THEN ${vin}
         ELSE ${serial_number}
         END;;
  }


  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      asset_id,
      custom_name,
      name,
      driver_name,
      markets.name,
      markets.canonical_name,
      markets.market_id,
      asset_service_intervals.count,
      organization_asset_xref.count
    ]
  }
}
