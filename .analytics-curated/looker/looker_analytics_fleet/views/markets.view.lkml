view: markets {
  sql_table_name: "PUBLIC"."MARKETS"
    ;;
  drill_fields: [market_id]

  dimension: market_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    hidden: yes
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
    hidden: yes
  }

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
    hidden: yes
  }

  dimension: account_rep_user_id {
    type: number
    sql: ${TABLE}."ACCOUNT_REP_USER_ID" ;;
    hidden: yes
  }

  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
    view_label: "Branch"
  }

  dimension: canonical_name {
    type: string
    sql: ${TABLE}."CANONICAL_NAME" ;;
    hidden: yes
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    hidden: yes
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
    hidden: yes
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
    view_label: "Branch"
  }

  dimension: default_branch {
    type: yesno
    sql: ${TABLE}."DEFAULT_BRANCH" ;;
    hidden: yes
  }

  dimension: default_zip_code_id {
    type: number
    sql: ${TABLE}."DEFAULT_ZIP_CODE_ID" ;;
    hidden: yes
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
    hidden: yes
  }

  dimension: is_public_msp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_MSP" ;;
    hidden: yes
  }

  dimension: is_public_rsp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_RSP" ;;
    hidden: yes
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
    hidden: yes
  }

  dimension: name {
    label: "Branch"
    type: string
    sql: ${TABLE}."NAME" ;;
    view_label: "Branch"
  }

  dimension: phone_number {
    type: string
    sql: ${TABLE}."PHONE_NUMBER" ;;
    hidden: yes
  }

  dimension: photo {
    type: string
    sql: ${TABLE}."PHOTO" ;;
    hidden: yes
  }

  dimension: ppc_phone_number {
    type: string
    sql: ${TABLE}."PPC_PHONE_NUMBER" ;;
    hidden: yes
  }

  dimension: sales_email {
    type: string
    sql: ${TABLE}."SALES_EMAIL" ;;
    hidden: yes
  }

  dimension: service_email {
    type: string
    sql: ${TABLE}."SERVICE_EMAIL" ;;
    hidden: yes
  }

  dimension: state_id {
    type: number
    sql: ${TABLE}."STATE_ID" ;;
    hidden: yes
  }

  dimension: tax_rate {
    type: number
    sql: ${TABLE}."TAX_RATE" ;;
    hidden: yes
  }

  measure: count {
    type: count
    drill_fields: [market_id, canonical_name, name]
    hidden: yes
  }
}
