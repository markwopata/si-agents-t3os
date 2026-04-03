view: business_segments {
  sql_table_name: "PUBLIC"."BUSINESS_SEGMENTS" ;;
  drill_fields: [business_segment_id]

  dimension: business_segment_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
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
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [business_segment_id, name]
  }
}
