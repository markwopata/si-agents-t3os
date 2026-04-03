view: assets {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ASSETS"
    ;;
  drill_fields: [asset_id]

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: analog_to_digital_fuel_level_curve_id {
    hidden: yes
    type: number
    sql: ${TABLE}."analog_to_digital_fuel_level_curve_id" ;;
  }

  dimension: asset_scd_hours_id {
    hidden: yes
    type: number
    sql: ${TABLE}."asset_scd_hours_id" ;;
  }

  dimension: asset_scd_odometer_id {
    hidden: yes
    type: number
    sql: ${TABLE}."asset_scd_odometer_id" ;;
  }

  dimension: date_created {
    type: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }


  dimension: asset_settings_id {
    hidden: yes
    type: number
    sql: ${TABLE}."asset_settings_id" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: camera_id {
    hidden: yes
    type: number
    sql: ${TABLE}."camera_id" ;;
  }

  dimension: category_id {
    hidden: yes
    type: number
    sql: ${TABLE}."category_id" ;;
  }

  dimension: company_id {
    #hidden: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: elog_device_id {
    hidden: yes
    type: number
    sql: ${TABLE}."elog_device_id" ;;
  }

  dimension: domain_id {
    hidden: yes
    type: number
    sql: ${TABLE}."domain_id" ;;
  }

  dimension: equipment_condition_id {
    hidden: yes
    type: number
    sql: ${TABLE}."equipment_condition_id" ;;
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
    hidden: yes
    type: number
    sql: ${TABLE}."location_id" ;;
  }

  dimension: maintenance_group_id {
    hidden: yes
    type: number
    sql: ${TABLE}."maintenance_group_id" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: photo_id {
    hidden: yes
    type: number
    sql: ${TABLE}."photo_id" ;;
  }

  dimension: service_branch_id {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }

  dimension: service_provider_company_id {
    hidden: yes
    type: number
    sql: ${TABLE}."service_provider_company_id" ;;
  }

  dimension: time_fence_id {
    hidden: yes
    type: number
    sql: ${TABLE}."time_fence_id" ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: tracker_id {
    hidden: yes
    type: number
    sql: ${TABLE}."tracker_id" ;;
  }

  dimension:asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

   dimension:serial_number_vin {
    type: string
    sql: coalesce(${TABLE}."SERIAL_NUMBER",${TABLE}."VIN") ;;
  }


  dimension_group: created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: updated {
    hidden: yes
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
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
    sql: CAST(${TABLE}."PLACED_IN_SERVICE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: deleted {
    # hidden: yes
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: available_for_rent {
    type: yesno
    sql: ${TABLE}."AVAILABLE_FOR_RENT" ;;
  }

  dimension: re_rent {
    type: yesno
    sql: SUBSTR(BTRIM(${serial_number}), 1, 3) = 'RR-'
      or SUBSTR(BTRIM(${serial_number}), 1, 2) = 'RR';;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: factory_build_specs {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: driver_name {
    hidden: yes
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  dimension: hours {
    #hidden: yes
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: odometer {
    hidden: yes
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }

  dimension: payout_percentage {
    hidden: yes
    type: number
    sql: ${TABLE}."payout_percentage" ;;
  }

  dimension: price_per_day {
    hidden: yes
    type: number
    sql: ${TABLE}."price_per_day" ;;
  }

  dimension: price_per_hour {
    hidden: yes
    type: number
    sql: ${TABLE}."price_per_hour" ;;
  }

  dimension: price_per_month {
    hidden: yes
    type: number
    sql: ${TABLE}."price_per_month" ;;
  }

  dimension: price_per_week {
    hidden: yes
    type: number
    sql: ${TABLE}."price_per_week" ;;
  }

  dimension: purchase_price {
    hidden: yes
    type: number
    sql: ${TABLE}."purchase_price" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: total_fuel_used_liters {
    hidden: yes
    type: number
    sql: ${TABLE}."total_fuel_used_liters" ;;
  }

  dimension: total_idle_fuel_used_liters {
    hidden: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."total_idle_fuel_used_liters" ;;
  }

  dimension: total_idle_seconds {
    hidden: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."total_idle_seconds" ;;
  }

  dimension: vin {
    hidden: yes
    type: string
    sql: ${TABLE}."vin" ;;
  }

  dimension: weekly_minimum {
    hidden: yes
    type: yesno
    sql: ${TABLE}."weekly_minimum" ;;
  }

  dimension: weight_lbs {
    type: number
    sql: ${TABLE}."WEIGHT_LBS" ;;
  }

  dimension: year {
    type: number
    value_format_name: id
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: available_to_rapid_rent {
    type: string
    sql: ${TABLE}."AVAILABLE_TO_RAPID_RENT" ;;
  }

  measure: total_units {
    type: count
    drill_fields: [asset_id,name,markets.name,asset_statuses.asset_inventory_status]
  }

  measure: number_of_assets {
    type: count
    drill_fields: [detail*]
  }

  measure: number_of_ES_assets {
    type: count
    filters: {
      field: asset_type_id
      value: "1"
    }
    filters: {
      field: company_id
      value: "1854"
    }
    filters: {
      field: available_for_rent
      value: "yes"
    }
    filters: {
      field: markets.company_id
      value: "1854"
    }
    filters: {
      field: markets.is_public_rsp
      value: "yes"
    }
  }

  dimension: make_and_model {
    type: string
    sql: concat(${make},' ',${model}) ;;
  }

  measure: avg_age_of_assets {
    type: average
    sql:  extract(year from  (date_trunc('year', current_date))) - ${year};;
    drill_fields: [asset_id,name,make_and_model,markets.name,year,avg_age_of_assets]
  }

  dimension: service_not_equal_to_rental_provider {
    type: yesno
    sql: ${service_branch_id} <> ${rental_branch_id} ;;
  }

  dimension: service_branch_is_es_market {
    type: yesno
    sql: ${service_branch_id} in (select ${markets.market_id} from markets where ${markets.company_id} = 1854) ;;
  }


  dimension: asset_with_tracker_link {
    type: number
    sql:${asset_id};;
    link: {
      label: "View Tracker Map"
      url: "https://equipmentshare.looker.com/looks/136?&f[assets.asset_id]={{ value | url_encode }}&toggle=det"
    }
  }

  dimension: is_asset_in_rapid_rent {
    type: yesno
    sql: ${available_to_rapid_rent} = true ;;
  }

  dimension: asset_id_link_to_asset_dashboard {
    type: number
    sql: ${asset_id} ;;

    link: {
      label: "View Asset Details Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/169?Asset+ID={{ value | url_encode }}"
    }
  }

  dimension: purchase_created_date {
    type: date
    sql: coalesce(${asset_purchase_history.invoice_purchase_date},${created_date}) ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      asset_id,
      make_and_model,
      markets.name
    ]
  }
}
