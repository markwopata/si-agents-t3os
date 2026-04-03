view: credit_snapshot {
  sql_table_name: "ANALYTICS"."TREASURY"."CREDIT_SNAPSHOT" ;;

  ####### DATES #######

  dimension_group: due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension_group: eom_billing_approved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."EOM_BILLING_APPROVED_DATE" ;;
  }

  dimension_group: eom_paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."EOM_PAID_DATE" ;;
  }

  dimension_group: snapshot {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SNAPSHOT_DATE" ;;
  }

  ####### DIMENSIONS #######

  dimension: credit_limit {
    value_format_name: usd_0
    type: number
    sql: ${TABLE}."CREDIT_LIMIT" ;;
  }

  dimension: customer_id {
    value_format_name: id
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ credit_snapshot.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: days_past_due {
    type: number
    sql: ${TABLE}."DAYS_PAST_DUE" ;;
  }

  dimension: invoice_no {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}&includeDeletedInvoices=false" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: tam {
    label: "TAM"
    type: string
    sql: ${TABLE}."TAM" ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}."TERMS" ;;
  }

  dimension: snapshot_date_is_today {
    type: yesno
    sql: ${TABLE}."SNAPSHOT_DATE" = CURRENT_DATE ;;
  }

  dimension: current_balance_dim {
    type: number
    sql: ${TABLE}."CURRENT_BALANCE" ;;
  }

  dimension: aging_bucket {
    type: string
    sql: ${TABLE}."AGING_BUCKET" ;;
  }

  dimension: fein {
    label: "FEIN"
    type: string
    sql: ${TABLE}."FEIN" ;;
  }

  dimension: account_age  {
    label: "Account Age (Months)"
    type:  number
    sql: ${TABLE}."ACCOUNT_AGE" ;;
  }

  dimension: phone_number  {
    type:  string
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }

  ####### MEASURES #######

  measure: current_balance {
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."CURRENT_BALANCE" ;;
    filters: [ snapshot_date_is_today: "yes" ]
  }

  measure: balance_dec_2022 {
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."SNAPSHOT_BALANCE" ;;
    filters: [ snapshot_date: "2022-12-31" ]
  }

  measure: balance_jun_2023 {
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."SNAPSHOT_BALANCE" ;;
    filters: [ snapshot_date: "2023-06-30" ]
  }

  measure: balance_dec_2023 {
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."SNAPSHOT_BALANCE" ;;
    filters: [ snapshot_date: "2023-12-31" ]
  }

  measure: balance_jun_2024 {
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."SNAPSHOT_BALANCE" ;;
    filters: [ snapshot_date: "2024-06-30" ]
  }

  measure: balance_dec_2024 {
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."SNAPSHOT_BALANCE" ;;
    filters: [ snapshot_date: "2024-12-31" ]
  }

  measure: oldest_days_past_due {
    type: max
    sql: ${days_past_due} ;;
    drill_fields: [trx_details*]
    filters: [snapshot_date_is_today: "yes",current_balance_dim: "NOT 0"]
  }


  ####### DRILL FIELDS #######

  set: trx_details {
    fields: [snapshot_date,customer_name,customer_id,phone_number,fein,invoice_no,credit_limit,terms,tam,days_past_due,
      balance_dec_2022,balance_jun_2023,balance_dec_2023,balance_jun_2024,balance_dec_2024,current_balance]
  }

}
