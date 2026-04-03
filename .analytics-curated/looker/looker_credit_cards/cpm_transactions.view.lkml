
view: cpm_transactions {
  derived_table: {
    sql: WITH transaction_list AS (
          SELECT
              TV.PK_TRANSACTION,
              TV.PK_UPLOAD,
              TV.TRANSACTION_ID,
              TV.TRANSACTION_DATE,
              TV.TRANSACTION_AMOUNT,
              TV.TRANSACTION_MERCHANT_NAME,
              TV.TRANSACTION_MCC_CODE,
              TV.TRANSACTION_MCC,
              TV.TRANSACTION_CARD_TYPE,
              TV.UPLOAD_ID,
              TV.UPLOAD_DATE,
              TV.UPLOAD_AMOUNT,
              TV.EMPLOYEE_ID AS TV_EMPLOYEE_ID,
              TV.FULL_NAME,
              TV.WORK_EMAIL,
              TV.TRANSACTION_DEFAULT_COST_CENTERS_FULL_PATH,
              TV.TRANSACTION_CARD_HOLDER_NAME,
              TV.UPLOAD_MARKET_ID,
              MD.MARKET_NAME,
              TV.UPLOAD_MARKET_VERIFIED,
              TV.SUB_DEPARTMENT_ID,
              TV.SUB_DEPARTMENT,
              TV.EXPENSE_LINE_ID,
              TV.EXPENSE_LINE,
              CASE
                  WHEN TV.FULL_NAME = 'NAVANTRAVEL DEPARTMENT' THEN 1
                  ELSE TV.VERIFIED_STATUS
              END AS VERIFIED_STATUS,
              CASE
                  WHEN TV.FULL_NAME = 'NAVANTRAVEL DEPARTMENT' THEN 'Verified'
                  ELSE TV.VERIFIED_STATUS_DESC
              END AS VERIFIED_STATUS_DESC,
              TV.UPLOAD_NOTES,
              TV.UPLOAD_URL,
              TV.UPLOAD_SUBMITTED_AT_DATE,
              TV.LOAD_SECTION,
              TV.RECORDTIMESTAMP,
              TV.UPLOAD_MODIFIED_AT_DATE,
              TV.CORPORATE_ACCOUNT_NAME
          FROM ANALYTICS.CREDIT_CARD.TRANSACTION_VERIFICATION TV
                    JOIN ANALYTICS.GS.MCC MCC ON TV.TRANSACTION_MCC_CODE = MCC.MCC_NO_
                    JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY CD ON TV.EMPLOYEE_ID = CD.EMPLOYEE_ID
                    LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK MD ON TV.UPLOAD_MARKET_ID = MD.MARKET_ID
          WHERE TV.VERIFIED_STATUS <> 2
              AND CD.DEFAULT_COST_CENTERS_FULL_PATH ILIKE '%Construction Project Managers%'
              AND TV.TRANSACTION_DATE >= '2025-01-01'
              AND MCC.INTACCT_ACCOUNT IN (6307, 6308, 7105, 7400, 7401, 7600, 7604)
      ),
      receipt_flatten AS (
          SELECT
              PK_TRANSACTION,
              REPLACE(REPLACE(REPLACE(C.VALUE::STRING, '[', ''), ']', ''), '"', '') AS RECEIPT_LIST_BY_PAGE
          FROM transaction_list,
               LATERAL SPLIT_TO_TABLE(UPLOAD_URL, ',') C
      )
      SELECT
          PEM.EMPLOYEE_TITLE AS "employee_title",
          PEM.WORK_LOCATION AS "work_location",
          INITCAP(CONCAT(U.FIRST_NAME, ' ', U.LAST_NAME)) AS "full_name",
          TL.TRANSACTION_CARD_TYPE AS "card_type",
          TL.TRANSACTION_DATE AS "transaction_date",
          TL.TRANSACTION_ID AS "transaction_id",
          TL.TRANSACTION_AMOUNT AS "transaction_amount",
          TL.TRANSACTION_MERCHANT_NAME AS "merchant_name",
          TL.TRANSACTION_MCC AS "transaction_mcc",
          TL.UPLOAD_MARKET_ID AS "market_id",
          TL.MARKET_NAME AS "market_name",
          TL.UPLOAD_NOTES AS "receipt_notes",
          TO_CHAR(TO_DATE(TL.UPLOAD_SUBMITTED_AT_DATE), 'YYYY-MM-DD') AS "receipt_upload_date_date",
          LISTAGG(DISTINCT RF.RECEIPT_LIST_BY_PAGE) AS "receipt_list"
      FROM transaction_list TL
      LEFT JOIN receipt_flatten RF ON TL.PK_TRANSACTION = RF.PK_TRANSACTION
      LEFT JOIN ANALYTICS.PUBLIC.PAYCOR_EMPLOYEES_MANAGERS PEM
          ON TRIM(LOWER(TL.WORK_EMAIL)) = TRIM(LOWER(PEM.EMPLOYEE_EMAIL))
      LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS U
          ON TRIM(LOWER(TL.WORK_EMAIL)) = TRIM(LOWER(U.EMAIL_ADDRESS))
      GROUP BY
          TL.UPLOAD_MARKET_ID,
          TL.MARKET_NAME,
          TL.TRANSACTION_DATE,
          TO_DATE(TL.UPLOAD_SUBMITTED_AT_DATE),
          PEM.EMPLOYEE_TITLE,
          U.FIRST_NAME,
          U.LAST_NAME,
          PEM.WORK_LOCATION,
          TL.TRANSACTION_CARD_TYPE,
          TL.TRANSACTION_ID,
          TL.TRANSACTION_AMOUNT,
          TL.TRANSACTION_MERCHANT_NAME,
          TL.TRANSACTION_MCC,
          TL.UPLOAD_NOTES ;;
    }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."market_id" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."market_name" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."employee_title" ;;
  }

  dimension: work_location {
    type: string
    sql: ${TABLE}."work_location" ;;
  }

  dimension: card_type {
    type: string
    sql: ${TABLE}."card_type" ;;
    html:
    {% if card_type._value == 'amex'  %}
    Amex
    {% elsif card_type._value == 'cent' %}
    Central Bank
    {% elsif card_type._value == 'citi' %}
    Citi
    {% elsif card_type._value == 'fuel' %}
    Fuel Card
    {% else %}
    Unknown
    {% endif %}
    ;;
  }

  dimension: transaction_date {
    type: date
    sql: TO_DATE(${TABLE}."transaction_date") ;;
  }

  dimension: transaction_id {
    type: string
    sql: ${TABLE}."transaction_id" ;;
  }

  dimension: transaction_amount {
    type: number
    sql: ${TABLE}."transaction_amount" ;;
  }

  dimension: merchant_name {
    type: string
    sql: ${TABLE}."merchant_name" ;;
  }

  dimension: transaction_mcc {
    type: string
    sql: ${TABLE}."transaction_mcc" ;;
  }

  dimension: receipt_notes {
    type: string
    sql: ${TABLE}."receipt_notes" ;;
  }

  dimension: receipt_upload_date {
    type: string
    sql: ${TABLE}."receipt_upload_date_date" ;;
  }

  dimension: cardholder {
    type: string
    sql: ${TABLE}."full_name" ;;
  }

  dimension: receipt_list_by_page {
    type: string
    html: <font color="blue"><u><a href ="{{rendered_value}}" target="_blank">{{rendered_value}}</a></font></u>;;
    sql: ${TABLE}."receipt_list" ;;
  }

  dimension: link_to_receipt {
    type: string
    html: <a href="{{rendered_value}}" target="_blank" style="color: #0063f3; text-decoration: underline;">Link to CC Receipt</a>;;
    sql: ${receipt_list_by_page} ;;
  }

  measure: receipt_list {
    label: "List of Receipt Links"
    type: list
    list_field: link_to_receipt
  }

  set: detail {
    fields: [
        employee_title,
  work_location,
  card_type,
  transaction_date,
  transaction_id,
  transaction_amount,
  merchant_name,
  transaction_mcc,
  receipt_notes,
  receipt_upload_date,
  receipt_list
    ]
  }
}
