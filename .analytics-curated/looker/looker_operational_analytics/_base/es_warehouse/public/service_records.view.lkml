view: service_records {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."SERVICE_RECORDS" ;;
  drill_fields: [service_record_id]

  dimension: service_record_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SERVICE_RECORD_ID" ;;
    value_format_name: id
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }
  dimension: break_in_disqualified {
    type: yesno
    sql: ${TABLE}."BREAK_IN_DISQUALIFIED" ;;
  }
  dimension: cost_labor {
    type: number
    sql: ${TABLE}."COST_LABOR" ;;
  }
  dimension: cost_parts {
    type: number
    sql: ${TABLE}."COST_PARTS" ;;
  }
  dimension: created_by {
    type: number
    sql: ${TABLE}."CREATED_BY" ;;
    value_format_name: id
  }
  dimension_group: date_completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_deleted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_DELETED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_scheduled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_SCHEDULED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: filename {
    type: string
    sql: ${TABLE}."FILENAME" ;;
  }
  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }
  dimension: iteration {
    type: number
    sql: ${TABLE}."ITERATION" ;;
  }
  dimension: maintenance_group_interval_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_ID" ;;
    value_format_name: id
  }
  dimension: miles {
    type: number
    sql: ${TABLE}."MILES" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }
  dimension: requesting_service_contact_email {
    type: string
    sql: ${TABLE}."REQUESTING_SERVICE_CONTACT_EMAIL" ;;
  }
  dimension: requesting_service_contact_number {
    type: string
    sql: ${TABLE}."REQUESTING_SERVICE_CONTACT_NUMBER" ;;
  }
  dimension: service_interval_id {
    type: number
    sql: ${TABLE}."SERVICE_INTERVAL_ID" ;;
    value_format_name: id
  }
  dimension: service_provider {
    type: string
    sql: ${TABLE}."SERVICE_PROVIDER" ;;
  }
  dimension: user_created {
    type: yesno
    sql: ${TABLE}."USER_CREATED" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }
  measure: count {
    type: count
    drill_fields: [service_record_id, filename, name]
  }
}
