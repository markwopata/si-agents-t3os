
view: admin_ar_payment_applications {
  derived_table: {
    sql: SELECT
          ARPAY.COMPANY_ID                                                      AS CUSTOMER,
          CUST.NAME                                                             AS CUSTOMER_NAME,
          ARPAY.PAYMENT_ID                                                      AS PAYMENT_ID,
          ARPAY.REFERENCE                                                       AS REFERENCE,
          ARPAY.STATUS                                                          AS PAYMENT_STATUS,
          CAST(CONVERT_TIMEZONE('America/Chicago', ARPAY.PAYMENT_DATE) AS DATE) AS PAYMENT_DATE,
          PAY_METHOD.NAME                                                       AS PAYMENT_METHOD,
          ROUND((ARPAY.AMOUNT), 2)                                              AS FULL_PAYMENT_AMOUNT,
          'E1'                                                                  AS ENTITY,
          TRUEBRANCH.BRANCH_ID                                                  AS BRANCH,
          BANK_ERP.INTACCT_BANK_ACCOUNT_ID                                      AS BANK_ACCOUNT,
          BANK_ERP.INTACCT_UNDEPFUNDSACCT                                       AS UNDEPOSITED_FUNDS_ACCOUNT,
          ADMINV.INVOICE_NO                                                     AS INVOICE_NUMBER,
          ROUND((PAY_APPLY.AMOUNT), 2)                                          AS INV_APPLIED_AMOUNT,
          CONVERT_TIMEZONE('America/Chicago', ARPAY.DATE_CREATED)               AS WHEN_CREATED,
          CONCAT(UI.FIRST_NAME, ' ', UI.LAST_NAME)                              AS CREATED_BY_USER_NAME,
          UI.EMAIL_ADDRESS                                                      AS CREATED_BY_USER_EMAIL
      FROM
          ES_WAREHOUSE.PUBLIC.PAYMENTS ARPAY
              LEFT JOIN ES_WAREHOUSE.PUBLIC.BANK_ACCOUNT_ERP_REFS BANK_ERP ON ARPAY.BANK_ACCOUNT_ID = BANK_ERP.BANK_ACCOUNT_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS UI ON ARPAY.CREATED_BY_USER_ID = UI.USER_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS PAY_APPLY ON ARPAY.PAYMENT_ID = PAY_APPLY.PAYMENT_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES ADMINV ON PAY_APPLY.INVOICE_ID = ADMINV.INVOICE_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES CUST ON ARPAY.COMPANY_ID = CUST.COMPANY_ID
              LEFT JOIN(SELECT DISTINCT
                            INVH1.INVOICE_ID             AS INVOICE_ID,
                            BERPR1.INTACCT_DEPARTMENT_ID AS BRANCH_ID
                        FROM
                            ES_WAREHOUSE.PUBLIC.INVOICES INVH1
                                LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEMS INVD1 ON INVH1.INVOICE_ID = INVD1.INVOICE_ID
                                LEFT JOIN ES_WAREHOUSE.PUBLIC.BRANCH_ERP_REFS BERPR1
                                          ON INVD1.BRANCH_ID = BERPR1.BRANCH_ID) TRUEBRANCH
                       ON ADMINV.INVOICE_ID = TRUEBRANCH.INVOICE_ID
              LEFT JOIN(SELECT DISTINCT
                            SUBSTR(APR.DOCNUMBER, 12, 100) AS PAYMENT_ID
                        FROM
                            ANALYTICS.INTACCT.APRECORD APR
                        WHERE
                              APR.RECORDTYPE = 'apbill'
                          AND APR.DOCNUMBER LIKE ('WTY_PMT_ID:%%')) PMT_ID_SYNCED
                       ON TO_VARCHAR(ARPAY.PAYMENT_ID) = PMT_ID_SYNCED.PAYMENT_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.PAYMENT_METHOD_TYPES PAY_METHOD
                        ON ARPAY.PAYMENT_METHOD_TYPE_ID = PAY_METHOD.PAYMENT_METHOD_TYPE_ID ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: customer {
    type: number
    sql: ${TABLE}."CUSTOMER" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: payment_id {
    type: number
    sql: ${TABLE}."PAYMENT_ID" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: payment_status {
    type: number
    sql: ${TABLE}."PAYMENT_STATUS" ;;
  }

  dimension: payment_date {
    type: date
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }

  dimension: payment_method {
    type: string
    sql: ${TABLE}."PAYMENT_METHOD" ;;
  }

  dimension: full_payment_amount {
    type: number
    sql: ${TABLE}."FULL_PAYMENT_AMOUNT" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: bank_account {
    type: string
    sql: ${TABLE}."BANK_ACCOUNT" ;;
  }

  dimension: undeposited_funds_account {
    type: string
    sql: ${TABLE}."UNDEPOSITED_FUNDS_ACCOUNT" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: inv_applied_amount {
    type: number
    sql: ${TABLE}."INV_APPLIED_AMOUNT" ;;
  }

  dimension_group: when_created {
    type: time
    sql: ${TABLE}."WHEN_CREATED" ;;
  }

  dimension: created_by_user_name {
    type: string
    sql: ${TABLE}."CREATED_BY_USER_NAME" ;;
  }

  dimension: created_by_user_email {
    type: string
    sql: ${TABLE}."CREATED_BY_USER_EMAIL" ;;
  }

  set: detail {
    fields: [
        customer,
	customer_name,
	payment_id,
	reference,
	payment_status,
	payment_date,
	payment_method,
	full_payment_amount,
	entity,
	branch,
	bank_account,
	undeposited_funds_account,
	invoice_number,
	inv_applied_amount,
	when_created_time,
	created_by_user_name,
	created_by_user_email
    ]
  }
}
