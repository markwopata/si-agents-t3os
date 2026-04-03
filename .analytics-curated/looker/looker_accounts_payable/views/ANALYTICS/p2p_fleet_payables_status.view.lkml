view: p2p_fleet_payables_status {

    derived_table: {
      sql:

select distinct
asset_id,
invoice_number,
-- serial,
reconciliation_status,
--  year,
-- factory_build_specifications,
-- attachments,
-- order_status,
-- invoice_date,
finance_status
-- note,
-- net_price,
-- pending_schedule,
-- payment_type,
--  sage_record_id
-- select *
from ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS --where sage_record_id is not null and company_purchase_order_id = 116025

-- where
-- (asset_id is not null


-- or (invoice_number <> '' or invoice_number is not null) )


--WHERE (TRIM(finance_status) = '' or finance_status is null)
--and (asset_id IS NOT NULL OR TRIM(invoice_number) <> '')
;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: asset_id {
      type: string
      sql: ${TABLE}."ASSET_ID" ;;
    }
    dimension: invoice_number {
      type: string
      sql: ${TABLE}."INVOICE_NUMBER" ;;
    }

    # dimension: sage_record_id {
    #   type: string
    #   sql: ${TABLE}."SAGE_RECORD_ID" ;;
    # }
    # dimension: paymentdate {
    #   type: date
    #   sql: ${TABLE}."PAYMENTDATE" ;;
    # }
    dimension: reconciliation_status {
      type: string
      sql: ${TABLE}."RECONCILIATION_STATUS" ;;
    }

    dimension: finance_status {
      type: string
      sql: ${TABLE}."FINANCE_STATUS" ;;
    }

    dimension: net_price {
      type: number
      sql: ${TABLE}."NET_PRICE" ;;
    }

    # dimension: amount {
    #   type: number
    #   sql: ${TABLE}."AMOUNT" ;;
    # }

    # dimension: recordkey {
    #   type: string
    #   sql: ${TABLE}."RECORDKEY" ;;
    # }
    # dimension_group: invoice_date {
    #   convert_tz:  no
    #   type: time

    #   sql: ${TABLE}."INVOICE_DATE" ;;
    # }

    # dimension: invoice_date {
    #   type: date
    #   sql: ${TABLE}."INVOICE_DATE" ;;
    # }

    # dimension_group: paid_date {
    #   type: time
    #   timeframes: [raw, date, week, month, quarter, year]
    #   convert_tz: no
    #   datatype: date
    #   sql: ${TABLE}."PAYMENTDATE" ;;
    # }

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

    # dimension_group: formatted_date {
    #   type: time
    #   timeframes: [raw, date, week, month, quarter, year]
    #   convert_tz: no
    #   datatype: date
    #   sql: ${TABLE}."FORMATTED_DATE" ;;
    # }

    # dimension: payment_week {
    #   type: string
    #   sql: ${TABLE}."PAYMENT_WEEK" ;;
    # }

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

    # measure: total_oec {
    #   type: sum
    #   sql: ${TABLE}."TOTAL_OEC" ;;
    # }

    # dimension: vendor {
    #   type: string
    #   sql: ${TABLE}."VENDOR" ;;
    # }

    # dimension: year {
    #   type: string
    #   sql: ${TABLE}."YEAR" ;;
    # }

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
        asset_id,
        invoice_number


      ]
    }
  }
