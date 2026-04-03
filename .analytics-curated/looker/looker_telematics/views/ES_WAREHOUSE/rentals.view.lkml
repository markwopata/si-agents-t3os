view: rentals {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."RENTALS"
    ;;
  drill_fields: [rental_id]

  dimension: rental_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: _es_update_timestamp {
    type: date_time
    sql: ${TABLE}.CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
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

  dimension: date_created {
    type: date_time
    sql: ${TABLE}.CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
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

  dimension: end_date {
    label: "Rental End Date"
    type: date_time
    sql: ${TABLE}.CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: end_date_estimated {
    type: yesno
    sql: ${TABLE}."END_DATE_ESTIMATED" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: external_id {
    type: string
    sql: ${TABLE}."EXTERNAL_ID" ;;
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

  dimension: job_description {
    type: string
    sql: ${TABLE}."JOB_DESCRIPTION" ;;
  }

  dimension: lien_notice_sent {
    type: yesno
    sql: ${TABLE}."LIEN_NOTICE_SENT" ;;
  }

  dimension: off_rent_date_requested {
    type: date_time
    sql: ${TABLE}.CAST(${TABLE}."OFF_RENT_DATE_REQUESTED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: part_type_id {
    type: number
    sql: ${TABLE}."PART_TYPE_ID" ;;
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

  dimension: purchase_price {
    type: number
    sql: ${TABLE}."PURCHASE_PRICE" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: rate_type_id {
    type: number
    sql: ${TABLE}."RATE_TYPE_ID" ;;
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

  dimension: start {
    type: date_time
    sql: ${TABLE}.CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
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
    drill_fields: [rental_id]
  }
}
