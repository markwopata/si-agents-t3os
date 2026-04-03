view: command_audit {
  sql_table_name: "PUBLIC"."COMMAND_AUDIT"
    ;;
  drill_fields: [command_audit_id]

  dimension: command_audit_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMMAND_AUDIT_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: audit_event_source_id {
    type: number
    sql: ${TABLE}."AUDIT_EVENT_SOURCE_ID" ;;
  }

  dimension: command {
    type: string
    sql: ${TABLE}."COMMAND" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: parameters {
    type: string
    sql: ${TABLE}."PARAMETERS" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql:  ${TABLE}."PARAMETERS":asset_id ;;
  }

  dimension: new_owner_company_id {
    type: number
    sql:  ${TABLE}."PARAMETERS":new_owner_company_id ;;
  }

  dimension: company_id {
    type: number
    sql:  ${TABLE}."PARAMETERS":"asset_args"."company_id" ;;
  }

  measure: count {
    type: count
    drill_fields: [command_audit_id]
  }
}
