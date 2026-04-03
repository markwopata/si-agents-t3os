view: asset_maintenance_status {
  sql_table_name: "PUBLIC"."ASSET_MAINTENANCE_STATUS" ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }
  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: business_key {
    type: string
    sql: ${TABLE}."BUSINESS_KEY" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CREATED_AT" ;;
  }
  dimension: current_secondary_usage_value {
    type: number
    sql: ${TABLE}."CURRENT_SECONDARY_USAGE_VALUE" ;;
  }
  dimension: current_time_value {
    type: number
    sql: ${TABLE}."CURRENT_TIME_VALUE" ;;
  }
  dimension: current_usage_value {
    type: number
    sql: ${TABLE}."CURRENT_USAGE_VALUE" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }
  dimension: is_deleted {
    type: yesno
    sql: ${TABLE}."IS_DELETED" ;;
  }
  dimension: last_service_secondary_usage_value {
    type: number
    sql: ${TABLE}."LAST_SERVICE_SECONDARY_USAGE_VALUE" ;;
  }
  dimension: last_service_time_value {
    type: number
    sql: ${TABLE}."LAST_SERVICE_TIME_VALUE" ;;
  }
  dimension: last_service_usage_value {
    type: number
    sql: ${TABLE}."LAST_SERVICE_USAGE_VALUE" ;;
  }
  dimension: maintenance_group_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
  }
  dimension: maintenance_group_interval_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_ID" ;;
  }
  dimension: next_service_secondary_usage_value {
    type: number
    sql: ${TABLE}."NEXT_SERVICE_SECONDARY_USAGE_VALUE" ;;
  }
  dimension: next_service_time_value {
    type: number
    sql: ${TABLE}."NEXT_SERVICE_TIME_VALUE" ;;
  }
  dimension: next_service_usage_value {
    type: number
    sql: ${TABLE}."NEXT_SERVICE_USAGE_VALUE" ;;
  }
  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }
  dimension: repeat {
    type: yesno
    sql: ${TABLE}."REPEAT" ;;
  }
  dimension: secondary_usage_interval_id {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_INTERVAL_ID" ;;
  }
  dimension: secondary_usage_percentage {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_PERCENTAGE" ;;
  }
  dimension: secondary_usage_percentage_remaining {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_PERCENTAGE_REMAINING" ;;
  }
  dimension: secondary_usage_unit_id {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_UNIT_ID" ;;
  }
  dimension: secondary_usage_value {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_VALUE" ;;
  }
  dimension: service_interval_id {
    type: number
    sql: ${TABLE}."SERVICE_INTERVAL_ID" ;;
  }
  dimension: service_interval_name {
    type: string
    sql: ${TABLE}."SERVICE_INTERVAL_NAME" ;;
  }
  dimension: service_record_id {
    type: number
    sql: ${TABLE}."SERVICE_RECORD_ID" ;;
  }
  dimension: time_interval_id {
    type: number
    sql: ${TABLE}."TIME_INTERVAL_ID" ;;
  }
  dimension: time_percentage {
    type: number
    sql: ${TABLE}."TIME_PERCENTAGE" ;;
  }
  dimension: time_percentage_remaining {
    type: number
    sql: ${TABLE}."TIME_PERCENTAGE_REMAINING" ;;
  }
  dimension: time_unit_id {
    type: number
    sql: ${TABLE}."TIME_UNIT_ID" ;;
  }
  dimension: time_value {
    type: number
    sql: ${TABLE}."TIME_VALUE" ;;
  }
  dimension: trigger_exceeded {
    type: yesno
    sql: ${TABLE}."TRIGGER_EXCEEDED" ;;
  }
  dimension: until_next_service_secondary_usage {
    type: number
    sql: ${TABLE}."UNTIL_NEXT_SERVICE_SECONDARY_USAGE" ;;
  }
  dimension: until_next_service_time {
    type: number
    sql: ${TABLE}."UNTIL_NEXT_SERVICE_TIME" ;;
  }
  dimension: until_next_service_usage {
    type: number
    sql: ${TABLE}."UNTIL_NEXT_SERVICE_USAGE" ;;
  }
  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."UPDATED_AT" ;;
  }
  dimension: usage_interval_id {
    type: number
    sql: ${TABLE}."USAGE_INTERVAL_ID" ;;
  }
  dimension: usage_percentage {
    type: number
    sql: ${TABLE}."USAGE_PERCENTAGE" ;;
  }
  dimension: usage_percentage_remaining {
    type: number
    sql: ${TABLE}."USAGE_PERCENTAGE_REMAINING" ;;
  }
  dimension: usage_unit_id {
    type: number
    sql: ${TABLE}."USAGE_UNIT_ID" ;;
  }
  dimension: usage_value {
    type: number
    sql: ${TABLE}."USAGE_VALUE" ;;
  }
  dimension: version_number {
    type: number
    sql: ${TABLE}."VERSION_NUMBER" ;;
  }
  dimension: warn_exceeded {
    type: yesno
    sql: ${TABLE}."WARN_EXCEEDED" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  dimension: work_order_originator_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ORIGINATOR_ID" ;;
  }
}
