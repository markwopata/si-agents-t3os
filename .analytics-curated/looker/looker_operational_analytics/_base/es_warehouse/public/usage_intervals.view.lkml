view: usage_intervals {
  sql_table_name: "PUBLIC"."USAGE_INTERVALS" ;;
  drill_fields: [usage_interval_id]

  dimension: usage_interval_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."USAGE_INTERVAL_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
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
  dimension: unit_id {
    type: number
    sql: ${TABLE}."UNIT_ID" ;;
  }
  dimension: value {
    type: number
    sql: ${TABLE}."VALUE" ;;
  }
}
