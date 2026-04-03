view: demand_requests {
  sql_table_name: "INVENTORY"."INVENTORY"."DEMAND_REQUESTS" ;;
  drill_fields: [demand_request_id, request_number]

  dimension: demand_request_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."DEMAND_REQUEST_ID" ;;
    value_format: "0"
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

  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
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

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format: "0"
  }

  dimension: requesting_inventory_id {
    type: number
    sql: ${TABLE}."REQUESTING_INVENTORY_ID" ;;
    value_format: "0"
  }

  dimension: fulfilling_inventory_id {
    type: number
    sql: ${TABLE}."FULFILLING_INVENTORY_ID" ;;
    value_format: "0"
  }

  dimension: assigned_to_user_id {
    type: number
    sql: ${TABLE}."ASSIGNED_TO_USER_ID" ;;
    value_format: "0"
  }

  dimension: requested_by_user_id {
    type: number
    sql: ${TABLE}."REQUESTED_BY_USER_ID" ;;
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

  dimension: request_number {
    type: string
    sql: ${TABLE}."REQUEST_NUMBER" ;;
  }

  dimension: contact_phone_primary {
    type: string
    sql: ${TABLE}."CONTACT_PHONE_PRIMARY" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
}
