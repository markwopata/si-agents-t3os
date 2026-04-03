view: legal_payments {
  derived_table: {
    sql:
 WITH OWED_CTE AS (
SELECT COMPANY_ID,SUM(OWED_AMOUNT) AS BALANCE_DUE
FROM ES_WAREHOUSE.PUBLIC.INVOICES
WHERE BILLING_APPROVED_DATE IS NOT NULL
AND BILLED_AMOUNT > 0
AND DUE_DATE::DATE < CURRENT_DATE
GROUP BY COMPANY_ID
)
SELECT P.COMPANY_ID AS CUSTOMER_ID, C.NAME AS CUSTOMER_NAME, P.PAYMENT_ID, P.DATE_CREATED::DATE AS PAYMENT_DATE_CREATED,
CCA.FINAL_COLLECTOR,CCA.DIRECT_MANAGER_NAME,
SUM(PA.AMOUNT) AS APPLIED_AMOUNT,OC.BALANCE_DUE
FROM ES_WAREHOUSE.PUBLIC.PAYMENTS AS P
INNER JOIN ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS AS PA ON P.PAYMENT_ID = PA.PAYMENT_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.BILLING_COMPANY_PREFERENCES AS BCP ON P.COMPANY_ID = BCP.COMPANY_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C ON P.COMPANY_ID = C.COMPANY_ID
LEFT JOIN ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS AS CCA ON P.COMPANY_ID = CCA.COMPANY_ID
LEFT JOIN OWED_CTE AS OC ON P.COMPANY_ID = OC.COMPANY_ID
WHERE BCP.PREFS:legal_audit = true
AND P.DATE_CREATED >= BCP.PREFS:legal_audit_time
AND PA.REVERSED_DATE IS NULL
GROUP BY ALL
HAVING SUM(PA.AMOUNT) <> 0
                ;;
  }

  ######## DIMENSIONS ########

  dimension: customer_id {
    label: "Customer ID"
    type: number
    value_format_name: id
    sql: ${TABLE}.CUSTOMER_ID ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ legal_payments.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}.CUSTOMER_NAME ;;
  }

  dimension: payment_id {
    type: number
    value_format_name: id
    html: <a href= "https://admin.equipmentshare.com/#/home/payments/{{ value }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}.PAYMENT_ID ;;
  }

  dimension: payment_date_created {
    type: date
    sql: ${TABLE}.PAYMENT_DATE_CREATED ;;
  }

  dimension: final_collector {
    type: string
    sql: ${TABLE}.FINAL_COLLECTOR ;;
  }

  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}.DIRECT_MANAGER_NAME;;
  }


  ######## MEASURES ########

  measure: applied_amount {
    type: sum
    value_format_name: usd
    drill_fields: [detail*]
    sql: ${TABLE}.APPLIED_AMOUNT ;;
  }

  measure: balance_due {
    label: "Balance Due - ES Admin"
    type: average
    value_format_name: usd
    drill_fields: [detail*]
    sql: ${TABLE}.BALANCE_DUE ;;
  }

######## DRILL-FIELDS ########

  set: detail {fields: [customer_name,customer_id,payment_id,payment_date_created,applied_amount,balance_due]}

  }
