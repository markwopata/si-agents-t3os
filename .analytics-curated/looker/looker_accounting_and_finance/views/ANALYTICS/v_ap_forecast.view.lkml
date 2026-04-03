view: v_ap_forecast {
  sql_table_name: "ANALYTICS"."TREASURY"."V_AP_FORECAST"
    ;;


###############BUCKETS##########################

  dimension: days_until_due {
    type: number
    sql: datediff(day, CURRENT_TIMESTAMP() , ${due_date_date})  ;;
  }

  dimension: due_days_buckets_monthly {
    type: string
    sql:
     CASE
    WHEN  DATEDIFF(MONTH,current_date,${due_date_date})  <= -1 THEN 'Past Due'
    WHEN  DATEDIFF(MONTH,current_date,${due_date_date})  = 0 THEN 'Due in Current Month'
    WHEN  (${due_date_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date_date})  = 1) THEN 'Due Next Month'
    WHEN  (${due_date_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date_date})  = 2) THEN 'Due In 2 Months'
    WHEN  (${due_date_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date_date})  > 2) THEN 'Due More Than 2 Months'
    ELSE 'Missing' END ;;
  }

  dimension: due_days_buckets_monthly_order {
    type: number
    sql:
     CASE
    WHEN  DATEDIFF(MONTH,current_date,${due_date_date})  <= -1 then 1
    WHEN  DATEDIFF(MONTH,current_date,${due_date_date})  = 0 THEN 2
    WHEN  (${due_date_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date_date})  = 1) THEN 3
    WHEN  (${due_date_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date_date})  = 2) THEN 4
    WHEN  (${due_date_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date_date})  > 2) THEN 5
    ELSE 6 END ;;
  }

###############DATES##########################

  dimension_group: bill_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILL_DATE" ;;
  }

  dimension_group: due_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension_group: last_payment_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LAST_PAYMENT_DATE" ;;
  }

###############DIMENSIONS##########################

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: expense_category {
    type: string
    sql: ${TABLE}."EXPENSE_CATEGORY" ;;
  }

  dimension: gl_account_name {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NAME" ;;
  }

  dimension: gl_account_number {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NUMBER" ;;
  }


  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

###############MEASURES##########################

  measure: outstanding_amount {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    drill_fields: [ap_forecast_details*]
    sql: ${TABLE}."OUTSTANDING_AMOUNT" ;;
  }


  measure: bill_amount {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: ${TABLE}."BILL_AMOUNT" ;;
  }

  measure: payment_amount {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

###############DRILL DOWN FIELDS##########################

  set: ap_forecast_details {
    fields: [
      vendor_name,vendor_id,expense_category,bill_number,bill_date_date,due_date_date,gl_account_number,gl_account_name,bill_amount,payment_amount,outstanding_amount
    ]
  }



}
