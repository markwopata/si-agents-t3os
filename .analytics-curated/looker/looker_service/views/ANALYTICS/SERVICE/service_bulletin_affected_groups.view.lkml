view: service_bulletin_affected_groups {
  sql_table_name: "ANALYTICS"."SERVICE"."SERVICE_BULLETIN_AFFECTED_GROUPS" ;;
  drill_fields: [service_bulletin_affected_group_id]

  dimension: service_bulletin_affected_group_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SERVICE_BULLETIN_AFFECTED_GROUP_ID" ;;
    value_format_name: id
  }
  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }
  dimension: assigned_by {
    type: string
    sql: ${TABLE}."ASSIGNED_BY" ;;
  }
  dimension_group: date_assigned {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_ASSIGNED" AS TIMESTAMP_NTZ) ;;
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
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: serial_number_range_end {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_RANGE_END" ;;
  }
  dimension: serial_number_range_start {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_RANGE_START" ;;
  }
  dimension: service_bulletin_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."SERVICE_BULLETIN_ID" ;;
    value_format_name: id
  }
  dimension: updated_by {
    type: string
    sql: ${TABLE}."UPDATED_BY" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
    value_format_name: id
  }
  measure: count {
    type: count
    drill_fields: [service_bulletin_affected_group_id, service_bulletins.service_bulletin_name, service_bulletins.service_bulletin_id]
  }
}
