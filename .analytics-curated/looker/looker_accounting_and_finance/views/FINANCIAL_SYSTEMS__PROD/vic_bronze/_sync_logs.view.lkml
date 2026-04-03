view: _sync_logs {
  sql_table_name: "VIC_BRONZE"."_SYNC_LOGS" ;;

  dimension: error_message {
    type: string
    sql: ${TABLE}."ERROR_MESSAGE" ;;
  }
  dimension: json_response {
    type: string
    sql: ${TABLE}."JSON_RESPONSE" ;;
  }
  dimension: json_sent {
    type: string
    sql: ${TABLE}."JSON_SENT" ;;
  }
  dimension: object_type {
    type: string
    sql: ${TABLE}."OBJECT_TYPE" ;;
  }
  dimension: operation_type {
    type: string
    sql: ${TABLE}."OPERATION_TYPE" ;;
  }
  dimension: primary_key_returned {
    type: string
    sql: ${TABLE}."PRIMARY_KEY_RETURNED" ;;
  }
  dimension: primary_key_sent {
    type: string
    sql: ${TABLE}."PRIMARY_KEY_SENT" ;;
  }
  dimension: request_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."REQUEST_ID" ;;
  }
  dimension_group: request_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."REQUEST_TIMESTAMP" ;;
  }
  dimension: response_time_ms {
    type: number
    sql: ${TABLE}."RESPONSE_TIME_MS" ;;
  }
  dimension: status_code {
    type: string
    sql: ${TABLE}."STATUS_CODE" ;;
  }
  dimension: success {
    type: yesno
    sql: ${TABLE}."SUCCESS" ;;
  }
  dimension: sync_environment {
    type: string
    sql: ${TABLE}."SYNC_ENVIRONMENT" ;;
  }
  dimension: sync_id {
    type: string
    sql: ${TABLE}."SYNC_ID" ;;
  }
  dimension: sync_object_type {
    type: string
    sql: ${TABLE}."SYNC_OBJECT_TYPE" ;;
  }
  dimension_group: sync_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."SYNC_TIMESTAMP" ;;
  }
  measure: count {
    type: count
  }
  measure: max_response_time_ms {
    type: max
    sql: ${response_time_ms} ;;
    value_format_name: decimal_2
  }

  measure: min_response_time_ms {
    type: min
    sql: ${response_time_ms} ;;
    value_format_name: decimal_2
  }

  measure: avg_response_time_ms {
    type: average
    sql: ${response_time_ms} ;;
    value_format_name: decimal_2
  }

  measure: median_response_time_ms {
    type: median
    sql: ${response_time_ms} ;;
    value_format_name: decimal_2
  }
  measure: p95_response_time_ms {
    type: percentile
    percentile: 95
    sql: ${response_time_ms} ;;
  }
}
