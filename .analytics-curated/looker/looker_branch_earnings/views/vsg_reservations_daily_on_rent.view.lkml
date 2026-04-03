view: vsg_reservations_daily_on_rent {
  sql_table_name: "ANALYTICS"."VEHICLE_SOLUTIONS"."VSG_RESERVATIONS_DAILY_ON_RENT" ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }
  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }
  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: as_of {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."AS_OF_DATE" ;;
  }
  dimension: month {
    type: number
    sql: ${TABLE}."MONTH" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  dimension: month_name {
    type: string
    sql: ${TABLE}."MONTH_NAME" ;;
  }
  dimension: billing_complete {
    type: yesno
    sql: ${TABLE}."BILLING_COMPLETE" ;;
  }
  dimension: charging_balance {
    type: number
    sql: ${TABLE}."CHARGING_BALANCE" ;;
  }
  dimension: charging_method {
    type: string
    sql: ${TABLE}."CHARGING_METHOD" ;;
  }
  dimension_group: collected {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COLLECTED_AT" ;;
  }
  dimension: collections_status {
    type: string
    sql: ${TABLE}."COLLECTIONS_STATUS" ;;
  }
  dimension: confirm_insurance {
    type: yesno
    sql: ${TABLE}."CONFIRM_INSURANCE" ;;
  }
  dimension: confirm_license {
    type: yesno
    sql: ${TABLE}."CONFIRM_LICENSE" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: created_by_service {
    type: string
    sql: ${TABLE}."CREATED_BY_SERVICE" ;;
  }
  dimension: customer_first_name {
    type: string
    sql: ${TABLE}."CUSTOMER_FIRST_NAME" ;;
  }
  dimension: customer_last_name {
    type: string
    sql: ${TABLE}."CUSTOMER_LAST_NAME" ;;
  }
  dimension: damage_waiver {
    type: yesno
    sql: ${TABLE}."DAMAGE_WAIVER" ;;
  }
  dimension: dbt_scd_id {
    type: string
    sql: ${TABLE}."DBT_SCD_ID" ;;
  }
  dimension_group: dbt_snapshot {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DBT_SNAPSHOT_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: dbt_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DBT_UPDATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: dbt_valid_from {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DBT_VALID_FROM" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: dbt_valid_to {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DBT_VALID_TO" AS TIMESTAMP_NTZ) ;;
  }
  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }
  dimension: extended {
    type: yesno
    sql: ${TABLE}."EXTENDED" ;;
  }
  dimension: gclid {
    type: string
    sql: ${TABLE}."GCLID" ;;
  }
  dimension: is_expired {
    type: yesno
    sql: ${TABLE}."IS_EXPIRED" ;;
  }
  dimension: late {
    type: yesno
    sql: ${TABLE}."LATE" ;;
  }
  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
  dimension: payment_balance {
    type: number
    sql: ${TABLE}."PAYMENT_BALANCE" ;;
  }
  dimension: phone {
    type: string
    sql: ${TABLE}."PHONE" ;;
  }
  dimension_group: pick_up {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."PICK_UP_DATE" ;;
  }
  dimension_group: picked_up {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."PICKED_UP_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: pickup {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."PICKUP_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: pickup_at_local_tz {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."PICKUP_AT_LOCAL_TZ" AS TIMESTAMP_NTZ) ;;
  }
  dimension: pickup_location {
    type: string
    sql: ${TABLE}."PICKUP_LOCATION" ;;
  }
  dimension: pickup_location_id {
    type: number
    sql: ${TABLE}."PICKUP_LOCATION_ID" ;;
  }
  dimension: pickup_photos {
    type: yesno
    sql: ${TABLE}."PICKUP_PHOTOS" ;;
  }
  dimension: pickup_schedule_priority {
    type: number
    sql: ${TABLE}."PICKUP_SCHEDULE_PRIORITY" ;;
  }
  dimension: day {
    type: number
    sql: ${TABLE}."DAY" ;;
  }
  dimension: pickup_timezone {
    type: string
    sql: ${TABLE}."PICKUP_TIMEZONE" ;;
  }
  dimension: pickup_user_id {
    type: string
    sql: ${TABLE}."PICKUP_USER_ID" ;;
  }
  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }
  dimension: platform_id {
    type: string
    sql: ${TABLE}."PLATFORM_ID" ;;
  }
  dimension: prefixed_id {
    type: string
    sql: ${TABLE}."PREFIXED_ID" ;;
  }
  dimension: region_id {
    type: number
    sql: ${TABLE}."REGION_ID" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  dimension: reservation_id {
    type: number
    sql: ${TABLE}."RESERVATION_ID" ;;
  }
  dimension_group: return {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."RETURN_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: return_location {
    type: string
    sql: ${TABLE}."RETURN_LOCATION" ;;
  }
  dimension: return_location_id {
    type: number
    sql: ${TABLE}."RETURN_LOCATION_ID" ;;
  }
  dimension: return_photos {
    type: yesno
    sql: ${TABLE}."RETURN_PHOTOS" ;;
  }
  dimension: return_schedule_priority {
    type: number
    sql: ${TABLE}."RETURN_SCHEDULE_PRIORITY" ;;
  }
  dimension: return_timezone {
    type: string
    sql: ${TABLE}."RETURN_TIMEZONE" ;;
  }
  dimension: return_user_id {
    type: string
    sql: ${TABLE}."RETURN_USER_ID" ;;
  }
  dimension_group: returned {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."RETURNED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: security_balance {
    type: number
    sql: ${TABLE}."SECURITY_BALANCE" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: tesla_rents_id {
    type: string
    sql: ${TABLE}."TESLA_RENTS_ID" ;;
  }
  dimension_group: updated_at {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."UPDATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: upload_pickup_photos {
    type: yesno
    sql: ${TABLE}."UPLOAD_PICKUP_PHOTOS" ;;
  }
  dimension: upload_return_photos {
    type: yesno
    sql: ${TABLE}."UPLOAD_RETURN_PHOTOS" ;;
  }
  dimension: vehicle_class {
    type: number
    sql: ${TABLE}."VEHICLE_CLASS" ;;
  }
  dimension: vehicle_model {
    type: string
    sql: ${TABLE}."VEHICLE_MODEL" ;;
  }
  dimension: vehicle_vin {
    type: string
    sql: ${TABLE}."VEHICLE_VIN" ;;
  }
  dimension: is_month_to_date {
    type: yesno
    sql: ${TABLE}."IS_MONTH_TO_DATE" ;;
  }
  dimension: is_current_month {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTH" ;;
  }
  measure: count {
    type: count
    drill_fields: [id, customer_first_name, customer_last_name, region_name]
  }
  measure: count_reservations {
    type: count_distinct
    sql: ${reservation_id} ;;
    drill_fields: [reservation_id, customer_first_name, customer_last_name, region_name, vehicle_vin]
  }
}
