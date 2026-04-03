view: in_store_payments_less_10k {
  derived_table: {
    sql:
WITH INVOICE_CTE AS (
SELECT INVOICE_NO, BILLED_AMOUNT AS INVOICE_AMOUNT
FROM ES_WAREHOUSE.PUBLIC.INVOICES
)
SELECT I.INVOICE_NO,I.BILLING_APPROVED_DATE::DATE AS BILLING_APPROVED_DATE,
I.SHIP_FROM:branch_id AS BRANCH_ID, X.MARKET_NAME AS BRANCH_NAME, X.REGION_NAME AS REGION,X.MARKET_TYPE,
LI.LINE_ITEM_TYPE_ID,LIT.NAME AS LINE_ITEM_TYPE,
U.FIRST_NAME||' '||U.LAST_NAME AS SALESPERSON_NAME, I.COMPANY_ID AS CUSTOMER_ID, C.NAME AS CUSTOMER_NAME,
IC.INVOICE_AMOUNT AS INVOICE_AMOUNT, SUM(LI.AMOUNT) AS LINE_ITEM_AMOUNT
FROM ANALYTICS.PUBLIC.V_LINE_ITEMS AS LI
LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES AS I ON LI.INVOICE_ID = I.INVOICE_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES AS LIT ON LI.LINE_ITEM_TYPE_ID = LIT.LINE_ITEM_TYPE_ID
LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK AS X ON I.SHIP_FROM:branch_id::VARCHAR = X.MARKET_ID::VARCHAR
LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS AS U ON I.SALESPERSON_USER_ID = U.USER_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C ON I.COMPANY_ID = C.COMPANY_ID
LEFT JOIN INVOICE_CTE AS IC ON I.INVOICE_NO = IC.INVOICE_NO
WHERE I.COMPANY_ID NOT IN (SELECT COMPANY_ID FROM ANALYTICS.PUBLIC.ES_COMPANIES)
AND I.BILLING_APPROVED_DATE IS NOT NULL
AND I.BILLING_APPROVED_DATE::DATE > '2024-01-01' AND I.BILLING_APPROVED_DATE::DATE <= CURRENT_DATE
AND I.COMPANY_ID = 1000
AND X.MARKET_NAME IS NOT NULL
AND X.REGION_NAME IS NOT NULL
AND (X.MARKET_TYPE ILIKE '%Core%' OR X.MARKET_TYPE ILIKE '%Advanced%')
GROUP BY ALL
HAVING IC.INVOICE_AMOUNT BETWEEN 1 AND 9999.99
      ;;
  }

  ######### DIMENSIONS #########

  dimension: invoice_no {
    type: string
    primary_key: yes
    html: <a href= "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}.INVOICE_NO;;
  }

  dimension: link_to_fuel_dashboard  {
    type: string
    html: <a href= "https://equipmentshare.looker.com/dashboards/1452?Billing+Approved+Date=2024%2F10%2F01+to+2024%2F12%2F31&Company+ID=NULL&Billing+Approved+%28Yes+%2F+No%29=Yes" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: 'Link to Fuel Revenue Dashboard' ;;
  }



  dimension_group: billing_approved {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: market_id  {
    type: number
    value_format_name: id
    sql: ${TABLE}.BRANCH_ID;;
  }

  dimension: market_name  {
    type: string
    sql: ${TABLE}.BRANCH_NAME;;
  }

  dimension:  region {
    type: string
    sql: ${TABLE}.REGION;;
  }

  dimension:  market_type {
    type: string
    sql: ${TABLE}.MARKET_TYPE;;
  }

  dimension: line_item_type_id  {
    type: number
    sql: ${TABLE}.LINE_ITEM_TYPE_ID;;
  }

  dimension: line_item_type  {
    type: string
    sql: ${TABLE}.LINE_ITEM_TYPE;;
  }

  dimension: salesperson_name {
    type: string
    sql: ${TABLE}.SALESPERSON_NAME;;
  }

  dimension: customer_id  {
    type: number
    value_format_name: id
    sql: ${TABLE}.CUSTOMER_ID;;
  }

  dimension: customer_name  {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ in_store_payments_less_10k.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}.CUSTOMER_NAME;;
  }

  ######### MEASURES #########

  measure: invoice_amount {
    type: sum_distinct
    value_format_name: usd
    drill_fields: [trx_details*]
    sql: ${TABLE}.INVOICE_AMOUNT;;
  }

  measure: invoice_count {
    type: count_distinct
    value_format_name: decimal_0
    drill_fields: [trx_details*]
    sql: ${TABLE}.INVOICE_NO;;
  }

  measure: line_item_amount {
    type: sum
    value_format_name: usd
    drill_fields: [trx_details*]
    sql: ${TABLE}.LINE_ITEM_AMOUNT ;;
  }

  ######### DRILL FIELDS #########

  set: trx_details {
    fields: [invoice_no,billing_approved_date,market_id,market_name,region,market_type,line_item_type_id,line_item_type,
      salesperson_name,customer_id,customer_name,line_item_amount,invoice_amount]
  }


  }
