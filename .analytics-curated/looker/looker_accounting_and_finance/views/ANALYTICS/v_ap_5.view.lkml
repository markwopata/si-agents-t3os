view: v_ap_5 {
  sql_table_name: "ANALYTICS"."TREASURY"."V_AP_5"
    ;;

###############HEADERS##########################

  dimension: top_vendor_past_due {
    type: string
    sql: 'Top 25 Vendors Past Due' ;;
    html: <p style = background-color: black><font color="white" >{{ value }}</font></p> ;;
  }

  dimension: forward_looking {
    type: string
    sql: 'Forward Looking' ;;
    html: <p style = background-color: black><font color="white" >{{ value }}</font></p> ;;
  }

  dimension: top_25_vendors_by_spend {
    type: string
    sql: 'Top 25 Vendors by Spend (YTD)' ;;
    html: <p style = background-color: black><font color="white" >{{ value }}</font></p> ;;
  }

  dimension: top_5_category_by_spend {
    type: string
    sql: 'Top 5 Category by Spend (YTD)' ;;
    html: <p style = background-color: black><font color="white" >{{ value }}</font></p> ;;
  }

  ##########DIMENSIONS#########
  dimension: bill_number {
    type: string
    html: <font color="blue "><u><a href = "{{ intacct_url }}" target="_blank">{{ value }}</a></u></font>;;
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: gl_acctname {
    type: string
    sql: ${TABLE}."GL_ACCTNAME" ;;
  }

  dimension: gl_acctno {
    type: string
    sql: ${TABLE}."GL_ACCTNO" ;;
  }

  dimension: dashboard {
    type: string
    sql: ${TABLE}."DASHBOARD" ;;
  }

  dimension: gl_acct {
    type: string
    sql: concat(${gl_acctno},' - ', ${gl_acctname}) ;;
  }

  dimension: intacct_url {
    type: string
    sql: ${TABLE}."INTACCT_URL" ;;
  }

  dimension: line_number {
    type: string
    sql: ${TABLE}."LINE_NUMBER" ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: vendor_id_name {
    type: string
    sql: concat(${vendor_name},' - ', ${vendor_id}) ;;
  }

  dimension: vendor_terms {
    type: string
    sql: ${TABLE}."VENDOR_TERMS" ;;
  }

  dimension: vendor_type {
    type: string
    sql: ${TABLE}."VENDOR_TYPE" ;;
  }

  dimension: cf1_tag {
    type: string
    sql: ${TABLE}."CF1_TAG" ;;
  }

  dimension: cf2_tag {
    type: string
    sql: ${TABLE}."CF2_TAG" ;;
  }

  dimension: cf3_tag {
    type: string
    sql: ${TABLE}."CF3_TAG" ;;
  }

  dimension: selection_list {
    type: string
    sql: ${TABLE}."SELECTION_LIST" ;;
  }

  ##########DATES#########

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


  dimension_group: discount_date {
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
    sql: ${TABLE}."DISCOUNT_DATE" ;;
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

  dimension_group: gl_date {
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
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension_group: payment_date {
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
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }


##########BUCKETS##########

  dimension: days_to_pay {
    type: number
    sql: ${TABLE}."DAYS_TO_PAY" ;;
  }

  dimension: past_due {
    type: string
    sql: ${TABLE}."PAST_DUE" ;;
  }

  dimension: days_until_due {
    type: number
    sql: ${TABLE}."DAYS_UNTIL_DUE" ;;
  }

  dimension: days_until_due_bucket {
    type: string
    sql: case when ${days_until_due} < 0 then     'PAST DUE'
          when ${days_until_due} between 0 and 7 then   '0 - 7 days'
          when ${days_until_due} between 8 and 14 then  '8 - 14 days'
          when ${days_until_due} between 15 and 30 then '15 - 30 days'
          when ${days_until_due} between 31 and 60 then '31 - 60 days'
          when ${days_until_due} between 61 and 90 then '61 - 90 days'
          when ${days_until_due} between 91 and 120 then '91 - 120 days'
          else '> 121 Days' end ;;
  }

  dimension: days_until_due_bucket_order {
    type: number
    sql: case when ${days_until_due_bucket} < 0 then     1
          when ${days_until_due_bucket} between 0 and 7 then   2
          when ${days_until_due_bucket} between 8 and 14 then  3
          when ${days_until_due_bucket} between 15 and 30 then 4
          when ${days_until_due_bucket} between 31 and 60 then 5
          when ${days_until_due_bucket} between 61 and 90 then 6
          when ${days_until_due} between 91 and 120 then 7
          else 8 end ;;
  }

  dimension: days_to_pay_bucket {
    type: string
    sql:
          case when ${days_to_pay} between 0 and 7 then   '0 - 7 days'
          when ${days_to_pay} between 8 and 14 then  '8 - 14 days'
          when ${days_to_pay} between 15 and 30 then '15 - 30 days'
          when ${days_to_pay} between 31 and 60 then '31 - 60 days'
          when ${days_to_pay} between 61 and 90 then '61 - 90 days'
          when ${days_to_pay} between 91 and 120 then '91 - 120 days'
          when ${days_to_pay} > 120 then '121+ days' end ;;
    order_by_field: days_to_pay_bucket_order
  }

  dimension: days_to_pay_bucket_order {
    type: number
    sql:
          case when ${days_to_pay_bucket} = '0 - 7 days' then   1
          when ${days_to_pay_bucket} = '8 - 14 days' then  2
          when ${days_to_pay_bucket} = '15 - 30 days' then 3
          when ${days_to_pay_bucket} = '31 - 60 days' then 4
          when ${days_to_pay_bucket} = '61 - 90 days' then 5
          when ${days_to_pay_bucket} = '91 - 120 days' then 6
          when ${days_to_pay_bucket} = '120+ days' then 7 end ;;
  }


##########MEASURES#########

  measure: billed_amount {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  measure: payment_amount {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

  measure: outstanding_amount {
    label: "Outstanding Amount"
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}."OUTSTANDING_AMOUNT" ;;
  }

  measure: billed_amount_mm {
    label: "Billed Amount $ MM"
    type: sum
    value_format: "$#.0;($#.0);-"
    drill_fields: [ap_details*]
    sql: ${TABLE}."BILLED_AMOUNT"/1000000 ;;
  }

  measure: paid_amount_mm {
    type: sum
    value_format: "$#.0;($#.0);-"
    drill_fields: [ap_details*]
    sql: ${TABLE}."PAYMENT_AMOUNT"/1000000 ;;
  }

  measure: outstanding_amount_mm {
    type: sum
    drill_fields: [ap_details*]
    value_format: "$#.0;($#.0);-"
    sql: ${TABLE}."OUTSTANDING_AMOUNT" / 1000000 ;;
  }

  measure: outstanding_amounts {
    type: sum
    drill_fields: [ap_details*]
    value_format: "$#,##0MM;"
    sql: ${TABLE}."OUTSTANDING_AMOUNT"/ 1000000  ;;
  }

  measure: average_days_to_pay {
    type: average
    drill_fields: [ap_details*]
    sql: ${days_to_pay} ;;
  }

  measure: outstanding_amount_due_next_week {
    type: sum
    drill_fields: [ap_details*]
    value_format: "$0.#0;($0.#0);-"
    sql: case when ${days_until_due} between 8 and 14 then ${TABLE}."OUTSTANDING_AMOUNT" / 1000000 else 0 end ;;
  }

  measure: outstanding_amount_due_two_weeks {
    type: sum
    drill_fields: [ap_details*]
    value_format: "$0.#0;($0.#0);-"
    sql: case when ${days_until_due} between 15 and 21 then ${TABLE}."OUTSTANDING_AMOUNT" / 1000000 else 0 end ;;
  }

  measure: outstanding_amount_due_three_weeks {
    type: sum
    drill_fields: [ap_details*]
    value_format: "$0.#0;($0.#0);-"
    sql: case when ${days_until_due} between 22 and 28 then ${TABLE}."OUTSTANDING_AMOUNT" / 1000000 else 0 end ;;
  }



  measure: count {
    type: count
    value_format: "#,##0"
    drill_fields: [ap_details*]
  }

  set: ap_details {
    fields: [vendor_id,
vendor_name,
vendor_category,
vendor_type,
vendor_terms,
bill_number,
line_number,
bill_date_date,
gl_date_date,
due_date_date,
discount_date_date,
payment_date_date,
gl_acctno,
gl_acctname,
cf1_tag,
cf2_tag,
cf3_tag,
dashboard,
intacct_url,
days_to_pay,
past_due,
days_until_due,
billed_amount,
payment_amount,
outstanding_amount,
]
  }

  }
