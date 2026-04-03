view: fleet_reimbursements {
  sql_table_name: "ANALYTICS"."TREASURY"."FLEET_REIMBURSEMENTS"
    ;;

  dimension: asset_id {
    type: string
    value_format: "#"
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: attachments {
    type: string
    sql: ${TABLE}."ATTACHMENTS" ;;
  }



  dimension: business_segment {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension_group: current_promise {
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
    sql: ${TABLE}."CURRENT_PROMISE_DATE" ;;
  }

  dimension: days_till_due {
    type: string
    sql: ${TABLE}."DAYS_TILL_DUE" ;;
  }

  dimension: difference {
    type: string
    sql: ${TABLE}."DIFFERENCE" ;;
  }

  dimension_group: due_date {
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
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension_group: expiration {
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
    sql: ${TABLE}."EXPIRATION" ;;
  }



  dimension: factory_build_specifications {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECIFICATIONS" ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }

  dimension: financial_schedule {
    type: string
    sql: ${TABLE}."FINANCIAL_SCHEDULE" ;;
  }

  dimension: freight {
    type: number
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}."FREIGHT" ;;
  }

  dimension_group: invoice {
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
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: l_h_on_title {
    type: string
    sql: ${TABLE}."L.H._ON_TITLE" ;;
  }

  dimension: license_state {
    type: string
    sql: ${TABLE}."LICENSE_STATE" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }



  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: order_number {
    type: string
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }

  dimension: order_status {
    type: string
    sql: ${TABLE}."ORDER_STATUS" ;;
  }

  dimension_group: original_promise {
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
    sql: ${TABLE}."ORIGINAL_PROMISE_DATE" ;;
  }

  dimension: owner {
    type: string
    sql: ${TABLE}."OWNER" ;;
  }

  dimension: pending_schedule {
    type: string
    sql: ${TABLE}."PENDING_SCHEDULE" ;;
  }

  dimension: period {
    type: number
    sql: ${TABLE}."PERIOD" ;;
  }

  dimension: plate {
    type: string
    sql: ${TABLE}."PLATE" ;;
  }

  dimension: pricing_year {
    type: string
    sql: ${TABLE}."PRICING_YEAR" ;;
  }

  dimension: qty {
    type: number
    sql: ${TABLE}."QTY" ;;
  }



  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}."RECONCILIATION_STATUS" ;;
  }

  dimension: registration_cost {
    type: string
    sql: ${TABLE}."REGISTRATION_COST" ;;
  }

  dimension: reimb_due_date {
    type: date
    sql: ${TABLE}."REIMB_DUE_DATE" ;;
  }

  dimension: reimb_inv_date {
    type: string
    sql: ${TABLE}."REIMB_INV_DATE" ;;
  }

  dimension: reimbursement_invoice {
    type: string
    sql: ${TABLE}."REIMBURSEMENT_INVOICE" ;;
  }

  dimension_group: release {
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
    sql: ${TABLE}."RELEASE_DATE" ;;
  }

  dimension: sales_tax {
    type: number
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}."SALES_TAX" ;;
  }

  dimension: serial {
    type: string
    sql: ${TABLE}."SERIAL" ;;
  }

  dimension: surcharge_amount {
    type: string
    sql: ${TABLE}."SURCHARGE_AMOUNT" ;;
  }

  dimension: title_status {
    type: string
    sql: ${TABLE}."TITLE_STATUS" ;;
  }

  dimension: titled_owner {
    type: string
    sql: ${TABLE}."TITLED_OWNER" ;;
  }

  dimension: total_oec {
    label: "Total OEC"
    type: number
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}."TOTAL_OEC" ;;
  }

  dimension: tracker_id {
    type: string
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: vendor_amount {
    type: string
    sql: ${TABLE}."VENDOR_AMOUNT" ;;
  }

  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: year_quarter {
    type: string
    sql: ${TABLE}."YEAR_QUARTER" ;;
  }

  dimension: reimbursement_status {
    type: string
    sql: iff(${TABLE}."REIMBURSEMENT_STATUS" is null,'Unpaid',${TABLE}."REIMBURSEMENT_STATUS") ;;
  }

  dimension: reimbursement_date_paid {
    type: date
    sql: ${TABLE}."REIMBURSEMENT_DATE_PAID" ;;
  }

  dimension: reimbursement_days_until_due {
    type: number
    sql: datediff(day, CURRENT_TIMESTAMP() , ${reimb_due_date})  ;;
  }

  dimension: reimbursement_due_day_buckets {
    type: string
    sql:
     CASE
    WHEN  DATEDIFF(DAY,current_date,${reimb_due_date})  <= -1 THEN 'Past Due'
    WHEN  DATEDIFF(MONTH,current_date,${reimb_due_date})  = 0 THEN 'Due in Current Month'
    WHEN  (${reimb_due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${reimb_due_date})  = 1) THEN 'Due Next Month'
    WHEN  (${reimb_due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${reimb_due_date})  = 2) THEN 'Due In 2 Months'
    WHEN  (${reimb_due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${reimb_due_date})  > 2) THEN 'Due More Than 2 Months'
    ELSE 'Missing' END ;;
  }

  dimension: reimbursement_due_day_buckets_summary {
    label: "Due Day Buckets"
    type: string
    sql:
     CASE
    WHEN  date_trunc(year,${reimb_due_date}::date) in ('2022-01-01') THEN '2022'
    WHEN  date_trunc(month,${reimb_due_date}::date) in ('2023-01-01','2023-02-01','2023-03-01') THEN 'Q1-2023'
    WHEN  date_trunc(month,${reimb_due_date}::date) = '2023-04-01' THEN 'April'
    WHEN  date_trunc(month,${reimb_due_date}::date) = '2023-05-01' THEN 'May'
    WHEN  date_trunc(month,${reimb_due_date}::date) = '2023-06-01' THEN 'June'
    WHEN  date_trunc(month,${reimb_due_date}::date) = '2023-07-01' THEN 'July'
    WHEN  date_trunc(month,${reimb_due_date}::date) = '2023-08-01' THEN 'August'
    WHEN  date_trunc(month,${reimb_due_date}::date) = '2023-09-01' THEN 'September'
    WHEN  date_trunc(month,${reimb_due_date}::date) = '2023-10-01' THEN 'October'
    WHEN  ${reimb_due_date} IS NULL THEN 'Missing Due Date'
    ELSE 'Research' END ;;
    order_by_field: due_day_bucket_order
  }

  dimension: due_day_bucket_order {
    type: number
    sql: case
        when ${reimbursement_due_day_buckets_summary} =  '2022'               then 1
        when ${reimbursement_due_day_buckets_summary} =  'Q1-2023'            then 2
        when ${reimbursement_due_day_buckets_summary}  =  'April'             then 3
        when ${reimbursement_due_day_buckets_summary}  =  'May'               then 4
        when ${reimbursement_due_day_buckets_summary}  =  'June'              then 5
        when ${reimbursement_due_day_buckets_summary}  =  'July'              then 6
        when ${reimbursement_due_day_buckets_summary}  =  'August'            then 7
        when ${reimbursement_due_day_buckets_summary}  =  'September'         then 8
        when ${reimbursement_due_day_buckets_summary}  =  'October'           then 9
        WHEN  ${reimbursement_due_day_buckets_summary} =  'Missing Due Date'  then 10
        WHEN  ${reimbursement_due_day_buckets_summary} =  'Research'          then 11
        else 12 end ;;
  }


  ################### MEASURES ####################

  measure: base_net_amount {
    type: sum
    value_format: "$#,##0;($#,##0)"
    drill_fields: [fleet_details*]
    sql: ${TABLE}."BASE_NET_AMOUNT" ;;
  }

  measure: extended_price {
    type: sum
    value_format: "$#,##0;($#,##0)"
    drill_fields: [fleet_details*]
    sql: ${TABLE}."EXTENDED_PRICE" ;;
  }

  measure: net_price {
    type: sum
    value_format: "$#,##0;($#,##0)"
    drill_fields: [fleet_details*]
    sql: ${TABLE}."NET_PRICE" ;;
  }

  measure: rebate_amount {
    label: "Expected Reimbursement Amount"
    type: sum
    value_format: "$#,##0;($#,##0)"
    drill_fields: [fleet_details*]
    sql: ${TABLE}."REBATE_AMOUNT" ;;
  }

  measure: rebate_amount_paid {
    label: "Reimbursement Amount Paid"
    type: sum
    value_format: "$#,##0;($#,##0)"
    drill_fields: [fleet_details*]
    sql: ${TABLE}."REBATE_AMOUNT_PAID" ;;
  }

  measure: rebate_amount_remaining {
    label: "Reimbursement Amount Outstanding"
    type: sum
    value_format: "$#,##0;($#,##0)"
    drill_fields: [fleet_details*]
    sql: ${TABLE}."REBATE_AMOUNT_REMAINING" ;;
  }

  measure: count {
    type: count
    drill_fields: [fleet_details*]
  }

################### DRILL FIELDS ####################

  set: fleet_details {
    fields: [
      order_number, vendor, business_segment, year, make, model, market, owner, release_date, order_status, asset_id, serial, invoice_number,
      invoice_date, finance_status, note, period,due_date_date, reimbursement_invoice, reimb_inv_date,reimb_due_date,reimbursement_days_until_due,
      reimbursement_status, reimbursement_date_paid,
      total_oec, freight, sales_tax, base_net_amount, rebate_amount, rebate_amount_paid,rebate_amount_remaining
    ]
  }
}
