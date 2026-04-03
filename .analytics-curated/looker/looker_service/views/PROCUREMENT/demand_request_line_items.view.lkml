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
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: target_id {
    type: number
    sql: ${TABLE}."TARGET_ID" ;;
  }

  dimension: target_type_id {
    type: number
    sql: ${TABLE}."TARGET_TYPE_ID" ;;
  }

  dimension: completed_by_user_id {
    type: number
    sql: ${TABLE}."COMPLETED_BY_USER_ID" ;;
  }

  dimension: cancelled_by_user_id {
    type: number
    sql: ${TABLE}."CANCELLED_BY_USER_ID" ;;
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

  dimension: is_completed {
    type: yesno
    sql: ${TABLE}."DATE_COMPLETED" IS NOT NULL ;;
  }

  dimension: is_cancelled {
    type: yesno
    sql: ${TABLE}."DATE_CANCELLED" IS NOT NULL ;;
  }

  dimension: status {
    type: string
    sql:
      CASE
        WHEN ${TABLE}."DATE_CANCELLED" IS NOT NULL THEN 'Cancelled'
        WHEN ${TABLE}."DATE_COMPLETED" IS NOT NULL THEN 'Completed'
        ELSE 'Open'
      END ;;
  }

  measure: count {
    type: count
    drill_fields: [line_item_id, demand_request_id, product_id, status, needed_by_date]
  }

  measure: total_quantity_requested {
    type: sum
    sql: ${quantity_requested} ;;
    value_format_name: decimal_0
  }

  measure: open_count {
    type: count
    filters: [status: "Open"]
  }

  measure: completed_count {
    type: count
    filters: [status: "Completed"]
  }

  measure: cancelled_count {
    type: count
    filters: [status: "Cancelled"]
  }
}
