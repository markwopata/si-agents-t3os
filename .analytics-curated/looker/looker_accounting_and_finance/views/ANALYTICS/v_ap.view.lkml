view: v_ap {
  sql_table_name: "ANALYTICS"."TREASURY"."V_AP_4"
    ;;

  ##########DIMENSIONS#########

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

  dimension: bill_number {
    type: string
    html: <font color="blue "><u><a href = "{{ intacct_url }}" target="_blank">{{ value }}</a></u></font>;;
    sql: ${TABLE}."BILL_NUMBER" ;;
  }



  dimension: intacct_url {
    type: string
    sql: ${TABLE}."INTACCT_URL" ;;
  }


##########DATES#########
  dimension_group: billed_date {
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
    sql: ${TABLE}."BILLED_DATE" ;;
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

  dimension_group: paid_date {
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

  ##########BUCKETS#########
  dimension: paid_status {
    type: string
    sql: ${TABLE}."PAID_STATUS" ;;
  }

  dimension: discount_eligible {
    type: string
    sql: ${TABLE}."DISCOUNT_ELIGIBLE" ;;
  }

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
    sql: case when ${days_until_due} < 0 then     '1) PAST DUE'
          when ${days_until_due} between 0 and 7 then   '2) 0 - 7 days'
          when ${days_until_due} between 8 and 14 then  '3) 8 - 14 days'
          when ${days_until_due} between 15 and 30 then '4) 15 - 30 days'
          when ${days_until_due} between 31 and 60 then '5) 31 - 60 days'
          when ${days_until_due} between 61 and 90 then '6) 61 - 90 days'
          else '7) > 90 Days' end ;;
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

  measure: paid_amount {
    type: sum
     value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

  measure: billed_amount_mm {
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

  measure: outstanding_amount {
    type: sum
     value_format: "$#,##0;($#,##0);-"
    drill_fields: [ap_details*]
    sql: ${TABLE}."OUTSTANDING_AMOUNT" ;;
  }



  measure: outstanding_amount_mm {
    type: sum
    drill_fields: [ap_details*]
    value_format: "$#.0;($#.0);-"
    sql: ${TABLE}."OUTSTANDING_AMOUNT" / 1000000 ;;
  }

  measure: average_days_to_pay {
    type: average
    drill_fields: [ap_details*]
    sql: ${days_to_pay} ;;
  }

  measure: count {
    type: count
    value_format: "#,##0"
    drill_fields: [ap_details*]
  }


  set: ap_details {
    fields: [vendor_id_name,bill_number,billed_date_date,due_date_date,paid_date_date,discount_date_date,days_until_due,days_to_pay,
      discount_eligible,paid_status,billed_amount,paid_amount,outstanding_amount]
  }


}
