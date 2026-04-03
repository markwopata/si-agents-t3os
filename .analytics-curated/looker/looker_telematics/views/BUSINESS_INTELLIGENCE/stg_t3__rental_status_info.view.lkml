view: stg_t3__rental_status_info {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__RENTAL_STATUS_INFO" ;;

  dimension: asset {
    label: "Custom ID"
    type: string
    sql: ${TABLE}."ASSET" ;;
  }
  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: cycles_next_seven_days {
    type: yesno
    sql: ${TABLE}."CYCLES_NEXT_SEVEN_DAYS" ;;
  }
  dimension: delivery_address {
    type: string
    sql: ${TABLE}."DELIVERY_ADDRESS" ;;
  }
  dimension: hours_in {
    type: string
    sql: ${TABLE}."HOURS_IN" ;;
  }
  dimension: hours_out {
    type: string
    sql: ${TABLE}."HOURS_OUT" ;;
  }
  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: miles_in {
    type: string
    sql: ${TABLE}."MILES_IN" ;;
  }
  dimension: miles_out {
    type: string
    sql: ${TABLE}."MILES_OUT" ;;
  }
  dimension_group: next_cycle {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."NEXT_CYCLE_DATE" ;;
  }
  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }
  dimension: ordered_by {
    type: string
    sql: ${TABLE}."ORDERED_BY" ;;
  }
  dimension: ordered_by_id {
    type: number
    sql: ${TABLE}."ORDERED_BY_ID" ;;
  }
  dimension: parent_company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PARENT_COMPANY_ID" ;;
  }
  dimension: parent_company_name {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME" ;;
  }
  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }
  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }
  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }
  dimension: primary_salesperson_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PRIMARY_SALESPERSON_ID" ;;
  }
  dimension: primary_salesperson_name {
    type: string
    sql: ${TABLE}."PRIMARY_SALESPERSON_NAME" ;;
  }
  dimension: pull_recent_asset_assignment {
    type: number
    sql: ${TABLE}."PULL_RECENT_ASSET_ASSIGNMENT" ;;
  }
  dimension: purchase_order {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER" ;;
  }
  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }
  dimension: rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."RENTAL_BILLING_CYCLE_STRATEGY" ;;
  }
  dimension_group: rental_end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RENTAL_END_DATE" ;;
  }
  dimension_group: rental_end_datetime {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."RENTAL_END_DATETIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension_group: rental_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }
  dimension_group: rental_start_datetime {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."RENTAL_START_DATETIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: hours_since_onrent_without_checkin {
    type: number
    value_format_name: decimal_0
    sql:  CASE
      WHEN ${TABLE}.RENTAL_START_DATETIME IS NULL THEN NULL
      -- If there's a checkin at or after rental start, it's not "without checkin"
      WHEN ${telematics_mothership.last_checkin_timestamp_time} IS NOT NULL
       AND ${telematics_mothership.last_checkin_timestamp_time} >= ${TABLE}.RENTAL_START_DATETIME
      THEN 0
      -- Otherwise, hours between rental start and now
      ELSE DATEDIFF(hour, ${TABLE}.RENTAL_START_DATETIME, CURRENT_TIMESTAMP)
    END  ;;
  }
  dimension: secondary_salesperson_1 {
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_1" ;;
  }
  dimension: secondary_salesperson_name {
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_NAME" ;;
  }
  dimension: shift_type_id {
    type: number
    sql: ${TABLE}."SHIFT_TYPE_ID" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: sub_renter_id {
    type: number
    sql: ${TABLE}."SUB_RENTER_ID" ;;
  }
  dimension: sub_renting_company {
    type: string
    sql: ${TABLE}."SUB_RENTING_COMPANY" ;;
  }
  dimension: sub_renting_contact {
    type: string
    sql: ${TABLE}."SUB_RENTING_CONTACT" ;;
  }
  dimension: total_secondary_salespersons {
    type: number
    sql: ${TABLE}."TOTAL_SECONDARY_SALESPERSONS" ;;
  }
  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }
  measure: count {
    type: count
    drill_fields: [parent_company_name, primary_salesperson_name, secondary_salesperson_name]
  }
}
