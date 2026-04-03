view: invoice_payments_charge_type {
  derived_table: {
    sql:
WITH INVOICE_CTE AS (
SELECT DISTINCT I.INVOICE_NO AS SALES_INVOICE_NUMBER,I.INVOICE_ID,I.INVOICE_DATE::DATE AS INVOICE_DATE,
CASE WHEN LI.LINE_ITEM_TYPE_ID IN (80,110,120) THEN 'Dealership' ELSE 'Rental' END AS CHARGE_TYPE
FROM ES_WAREHOUSE.PUBLIC.INVOICES AS I
LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEMS AS LI ON I.INVOICE_ID = LI.INVOICE_ID
WHERE LI.LINE_ITEM_TYPE_ID IN (118,111,50,24,80,120,110,81)
AND I.COMPANY_ID NOT IN (6954,102983,55524,1854,1855)
AND I.INVOICE_NO NOT IN ('1427672-000','1538589-000','1886831-000','2330997-000','2335197-000','2490891-000','2667746-000','3014251-000')),
PAYMENT_CTE AS (
SELECT PA.INVOICE_ID, PA.PAYMENT_ID,PA.DATE::DATE AS PAYMENT_DATE,BAER.INTACCT_BANK_ACCOUNT_ID AS CHECKING_ACCOUNT,SUM(PA.AMOUNT) AS PAYMENT_AMOUNT
FROM ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS AS PA
LEFT JOIN ES_WAREHOUSE.PUBLIC.PAYMENTS AS PMT ON PA.PAYMENT_ID = PMT.PAYMENT_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.BANK_ACCOUNT_ERP_REFS AS BAER ON PMT.BANK_ACCOUNT_ID = BAER.BANK_ACCOUNT_ID
WHERE PA.REVERSED_DATE IS NULL
GROUP BY PA.INVOICE_ID,PA.PAYMENT_ID,PA.DATE::DATE,BAER.INTACCT_BANK_ACCOUNT_ID
)
SELECT INV.SALES_INVOICE_NUMBER,INV.INVOICE_ID, INV.CHARGE_TYPE,
PMT.PAYMENT_ID, PMT.PAYMENT_DATE,PMT.CHECKING_ACCOUNT, SUM(PMT.PAYMENT_AMOUNT) AS PAYMENT_AMOUNT
FROM INVOICE_CTE AS INV
LEFT JOIN PAYMENT_CTE AS PMT ON INV.INVOICE_ID = PMT.INVOICE_ID
WHERE INV.INVOICE_DATE::DATE >= '2022-01-01'
--AND INV.SALES_INVOICE_NUMBER = '2997190-000'
GROUP BY INV.SALES_INVOICE_NUMBER, INV.INVOICE_ID,INV.CHARGE_TYPE,
PMT.PAYMENT_ID,PMT.PAYMENT_DATE, PMT.CHECKING_ACCOUNT
          ;;
  }

  ################## DIMENSIONS ##################

  dimension: sales_invoice_number {
    type: string
    html: {% if value == null %}&nbsp;
    {% else %}
    <font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}" target="_blank">{{ value }}</a></u></font>
    {% endif %};;
    sql: ${TABLE}.SALES_INVOICE_NUMBER ;;
  }

  dimension: charge_type {
    type: string
    sql: ${TABLE}.CHARGE_TYPE ;;
  }

  dimension: payment_id {
    type: string
    html: {% if value == null %}&nbsp;
    {% else %}
    <font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/payments/{{ value }}" target="_blank">{{ value }}</a></u></font>
    {% endif %};;
    sql: ${TABLE}.PAYMENT_ID ;;
  }

  dimension: checking_account {
    type: string
    sql: ${TABLE}.CHECKING_ACCOUNT ;;
  }

  ################## DATES ##################

  dimension: payment_date {
    type: date
    sql: ${TABLE}.PAYMENT_DATE ;;
  }

  ################## MEASURES ##################

  measure: payment_amount {
    type: sum
    sql: ${TABLE}.PAYMENT_AMOUNT ;;
  }
  }
