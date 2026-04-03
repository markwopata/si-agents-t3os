view: service_bulletins {
  sql_table_name: "ANALYTICS"."SERVICE"."SERVICE_BULLETINS" ;;
  drill_fields: [service_bulletin_id]

  dimension: service_bulletin_id {
    type: number
    sql: ${TABLE}."SERVICE_BULLETIN_ID" ;;
    value_format_name: id
  }
  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_due {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_DUE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_released {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_RELEASED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: is_current {
    type: yesno
    sql: ${TABLE}."IS_CURRENT" ;;
  }
  dimension: oem {
    type: string
    sql: ${TABLE}."OEM" ;;
  }
  dimension: service_bulletin_name {
    type: string
    sql: ${TABLE}."SERVICE_BULLETIN_NAME" ;;
  }
  dimension: service_bulletin_record_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SERVICE_BULLETIN_RECORD_ID" ;;
    value_format_name: id
  }
  dimension: service_bulletin_type {
    type: string
    sql: ${TABLE}."SERVICE_BULLETIN_TYPE" ;;
  }
  dimension: updated_by {
    type: string
    sql: ${TABLE}."UPDATED_BY" ;;
  }
  measure: count {
    type: count
    drill_fields: [service_bulletin_id, service_bulletin_name, service_bulletin_affected_groups.count, service_bulletin_assignment.count]
  }
}
