view: declined_credit_notes {
  sql_table_name: "ANALYTICS"."TREASURY"."DECLINED_CREDIT_NOTES" ;;

  ##### DIMENSIONS #####

  dimension_group: billing_approved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension_group: denied {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DENIED_DATE" ;;
  }

  dimension: credit_note_created_by {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_CREATED_BY" ;;
  }

  dimension_group: credit_note {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CREDIT_NOTE_DATE" ;;
  }

  dimension: credit_note_denied_by {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_DENIED_BY" ;;
  }

  dimension: credit_note_number {
    type: string
    html:<font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/transactions/credit-notes/search?query={{value}}" target="_blank">{{value}}</a></font></u>;;
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }

  dimension: credit_note_status {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_STATUS" ;;
  }

  dimension: denied_reason {
    type: string
    sql: ${TABLE}."DENIED_REASON" ;;
  }

  dimension: customer_id {
    value_format_name: id
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html:<font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/companies/{{ declined_credit_notes.customer_id }}" target="_blank">{{value}}</a></font></u>;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension_group: due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: originating_invoice_number {
    type: string
    html:<font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}" target="_blank">{{value}}</a></font></u>;;
    sql: ${TABLE}."ORIGINATING_INVOICE_NUMBER" ;;
  }

  dimension: outstanding_invoice {
    type: string
    sql:  iff(${TABLE}."OWED_AMOUNT">0,'Yes','No') ;;
  }

  ##### MEASURES #####

  measure: billed_amount {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  measure: owed_amount {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }

  measure: total_credit_amount {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."TOTAL_CREDIT_AMOUNT" ;;
  }


}
