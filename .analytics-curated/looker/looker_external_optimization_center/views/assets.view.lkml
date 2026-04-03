view: assets {
  sql_table_name: "PUBLIC"."ASSETS"
    ;;
  # drill_fields: [asset_id]

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
    sql: coalesce(${TABLE}."ASSET_CLASS",'Unassigned') ;;
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
    label: "Asset"
    type: string
    sql: TRIM(${TABLE}."CUSTOM_NAME") ;;
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
  }

  dimension: asset_make_model {
    type: string
    sql: concat(${custom_name},' ',coalesce(${make},' '),' ',coalesce(${model},' ')) ;;
  }

  dimension: asset_linked_to_track_w_notification_date {
    label: "Asset with Link"
    type: string
    sql: ${asset_make_model};;
    html: <font color="blue"><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{ asset_id._filterable_value }}/history?selectedDate={{ notification_delivery_logs.delivered_date._filterable_value}}" target="_blank">{{value}}</a></font?</u>;;
  }

  dimension: asset_linked_to_track_w_speeding_date {
    label: "Speeding Asset with Link"
    type: string
    sql: ${asset_make_model};;
    html: <font color="blue"><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{ asset_id._filterable_value }}/history?selectedDate={{ speed_report_incident_log.start_date._filterable_value}}" target="_blank">{{value}}</a></font?</u>;;
  }


  measure: dummy {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [detail*]
  }

  measure: asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
    link: {
      label: "View Assets by Category"
      url: "{% assign vis= '{\"show_view_names\":false,
      \"show_row_numbers\":true,
      \"transpose\":false,
      \"truncate_text\":true,
      \"hide_totals\":false,
      \"hide_row_totals\":false,
      \"size_to_fit\":true,
      \"table_theme\":\"white\",
      \"limit_displayed_rows\":false,
      \"enable_conditional_formatting\":false,
      \"header_text_alignment\":\"left\",
      \"header_font_size\":12,
      \"rows_font_size\":12,
      \"conditional_formatting_include_totals\":false,
      \"conditional_formatting_include_nulls\":false,
      \"type\":\"looker_grid\",
      \"defaults_version\":1}' %}

      {{dummy._link}}&f[asset_types.asset_type]={{_filters['asset_types.asset_type'] | url_encode }}&f[assets.custom_name]={{_filters['assets.custom_name'] | url_encode }}&f[assets.ownership_type]={{_filters['assets.ownership_type'] | url_encode }}&f[categories.name]={{_filters['categories.name'] | url_encode }}&sorts=categories.name+asc&vis={{vis | encode_uri}}"
    }
  }

  measure: count_percent {
    type: percent_of_total
    sql: ${asset_count} ;;
  }

  measure: asset_count_for_trackers {
    type: count_distinct
    sql: ${asset_id} ;;
    html: {{rendered_value}} ({{count_percent._rendered_value}}) ;;
    link: {
      label: "View Assets by Category"
      url: "{% assign vis= '{\"show_view_names\":false,
      \"show_row_numbers\":true,
      \"transpose\":false,
      \"truncate_text\":true,
      \"hide_totals\":false,
      \"hide_row_totals\":false,
      \"size_to_fit\":true,
      \"table_theme\":\"white\",
      \"limit_displayed_rows\":false,
      \"enable_conditional_formatting\":false,
      \"header_text_alignment\":\"left\",
      \"header_font_size\":12,
      \"rows_font_size\":12,
      \"conditional_formatting_include_totals\":false,
      \"conditional_formatting_include_nulls\":false,
      \"type\":\"looker_grid\",
      \"defaults_version\":1}' %}

      {{dummy._link}}&f[asset_types.asset_type]={{_filters['asset_types.asset_type'] | url_encode }}&f[assets.custom_name]={{_filters['assets.custom_name'] | url_encode }}&f[assets.ownership_type]={{_filters['assets.ownership_type'] | url_encode }}&f[categories.name]={{_filters['categories.name'] | url_encode }}&sorts=categories.name+asc&vis={{vis | encode_uri}}"
    }
  }

  set: detail {
    fields: [
      custom_name, make, model, ownership_type, asset_types.asset_type, categories.name, organizations.asset_groups, trackers.tracker_information, asset_last_location.address
    ]
  }
}
