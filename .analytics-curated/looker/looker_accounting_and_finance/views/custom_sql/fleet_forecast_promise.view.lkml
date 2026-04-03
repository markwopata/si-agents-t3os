view: fleet_forecast_promise {
  derived_table: {
    sql:
    SELECT PO.COMPANY_PURCHASE_ORDER_ID,POL.INVOICE_NUMBER,PO.VENDOR_ID,C1.NAME AS VENDOR_NAME,
COALESCE(POL.CURRENT_PROMISE_DATE,POL.ORIGINAL_PROMISE_DATE) AS PROMISE_DATE,
COALESCE(NT.DAYS,30) AS NET_TERM_DAYS,
DATEADD(DAY,COALESCE(NT.DAYS,30),PROMISE_DATE) AS DUE_DATE,POL.ORDER_STATUS, POL.RECONCILIATION_STATUS,POL.FINANCE_STATUS,
POT.PREFIX||'PO'||POL.COMPANY_PURCHASE_ORDER_ID||'-'||POL.COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER AS ORDER_NUMBER,
SUM(COALESCE(POL.NET_PRICE,0)) AS NET_PRICE
FROM ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS AS POL
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDERS AS PO ON POL.COMPANY_PURCHASE_ORDER_ID = PO.COMPANY_PURCHASE_ORDER_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_TYPES AS POT ON PO.COMPANY_PURCHASE_ORDER_TYPE_ID =  POT.COMPANY_PURCHASE_ORDER_TYPE_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.NET_TERMS AS NT ON PO.NET_TERMS_ID = NT.NET_TERMS_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C1 ON PO.VENDOR_ID = C1.COMPANY_ID
WHERE POL.FINANCE_STATUS IN ('Dealer - Net Terms','Retail - Net Terms','Net Term Purchase')
AND POL.INVOICE_NUMBER IS NULL
AND POL.INVOICE_DATE IS NULL
AND POL.RELEASE_DATE IS NULL
AND COALESCE(POL.CURRENT_PROMISE_DATE,POL.ORIGINAL_PROMISE_DATE) IS NOT NULL
AND POL.NET_PRICE IS NOT NULL AND POL.NET_PRICE <> 0
AND DUE_DATE >= '2016-01-01'
GROUP BY PO.COMPANY_PURCHASE_ORDER_ID,POL.INVOICE_NUMBER, PO.VENDOR_ID,C1.NAME,POL.RELEASE_DATE, NT.DAYS,COALESCE(POL.CURRENT_PROMISE_DATE,POL.ORIGINAL_PROMISE_DATE),
POL.ORDER_STATUS, POL.RECONCILIATION_STATUS,POL.FINANCE_STATUS,POT.PREFIX||'PO'||POL.COMPANY_PURCHASE_ORDER_ID||'-'||POL.COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER
     ;;
  }


  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}.COMPANY_PURCHASE_ORDER_ID ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}.INVOICE_NUMBER ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.VENDOR_ID ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.VENDOR_NAME ;;
  }

  dimension: vendor {
    type: string
    sql: concat(${vendor_name},' - ', ${vendor_id}) ;;
  }

  dimension: promise_date {
    type: date
    sql: ${TABLE}.PROMISE_DATE ;;
  }

  dimension: order_number {
    type: string
    sql: ${TABLE}.ORDER_NUMBER ;;
  }


  dimension: net_term_days {
    type: number
    sql: ${TABLE}.NET_TERM_DAYS ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}.DUE_DATE ;;
  }

  dimension: order_status {
    type: string
    sql: ${TABLE}.ORDER_STATUS ;;
  }



  dimension: finance_status {
    type: string
    sql: ${TABLE}.FINANCE_STATUS ;;
  }

  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}.RECONCILIATION_STATUS ;;
  }

  measure : net_price {
    type: sum
    drill_fields: [net_price_details*]
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: ${TABLE}.NET_PRICE ;;
  }

  measure : net_price_k {
    type: sum
    value_format: "$0.0;($0.0);-"
    #drill_fields: [fleet_details*]
    sql: ${TABLE}.NET_PRICE/1000 ;;
  }

  dimension: days_until_due {
    type: number
    sql: datediff(day, CURRENT_TIMESTAMP() , ${due_date})  ;;
  }

  dimension: due_days_buckets_monthly {
    type: string
    sql:
     CASE
    WHEN  DATEDIFF(MONTH,current_date,${due_date})  <= -1 THEN 'Past Due'
    WHEN  DATEDIFF(MONTH,current_date,${due_date})  = 0 THEN 'Due in Current Month'
    WHEN  (${due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date})  = 1) THEN 'Due Next Month'
    WHEN  (${due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date})  = 2) THEN 'Due In 2 Months'
    WHEN  (${due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date})  > 2) THEN 'Due More Than 2 Months'
    ELSE 'Missing' END ;;
  }

  dimension: due_days_buckets_monthly_order {
    type: number
    sql:
     CASE
    WHEN  DATEDIFF(MONTH,current_date,${due_date})  <= -1 then 1
    WHEN  DATEDIFF(MONTH,current_date,${due_date})  = 0 THEN 2
    WHEN  (${due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date})  = 1) THEN 3
    WHEN  (${due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date})  = 2) THEN 4
    WHEN  (${due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date})  > 2) THEN 5
    ELSE 6 END ;;
  }

  set: net_price_details {
    fields: [
      order_number,purchase_order_id,invoice_number,vendor_name,reconciliation_status,promise_date,net_term_days,due_date,order_status,
      finance_status,days_until_due,due_days_buckets_monthly,net_price
    ]
  }


}
