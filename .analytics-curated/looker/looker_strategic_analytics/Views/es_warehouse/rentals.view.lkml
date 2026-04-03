view: rentals {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."RENTALS" ;;

  measure: count {
    type: count
    drill_fields: [detail_drill*]
  }

  dimension: rental_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: equipment_class_id {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: return_delivery_id {
    type: string
    sql: ${TABLE}."RETURN_DELIVERY_ID" ;;
  }

  dimension: borrower_user_id {
    type: string
    sql: ${TABLE}."BORROWER_USER_ID" ;;
  }

  dimension: rental_protection_plan_id {
    type: string
    sql: ${TABLE}."RENTAL_PROTECTION_PLAN_ID" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: rental_status_id {
    type: string
    sql: ${TABLE}."RENTAL_STATUS_ID" ;;
  }

  dimension: drop_off_delivery_id {
    type: string
    sql: ${TABLE}."DROP_OFF_DELIVERY_ID" ;;
  }

  dimension: rental_type_id {
    type: string
    sql: ${TABLE}."RENTAL_TYPE_ID" ;;
  }

  dimension: rental_purchase_option_id {
    type: string
    sql: ${TABLE}."RENTAL_PURCHASE_OPTION_ID" ;;
  }

  dimension: part_type_id {
    type: string
    sql: ${TABLE}."PART_TYPE_ID" ;;
  }

  dimension: rate_type_id {
    type: string
    sql: ${TABLE}."RATE_TYPE_ID" ;;
  }

  dimension: inventory_product_id {
    type: string
    sql: ${TABLE}."INVENTORY_PRODUCT_ID" ;;
  }

  dimension: rental_pricing_structure_id {
    type: string
    sql: ${TABLE}."RENTAL_PRICING_STRUCTURE_ID" ;;
  }

  dimension: shift_type_id {
    type: string
    sql: ${TABLE}."SHIFT_TYPE_ID" ;;
  }

  dimension: parent_rental_id {
    type: string
    sql: ${TABLE}."PARENT_RENTAL_ID" ;;
  }

  dimension: reassignment_source_rental_id {
    type: string
    sql: ${TABLE}."REASSIGNMENT_SOURCE_RENTAL_ID" ;;
  }

  dimension: reassignment_target_rental_id {
    type: string
    sql: ${TABLE}."REASSIGNMENT_TARGET_RENTAL_ID" ;;
  }

  dimension: job_description {
    type: string
    sql: ${TABLE}."JOB_DESCRIPTION" ;;
  }

  dimension: delivery_instructions {
    type: string
    sql: ${TABLE}."DELIVERY_INSTRUCTIONS" ;;
  }

  dimension: external_id {
    type: string
    sql: ${TABLE}."EXTERNAL_ID" ;;
  }

  dimension: inventory_product_name {
    type: string
    sql: ${TABLE}."INVENTORY_PRODUCT_NAME" ;;
  }

  dimension: inventory_product_name_historical {
    type: string
    sql: ${TABLE}."INVENTORY_PRODUCT_NAME_HISTORICAL" ;;
  }

  dimension: cancel_reason_type {
    type: string
    sql: ${TABLE}."CANCEL_REASON_TYPE" ;;
  }

  dimension: cancel_reason_note {
    type: string
    sql: ${TABLE}."CANCEL_REASON_NOTE" ;;
  }

  dimension: bulk_label {
    type: string
    sql: ${TABLE}."BULK_LABEL" ;;
  }

  dimension: price {
    type: number
    sql: ${TABLE}."PRICE" ;;
    value_format_name: usd
  }

  measure: total_price {
    type: sum
    sql: ${price} ;;
    value_format_name: usd
  }

  dimension: delivery_charge {
    type: number
    sql: ${TABLE}."DELIVERY_CHARGE" ;;
    value_format_name: usd
  }

  dimension: amount_received {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
  }

  measure: total_amount_received {
    type: sum
    sql: ${amount_received} ;;
    value_format_name: usd
  }

  dimension: return_charge {
    type: number
    sql: ${TABLE}."RETURN_CHARGE" ;;
    value_format_name: usd
  }

  dimension: purchase_price {
    type: number
    sql: ${TABLE}."PURCHASE_PRICE" ;;
    value_format_name: usd
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd
  }

  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
    value_format_name: usd
  }

  dimension: one_time_charge {
    type: number
    sql: ${TABLE}."ONE_TIME_CHARGE" ;;
    value_format_name: usd
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: lien_notice_sent {
    type: yesno
    sql: ${TABLE}."LIEN_NOTICE_SENT" ;;
  }

  dimension: delivery_required {
    type: yesno
    sql: ${TABLE}."DELIVERY_REQUIRED" ;;
  }

  dimension: drop_off_delivery_required {
    type: yesno
    sql: ${TABLE}."DROP_OFF_DELIVERY_REQUIRED" ;;
  }

  dimension: return_delivery_required {
    type: yesno
    sql: ${TABLE}."RETURN_DELIVERY_REQUIRED" ;;
  }

  dimension: start_date_estimated {
    type: yesno
    sql: ${TABLE}."START_DATE_ESTIMATED" ;;
  }

  dimension: taxable {
    type: yesno
    sql: ${TABLE}."TAXABLE" ;;
  }

  dimension: end_date_estimated {
    type: yesno
    sql: ${TABLE}."END_DATE_ESTIMATED" ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: has_re_rent {
    type: yesno
    sql: ${TABLE}."HAS_RE_RENT" ;;
  }

  dimension: is_below_floor_rate {
    type: yesno
    sql: ${TABLE}."IS_BELOW_FLOOR_RATE" ;;
  }

  dimension: is_flat_monthly_rate {
    type: yesno
    sql: ${TABLE}."IS_FLAT_MONTHLY_RATE" ;;
  }

  dimension: is_flexible_rate {
    type: yesno
    sql: ${TABLE}."IS_FLEXIBLE_RATE" ;;
  }

  dimension: no_attachment_needed {
    type: yesno
    sql: ${TABLE}."NO_ATTACHMENT_NEEDED" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension_group: off_rent_date_requested {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."OFF_RENT_DATE_REQUESTED" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: end_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension_group: start_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."START_DATE" ;;
  }

  set: detail_drill {
    fields: [rental_id, order_id, asset_id, inventory_product_name, start_date_date, end_date_date, price]
  }


}
