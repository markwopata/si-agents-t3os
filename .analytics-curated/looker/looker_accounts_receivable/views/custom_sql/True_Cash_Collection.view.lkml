view: True_Cash_Collection {
  derived_table: {
    sql:

WITH payment_data AS (
  SELECT
    C.COMPANY_ID,
    C.NAME,
    P.PAYMENT_ID,
    P.AMOUNT,
    P.PAYMENT_DATE,
    ROW_NUMBER() OVER (
      PARTITION BY C.COMPANY_ID, P.PAYMENT_ID
      ORDER BY P.PAYMENT_DATE DESC
    ) AS rn
  FROM ES_WAREHOUSE.PUBLIC.COMPANIES C
  LEFT JOIN ES_WAREHOUSE.PUBLIC.PAYMENTS P
      ON C.COMPANY_ID = P.COMPANY_ID
  LEFT JOIN ES_WAREHOUSE.PUBLIC.BANK_ACCOUNT_ERP_REFS RF
      ON P.BANK_ACCOUNT_ID = RF.BANK_ACCOUNT_ID
  INNER JOIN ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS PY
      ON PY.PAYMENT_ID = P.PAYMENT_ID
  WHERE
    RF.intacct_bank_account_id IS NOT NULL
    AND P.STATUS NOT IN (1, 3)
),

latest_payments AS (
  SELECT *
  FROM payment_data
  WHERE rn = 1
)

SELECT
  COMPANY_ID,
  NAME AS CUSTOMER_NAME,
  AMOUNT,
  PAYMENT_ID,
  PAYMENT_DATE
FROM latest_payments
;;}


  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: payment_id {
    type: number
    sql: ${TABLE}.payment_id ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}.customer_name ;;
  }


  dimension: amount {
    type: number
    sql: ${TABLE}.amount ;;
    }

  dimension:  payment_date {
    type: date
    sql: ${TABLE}.payment_date ;;
  }

 }
