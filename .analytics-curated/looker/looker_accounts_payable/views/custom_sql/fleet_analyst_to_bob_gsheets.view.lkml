view: fleet_analyst_to_bob_gsheets {

  derived_table: {
    sql:
    select distinct
bob.*,  gs_list.ASSIGNED_FLEET_ANALYST_, gs_list.core_non_core_vehicles, gs_list.book_of_business, gs_list.category, gs_list.equipment_net_terms

from analytics.fleet.finance_status_bob bob
left join analytics.fleet.gs_fleet_vendor_list gs_list on bob.vendor_id = gs_list.fleet_track_vendor_number
      ;;
  }
  # Define the case dimension
  dimension: days_past_due {
    type: string
    sql: CASE
          WHEN ${days_until_due} <= 0 THEN 'Current'
          WHEN ${days_until_due} >= 1 AND ${days_until_due} <= 5 THEN '1-5'
          WHEN ${days_until_due} >= 6 AND ${days_until_due} <= 10 THEN '6-10'
          WHEN ${days_until_due} >= 11 AND ${days_until_due} <= 21 THEN '11-21'
          WHEN ${days_until_due} >= 22 AND ${days_until_due} <= 28 THEN '22-28'
          WHEN ${days_until_due} >= 29 AND ${days_until_due} <= 35 THEN '29-35'
          WHEN ${days_until_due} >= 36 AND ${days_until_due} <= 45 THEN '36-45'
          WHEN ${days_until_due} >= 46 AND ${days_until_due} <= 59 THEN '46-59'
          WHEN ${days_until_due} >= 60 THEN '>=60'
          ELSE 'unknown'
        END ;;
  }
  dimension: equipment_net_terms {
    type: string
    sql: ${TABLE}."EQUIPMENT_NET_TERMS" ;;
  }
  dimension: core_non_core_vehicles {
    type: string
    sql: ${TABLE}."CORE_NON_CORE_VEHICLES" ;;
  }
  dimension: book_of_business {
    type: string
    sql: ${TABLE}."BOOK_OF_BUSINESS" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: assigned_fleet_analyst {
    type: string
    sql: ${TABLE}."ASSIGNED_FLEET_ANALYST_" ;;
  }

  dimension: financing_designation {
    type: string
    sql: ${TABLE}."FINANCING_DESIGNATION" ;;
  }
  dimension: recon_status_w_statment_verification {
    type: string
    sql: ${TABLE}."RECON_STATUS_WITH_SHIPMENT_VERIFICATION" ;;
  }

  dimension: core_vs_non_core {
    type: string
    sql: ${TABLE}."CORE_VS_NON_CORE" ;;
  }
  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: BOB {
    type: string
    sql: ${TABLE}."BOB" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  dimension: paid_vs_nonpaid_own {
    type: string
    sql: ${TABLE}."CUSTOMER_PAID_" ;;
  }

  dimension: vehicle_title_status {
    type: string
    sql: ${TABLE}."VEHICLE_TITLE" ;;
  }
  dimension: payment_date {
    type: date
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }
  dimension: days_until_due {
    type: number
    sql: ${TABLE}."DAYS_UNTIL_DUE" ;;
  }


  # dimension: due_date {
  #   type: date
  #   sql: ${TABLE}."DUE_DATE" ;;
  # }

  # dimension: factory_build_specs {
  #   type: string
  #   sql: ${TABLE}."FACTORY_BUILD_SPECS" ;;
  # }

  # dimension: financing_designation {
  #   type: string
  #   sql: ${TABLE}."FINANCING_DESIGNATION" ;;
  # }
  # # dimension_group: invoice_date {
  # #   convert_tz:  no
  # #   type: time

  # #   sql: ${TABLE}."INVOICE_DATE" ;;
  # # }

  # dimension: invoice_date {
  #   type: date
  #   sql: ${TABLE}."INVOICE_DATE" ;;
  # }

  # # dimension_group: invoice_number {
  # #   type: time
  # #   timeframes: [raw, date, week, month, quarter, year]
  # #   convert_tz: no
  # #   datatype: date
  # #   sql: ${TABLE}."INVOICE_NUMBER" ;;
  # # }

  # dimension: invoice_number {
  #   type: string
  #   sql: ${TABLE}."INVOICE_NUMBER" ;;
  # }

  # dimension: make {
  #   type: string
  #   sql: ${TABLE}."MAKE" ;;
  # }

  # dimension: market {
  #   type: string
  #   sql: ${TABLE}."MARKET" ;;
  # }

  # dimension: market_id {
  #   type: string
  #   sql: ${TABLE}."MARKET_ID" ;;
  # }

  # dimension: model {
  #   type: string
  #   sql: ${TABLE}."MODEL" ;;
  # }
  # dimension: order_number {
  #   type: string
  #   sql: ${TABLE}."ORDER_NUMBER" ;;
  # }

  # dimension: order_status {
  #   type: string
  #   sql: ${TABLE}."ORDER_STATUS" ;;
  # }

  # dimension: string_payment_month {
  #   type: string
  #   sql: ${TABLE}."PAYMENT_MONTH" ;;
  # }

  # dimension: payment_month {
  #   type: date


  #   sql: CONCAT(SUBSTRING(${TABLE}."PAYMENT_MONTH", -4), '-', CASE
  #           WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Jan' THEN '01'
  #           WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Feb' THEN '02'
  #           WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Mar' THEN '03'
  #           WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Apr' THEN '04'
  #           WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'May' THEN '05'
  #           WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Jun' THEN '06'
  #           WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Jul' THEN '07'
  #           WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Aug' THEN '08'
  #           WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Sep' THEN '09'
  #           WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Oct' THEN '10'
  #           WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Nov' THEN '11'
  #           WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Dec' THEN '12'
  #         END, '-01');;
  # }

  dimension_group: formatted_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FORMATTED_DATE" ;;
  }

  dimension: payment_week {
    type: string
    sql: ${TABLE}."PAYMENT_WEEK" ;;
  }

  # dimension: pending_schedule {
  #   type: string
  #   sql: ${TABLE}."PENDING_SCHEDULE" ;;
  # }

  # dimension: reconciliation_status {
  #   type: string
  #   sql: ${TABLE}."RECONCILIATION_STATUS" ;;
  # }

  # dimension: serial_number {
  #   type: string
  #   sql: ${TABLE}."SERIAL_NUMBER" ;;
  # }

  # # dimension: statement_verified {
  # #   type: string
  # #   label: "Month"
  # #   sql: to_varchar(${TABLE}."PERIOD", 'MMMM YYYY');;
  # # }
  # dimension: statement_verified {
  #   type: string
  #   sql:${TABLE}."STATEMENT_VERIFIED";;
  # }
  measure: count {
    type:count
    drill_fields: [

      pending_schedule,
      order_number_fleet,
      asset_class,
      year,
      make,
      model,

      factory_build_specs,
      serial_number_vin,
      market_id,
      market_name,
      invoice_date,
      purchase_created_date,
      due_date,
      abl_category,
      asset_id,
      vendor,
      invoice_number_fleet,
      reconciliation_status,
      order_status,
      company_id,
      due_days_buckets_monthly,
      days_until_due,
      purchase_order_number,
      vendor_id,
      total_purchase_price,
      statement_verified,
      payment_month,
      payment_week,
      payment,
      BOB,
      financing_designation,
      core_vs_non_core,
      vehicle_title_status,

      customer_paid
    ]
    }
  measure: total_purchase_price {
    type: sum
    drill_fields: [

      pending_schedule,
      order_number_fleet,
      asset_class,
      year,
      make,
      model,

      factory_build_specs,
      serial_number_vin,
      market_id,
      market_name,
      invoice_date,
      purchase_created_date,
      due_date,
      abl_category,
      asset_id,
      vendor,
      invoice_number_fleet,
      reconciliation_status,
      order_status,
      company_id,
      due_days_buckets_monthly,
      days_until_due,
      purchase_order_number,
      vendor_id,
      total_purchase_price,
      statement_verified,
      payment_month,
      payment_week,
      payment,
      BOB,
      financing_designation,
      core_vs_non_core,
      vehicle_title_status,

      customer_paid
    ]
    sql: ${TABLE}."TOTAL_PURCHASE_PRICE" ;;
  }



  # dimension: vendor {
  #   type: string
  #   sql: ${TABLE}."VENDOR" ;;
  # }

  # dimension: year {
  #   type: string
  #   sql: ${TABLE}."YEAR" ;;
  # }

  # # dimension: billed_count_by_gl {
  # #   type: number
  # #   sql: ${TABLE}."UNIT_PRICE" ;;
  # # }

  # # dimension: billed_count_by_gl {
  # #   type: number
  # #   sql: ${TABLE}."EXT_COST" ;;
  # # }

  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }




  dimension: pending_schedule {
    type: string
    sql: ${TABLE}."PENDING_SCHEDULE" ;;
  }

  dimension: order_number_fleet {
    type: string
    sql: ${TABLE}."ORDER_NUMBER_FLEET" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: factory_build_specs {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECS" ;;
  }

  dimension: serial_number_vin {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_VIN" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }


  dimension: invoice_date {
    type: string
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: purchase_created_date {
    type: string
    sql: ${TABLE}."PURCHASE_CREATED_DATE" ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: abl_category {
    type: string
    sql: ${TABLE}."ABL_CATEGORY" ;;
  }



  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: invoice_number_fleet {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER_FLEET" ;;
  }

  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}."RECONCILIATION_STATUS" ;;
  }

  dimension: order_status {
    type: string
    sql: ${TABLE}."ORDER_STATUS" ;;
  }
  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: due_days_buckets_monthly {
    type: string
    sql: ${TABLE}."DUE_DAYS_BUCKETS_MONTHLY" ;;
  }

  # dimension: days_until_due {
  #   type: string
  #   sql: ${TABLE}."DAYS_UNTIL_DUE" ;;
  # }

  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension:  statement_verified{
    type: string
    sql: ${TABLE}."STATEMENT_VERIFIED" ;;
  }


  dimension: payment_month {
    type: string
    sql: ${TABLE}."PAYMENT_MONTH" ;;
  }
  dimension: payment {
    type: string
    sql: ${TABLE}."PAYMENT" ;;
  }


  dimension: customer_paid {
    type: string
    sql: ${TABLE}."CUSTOMER_PAID" ;;
  }

  # # measure: paid {
  # #   label: "Paid Amount"
  # #   type: sum
  # #   value_format: "#,##0;(#,##0);-"
  # #   sql: ${payed_amount} ;;
  # # }

  # # measure: paid_count_by_gl {
  # #   label: "Paid Count by GL"
  # #   type: sum
  # #   sql: ${payed_count_by_gl} ;;
  # # }

  # # measure: billed {
  # #   label: "Billed Amount"
  # #   type: sum
  # #   value_format: "#,##0;(#,##0);-"
  # #   sql: ${billed_amount} ;;
  # # }

  # # measure: billed_count {
  # #   label: "Billed Count by GL"
  # #   type: sum
  # #   sql: ${billed_count_by_gl} ;;
  # # }

  # set: detail {
  #   fields: [
  #     asset,
  #     vendor,
  #     financing_designation,
  #     factory_build_specs,
  #     vendor_category,
  #     recon_status_w_statment_verification,

  #     year,

  #     statement_verified,
  #     serial_number,
  #     reconciliation_status,
  #     pending_schedule,
  #     payment_week,
  #     string_payment_month,
  #     order_status,
  #     order_number,
  #     model,
  #     market_id,
  #     market,
  #     make,
  #     invoice_date,
  #     invoice_number,
  #     payment_month
  #   ]
  # }
  # set: detail {
  #   fields: [
  #     row,
  #     pending_schedule,
  #     order_number_fleet,
  #     asset_class,
  #     year,
  #     make,
  #     model,
  #     factory_build_specs,
  #     serial_number_vin,
  #     market_id,
  #     market_name,
  #     invoice_date,
  #     purchase_created_date,
  #     due_date,
  #     abl_category,
  #     asset_id,
  #     vendor,
  #     invoice_number_fleet,
  #     reconciliation_status,
  #     order_status_company_id,
  #     due_days_buckets_monthly,
  #     days_until_due,
  #     purchase_order_number,
  #     vendor_id,
  #     total_purchase_price,
  #     statement_verified,
  #     payment_month,
  #     payment,
  #     BOB,
  #     financing_designation,
  #     core_vs_non_core,
  #     vehicle_title_status,
  #     paid_by_es,
  #     customer_paid

  #   ]

  }
