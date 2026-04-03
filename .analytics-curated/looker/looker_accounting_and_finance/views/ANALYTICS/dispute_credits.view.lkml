view: dispute_credits {
  sql_table_name: "ANALYTICS"."TREASURY"."DISPUTE_CREDITS" ;;

######### DIMENSIONS #########

  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: dispute_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."DISPUTE_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }


  dimension: credit_note_number {
    type: string
    html: <a href='https://admin.equipmentshare.com/#/home/transactions/credit-notes/search?query={{ value | url_encode }}' target='_blank' style='color: blue; text-decoration: underline;'>{{ value | url_encode }}</a> ;;
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }

  dimension_group: date_created {
    label: "Credit Note Created"
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }


  dimension_group: invoice {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."INVOICE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: in_dispute_tool {
    type: string
    sql:${TABLE}."IN_DISPUTE_TOOL" ;;
  }

  dimension: invoice_no {
    type: string
    html: <a href='https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value | url_encode }}' target='_blank' style='color: blue; text-decoration: underline;'>{{ value | url_encode }}</a> ;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: general_manager {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER" ;;
  }


  dimension: days_from_invoice_to_credit_note {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."DAYS_FROM_INVOICE_TO_CREDIT_NOTE" ;;
  }



  ######### MEASURES #########

  measure: credit_note_count {
    type: count_distinct
    drill_fields: [trx_details*]
    sql: ${credit_note_number} ;;
  }

  measure: credit_note_amount {
    type: sum
    value_format_name: usd
    drill_fields: [trx_details*]
    sql: ${TABLE}."CREDIT_NOTE_AMOUNT" ;;
  }

  measure: invoice_amount {
    type: sum
    value_format_name: usd
    drill_fields: [trx_details*]
    sql: ${TABLE}."INVOICE_AMOUNT" ;;
  }


  measure: average_days_from_invoice_to_credit_note {
    type: average
    value_format_name: decimal_1
    drill_fields: [trx_details*]
    sql: ${TABLE}."DAYS_FROM_INVOICE_TO_CREDIT_NOTE" ;;
  }


  measure: average_credits_percent_of_sales {
    type: number
    value_format_name: percent_2
    drill_fields: [trx_details*]
    sql: iff(${invoice_amount}=0,0,${credit_note_amount}/${invoice_amount}) ;;
  }

  ######### DRILL FIELDS #########
  set: trx_details {
    fields: [dispute_id,invoice_no,credit_note_number,invoice_date,date_created_date,days_from_invoice_to_credit_note,in_dispute_tool,branch_id,branch_name,general_manager,invoice_amount,credit_note_amount,average_credits_percent_of_sales]
  }

}
