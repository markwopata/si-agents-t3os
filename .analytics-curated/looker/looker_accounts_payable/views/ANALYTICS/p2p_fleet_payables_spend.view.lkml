view: p2p_fleet_payables_spend {

    derived_table: {
      sql:

      SELECT
distinct
a.asset_id,
POL.INVOICE_NUMBER,
PO.VENDOR_ID,
C1.NAME AS VENDOR_NAME,
POL.INVOICE_DATE,
-- COALESCE(NT.DAYS,30) AS NET_TERM_DAYS,
-- DATEADD(DAY,COALESCE(NT.DAYS,30),INVOICE_DATE) AS DUE_DATE,
POL.ORDER_STATUS,
POL.RECONCILIATION_STATUS,
POL.FINANCE_STATUS,
pol.sage_record_id,
aph.oec,
apbill.paymentdate,
apbill.recordkey,
apbill.amount,
A.COMPANY_ID AS COMPANY_ID,
C2.NAME AS ASSET_OWNER,
pol.net_price

-- POT.PREFIX||'PO'||POL.COMPANY_PURCHASE_ORDER_ID||'-'||POL.COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER AS ORDER_NUMBER,
-- (SUM(COALESCE(POL.NET_PRICE,0)) + SUM(COALESCE(POL.FREIGHT_COST,0)) + SUM(COALESCE(POL.SALES_TAX,0))+ SUM(COALESCE(POL.REBATE,0))) AS NET_PRICE


FROM ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS AS POL

LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDERS AS PO ON POL.COMPANY_PURCHASE_ORDER_ID = PO.COMPANY_PURCHASE_ORDER_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_TYPES AS POT ON PO.COMPANY_PURCHASE_ORDER_TYPE_ID =  POT.COMPANY_PURCHASE_ORDER_TYPE_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.NET_TERMS AS NT ON PO.NET_TERMS_ID = NT.NET_TERMS_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C1 ON PO.VENDOR_ID = C1.COMPANY_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY AS APH ON  POL.ASSET_ID = APH.ASSET_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS AS A ON POL.ASSET_ID = A.ASSET_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C2 ON A.COMPANY_ID = C2.COMPANY_ID
left join analytics.intacct.apbillpayment apbill on POL.sage_record_id = apbill.recordkey

WHERE --POL.FINANCE_STATUS IN ('Dealer - Net Terms','Retail - Net Terms','Net Term Purchase')
-- AND POL.ORDER_STATUS <> ''
-- AND POL.INVOICE_NUMBER IS NOT NULL AND POL.INVOICE_NUMBER <> ''
-- AND POL.INVOICE_DATE IS NOT NULL
-- AND POL.NET_PRICE IS NOT NULL AND POL.NET_PRICE <> 0
-- AND APH.FINANCIAL_SCHEDULE_ID IS NULL
-- AND DUE_DATE >= '2016-01-01'
--AND POL.RECONCILIATION_STATUS is null

 pol.sage_record_id is not null
--AND A.COMPANY_ID IN (1854,32367,31712,6954,55524,76482)


--AND POL.DELETED_AT IS NULL
--and (pol.finance_status = '' or pol.finance_status is null)
--and
-- GROUP BY a.asset_id,
-- POL.INVOICE_NUMBER,
-- PO.VENDOR_ID,C1.NAME,
-- POL.INVOICE_DATE,
-- NT.DAYS, POL.ORDER_STATUS,
-- POL.RECONCILIATION_STATUS,
-- POL.FINANCE_STATUS,
-- A.COMPANY_ID,C2.NAME,
-- POT.PREFIX||'PO'||POL.COMPANY_PURCHASE_ORDER_ID||'-'||POL.COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER,
-- pol.sage_record_id

        ;;
    }

    # measure: count {
    #   type: count
    #   drill_fields: [detail*]
    # }

    dimension: asset_id {
      type: string
      sql: ${TABLE}."ASSET_ID" ;;
    }
    dimension: invoice_number {
      type: string
      sql: ${TABLE}."INVOICE_NUMBER" ;;
    }

    dimension: sage_record_id {
      type: string
      sql: ${TABLE}."SAGE_RECORD_ID" ;;
    }
    dimension: paymentdate {
      type: date
      sql: ${TABLE}."PAYMENTDATE" ;;
    }
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

    dimension: amount {
      type: number
      sql: ${TABLE}."AMOUNT" ;;
    }

    dimension: recordkey {
      type: string
      sql: ${TABLE}."RECORDKEY" ;;
    }
    # dimension_group: invoice_date {
    #   convert_tz:  no
    #   type: time

    #   sql: ${TABLE}."INVOICE_DATE" ;;
    # }

    dimension: vendor_id {
      type: string
      sql: ${TABLE}."VENDOR_ID" ;;
    }

    dimension_group: paid_date {
      type: time
      timeframes: [raw, date, week, month, quarter, year]
      convert_tz: no
      datatype: date
      sql: ${TABLE}."PAYMENTDATE" ;;
    }

    dimension: vendor_name {
      type: string
      sql: ${TABLE}."VENDOR_NAME" ;;
    }

    measure: oec {
      type: sum
      drill_fields: [detail*]
      sql: ${TABLE}."OEC" ;;
    }

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
        invoice_number,
        sage_record_id,
        paymentdate,

      ]
    }
  }
