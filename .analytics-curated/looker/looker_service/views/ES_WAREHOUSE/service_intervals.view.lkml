view: service_intervals {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."SERVICE_INTERVALS" ;;
  drill_fields: [service_interval_id]

  dimension: service_interval_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SERVICE_INTERVAL_ID" ;;
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
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: secondary_usage_interval_id {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_INTERVAL_ID" ;;
  }
  dimension: time_interval_id {
    type: number
    sql: ${TABLE}."TIME_INTERVAL_ID" ;;
  }
  dimension: usage_interval_id {
    type: number
    sql: ${TABLE}."USAGE_INTERVAL_ID" ;;
  }
  dimension: interval_type {
    type: string
    sql: case
      when ${time_interval_id} is not null and ${usage_interval_id} is not null then 'Combination'
      when ${time_interval_id} is not null and ${usage_interval_id} is null then 'Time'
      when ${time_interval_id} is null and ${usage_interval_id} is not null then 'Usage'
      else 'Neither' end;;
  }
  measure: count {
    type: count
    drill_fields: [service_interval_id, name, maintenance_group_intervals.count]
  }
}
