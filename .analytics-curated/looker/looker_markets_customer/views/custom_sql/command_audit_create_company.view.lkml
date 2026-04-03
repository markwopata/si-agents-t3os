view: command_audit_create_company {
  derived_table: { sql:
    select
    ca.*
    ,concat(u.first_name ,' ',u.last_name ) as create_company_user
    ,ca.parameters:company_id AS company_id
    from ES_WAREHOUSE.PUBLIC.command_audit ca
    left join ES_WAREHOUSE.public.users u
    on ca.user_id =u.user_id
    where command = 'CreateCompany' ;;
  }

  dimension: command_audit_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMMAND_AUDIT_ID" ;;
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
     sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: domain_id {
    type: number
    sql: ${TABLE}."DOMAIN_ID" ;;
  }

  dimension: parameters {
    type: string
    sql: ${TABLE}."PARAMETERS" ;;
  }

  dimension: create_company_user {
    type: string
    sql: ${TABLE}."CREATE_COMPANY_USER" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID";;
  }

  dimension: app_is_current_month {
    type: yesno
    sql: DATE_TRUNC('month',current_timestamp::DATE)::DATE =  DATE_TRUNC('month', ${date_created_date}::DATE)::DATE;;
  }

  dimension: app_is_previous_month {
    type: yesno
    sql: (DATE_TRUNC('month',current_timestamp::DATE)::DATE - interval '1 month')::DATE = DATE_TRUNC('month', ${date_created_date}::DATE)::DATE;;
  }

  measure: apps_current_month {
    type: count
    filters: [app_is_current_month: "Yes" ]
    drill_fields: [create_company_user ,companies.name,company_id,markets.name, date_created_date]
  }

  measure: apps_previous_month {
    type: count
    filters: [app_is_previous_month: "Yes" ]
    drill_fields: [create_company_user ,companies.name,company_id,markets.name, date_created_date]
  }

  measure: count {
    type: count
    drill_fields: [create_company_user ,companies.name,company_id,markets.name, date_created_date]
  }
}
