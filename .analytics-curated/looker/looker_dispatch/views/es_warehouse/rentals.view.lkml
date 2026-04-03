view: rentals {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."RENTALS"
    ;;
  drill_fields: [rental_id]

  dimension: rental_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: rental_id_admin {
    type: string
    sql: ${rental_id} ;;
    html: <u><a style="color:blue;" href="https://admin.equipmentshare.com/#/home/rentals/{{value}}">{{rendered_value}}</a></u> ;;
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
      day_of_week,
      day_of_week_index,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  # This can easily be done with date_created_day_of_week_index but it's easier to read for the user when filtering this
  dimension: date_created_is_weekend {
    type: yesno
    sql: ${date_created_day_of_week_index} >= 5 ;;
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
    # hidden: yes
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

  dimension: rental_purchase_option_id {
    type: number
    sql: ${TABLE}."RENTAL_PURCHASE_OPTION_ID" ;;
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
  }

  dimension: start_date_estimated {
    type: yesno
    sql: ${TABLE}."START_DATE_ESTIMATED" ;;
  }

  dimension: taxable {
    type: yesno
    sql: ${TABLE}."TAXABLE" ;;
  }

  # - - - - - MEASURES - - - - -

  measure: last_1_day_rentals {
    type: count_distinct
    sql: IFF(${date_created_date} >= dateadd('day', -1, current_date()), ${rental_id}, null) ;;
    drill_fields: [rental_detail*]
  }

  measure: last_7_days_rentals {
    type: count_distinct
    sql: IFF(${date_created_date} >= dateadd('day', -7, current_date()), ${rental_id}, null) ;;
    drill_fields: [rental_detail*]
  }

  measure: last_30_days_rentals {
    type: count_distinct
    sql: IFF(${date_created_date} >= dateadd('day', -30, current_date()), ${rental_id}, null) ;;
    drill_fields: [rental_detail*]
  }

  measure: count_rentals {
    type: count_distinct
    sql: ${rental_id} ;;
    drill_fields: [rental_detail*]
  }

  measure: count_billed_rentals {
    type: count_distinct
    sql: ${rental_id} ;;
    filters: [rental_status_id: "9"]
    drill_fields: [rental_detail*]
  }

  # - - - - - SETS - - - - -

  set: rental_detail {
    fields: [rental_statuses.name, rental_id_admin, invoice_company.name, invoices.invoice_id, invoices.invoice_no, rentals_to_line_items.billed_rental_amount]
  }

}
