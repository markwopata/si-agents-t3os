view: p2p_fleet_master_spreadsheet {

  derived_table: {
    sql: select abl_rating,
    asset,
    bo_b,
    class,
    due_date,
    factory_build_specs,
    financing_designation,
    invoice_date,
    invoice_number,
    make,
    market,
    market_id,
    model,
    order_number,
    order_status,
    payment_month,
    payment_week,
    pending_schedule,
    reconciliation_status,
    serial_number,
    statement_verified,
    total_oec,
    vendor,
    year,
    TO_DATE('01-' || payment_month, 'DD-Mon YYYY') AS formatted_date,
     CASE
        WHEN upper(reconciliation_status) IN ('RECONCILED', 'RECONCILED. AFTERMARKET IN PROGRESS') AND upper(order_status) = 'RECEIVED' THEN '1-Reconciled and Received'
        WHEN  upper(reconciliation_status) IN ('RECONCILED', 'RECONCILED. AFTERMARKET IN PROGRESS') AND upper(order_status) = 'SHIPPED' THEN '2-Reconciled and Shipped'
        WHEN  upper(reconciliation_status) IN ('RECONCILED', 'RECONCILED. AFTERMARKET IN PROGRESS') and upper(order_status) <> 'RECEIVED' and upper(order_status) <> 'SHIPPED' THEN '3-Reconciled and Not Shipped'
        ELSE '4-Unreconciled'
END AS recon_status_w_statment_verification,
  CASE
    WHEN vendor IN ('JCB, Inc.', 'JLG Industries Inc.', 'Genie Industries', 'John Deere Shared Services, Inc.', 'Takeuchi Mfg (US) Ltd', 'Takeuchi Mfg (US) Ltd IES') THEN 'Core'
    ELSE 'Non-Core'
  END AS vendor_category

    From analytics.fleet.fleet_fin_download_march

    WHERE
payment_month like '%20%';;
  }

  # measure: count {
  #   type: count
  #   drill_fields: [detail*]
  # }
  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }
  dimension: recon_status_w_statment_verification {
    type: string
    sql: ${TABLE}."RECON_STATUS_W_STATMENT_VERIFICATION" ;;
  }

  dimension: abl_rating {
    type: string
    sql: ${TABLE}."ABL_RATING" ;;
  }
  dimension: asset {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET" ;;
  }
  dimension: bo_b {
    type: string
    sql: ${TABLE}."BO_B" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: factory_build_specs {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECS" ;;
  }

  dimension: financing_designation {
    type: string
    sql: ${TABLE}."FINANCING_DESIGNATION" ;;
  }
  # dimension_group: invoice_date {
  #   convert_tz:  no
  #   type: time

  #   sql: ${TABLE}."INVOICE_DATE" ;;
  # }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  # dimension_group: invoice_number {
  #   type: time
  #   timeframes: [raw, date, week, month, quarter, year]
  #   convert_tz: no
  #   datatype: date
  #   sql: ${TABLE}."INVOICE_NUMBER" ;;
  # }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: order_number {
    type: string
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }

  dimension: order_status {
    type: string
    sql: ${TABLE}."ORDER_STATUS" ;;
  }

  dimension: string_payment_month {
    type: string
    sql: ${TABLE}."PAYMENT_MONTH" ;;
  }

  dimension: payment_month {
    type: date


    sql: CONCAT(SUBSTRING(${TABLE}."PAYMENT_MONTH", -4), '-', CASE
      WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Jan' THEN '01'
      WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Feb' THEN '02'
      WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Mar' THEN '03'
      WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Apr' THEN '04'
      WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'May' THEN '05'
      WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Jun' THEN '06'
      WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Jul' THEN '07'
      WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Aug' THEN '08'
      WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Sep' THEN '09'
      WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Oct' THEN '10'
      WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Nov' THEN '11'
      WHEN LEFT(${TABLE}."PAYMENT_MONTH", 3) = 'Dec' THEN '12'
    END, '-01');;
  }

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

  dimension: pending_schedule {
    type: string
    sql: ${TABLE}."PENDING_SCHEDULE" ;;
  }

  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}."RECONCILIATION_STATUS" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  # dimension: statement_verified {
  #   type: string
  #   label: "Month"
  #   sql: to_varchar(${TABLE}."PERIOD", 'MMMM YYYY');;
  # }
    dimension: statement_verified {
    type: string
    sql:${TABLE}."STATEMENT_VERIFIED";;
  }

  measure: total_oec {
    type: sum
    drill_fields: [detail*]
    sql: ${TABLE}."TOTAL_OEC" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  # dimension: billed_count_by_gl {
  #   type: number
  #   sql: ${TABLE}."UNIT_PRICE" ;;
  # }

  # dimension: billed_count_by_gl {
  #   type: number
  #   sql: ${TABLE}."EXT_COST" ;;
  # }

  # dimension: billed_count_by_gl {
  #   type: number
  #   sql: ${TABLE}."RECEIPT_CREATED" ;;
  # }


  # measure: paid {
  #   label: "Paid Amount"
  #   type: sum
  #   value_format: "#,##0;(#,##0);-"
  #   sql: ${payed_amount} ;;
  # }

  # measure: paid_count_by_gl {
  #   label: "Paid Count by GL"
  #   type: sum
  #   sql: ${payed_count_by_gl} ;;
  # }

  # measure: billed {
  #   label: "Billed Amount"
  #   type: sum
  #   value_format: "#,##0;(#,##0);-"
  #   sql: ${billed_amount} ;;
  # }

  # measure: billed_count {
  #   label: "Billed Count by GL"
  #   type: sum
  #   sql: ${billed_count_by_gl} ;;
  # }

  set: detail {
    fields: [
asset,
vendor,
    financing_designation,
    factory_build_specs,
    vendor_category,
    recon_status_w_statment_verification,

    year,

    statement_verified,
    serial_number,
    reconciliation_status,
    pending_schedule,
    payment_week,
    string_payment_month,
    order_status,
    order_number,
    model,
    market_id,
    market,
    make,
    invoice_date,
    invoice_number,
    payment_month
    ]
  }
}
