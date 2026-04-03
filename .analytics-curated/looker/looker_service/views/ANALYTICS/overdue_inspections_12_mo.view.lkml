view: overdue_inspections_12_mo {
  sql_table_name: "ANALYTICS"."SERVICE"."OVERDUE_INSPECTIONS_SNAPSHOT" ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension_group: current_time_value {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CURRENT_TIME_VALUE" ;;
  }
  dimension: current_usage_value {
    type: number
    sql: ${TABLE}."CURRENT_USAGE_VALUE" ;;
  }
  dimension_group: date_of {
    type: time
    timeframes: [raw, date, week, day_of_week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_OF" ;;
  }
  dimension_group: last_service_time_value {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
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
  dimension: maintenance_group_interval_name {
    type: string
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_NAME" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension_group: next_service_time_value {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."NEXT_SERVICE_TIME_VALUE" ;;
  }
  dimension: next_service_usage_value {
    type: number
    sql: ${TABLE}."NEXT_SERVICE_USAGE_VALUE" ;;
  }
  dimension: overdue_flag {
    type: number
    sql: ${TABLE}."OVERDUE_FLAG" ;;
  }
  dimension: service_interval_id {
    type: number
    sql: ${TABLE}."SERVICE_INTERVAL_ID" ;;
  }
  dimension: service_interval_name {
    type: string
    sql: ${TABLE}."SERVICE_INTERVAL_NAME" ;;
  }
  dimension: service_interval_type_id {
    type: number
    sql: ${TABLE}."SERVICE_INTERVAL_TYPE_ID" ;;
  }
  dimension: service_interval_type_name {
    type: string
    sql: ${TABLE}."SERVICE_INTERVAL_TYPE_NAME" ;;
  }
  dimension: service_record_id {
    type: number
    sql: ${TABLE}."SERVICE_RECORD_ID" ;;
  }
  # dimension: service_time_remaining_in_weeks {
  #   type: number
  #   sql: ${TABLE}."SERVICE_TIME_REMAINING_IN_WEEKS" ;;
  # }
  dimension: time_interval_id {
    type: number
    sql: ${TABLE}."TIME_INTERVAL_ID" ;;
  }
  dimension: time_unit_id {
    type: number
    sql: ${TABLE}."TIME_UNIT_ID" ;;
  }
  dimension: time_value {
    type: number
    sql: ${TABLE}."TIME_VALUE" ;;
  }
  dimension: until_next_service_usage {
    type: number
    sql: ${TABLE}."UNTIL_NEXT_SERVICE_USAGE" ;;
  }
  dimension: usage_interval_id {
    type: number
    sql: ${TABLE}."USAGE_INTERVAL_ID" ;;
  }
  dimension: usage_unit_id {
    type: number
    sql: ${TABLE}."USAGE_UNIT_ID" ;;
  }
  dimension: usage_value {
    type: number
    sql: ${TABLE}."USAGE_VALUE" ;;
  }
  measure: count {
    type: count
    drill_fields: [service_interval_name, maintenance_group_interval_name, service_interval_type_name]
  }
  measure: count_distinct {
    type: count_distinct
    sql: concat(${asset_id},${maintenance_group_interval_id}) ;;
    drill_fields: [details*]
  }
  measure: count_overdue {
    type: count_distinct
    filters: [overdue_flag: "1"]
    sql: concat(${asset_id},${maintenance_group_interval_id});;
  }
  set: details {
    fields: [
      asset_id,
      market_id,
      maintenance_group_interval_name,
      until_next_service_usage
    ]
  }
}
