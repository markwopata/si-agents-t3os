view: commission_override_requests {
  sql_table_name: "SWORKS"."COMMISSIONS"."COMMISSION_OVERRIDE_REQUESTS" ;;
  drill_fields: [commission_override_request_id]

  dimension: commission_override_request_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMMISSION_OVERRIDE_REQUEST_ID" ;;
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
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    value_format_name: id
  }
  dimension: equipment_rate {
    type: number
    sql: ${TABLE}."EQUIPMENT_RATE" ;;
  }
  dimension: equipment_utilization {
    type: number
    sql: ${TABLE}."EQUIPMENT_UTILIZATION" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
  }
  dimension: request_note {
    type: string
    sql: ${TABLE}."REQUEST_NOTE" ;;
  }
  dimension: request_rate {
    type: number
    sql: ${TABLE}."REQUEST_RATE" ;;
  }
  dimension: request_user_id {
    type: number
    sql: ${TABLE}."REQUEST_USER_ID" ;;
    value_format_name: id
  }
  dimension_group: review {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."REVIEW_DATE" ;;
  }
  dimension: review_note {
    type: string
    sql: ${TABLE}."REVIEW_NOTE" ;;
  }
  dimension: review_status {
    type: string
    sql: ${TABLE}."REVIEW_STATUS" ;;
  }
  dimension: review_user_id {
    type: number
    sql: ${TABLE}."REVIEW_USER_ID" ;;
    value_format_name: id
  }
  measure: count {
    type: count
    drill_fields: [commission_override_request_id]
  }
}
