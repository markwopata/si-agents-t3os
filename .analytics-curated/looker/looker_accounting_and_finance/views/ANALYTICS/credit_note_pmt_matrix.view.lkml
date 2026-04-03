view: credit_note_pmt_matrix {
  sql_table_name: "ANALYTICS"."TREASURY"."CREDIT_NOTE_PMT_MATRIX" ;;


  ########## DIMENSIONS ##########

  dimension: created_by_name {
    type: string
    sql: ${TABLE}."CREATED_BY_NAME" ;;
  }

  dimension: created_by_user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: credit_note_number {
    type: string
    html: <a href='https://admin.equipmentshare.com/#/home/transactions/credit-notes/search?query={{ value | url_encode }}' target='_blank' style='color: blue; text-decoration: underline;'>{{ value | url_encode }}</a> ;;
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }

  dimension_group: date_created {
    type: time
    intervals: [day,hour] # timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: invoice_no {
    type: string
    html: <a href='https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value | url_encode }}' target='_blank' style='color: blue; text-decoration: underline;'>{{ value | url_encode }}</a> ;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }


  ########## MEASURES ##########

  measure: total_credit_amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."TOTAL_CREDIT_AMOUNT" ;;
  }

  measure: credit_note_count {
    type: count_distinct
    value_format_name: decimal_0
    drill_fields: [cn_details*]
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }

  measure: credit_note_count_daily {
    type: count_distinct
    value_format_name: decimal_0
    drill_fields: [date_details*]
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }


  ########## DRILL FIELDS ##########

  set: cn_details {
    fields: [credit_note_number,date_created_date,invoice_no,created_by_user_id,created_by_name,customer_id,customer_name,memo,total_credit_amount]
  }

  set: date_details {
    fields: [created_by_name,created_by_user_id,date_created_minute,credit_note_count]
  }

}
