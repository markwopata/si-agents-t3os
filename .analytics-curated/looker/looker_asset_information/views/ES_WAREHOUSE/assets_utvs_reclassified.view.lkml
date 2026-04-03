view: assets_utvs_reclassified {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ASSETS"
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
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: factory_build_specs {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
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

  dimension: created_date {
    type: date
    sql: ${TABLE}."DATE_CREATED" ;;
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
    value_format_name: id
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

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
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
    # hidden: yes
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
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

  dimension: market_id_to_use {
    type: number
    # hidden: yes
    sql: coalesce(${rental_branch_id},${inventory_branch_id}) ;;
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
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: make_and_model {
    type: string
    sql: concat(${make},' ',${model}, ' (', ${year}, ')') ;;
  }

  measure: number_of_assets {
    type: count
    drill_fields: [detail*]
  }

  measure: total_units {
    type: count
    drill_fields: [inventory_info_detail*]
  }

  dimension: re_rent {
    type: yesno
    sql:  ${company_id} = 11606 or LEFT(${custom_name}, 2) = 'RR' or LEFT(${serial_number}, 2) = 'RR' ;;
  }

  dimension:serial_number_vin {
    type: string
    sql: coalesce(${serial_number},${vin}) ;;
  }

  dimension: service_not_equal_to_rental_provider {
    type: yesno
    sql: ${service_branch_id} <> ${rental_branch_id} ;;
  }

  dimension: service_branch_is_es_market {
    type: yesno
    sql: ${service_branch_id} in (select ${markets.market_id} from markets where ${markets.company_id} = 1854) ;;
  }

  dimension: has_tracker {
    type: string
    sql: IFF(${tracker_id} is not null, 'Has Tracker', 'No Tracker') ;;
  }

  dimension: service_match_inventory_branch_loc {
    type: string
    description: "Does the service branch location (Admin) match the inventory (T3) branch location?"
    sql: IFF(${service_branch_id} = ${inventory_branch_id}, 'True', 'False') ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      asset_id_link_to_asset_dashboard,
      make_and_model,
      markets.name
    ]
  }

  set: inventory_info_detail {
    fields: [
      asset_id,
      make_and_model,
      markets.market_name,
      assets_aggregate.class,
      serial_number,
      assets_aggregate.oec
    ]
  }
  #      deliveries.requested_return --adding this in the inventory_info_drill causes assets to duplicate in the drill down

  dimension: asset_id_link_to_asset_dashboard {
    type: number
    value_format_name: id
    sql: ${asset_id} ;;
    html:  <u><p style="color:Blue;"><a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{ value | url_encode }}">{{rendered_value}}</a></p></u>;;

    # link: {
    #   label: "View Asset Details Dashboard"
    #   url: "https://equipmentshare.looker.com/dashboards/169?Asset+ID={{ value | url_encode }}"
    # }
  }

  dimension: view_inventory_button {
    type: string
    sql: 'View Inventory'  ;;

    link: {
      label: "View Inventory"
      url: "https://equipmentshare.looker.com/dashboards/27"
    }
  }

  dimension: purchase_created_date {
    type: date
    sql: coalesce(${asset_purchase_history.invoice_purchase_date},${created_date}) ;;
  }

  dimension: year_make_model {
    type: string
    sql: concat(${year},' ',${make},' ',${model}) ;;
  }
# ----------------------------------------------------------------
  #  Added dimension: equipment_class_name (override via model/make+model)
  # ----------------------------------------------------------------
  dimension: equipment_class_name {
    type: string
    sql:
      CASE
        -- Model‐only overrides
        WHEN ${model} = 'Pro XD Crew (Canopy)'
          THEN 'Utility Vehicle 4 - 6 Passenger Diesel, Open ROPS'
        WHEN ${model} = 'RTV-X1140W-H (Canopy)'
          THEN 'Utility Vehicle 4 - 6 Passenger Diesel, Open ROPS'
        WHEN ${model} = 'CA1700D (Canopy)'
          THEN 'Utility Vehicle 4 - 6 Passenger Diesel, Open ROPS'
        WHEN ${model} = 'Ranger XP1000 Crew Northstar'
          THEN 'Utility Vehicle Luxury 4 - 6 Passenger Gas, Cab Heat and AC'
        WHEN ${model} = 'RTV-X1140W-H-A (Canopy)'
          THEN 'Utility Vehicle 4 - 6 Passenger Diesel, Open ROPS'
        WHEN ${model} = 'Mule PRO-DXT'
          THEN 'Utility Vehicle 4 - 6 Passenger Diesel, Open ROPS'
        WHEN ${model} = 'RTV-X1140WL-H (Canopy)'
          THEN 'Utility Vehicle 4 - 6 Passenger Diesel, Open ROPS'
        WHEN ${model} = 'Trans Mule FE - Gas (Canopy)'
          THEN 'Utility Vehicle 4 - 6 Passenger Gas, Open ROPS'
        WHEN ${model} = 'Ranger XP 1000 Northstar Premium 4 - 6 Passenger (Cab)'
          THEN 'Utility Vehicle 4 - 6 Passenger Gas, Cab Heat and AC'
        WHEN ${model} = 'MULE PRO-DX'
          THEN 'Utility Vehicle 4 - 6 Passenger Gas, Open ROPS'
        WHEN ${model} = 'Payloader 2XL'
          THEN 'Burden Carrier 4 Wheel, 2 - 3 Passenger Electric'
        WHEN ${model} = 'Bigfoot 4 Seat'
          THEN 'Burden Carrier 4 Wheel, 4 - 6 Passenger Electric'
        WHEN ${model} = 'YU1000'
          THEN 'Utility Vehicle 2 - 3 Passenger Diesel, Open ROPS'

      -- make+model combined overrides
      WHEN ( ${make} || ' ' || ${model} ) IN (
      'KAWASAKI Mule PRO-DXT - 3 Passenger',
      'KUBOTA RTVX900WH',
      'KAWASAKI MULE PRO-DX, 2-3 Seat',
      'KUBOTA RTV-X900G-H - 2 Passenger',
      'BOBCAT UV34 D'
      ) THEN 'Utility Vehicle 2 - 3 Passenger Diesel, Open ROPS'

      WHEN ( ${make} || ' ' || ${model} ) IN (
      'KAWASAKI Mule PRO-FXT'
      ) THEN 'Utility Vehicle 4 - 6 Passenger Gas, Open ROPS'

      WHEN ( ${make} || ' ' || ${model} ) IN (
      'CUSHMAN Hauler 4x4 Crew',
      'JOHN DEERE 855M S4 Canopy',
      'JOHN DEERE XUV855M S4 Canopy'
      ) THEN 'Utility Vehicle 4 - 6 Passenger Diesel, Open ROPS'

      WHEN ( ${make} || ' ' || ${model} ) IN (
      'JOHN DEERE 855M S4 Cab'
      ) THEN 'Utility Vehicle 4 - 6 Passenger Diesel, Cab Heat Only'

      WHEN ( ${make} || ' ' || ${model} ) IN (
      'ADVENT Advanced EV1',
      'ADVENT Advent 4'
      ) THEN 'Utility Vehicle 4 - 6 Passenger Electric, Open ROPS'

      WHEN ( ${make} || ' ' || ${model} ) IN (
      'COLUMBIA Expeditor',
      'Expeditor Expeditor',
      'COLUMBIA Expeditor TAYLOR DUNN SS-536'
      ) THEN 'Burden Carrier 3 Wheel, 2 - 3 Passenger Electric'

      WHEN ( ${make} || ' ' || ${model} ) IN (
      'TAYLOR DUNN Bigfoot 4 Seat'
      ) THEN 'Burden Carrier 4 Wheel, 4 - 6 Passenger Electric'

      WHEN ( ${make} || ' ' || ${model} ) IN (
      'COLUMBIA Payloader 2XL',
      'TAYLOR DUNN Bigfoot',
      'TAYLOR DUNN Bigfoot S'
      ) THEN 'Burden Carrier 4 Wheel, 2 - 3 Passenger Electric'

      WHEN ( ${make} || ' ' || ${model} ) IN (
      'TAYLOR DUNN R-380'
      ) THEN 'Personnel Carrier 4 Wheel, 4 Passenger Electric'

      ELSE ${equipment_classes.name}
      END ;;
  }
}
