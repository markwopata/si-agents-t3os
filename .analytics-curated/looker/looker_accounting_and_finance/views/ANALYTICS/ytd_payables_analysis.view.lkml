view: ytd_payables_analysis {
  sql_table_name: "ANALYTICS"."TREASURY"."YTD_PAYABLES_ANALYSIS_DATA" ;;


  ############ DIMENSIONS #################
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: payment_date {
    type: date
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }

  dimension: payment_week {
    type: number
    sql: ${TABLE}."PAYMENT_WEEK" ;;
  }

  dimension: payment_week_dates {
    type: string
    sql: ${TABLE}."PAYMENT_WEEK_DATES" ;;
  }

  dimension: gl_account_name {
    label: "GL Account Name"
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NAME" ;;
  }

  dimension: gl_account_number {
    label: "GL Account Number"
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NUMBER" ;;
  }

  dimension: cf {
    label: "CF"
    type: string
    sql: ${TABLE}."CF" ;;
  }

  ############ MEASURES #################


  measure: payment_amount {
    type: sum
    drill_fields: [ap_details*]
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

  ############ DRILL FIELDS #################
  set: ap_details {
    fields: [vendor_id,vendor_name,gl_account_number,gl_account_name,cf,payment_date,payment_week,payment_amount]
  }
}
