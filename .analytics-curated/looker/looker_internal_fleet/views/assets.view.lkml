view: assets {
  # Change from model reference to derived table in order to create an es_owned_model_flag to use for the Re-Rents program.
  # E.M. 2/12/2025
  derived_table: {
     sql:
    SELECT
    *,
    CASE
        WHEN a.model IN (
            SELECT DISTINCT a2.model
            FROM es_warehouse.public.assets a2
            WHERE a2.company_id IN (1854, 1855)
        ) THEN TRUE
        ELSE FALSE
    END AS es_owned_model_flag,

    CASE
        WHEN a.category_id IN (
            SELECT DISTINCT a3.category_id
            FROM es_warehouse.public.assets a3
            LEFT JOIN es_warehouse.public.equipment_classes c
                ON a3.category_id = c.category_id
            WHERE a3.company_id IN (1854, 1855)
        ) THEN TRUE
        ELSE FALSE
    END AS es_owned_class_flag
FROM es_warehouse.public.assets a
    ;;
    }
  drill_fields: [asset_id]

  dimension: asset_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
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
    sql: TRIM(${TABLE}."DRIVER_NAME",' ') ;;
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
    # hidden: yes
    sql: ${TABLE}."EQUIPMENT_MAKE_ID" ;;
  }

  dimension: equipment_model_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
  }

  dimension: equipmentshare_owned_model_flag {
    type: yesno
    sql: ${TABLE}."ES_OWNED_MODEL_FLAG" ;;
  }

  dimension: equipmentshare_owned_class_flag {
    type: yesno
    sql: ${TABLE}."ES_OWNED_CLASS_FLAG" ;;
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

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: model {
    type: string
    sql: COALESCE(${equipment_models.name}, ${TABLE}."MODEL") ;;
  }

  dimension: make {
    type: string
    sql: ${equipment_makes.name} ;;
  }

  dimension: class {
    type: string
    sql: ${equipment_classes.name} ;;
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

  dimension: serial_last_5 {
    type: string
    sql: RIGHT(${TABLE}."SERIAL_NUMBER", 5) ;;
  }

  measure: asset_ids {
    type: list
    list_field: asset_id
  }

  measure: serial_numbers {
    type: list
    list_field: serial_number
  }

  measure: count_asset_ids {
    type: count_distinct
    sql:  ${TABLE}."ASSET_ID" ;;
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

  dimension: serial_vin {
    type: string
    sql: coalesce(${TABLE}."SERIAL_NUMBER",${TABLE}."VIN") ;;
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
    value_format: "0000"
    sql: ${TABLE}."YEAR" ;;
  }
  dimension: created_date {
    type: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  # dimension: purchase_created_date {
  #   type: date
  #   sql: coalesce(${asset_purchase_history.invoice_purchase_date},${created_date}) ;;
  # }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      asset_id,
      equipment_classes.name,
      equipment_makes.name,
      equipment_models.name,
      description,
      asset_purchase_history.oec,
    ]
  }
}
