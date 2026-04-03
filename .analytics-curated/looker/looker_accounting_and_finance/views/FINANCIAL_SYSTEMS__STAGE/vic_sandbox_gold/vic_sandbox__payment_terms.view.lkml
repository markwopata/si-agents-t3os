view: vic_sandbox__payment_terms {
  sql_table_name: "VIC_GOLD"."VIC_SANDBOX__PAYMENT_TERMS" ;;

  dimension: days_to_pay {
    type: number
    sql: ${TABLE}."DAYS_TO_PAY" ;;
  }
  dimension: days_to_pay_condition {
    type: string
    sql: ${TABLE}."DAYS_TO_PAY_CONDITION" ;;
  }
  dimension: discount_days {
    type: number
    sql: ${TABLE}."DISCOUNT_DAYS" ;;
  }
  dimension: discount_days_condition {
    type: string
    sql: ${TABLE}."DISCOUNT_DAYS_CONDITION" ;;
  }
  dimension: discount_percentage {
    type: number
    sql: ${TABLE}."DISCOUNT_PERCENTAGE" ;;
  }
  dimension: fk_source_payment_term_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PAYMENT_TERM_ID" ;;
  }
  dimension: name_environment {
    type: string
    sql: ${TABLE}."NAME_ENVIRONMENT" ;;
  }
  dimension: name_term {
    type: string
    sql: ${TABLE}."NAME_TERM" ;;
  }
  dimension: pk_payment_term_id {
    type: string
    sql: ${TABLE}."PK_PAYMENT_TERM_ID" ;;
    primary_key: yes
  }
  dimension: term_description {
    type: string
    sql: ${TABLE}."TERM_DESCRIPTION" ;;
  }
  dimension_group: timestamp_extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_EXTRACTED" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
  }
}
