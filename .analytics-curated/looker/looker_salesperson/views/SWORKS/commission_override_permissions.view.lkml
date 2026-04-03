view: commission_override_permissions {
  sql_table_name: "SWORKS"."COMMISSIONS"."COMMISSION_OVERRIDE_PERMISSIONS" ;;
  drill_fields: [commission_override_permission_id]

  dimension: commission_override_permission_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMMISSION_OVERRIDE_PERMISSION_ID" ;;
    value_format_name: id
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    value_format_name: id
  }
  measure: count {
    type: count
    drill_fields: [commission_override_permission_id]
  }
}
