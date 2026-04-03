view: rentals {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."RENTALS"
    ;;
  drill_fields: [rental_id]

  dimension: rental_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
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
    sql: ${TABLE}."DATE_CREATED" ;;
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
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: end_date_estimated {
    type: yesno
    sql: ${TABLE}."END_DATE_ESTIMATED" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: future_rent {
    type: yesno
    sql: current_date() < ${rentals.start_date} ;;
  }


  dimension: job_description {
    type: string
    sql: ${TABLE}."JOB_DESCRIPTION" ;;
  }

  dimension: lien_notice_sent {
    type: yesno
    sql: ${TABLE}."LIEN_NOTICE_SENT" ;;
  }

  dimension: no_attachment_needed {
    sql: ${TABLE}."NO_ATTACHMENT_NEEDED" ;;
  }

  dimension: on_rent {
    type: yesno
    sql: current_date() between ${rentals.start_date}::date AND ${rentals.end_date}::date ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: parent_rental_id {
    type: number
    sql: ${TABLE}."PARENT_RENTAL_ID" ;;
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
    sql: ${TABLE}."START_DATE" ;;
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
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      rental_id,
      orders.order_id,
      assets.custom_name,
      assets.asset_id,
      assets.name,
      assets.driver_name,
      equipment_assignments.count
    ]
  }
}
