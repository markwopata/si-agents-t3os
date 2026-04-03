view: payment_applications {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."PAYMENT_APPLICATIONS"
    ;;
  drill_fields: [payment_application_id]

  dimension: payment_application_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PAYMENT_APPLICATION_ID" ;;
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

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension_group: date {
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
    sql: CAST(${TABLE}."DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: payment_id {
    type: number
    sql: ${TABLE}."PAYMENT_ID" ;;
  }

  dimension: reversal_reason {
    type: string
    sql: ${TABLE}."REVERSAL_REASON" ;;
  }

  dimension: reversed_by_user_id {
    type: number
    sql: ${TABLE}."REVERSED_BY_USER_ID" ;;
  }

  dimension_group: reversed {
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
    sql: CAST(${TABLE}."REVERSED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [payment_application_id]
  }
}
