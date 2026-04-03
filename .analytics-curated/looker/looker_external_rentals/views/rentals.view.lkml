view: rentals {
  sql_table_name: "PUBLIC"."RENTALS"
    ;;
  # drill_fields: [rental_id]

  dimension: rental_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
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

  dimension: amount_received {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
  }

  dimension: asset_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: borrower_user_id {
    type: number
    sql: ${TABLE}."BORROWER_USER_ID" ;;
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: delivery_charge {
    type: number
    sql: ${TABLE}."DELIVERY_CHARGE" ;;
  }

  dimension: delivery_instructions {
    type: string
    sql: ${TABLE}."DELIVERY_INSTRUCTIONS" ;;
  }

  dimension: delivery_required {
    type: yesno
    sql: ${TABLE}."DELIVERY_REQUIRED" ;;
  }

  dimension: drop_off_delivery_id {
    type: number
    sql: ${TABLE}."DROP_OFF_DELIVERY_ID" ;;
  }

  dimension: drop_off_delivery_required {
    type: yesno
    sql: ${TABLE}."DROP_OFF_DELIVERY_REQUIRED" ;;
  }

  dimension_group: end {
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
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: end_date_estimated {
    type: yesno
    sql: ${TABLE}."END_DATE_ESTIMATED" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: job_description {
    type: string
    sql: ${TABLE}."JOB_DESCRIPTION" ;;
  }

  dimension: lien_notice_sent {
    type: yesno
    sql: ${TABLE}."LIEN_NOTICE_SENT" ;;
  }

  dimension_group: off_rent_date_requested {
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
    sql: CAST(${TABLE}."OFF_RENT_DATE_REQUESTED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: price {
    type: number
    sql: ${TABLE}."PRICE" ;;
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

  dimension: rental_protection_plan_id {
    type: number
    sql: ${TABLE}."RENTAL_PROTECTION_PLAN_ID" ;;
  }

  dimension: rental_status_id {
    type: number
    sql: ${TABLE}."RENTAL_STATUS_ID" ;;
  }

  dimension: rental_type_id {
    type: number
    sql: ${TABLE}."RENTAL_TYPE_ID" ;;
  }

  dimension: return_charge {
    type: number
    sql: ${TABLE}."RETURN_CHARGE" ;;
  }

  dimension: return_delivery_id {
    type: number
    sql: ${TABLE}."RETURN_DELIVERY_ID" ;;
  }

  dimension: return_delivery_required {
    type: yesno
    sql: ${TABLE}."RETURN_DELIVERY_REQUIRED" ;;
  }

  dimension_group: start {
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
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: start_date_estimated {
    type: yesno
    sql: ${TABLE}."START_DATE_ESTIMATED" ;;
  }

  dimension: taxable {
    type: yesno
    sql: ${TABLE}."TAXABLE" ;;
  }

  measure: count {
    type: count
    drill_fields: [rental_id, assets.custom_name, assets.asset_id, assets.name, assets.driver_name]
  }

  measure: on_rent_count {
    type: count_distinct
    sql: ${rental_id} ;;
    filters: [rental_on_rent: "Yes"]
    # filters: [rental_status_id: "5"]
    drill_fields: [on_rent_rental_kpi*]
  }

  dimension: rental_on_rent {
    type: yesno
    sql: ${rental_status_id} = 5
    ;;
  }

  # (is_null(${equipment_assignments.end_date})
  # OR (${equipment_assignments.end_time} >= now() AND ${equipment_assignments.start_time} <= now()))
  # OR (${rentals.rental_status_id} = 5 AND is_null(${rentals.asset_id}))

  measure: waiting_for_pickup_count {
    type: count
    filters: [rental_status_id: "6"]
    # filters: [drop_off_delivery_required: "Yes",
    #   rental_status_id: "6"]
    #off rent date requested date is in the past 14 days
    drill_fields: [pickup_rental_kpi*]
  }

  measure: rental_reservations {
    type: count
    filters: [rental_status_id: "4"]
    #using rental status of scheduled
    drill_fields: [reservations_rental_kpi*]
  }

  dimension: asset_reserved {
    type: yesno
    sql: ${rental_status_id} <= 4 ;;
    # sql: (${start_raw} > current_timestamp and ${rental_status_id} NOT IN (5,8)) OR (${start_raw} < current_timestamp and ${rental_status_id} <= 4)  ;;
  }

  measure: dummy {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [reservations_rental_kpi*]
  }

  measure: reservation_count {
    type: count_distinct
    sql: ${rental_id} ;;
    filters: [asset_reserved: "Yes"]
    # drill_fields: [reservations_rental_kpi*]
    link: {
      label: "View Reservations"
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

    {{dummy._link}}&f[rentals.asset_reserved]=Yes&vis={{vis | encode_uri}}&sorts=rentals.rental_id+asc"
    }
  }

  dimension_group: non_formatted_start {
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
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}', CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ)) ;;
  }

  set: on_rent_rental_kpi {
    fields: [rental_id, assets.custom_name_make_model_bulk_item, locations.jobsite_group, purchase_orders.name, assets.asset_class, users.ordered_by, start_date, admin_cycle.end_date, admin_cycle.next_cycle_inv_date,
      admin_cycle.price_per_day, admin_cycle.price_per_week, admin_cycle.price_per_month, delivery_location.delivery_address, line_items.rental_revenue]
  }

  set: pickup_rental_kpi {
    fields: [delivery_statuses.name, assets.custom_name_make_model, locations.location_address, purchase_orders.name, assets.asset_class, equipment_assignments.start_date, equipment_assignments.scheduled_off_rent_date]
  }

  set: reservations_rental_kpi {
    fields: [contracts.view_rental_contract, assets.custom_name, locations.jobsite_group, purchase_orders.name, equipment_classes.name, users.ordered_by, rentals.start_date]
  }


}
