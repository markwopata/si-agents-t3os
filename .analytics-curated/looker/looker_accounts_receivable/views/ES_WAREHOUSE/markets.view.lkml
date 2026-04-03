view: markets {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."MARKETS"
    ;;
  drill_fields: [market_id]

  dimension: market_id {
    primary_key: yes
    type: number
    value_format: "0"
    sql: ${TABLE}."MARKET_ID" ;;
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

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }

  dimension: account_rep_user_id {
    type: number
    sql: ${TABLE}."ACCOUNT_REP_USER_ID" ;;
  }

  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }

  dimension: canonical_name {
    type: string
    sql: ${TABLE}."CANONICAL_NAME" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
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

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: default_branch {
    type: yesno
    sql: ${TABLE}."DEFAULT_BRANCH" ;;
  }

  dimension: default_zip_code_id {
    type: number
    sql: ${TABLE}."DEFAULT_ZIP_CODE_ID" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: is_public_msp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_MSP" ;;
  }

  dimension: is_public_rsp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_RSP" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: phone_number {
    type: string
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }

  dimension: photo {
    type: string
    sql: ${TABLE}."PHOTO" ;;
  }

  dimension: ppc_phone_number {
    type: string
    sql: ${TABLE}."PPC_PHONE_NUMBER" ;;
  }

  dimension: sales_email {
    type: string
    sql: ${TABLE}."SALES_EMAIL" ;;
  }

  dimension: service_email {
    type: string
    sql: ${TABLE}."SERVICE_EMAIL" ;;
  }

  dimension: state_id {
    type: number
    sql: ${TABLE}."STATE_ID" ;;
  }

  dimension: tax_rate {
    type: number
    sql: ${TABLE}."TAX_RATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_id, canonical_name, name, assets.count, orders.count]
  }
}
