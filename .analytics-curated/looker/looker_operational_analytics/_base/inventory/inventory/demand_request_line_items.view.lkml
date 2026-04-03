view: demand_request_line_items {
  sql_table_name: "INVENTORY"."INVENTORY"."DEMAND_REQUEST_LINE_ITEMS" ;;
  drill_fields: [line_item_id, demand_request_id]

  dimension: line_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: demand_request_id {
    type: number
    sql: ${TABLE}."DEMAND_REQUEST_ID" ;;
    value_format: "0"
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}."PRODUCT_ID" ;;
    value_format: "0"
  }

  dimension: target_id {
    type: number
    sql: ${TABLE}."TARGET_ID" ;;
    value_format: "0"
  }

  dimension: target_type_id {
    type: number
    sql: ${TABLE}."TARGET_TYPE_ID" ;;
    value_format: "0"
  }

  dimension: completed_by_user_id {
    type: number
    sql: ${TABLE}."COMPLETED_BY_USER_ID" ;;
    value_format: "0"
  }

  dimension: cancelled_by_user_id {
    type: number
    sql: ${TABLE}."CANCELLED_BY_USER_ID" ;;
    value_format: "0"
  }

  dimension: allow_substitution {
    type: yesno
    sql: ${TABLE}."ALLOW_SUBSTITUTION" ;;
  }

  dimension: will_call {
    type: yesno
    sql: ${TABLE}."WILL_CALL" ;;
  }

  dimension: quantity_requested {
    type: number
    sql: ${TABLE}."QUANTITY_REQUESTED" ;;
  }

  dimension: fulfiller_notes {
    type: string
    sql: ${TABLE}."FULFILLER_NOTES" ;;
  }

  dimension: line_notes {
    type: string
    sql: ${TABLE}."LINE_NOTES" ;;
  }

  dimension_group: needed_by {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."NEEDED_BY" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_cancelled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CANCELLED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
}
