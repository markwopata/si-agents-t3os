view: stg_t3__on_rent {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__ON_RENT" ;;

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: billing_days_left {
    type: number
    sql: ${TABLE}."BILLING_DAYS_LEFT" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: current_asset_location {
    type: string
    sql: ${TABLE}."CURRENT_ASSET_LOCATION" ;;
  }
  dimension: current_cycle {
    type: number
    sql: ${TABLE}."CURRENT_CYCLE" ;;
  }
  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }
  dimension_group: data_refresh_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATA_REFRESH_TIMESTAMP" ;;
  }
  dimension: filename {
    type: string
    sql: ${TABLE}."FILENAME" ;;
  }
  dimension_group: five_days_ago {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FIVE_DAYS_AGO_DATE" ;;
  }
  dimension: five_days_utilization_cst {
    type: number
    sql: ${TABLE}."FIVE_DAYS_UTILIZATION_CST" ;;
  }
  dimension: five_days_utilization_est {
    type: number
    sql: ${TABLE}."FIVE_DAYS_UTILIZATION_EST" ;;
  }
  dimension: five_days_utilization_mnt {
    type: number
    sql: ${TABLE}."FIVE_DAYS_UTILIZATION_MNT" ;;
  }
  dimension: five_days_utilization_utc {
    type: number
    sql: ${TABLE}."FIVE_DAYS_UTILIZATION_UTC" ;;
  }
  dimension: five_days_utilization_wst {
    type: number
    sql: ${TABLE}."FIVE_DAYS_UTILIZATION_WST" ;;
  }
  dimension_group: four_days_ago {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FOUR_DAYS_AGO_DATE" ;;
  }
  dimension: four_days_utilization_cst {
    type: number
    sql: ${TABLE}."FOUR_DAYS_UTILIZATION_CST" ;;
  }
  dimension: four_days_utilization_est {
    type: number
    sql: ${TABLE}."FOUR_DAYS_UTILIZATION_EST" ;;
  }
  dimension: four_days_utilization_mnt {
    type: number
    sql: ${TABLE}."FOUR_DAYS_UTILIZATION_MNT" ;;
  }
  dimension: four_days_utilization_utc {
    type: number
    sql: ${TABLE}."FOUR_DAYS_UTILIZATION_UTC" ;;
  }
  dimension: four_days_utilization_wst {
    type: number
    sql: ${TABLE}."FOUR_DAYS_UTILIZATION_WST" ;;
  }
  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }
  dimension: jobsite_city_state {
    type: string
    sql: ${TABLE}."JOBSITE_CITY_STATE" ;;
  }
  dimension: lat_lon {
    type: string
    sql: ${TABLE}."LAT_LON" ;;
  }
  dimension: make_and_model {
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }
  dimension_group: next_cycle {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."NEXT_CYCLE_DATE" ;;
  }
  dimension: ordered_by {
    type: string
    sql: ${TABLE}."ORDERED_BY" ;;
  }
  dimension_group: previous_day {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PREVIOUS_DAY_DATE" ;;
  }
  dimension: previous_day_utilization_cst {
    type: number
    sql: ${TABLE}."PREVIOUS_DAY_UTILIZATION_CST" ;;
  }
  dimension: previous_day_utilization_est {
    type: number
    sql: ${TABLE}."PREVIOUS_DAY_UTILIZATION_EST" ;;
  }
  dimension: previous_day_utilization_mnt {
    type: number
    sql: ${TABLE}."PREVIOUS_DAY_UTILIZATION_MNT" ;;
  }
  dimension: previous_day_utilization_utc {
    type: number
    sql: ${TABLE}."PREVIOUS_DAY_UTILIZATION_UTC" ;;
  }
  dimension: previous_day_utilization_wst {
    type: number
    sql: ${TABLE}."PREVIOUS_DAY_UTILIZATION_WST" ;;
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
  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }
  dimension: purchase_order_name {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NAME" ;;
  }
  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: rental_location {
    type: string
    sql: ${TABLE}."RENTAL_LOCATION" ;;
  }
  dimension: rental_period_utilization_cst {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_UTILIZATION_CST" ;;
  }
  dimension: rental_period_utilization_est {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_UTILIZATION_EST" ;;
  }
  dimension: rental_period_utilization_mnt {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_UTILIZATION_MNT" ;;
  }
  dimension: rental_period_utilization_utc {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_UTILIZATION_UTC" ;;
  }
  dimension: rental_period_utilization_wst {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_UTILIZATION_WST" ;;
  }
  dimension_group: rental_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }
  dimension_group: rental_start_date_and {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."RENTAL_START_DATE_AND_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: scheduled_off_rent {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SCHEDULED_OFF_RENT_DATE" ;;
  }
  dimension_group: scheduled_off_rent_date_and {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."SCHEDULED_OFF_RENT_DATE_AND_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: seven_days_ago {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SEVEN_DAYS_AGO_DATE" ;;
  }
  dimension: seven_days_utilization_cst {
    type: number
    sql: ${TABLE}."SEVEN_DAYS_UTILIZATION_CST" ;;
  }
  dimension: seven_days_utilization_est {
    type: number
    sql: ${TABLE}."SEVEN_DAYS_UTILIZATION_EST" ;;
  }
  dimension: seven_days_utilization_mnt {
    type: number
    sql: ${TABLE}."SEVEN_DAYS_UTILIZATION_MNT" ;;
  }
  dimension: seven_days_utilization_utc {
    type: number
    sql: ${TABLE}."SEVEN_DAYS_UTILIZATION_UTC" ;;
  }
  dimension: seven_days_utilization_wst {
    type: number
    sql: ${TABLE}."SEVEN_DAYS_UTILIZATION_WST" ;;
  }
  dimension_group: six_days_ago {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SIX_DAYS_AGO_DATE" ;;
  }
  dimension: six_days_utilization_cst {
    type: number
    sql: ${TABLE}."SIX_DAYS_UTILIZATION_CST" ;;
  }
  dimension: six_days_utilization_est {
    type: number
    sql: ${TABLE}."SIX_DAYS_UTILIZATION_EST" ;;
  }
  dimension: six_days_utilization_mnt {
    type: number
    sql: ${TABLE}."SIX_DAYS_UTILIZATION_MNT" ;;
  }
  dimension: six_days_utilization_utc {
    type: number
    sql: ${TABLE}."SIX_DAYS_UTILIZATION_UTC" ;;
  }
  dimension: six_days_utilization_wst {
    type: number
    sql: ${TABLE}."SIX_DAYS_UTILIZATION_WST" ;;
  }
  dimension_group: three_days_ago {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."THREE_DAYS_AGO_DATE" ;;
  }
  dimension: three_days_utilization_cst {
    type: number
    sql: ${TABLE}."THREE_DAYS_UTILIZATION_CST" ;;
  }
  dimension: three_days_utilization_est {
    type: number
    sql: ${TABLE}."THREE_DAYS_UTILIZATION_EST" ;;
  }
  dimension: three_days_utilization_mnt {
    type: number
    sql: ${TABLE}."THREE_DAYS_UTILIZATION_MNT" ;;
  }
  dimension: three_days_utilization_utc {
    type: number
    sql: ${TABLE}."THREE_DAYS_UTILIZATION_UTC" ;;
  }
  dimension: three_days_utilization_wst {
    type: number
    sql: ${TABLE}."THREE_DAYS_UTILIZATION_WST" ;;
  }
  dimension: to_date_rental {
    type: number
    sql: ${TABLE}."TO_DATE_RENTAL" ;;
  }
  dimension: total_days_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_DAYS_ON_RENT" ;;
  }
  dimension: total_weekdays_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_WEEKDAYS_ON_RENT" ;;
  }
  dimension_group: two_days_ago {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."TWO_DAYS_AGO_DATE" ;;
  }
  dimension: two_days_utilization_cst {
    type: number
    sql: ${TABLE}."TWO_DAYS_UTILIZATION_CST" ;;
  }
  dimension: two_days_utilization_est {
    type: number
    sql: ${TABLE}."TWO_DAYS_UTILIZATION_EST" ;;
  }
  dimension: two_days_utilization_mnt {
    type: number
    sql: ${TABLE}."TWO_DAYS_UTILIZATION_MNT" ;;
  }
  dimension: two_days_utilization_utc {
    type: number
    sql: ${TABLE}."TWO_DAYS_UTILIZATION_UTC" ;;
  }
  dimension: two_days_utilization_wst {
    type: number
    sql: ${TABLE}."TWO_DAYS_UTILIZATION_WST" ;;
  }
  dimension: utilization_status {
    type: string
    sql: ${TABLE}."UTILIZATION_STATUS" ;;
  }
  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }
  measure: count {
    type: count
    drill_fields: [custom_name, purchase_order_name, filename, company_name]
  }
}
