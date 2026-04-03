view: citi_card_holder {
  sql_table_name: "CREDIT_CARD"."CITI_CARD_HOLDER" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension_group: account_open {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."ACCOUNT_OPEN_DATE" ;;
  }
  dimension: account_type {
    type: string
    sql: ${TABLE}."ACCOUNT_TYPE" ;;
  }
  dimension: base_currency_code {
    type: string
    sql: ${TABLE}."BASE_CURRENCY_CODE" ;;
  }
  dimension_group: card_activation {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CARD_ACTIVATION_DATE" ;;
  }
  dimension: card_activation_status {
    type: string
    sql: ${TABLE}."CARD_ACTIVATION_STATUS" ;;
  }
  dimension_group: card_closed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CARD_CLOSED_DATE" ;;
  }
  dimension_group: card_expiration {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CARD_EXPIRATION_DATE" ;;
  }
  dimension: card_status {
    type: string
    sql: ${TABLE}."CARD_STATUS" ;;
  }
  dimension: card_status_description {
    type: string
    sql: ${TABLE}."CARD_STATUS_DESCRIPTION" ;;
  }
  dimension: corporate_account_number {
    type: number
    sql: ${TABLE}."CORPORATE_ACCOUNT_NUMBER" ;;
  }
  dimension: credit_limit {
    type: number
    sql: ${TABLE}."CREDIT_LIMIT" ;;
  }
  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: upper_full_name {
    type: string
    sql: upper(${TABLE}."FULL_NAME") ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension: middle_name {
    type: string
    sql: ${TABLE}."MIDDLE_NAME" ;;
  }
  dimension: national_id {
    type: string
    sql: ${TABLE}."NATIONAL_ID" ;;
  }
  dimension: single_transaction_limit {
    type: number
    sql: ${TABLE}."SINGLE_TRANSACTION_LIMIT" ;;
  }
  measure: count {
    type: count
    drill_fields: [last_name, first_name, full_name, middle_name]
  }
}
