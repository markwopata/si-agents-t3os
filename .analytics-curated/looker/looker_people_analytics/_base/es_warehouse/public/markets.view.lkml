view: markets {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."MARKETS"
    ;;

  dimension: market_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: _es_update_timestamp {
    type: date_raw
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP";;
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

  dimension: date_created {
    type: date_raw
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: date_updated {
    type: date_raw
    sql: ${TABLE}."DATE_UPDATED";;
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

  dimension: market_name {
    type: string
    sql: ${TABLE}."NAME";;
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
  }
}
