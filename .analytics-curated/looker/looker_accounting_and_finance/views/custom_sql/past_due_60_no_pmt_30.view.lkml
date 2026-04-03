view: past_due_60_no_pmt_30 {
  derived_table: {
    sql: WITH INVOICE_CTE AS (
SELECT COMPANY_ID, INVOICE_NO, SHIP_FROM:branch_id AS BRANCH_ID,
BILLING_APPROVED_DATE, DUE_DATE,BILLED_AMOUNT,OWED_AMOUNT
FROM ES_WAREHOUSE.PUBLIC.INVOICES
WHERE BILLING_APPROVED_DATE IS NOT NULL
AND BILLED_AMOUNT > 0
AND OWED_AMOUNT > 0
) ,
PAYMENT_CTE AS (
SELECT P.COMPANY_ID, MAX(P.PAYMENT_DATE::DATE) AS MOST_RECENT_PAYMENT_DATE ,
DATEDIFF(DAY,MAX(P.PAYMENT_DATE::DATE),CURRENT_DATE) AS DAYS_SINCE_LAST_PAYMENT
FROM ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS AS PA
JOIN ES_WAREHOUSE.PUBLIC.PAYMENTS AS P ON PA.PAYMENT_ID = P.PAYMENT_ID
WHERE PA.REVERSED_DATE IS NULL
GROUP BY ALL
--HAVING DAYS_SINCE_LAST_PAYMENT > 30
),
CUSTOMER_COLLECTOR_CTE AS (
SELECT DISTINCT COMPANY_ID,FINAL_COLLECTOR,DIRECT_MANAGER_NAME
FROM ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS
),
MARKET_COLLECTOR_CTE AS (
SELECT DISTINCT MARKET_ID, MARKET_COLLECTOR, DIRECT_MANAGER_NAME
FROM ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS
WHERE MARKET_COLLECTOR = FINAL_COLLECTOR
)
SELECT IC.COMPANY_ID AS CUSTOMER_ID, C.NAME AS CUSTOMER_NAME, C.DO_NOT_RENT AS DNR,
MIN(IC.DUE_DATE::DATE) AS OLDEST_DUE_DATE,
DATEDIFF(DAY,MIN(IC.DUE_DATE::DATE),CURRENT_DATE) AS DAYS_PAST_DUE,
COALESCE(CCC.FINAL_COLLECTOR,MCC.MARKET_COLLECTOR) AS COLLECTOR,
CASE WHEN CCC.COMPANY_ID IS NULL THEN MCC.DIRECT_MANAGER_NAME ELSE CCC.DIRECT_MANAGER_NAME END AS MANAGER,
CT.TAM, CT.TAM_EMAIL,
BCP.PREFS:managed_billing AS MANAGED_BILLING, BCP.PREFS:national_account AS NATIONAL_ACCOUNT,
C.HAS_MSA AS MASTER_SERVICE_AGGREMENT , PC.MOST_RECENT_PAYMENT_DATE,PC.DAYS_SINCE_LAST_PAYMENT,
SUM(IC.OWED_AMOUNT) AS OWED_AMOUNT
FROM INVOICE_CTE AS IC
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C ON IC.COMPANY_ID = C.COMPANY_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.BILLING_COMPANY_PREFERENCES AS BCP ON IC.COMPANY_ID = BCP.COMPANY_ID
LEFT JOIN PAYMENT_CTE AS PC ON IC.COMPANY_ID = PC.COMPANY_ID
LEFT JOIN CUSTOMER_COLLECTOR_CTE AS CCC ON IC.COMPANY_ID = CCC.COMPANY_ID
LEFT JOIN MARKET_COLLECTOR_CTE AS MCC ON IC.BRANCH_ID::VARCHAR = MCC.MARKET_ID::VARCHAR
LEFT JOIN ANALYTICS.TREASURY.CUSTOMER_TAM AS CT ON IC.COMPANY_ID = CT.CUSTOMER_ID
WHERE IC.BILLING_APPROVED_DATE IS NOT NULL
AND IC.COMPANY_ID NOT IN (SELECT COMPANY_ID FROM ANALYTICS.PUBLIC.ES_COMPANIES)
AND coalesce(BCP.PREFS:managed_billing,false) <> true
AND coalesce(BCP.PREFS:national_account,false) <> true
AND coalesce(BCP.PREFS:specialized_billing,false) <> true
AND coalesce(C.HAS_MSA,false) <> true
GROUP BY ALL
HAVING DAYS_PAST_DUE >= 60
AND SUM(IC.OWED_AMOUNT) > 0
AND ((PC.DAYS_SINCE_LAST_PAYMENT > 30) OR (PC.DAYS_SINCE_LAST_PAYMENT IS NULL))
                ;;
  }


  ####### DIMENSIONS #######

  dimension: customer_id {
    type: string
    value_format_name: id
    sql: ${TABLE}.CUSTOMER_ID ;;
  }

  dimension: customer_name {
    type: string
    html:<font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/companies/{{ past_due_60_no_pmt_30.customer_id }}" target="_blank">{{value}}</a></font></u>;;
    sql: ${TABLE}.CUSTOMER_NAME ;;
  }

  dimension: oldest_due_date {
    type: date
    sql: ${TABLE}.OLDEST_DUE_DATE ;;
  }

  dimension: days_past_due {
    type: number
    sql: ${TABLE}.DAYS_PAST_DUE ;;
  }

  dimension: managed_billing {
    type: string
    sql: IFF(${TABLE}.MANAGED_BILLING = 'false','No','Yes') ;;
  }

  dimension: national_account {
    type: string
    sql: IFF(${TABLE}.NATIONAL_ACCOUNT = 'false','No','Yes') ;;
  }

  dimension: master_service_agreement {
    type: string
    sql: IFF(${TABLE}.MASTER_SERVICE_AGREEMENT = 'false','No','Yes') ;;
  }

  dimension: dnr {
    label: "DNR (Yes/No)"
    type: string
    sql: IFF(${TABLE}.DNR = 'false','No','Yes') ;;
  }


  dimension: most_recent_payment_date {
    type: date
    sql: ${TABLE}.MOST_RECENT_PAYMENT_DATE ;;
  }

  dimension: days_since_last_payment {
    type: number
    sql: ${TABLE}.DAYS_SINCE_LAST_PAYMENT ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}.COLLECTOR ;;
  }


  dimension: manager {
    type: string
    sql: ${TABLE}.MANAGER ;;
  }

  dimension: tam {
    label: "TAM"
    type: string
    sql: ${TABLE}.TAM ;;
  }

  dimension: tam_email {
    label: "TAM Email"
    type: string
    sql: ${TABLE}.TAM_EMAIL ;;
  }

  ####### MEASURES #######

  measure: owed_amount {
    label: "Balance"
    value_format_name: usd_0
    type: sum
    #drill_fields: [trx_details*]
    sql: ${TABLE}.OWED_AMOUNT ;;
  }

  ####### DRILL FIELDS #######

  #set: trx_details {
  #  fields: [customer_id,customer_name,oldest_due_date,days_past_due,managed_billing,national_account,master_service_agreement,dnr,
  #    most_recent_payment_date,days_since_last_payment,owed_amount]
  #}

  }
