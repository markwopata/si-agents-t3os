view: wty_pmt_on_hold {
  derived_table: {
    sql: SELECT DISTINCT ARPAY.PAYMENT_ID                                                                          AS PAYMENT_ID,
                CONCAT('WTY_PMT_ID:', ARPAY.PAYMENT_ID)                                                   AS PAYMENT_REF,
                CASE
                    WHEN CAST(CONVERT_TIMEZONE('America/Chicago', ARPAY.PAYMENT_DATE) AS DATE) <= LC.LAST_CLOSE_DATE
                        THEN DATEADD(DAY, 1, LC.LAST_CLOSE_DATE)
                    ELSE CAST(CONVERT_TIMEZONE('America/Chicago', ARPAY.PAYMENT_DATE) AS DATE) END        AS PAYMENT_DATE,
                YEAR(CASE
                         WHEN CAST(CONVERT_TIMEZONE('America/Chicago', ARPAY.PAYMENT_DATE) AS DATE) <=
                              LC.LAST_CLOSE_DATE
                             THEN DATEADD(DAY, 1, LC.LAST_CLOSE_DATE)
                         ELSE CAST(CONVERT_TIMEZONE('America/Chicago', ARPAY.PAYMENT_DATE) AS DATE) END)  AS YEAR,
                MONTH(CASE
                          WHEN CAST(CONVERT_TIMEZONE('America/Chicago', ARPAY.PAYMENT_DATE) AS DATE) <=
                               LC.LAST_CLOSE_DATE
                              THEN DATEADD(DAY, 1, LC.LAST_CLOSE_DATE)
                          ELSE CAST(CONVERT_TIMEZONE('America/Chicago', ARPAY.PAYMENT_DATE) AS DATE) END) AS MONTH,
                DAY(CASE
                        WHEN CAST(CONVERT_TIMEZONE('America/Chicago', ARPAY.PAYMENT_DATE) AS DATE) <= LC.LAST_CLOSE_DATE
                            THEN DATEADD(DAY, 1, LC.LAST_CLOSE_DATE)
                        ELSE CAST(CONVERT_TIMEZONE('America/Chicago', ARPAY.PAYMENT_DATE) AS DATE) END)   AS DAY,
                ARPAY.COMPANY_ID                                                                          AS CUSTOMER,
                CUST.NAME                                                                                 AS CUSTOMER_NAME,
                CASE
                    WHEN INTCUST.VENDOR_ID_REF IS NULL THEN 'Customer is missing Vendor reference'
                    ELSE '-' END                                                                          AS VENDOR_CHECK,
                INTCUST.VENDOR_ID_REF                                                                     AS VENDOR_ID,
                INTCUST.NAME                                                                              AS VENDOR_NAME,
                TRUEBRANCH.BRANCH_ID                                                                      AS BRANCH,
                TRUEBRANCH.T3_BRANCH_ID,
                CASE
                    WHEN DEPT.STATUS != 'active' THEN 'Inactive branch'
                    WHEN TRUEBRANCH.BRANCH_ID IS NULL THEN 'Invalid branch'
                    ELSE '-' END                                                                          AS BRANCH_CHECK,
                ARPAY.PAYMENT_METHOD_ID,
                ARPAY.PAYMENT_METHOD_TYPE_ID,
                (ARPAY.AMOUNT) * -1                                                                       AS PAYMENT_AMOUNT,
                ARPAY.AMOUNT_REMAINING                                                                    AS AMOUNT_REMAINING,
                ARPAY.STATUS,
                ARPAY.REFERENCE                                                                           AS CM_NUMBER,
                CONCAT(UI.FIRST_NAME, ' ', UI.LAST_NAME)                                                  AS USER_NAME,
                UI.EMAIL_ADDRESS                                                                          AS USER_EMAIL,
                BANK_ERP.INTACCT_BANK_ACCOUNT_ID                                                          AS BANK_ACCOUNT,
                BANK_ERP.INTACCT_UNDEPFUNDSACCT                                                           AS UNDEPOSITED_FUNDS_ACCOUNT,
                BANK_ERP.ERP_INSTANCE_ID,
                CONVERT_TIMEZONE('America/Chicago', ARPAY.DATE_CREATED)                                   AS CREATE_DATE,
                DATEDIFF(DAY,CREATE_DATE,CURRENT_DATE)                                                    AS DAYS_ON_HOLD,
                SUM(PAY_APPLY.AMOUNT) * -1                                                                AS INV_APPLIED_AMOUNT,
                CASE
                    WHEN PAY_APPLY.INVOICE_ID IS NULL THEN 'Not applied to invoice'
                    WHEN INTCUST.VENDOR_ID_REF IS NULL THEN 'No vendor mapping for customer'
                    ELSE '-' END                                                                          AS ERROR
FROM ES_WAREHOUSE.PUBLIC.PAYMENTS ARPAY
         LEFT JOIN ES_WAREHOUSE.PUBLIC.BANK_ACCOUNT_ERP_REFS BANK_ERP
                   ON ARPAY.BANK_ACCOUNT_ID = BANK_ERP.BANK_ACCOUNT_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS UI ON ARPAY.CREATED_BY_USER_ID = UI.USER_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS PAY_APPLY ON ARPAY.PAYMENT_ID = PAY_APPLY.PAYMENT_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES ADMINV ON PAY_APPLY.INVOICE_ID = ADMINV.INVOICE_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES CUST ON ARPAY.COMPANY_ID = CUST.COMPANY_ID
         LEFT JOIN ANALYTICS.INTACCT.CUSTOMER INTCUST ON TO_CHAR(ARPAY.COMPANY_ID) = INTCUST.CUSTOMERID
         LEFT JOIN(SELECT DISTINCT INVH1.INVOICE_ID             AS INVOICE_ID,
                                   INVD1.BRANCH_ID              AS T3_BRANCH_ID,
                                   BERPR1.INTACCT_DEPARTMENT_ID AS BRANCH_ID
                   FROM ES_WAREHOUSE.PUBLIC.INVOICES INVH1
                            LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEMS INVD1 ON INVH1.INVOICE_ID = INVD1.INVOICE_ID
                            LEFT JOIN ES_WAREHOUSE.PUBLIC.BRANCH_ERP_REFS BERPR1
                                      ON INVD1.BRANCH_ID = BERPR1.BRANCH_ID) TRUEBRANCH
                  ON ADMINV.INVOICE_ID = TRUEBRANCH.INVOICE_ID
         LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON TRUEBRANCH.BRANCH_ID = DEPT.DEPARTMENTID
         LEFT JOIN(SELECT DISTINCT SUBSTR(APR.DOCNUMBER, 12, 100) AS PAYMENT_ID
                   FROM ANALYTICS.INTACCT.APRECORD APR
                   WHERE APR.RECORDTYPE = 'apbill'
                     AND APR.DOCNUMBER LIKE ('WTY_PMT_ID:%%')) PMT_ID_SYNCED
                  ON TO_VARCHAR(ARPAY.PAYMENT_ID) = PMT_ID_SYNCED.PAYMENT_ID
         LEFT JOIN (SELECT DISTINCT CREATE_WTPAY.CHECK_FIELD
                    FROM ANALYTICS.PUBLIC.INTACCT_CREATE_WTYPAYS_API_JOB_RESULTS CREATE_WTPAY) FAIL_COUNT
                   ON FAIL_COUNT.CHECK_FIELD = ARPAY.PAYMENT_ID
         LEFT JOIN (SELECT MAX(LAST_CLOSED_DATE) AS LAST_CLOSE_DATE
                    FROM ANALYTICS.CONCUR.LAST_CLOSE_DATE_AP) LC
WHERE BANK_ERP.INTACCT_UNDEPFUNDSACCT IN ('2303')
  AND ARPAY.STATUS != 1 --PAYMENT NOT REVERSED
  AND PMT_ID_SYNCED.PAYMENT_ID IS NULL
  AND (INTCUST.VENDOR_ID_REF IS NULL OR PAY_APPLY.AMOUNT IS NULL)
-- AND CREATE_DATE > '2024-07-31'
  AND FAIL_COUNT.CHECK_FIELD IS NULL
GROUP BY
    ALL
ORDER BY ARPAY.PAYMENT_ID ASC,
         ARPAY.REFERENCE ASC,
         TRUEBRANCH.BRANCH_ID;;
  }

  measure: count {type: count_distinct sql: ${TABLE}."PAYMENT_ID";;}
  dimension: payment_id {type: string sql: ${TABLE}."PAYMENT_ID" ;; html: <a href='https://admin.equipmentshare.com/#/home/payments/{{ payment_id._value }}' target='_blank' style='color: blue;'>{{ payment_id._value | escape }}</a> ;;}
  dimension: error {type: string sql: ${TABLE}."ERROR" ;;}
  dimension: payment_ref {type: string sql: ${TABLE}."PAYMENT_REF" ;;}
  dimension: payment_date {convert_tz: no type: date sql: ${TABLE}."PAYMENT_DATE" ;;}
  dimension: year {type: number sql: ${TABLE}."YEAR" ;;}
  dimension: month {type: number sql: ${TABLE}."MONTH" ;;}
  dimension: day {type: number sql: ${TABLE}."DAY" ;;}
  dimension: customer {type: string sql: ${TABLE}."CUSTOMER" ;;}
  dimension: customer_name {type: string sql: ${TABLE}."CUSTOMER_NAME" ;;}
  dimension: vendor_check {type: string sql: ${TABLE}."VENDOR_CHECK" ;;}
  dimension: vendor_id {type: string sql: ${TABLE}."VENDOR_ID" ;;}
  dimension: vendor_name {type: string sql: ${TABLE}."VENDOR_NAME" ;;}
  dimension: branch {type: string sql: ${TABLE}."BRANCH" ;;}
  dimension: branch_check {type: string sql: ${TABLE}."BRANCH_CHECK" ;;}
  dimension: payment_method_id {type: string sql: ${TABLE}."PAYMENT_METHOD_ID" ;;}
  dimension: payment_method_type_id {type: string sql: ${TABLE}."PAYMENT_METHOD_TYPE_ID" ;;}
  measure: payment_amount {type: sum sql: ${TABLE}."PAYMENT_AMOUNT" ;;}
  measure: amount_remaining {type: sum sql: ${TABLE}."AMOUNT_REMAINING" ;;}
  dimension: status {type: string sql: ${TABLE}."STATUS" ;;}
  dimension: cm_number {type: string sql: ${TABLE}."CM_NUMBER" ;;}
  dimension: user_name {type: string sql: ${TABLE}."USER_NAME" ;;}
  dimension: user_email {type: string sql: ${TABLE}."USER_EMAIL" ;;}
  dimension: bank_account {type: string sql: ${TABLE}."BANK_ACCOUNT" ;;}
  dimension: undeposited_funds_account {type: string sql: ${TABLE}."UNDEPOSITED_FUNDS_ACCOUNT" ;;}
  dimension: erp_instance_id {type: string sql: ${TABLE}."ERP_INSTANCE_ID" ;;}
  dimension: create_date {convert_tz: no type: date sql: ${TABLE}."CREATE_DATE" ;;}
  measure: inv_applied_amount {type: sum sql: ${TABLE}."INV_APPLIED_AMOUNT" ;;}
  measure: days {type: max sql: ${TABLE}."DAYS_ON_HOLD" ;;}

  set: detail {
    fields: [

      payment_id,
      error,
      payment_ref,
      payment_date,
      year,
      month,
      day,
      customer,
      customer_name,
      vendor_check,
      vendor_id,
      vendor_name,
      branch,
      branch_check,
      payment_method_id,
      payment_method_type_id,
      payment_amount,
      amount_remaining,
      status,
      cm_number,
      user_name,
      user_email,
      bank_account,
      undeposited_funds_account,
      erp_instance_id,
      create_date,
      inv_applied_amount,
      days
    ]
  }
}
