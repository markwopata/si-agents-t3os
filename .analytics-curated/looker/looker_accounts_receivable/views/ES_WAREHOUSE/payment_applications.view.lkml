view: payment_applications {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."PAYMENT_APPLICATIONS";;
  drill_fields: [payment_application_id]

  dimension: payment_application_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PAYMENT_APPLICATION_ID" ;;
  }

  dimension: payment_invoice {
    #primary_key: yes
    type: string
    sql: concat(${payment_application_id},'-',${invoice_id}) ;;
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

  dimension: date_in_last_30 {
    type: yesno
    sql: ${date_date} >= DATEADD('day', -29, CURRENT_DATE())
         AND ${date_date} < DATEADD('day', 1, CURRENT_DATE());;
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
    label: "Reversal Reason Notes"
    sql: ${TABLE}."REVERSAL_REASON" ;;
  }

  dimension: payment_application_reversal_reason_id {
    type: string
    label: "Reversal Reason ID"
    sql: ${TABLE}."PAYMENT_APPLICATION_REVERSAL_REASON_ID" ;;
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

  dimension: payment_reversed {
    type: yesno
    sql: ${reversal_reason} is not NULL ;;
  }

  dimension: admin_link {
    type: string
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/payments/{{ payment_id._value }}" target="_blank">Admin</a></font></u> ;;
    sql: ${payment_id}  ;;
  }

  measure: last_payment_date {
    type:  date
    sql:  MAX(${TABLE}."DATE") ;;
  }
  measure: total_payments {
    type: sum
    sql: ${amount} ;;
    filters: [payment_reversed: "No"]
  }

  measure: total_payments_last_30 {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [payment_reversed: "No", date_in_last_30: "Yes"]
  }

  measure: no_payments_last_30 {
    type: yesno
    sql: ${total_payments_last_30} < 1 ;;
  }

  measure: count {
    type: count
    drill_fields: [payment_application_id]
  }
}
