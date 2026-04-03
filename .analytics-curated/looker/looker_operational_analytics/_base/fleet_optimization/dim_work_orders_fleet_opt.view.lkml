view: dim_work_orders_fleet_opt {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_WORK_ORDERS_FLEET_OPT" ;;

  dimension: work_order_archived_time_12_hour_time {
    type: string
    sql: ${TABLE}."WORK_ORDER_ARCHIVED_TIME_12_HOUR_TIME" ;;
  }
  dimension: work_order_archived_time_24_hour_time {
    type: string
    sql: ${TABLE}."WORK_ORDER_ARCHIVED_TIME_24_HOUR_TIME" ;;
  }
  dimension: work_order_asset_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ASSET_ID" ;;
    value_format_name: id
  }
  dimension: work_order_asset_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_ASSET_KEY" ;;
  }
  dimension_group: work_order_billing {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: nullif(${TABLE}."WORK_ORDER_BILLING_DATE",'0001-01-01') ;;
  }
  dimension: work_order_billing_notes {
    type: string
    sql: ${TABLE}."WORK_ORDER_BILLING_NOTES" ;;
  }
  dimension: work_order_billing_time_12_hour_time {
    type: string
    sql: ${TABLE}."WORK_ORDER_BILLING_TIME_12_HOUR_TIME" ;;
  }
  dimension: work_order_billing_time_24_hour_time {
    type: string
    sql: ${TABLE}."WORK_ORDER_BILLING_TIME_24_HOUR_TIME" ;;
  }
  dimension: work_order_billing_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_BILLING_TYPE_ID" ;;
    value_format_name: id
  }
  dimension: work_order_billing_type_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_BILLING_TYPE_NAME" ;;
  }
  dimension_group: work_order_completed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: nullif(${TABLE}."WORK_ORDER_COMPLETED_DATE",'0001-01-01') ;;
  }
  dimension: work_order_completed_time_12_hour_time {
    type: string
    sql: ${TABLE}."WORK_ORDER_COMPLETED_TIME_12_HOUR_TIME" ;;
  }
  dimension: work_order_completed_time_24_hour_time {
    type: string
    sql: ${TABLE}."WORK_ORDER_COMPLETED_TIME_24_HOUR_TIME" ;;
  }
  dimension_group: work_order_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WORK_ORDER_CREATED_DATE" ;;
  }
  dimension: work_order_created_time_12_hour_time {
    type: string
    sql: ${TABLE}."WORK_ORDER_CREATED_TIME_12_HOUR_TIME" ;;
  }
  dimension: work_order_created_time_24_hour_time {
    type: string
    sql: ${TABLE}."WORK_ORDER_CREATED_TIME_24_HOUR_TIME" ;;
  }
  dimension: work_order_creator_user_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_CREATOR_USER_KEY" ;;
  }
  dimension_group: work_order_date_archived {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: nullif(${TABLE}."WORK_ORDER_DATE_ARCHIVED",'0001-01-01') ;;
  }
  dimension: work_order_date_archived_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_DATE_ARCHIVED_KEY" ;;
  }
  dimension: work_order_date_billing_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_DATE_BILLING_KEY" ;;
  }
  dimension: work_order_date_completed_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_DATE_COMPLETED_KEY" ;;
  }
  dimension: work_order_date_created_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_DATE_CREATED_KEY" ;;
  }
  dimension: work_order_description {
    type: string
    sql: ${TABLE}."WORK_ORDER_DESCRIPTION" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
    primary_key: yes
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  dimension: work_order_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_KEY" ;;
  }
  dimension: work_order_market_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_MARKET_ID" ;;
    value_format_name: id
  }
  dimension: work_order_market_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_MARKET_KEY" ;;
  }
  dimension: work_order_number_of_days_to_complete {
    type: number
    sql: ${TABLE}."WORK_ORDER_NUMBER_OF_DAYS_TO_COMPLETE" ;;
  }
  dimension: work_order_originator_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ORIGINATOR_ID" ;;
    value_format_name: id
  }
  dimension: work_order_originator_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ORIGINATOR_TYPE_ID" ;;
    value_format_name: id
  }
  dimension: work_order_originator_type_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_ORIGINATOR_TYPE_NAME" ;;
  }
  dimension_group: work_order_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."WORK_ORDER_RECORDTIMESTAMP" ;;
  }
  dimension: work_order_service_company_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_SERVICE_COMPANY_KEY" ;;
  }
  dimension: work_order_source {
    type: string
    sql: ${TABLE}."WORK_ORDER_SOURCE" ;;
  }
  dimension: work_order_status_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_STATUS_ID" ;;
    value_format_name: id
  }
  dimension: work_order_status_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_STATUS_NAME" ;;
  }
  dimension: work_order_time_archived_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_TIME_ARCHIVED_KEY" ;;
  }
  dimension: work_order_time_billing_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_TIME_BILLING_KEY" ;;
  }
  dimension: work_order_time_completed_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_TIME_COMPLETED_KEY" ;;
  }
  dimension: work_order_time_created_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_TIME_CREATED_KEY" ;;
  }
  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
    value_format_name: id
  }
  dimension: work_order_type_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_TYPE_NAME" ;;
  }
  dimension: work_order_urgency_level_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_URGENCY_LEVEL_ID" ;;
  }
  dimension: work_order_urgency_level_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_URGENCY_LEVEL_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [work_order_urgency_level_name, work_order_status_name, work_order_billing_type_name, work_order_originator_type_name, work_order_type_name]
  }
}
