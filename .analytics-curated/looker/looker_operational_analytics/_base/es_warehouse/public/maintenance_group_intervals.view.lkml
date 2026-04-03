view: maintenance_group_intervals {
  sql_table_name: "PUBLIC"."MAINTENANCE_GROUP_INTERVALS" ;;
  drill_fields: [maintenance_group_interval_id]

  dimension: maintenance_group_interval_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_ID" ;;
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
  dimension_group: delete {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DELETE_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: maintenance_group_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: repeat {
    type: yesno
    sql: ${TABLE}."REPEAT" ;;
  }
  dimension: secondary_usage_trigger_from_due {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_TRIGGER_FROM_DUE" ;;
  }
  dimension: secondary_usage_warn_from_due {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_WARN_FROM_DUE" ;;
  }
  dimension: service_interval_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."SERVICE_INTERVAL_ID" ;;
  }
  dimension: trigger_from_due {
    type: number
    sql: ${TABLE}."TRIGGER_FROM_DUE" ;;
  }
  dimension: usage_trigger_from_due {
    type: number
    sql: ${TABLE}."USAGE_TRIGGER_FROM_DUE" ;;
  }
  dimension: usage_warn_from_due {
    type: number
    sql: ${TABLE}."USAGE_WARN_FROM_DUE" ;;
  }
  dimension: warn_from_due {
    type: number
    sql: ${TABLE}."WARN_FROM_DUE" ;;
  }
}
