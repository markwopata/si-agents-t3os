view: command_audit {
  derived_table: {
    sql: select
      ca.*
      ,concat(u.first_name ,' ',u.last_name ) as create_company_user
      ,ca.parameters:company_id AS company_id
      from ES_WAREHOUSE.PUBLIC.command_audit ca
      left join ES_WAREHOUSE.public.users u
      on ca.user_id =u.user_id
      where command = 'CreateCompany' ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: command_audit_id {
    type: number
    sql: ${TABLE}."COMMAND_AUDIT_ID" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: command {
    type: string
    sql: ${TABLE}."COMMAND" ;;
  }

  dimension: parameters {
    type: string
    sql: ${TABLE}."PARAMETERS" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: audit_event_source_id {
    type: number
    sql: ${TABLE}."AUDIT_EVENT_SOURCE_ID" ;;
  }

  dimension: create_company_user {
    type: string
    sql: ${TABLE}."CREATE_COMPANY_USER" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID"::INT ;;
  }

  set: detail {
    fields: [
      _es_update_timestamp_time,
      command_audit_id,
      user_id,
      command,
      parameters,
      date_created_time,
      audit_event_source_id,
      create_company_user,
      company_id
    ]
  }
}
