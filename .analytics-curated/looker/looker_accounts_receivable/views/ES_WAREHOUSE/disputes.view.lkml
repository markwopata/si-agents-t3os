view: disputes {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."DISPUTES" ;;
  drill_fields: [dispute_id]

  dimension: dispute_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."DISPUTE_ID" ;;
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
  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_resolved {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_RESOLVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: dispute_reason_id {
    type: number
    sql: ${TABLE}."DISPUTE_REASON_ID" ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: requested_by_user_id {
    type: number
    sql: ${TABLE}."REQUESTED_BY_USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [dispute_id]
  }
}
